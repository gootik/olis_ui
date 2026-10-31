export function registerOlisListbox(Alpine) {
  Alpine.data("olisListbox", () => ({
    search: null,
    keys: [],
    init() {
      this.keys = this.readKeys();
      this.$nextTick(() => this.sync());
    },
    readKeys() {
      try {
        const keys = JSON.parse(this.$root.dataset.selectedKeys || "[]");
        return Array.isArray(keys) ? keys.filter((key) => typeof key === "string") : [];
      } catch (_) {
        return [];
      }
    },
    allItems() {
      const root = this.$root;
      return [...root.querySelectorAll('[role="option"]')].filter(
        (item) => item.closest("[data-olis-listbox]") === root,
      );
    },
    items() {
      return this.allItems().filter((item) => item.getAttribute("aria-disabled") !== "true");
    },
    setActive(item, scroll = false) {
      const root = this.$root;
      if (item) {
        root.setAttribute("aria-activedescendant", item.id);
      } else {
        root.removeAttribute("aria-activedescendant");
      }
      this.allItems().forEach((option) => {
        option.dataset.active = String(option === item);
      });
      if (item && scroll) {
        item.scrollIntoView({ block: "nearest" });
      }
    },
    paint() {
      if (this.$root.dataset.selectionMode === "none") {
        return;
      }
      this.allItems().forEach((option) => {
        const selected = this.keys.includes(option.dataset.key);
        option.setAttribute("aria-selected", String(selected));
        const indicator = option.querySelector("[data-olis-listbox-indicator]");
        if (indicator) {
          indicator.hidden = !selected;
        }
      });
    },
    sync() {
      if (!this.$root.isConnected) {
        return;
      }
      if (this.$root.dataset.controlled === "true") {
        this.keys = this.readKeys();
      }
      this.paint();
      const items = this.items();
      const active = items.find(
        (item) => item.id === this.$root.getAttribute("aria-activedescendant"),
      );
      this.setActive(
        active || items.find((item) => item.getAttribute("aria-selected") === "true") || items[0],
      );
    },
    emit(name, selector, detail) {
      this.$root.dispatchEvent(new CustomEvent(name, { bubbles: true, detail }));
      const button = this.$root.querySelector(selector);
      if (button) {
        queueMicrotask(() => {
          if (!button.isConnected) {
            return;
          }
          if ("keys" in detail) {
            button.setAttribute("phx-value-keys", JSON.stringify(detail.keys));
          }
          button.setAttribute("phx-value-value", detail.value);
          // LiveView includes a button's native value in click payloads.
          button.value = detail.value;
          if ("selected" in detail) {
            button.setAttribute("phx-value-selected", String(detail.selected));
          }
          button.click();
        });
      }
    },
    activate(option) {
      const root = this.$root,
        value = option.dataset.key,
        mode = root.dataset.selectionMode;
      if (mode !== "none" && value != null) {
        const wasSelected = this.keys.includes(value);
        const next =
          mode === "single"
            ? [value]
            : wasSelected
              ? this.keys.filter((key) => key !== value)
              : [...this.keys, value];
        const changed =
          next.length !== this.keys.length || next.some((key) => !this.keys.includes(key));
        if (changed) {
          if (root.dataset.controlled !== "true") {
            this.keys = next;
            this.paint();
          }
          this.emit("olis:listbox-selection-change", "[data-olis-listbox-selection-event]", {
            keys: next,
            value,
            selected: next.includes(value),
          });
        }
      }
      if (value != null) {
        this.emit("olis:listbox-action", "[data-olis-listbox-action-event]", { value });
      }
    },
    click(event) {
      const root = this.$root,
        option = event.target.closest?.('[role="option"]');
      if (
        !option ||
        option.closest("[data-olis-listbox]") !== root ||
        root.getAttribute("aria-disabled") === "true" ||
        option.getAttribute("aria-disabled") === "true"
      ) {
        return;
      }
      this.setActive(option);
      root.focus({ preventScroll: true });
      this.activate(option);
    },
    keydown(event) {
      const root = this.$root;
      if (
        event.target.closest?.("[data-olis-listbox]") !== root ||
        root.getAttribute("aria-disabled") === "true"
      ) {
        return;
      }
      const items = this.items(),
        current = items.findIndex((item) => item.id === root.getAttribute("aria-activedescendant"));
      if (!items.length) {
        return;
      }
      let index;
      if (event.key === "ArrowDown") {
        index = (current + 1) % items.length;
      } else if (event.key === "ArrowUp") {
        index = current < 0 ? items.length - 1 : (current - 1 + items.length) % items.length;
      } else if (event.key === "Home") {
        index = 0;
      } else if (event.key === "End") {
        index = items.length - 1;
      } else if (event.key === "Enter" || event.key === " ") {
        event.preventDefault();
        (items[current] || items[0]).click();
        return;
      } else if (event.key.length === 1 && !event.ctrlKey && !event.metaKey && !event.altKey) {
        const query = (
          (this.search && Date.now() - this.search.time < 700 ? this.search.text : "") + event.key
        ).toLocaleLowerCase();
        this.search = { text: query, time: Date.now() };
        const ordered = [...items.slice(current + 1), ...items.slice(0, current + 1)];
        const match = ordered.find((item) =>
          (
            item.dataset.textValue ||
            item.querySelector('[data-slot="label"]')?.textContent.trim() ||
            ""
          )
            .toLocaleLowerCase()
            .startsWith(query),
        );
        if (match) {
          event.preventDefault();
          this.setActive(match, true);
        }
        return;
      } else {
        return;
      }
      event.preventDefault();
      this.setActive(items[index], true);
    },
  }));
}

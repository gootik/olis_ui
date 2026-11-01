import { listBoxItemClasses, listBoxIndicatorClasses } from "../list-box-styles.js";

export function registerOlisSelect(Alpine) {
  Alpine.data("olisSelect", () => {
    const searches = new WeakMap();
    const supportsPopover =
      typeof HTMLElement !== "undefined" && typeof HTMLElement.prototype.showPopover === "function";
    let root,
      resetFrame = null,
      nativeAttributes = null;

    const parts = (container) => ({
      native: container.querySelector("[data-olis-native-select]"),
      ui: container.querySelector("[data-olis-select-ui]"),
      button: container.querySelector("[data-olis-select-trigger]"),
      popup: container.querySelector("[data-olis-select-popup]"),
      list: container.querySelector("[data-olis-select-list]"),
      error: container.querySelector("[data-olis-select-error]"),
    });
    const enabledItems = (list) =>
      Array.from(list.querySelectorAll('[role="option"]')).filter(
        (item) => item.getAttribute("aria-disabled") !== "true",
      );
    function setActive(button, item, scroll = false) {
      const list = document.getElementById(button.getAttribute("aria-controls"));
      list?.querySelectorAll('[role="option"]').forEach((option) => {
        option.dataset.active = String(option === item);
      });
      if (item) {
        button.setAttribute("aria-activedescendant", item.id);
      } else {
        button.removeAttribute("aria-activedescendant");
      }
      if (scroll && item) {
        item.scrollIntoView({ block: "nearest" });
      }
    }
    function syncName(native, ...targets) {
      const labelledby = native.getAttribute("aria-labelledby");
      const label =
        native.getAttribute("aria-label") ||
        Array.from(native.labels || [])
          .map((node) => node.textContent.trim())
          .join(" ")
          .trim();
      targets.forEach((target) => {
        if (labelledby) {
          target.setAttribute("aria-labelledby", labelledby);
          target.removeAttribute("aria-label");
        } else {
          target.removeAttribute("aria-labelledby");
          if (label) {
            target.setAttribute("aria-label", label);
          } else {
            target.removeAttribute("aria-label");
          }
        }
      });
    }
    function restoreNative(native) {
      if (!native || !nativeAttributes) {
        return;
      }
      for (const [name, value] of Object.entries(nativeAttributes)) {
        if (value == null) {
          native.removeAttribute(name);
        } else {
          native.setAttribute(name, value);
        }
      }
    }
    function sync(container, rebuild = false) {
      const { native, ui, button, popup, list, error } = parts(container);
      if (!native || !ui || !button || !popup || !list) {
        return;
      }
      if (native.multiple || native.size > 1) {
        if (popup.matches(":popover-open")) {
          popup.hidePopover();
        }
        ui.hidden = true;
        delete container.dataset.enhanced;
        restoreNative(native);
        return;
      }
      container.dataset.enhanced = "true";
      native.setAttribute("aria-hidden", "true");
      native.tabIndex = -1;
      ui.hidden = false;
      button.disabled = native.matches(":disabled");
      if (button.disabled && popup.matches(":popover-open")) {
        popup.hidePopover();
      }
      syncName(native, button, list);
      button.setAttribute("aria-required", String(native.required));
      if (native.getAttribute("aria-invalid") === "true" || !error.hidden) {
        button.setAttribute("aria-invalid", "true");
      } else {
        button.removeAttribute("aria-invalid");
      }
      const descriptions = [native.getAttribute("aria-describedby"), !error.hidden && error.id]
        .filter(Boolean)
        .join(" ");
      if (descriptions) {
        button.setAttribute("aria-describedby", descriptions);
      } else {
        button.removeAttribute("aria-describedby");
      }
      const chosen = native.selectedOptions[0];
      const value = button.querySelector("[data-olis-select-value]");
      value.textContent = chosen?.textContent || "";
      value.dataset.placeholder = String(!chosen || (chosen.value === "" && chosen.index === 0));
      if (!rebuild) {
        return;
      }
      const oldActive = list.querySelector('[data-active="true"]')?.dataset.index;
      list.replaceChildren();
      function appendOption(option, parent) {
        if (option.hidden) {
          return;
        }
        const index = option.index;
        const item = document.createElement("div");
        item.id = `${native.id}-option-${index}`;
        item.className = `${listBoxItemClasses} list-box-item--default`;
        item.setAttribute("role", "option");
        item.setAttribute("aria-selected", String(option.selected));
        const disabled =
          option.disabled ||
          (option.parentElement?.tagName === "OPTGROUP" && option.parentElement.disabled);
        if (disabled) {
          item.setAttribute("aria-disabled", "true");
          item.dataset.disabled = "true";
        }
        item.dataset.olisSelectOption = "";
        item.dataset.index = String(index);
        const label = document.createElement("span");
        label.dataset.slot = "label";
        label.textContent = option.textContent;
        item.appendChild(label);
        const indicator = document.createElement("span");
        indicator.className = listBoxIndicatorClasses;
        indicator.setAttribute("aria-hidden", "true");
        indicator.hidden = !option.selected;
        const svg = document.createElementNS("http://www.w3.org/2000/svg", "svg");
        svg.setAttribute("viewBox", "0 0 16 16");
        svg.setAttribute("fill", "none");
        svg.dataset.slot = "list-box-item-indicator--checkmark";
        const path = document.createElementNS("http://www.w3.org/2000/svg", "path");
        path.setAttribute("d", "M3.5 8l3 3 6-6");
        path.setAttribute("stroke", "currentColor");
        path.setAttribute("stroke-width", "2");
        path.setAttribute("stroke-linecap", "round");
        path.setAttribute("stroke-linejoin", "round");
        svg.appendChild(path);
        indicator.appendChild(svg);
        item.appendChild(indicator);
        parent.appendChild(item);
      }
      Array.from(native.children).forEach((child) => {
        if (child.tagName === "OPTGROUP") {
          if (child.hidden) {
            return;
          }
          const group = document.createElement("div");
          group.className = "list-box-section";
          group.setAttribute("role", "group");
          group.setAttribute("aria-label", child.label);
          const header = document.createElement("div");
          header.className = "header";
          header.setAttribute("aria-hidden", "true");
          header.textContent = child.label;
          group.appendChild(header);
          Array.from(child.children).forEach((option) => {
            appendOption(option, group);
          });
          list.appendChild(group);
        } else if (child.tagName === "OPTION") {
          appendOption(child, list);
        }
      });
      const enabled = enabledItems(list);
      const active =
        enabled.find((item) => item.dataset.index === oldActive) ||
        enabled.find((item) => native.options[Number(item.dataset.index)].selected) ||
        enabled[0];
      setActive(button, active);
    }
    function position(container) {
      const { button, popup } = parts(container);
      if (!button || !popup?.matches(":popover-open")) {
        return;
      }
      const anchor = button.getBoundingClientRect();
      popup.style.minWidth = `${Math.min(anchor.width, innerWidth - 16)}px`;
      const box = popup.getBoundingClientRect();
      popup.style.left = `${Math.max(8, Math.min(anchor.left, innerWidth - box.width - 8))}px`;
      popup.style.top = `${anchor.bottom + 4 + box.height <= innerHeight - 8 ? anchor.bottom + 4 : Math.max(8, anchor.top - box.height - 4)}px`;
    }
    function choose(container, item) {
      if (!item || item.getAttribute("aria-disabled") === "true") {
        return;
      }
      const { native, button, popup, error } = parts(container);
      const previous = native.value;
      native.selectedIndex = Number(item.dataset.index);
      error.hidden = true;
      error.textContent = "";
      sync(container, true);
      if (popup.matches(":popover-open")) {
        popup.hidePopover();
      }
      button.focus({ preventScroll: true });
      if (native.value !== previous) {
        native.dispatchEvent(new Event("change", { bubbles: true }));
      }
    }
    function onClick(event) {
      const item = event.target.closest?.("[data-olis-select-option]");
      if (item && item.closest("[data-olis-select-root]") === root) {
        choose(item.closest("[data-olis-select-root]"), item);
        return;
      }
      const label = event.target.closest?.("label");
      const native = label?.control;
      if (
        native?.matches("[data-olis-native-select]") &&
        native.closest("[data-olis-select-root]") === root &&
        root.dataset.enhanced === "true" &&
        !event.target.closest("button, a, input, select")
      ) {
        event.preventDefault();
        parts(native.closest("[data-olis-select-root]")).button.focus();
      }
    }
    function onToggle(event) {
      const popup = event.target;
      if (
        !popup.matches?.("[data-olis-select-popup]") ||
        popup.closest("[data-olis-select-root]") !== root
      ) {
        return;
      }
      const container = popup.closest("[data-olis-select-root]"),
        { button } = parts(container);
      const open = popup.matches(":popover-open");
      button.setAttribute("aria-expanded", String(open));
      if (open) {
        sync(container, true);
        position(container);
        button.focus({ preventScroll: true });
      } else {
        button.removeAttribute("aria-activedescendant");
      }
    }
    function onKeyDown(event) {
      const button = event.target.closest?.("[data-olis-select-trigger]");
      if (!button || button.closest("[data-olis-select-root]") !== root || button.disabled) {
        return;
      }
      const container = button.closest("[data-olis-select-root]"),
        { popup, list } = parts(container);
      const open = popup.matches(":popover-open");
      if (!open && (event.key === "ArrowDown" || event.key === "ArrowUp")) {
        event.preventDefault();
        popup.showPopover();
        return;
      }
      if (!open) {
        return;
      }
      const items = enabledItems(list),
        index = items.findIndex((item) => item.id === button.getAttribute("aria-activedescendant"));
      if (event.key === "Escape") {
        event.preventDefault();
        popup.hidePopover();
        return;
      }
      if (event.key === "Tab") {
        popup.hidePopover();
        return;
      }
      if (event.key === "Enter" || event.key === " ") {
        event.preventDefault();
        choose(container, items[index]);
        return;
      }
      let next;
      if (event.key === "ArrowDown") {
        next = items[Math.min(index + 1, items.length - 1)];
      } else if (event.key === "ArrowUp") {
        next = items[Math.max(index - 1, 0)];
      } else if (event.key === "Home") {
        next = items[0];
      } else if (event.key === "End") {
        next = items.at(-1);
      } else if (event.key.length === 1 && !event.ctrlKey && !event.metaKey && !event.altKey) {
        const previous = searches.get(button),
          query = (
            (previous && Date.now() - previous.time < 700 ? previous.text : "") + event.key
          ).toLocaleLowerCase();
        searches.set(button, { text: query, time: Date.now() });
        const ordered = [...items.slice(index + 1), ...items.slice(0, index + 1)];
        next = ordered.find((item) =>
          item
            .querySelector('[data-slot="label"]')
            .textContent.trim()
            .toLocaleLowerCase()
            .startsWith(query),
        );
      } else {
        return;
      }
      event.preventDefault();
      if (next) {
        setActive(button, next, true);
      }
    }
    function onInvalid(event) {
      const native = event.target;
      if (!native.matches?.("[data-olis-native-select]")) {
        return;
      }
      const container = native.closest("[data-olis-select-root]");
      if (container !== root || container.dataset.enhanced !== "true") {
        return;
      }
      event.preventDefault();
      const { button, error } = parts(container);
      error.textContent = native.validationMessage;
      error.hidden = false;
      sync(container);
      button.focus();
    }
    function syncAll() {
      if (root?.isConnected) {
        sync(root, true);
      }
    }
    function reposition() {
      if (root?.dataset.enhanced === "true") {
        position(root);
      }
    }
    return {
      init() {
        root = this.$root;
        const native = parts(root).native;
        if (native) {
          nativeAttributes = {
            "aria-hidden": native.getAttribute("aria-hidden"),
            tabindex: native.getAttribute("tabindex"),
          };
        }
        if (supportsPopover) {
          syncAll();
        }
      },
      destroy() {
        if (resetFrame != null) {
          cancelAnimationFrame(resetFrame);
        }
        if (!supportsPopover || !root) {
          return;
        }
        const { native, ui, popup } = parts(root);
        if (popup?.matches(":popover-open")) {
          popup.hidePopover();
        }
        if (ui) {
          ui.hidden = true;
        }
        restoreNative(native);
        delete root.dataset.enhanced;
      },
      click(event) {
        if (supportsPopover) {
          onClick(event);
        }
      },
      keydown(event) {
        if (supportsPopover) {
          onKeyDown(event);
        }
      },
      toggle(event) {
        if (supportsPopover) {
          onToggle(event);
        }
      },
      invalid(event) {
        if (supportsPopover) {
          onInvalid(event);
        }
      },
      change(event) {
        if (supportsPopover && event.target === parts(root).native) {
          syncAll();
        }
      },
      reset(event) {
        if (!supportsPopover || event.target !== parts(root).native?.form) {
          return;
        }
        if (resetFrame != null) {
          cancelAnimationFrame(resetFrame);
        }
        resetFrame = requestAnimationFrame(() => {
          resetFrame = null;
          syncAll();
        });
      },
      sync() {
        if (supportsPopover) {
          syncAll();
        }
      },
      position() {
        if (supportsPopover) {
          reposition();
        }
      },
    };
  });
}

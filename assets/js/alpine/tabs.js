export function registerOlisTabs(Alpine) {
  Alpine.data("olisTabs", () => ({
    selected: null,
    focused: null,
    before: false,
    after: false,
    observer: null,
    init() {
      this.selected = this.$root.dataset.initialKey;
      this.focused = this.selected;
      this.$watch("selected", (key, previous) => {
        if (!previous || matchMedia("(prefers-reduced-motion: reduce)").matches) {
          return;
        }
        const tabs = this.tabs(),
          from = tabs.find((tab) => tab.dataset.key === previous),
          to = tabs.find((tab) => tab.dataset.key === key);
        if (!from || !to) {
          return;
        }
        const start = from.getBoundingClientRect(),
          end = to.getBoundingClientRect();
        if (!start.width || !start.height || !end.width || !end.height) {
          return;
        }
        this.$nextTick(() =>
          to.querySelector(".tabs__indicator")?.animate(
            [
              {
                transformOrigin: "top left",
                transform: `translate(${start.left - end.left}px, ${start.top - end.top}px) scale(${start.width / end.width}, ${start.height / end.height})`,
              },
              { transformOrigin: "top left", transform: "none" },
            ],
            { duration: 250, easing: "cubic-bezier(0.22, 1, 0.36, 1)" },
          ),
        );
      });
      this.$nextTick(() => {
        if (typeof ResizeObserver !== "undefined") {
          this.observer = new ResizeObserver(() => this.updateScroll());
          this.observer.observe(this.$refs.scroller);
          this.observer.observe(this.$refs.list);
        }
        this.updateScroll();
      });
    },
    destroy() {
      this.observer?.disconnect();
    },
    tabs() {
      return [...this.$refs.list.querySelectorAll('[role="tab"]')].filter(
        (tab) => tab.closest("[data-olis-tabs]") === this.$root && !tab.disabled,
      );
    },
    sync() {
      const tabs = this.tabs();
      const controlled = this.$root.dataset.controlled === "true";
      const desired = controlled ? this.$root.dataset.selectedKey : this.selected;
      const available = tabs.find((tab) => tab.dataset.key === desired);
      if (controlled || !available) {
        this.selected = (available || tabs[0])?.dataset.key;
        if (
          !this.$refs.list.contains(document.activeElement) ||
          !tabs.some((tab) => tab.dataset.key === this.focused)
        ) {
          this.focused = this.selected;
        }
      }
      this.updateScroll();
    },
    select(key) {
      if (!this.tabs().some((tab) => tab.dataset.key === key)) {
        return;
      }
      this.focused = key;
      if (this.selected === key) {
        return;
      }
      if (this.$root.dataset.controlled !== "true") {
        this.selected = key;
      }
      this.$dispatch("olis:tabs-change", { key });
      const eventButton = this.$refs.changeEvent;
      if (eventButton) {
        eventButton.setAttribute("phx-value-key", key);
        eventButton.click();
      }
    },
    keydown(event) {
      const tabs = this.tabs(),
        current = tabs.indexOf(event.target.closest('[role="tab"]'));
      if (current < 0 || !tabs.length) {
        return;
      }
      const vertical = this.$root.dataset.orientation === "vertical";
      const rtl = getComputedStyle(this.$root).direction === "rtl";
      let index;
      if (event.key === "Home") {
        index = 0;
      } else if (event.key === "End") {
        index = tabs.length - 1;
      } else if (event.key === (vertical ? "ArrowDown" : rtl ? "ArrowLeft" : "ArrowRight")) {
        index = (current + 1) % tabs.length;
      } else if (event.key === (vertical ? "ArrowUp" : rtl ? "ArrowRight" : "ArrowLeft")) {
        index = (current - 1 + tabs.length) % tabs.length;
      } else {
        return;
      }
      event.preventDefault();
      const next = tabs[index];
      this.focused = next.dataset.key;
      if (this.$root.dataset.activationMode !== "manual") {
        this.select(next.dataset.key);
      }
      next.focus({ preventScroll: true });
      next.scrollIntoView({ block: "nearest", inline: "nearest" });
    },
    leave(event) {
      if (!this.$refs.list.contains(event.relatedTarget)) {
        this.focused = this.selected;
      }
    },
    updateScroll() {
      const scroller = this.$refs.scroller;
      if (!scroller) {
        return;
      }
      const vertical = this.$root.dataset.orientation === "vertical";
      const extent = vertical
        ? scroller.scrollHeight - scroller.clientHeight
        : scroller.scrollWidth - scroller.clientWidth;
      const position = vertical ? scroller.scrollTop : Math.abs(scroller.scrollLeft);
      this.before = extent > 0.5 && position > 0.5;
      this.after = extent > 0.5 && position < extent - 0.5;
    },
    scroll(direction) {
      const vertical = this.$root.dataset.orientation === "vertical";
      const rtl = getComputedStyle(this.$root).direction === "rtl";
      const amount = (direction === "previous" ? -1 : 1) * 160;
      const behavior = matchMedia("(prefers-reduced-motion: reduce)").matches
        ? "instant"
        : "smooth";
      this.$refs.scroller.scrollBy(
        vertical ? { top: amount, behavior } : { left: rtl ? -amount : amount, behavior },
      );
    },
  }));
}

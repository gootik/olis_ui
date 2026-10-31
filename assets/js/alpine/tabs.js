export function registerOlisTabs(Alpine) {
  Alpine.data("olisTabs", () => ({
    selected: null,
    focused: null,
    before: false,
    after: false,
    observer: null,

    init() {
      this.selected = this.$root.dataset.selectedKey;
      this.focused = this.selected;
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
      this.selected = this.$root.dataset.selectedKey;

      if (
        !this.$refs.list.contains(document.activeElement) ||
        !tabs.some((tab) => tab.dataset.key === this.focused)
      ) {
        this.focused = this.selected;
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

      this.$dispatch("olis:tabs-change", { key });
      const eventButton = this.$refs.changeEvent;

      if (eventButton) {
        eventButton.setAttribute("phx-value-key", key);
        eventButton.click();
      }
    },

    keydown(event) {
      const tabs = this.tabs();
      const current = tabs.indexOf(event.target.closest('[role="tab"]'));

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

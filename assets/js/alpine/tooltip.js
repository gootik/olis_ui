export function registerOlisTooltip(Alpine) {
  Alpine.data("olisTooltip", () => ({
    hovering: false,
    focused: false,
    suppressed: false,
    openTimer: null,
    closeTimer: null,
    observer: null,
    describedElement: null,
    describedId: null,
    descriptionAdded: false,

    init() {
      this.$nextTick(() => {
        this.connectDescription();
        this.sync();

        if (!this.$root.isConnected || typeof ResizeObserver === "undefined") {
          return;
        }

        this.observer = new ResizeObserver(() => this.position());

        if (this.$refs.trigger) {
          this.observer.observe(this.$refs.trigger);
        }

        if (this.$refs.content) {
          this.observer.observe(this.$refs.content);
        }
      });
    },

    destroy() {
      clearTimeout(this.openTimer);
      clearTimeout(this.closeTimer);
      this.observer?.disconnect();
      this.hide();
      this.disconnectDescription();
    },

    disconnectDescription() {
      const element = this.describedElement;
      const id = this.describedId;

      if (element && id && this.descriptionAdded) {
        const ids = (element.getAttribute("aria-describedby") || "")
          .split(/\s+/)
          .filter((value) => value && value !== id);

        if (ids.length) {
          element.setAttribute("aria-describedby", ids.join(" "));
        } else {
          element.removeAttribute("aria-describedby");
        }
      }

      this.describedElement = null;
      this.describedId = null;
      this.descriptionAdded = false;
    },

    connectDescription() {
      const anchor = this.$refs.trigger;
      const id = this.$refs.content?.id;

      if (!anchor || !id) {
        return;
      }

      const selector =
        'button, a[href], input:not([type="hidden"]), select, textarea, [tabindex], [role="button"], [contenteditable="true"]';
      const element = anchor.matches(selector) ? anchor : anchor.querySelector(selector);

      if (element !== this.describedElement || id !== this.describedId) {
        this.disconnectDescription();
        this.describedElement = element;
        this.describedId = id;
      }

      if (!element) {
        return;
      }

      const ids = (element.getAttribute("aria-describedby") || "").split(/\s+/).filter(Boolean);

      if (!ids.includes(id)) {
        element.setAttribute("aria-describedby", [...ids, id].join(" "));
        this.descriptionAdded = true;
      }
    },

    time(attribute, variable, fallback) {
      const explicit = this.$root.dataset[attribute];

      if (explicit !== undefined && explicit !== "") {
        return Math.max(0, Number(explicit) || 0);
      }

      const value = getComputedStyle(this.$root).getPropertyValue(variable).trim();

      if (!/^(?:\d+\.?\d*|\.\d+)\s*(?:ms|s)$/.test(value)) {
        return fallback;
      }

      const amount = parseFloat(value);

      return value.endsWith("ms") ? amount : amount * 1000;
    },

    enter(event) {
      if (event.pointerType === "touch") {
        return;
      }

      this.hovering = true;
      clearTimeout(this.closeTimer);
      this.showAfter(this.time("delay", "--tooltip-delay", 1500));
    },

    leave(event) {
      if (event.pointerType === "touch") {
        return;
      }

      this.hovering = false;
      this.maybeClose();
    },

    focus() {
      this.focused = true;
      clearTimeout(this.closeTimer);
      this.showAfter(0);
    },

    blur(event) {
      if (this.$root.contains(event.relatedTarget)) {
        return;
      }

      this.focused = false;
      this.maybeClose();
    },

    maybeClose() {
      if (this.hovering || this.focused) {
        return;
      }

      this.suppressed = false;
      clearTimeout(this.openTimer);
      clearTimeout(this.closeTimer);
      this.closeTimer = setTimeout(
        () => this.request(false, "leave"),
        this.time("closeDelay", "--tooltip-close-delay", 500),
      );
    },

    escape() {
      if (!this.hovering && !this.focused && !this.$refs.content?.matches(":popover-open")) {
        return;
      }

      this.suppressed = this.hovering || this.focused;
      clearTimeout(this.openTimer);
      clearTimeout(this.closeTimer);
      this.request(false, "escape");
    },

    showAfter(delay) {
      if (this.suppressed) {
        return;
      }

      clearTimeout(this.openTimer);
      this.openTimer = setTimeout(() => {
        const content = this.$refs.content;

        // The trigger may have lost focus or been removed while the timer ran.
        if (
          !content ||
          !this.$root.isConnected ||
          (!this.hovering && !this.focused) ||
          this.suppressed
        ) {
          return;
        }

        this.request(true, this.focused ? "focus" : "hover");
      }, delay);
    },

    request(open, reason) {
      const button = this.$root.querySelector(":scope > [data-olis-tooltip-event]");

      if (button) {
        button.setAttribute("phx-value-open", String(open));
        button.setAttribute("phx-value-reason", reason);
        button.click();
      }
    },

    sync() {
      const content = this.$refs.content;

      if (!content) {
        return;
      }

      if (this.$root.dataset.open === "true") {
        if (!content.matches(":popover-open")) {
          content.showPopover();
        }
        this.position();
      } else {
        this.hide();
      }
    },

    hide() {
      const content = this.$refs.content;

      if (content?.matches(":popover-open")) {
        content.hidePopover();
      }
    },

    updated() {
      this.$nextTick(() => {
        this.connectDescription();
        this.sync();

        if (this.observer) {
          this.observer.disconnect();

          if (this.$refs.trigger) {
            this.observer.observe(this.$refs.trigger);
          }

          if (this.$refs.content) {
            this.observer.observe(this.$refs.content);
          }
        }

        this.position();
      });
    },

    position() {
      const trigger = this.$refs.trigger;
      const content = this.$refs.content;

      if (!trigger || !content?.matches(":popover-open")) {
        return;
      }

      const anchor = trigger.getBoundingClientRect();
      const box = content.getBoundingClientRect();
      const gap = Number(this.$root.dataset.offset) || 0;
      const margin = 8;
      const width = window.innerWidth;
      const height = window.innerHeight;
      const preferred = this.$root.dataset.requestedPlacement || "top";
      const opposite = { top: "bottom", bottom: "top", left: "right", right: "left" };
      const space = {
        top: anchor.top - margin,
        bottom: height - anchor.bottom - margin,
        left: anchor.left - margin,
        right: width - anchor.right - margin,
      };
      const needed = (preferred === "top" || preferred === "bottom" ? box.height : box.width) + gap;
      const side =
        space[preferred] < needed && space[opposite[preferred]] > space[preferred]
          ? opposite[preferred]
          : preferred;
      let left = anchor.left + (anchor.width - box.width) / 2;
      let top = anchor.top + (anchor.height - box.height) / 2;

      if (side === "top") {
        top = anchor.top - box.height - gap;
      }

      if (side === "bottom") {
        top = anchor.bottom + gap;
      }

      if (side === "left") {
        left = anchor.left - box.width - gap;
      }

      if (side === "right") {
        left = anchor.right + gap;
      }

      left = Math.max(margin, Math.min(left, width - box.width - margin));
      top = Math.max(margin, Math.min(top, height - box.height - margin));
      content.style.left = `${left}px`;
      content.style.top = `${top}px`;
      content.dataset.placement = side;
      const arrow = content.querySelector('[data-slot="overlay-arrow"]');

      if (arrow) {
        if (side === "top" || side === "bottom") {
          arrow.style.left = `${Math.max(8, Math.min(box.width - 8, anchor.left + anchor.width / 2 - left))}px`;
          arrow.style.removeProperty("top");
        } else {
          arrow.style.top = `${Math.max(8, Math.min(box.height - 8, anchor.top + anchor.height / 2 - top))}px`;
          arrow.style.removeProperty("left");
        }
      }
    },
  }));
}

export function registerOlisPopover(Alpine) {
  Alpine.data("olisPopover", () => ({
    ignoredState: null,
    pendingReason: null,
    destroyed: false,
    motionTimer: null,

    trigger() {
      const ref = this.$refs.trigger;

      return ref?.matches("[data-olis-popover-trigger]")
        ? ref
        : ref?.querySelector("[data-olis-popover-trigger]");
    },

    init() {
      this.$nextTick(() => {
        if (this.destroyed || !this.$root) {
          return;
        }

        const open = this.$root.dataset.open === "true";
        if (open) {
          this.setOpen(true);
        }
      });
    },

    destroy() {
      this.destroyed = true;
      clearTimeout(this.motionTimer);
      const content = this.$refs.content;

      if (content?.matches(":popover-open")) {
        content.hidePopover();
      }
    },

    setOpen(open) {
      const content = this.$refs.content;

      if (
        !content ||
        typeof content.showPopover !== "function" ||
        open === content.matches(":popover-open")
      ) {
        return;
      }

      this.ignoredState = open;
      const restoreFocus = !open && content.contains(document.activeElement);

      if (open) {
        content.showPopover();
      } else {
        content.hidePopover();
      }

      this.updateExpanded();

      if (open) {
        this.position();
      } else if (restoreFocus) {
        this.trigger()?.focus({ preventScroll: true });
      }
    },

    updateExpanded() {
      const content = this.$refs.content;

      this.trigger()?.setAttribute("aria-expanded", String(!!content?.matches(":popover-open")));
    },

    position() {
      if (this.destroyed || !this.$root || this.$root.isConnected === false) {
        return;
      }

      const trigger = this.trigger();
      const content = this.$refs.content;

      if (!trigger || !content?.matches(":popover-open")) {
        return;
      }

      const anchor = trigger.getBoundingClientRect();
      const box = content.getBoundingClientRect();
      const margin = 8;
      let [side, align] = (this.$root.dataset.requestedPlacement || "bottom").split(" ");
      const offset = Number(this.$root.dataset.offset || 0);
      const opposite = { top: "bottom", bottom: "top", left: "right", right: "left" };
      const fits = {
        top: anchor.top - offset - box.height >= margin,
        bottom: anchor.bottom + offset + box.height <= window.innerHeight - margin,
        left: anchor.left - offset - box.width >= margin,
        right: anchor.right + offset + box.width <= window.innerWidth - margin,
      };

      if (this.$root.dataset.shouldFlip !== "false" && !fits[side] && fits[opposite[side]]) {
        side = opposite[side];
      }

      const rtl = getComputedStyle(trigger).direction === "rtl";
      let left;
      let top;

      if (side === "top" || side === "bottom") {
        top = side === "top" ? anchor.top - box.height - offset : anchor.bottom + offset;

        if (align === "start") {
          left = rtl ? anchor.right - box.width : anchor.left;
        } else if (align === "end") {
          left = rtl ? anchor.left : anchor.right - box.width;
        } else {
          left = anchor.left + (anchor.width - box.width) / 2;
        }
      } else {
        left = side === "left" ? anchor.left - box.width - offset : anchor.right + offset;

        if (align === "start") {
          top = anchor.top;
        } else if (align === "end") {
          top = anchor.bottom - box.height;
        } else {
          top = anchor.top + (anchor.height - box.height) / 2;
        }
      }

      content.style.left = `${Math.max(margin, Math.min(left, window.innerWidth - box.width - margin))}px`;
      content.style.top = `${Math.max(margin, Math.min(top, window.innerHeight - box.height - margin))}px`;
      content.dataset.placement = side;
    },

    notify(open, reason) {
      this.$root.dispatchEvent(
        new CustomEvent("olis:popover-open-change", { bubbles: true, detail: { open, reason } }),
      );
      const button = this.$root.querySelector(":scope > [data-olis-popover-event]");

      if (button) {
        button.setAttribute("phx-value-open", String(open));
        button.setAttribute("phx-value-reason", reason);
        button.click();
      }
    },

    onClick(event) {
      const content = this.$refs.content;
      const trigger = this.trigger();

      if (!content || !trigger) {
        return;
      }

      const targetTrigger = event.target.closest?.("[data-olis-popover-trigger]");

      if (targetTrigger === trigger && !trigger.matches(':disabled, [aria-disabled="true"]')) {
        event.preventDefault();
        this.notify(!content.matches(":popover-open"), "trigger");

        return;
      }

      const close = event.target.closest?.("[data-olis-popover-close]");

      if (
        !close ||
        close.closest("[data-olis-popover]") !== content ||
        !content.matches(":popover-open")
      ) {
        return;
      }

      this.notify(false, "close");
    },

    beforeToggle(event) {
      const content = this.$refs.content;

      if (event.target !== content) {
        return;
      }

      clearTimeout(this.motionTimer);
      delete content.dataset.entering;
      delete content.dataset.exiting;
      const reduce =
        content.closest?.('[data-reduce-motion="true"]') ||
        window.matchMedia?.("(prefers-reduced-motion: reduce)").matches;

      if (reduce) {
        return;
      }

      const state = event.newState === "open" ? "entering" : "exiting";

      content.dataset[state] = "true";
      // Browsers can omit animationend when an overlay is interrupted or removed.
      this.motionTimer = setTimeout(() => {
        delete content.dataset[state];
        this.motionTimer = null;
      }, 300);
    },

    animationEnd(event) {
      if (event.target !== this.$refs.content || !event.animationName.startsWith("olis-overlay-")) {
        return;
      }

      clearTimeout(this.motionTimer);
      this.motionTimer = null;
      delete this.$refs.content.dataset.entering;
      delete this.$refs.content.dataset.exiting;
    },

    toggle(event) {
      const content = this.$refs.content;

      if (this.destroyed || !this.$root || event.target !== content) {
        return;
      }

      const open = content.matches(":popover-open");

      this.updateExpanded();

      if (open) {
        this.position();
        this.$refs.dialog?.focus({ preventScroll: true });
      }

      if (this.ignoredState === open) {
        this.ignoredState = null;
        this.pendingReason = null;

        return;
      }

      this.ignoredState = null;

      const expected = this.$root.dataset.open === "true";

      if (open !== expected) {
        this.notify(open, "dismiss");
        this.setOpen(expected);
      }

      this.pendingReason = null;
    },

    sync() {
      if (this.destroyed || !this.$root || this.$root.isConnected === false) {
        return;
      }

      const content = this.$refs.content;

      if (!content) {
        return;
      }

      this.setOpen(this.$root.dataset.open === "true");

      this.updateExpanded();
      this.position();
    },
  }));
}

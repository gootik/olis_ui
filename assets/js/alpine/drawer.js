import { gestureAxis, gestureDirection } from "./gesture.js";

export function registerOlisDrawer(Alpine) {
  // Native dialog retains browser focus trapping and focus restoration.
  Alpine.data("olisDrawer", () => ({
    closing: false,
    animations: [],
    ignoredCloseEvents: 0,
    destroyed: false,
    drag: null,
    suppressClick: false,
    suppressClickTimer: null,
    init() {
      const dialog = this.$root;
      if (
        dialog.dataset.controlled === "true"
          ? dialog.dataset.controlledOpen === "true"
          : dialog.dataset.defaultOpen === "true"
      ) {
        this.show();
      }
    },
    destroy() {
      this.destroyed = true;
      clearTimeout(this.suppressClickTimer);
      this.releaseDrag();
      this.stopAnimations();
      this.$root.style.removeProperty("transform");
      if (this.$root.open) {
        this.$root.close();
      }
    },
    stopAnimations() {
      for (const animation of this.animations) {
        animation.cancel();
      }
      this.animations = [];
    },
    animate(opening, from = null) {
      const dialog = this.$root;
      if (
        typeof dialog.animate !== "function" ||
        window.matchMedia?.("(prefers-reduced-motion: reduce)").matches
      ) {
        return null;
      }
      const side = dialog.dataset.placement || "bottom";
      const direction = {
        top: "translateY(-100%)",
        bottom: "translateY(100%)",
        left: "translateX(-100%)",
        right: "translateX(100%)",
      }[side];
      const start = from || (opening ? direction : "translate(0, 0)");
      const end = opening ? "translate(0, 0)" : direction;
      const options = { duration: opening ? 250 : 200, easing: "cubic-bezier(0.32, 0.72, 0, 1)" };
      const panel = dialog.animate([{ transform: start }, { transform: end }], options);
      this.animations = [panel];
      try {
        const backdrop = dialog.animate(
          [{ opacity: opening ? 0 : 1 }, { opacity: opening ? 1 : 0 }],
          { ...options, pseudoElement: "::backdrop" },
        );
        this.animations.push(backdrop);
      } catch (_) {
        // The native backdrop remains usable when pseudo-element animation is unsupported.
      }
      for (const animation of this.animations) {
        animation.finished.catch(() => {});
      }
      return panel;
    },
    openFromTrigger(event) {
      const trigger = event.target.closest?.("[data-olis-dialog-open]");
      if (
        !trigger ||
        trigger.getAttribute("data-olis-dialog-open") !== this.$root.id ||
        trigger.matches(':disabled, [aria-disabled="true"]')
      ) {
        return;
      }
      this.request(true, "trigger");
    },
    notify(open, reason) {
      this.$root.dispatchEvent(
        new CustomEvent("olis:drawer-open-change", { bubbles: true, detail: { open, reason } }),
      );
      const button = this.$root.querySelector(":scope > [data-olis-drawer-event]");
      if (button) {
        button.setAttribute("phx-value-open", String(open));
        button.setAttribute("phx-value-reason", reason);
        button.click();
      }
    },
    request(open, reason) {
      if (open ? this.$root.open && !this.closing : !this.$root.open || this.closing) {
        return;
      }
      if (this.$root.dataset.controlled === "true") {
        this.notify(open, reason);
        return;
      }
      if (open) {
        this.show();
      } else {
        this.close();
      }
      this.notify(open, reason);
    },
    show() {
      if (this.$root.open) {
        if (this.closing) {
          this.closing = false;
          this.stopAnimations();
          this.$root.style.removeProperty("transform");
        }
        return;
      }
      this.closing = false;
      this.stopAnimations();
      this.$root.showModal();
      this.animate(true);
    },
    close() {
      if (!this.$root.open || this.closing) {
        return;
      }
      const from = getComputedStyle(this.$root).transform;
      this.releaseDrag();
      this.stopAnimations();
      this.closing = true;
      const panel = this.animate(false, from === "none" ? null : from);
      this.$root.style.removeProperty("transform");
      const finish = () => {
        if (!this.closing) {
          return;
        }
        this.closing = false;
        this.animations = [];
        if (this.$root.open) {
          this.ignoredCloseEvents++;
          this.$root.close();
        }
      };
      if (panel) {
        panel.finished.then(finish, () => {});
      } else {
        finish();
      }
    },
    onClick(event) {
      const dialog = this.$root;
      if (this.suppressClick && event.isTrusted) {
        this.suppressClick = false;
        event.preventDefault();
        event.stopPropagation();
        return;
      }
      const close = event.target.closest?.("[data-olis-dialog-close]");
      if (close && close.closest("dialog") === dialog) {
        this.request(false, "close");
        return;
      }
      if (event.target !== dialog || dialog.dataset.dismissible !== "true") {
        return;
      }
      const rect = dialog.getBoundingClientRect();
      if (
        event.clientX < rect.left ||
        event.clientX > rect.right ||
        event.clientY < rect.top ||
        event.clientY > rect.bottom
      ) {
        this.request(false, "backdrop");
      }
    },
    onCancel() {
      if (this.$root.dataset.dismissible === "true") {
        this.request(false, "escape");
      }
    },
    onNativeClose(event) {
      if (event.target !== this.$root || this.destroyed) {
        return;
      }
      if (this.ignoredCloseEvents > 0) {
        this.ignoredCloseEvents--;
        return;
      }
      this.closing = false;
      this.releaseDrag();
      this.stopAnimations();
      this.$root.style.removeProperty("transform");
      this.notify(false, "native");
    },
    sync() {
      if (
        this.drag &&
        (this.$root.dataset.dismissible !== "true" ||
          this.$root.dataset.placement !== this.drag.placement)
      ) {
        this.releaseDrag();
        this.snapBack();
      }
      if (this.$root.dataset.controlled !== "true") {
        return;
      }
      if (this.$root.dataset.controlledOpen === "true") {
        this.show();
      } else {
        this.close();
      }
    },
    releaseDrag() {
      const drag = this.drag;
      this.drag = null;
      delete this.$root.dataset.dragging;
      if (drag && this.$root.hasPointerCapture?.(drag.id)) {
        this.$root.releasePointerCapture(drag.id);
      }
    },
    snapBack() {
      const dialog = this.$root,
        from = getComputedStyle(dialog).transform;
      this.stopAnimations();
      dialog.style.removeProperty("transform");
      if (
        from === "none" ||
        typeof dialog.animate !== "function" ||
        window.matchMedia?.("(prefers-reduced-motion: reduce)").matches
      ) {
        return;
      }
      const animation = dialog.animate([{ transform: from }, { transform: "translate(0, 0)" }], {
        duration: 300,
        easing: "cubic-bezier(0.32, 0.72, 0, 1)",
      });
      this.animations = [animation];
      animation.finished.then(
        () => {
          if (this.animations.includes(animation)) {
            this.animations = [];
          }
        },
        () => {},
      );
    },
    pointerDown(event) {
      const dialog = this.$root,
        target = event.target;
      if (
        !dialog.open ||
        this.closing ||
        dialog.dataset.dismissible !== "true" ||
        event.button !== 0 ||
        this.drag
      ) {
        return;
      }
      const zone = target.closest?.("[data-olis-drawer-drag]");
      if (
        !zone ||
        zone.closest("dialog") !== dialog ||
        target.closest(
          'button, a, input, textarea, select, [tabindex], [role="button"], [role="link"], [contenteditable]:not([contenteditable="false"])',
        )
      ) {
        return;
      }
      const axis = gestureAxis(dialog.dataset.placement),
        position = axis === "Y" ? event.clientY : event.clientX;
      const cross = axis === "Y" ? event.clientX : event.clientY;
      this.drag = {
        id: event.pointerId,
        axis,
        placement: dialog.dataset.placement,
        direction: gestureDirection(dialog.dataset.placement),
        start: position,
        cross,
        previous: position,
        time: performance.now(),
        velocity: 0,
        offset: 0,
        active: false,
      };
      dialog.setPointerCapture(event.pointerId);
    },
    pointerMove(event) {
      const drag = this.drag,
        dialog = this.$root;
      if (!drag || drag.id !== event.pointerId) {
        return;
      }
      const position = drag.axis === "Y" ? event.clientY : event.clientX;
      const cross = drag.axis === "Y" ? event.clientX : event.clientY;
      const delta = position - drag.start;
      if (!drag.active) {
        if (Math.abs(delta) < 8 && Math.abs(cross - drag.cross) < 8) {
          return;
        }
        if (Math.abs(cross - drag.cross) > Math.abs(delta)) {
          this.releaseDrag();
          return;
        }
        drag.active = true;
        dialog.dataset.dragging = "true";
        this.stopAnimations();
      }
      event.preventDefault();
      const direction = drag.direction,
        now = performance.now();
      const size = drag.axis === "Y" ? dialog.offsetHeight : dialog.offsetWidth;
      drag.offset = Math.min(size, Math.max(0, direction * delta));
      drag.velocity = (direction * (position - drag.previous)) / Math.max(1, now - drag.time);
      drag.previous = position;
      drag.time = now;
      dialog.style.transform = `translate${drag.axis}(${direction * drag.offset}px)`;
    },
    finishPointer(event, cancelled = false) {
      const drag = this.drag,
        dialog = this.$root;
      if (!drag || drag.id !== event.pointerId) {
        return;
      }
      this.releaseDrag();
      if (!drag.active) {
        return;
      }
      if (!cancelled) {
        this.suppressClick = true;
        clearTimeout(this.suppressClickTimer);
        this.suppressClickTimer = setTimeout(() => {
          this.suppressClick = false;
          this.suppressClickTimer = null;
        }, 0);
      }
      const size = drag.axis === "Y" ? dialog.offsetHeight : dialog.offsetWidth;
      const dismiss =
        !cancelled &&
        dialog.dataset.dismissible === "true" &&
        drag.offset > 0 &&
        (drag.offset > size * 0.3 || drag.velocity > 0.5);
      if (!dismiss) {
        this.snapBack();
        return;
      }
      if (dialog.dataset.controlled === "true") {
        this.snapBack();
      }
      this.request(false, "swipe");
    },
    pointerUp(event) {
      this.finishPointer(event);
    },
    pointerCancel(event) {
      this.finishPointer(event, true);
    },
    lostPointerCapture(event) {
      if (event.target === this.$root) {
        this.finishPointer(event, true);
      }
    },
  }));
}

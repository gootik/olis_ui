/** Per-region queue; Alpine renders the keyed toast nodes in the server template. */
export function registerOlisToastRegion(Alpine) {
  Alpine.data("olisToastRegion", () => {
    let region;
    let tick;
    let active = true;

    return {
      items: [],
      serial: 0,
      hover: false,
      focused: false,
      lastFocus: null,

      init() {
        region = this.$root;
        tick = this.$nextTick;
        this.sync();
      },

      sync() {
        const toasts = JSON.parse(region.dataset.toasts);
        const ids = new Set(toasts.map((toast) => String(toast.id)));

        for (const item of this.items) {
          if (!item.exiting && !ids.has(item.id)) {
            this.remove(item, "server");
          }
        }

        for (const toast of [...toasts].reverse()) {
          const item = this.items.find((entry) => entry.id === String(toast.id) && !entry.exiting);

          if (item) {
            this.update(toast);
          } else {
            this.show(toast);
          }
        }

        const byId = new Map(
          this.items.filter((item) => !item.exiting).map((item) => [item.id, item]),
        );
        this.items = [
          ...toasts.map((toast) => byId.get(String(toast.id))),
          ...this.items.filter((item) => item.exiting),
        ];
        tick(() => this.layout());
      },

      element(item) {
        return region.querySelector(`[data-toast-uid="${CSS.escape(item.uid)}"]`);
      },

      variant(value) {
        return ["default", "accent", "success", "warning", "danger"].includes(value)
          ? value
          : "default";
      },

      loading(item) {
        return item.data.is_loading === true;
      },

      customIndicator(item) {
        return (
          typeof item.data.indicator === "string" &&
          JSON.parse(region.dataset.indicators).includes(item.data.indicator)
        );
      },

      actionCommand(item) {
        const action = item.data.action || {};

        if (typeof action.event !== "string" || !/^[\w:.-]+$/.test(action.event)) {
          return null;
        }

        const value = Object.create(null);

        if (action.params && typeof action.params === "object") {
          for (const [key, param] of Object.entries(action.params)) {
            if (
              /^[a-zA-Z0-9_-]+$/.test(key) &&
              ["string", "number", "boolean"].includes(typeof param)
            ) {
              value[key] = String(param);
            }
          }
        }

        return JSON.stringify([["push", { event: action.event, value }]]);
      },

      style(item) {
        return {
          "--offset-collapsed": `${item.collapsed || 0}px`,
          "--offset-expanded": `${item.offset || 0}px`,
          "--scale-collapsed": String(item.scale ?? 1),
          "--front-height": `${item.frontHeight || 0}px`,
          "--toast-height": `${item.height || 0}px`,
          zIndex: item.z || 1,
        };
      },

      paused() {
        return this.hover || this.focused || document.hidden || !document.hasFocus();
      },

      pause(item) {
        if (item.timer) {
          clearTimeout(item.timer);
          item.timer = null;
          item.remaining = Math.max(0, item.remaining - (performance.now() - item.started));
        }
      },

      start(item) {
        if (
          item.exiting ||
          item.timeoutRequested ||
          item.remaining == null ||
          item.timer ||
          this.paused()
        ) {
          return;
        }

        item.started = performance.now();
        item.timer = setTimeout(
          () => {
            item.timer = null;
            item.timeoutRequested = true;
            this.close(item, "timeout");
          },
          Math.max(0, item.remaining),
        );
      },

      reconcile() {
        this.items.forEach((item) => {
          this.paused() ? this.pause(item) : this.start(item);
        });
      },

      layout() {
        const active = this.items.filter((item) => !item.exiting);
        const expanded = region.dataset.expanded === "true" || this.hover || this.focused;
        const gap = Math.max(0, Number(region.dataset.gap) || 0);
        const max = Math.max(1, Number(region.dataset.maxVisible) || 3);
        const heights = active.map((item) => {
          const el = this.element(item);

          if (!el) {
            return 0;
          }

          el.style.height = "auto";
          const height = el.offsetHeight;

          el.style.removeProperty("height");

          return height;
        });
        const front = heights[0] || 0;
        let before = 0;

        active.forEach((item, index) => {
          Object.assign(item, {
            index,
            expanded,
            hidden: index >= max,
            collapsed: index * gap,
            offset: before + index * gap,
            scale: Math.max(0, 1 - index * 0.05),
            frontHeight: front,
            height: heights[index],
            z: active.length - index,
          });
          before += heights[index];
        });
      },

      show(detail) {
        const id = String(detail.id);
        const previous = this.items.find((item) => item.id === id && !item.exiting);

        if (previous) {
          this.update({ ...detail, id });

          return;
        }

        const timeout = Number(
          detail.timeout ?? (detail.is_loading === true ? 0 : region.dataset.timeout),
        );
        const item = {
          id,
          uid: `${region.id}-toast-${++this.serial}`,
          data: { ...detail },
          remaining: Number.isFinite(timeout) && timeout > 0 ? timeout : null,
          timer: null,
          entering: true,
          exiting: false,
          index: 0,
          hidden: false,
          expanded: false,
        };

        this.items.unshift(item);
        const current = this.items[0];

        tick(() => {
          if (!active || !this.element(current)) {
            return;
          }

          this.layout();
          requestAnimationFrame(() =>
            requestAnimationFrame(() => {
              current.entering = false;
            }),
          );
          this.start(current);
        });
      },

      update(detail) {
        const item = this.items.find((x) => x.id === String(detail.id) && !x.exiting);

        if (!item) {
          return;
        }

        const focused = this.element(item)?.contains(document.activeElement);
        const wasLoading = this.loading(item);
        const timeoutChanged = detail.timeout !== item.data.timeout;
        item.data = { ...detail };

        if (timeoutChanged || wasLoading !== this.loading(item)) {
          this.pause(item);
          const timeout = Number(
            detail.timeout ?? (this.loading(item) ? 0 : region.dataset.timeout),
          );
          item.remaining = Number.isFinite(timeout) && timeout > 0 ? timeout : null;
          item.timeoutRequested = false;
        }

        tick(() => {
          if (!active) {
            return;
          }

          this.layout();

          if (focused) {
            this.element(item)?.focus({ preventScroll: true });
          }

          this.start(item);
        });
      },

      close(item, reason = "dismiss") {
        const button = region.querySelector(":scope > [data-olis-toast-dismiss]");

        button.setAttribute("phx-value-id", item.id);
        button.setAttribute("phx-value-reason", reason);
        button.click();
      },

      remove(item, reason = "server") {
        if (!item || item.exiting) {
          return;
        }

        this.pause(item);
        const el = this.element(item);

        item.exiting = true;

        if (el?.contains(document.activeElement)) {
          const other = this.items.find((x) => x !== item && !x.exiting && !x.hidden);

          (
            this.element(other || {}) ||
            (this.lastFocus?.isConnected && this.lastFocus) ||
            region
          ).focus({ preventScroll: true });
        }

        tick(() => {
          if (active) {
            this.layout();
          }
        });
        item.removeTimer = setTimeout(() => {
          if (!active) {
            return;
          }

          this.items = this.items.filter((x) => x.uid !== item.uid);
          tick(() => {
            if (active) {
              this.layout();
            }
          });
        }, 250);
        window.dispatchEvent(
          new CustomEvent("olis:toast-closed", {
            detail: { id: item.id, region: region.id, reason },
          }),
        );
      },

      action(item) {
        window.dispatchEvent(
          new CustomEvent("olis:toast-action", { detail: { id: item.id, region: region.id } }),
        );

        if (item.data.action?.close_on_action !== false) {
          setTimeout(() => {
            if (active) {
              this.close(item, "action");
            }
          }, 0);
        }
      },

      pointerEnter(event) {
        if (event.pointerType === "touch" || this.hover) {
          return;
        }

        this.hover = true;
        this.layout();
        this.reconcile();
      },

      pointerLeave(event) {
        if (event.pointerType === "touch") {
          return;
        }

        this.hover = false;
        this.layout();
        this.reconcile();
      },

      focusIn(event) {
        if (!region.contains(event.relatedTarget)) {
          this.lastFocus = event.relatedTarget;
        }

        this.focused = true;
        this.layout();
        this.reconcile();
      },

      focusOut(event) {
        if (region.contains(event.relatedTarget)) {
          return;
        }

        this.focused = false;
        this.layout();
        this.reconcile();
      },

      keydown(event) {
        if (
          event.altKey &&
          !event.ctrlKey &&
          !event.metaKey &&
          !event.shiftKey &&
          event.code === "KeyT"
        ) {
          const first = [...document.querySelectorAll("[data-olis-toast-region]")].find((el) =>
            el.querySelector("[data-olis-toast]:not([data-exiting])"),
          );

          if (first === region) {
            event.preventDefault();
            this.lastFocus = document.activeElement;
            region.focus();
          }
        } else if (
          event.key === "Escape" &&
          event.target instanceof Node &&
          region.contains(event.target)
        ) {
          // Match OlisUI: collapse the stack and release focus without dismissing a toast.
          if (region.contains(document.activeElement)) {
            document.activeElement.blur();
          }

          this.hover = false;
          this.focused = false;
          this.layout();
          this.reconcile();
        }
      },

      destroy() {
        active = false;
        this.items.forEach((item) => {
          this.pause(item);
          clearTimeout(item.removeTimer);
        });
        this.items = [];
      },
    };
  });
}

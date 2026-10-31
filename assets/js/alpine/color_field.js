export function registerOlisColorField(Alpine) {
  Alpine.data("olisColorField", () => {
    let resetTimer = null;
    const normalize = (value, allowAlpha) => {
      const text = value.trim();
      if (!text) {
        return "";
      }
      const hex = text.startsWith("#") ? text.slice(1) : text;
      const lengths = allowAlpha ? [3, 4, 6, 8] : [3, 6];
      if (!lengths.includes(hex.length) || !/^[0-9a-f]+$/i.test(hex)) {
        return null;
      }
      const expanded = hex.length <= 4 ? [...hex].map((char) => char + char).join("") : hex;
      return `#${expanded.toUpperCase()}`;
    };
    return {
      committed: "",
      init() {
        const input = this.$root.querySelector("[data-olis-color-input]");
        this.committed = input
          ? normalize(input.value, this.$root.dataset.allowAlpha === "true") || ""
          : "";
        this.sync();
      },
      destroy() {
        if (resetTimer !== null) {
          clearTimeout(resetTimer);
        }
      },
      paint(value) {
        const field = this.$root;
        const swatch = field.querySelector('[data-olis-color-preview] [data-slot="color-swatch"]');
        if (!swatch) {
          return;
        }
        const color =
          field.dataset.previewOverride === "true" || field.dataset.channel !== "hex"
            ? field.dataset.previewColor
            : value || "#E4E4E7";
        if (!color) {
          return;
        }
        swatch.style.setProperty("--color-swatch-current", color);
        swatch.setAttribute("aria-label", `Color preview: ${color}`);
      },
      sync(force = false) {
        const field = this.$root,
          input = field.querySelector("[data-olis-color-input]");
        if (!input) {
          return;
        }
        if (field.dataset.channel === "hex" && (force || document.activeElement !== input)) {
          const value = normalize(input.value, field.dataset.allowAlpha === "true");
          if (value !== null) {
            this.committed = value;
          }
        }
        this.paint(this.committed);
      },
      commit() {
        const field = this.$root,
          input = field.querySelector("[data-olis-color-input]");
        if (
          !input ||
          field.dataset.channel !== "hex" ||
          input.readOnly ||
          input.matches(":disabled")
        ) {
          return;
        }
        const normalized = normalize(input.value, field.dataset.allowAlpha === "true");
        const value = normalized === null ? this.committed : normalized;
        const changed = input.value !== value;
        input.value = value;
        this.committed = value;
        this.paint(value);
        if (changed) {
          input.dispatchEvent(new Event("input", { bubbles: true }));
          input.dispatchEvent(new Event("change", { bubbles: true }));
        }
      },
      focusout(event) {
        if (event.target === this.$root.querySelector("[data-olis-color-input]")) {
          this.commit();
        }
      },
      change(event) {
        if (
          event.target === this.$root.querySelector("[data-olis-color-input]") &&
          document.activeElement !== event.target
        ) {
          this.sync();
        }
      },
      submit(event) {
        const input = this.$root.querySelector("[data-olis-color-input]");
        if (input?.form === event.target) {
          this.commit();
        }
      },
      reset(event) {
        const input = this.$root.querySelector("[data-olis-color-input]");
        if (!input?.form || input.form !== event.target) {
          return;
        }
        if (resetTimer !== null) {
          clearTimeout(resetTimer);
        }
        resetTimer = setTimeout(() => {
          resetTimer = null;
          if (this.$root.isConnected) {
            this.sync(true);
          }
        }, 0);
      },
    };
  });
}

export function registerOlisInputGroup(Alpine) {
  Alpine.data("olisInputGroup", () => ({
    focusInput(event) {
      const target = event.target;

      // Leave clicks on nested groups and interactive controls alone.
      if (
        target.closest("[data-olis-input-group]") !== this.$root ||
        target.closest(
          'input, textarea, select, button, a, [contenteditable="true"], [role="button"]',
        )
      ) {
        return;
      }

      const input = this.$root.querySelector(
        '[data-slot="input-group-input"], [data-slot="input-group-textarea"]',
      );

      if (!input.matches(":disabled")) {
        input.focus();
      }
    },
  }));
}

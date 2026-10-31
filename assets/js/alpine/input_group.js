export function registerHeroInputGroup(Alpine) {

  Alpine.data('heroInputGroup', () => ({
    focusInput(event) {
      const target = event.target;
      if (target.closest('[data-hero-input-group]') !== this.$root ||
          target.closest('input, textarea, select, button, a, [contenteditable="true"], [role="button"]')) return;
      const input = this.$root.querySelector('[data-slot="input-group-input"], [data-slot="input-group-textarea"]');
      if (input && !input.matches(':disabled')) input.focus();
    }
  }));
}

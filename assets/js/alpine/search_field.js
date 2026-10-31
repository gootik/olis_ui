export function registerHeroSearchField(Alpine) {

  Alpine.data('heroSearchField', () => ({
    empty: true,
    locked: false,
    sync() {
      const input = this.$refs.input;
      if (!input) return;
      this.empty = input.value === '';
      this.locked = input.matches(':disabled') || input.readOnly;
    },
    clear() {
      const input = this.$refs.input;
      if (!input || this.locked || this.empty) return;
      input.value = '';
      input.dispatchEvent(new Event('input', {bubbles: true}));
      input.focus();
    }
  }));
}

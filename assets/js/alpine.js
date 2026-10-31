/** Register Alpine state used by HeroUI components before calling Alpine.start(). */
export function registerHeroUIAlpine(Alpine) {
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

  Alpine.data('heroNumberField', () => ({
    locked: true,
    disabled: false,
    cannotDecrease: false,
    cannotIncrease: false,
    sync() {
      const input = this.$refs.input;
      if (!input) return;
      this.disabled = input.matches(':disabled');
      this.locked = this.disabled || input.readOnly;
      const cannotStep = direction => {
        const probe = input.cloneNode();
        probe.value = input.value;
        try {
          if (direction === 'up') probe.stepUp(); else probe.stepDown();
          return probe.value === input.value;
        } catch (_) {
          return true;
        }
      };
      this.cannotDecrease = cannotStep('down');
      this.cannotIncrease = cannotStep('up');
    },
    step(direction) {
      const input = this.$refs.input;
      if (!input || input.matches(':disabled') || input.readOnly) return;
      const previous = input.value;
      if (direction === 'up') input.stepUp(); else input.stepDown();
      if (input.value !== previous) input.dispatchEvent(new Event('input', {bubbles: true}));
      this.sync();
    }
  }));
}

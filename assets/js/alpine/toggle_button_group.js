/** Coordinate managed toggle buttons while preserving independent groups. */
export function registerHeroToggleButtonGroup(Alpine) {
  Alpine.data('heroToggleButtonGroup', () => ({
    keys: [],
    focused: null,
    init() {
      this.keys = this.readKeys();
      this.$nextTick(() => this.sync());
    },
    readKeys() {
      try { const keys = JSON.parse(this.$root.dataset.selectedKeys || '[]'); return Array.isArray(keys) ? keys.filter(key => typeof key === 'string') : []; }
      catch (_) { return []; }
    },
    key(button) { return button.getAttribute('data-key') ?? button.getAttribute('value') ?? button.id ?? ''; },
    allButtons() {
      return [...this.$root.querySelectorAll('[data-slot="toggle-button"]')].filter(button => button.closest('[data-hero-toggle-group]') === this.$root);
    },
    buttons() { return this.allButtons().filter(button => this.key(button)); },
    enabled() { return this.buttons().filter(button => !button.matches(':disabled') && button.getAttribute('aria-disabled') !== 'true'); },
    sync() {
      if (!this.$root.isConnected) return;
      for (const button of this.allButtons()) {
        const size = button.dataset.heroToggleSize || this.$root.dataset.heroToggleSize || 'md';
        button.classList.remove('toggle-button--sm', 'toggle-button--md', 'toggle-button--lg');
        button.classList.add(`toggle-button--${size}`);
      }
      if (!['single', 'multiple'].includes(this.$root.dataset.selectionMode)) return;
      if (this.$root.dataset.controlled === 'true') this.keys = this.readKeys();
      const buttons = this.buttons(), enabled = this.enabled(), single = this.$root.dataset.selectionMode === 'single';
      this.$root.setAttribute('role', single ? 'radiogroup' : 'toolbar');
      this.$root.setAttribute('aria-orientation', this.$root.dataset.orientation);
      for (const button of buttons) {
        const selected = this.keys.includes(this.key(button));
        if (single) { button.setAttribute('role', 'radio'); button.setAttribute('aria-checked', String(selected)); button.removeAttribute('aria-pressed'); }
        else { button.removeAttribute('role'); button.removeAttribute('aria-checked'); button.setAttribute('aria-pressed', String(selected)); }
        if (selected) button.setAttribute('data-selected', 'true'); else button.removeAttribute('data-selected');
      }
      const focused = enabled.find(button => this.key(button) === this.focused);
      const active = focused || enabled.find(button => this.keys.includes(this.key(button))) || enabled[0];
      for (const button of buttons) button.tabIndex = button === active ? 0 : -1;
      this.focused = active ? this.key(active) : null;
    },
    select(button) {
      if (!this.enabled().includes(button)) return;
      const key = this.key(button), selected = this.keys.includes(key), single = this.$root.dataset.selectionMode === 'single';
      const next = selected ? this.keys.filter(value => value !== key) : single ? [key] : [...this.keys, key];
      if (!next.length && this.$root.dataset.disallowEmpty === 'true') return;
      if (this.$root.dataset.controlled !== 'true') { this.keys = next; this.sync(); }
      this.$root.dispatchEvent(new CustomEvent('hero:toggle-button-group-change', {bubbles: true, detail: {keys: next}}));
      const eventButton = this.$root.querySelector(':scope > [data-hero-toggle-group-event]');
      if (eventButton) { eventButton.setAttribute('phx-value-keys', JSON.stringify(next)); eventButton.click(); }
    },
    click(event) {
      const button = event.target.closest?.('[data-slot="toggle-button"]');
      if (button && this.buttons().includes(button)) this.select(button);
    },
    focus(event) {
      const button = event.target.closest?.('[data-slot="toggle-button"]');
      if (!button || !this.enabled().includes(button)) return;
      this.focused = this.key(button);
      for (const candidate of this.buttons()) candidate.tabIndex = candidate === button ? 0 : -1;
    },
    keydown(event) {
      const buttons = this.enabled(), current = buttons.indexOf(event.target);
      if (current < 0) return;
      const vertical = this.$root.dataset.orientation === 'vertical';
      const rtl = getComputedStyle(this.$root).direction === 'rtl';
      let index;
      if (event.key === 'Home') index = 0;
      else if (event.key === 'End') index = buttons.length - 1;
      else if (event.key === (vertical ? 'ArrowDown' : rtl ? 'ArrowLeft' : 'ArrowRight')) index = (current + 1) % buttons.length;
      else if (event.key === (vertical ? 'ArrowUp' : rtl ? 'ArrowRight' : 'ArrowLeft')) index = (current - 1 + buttons.length) % buttons.length;
      else return;
      event.preventDefault(); event.stopPropagation();
      const next = buttons[index]; this.focused = this.key(next);
      for (const button of this.buttons()) button.tabIndex = button === next ? 0 : -1;
      next.focus({preventScroll: true});
      if (this.$root.dataset.selectionMode === 'single' && !this.keys.includes(this.key(next))) this.select(next);
    }
  }));
}

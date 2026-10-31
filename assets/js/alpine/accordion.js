export function registerHeroAccordion(Alpine) {

  Alpine.data('heroAccordion', () => ({
    expanded: [],
    init() { this.expanded = JSON.parse(this.$root.dataset.initialExpanded); },
    triggers() {
      return [...this.$root.querySelectorAll('[data-accordion-trigger]')]
        .filter(button => button.closest('[data-hero-accordion]') === this.$root && !button.disabled);
    },
    sync() {
      if (this.$root.dataset.controlled === 'true') {
        this.setExpanded(JSON.parse(this.$root.dataset.expandedKeys));
      } else {
        const keys = [...this.$root.querySelectorAll('[data-accordion-trigger]')]
          .filter(button => button.closest('[data-hero-accordion]') === this.$root)
          .map(button => button.dataset.key);
        this.setExpanded(this.expanded.filter(key => keys.includes(key)));
      }
    },
    setExpanded(keys) {
      const panel = document.activeElement?.closest?.('[data-slot="accordion-panel"]');
      if (panel?.closest('[data-hero-accordion]') === this.$root && !keys.includes(panel.dataset.key)) {
        this.triggers().find(button => button.dataset.key === panel.dataset.key)?.focus({preventScroll: true});
      }
      this.expanded = keys;
    },
    toggle(key) {
      if (!this.triggers().some(button => button.dataset.key === key)) return;
      const open = !this.expanded.includes(key);
      const next = open
        ? (this.$root.dataset.multiple === 'true' ? [...this.expanded, key] : [key])
        : this.expanded.filter(value => value !== key);
      if (this.$root.dataset.controlled !== 'true') this.setExpanded(next);
      this.$dispatch('hero:accordion-change', {key, expanded: open, keys: next});
      const eventButton = this.$refs.changeEvent;
      if (eventButton) {
        eventButton.setAttribute('phx-value-key', key);
        eventButton.setAttribute('phx-value-expanded', String(open));
        eventButton.setAttribute('phx-value-keys', JSON.stringify(next));
        eventButton.click();
      }
    },
    keydown(event) {
      const triggers = this.triggers(), index = triggers.indexOf(event.target);
      if (index < 0) return;
      let next;
      if (event.key === 'ArrowDown') next = (index + 1) % triggers.length;
      else if (event.key === 'ArrowUp') next = (index - 1 + triggers.length) % triggers.length;
      else if (event.key === 'Home') next = 0;
      else if (event.key === 'End') next = triggers.length - 1;
      else return;
      event.preventDefault();
      triggers[next].focus();
    }
  }));
}

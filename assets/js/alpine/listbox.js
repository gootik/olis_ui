export function registerHeroListbox(Alpine) {

  Alpine.data('heroListbox', () => ({
    search: null,
    init() { this.$nextTick(() => this.sync()); },
    items() {
      const root = this.$root;
      return [...root.querySelectorAll('[role="option"]')].filter(item =>
        item.closest('[data-hero-listbox]') === root && item.getAttribute('aria-disabled') !== 'true');
    },
    setActive(item, scroll = false) {
      const root = this.$root;
      if (item) root.setAttribute('aria-activedescendant', item.id);
      else root.removeAttribute('aria-activedescendant');
      root.querySelectorAll('[role="option"]').forEach(option => {
        if (option.closest('[data-hero-listbox]') === root) option.dataset.active = String(option === item);
      });
      if (item && scroll) item.scrollIntoView({block: 'nearest'});
    },
    sync() {
      if (!this.$root.isConnected) return;
      const items = this.items();
      const active = items.find(item => item.id === this.$root.getAttribute('aria-activedescendant'));
      this.setActive(active || items.find(item => item.getAttribute('aria-selected') === 'true') || items[0]);
    },
    click(event) {
      const root = this.$root, option = event.target.closest?.('[role="option"]');
      if (!option || option.closest('[data-hero-listbox]') !== root || root.getAttribute('aria-disabled') === 'true' || option.getAttribute('aria-disabled') === 'true') return;
      this.setActive(option);
      root.focus({preventScroll: true});
    },
    keydown(event) {
      const root = this.$root;
      if (event.target.closest?.('[data-hero-listbox]') !== root || root.getAttribute('aria-disabled') === 'true') return;
      const items = this.items(), current = items.findIndex(item => item.id === root.getAttribute('aria-activedescendant'));
      if (!items.length) return;
      let index;
      if (event.key === 'ArrowDown') index = (current + 1) % items.length;
      else if (event.key === 'ArrowUp') index = current < 0 ? items.length - 1 : (current - 1 + items.length) % items.length;
      else if (event.key === 'Home') index = 0;
      else if (event.key === 'End') index = items.length - 1;
      else if (event.key === 'Enter' || event.key === ' ') { event.preventDefault(); (items[current] || items[0]).click(); return; }
      else if (event.key.length === 1 && !event.ctrlKey && !event.metaKey && !event.altKey) {
        const query = ((this.search && Date.now() - this.search.time < 700 ? this.search.text : '') + event.key).toLocaleLowerCase();
        this.search = {text: query, time: Date.now()};
        const ordered = [...items.slice(current + 1), ...items.slice(0, current + 1)];
        const match = ordered.find(item => item.querySelector('[data-slot="label"]')?.textContent.trim().toLocaleLowerCase().startsWith(query));
        if (match) { event.preventDefault(); this.setActive(match, true); }
        return;
      } else return;
      event.preventDefault();
      this.setActive(items[index], true);
    }
  }));
}

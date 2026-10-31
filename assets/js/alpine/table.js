export function registerHeroTable(Alpine) {
  Alpine.data('heroTable', () => ({
    keys: [],
    readKeys() {
      try { const value = JSON.parse(this.$root.dataset.selectedKeys || '[]'); return Array.isArray(value) ? value.filter(key => typeof key === 'string') : []; }
      catch (_) { return []; }
    },
    rows() {
      return [...this.$root.querySelectorAll('[data-hero-table-row]')].filter(row => row.closest('[data-hero-table]') === this.$root);
    },
    enabledRows() { return this.rows().filter(row => !row.querySelector('[data-hero-table-select-row]')?.disabled); },
    init() { this.keys = this.readKeys(); this.sync(); },
    paint() {
      this.rows().forEach(row => {
        const selected = this.keys.includes(row.dataset.key);
        row.setAttribute('aria-selected', String(selected));
        if (selected) row.dataset.selected = 'true'; else delete row.dataset.selected;
        const input = row.querySelector('[data-hero-table-select-row]');
        if (input) input.checked = selected;
      });
      const all = this.$root.querySelector('[data-hero-table-select-all]');
      if (!all) return;
      const rows = this.enabledRows(), count = rows.filter(row => this.keys.includes(row.dataset.key)).length;
      all.checked = rows.length > 0 && count === rows.length;
      all.indeterminate = count > 0 && count < rows.length;
      all.disabled = rows.length === 0;
      const label = all.closest('.checkbox');
      if (label) {
        if (all.indeterminate) label.dataset.indeterminate = 'true'; else delete label.dataset.indeterminate;
        if (all.disabled) label.dataset.disabled = 'true'; else delete label.dataset.disabled;
      }
    },
    sync() {
      if (!this.$root.isConnected) return;
      if (this.$root.dataset.controlled === 'true') this.keys = this.readKeys();
      this.paint();
    },
    setSelection(next) {
      if (next.length === this.keys.length && next.every(key => this.keys.includes(key))) { this.paint(); return; }
      if (this.$root.dataset.controlled !== 'true') this.keys = next;
      this.paint();
      this.$root.dispatchEvent(new CustomEvent('hero:table-selection-change', {bubbles: true, detail: {keys: next}}));
      const button = this.$root.querySelector('[data-hero-table-selection-event]');
      if (button) queueMicrotask(() => { if (button.isConnected) { button.setAttribute('phx-value-keys', JSON.stringify(next)); button.click(); } });
    },
    selectionChange(event) {
      const input = event.target;
      if (input.closest?.('[data-hero-table]') !== this.$root) return;
      if (input.matches('[data-hero-table-select-all]')) {
        const keys = this.enabledRows().map(row => row.dataset.key);
        this.setSelection(input.checked ? [...new Set([...this.keys, ...keys])] : this.keys.filter(key => !keys.includes(key)));
      } else if (input.matches('[data-hero-table-select-row]') && !input.disabled) {
        const key = input.closest('[data-hero-table-row]')?.dataset.key;
        if (!key) return;
        const next = input.checked ? (this.$root.dataset.selectionMode === 'single' ? [key] : [...new Set([...this.keys, key])]) : this.keys.filter(value => value !== key);
        this.setSelection(next);
      }
    },
    rowClick(event) {
      if (event.target.closest?.('a,button,input,select,textarea,label,[contenteditable="true"],[role="button"]')) return;
      const row = event.target.closest?.('[data-hero-table-row]');
      if (!row || row.closest('[data-hero-table]') !== this.$root) return;
      const input = row.querySelector('[data-hero-table-select-row]');
      if (input && !input.disabled) input.click();
    }
  }));
}

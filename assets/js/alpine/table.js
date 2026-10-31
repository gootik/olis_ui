export function registerHeroTable(Alpine) {
  Alpine.data('heroTable', () => {
    const originalTabs = new Map();
    let current = null;
    let location = null;
    let ownsFocus = false;
    let innerControlIndex = null;
    let root = null;
    const onPointerDown = event => { if (!root?.contains(event.target)) ownsFocus = false; };
    const controls = 'a[href], button, input:not([type=hidden]), select, textarea, [contenteditable=true], [tabindex]';
    return ({
    keys: [],
    readKeys() {
      try { const value = JSON.parse(this.$root.dataset.selectedKeys || '[]'); return Array.isArray(value) ? value.filter(key => typeof key === 'string') : []; }
      catch (_) { return []; }
    },
    rows() {
      return [...this.$root.querySelectorAll('[data-hero-table-row]')].filter(row => row.closest('[data-hero-table]') === this.$root);
    },
    enabledRows() { return this.rows().filter(row => !row.querySelector('[data-hero-table-select-row]')?.disabled); },
    init() { root = this.$root; document.addEventListener('pointerdown', onPointerDown, true); this.keys = this.readKeys(); this.sync(); },
    destroy() {
      document.removeEventListener('pointerdown', onPointerDown, true);
      for (const [node, value] of originalTabs) {
        if (value === null) node.removeAttribute('tabindex'); else node.setAttribute('tabindex', value);
      }
      originalTabs.clear();
      current = null;
    },
    table() { return this.$root.querySelector('table'); },
    headers() {
      const table = this.table();
      return [...table.querySelectorAll('thead th')].filter(cell => cell.closest('table') === table);
    },
    cells(row) { return [...row.children].filter(cell => cell.matches('td, th')); },
    gridNodes() { return [...this.headers(), ...this.rows().flatMap(row => [row, ...this.cells(row)])]; },
    cellControls(cell) {
      const table = this.table();
      return [...cell.querySelectorAll(controls)].filter(node => {
        if (node.closest('table') !== table || node.closest('th, td') !== cell) return false;
        if (node.matches(':disabled, [aria-disabled=true]') || node.closest('[hidden], [inert], [aria-hidden=true]')) return false;
        const overlay = node.closest('[popover], dialog, [role=menu], [role=listbox], [role=dialog]');
        if (overlay && cell.contains(overlay)) return false;
        if (!node.getClientRects().length || getComputedStyle(node).visibility === 'hidden') return false;
        const initial = originalTabs.has(node) ? originalTabs.get(node) : node.getAttribute('tabindex');
        return initial === null || Number(initial) >= 0;
      });
    },
    remember(node) {
      if (!originalTabs.has(node)) originalTabs.set(node, node.getAttribute('tabindex'));
    },
    position(node) {
      const headers = this.headers(), header = headers.indexOf(node);
      if (header >= 0) return {header};
      const rows = this.rows(), row = node.closest('[data-hero-table-row]');
      const rowIndex = rows.indexOf(row);
      if (rowIndex < 0) return null;
      return {key: row.id || row.dataset.key || null, rowIndex, column: node === row ? -1 : this.cells(row).indexOf(node)};
    },
    findPosition() {
      if (!location) return null;
      if (location.header != null) return this.headers()[location.header] || this.headers()[0];
      const rows = this.rows();
      const row = rows.find(item => location.key && (item.id === location.key || item.dataset.key === location.key)) || rows[location.rowIndex] || rows[0];
      if (!row) return this.headers()[0];
      return location.column < 0 ? row : this.cells(row)[location.column] || row;
    },
    syncFocus() {
      const table = this.table();
      if (!table) return;
      const nodes = this.gridNodes();
      // Only elements belonging to this table are managed; controls in nested grids retain their own behavior.
      for (const node of table.querySelectorAll(controls)) {
        if (node.closest('table') !== table || nodes.includes(node)) continue;
        this.remember(node);
        node.tabIndex = -1;
      }
      const restoreFocus = current && ownsFocus && document.activeElement === document.body && document.hasFocus?.() !== false;
      if (!nodes.includes(current)) current = this.findPosition();
      if (!nodes.includes(current)) current = null;
      for (const node of nodes) {
        this.remember(node);
        node.tabIndex = node === current ? 0 : -1;
      }
      table.tabIndex = current ? -1 : 0;
      for (const node of originalTabs.keys()) if (!node.isConnected) originalTabs.delete(node);
      if (restoreFocus && current) {
        const control = innerControlIndex === null ? null : current.querySelectorAll(controls)[innerControlIndex];
        if (control && !control.disabled) control.focus(); else current.focus();
      }
    },
    focusNode(node) {
      if (!node) return;
      current = node;
      innerControlIndex = null;
      location = this.position(node);
      this.syncFocus();
      node.focus();
    },
    focusIn(event) {
      const table = this.table(), target = event.target;
      if (!table || target.closest?.('table') !== table) return;
      ownsFocus = true;
      if (target === table) {
        this.focusNode(this.findPosition() || this.enabledRows()[0] || this.rows()[0] || this.headers()[0]);
        return;
      }
      const node = target.closest('th, td, tr');
      if (node && this.gridNodes().includes(node)) {
        current = node; innerControlIndex = target === node ? null : [...node.querySelectorAll(controls)].indexOf(target);
        if (innerControlIndex < 0) innerControlIndex = null;
        location = this.position(node); this.syncFocus();
      }
    },
    focusOut(event) {
      if (event.relatedTarget && !this.table()?.contains(event.relatedTarget)) ownsFocus = false;
    },
    keyDown(event) {
      if (event.defaultPrevented || event.altKey) return;
      const table = this.table(), target = event.target;
      if (!table || target.closest?.('table') !== table) return;
      const nodes = this.gridNodes();
      // While interacting with a cell, Tab reaches each embedded control and Escape returns to the cell.
      // Otherwise native controls retain their own keys, including arrows in inputs and selects.
      if (!nodes.includes(target)) {
        const cell = target.closest('th, td');
        if (!cell || !nodes.includes(cell)) return;
        const overlay = target.closest('[popover], dialog, [role=menu], [role=listbox], [role=dialog]');
        if (overlay && cell.contains(overlay)) return;
        if (event.key === 'Escape' && target.getAttribute('aria-expanded') !== 'true') {
          event.preventDefault(); this.focusNode(cell); return;
        }
        if (event.key === 'Tab' && !event.ctrlKey && !event.metaKey) {
          const candidates = this.cellControls(cell), index = candidates.indexOf(target);
          if (index < 0) return;
          const next = candidates[index + (event.shiftKey ? -1 : 1)];
          if (next) { event.preventDefault(); next.focus(); }
          else if (event.shiftKey) { event.preventDefault(); this.focusNode(cell); }
        }
        return;
      }
      if (event.shiftKey || ((event.ctrlKey || event.metaKey) && !['Home', 'End'].includes(event.key))) return;
      const rows = this.rows(), headers = this.headers(), row = target.closest('[data-hero-table-row]');
      const rowIndex = rows.indexOf(row), cells = row ? this.cells(row) : [], column = row ? cells.indexOf(target) : headers.indexOf(target);
      const header = rowIndex < 0 && column >= 0;
      const rtl = getComputedStyle(table).direction === 'rtl';
      const left = rtl ? 'ArrowRight' : 'ArrowLeft', right = rtl ? 'ArrowLeft' : 'ArrowRight';
      let next = null;
      if (event.key === 'ArrowDown') {
        if (header) next = rows[0] && (this.cells(rows[0])[column] || rows[0]);
        else if (rowIndex >= 0 && rows[rowIndex + 1]) next = column < 0 ? rows[rowIndex + 1] : this.cells(rows[rowIndex + 1])[column] || rows[rowIndex + 1];
      } else if (event.key === 'ArrowUp') {
        if (rowIndex > 0) next = column < 0 ? rows[rowIndex - 1] : this.cells(rows[rowIndex - 1])[column] || rows[rowIndex - 1];
        else if (rowIndex === 0) next = headers[Math.max(0, column)];
      } else if (event.key === right) {
        if (header) next = headers[column + 1];
        else if (row) next = cells[column + 1];
      } else if (event.key === left) {
        if (header) next = headers[column - 1];
        else if (row && column === 0) next = row;
        else if (row && column > 0) next = cells[column - 1];
      } else if (event.key === 'Home' || event.key === 'End') {
        const last = event.key === 'End';
        if (event.ctrlKey || event.metaKey) {
          const destination = last ? rows.at(-1) : rows[0];
          next = destination && (column < 0 ? destination : this.cells(destination)[column] || destination);
        } else if (header) next = last ? headers.at(-1) : headers[0];
        else if (row) next = column < 0 ? (last ? rows.at(-1) : rows[0]) : (last ? cells.at(-1) : cells[0]);
      } else if ((event.key === ' ' || event.key === 'Enter') && !event.ctrlKey && !event.metaKey) {
        if (target === row) {
          const selection = row.querySelector('[data-hero-table-select-row]');
          if (selection && !selection.disabled) { event.preventDefault(); selection.click(); }
        } else {
          const special = target.querySelector('[data-hero-table-select-row], [data-hero-table-select-all], .table__sortable-column-header');
          if (special && !special.disabled) { event.preventDefault(); special.click(); }
          else {
            const control = this.cellControls(target)[0];
            if (control) { event.preventDefault(); control.focus(); }
          }
        }
        return;
      }
      if (next) { event.preventDefault(); this.focusNode(next); }
    },
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
      if (['single', 'multiple'].includes(this.$root.dataset.selectionMode)) this.paint();
      this.syncFocus();
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
  });
  });
}

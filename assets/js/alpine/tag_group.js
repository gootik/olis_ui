export function registerHeroTagGroup(Alpine) {

  // Selection may be LiveView-controlled or managed locally; removals remain server-controlled.
  Alpine.data('heroTagGroup', () => ({
    pendingRemoval: null,
    keys: [],
    knownKeys: [],
    readKeys() {
      try { const keys=JSON.parse(this.$root.dataset.selectedKeys || '[]'); return Array.isArray(keys) ? keys.filter(key=>typeof key==='string') : []; }
      catch (_) { return []; }
    },
    allTags() {
      return [...this.$root.querySelectorAll('[data-hero-tag]')].filter(tag=>tag.closest('[data-hero-tag-group]') === this.$root);
    },
    paintSelection() {
      if (this.$root.dataset.selectionMode === 'none') return;
      this.allTags().forEach(tag=>{
        const selected=this.keys.includes(tag.dataset.key);
        tag.setAttribute('aria-selected',String(selected));
        if (selected) tag.dataset.selected='true'; else delete tag.dataset.selected;
      });
    },
    setSelection(next) {
      if (next.length === this.keys.length && next.every(key=>this.keys.includes(key))) return;
      if (this.$root.dataset.controlled !== 'true') { this.keys=next; this.paintSelection(); }
      this.$root.dispatchEvent(new CustomEvent('hero:tag-group-selection-change',{bubbles:true,detail:{keys:next}}));
      const button=document.getElementById(this.$root.dataset.selectionEventId);
      if (button) queueMicrotask(()=>{ if (button.isConnected) { button.setAttribute('phx-value-keys',JSON.stringify(next)); button.click(); } });
    },
    select(tag) {
      if (!this.tags().includes(tag) || this.$root.dataset.selectionMode === 'none') return;
      const key=tag.dataset.key, selected=this.keys.includes(key);
      const next=selected ? this.keys.filter(value=>value!==key) : this.$root.dataset.selectionMode === 'single' ? [key] : [...this.keys,key];
      this.setSelection(next);
    },
    tags() {
      return [...this.$root.querySelectorAll('[data-hero-tag]')].filter(tag =>
        tag.closest('[data-hero-tag-group]') === this.$root && tag.getAttribute('aria-disabled') !== 'true');
    },
    activate(tag, focus = false) {
      const enabled = this.tags();
      if (!enabled.includes(tag)) tag = enabled[0];
      enabled.forEach(item => { item.tabIndex = item === tag ? 0 : -1; });
      this.$root.tabIndex = enabled.length || this.$root.getAttribute('aria-disabled') === 'true' ? -1 : 0;
      if (focus && tag) tag.focus();
    },
    init() { this.keys=this.readKeys(); this.knownKeys=this.allTags().map(tag=>tag.dataset.key); this.sync(); },
    sync() {
      const present=this.allTags().map(tag=>tag.dataset.key);
      const removed=this.knownKeys.filter(key=>!present.includes(key));
      this.knownKeys=present;
      if (this.$root.dataset.controlled === 'true') this.keys=this.readKeys();
      else if (removed.some(key=>this.keys.includes(key))) this.setSelection(this.keys.filter(key=>!removed.includes(key)));
      this.paintSelection();
      const enabled = this.tags(), pending = this.pendingRemoval;
      if (pending) {
        this.pendingRemoval = null;
        if (!this.$root.querySelector(`[id="${CSS.escape(pending.id)}"]`)) {
          const next = enabled[Math.min(pending.index, enabled.length - 1)];
          this.activate(next, pending.focus);
          if (!next && pending.focus) this.$root.focus();
          return;
        }
      }
      const focused = document.activeElement?.closest?.('[data-hero-tag]');
      this.activate(enabled.includes(focused) ? focused : enabled.find(tag => tag.tabIndex === 0) || enabled.find(tag => tag.getAttribute('aria-selected') === 'true'));
    },
    tagFor(event) {
      const tag = event.target.closest?.('[data-hero-tag]');
      return tag?.closest('[data-hero-tag-group]') === this.$root && tag.getAttribute('aria-disabled') !== 'true' ? tag : null;
    },
    onFocus(event) {
      const tag = this.tagFor(event);
      if (tag) this.activate(tag);
    },
    onClick(event) {
      const tag = this.tagFor(event);
      if (!tag) return;
      const remove = event.target.closest?.('[data-hero-tag-remove]');
      if (remove && !remove.disabled) {
        this.pendingRemoval = {id: tag.id, index: this.tags().indexOf(tag), focus: this.$root.contains(document.activeElement)};
      } else if (!remove) { this.activate(tag, true); this.select(tag); }
    },
    onKeyDown(event) {
      const tag = this.tagFor(event);
      if (!tag || event.target !== tag) return;
      const enabled = this.tags(), index = enabled.indexOf(tag);
      const rtl = getComputedStyle(this.$root).direction === 'rtl';
      let next;
      if (event.key === 'ArrowDown' || event.key === (rtl ? 'ArrowLeft' : 'ArrowRight')) next = enabled[Math.min(index + 1, enabled.length - 1)];
      else if (event.key === 'ArrowUp' || event.key === (rtl ? 'ArrowRight' : 'ArrowLeft')) next = enabled[Math.max(index - 1, 0)];
      else if (event.key === 'Home') next = enabled[0];
      else if (event.key === 'End') next = enabled.at(-1);
      else if (event.key === 'Escape' && this.keys.length && tag.dataset.selectionMode !== 'none' && (this.$root.dataset.controlled !== 'true' || this.$root.dataset.selectionEventId)) {
        event.preventDefault(); event.stopPropagation(); this.setSelection([]); return;
      } else if ((event.ctrlKey || event.metaKey) && event.key.toLowerCase() === 'a' && tag.dataset.selectionMode === 'multiple' && (this.$root.dataset.controlled !== 'true' || this.$root.dataset.selectionEventId)) {
        event.preventDefault(); this.setSelection(enabled.map(item=>item.dataset.key)); return;
      } else if ((event.key === ' ' || event.key === 'Enter') && tag.dataset.selectionMode !== 'none') {
        event.preventDefault(); tag.click(); return;
      } else if (event.key === 'Delete' || event.key === 'Backspace') {
        const remove = tag.querySelector('[data-hero-tag-remove]:not(:disabled)');
        if (remove) { event.preventDefault(); remove.click(); }
        return;
      } else return;
      event.preventDefault(); this.activate(next, true);
    }
  }));
}

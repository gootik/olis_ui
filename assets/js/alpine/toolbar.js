export function registerHeroToolbar(Alpine) {

  Alpine.data('heroToolbar', () => {
    const originals = new Map();
    const selector = 'button, a[href], input:not([type="hidden"]), select, textarea, [contenteditable="true"], [tabindex]';
    let observer = null;
    let active = null;

    return {
      init() {
        this.sync();
        observer = new MutationObserver(() => this.sync());
        observer.observe(this.$root, {
          subtree: true, childList: true, attributes: true,
          attributeFilter: ['disabled', 'aria-disabled', 'hidden', 'inert', 'aria-hidden']
        });
      },
      destroy() {
        observer?.disconnect();
        observer = null;
        for (const [element, value] of originals) {
          if (value === null) element.removeAttribute('tabindex');
          else element.setAttribute('tabindex', value);
        }
        originals.clear();
        active = null;
      },
      controls() {
        const toolbar = this.$root;
        return [...toolbar.querySelectorAll(selector)].filter(element => {
          if (element.closest('[data-hero-toolbar]') !== toolbar || element.matches(':disabled, [aria-disabled="true"]')) return false;
          if (element.closest('[hidden], [inert], [aria-hidden="true"], [popover], dialog, [role="menu"], [role="listbox"], [role="tablist"]')) return false;
          if (!element.getClientRects().length || getComputedStyle(element).visibility === 'hidden') return false;
          if (!originals.has(element)) originals.set(element, element.getAttribute('tabindex'));
          const initial = originals.get(element);
          return initial === null || Number(initial) >= 0;
        });
      },
      sync(preferred = null) {
        const toolbar = this.$root;
        for (const element of toolbar.querySelectorAll('[aria-disabled="true"]')) {
          if (!element.matches(selector) || element.closest('[data-hero-toolbar]') !== toolbar || element.closest('[popover], dialog, [role="menu"], [role="listbox"], [role="tablist"]')) continue;
          if (!originals.has(element)) originals.set(element, element.getAttribute('tabindex'));
          element.tabIndex = -1;
        }
        const items = this.controls();
        active = preferred && items.includes(preferred) ? preferred : items.includes(document.activeElement) ? document.activeElement : items.includes(active) ? active : items[0];
        for (const item of items) item.tabIndex = item === active ? 0 : -1;
        for (const element of originals.keys()) if (!element.isConnected) originals.delete(element);
      },
      onFocusIn(event) {
        if (event.target.closest?.('[data-hero-toolbar]') !== this.$root) return;
        if (this.controls().includes(event.target)) this.sync(event.target);
      },
      onKeyDown(event) {
        if (event.defaultPrevented || event.altKey || event.ctrlKey || event.metaKey || event.shiftKey) return;
        const target = event.target, toolbar = this.$root;
        if (target.closest?.('[data-hero-toolbar]') !== toolbar) return;
        if (target.matches('input, textarea, select, [contenteditable="true"], [role="slider"], [role="spinbutton"], [role="combobox"], [role="radio"], [role="tab"]')) return;
        const items = this.controls(), current = items.indexOf(target);
        if (current < 0 || items.length < 2) return;
        const vertical = toolbar.dataset.orientation === 'vertical', rtl = getComputedStyle(toolbar).direction === 'rtl';
        let next;
        if (event.key === 'Home') next = 0;
        else if (event.key === 'End') next = items.length - 1;
        else if (vertical && event.key === 'ArrowDown') next = (current + 1) % items.length;
        else if (vertical && event.key === 'ArrowUp') next = (current + items.length - 1) % items.length;
        else if (!vertical && event.key === 'ArrowRight') next = (current + (rtl ? items.length - 1 : 1)) % items.length;
        else if (!vertical && event.key === 'ArrowLeft') next = (current + (rtl ? 1 : items.length - 1)) % items.length;
        else return;
        event.preventDefault();
        this.sync(items[next]);
        items[next].focus();
      }
    };
  });
}

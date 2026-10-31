/** Arrow-key navigation for related toolbar controls. */
export function installToolbar(root = document) {
  const states = new WeakMap(), originals = new Map();
  const toolbars = () => root.querySelectorAll('[data-hero-toolbar]');
  const selector = 'button, a[href], input:not([type="hidden"]), select, textarea, [contenteditable="true"], [tabindex]';
  function controls(toolbar) {
    return [...toolbar.querySelectorAll(selector)].filter(el => {
      if (el.closest('[data-hero-toolbar]') !== toolbar || el.matches(':disabled, [aria-disabled="true"]')) return false;
      if (el.closest('[hidden], [inert], [aria-hidden="true"], [popover], dialog, [role="menu"], [role="listbox"], [role="tablist"]')) return false;
      if (!el.getClientRects().length || getComputedStyle(el).visibility === 'hidden') return false;
      if (!originals.has(el)) originals.set(el,el.getAttribute('tabindex'));
      const initial=originals.get(el);
      return initial === null || Number(initial) >= 0;
    });
  }
  function sync(toolbar, preferred = null) {
    for (const el of toolbar.querySelectorAll('[aria-disabled="true"]')) {
      if (!el.matches(selector) || el.closest('[data-hero-toolbar]') !== toolbar || el.closest('[popover], dialog, [role="menu"], [role="listbox"], [role="tablist"]')) continue;
      if (!originals.has(el)) originals.set(el,el.getAttribute('tabindex'));
      el.tabIndex = -1;
    }
    const items=controls(toolbar), old=states.get(toolbar), active=preferred && items.includes(preferred) ? preferred : items.includes(document.activeElement) ? document.activeElement : items.includes(old?.active) ? old.active : items[0];
    for (const item of items) item.tabIndex = item === active ? 0 : -1;
    states.set(toolbar,{active});
  }
  function onFocusIn(event) {
    const toolbar=event.target.closest?.('[data-hero-toolbar]'); if (!toolbar || !root.contains(toolbar)) return;
    if (controls(toolbar).includes(event.target)) sync(toolbar,event.target);
  }
  function onKeyDown(event) {
    if (event.defaultPrevented || event.altKey || event.ctrlKey || event.metaKey || event.shiftKey) return;
    const target=event.target, toolbar=target.closest?.('[data-hero-toolbar]'); if (!toolbar || !root.contains(toolbar)) return;
    if (target.matches('input, textarea, select, [contenteditable="true"], [role="slider"], [role="spinbutton"], [role="combobox"], [role="radio"], [role="tab"]')) return;
    const items=controls(toolbar), current=items.indexOf(target); if (current < 0 || items.length < 2) return;
    const vertical=toolbar.dataset.orientation === 'vertical', rtl=getComputedStyle(toolbar).direction === 'rtl'; let next;
    if (event.key === 'Home') next=0;
    else if (event.key === 'End') next=items.length-1;
    else if (vertical && event.key === 'ArrowDown') next=(current+1)%items.length;
    else if (vertical && event.key === 'ArrowUp') next=(current+items.length-1)%items.length;
    else if (!vertical && event.key === 'ArrowRight') next=(current+(rtl ? items.length-1 : 1))%items.length;
    else if (!vertical && event.key === 'ArrowLeft') next=(current+(rtl ? 1 : items.length-1))%items.length;
    else return;
    event.preventDefault(); sync(toolbar,items[next]); items[next].focus();
  }
  function syncAll() { toolbars().forEach(toolbar=>sync(toolbar)); for (const el of originals.keys()) if (!el.isConnected) originals.delete(el); }
  const observer = new MutationObserver(records => {
    const changed = new Set();
    for (const record of records) {
      const target=record.target instanceof Element ? record.target : record.target.parentElement;
      const toolbar=target?.closest('[data-hero-toolbar]'); if (toolbar && root.contains(toolbar)) changed.add(toolbar);
      for (const node of record.addedNodes) if (node instanceof Element) {
        if (node.matches('[data-hero-toolbar]')) changed.add(node);
        node.querySelectorAll('[data-hero-toolbar]').forEach(item=>changed.add(item));
      }
    }
    changed.forEach(toolbar=>sync(toolbar));
  });
  syncAll(); observer.observe(root === document ? document.documentElement : root, {subtree:true,childList:true,attributes:true,attributeFilter:['disabled','aria-disabled','hidden','inert','aria-hidden']});
  root.addEventListener('focusin',onFocusIn); root.addEventListener('keydown',onKeyDown); document.addEventListener('phx:update',syncAll);
  return () => { observer.disconnect(); root.removeEventListener('focusin',onFocusIn); root.removeEventListener('keydown',onKeyDown); document.removeEventListener('phx:update',syncAll); for (const [el, value] of originals) { if (value === null) el.removeAttribute('tabindex'); else el.setAttribute('tabindex',value); } originals.clear(); };
}

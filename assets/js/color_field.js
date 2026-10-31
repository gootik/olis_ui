/** Commits hex colors on blur while preserving a regular text input for forms. */
export function installColorField(root = document) {
  const states = new WeakMap();
  const fields = () => root.querySelectorAll('[data-hero-color-field]');
  const inputFor = field => field.querySelector('[data-hero-color-input]');
  function normalize(value, allowAlpha) {
    const text = value.trim(); if (!text) return '';
    const hex = text.startsWith('#') ? text.slice(1) : text;
    const lengths = allowAlpha ? [3,4,6,8] : [3,6];
    if (!lengths.includes(hex.length) || !/^[0-9a-f]+$/i.test(hex)) return null;
    const expanded = hex.length <= 4 ? [...hex].map(char => char + char).join('') : hex;
    return `#${expanded.toUpperCase()}`;
  }
  function paint(field, value) {
    const swatch = field.querySelector('[data-hero-color-preview] [data-slot="color-swatch"]'); if (!swatch) return;
    const color = field.dataset.previewOverride === 'true' || field.dataset.channel !== 'hex' ? field.dataset.previewColor : value || '#E4E4E7';
    if (!color) return;
    swatch.style.setProperty('--color-swatch-current', color);
    swatch.setAttribute('aria-label', `Color preview: ${color}`);
  }
  function sync(field, force = false) {
    const input=inputFor(field); if (!input) return;
    let state=states.get(field);
    if (!state) { state={committed:normalize(input.value,field.dataset.allowAlpha === 'true') || ''}; states.set(field,state); }
    if (field.dataset.channel === 'hex' && (force || document.activeElement !== input)) {
      const value=normalize(input.value,field.dataset.allowAlpha === 'true');
      if (value !== null) state.committed=value;
    }
    paint(field,state.committed);
  }
  function commit(field) {
    const input=inputFor(field), state=states.get(field);
    if (!input || !state || field.dataset.channel !== 'hex' || input.readOnly || input.matches(':disabled')) return;
    const normalized=normalize(input.value,field.dataset.allowAlpha === 'true'), value=normalized === null ? state.committed : normalized;
    const changed=input.value !== value; input.value=value; state.committed=value; paint(field,value);
    if (changed) { input.dispatchEvent(new Event('input',{bubbles:true})); input.dispatchEvent(new Event('change',{bubbles:true})); }
  }
  function onFocusOut(event) {
    const input=event.target; if (!input.matches?.('[data-hero-color-input]')) return;
    const field=input.closest('[data-hero-color-field]'); if (field && root.contains(field)) commit(field);
  }
  function onChange(event) {
    const input=event.target; if (!input.matches?.('[data-hero-color-input]') || document.activeElement === input) return;
    const field=input.closest('[data-hero-color-field]'); if (field && root.contains(field)) sync(field);
  }
  function onSubmit(event) {
    if (!(event.target instanceof HTMLFormElement)) return;
    for (const input of event.target.elements) {
      if (!input.matches?.('[data-hero-color-input]')) continue;
      const field=input.closest('[data-hero-color-field]'); if (field && root.contains(field)) commit(field);
    }
  }
  function syncAll() { fields().forEach(field=>sync(field)); }
  function onReset() { setTimeout(()=>fields().forEach(field=>sync(field,true)),0); }
  syncAll(); root.addEventListener('focusout',onFocusOut); root.addEventListener('change',onChange); root.addEventListener('submit',onSubmit,true); root.addEventListener('reset',onReset); document.addEventListener('phx:update',syncAll);
  return () => { root.removeEventListener('focusout',onFocusOut); root.removeEventListener('change',onChange); root.removeEventListener('submit',onSubmit,true); root.removeEventListener('reset',onReset); document.removeEventListener('phx:update',syncAll); };
}

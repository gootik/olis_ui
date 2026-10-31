/** Gregorian date segments backed by an ordinary native date input. */
export function installDateField(root = document) {
  const states = new WeakMap();
  const fields = () => root.querySelectorAll('[data-hero-date-field]');
  const parts = field => ({ native: field.querySelector('[data-hero-date-native]'), ui: field.querySelector('[data-hero-date-ui]'), group: field.querySelector('[data-hero-date-group]'), segments: field.querySelector('[data-hero-date-segments]'), error: field.querySelector('[data-hero-date-error]') });
  const pad = (n, width = 2) => String(n).padStart(width, '0');
  function parse(value) {
    const match = /^(\d{4})-(\d{2})-(\d{2})$/.exec(value || '');
    if (!match) return { year: null, month: null, day: null };
    return { year: Number(match[1]), month: Number(match[2]), day: Number(match[3]) };
  }
  function daysInMonth(year, month) {
    if (!month) return 31;
    if (month === 2) return year && (year % 4 === 0 && (year % 100 !== 0 || year % 400 === 0)) ? 29 : 28;
    return [4, 6, 9, 11].includes(month) ? 30 : 31;
  }
  function dateValue(value) {
    const {year, month, day} = value;
    if (!year || year > 9999 || !month || month > 12 || !day || day > daysInMonth(year, month)) return '';
    return `${pad(year, 4)}-${pad(month)}-${pad(day)}`;
  }
  function locale(field) { return field.dataset.locale || field.closest('[lang]')?.lang || navigator.language || 'en-US'; }
  function formatParts(field) {
    try { return new Intl.DateTimeFormat(locale(field), {calendar:'gregory', numberingSystem:'latn', timeZone:'UTC', month:'2-digit', day:'2-digit', year:'numeric'}).formatToParts(new Date(Date.UTC(2006, 10, 22))); }
    catch (_) { return new Intl.DateTimeFormat('en-US', {timeZone:'UTC', month:'2-digit', day:'2-digit', year:'numeric'}).formatToParts(new Date(Date.UTC(2006, 10, 22))); }
  }
  function paint(field) {
    const {native, group, segments, error} = parts(field), state = states.get(field);
    const disabled = native.matches(':disabled'), invalid = native.getAttribute('aria-invalid') === 'true' || !error.hidden;
    group.toggleAttribute('data-disabled', disabled); if (disabled) group.dataset.disabled = 'true';
    group.toggleAttribute('data-invalid', invalid); if (invalid) group.dataset.invalid = 'true';
    group.classList.toggle('date-input-group--secondary', field.dataset.variant === 'secondary');
    group.classList.toggle('date-input-group--primary', field.dataset.variant !== 'secondary');
    group.classList.toggle('date-input-group--full-width', field.classList.contains('date-field--full-width'));
    const description = [native.getAttribute('aria-describedby'), !error.hidden && error.id].filter(Boolean).join(' ');
    if (description) group.setAttribute('aria-describedby', description); else group.removeAttribute('aria-describedby');
    for (const segment of segments.querySelectorAll('[data-hero-date-segment]')) {
      const type = segment.dataset.heroDateSegment, value = state.values[type], max = type === 'year' ? 9999 : type === 'month' ? 12 : daysInMonth(state.values.year, state.values.month);
      segment.textContent = value == null ? {month:'mm', day:'dd', year:'yyyy'}[type] : type === 'year' ? String(value) : pad(value);
      segment.setAttribute('aria-valuemin', '1'); segment.setAttribute('aria-valuemax', String(max));
      if (value == null) { delete segment.dataset.value; segment.dataset.placeholder = 'true'; segment.removeAttribute('aria-valuenow'); segment.setAttribute('aria-valuetext', 'Empty'); }
      else { segment.dataset.value = String(value); delete segment.dataset.placeholder; segment.setAttribute('aria-valuenow', String(value)); segment.setAttribute('aria-valuetext', segment.textContent); }
      if (disabled) { segment.dataset.disabled = 'true'; segment.setAttribute('aria-disabled', 'true'); segment.tabIndex = -1; segment.removeAttribute('contenteditable'); }
      else { delete segment.dataset.disabled; segment.removeAttribute('aria-disabled'); segment.tabIndex = 0; segment.setAttribute('contenteditable', native.readOnly ? 'false' : 'true'); }
      if (native.readOnly) segment.setAttribute('aria-readonly', 'true'); else segment.removeAttribute('aria-readonly');
      if (invalid) segment.dataset.invalid = 'true'; else delete segment.dataset.invalid;
    }
  }
  function build(field) {
    const {native, segments} = parts(field), state = states.get(field), active = document.activeElement?.dataset.heroDateSegment;
    segments.replaceChildren();
    for (const part of formatParts(field)) {
      const span = document.createElement('span'); span.className = 'date-input-group__segment'; span.dataset.slot = 'date-input-group-segment';
      if (['year', 'month', 'day'].includes(part.type)) {
        span.dataset.type = part.type; span.dataset.heroDateSegment = part.type; span.setAttribute('role', 'spinbutton');
        span.id = `${native.id}-${part.type}`; span.setAttribute('aria-label', part.type); span.setAttribute('aria-labelledby', `${span.id} ${native.id}-label`);
        span.setAttribute('inputmode', 'numeric'); span.setAttribute('enterkeyhint', 'next'); span.setAttribute('spellcheck', 'false'); span.setAttribute('autocorrect', 'off'); span.style.caretColor = 'transparent';
      } else { span.dataset.type = 'literal'; span.setAttribute('aria-hidden', 'true'); span.textContent = part.value; }
      segments.appendChild(span);
    }
    state.builtLocale = locale(field); paint(field);
    if (active) segments.querySelector(`[data-hero-date-segment="${active}"]`)?.focus({preventScroll:true});
  }
  function setValidity(field) {
    const {native} = parts(field), state = states.get(field), values = Object.values(state.values), partial = values.some(v => v != null) && !dateValue(state.values);
    let unavailable = []; try { unavailable = JSON.parse(field.dataset.unavailable || '[]'); } catch (_) { /* Ignore malformed configuration. */ }
    const blocked = Array.isArray(unavailable) && native.value && unavailable.includes(native.value);
    const message = partial ? 'Enter a complete, valid date.' : blocked ? 'This date is unavailable.' : '';
    if (message && (!native.validity.customError || state.managedError)) { native.setCustomValidity(message); state.managedError = true; }
    else if (!message && state.managedError) { native.setCustomValidity(''); state.managedError = false; }
  }
  function commit(field) {
    const {native, error} = parts(field), state = states.get(field), value = dateValue(state.values), changed = native.value !== value;
    native.value = value; state.lastValue = value; error.hidden = true; error.textContent = '';
    setValidity(field); paint(field);
    if (changed) { native.dispatchEvent(new Event('input', {bubbles:true})); native.dispatchEvent(new Event('change', {bubbles:true})); }
  }
  function sync(field) {
    const {native, ui, group, segments, error} = parts(field); if (!native || !ui || !group || !segments || !error) return;
    const hadFocus = document.activeElement === native;
    let state = states.get(field);
    if (!state) { state = {values:parse(native.value), lastValue:native.value, builtLocale:null, managedError:false, buffer:'', bufferType:null, bufferTime:0}; states.set(field, state); }
    else if (state.lastValue !== native.value) { state.values = parse(native.value); state.lastValue = native.value; state.buffer = ''; error.hidden = true; error.textContent = ''; }
    field.dataset.enhanced = 'true'; native.setAttribute('aria-hidden', 'true'); native.tabIndex = -1; ui.hidden = false;
    setValidity(field);
    if (state.builtLocale !== locale(field)) build(field); else paint(field);
    if (hadFocus) segments.querySelector('[data-hero-date-segment]:not([aria-disabled])')?.focus({preventScroll:true});
  }
  function nextSegment(segment, direction) {
    const all = [...segment.parentElement.querySelectorAll('[data-hero-date-segment]')], next = all[all.indexOf(segment) + direction];
    next?.focus();
  }
  function enterDigit(field, segment, digit) {
    const state = states.get(field), type = segment.dataset.heroDateSegment, now = Date.now(), max = type === 'year' ? 9999 : type === 'month' ? 12 : 31;
    let buffer = state.bufferType === type && now - state.bufferTime < 1500 ? state.buffer + digit : digit;
    if (Number(buffer) > max || buffer.length > (type === 'year' ? 4 : 2)) buffer = digit;
    state.buffer = buffer; state.bufferType = type; state.bufferTime = now;
    const number = Number(buffer); state.values[type] = number === 0 ? null : number; commit(field);
    const advance = type === 'year' ? buffer.length === 4 : buffer.length === 2 || (buffer.length === 1 && number > Math.floor(max / 10));
    if (advance) { state.buffer = ''; nextSegment(segment, 1); }
  }
  function onKeyDown(event) {
    const segment = event.target.closest?.('[data-hero-date-segment]'); if (!segment || !root.contains(segment)) return;
    const field = segment.closest('[data-hero-date-field]'), {native} = parts(field), state = states.get(field), type = segment.dataset.heroDateSegment;
    if (native.matches(':disabled')) return;
    if (event.key === 'ArrowLeft' || event.key === 'ArrowRight') { event.preventDefault(); state.buffer = ''; nextSegment(segment, event.key === 'ArrowLeft' ? -1 : 1); return; }
    if (native.readOnly) return;
    if (/^\d$/.test(event.key) && !event.ctrlKey && !event.metaKey && !event.altKey) { event.preventDefault(); enterDigit(field, segment, event.key); }
    else if (event.key === 'Backspace' || event.key === 'Delete') { event.preventDefault(); state.buffer = ''; state.values[type] = null; commit(field); }
    else if (['ArrowUp', 'ArrowDown', 'Home', 'End'].includes(event.key)) {
      event.preventDefault(); state.buffer = '';
      const max = type === 'year' ? 9999 : type === 'month' ? 12 : daysInMonth(state.values.year, state.values.month), current = state.values[type];
      state.values[type] = event.key === 'Home' ? 1 : event.key === 'End' ? max : current == null ? (event.key === 'ArrowUp' ? 1 : max) : event.key === 'ArrowUp' ? current % max + 1 : (current + max - 2) % max + 1;
      commit(field);
    }
  }
  function onBeforeInput(event) {
    const segment = event.target.closest?.('[data-hero-date-segment]'); if (!segment || !root.contains(segment)) return;
    const field = segment.closest('[data-hero-date-field]'), {native} = parts(field); if (native.readOnly || native.matches(':disabled')) { event.preventDefault(); return; }
    if (event.inputType === 'insertText' && /^\d$/.test(event.data || '')) { event.preventDefault(); enterDigit(field, segment, event.data); }
    else if (event.inputType?.startsWith('delete')) { event.preventDefault(); states.get(field).values[segment.dataset.heroDateSegment] = null; commit(field); }
    else event.preventDefault();
  }
  function onPaste(event) {
    const segment = event.target.closest?.('[data-hero-date-segment]'); if (!segment || !root.contains(segment)) return;
    const field = segment.closest('[data-hero-date-field]'), {native} = parts(field); if (native.readOnly || native.matches(':disabled')) return;
    event.preventDefault(); const text = event.clipboardData?.getData('text')?.trim(), value = parse(text);
    if (dateValue(value) === text) { states.get(field).values = value; states.get(field).buffer = ''; commit(field); }
  }
  function onFocus(event) { const segment = event.target.closest?.('[data-hero-date-segment]'); if (segment && root.contains(segment)) { const state = states.get(segment.closest('[data-hero-date-field]')); state.buffer = ''; state.bufferType = null; } }
  function onClick(event) {
    const label = event.target.closest?.('label'), native = label?.control, field = native?.closest('[data-hero-date-field]');
    if (field?.dataset.enhanced === 'true' && !native.matches(':disabled')) { event.preventDefault(); parts(field).segments.querySelector('[data-hero-date-segment]')?.focus(); }
  }
  function onInvalid(event) {
    const native = event.target; if (!native.matches?.('[data-hero-date-native]')) return;
    const field = native.closest('[data-hero-date-field]'); if (field.dataset.enhanced !== 'true') return;
    event.preventDefault(); const {error,segments} = parts(field); error.textContent = native.validationMessage; error.hidden = false; paint(field); segments.querySelector('[data-hero-date-segment]:not([aria-disabled])')?.focus();
  }
  function onChange(event) { if (event.target.matches?.('[data-hero-date-native]')) sync(event.target.closest('[data-hero-date-field]')); }
  function syncAll() { fields().forEach(sync); }
  function onReset() { setTimeout(() => { fields().forEach(field => { const {native,error} = parts(field), state = states.get(field); if (!state) return; state.values = parse(native.value); state.lastValue = native.value; state.buffer = ''; error.hidden = true; error.textContent = ''; }); syncAll(); }, 0); }
  syncAll(); root.addEventListener('keydown', onKeyDown); root.addEventListener('beforeinput', onBeforeInput); root.addEventListener('paste', onPaste); root.addEventListener('focusin', onFocus); root.addEventListener('click', onClick); root.addEventListener('invalid', onInvalid, true); root.addEventListener('change', onChange); root.addEventListener('reset', onReset); document.addEventListener('phx:update', syncAll);
  return () => { root.removeEventListener('keydown', onKeyDown); root.removeEventListener('beforeinput', onBeforeInput); root.removeEventListener('paste', onPaste); root.removeEventListener('focusin', onFocus); root.removeEventListener('click', onClick); root.removeEventListener('invalid', onInvalid, true); root.removeEventListener('change', onChange); root.removeEventListener('reset', onReset); document.removeEventListener('phx:update', syncAll); fields().forEach(field => { const {native,ui} = parts(field), state = states.get(field); if (state?.managedError) native.setCustomValidity(''); native.removeAttribute('aria-hidden'); native.removeAttribute('tabindex'); ui.hidden = true; delete field.dataset.enhanced; }); };
}

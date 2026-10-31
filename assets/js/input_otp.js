/** Enhance a single native input with HeroUI's visual OTP slots. */
export function installInputOTP(root = document) {
  const previous = new WeakMap();
  const fields = () => root.querySelectorAll('[data-hero-otp]');
  const inputFor = field => field.querySelector('[data-hero-otp-input]');

  function allowed(field, value) {
    const pattern = field.dataset.allowedPattern;
    if (!pattern) return true;
    try { return new RegExp(`^(?:${pattern})$`, 'v').test(value); }
    catch (_) {
      try { return new RegExp(`^(?:${pattern})$`, 'u').test(value); }
      catch (_) { return true; }
    }
  }
  function render(field) {
    const input = inputFor(field);
    if (!input) return;
    field.dataset.heroOtpReady = 'true';
    const disabled = input.matches(':disabled');
    if (disabled) field.dataset.disabled = 'true'; else delete field.dataset.disabled;
    const focused = document.activeElement === input && !disabled;
    const start = input.selectionStart ?? 0, end = input.selectionEnd ?? start;
    const active = Math.min(start, input.maxLength - 1);
    field.querySelectorAll('[data-hero-otp-index]').forEach(slot => {
      const index = Number(slot.dataset.heroOtpIndex);
      const character = input.value[index] || '';
      const value = slot.querySelector('[data-hero-otp-value]');
      const caret = slot.querySelector('[data-hero-otp-caret]');
      if (value.textContent !== character) value.textContent = character;
      value.hidden = !character;
      caret.hidden = !(focused && start === end && index === active && !character);
      if (character) slot.dataset.filled = 'true'; else delete slot.dataset.filled;
      if (focused && index === active) slot.dataset.active = 'true'; else delete slot.dataset.active;
      if (disabled) slot.dataset.disabled = 'true'; else delete slot.dataset.disabled;
      if (field.dataset.invalid === 'true') slot.dataset.invalid = 'true'; else delete slot.dataset.invalid;
    });
  }
  function syncAll() {
    fields().forEach(field => {
      const input = inputFor(field);
      if (!input) return;
      const state = previous.get(input);
      if (!state || state.value !== input.value) previous.set(input, {value: input.value, start: input.selectionStart, end: input.selectionEnd});
      render(field);
    });
  }
  function onInput(event) {
    const input = event.target;
    if (!input.matches?.('[data-hero-otp-input]') || event.isComposing) return;
    const field = input.closest('[data-hero-otp]'), state = previous.get(input);
    if (!allowed(field, input.value) && state) {
      input.value = state.value;
      input.setSelectionRange(state.start ?? input.value.length, state.end ?? input.value.length);
      event.stopImmediatePropagation();
      render(field);
      return;
    }
    const wasComplete = state?.value.length === input.maxLength;
    previous.set(input, {value: input.value, start: input.selectionStart, end: input.selectionEnd});
    render(field);
    if (!wasComplete && input.value.length === input.maxLength) {
      input.dispatchEvent(new CustomEvent('hero:otp-complete', {bubbles:true, detail:{value:input.value}}));
    }
  }
  function onPointerDown(event) {
    const input = event.target.closest?.('[data-hero-otp-input]');
    if (!input || input.matches(':disabled') || input.readOnly || event.button !== 0) return;
    const slots = Array.from(input.closest('[data-hero-otp]').querySelectorAll('[data-hero-otp-index]'));
    if (!slots.length) return;
    const nearest = slots.reduce((best, slot) => {
      const rect = slot.getBoundingClientRect(), distance = Math.abs(event.clientX - (rect.left + rect.width / 2));
      return distance < best.distance ? {slot, distance} : best;
    }, {slot:slots[0], distance:Infinity}).slot;
    event.preventDefault();
    input.focus({preventScroll:true});
    const index = Math.min(Number(nearest.dataset.heroOtpIndex), input.value.length);
    input.setSelectionRange(index, Math.min(index + 1, input.value.length));
    render(input.closest('[data-hero-otp]'));
  }
  function onSelection() {
    const input = document.activeElement;
    if (input?.matches?.('[data-hero-otp-input]') && root.contains(input)) {
      const state = previous.get(input);
      if (state) { state.start = input.selectionStart; state.end = input.selectionEnd; }
      render(input.closest('[data-hero-otp]'));
    }
  }
  function onFocus(event) {
    const field = event.target.closest?.('[data-hero-otp]');
    if (field) queueMicrotask(() => { if (field.isConnected) render(field); });
  }
  function onReset() { setTimeout(syncAll, 0); }
  syncAll();
  root.addEventListener('input', onInput);
  root.addEventListener('compositionend', onInput);
  root.addEventListener('pointerdown', onPointerDown);
  root.addEventListener('focusin', onFocus);
  root.addEventListener('focusout', onFocus);
  root.addEventListener('reset', onReset);
  document.addEventListener('selectionchange', onSelection);
  document.addEventListener('phx:update', syncAll);
  return () => {
    root.removeEventListener('input', onInput); root.removeEventListener('compositionend', onInput);
    root.removeEventListener('pointerdown', onPointerDown);
    root.removeEventListener('focusin', onFocus); root.removeEventListener('focusout', onFocus);
    root.removeEventListener('reset', onReset);
    document.removeEventListener('selectionchange', onSelection);
    document.removeEventListener('phx:update', syncAll);
    fields().forEach(field => { delete field.dataset.heroOtpReady; delete field.dataset.disabled; });
  };
}

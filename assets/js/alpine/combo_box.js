export function registerHeroComboBox(Alpine) {
  Alpine.data('heroComboBox', () => {
  const supportsPopover = typeof HTMLElement !== 'undefined' && typeof HTMLElement.prototype.showPopover === 'function';
  let root, resetTimer = null, nativeAttrs = null;
  const states = new WeakMap();
  const pointerOpen = new WeakMap();
  const parts = field => ({
    native: field.querySelector('[data-hero-combo-native]'), ui: field.querySelector('[data-hero-combo-ui]'),
    input: field.querySelector('[data-hero-combo-input]'), trigger: field.querySelector('[data-hero-combo-trigger]'),
    popup: field.querySelector('[data-hero-combo-popup]'), list: field.querySelector('[data-hero-combo-list]'),
    empty: field.querySelector('[data-hero-combo-empty]'), error: field.querySelector('[data-hero-combo-error]'),
    value: field.querySelector('[data-hero-combo-value]')
  });
  const selectedText = native => native.value ? (native.selectedOptions[0]?.textContent || '').trim() : '';
  const currentValue = native => native.multiple ? JSON.stringify(Array.from(native.selectedOptions, option => option.value)) : native.value;
  function initialOrder(field) {
    try { const values = JSON.parse(field.dataset.selectedOrder || '[]'); return Array.isArray(values) ? values.map(String) : []; }
    catch (_) { return []; }
  }
  function formatLabels(labels) {
    try { return new Intl.ListFormat(document.documentElement.lang || undefined, {style:'long', type:'conjunction'}).format(labels); }
    catch (_) { return labels.join(', '); }
  }
  const custom = field => field.dataset.custom === 'true';
  const items = list => Array.from(list.querySelectorAll('[role="option"]')).filter(item => item.getAttribute('aria-disabled') !== 'true');
  function active(input, item, scroll = false) {
    const list = document.getElementById(input.getAttribute('aria-controls'));
    list.querySelectorAll('[role="option"]').forEach(option => { if (option === item) option.dataset.active = 'true'; else delete option.dataset.active; });
    if (item) input.setAttribute('aria-activedescendant', item.id); else input.removeAttribute('aria-activedescendant');
    if (scroll && item) item.scrollIntoView({block:'nearest'});
  }
  function render(field) {
    const {native, input, list, empty, popup} = parts(field), state = states.get(field);
    const previous = list.querySelector('[data-active="true"]')?.dataset.index;
    const query = state.query.toLocaleLowerCase();
    list.replaceChildren();
    function append(option, parent) {
      if ((!native.multiple && option.index === 0) || option.hidden || !option.textContent.trim().toLocaleLowerCase().includes(query)) return false;
      const item = document.createElement('div');
      item.id = `${native.id}-combo-option-${option.index}`;
      item.className = 'list-box-item list-box-item--default';
      item.dataset.slot = 'list-box-item'; item.dataset.heroComboOption = ''; item.dataset.index = String(option.index);
      item.setAttribute('role', 'option'); item.setAttribute('aria-selected', String(option.selected));
      if (option.disabled || (option.parentElement.tagName === 'OPTGROUP' && option.parentElement.disabled)) { item.dataset.disabled = 'true'; item.setAttribute('aria-disabled', 'true'); }
      const label = document.createElement('span'); label.dataset.slot = 'label'; label.textContent = option.textContent.trim(); item.appendChild(label);
      const indicator = document.createElement('span'); indicator.className = 'list-box-item__indicator'; indicator.dataset.slot = 'list-box-item-indicator'; indicator.setAttribute('aria-hidden', 'true'); indicator.hidden = !option.selected;
      const svg = document.createElementNS('http://www.w3.org/2000/svg','svg'); svg.setAttribute('viewBox','0 0 16 16'); svg.setAttribute('fill','none'); svg.dataset.slot = 'list-box-item-indicator--checkmark';
      const path = document.createElementNS('http://www.w3.org/2000/svg','path'); path.setAttribute('d','M3.5 8l3 3 6-6'); path.setAttribute('stroke','currentColor'); path.setAttribute('stroke-width','2'); path.setAttribute('stroke-linecap','round'); path.setAttribute('stroke-linejoin','round'); svg.appendChild(path); indicator.appendChild(svg); item.appendChild(indicator); parent.appendChild(item);
      return true;
    }
    Array.from(native.children).forEach(child => {
      if (child.tagName === 'OPTION') append(child, list);
      else if (child.tagName === 'OPTGROUP' && !child.hidden) {
        const group = document.createElement('div'); group.className = 'list-box-section'; group.setAttribute('role','group'); group.setAttribute('aria-label',child.label);
        const header = document.createElement('div'); header.className = 'header'; header.setAttribute('aria-hidden','true'); header.textContent = child.label; group.appendChild(header);
        let count = 0; Array.from(child.children).forEach(option => { if (append(option, group)) count++; });
        if (count) list.appendChild(group);
      }
    });
    empty.hidden = list.querySelector('[role="option"]') !== null;
    if (popup.matches(':popover-open')) {
      const enabled = items(list);
      active(input, enabled.find(item => item.dataset.index === previous) || enabled.find(item => item.getAttribute('aria-selected') === 'true') || enabled[0]);
    } else input.removeAttribute('aria-activedescendant');
  }
  function sync(field) {
    const {native, ui, input, trigger, popup, error, value, list} = parts(field);
    if (!native || !ui || !input || !trigger || !popup || !error) return;
    let state = states.get(field);
    if (!state) { state = {value:currentValue(native), query:'', order:initialOrder(field)}; states.set(field, state); if (!custom(field)) input.value = native.multiple ? '' : selectedText(native); }
    else if (!custom(field) && state.value !== currentValue(native)) { state.value = currentValue(native); if (!native.multiple) { state.query = ''; input.value = selectedText(native); } }
    if (custom(field)) {
      const match = Array.from(native.options).find(option => option.index > 0 && option.textContent.trim() === input.value && !option.disabled && !(option.parentElement.tagName === 'OPTGROUP' && option.parentElement.disabled));
      native.selectedIndex = match ? match.index : 0; state.value = native.value;
      input.removeAttribute('list'); input.setAttribute('role','combobox'); input.setAttribute('aria-autocomplete','list'); input.setAttribute('aria-controls', `${input.id}-listbox`);
      if (!input.hasAttribute('aria-expanded')) input.setAttribute('aria-expanded','false');
      trigger.hidden = false;
    }
    field.dataset.enhanced = 'true'; native.setAttribute('aria-hidden','true'); native.tabIndex = -1; ui.hidden = false;
    input.placeholder = field.dataset.placeholder || '';
    input.classList.toggle('input--primary', field.dataset.variant !== 'secondary');
    input.classList.toggle('input--secondary', field.dataset.variant === 'secondary');
    input.classList.toggle('input--full-width', field.dataset.fullWidth === 'true');
    input.parentElement.classList.toggle('combo-box__input-group--full-width', field.dataset.fullWidth === 'true');
    trigger.setAttribute('aria-label', `Show ${field.querySelector('label')?.textContent.trim() || ''} options`);
    input.disabled = native.matches(':disabled'); trigger.disabled = input.disabled;
    if (input.disabled && popup.matches(':popover-open')) popup.hidePopover();
    input.setAttribute('aria-required', String(custom(field) ? input.required : native.required));
    if (native.getAttribute('aria-invalid') === 'true' || !error.hidden) input.setAttribute('aria-invalid','true'); else input.removeAttribute('aria-invalid');
    if (native.multiple) list.setAttribute('aria-multiselectable','true'); else list.removeAttribute('aria-multiselectable');
    if (value && native.multiple) {
      const selected = Array.from(native.selectedOptions);
      state.order = state.order.filter(key => selected.some(option => option.value === key));
      selected.forEach(option => { if (!state.order.includes(option.value)) state.order.push(option.value); });
      const labels = state.order.map(key => selected.find(option => option.value === key)?.textContent.trim()).filter(Boolean);
      value.textContent = labels.length ? formatLabels(labels) : (field.dataset.selectedPlaceholder || '');
      if (labels.length) { value.removeAttribute('data-placeholder'); value.setAttribute('aria-hidden','true'); }
      else { value.dataset.placeholder = 'true'; value.removeAttribute('aria-hidden'); }
    }
    const describedby = [native.getAttribute('aria-describedby'), value && native.multiple && value.textContent && value.id, !error.hidden && error.id].filter(Boolean).join(' ');
    if (describedby) input.setAttribute('aria-describedby',describedby); else input.removeAttribute('aria-describedby');
    render(field);
  }
  function position(field) {
    const {input, popup} = parts(field);
    if (!popup?.matches(':popover-open')) return;
    const anchor = input.getBoundingClientRect();
    popup.style.minWidth = `${Math.min(anchor.width, innerWidth - 16)}px`;
    const box = popup.getBoundingClientRect();
    popup.style.left = `${Math.max(8, Math.min(anchor.left, innerWidth - box.width - 8))}px`;
    popup.style.top = `${anchor.bottom + 4 + box.height <= innerHeight - 8 ? anchor.bottom + 4 : Math.max(8, anchor.top - box.height - 4)}px`;
  }
  function open(field, query = '') {
    const {input, popup} = parts(field);
    if (input.disabled) return;
    states.get(field).query = query; render(field);
    if (!popup.matches(':popover-open')) popup.showPopover();
    render(field); position(field);
  }
  function choose(field, item) {
    if (!item || item.getAttribute('aria-disabled') === 'true') return;
    const {native, input, popup, error} = parts(field), old = native.value, previousInput = input.value;
    if (native.multiple) {
      const option = native.options[Number(item.dataset.index)]; option.selected = !option.selected;
      const state = states.get(field); state.value = currentValue(native); state.query = '';
      state.order = state.order.filter(key => key !== option.value); if (option.selected) state.order.push(option.value);
      input.value = ''; error.hidden = true; error.textContent = '';
      sync(field); input.focus({preventScroll:true});
      native.dispatchEvent(new Event('change', {bubbles:true}));
      return;
    }
    native.selectedIndex = Number(item.dataset.index);
    const state = states.get(field); state.value = native.value; state.query = '';
    input.value = selectedText(native); error.hidden = true; error.textContent = '';
    if (popup.matches(':popover-open')) popup.hidePopover();
    sync(field); input.focus({preventScroll:true});
    if (custom(field)) {
      if (input.value !== previousInput) { state.selecting = true; input.dispatchEvent(new Event('input', {bubbles:true})); state.selecting = false; }
    } else if (native.value !== old) native.dispatchEvent(new Event('change', {bubbles:true}));
  }
  function onInput(event) {
    const input = event.target;
    if (!input.matches?.('[data-hero-combo-input]')) return;
    const field = input.closest('[data-hero-combo]'), {native, error} = parts(field), state = states.get(field);
    if (!state) return;
    if (custom(field)) {
      if (state.selecting) return;
      error.hidden = true; error.textContent = ''; state.query = input.value;
      sync(field); open(field, input.value); return;
    }
    // The visible query is not a form value. Only the native select sends changes to LiveView.
    event.stopPropagation();
    if (!native.multiple && native.value) { native.value = ''; state.value = ''; native.dispatchEvent(new Event('change', {bubbles:true})); }
    error.hidden = true; error.textContent = '';
    state.query = input.value; sync(field); open(field, input.value);
  }
  function onKeyDown(event) {
    const input = event.target;
    if (!input.matches?.('[data-hero-combo-input]') || input.disabled) return;
    const field = input.closest('[data-hero-combo]'), {popup, list} = parts(field), isOpen = popup.matches(':popover-open');
    if (event.key === 'ArrowDown' || event.key === 'ArrowUp') {
      event.preventDefault();
      if (!isOpen) { open(field); return; }
      const enabled = items(list), index = enabled.findIndex(item => item.id === input.getAttribute('aria-activedescendant'));
      active(input, enabled[Math.max(0, Math.min(enabled.length - 1, index + (event.key === 'ArrowDown' ? 1 : -1)))], true);
    } else if (event.key === 'Enter' && isOpen) {
      const item = document.getElementById(input.getAttribute('aria-activedescendant'));
      if (item) { event.preventDefault(); choose(field, item); }
    } else if (event.key === 'Escape' && isOpen) {
      event.preventDefault(); popup.hidePopover(); if (!custom(field)) input.value = parts(field).native.multiple ? '' : selectedText(parts(field).native); states.get(field).query = '';
    } else if (event.key === 'Tab' && isOpen) popup.hidePopover();
  }
  function onClick(event) {
    const option = event.target.closest?.('[data-hero-combo-option]');
    if (option && root.contains(option)) { choose(option.closest('[data-hero-combo]'), option); return; }
    const trigger = event.target.closest?.('[data-hero-combo-trigger]');
    if (trigger && root.contains(trigger) && !trigger.disabled) {
      const field = trigger.closest('[data-hero-combo]'), {input, popup} = parts(field);
      const wasOpen = pointerOpen.has(field) ? pointerOpen.get(field) : popup.matches(':popover-open');
      pointerOpen.delete(field);
      if (wasOpen) { if (popup.matches(':popover-open')) popup.hidePopover(); }
      else { open(field); input.focus({preventScroll:true}); }
      return;
    }
    const input = event.target.closest?.('[data-hero-combo-input]');
    if (input && root.contains(input) && !input.disabled) {
      const field = input.closest('[data-hero-combo]'), {popup} = parts(field);
      pointerOpen.delete(field);
      if (!popup.matches(':popover-open')) open(field, states.get(field).query);
      return;
    }
    const label = event.target.closest?.('label'), native = label?.control;
    if (native?.matches('[data-hero-combo-native]') && native.closest('[data-hero-combo]')?.dataset.enhanced === 'true') { event.preventDefault(); parts(native.closest('[data-hero-combo]')).input.focus(); }
  }
  function onPointerDown(event) {
    const control = event.target.closest?.('[data-hero-combo-input], [data-hero-combo-trigger]');
    if (control) { const field = control.closest('[data-hero-combo]'); pointerOpen.set(field, parts(field).popup.matches(':popover-open')); }
    if (event.target.closest?.('[data-hero-combo-option], [data-hero-combo-trigger]')) event.preventDefault();
  }
  function onFocusIn(event) {
    if (event.target.matches?.('[data-hero-combo-input]')) open(event.target.closest('[data-hero-combo]'));
  }
  function onFocusOut(event) {
    const input = event.target;
    if (!input.matches?.('[data-hero-combo-input]')) return;
    const field = input.closest('[data-hero-combo]');
    if (field.contains(event.relatedTarget)) return;
    const {native, popup} = parts(field);
    if (popup.matches(':popover-open')) popup.hidePopover();
    if (!custom(field)) input.value = native.multiple ? '' : selectedText(native); states.get(field).query = '';
  }
  function onToggle(event) {
    const popup = event.target;
    if (!popup.matches?.('[data-hero-combo-popup]') || !root.contains(popup)) return;
    const field = popup.closest('[data-hero-combo]'), {input, trigger} = parts(field), isOpen = popup.matches(':popover-open');
    input.setAttribute('aria-expanded',String(isOpen));
    trigger.setAttribute('aria-expanded',String(isOpen));
    if (isOpen) { trigger.dataset.open = 'true'; render(field); position(field); }
    else { delete trigger.dataset.open; input.removeAttribute('aria-activedescendant'); }
  }
  function onInvalid(event) {
    const native = event.target;
    if (!native.matches?.('[data-hero-combo-native]')) return;
    const field = native.closest('[data-hero-combo]');
    if (field.dataset.enhanced !== 'true') return;
    event.preventDefault(); const {input, error} = parts(field); error.textContent = native.validationMessage; error.hidden = false; sync(field); input.focus();
  }
  function onChange(event) {
    if (event.target.matches?.('[data-hero-combo-input]')) { if (!custom(event.target.closest('[data-hero-combo]'))) event.stopPropagation(); return; }
    if (!event.target.matches?.('[data-hero-combo-native]')) return;
    const field = event.target.closest('[data-hero-combo]'), state = states.get(field);
    if (state && state.value !== currentValue(event.target)) sync(field);
  }
  function syncCurrent() { if (root?.isConnected) sync(root); }
  function owns(event) { return event.target.closest?.('[data-hero-combo]') === root; }
  function restore(native, attr, value) {
    if (!native) return;
    if (value === null) native.removeAttribute(attr); else native.setAttribute(attr, value);
  }
  return {
    init() {
      root = this.$root;
      const native = parts(root).native;
      if (native) nativeAttrs = {hidden: native.getAttribute('aria-hidden'), tabindex: native.getAttribute('tabindex')};
      if (supportsPopover) syncCurrent();
    },
    destroy() {
      if (resetTimer !== null) clearTimeout(resetTimer);
      if (!supportsPopover || !root) return;
      const {native, ui, input, trigger, popup} = parts(root);
      if (popup?.matches(':popover-open')) popup.hidePopover();
      if (ui) ui.hidden = !custom(root);
      if (custom(root) && input) {
        input.setAttribute('list', `${input.id}-suggestions`);
        ['role', 'aria-controls', 'aria-expanded', 'aria-autocomplete', 'aria-activedescendant'].forEach(attr => input.removeAttribute(attr));
        if (trigger) trigger.hidden = true;
      }
      restore(native, 'aria-hidden', nativeAttrs?.hidden ?? null);
      restore(native, 'tabindex', nativeAttrs?.tabindex ?? null);
      delete root.dataset.enhanced;
      states.delete(root);
      pointerOpen.delete(root);
    },
    input(event) { if (supportsPopover && owns(event)) onInput(event); },
    change(event) { if (supportsPopover && owns(event)) onChange(event); },
    keydown(event) { if (supportsPopover && owns(event)) onKeyDown(event); },
    click(event) { if (supportsPopover && owns(event)) onClick(event); },
    pointerdown(event) { if (supportsPopover && owns(event)) onPointerDown(event); },
    focusin(event) { if (supportsPopover && owns(event)) onFocusIn(event); },
    focusout(event) { if (supportsPopover && owns(event)) onFocusOut(event); },
    toggle(event) { if (supportsPopover && owns(event)) onToggle(event); },
    invalid(event) { if (supportsPopover && owns(event)) onInvalid(event); },
    reset(event) {
      const {native, input} = parts(root);
      const form = custom(root) ? input?.form : native?.form;
      if (!supportsPopover || !form || event.target !== form) return;
      if (resetTimer !== null) clearTimeout(resetTimer);
      resetTimer = setTimeout(() => {
        resetTimer = null;
        if (!root?.isConnected) return;
        const {native, input, popup, error} = parts(root), state = states.get(root);
        if (!state) return;
        state.value = currentValue(native); state.query = ''; state.order = initialOrder(root);
        if (!custom(root)) input.value = native.multiple ? '' : selectedText(native);
        error.hidden = true; error.textContent = '';
        if (popup.matches(':popover-open')) popup.hidePopover();
        syncCurrent();
      }, 0);
    },
    sync() { if (supportsPopover) syncCurrent(); },
    position() { if (supportsPopover && root?.dataset.enhanced === 'true') position(root); }
  };
  });
}

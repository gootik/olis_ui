import { installSelect } from "./select.js";
import { installInputOTP } from "./input_otp.js";
import { installTagGroup } from "./tag_group.js";
import { installComboBox } from "./combo_box.js";
import { installCalendar } from "./calendar.js";
import { installDateField } from "./date_field.js";
import { installTimeField } from "./time_field.js";
import { installDatePicker } from "./date_picker.js";
import { installToast } from "./toast.js";
import { installColorField } from "./color_field.js";
import { installToolbar } from "./toolbar.js";
import { installScrollShadow } from "./scroll_shadow.js";
import { installAutocomplete } from "./autocomplete.js";
import { installSheet } from "./sheet.js";
import { installDropdown } from "./dropdown.js";
export { toast, updateToast, dismissToast, clearToasts } from "./toast.js";

/** Install delegated behavior for HeroUI components. Returns a cleanup function. */
export function installHeroUI(root = document) {
  const removeSelect = installSelect(root);
  const removeInputOTP = installInputOTP(root);
  const removeTagGroup = installTagGroup(root);
  const removeComboBox = installComboBox(root);
  const removeCalendar = installCalendar(root);
  const removeDateField = installDateField(root);
  const removeTimeField = installTimeField(root);
  const removeDatePicker = installDatePicker(root);
  const removeToast = installToast(root);
  const removeColorField = installColorField(root);
  const removeToolbar = installToolbar(root);
  const removeScrollShadow = installScrollShadow(root);
  const removeAutocomplete = installAutocomplete(root);
  const removeSheet = installSheet(root);
  const removeDropdown = installDropdown(root);
  const menuSearch = new WeakMap();
  function menuItems(menu) {
    return Array.from(menu.querySelectorAll('[role="menuitem"]')).filter(item => !item.disabled && item.getAttribute('aria-disabled') !== 'true');
  }
  function menuTrigger(menu) {
    return menu.parentElement?.querySelector('[popovertarget]');
  }
  function positionMenu(menu) {
    const trigger = menuTrigger(menu);
    if (!trigger || !menu.matches(':popover-open')) return;
    const rect = trigger.getBoundingClientRect();
    const box = menu.getBoundingClientRect();
    const left = Math.max(8, Math.min(rect.left, window.innerWidth - box.width - 8));
    const below = rect.bottom + 4;
    const top = below + box.height <= window.innerHeight - 8 ? below : Math.max(8, rect.top - box.height - 4);
    menu.style.left = `${left}px`;
    menu.style.top = `${top}px`;
  }
  function positionTooltip(tip) {
    const trigger = tip.parentElement?.querySelector('[data-hero-tooltip-trigger]');
    if (!trigger || !tip.matches(':popover-open')) return;
    const anchor = trigger.getBoundingClientRect(), box = tip.getBoundingClientRect();
    const left = Math.max(8, Math.min(anchor.left + (anchor.width - box.width) / 2, innerWidth - box.width - 8));
    const topPreferred = tip.dataset.placement !== 'bottom';
    const above = anchor.top - box.height - 6;
    const below = anchor.bottom + 6;
    const top = topPreferred ? (above >= 8 ? above : below) : (below + box.height <= innerHeight - 8 ? below : Math.max(8, above));
    tip.style.left = `${left}px`; tip.style.top = `${top}px`;
  }
  function repositionOpenMenus() {
    root.querySelectorAll('[data-hero-menu]:popover-open, [data-hero-popover]:popover-open').forEach(positionMenu);
    root.querySelectorAll('[data-hero-tooltip]:popover-open').forEach(positionTooltip);
  }
  const tooltipTimers = new WeakMap();
  function hideTooltip(container) {
    clearTimeout(tooltipTimers.get(container));
    const tip = container.querySelector('[data-hero-tooltip]');
    if (tip?.matches(':popover-open')) tip.hidePopover();
  }
  function showTooltip(container, delay) {
    clearTimeout(tooltipTimers.get(container));
    tooltipTimers.set(container, setTimeout(() => {
      const tip = container.querySelector('[data-hero-tooltip]');
      if (!tip || !container.isConnected) return;
      if (!tip.matches(':popover-open')) tip.showPopover();
      positionTooltip(tip);
    }, delay));
  }
  function onPointerOver(event) {
    const container = event.target.closest?.('[data-hero-tooltip-root]');
    if (!container || !root.contains(container) || container.contains(event.relatedTarget) || event.pointerType === 'touch') return;
    showTooltip(container, Number(container.dataset.delay) || 0);
  }
  function onPointerOut(event) {
    const container = event.target.closest?.('[data-hero-tooltip-root]');
    if (!container || container.contains(event.relatedTarget) || container.matches(':focus-within')) return;
    hideTooltip(container);
  }
  function onFocusIn(event) {
    const trigger = event.target.closest?.('[data-hero-tooltip-trigger]');
    if (trigger && root.contains(trigger)) showTooltip(trigger.closest('[data-hero-tooltip-root]'), 0);
  }
  function onTooltipFocusOut(event) {
    const container = event.target.closest?.('[data-hero-tooltip-root]');
    if (container && !container.contains(event.relatedTarget) && !container.matches(':hover')) hideTooltip(container);
  }
  function onToggle(event) {
    const menu = event.target;
    if (!menu.matches?.('[data-hero-menu], [data-hero-popover]')) return;
    const trigger = menuTrigger(menu);
    const open = menu.matches(':popover-open');
    trigger?.setAttribute('aria-expanded', String(open));
    if (open) {
      positionMenu(menu);
      if (menu.matches('[data-hero-popover]')) menu.focus();
      else {
        const items = menuItems(menu);
        (menu.dataset.heroFocusLast === 'true' ? items.at(-1) : items[0])?.focus();
        delete menu.dataset.heroFocusLast;
      }
    }
  }
  function onFocusOut(event) {
    const menu = event.target.closest?.('[data-hero-menu]');
    if (menu && event.relatedTarget && !menu.contains(event.relatedTarget) && menu.matches(':popover-open')) menu.hidePopover();
  }
  const listboxSearch = new WeakMap();
  function listboxItems(listbox) {
    return Array.from(listbox.querySelectorAll('[role="option"]')).filter(item => item.closest('[data-hero-listbox]') === listbox && item.getAttribute('aria-disabled') !== 'true');
  }
  function setListboxActive(listbox, item, scroll = false) {
    if (!item) { listbox.removeAttribute('aria-activedescendant'); return; }
    listbox.setAttribute('aria-activedescendant', item.id);
    listbox.querySelectorAll('[role="option"]').forEach(option => {
      if (option.closest('[data-hero-listbox]') === listbox) option.dataset.active = String(option === item);
    });
    if (scroll) item.scrollIntoView({block:'nearest'});
  }
  function reconcileListboxes() {
    root.querySelectorAll('[data-hero-listbox]').forEach(listbox => {
      const items = listboxItems(listbox), active = items.find(item => item.id === listbox.getAttribute('aria-activedescendant'));
      setListboxActive(listbox, active || items.find(item => item.getAttribute('aria-selected') === 'true') || items[0]);
    });
  }
  function onKeyDown(event) {
    const listbox = event.target.closest?.('[data-hero-listbox]');
    if (listbox && root.contains(listbox) && listbox.getAttribute('aria-disabled') !== 'true') {
      const items = listboxItems(listbox), current = items.findIndex(item => item.id === listbox.getAttribute('aria-activedescendant'));
      if (!items.length) return;
      let index;
      if (event.key === 'ArrowDown') index = (current + 1) % items.length;
      else if (event.key === 'ArrowUp') index = (current - 1 + items.length) % items.length;
      else if (event.key === 'Home') index = 0;
      else if (event.key === 'End') index = items.length - 1;
      else if (event.key === 'Enter' || event.key === ' ') { event.preventDefault(); (items[current] || items[0]).click(); return; }
      else if (event.key.length === 1 && !event.ctrlKey && !event.metaKey && !event.altKey) {
        const previous = listboxSearch.get(listbox);
        const query = ((previous && Date.now() - previous.time < 700 ? previous.text : '') + event.key).toLocaleLowerCase();
        listboxSearch.set(listbox, {text:query, time:Date.now()});
        const ordered = [...items.slice(current + 1), ...items.slice(0, current + 1)];
        const match = ordered.find(item => item.querySelector('[data-slot="label"]')?.textContent.trim().toLocaleLowerCase().startsWith(query));
        if (match) { event.preventDefault(); setListboxActive(listbox, match, true); }
        return;
      } else return;
      event.preventDefault(); setListboxActive(listbox, items[index], true); return;
    }
    if (event.key === 'Escape') {
      root.querySelectorAll('[data-hero-tooltip-root]').forEach(hideTooltip);
    }
    const menu = event.target.closest?.('[data-hero-menu]');
    if (menu && root.contains(menu)) {
      const items = menuItems(menu), current = items.indexOf(event.target.closest('[role="menuitem"]'));
      let index;
      if (event.key === 'ArrowDown') index = (current + 1) % items.length;
      else if (event.key === 'ArrowUp') index = (current - 1 + items.length) % items.length;
      else if (event.key === 'Home') index = 0;
      else if (event.key === 'End') index = items.length - 1;
      else if (event.key === 'Escape') { event.preventDefault(); menu.hidePopover(); menuTrigger(menu)?.focus(); return; }
      else if (event.key.length === 1 && !event.ctrlKey && !event.metaKey && !event.altKey && event.key !== ' ') {
        const previous = menuSearch.get(menu);
        const query = ((previous && Date.now() - previous.time < 700 ? previous.text : '') + event.key).toLocaleLowerCase();
        menuSearch.set(menu, {text: query, time: Date.now()});
        const ordered = [...items.slice(current + 1), ...items.slice(0, current + 1)];
        const match = ordered.find(item => item.textContent.trim().toLocaleLowerCase().startsWith(query));
        if (match) { event.preventDefault(); match.focus(); }
        return;
      }
      else return;
      if (items.length) { event.preventDefault(); items[index].focus(); }
      return;
    }
    const menuButton = event.target.closest?.('[popovertarget][aria-haspopup="menu"]');
    if (menuButton && (event.key === 'ArrowDown' || event.key === 'ArrowUp')) {
      const target = document.getElementById(menuButton.getAttribute('popovertarget'));
      if (target && !target.matches(':popover-open')) { event.preventDefault(); target.dataset.heroFocusLast = String(event.key === 'ArrowUp'); target.showPopover(); }
      return;
    }
  }
  function onAvatarError(event) {
    const image = event.target;
    if (image.matches?.('[data-hero-avatar-image]') && root.contains(image)) image.dataset.failed = 'true';
  }
  function onAvatarLoad(event) {
    const image = event.target;
    if (image.matches?.('[data-hero-avatar-image]') && root.contains(image)) delete image.dataset.failed;
  }
  function checkAvatar(image) {
    if (image.complete && image.naturalWidth === 0 && image.dataset.failed !== 'true') image.dataset.failed = 'true';
  }
  function scanAvatars(node) {
    if (node.matches?.('[data-hero-avatar-image]')) checkAvatar(node);
    node.querySelectorAll?.('[data-hero-avatar-image]').forEach(checkAvatar);
  }
  scanAvatars(root);
  const avatarObserver = new MutationObserver(records => {
    for (const record of records) {
      if (record.type === 'attributes') scanAvatars(record.target);
      else record.addedNodes.forEach(scanAvatars);
    }
  });
  avatarObserver.observe(root, {subtree: true, childList: true, attributes: true, attributeFilter: ['src', 'data-failed']});
  let sliderDrag = null;
  function syncSlider(slider, changed) {
    const inputs = [...slider.querySelectorAll('[data-hero-slider-input]')];
    if (!inputs.length) return;
    const index = inputs.indexOf(changed);
    if (index >= 0) {
      const lower = index ? Number(inputs[index - 1].value) : Number(changed.min);
      const upper = index < inputs.length - 1 ? Number(inputs[index + 1].value) : Number(changed.max);
      changed.value = Math.max(lower, Math.min(upper, Number(changed.value)));
    }
    const min = Number(inputs[0].min), max = Number(inputs[0].max);
    const values = inputs.map(input => Number(input.value));
    const percentages = values.map(value => (value - min) / (max - min) * 100);
    const start = values.length === 1 ? 0 : percentages[0], end = percentages.at(-1);
    const vertical = slider.dataset.orientation === 'vertical';
    const track = slider.querySelector('[data-hero-slider-track]'), fill = slider.querySelector('[data-hero-slider-fill]');
    const rtl = getComputedStyle(slider).direction === 'rtl';
    track.dataset.fillStart = String(start === 0); track.dataset.fillEnd = String(end === 100);
    fill.style[vertical ? 'bottom' : 'insetInlineStart'] = `${start}%`;
    fill.style[vertical ? 'height' : 'width'] = `${end - start}%`;
    slider.querySelectorAll('[data-hero-slider-thumb]').forEach((thumb, i) => {
      thumb.style[vertical ? 'bottom' : 'insetInlineStart'] = `${percentages[i]}%`;
      inputs[i].setAttribute('aria-valuemin', String(i ? values[i - 1] : min));
      inputs[i].setAttribute('aria-valuemax', String(i < values.length - 1 ? values[i + 1] : max));
    });
    slider.querySelectorAll('[data-slot="slider-steps"], [data-slot="slider-marks"]').forEach(node => { node.dataset.direction = rtl ? 'rtl' : 'ltr'; node.dataset.orientation = slider.dataset.orientation; });
    slider.querySelectorAll('[data-slot="slider-step"], [data-slot="slider-mark"]').forEach(node => { const value = Number(node.dataset.value); node.dataset.filled = String(value >= (values.length === 1 ? min : values[0]) && value <= values.at(-1)); });
    slider.querySelector('[data-hero-slider-output]').textContent = inputs.map(input => input.value).join(' – ');
  }
  function syncSliders() { root.querySelectorAll('[data-hero-slider]').forEach(slider => syncSlider(slider)); }
  function onSliderInput(event) {
    const input = event.target;
    if (input.matches?.('[data-hero-slider-input]') && root.contains(input)) syncSlider(input.closest('[data-hero-slider]'), input);
  }
  function sliderPointerValue(track, event) {
    const rect = track.getBoundingClientRect(), style = getComputedStyle(track), vertical = track.closest('[data-hero-slider]').dataset.orientation === 'vertical';
    const start = parseFloat(vertical ? style.borderBottomWidth : style.borderLeftWidth) || 0;
    const end = parseFloat(vertical ? style.borderTopWidth : style.borderRightWidth) || 0;
    let fraction = vertical ? (rect.bottom - start - event.clientY) / (rect.height - start - end) : (event.clientX - rect.left - start) / (rect.width - start - end);
    if (!vertical && style.direction === 'rtl') fraction = 1 - fraction;
    return Math.max(0, Math.min(1, fraction));
  }
  function moveSlider(event) {
    if (!sliderDrag || event.pointerId !== sliderDrag.pointerId) return;
    const {track, input} = sliderDrag, min = Number(input.min), max = Number(input.max), step = Number(input.step);
    const fraction = sliderPointerValue(track, event), value = min + Math.round((min + fraction * (max - min) - min) / step) * step;
    const decimals = number => { const [coefficient, exponent = '0'] = String(number).toLowerCase().split('e'); return Math.max(0, (coefficient.split('.')[1]?.length || 0) - Number(exponent)); };
    const precision = Math.min(15, Math.max(decimals(min), decimals(step)));
    const previous = input.value; input.value = String(Number(value.toFixed(precision)));
    if (input.value !== previous) input.dispatchEvent(new Event('input', {bubbles: true}));
  }
  function onSliderPointerDown(event) {
    const track = event.target.closest?.('[data-hero-slider-track]');
    if (!track || !root.contains(track) || event.button !== 0) return;
    const slider = track.closest('[data-hero-slider]'), inputs = [...slider.querySelectorAll('[data-hero-slider-input]')];
    if (!inputs.length || inputs[0].disabled) return;
    const fraction = sliderPointerValue(track, event), min = Number(inputs[0].min), max = Number(inputs[0].max), value = min + fraction * (max - min);
    const input = inputs.reduce((best, candidate) => {
      const distance = Math.abs(Number(candidate.value) - value), bestDistance = Math.abs(Number(best.value) - value);
      return distance < bestDistance || (distance === bestDistance && value >= Number(candidate.value)) ? candidate : best;
    });
    event.preventDefault(); input.focus({preventScroll: true}); track.setPointerCapture(event.pointerId);
    sliderDrag = {track, input, pointerId: event.pointerId, initial: input.value};
    input.nextElementSibling.dataset.dragging = 'true'; moveSlider(event);
  }
  function onSliderPointerEnd(event) {
    if (!sliderDrag || event.pointerId !== sliderDrag.pointerId) return;
    const {input, initial} = sliderDrag; delete input.nextElementSibling.dataset.dragging; sliderDrag = null;
    if (input.value !== initial) input.dispatchEvent(new Event('change', {bubbles: true}));
  }
  function onFormReset() { setTimeout(syncSliders, 0); }
  function onClick(event) {
    const inputGroup = event.target.closest?.('[data-hero-input-group]');
    if (inputGroup && root.contains(inputGroup) && !event.target.closest('input, textarea, select, button, a, [contenteditable="true"], [role="button"]')) {
      const input = inputGroup.querySelector('[data-slot="input-group-input"], [data-slot="input-group-textarea"]');
      if (input && !input.matches(':disabled')) input.focus();
    }
    const option = event.target.closest?.('[role="option"]');
    const listbox = option?.closest('[data-hero-listbox]');
    if (listbox && root.contains(listbox) && listbox.getAttribute('aria-disabled') !== 'true' && option.getAttribute('aria-disabled') !== 'true') {
      setListboxActive(listbox, option); listbox.focus({preventScroll:true});
    }
    const closePopover = event.target.closest?.('[data-hero-popover-close]');
    if (closePopover && root.contains(closePopover)) {
      const popover = closePopover.closest('[data-hero-popover]');
      if (popover?.matches(':popover-open')) { popover.hidePopover(); menuTrigger(popover)?.focus(); }
    }
    const close = event.target.closest?.('[data-hero-dialog-close]');
    if (close && root.contains(close)) {
      const dialog = close.closest('dialog[data-hero-dialog]');
      if (dialog?.open) dialog.close();
    }
    const item = event.target.closest?.('[role="menuitem"]');
    const menu = item?.closest('[data-hero-menu]');
    if (menu && !item.disabled && item.getAttribute('aria-disabled') !== 'true') { menu.hidePopover(); if (item.tagName !== 'A') menuTrigger(menu)?.focus(); }

    const trigger = event.target.closest?.('[data-hero-dialog-open]');
    if (trigger && root.contains(trigger)) {
      const id = trigger.getAttribute('data-hero-dialog-open');
      const dialog = root.getElementById ? root.getElementById(id) : document.getElementById(id);
      if (dialog instanceof HTMLDialogElement && !dialog.matches('[data-hero-drawer]') && !dialog.open) dialog.showModal();
      return;
    }
    const dialog = event.target;
    if (!(dialog instanceof HTMLDialogElement) || !dialog.matches('[data-hero-dialog][data-dismissible="true"]')) return;
    const rect = dialog.getBoundingClientRect();
    if (event.clientX < rect.left || event.clientX > rect.right || event.clientY < rect.top || event.clientY > rect.bottom) dialog.close();
  }
  function onCancel(event) {
    if (event.target.matches?.('[data-hero-dialog][data-dismissible="false"]')) event.preventDefault();
  }
  window.addEventListener('resize', repositionOpenMenus);
  window.addEventListener('scroll', repositionOpenMenus, true);
  document.addEventListener('phx:update', reconcileListboxes);
  document.addEventListener('phx:update', syncSliders);
  syncSliders();
  root.addEventListener('error', onAvatarError, true);
  root.addEventListener('load', onAvatarLoad, true);
  root.addEventListener('input', onSliderInput, true);
  root.addEventListener('pointerdown', onSliderPointerDown);
  root.addEventListener('pointermove', moveSlider);
  root.addEventListener('pointerup', onSliderPointerEnd);
  root.addEventListener('pointercancel', onSliderPointerEnd);
  root.addEventListener('reset', onFormReset);
  root.addEventListener('pointerover', onPointerOver);
  root.addEventListener('pointerout', onPointerOut);
  root.addEventListener('focusin', onFocusIn);
  root.addEventListener('focusout', onTooltipFocusOut);
  root.addEventListener('toggle', onToggle, true);
  root.addEventListener('focusout', onFocusOut);
  root.addEventListener('click', onClick);
  root.addEventListener('keydown', onKeyDown);
  root.addEventListener('cancel', onCancel, true);
  return () => {
    removeSelect();
    removeInputOTP();
    removeTagGroup();
    removeComboBox();
    removeCalendar();
    removeDateField();
    removeTimeField();
    removeDatePicker();
    removeToast();
    removeColorField();
    removeToolbar();
    removeScrollShadow();
    removeAutocomplete();
    removeSheet();
    removeDropdown();
    window.removeEventListener('resize', repositionOpenMenus);
    window.removeEventListener('scroll', repositionOpenMenus, true);
    avatarObserver.disconnect();
    document.removeEventListener('phx:update', reconcileListboxes);
    document.removeEventListener('phx:update', syncSliders);
    root.removeEventListener('error', onAvatarError, true);
    root.removeEventListener('load', onAvatarLoad, true);
    root.removeEventListener('input', onSliderInput, true);
    root.removeEventListener('pointerdown', onSliderPointerDown);
    root.removeEventListener('pointermove', moveSlider);
    root.removeEventListener('pointerup', onSliderPointerEnd);
    root.removeEventListener('pointercancel', onSliderPointerEnd);
    root.removeEventListener('reset', onFormReset);
    root.removeEventListener('pointerover', onPointerOver);
    root.removeEventListener('pointerout', onPointerOut);
    root.removeEventListener('focusin', onFocusIn);
    root.removeEventListener('focusout', onTooltipFocusOut);
    root.querySelectorAll('[data-hero-tooltip-root]').forEach(hideTooltip);
    root.removeEventListener('toggle', onToggle, true);
    root.removeEventListener('focusout', onFocusOut);
    root.removeEventListener('click', onClick);
    root.removeEventListener('keydown', onKeyDown);
    root.removeEventListener('cancel', onCancel, true);
  };
}

import { installToast } from "./toast.js";

/** Register Alpine state used by HeroUI components before calling Alpine.start(). */
export function registerHeroUIAlpine(Alpine) {
  Alpine.data('heroAvatarImage', () => ({
    sync() {
      if (!this.$el.complete) return;
      if (this.$el.naturalWidth) this.$el.removeAttribute('data-failed');
      else this.$el.dataset.failed = 'true';
    },
    init() { this.sync(); }
  }));

  Alpine.data('heroInputGroup', () => ({
    focusInput(event) {
      const target = event.target;
      if (target.closest('[data-hero-input-group]') !== this.$root ||
          target.closest('input, textarea, select, button, a, [contenteditable="true"], [role="button"]')) return;
      const input = this.$root.querySelector('[data-slot="input-group-input"], [data-slot="input-group-textarea"]');
      if (input && !input.matches(':disabled')) input.focus();
    }
  }));

  Alpine.data('heroSelect', () => {
  const searches = new WeakMap();
  const supportsPopover = typeof HTMLElement !== 'undefined' && typeof HTMLElement.prototype.showPopover === 'function';
  let root, resetFrame = null, nativeAttributes = null;

  const parts = container => ({
    native: container.querySelector('[data-hero-native-select]'),
    ui: container.querySelector('[data-hero-select-ui]'),
    button: container.querySelector('[data-hero-select-trigger]'),
    popup: container.querySelector('[data-hero-select-popup]'),
    list: container.querySelector('[data-hero-select-list]'),
    error: container.querySelector('[data-hero-select-error]')
  });
  const enabledItems = list => Array.from(list.querySelectorAll('[role="option"]')).filter(item => item.getAttribute('aria-disabled') !== 'true');
  function setActive(button, item, scroll = false) {
    const list = document.getElementById(button.getAttribute('aria-controls'));
    list?.querySelectorAll('[role="option"]').forEach(option => { option.dataset.active = String(option === item); });
    if (item) button.setAttribute('aria-activedescendant', item.id); else button.removeAttribute('aria-activedescendant');
    if (scroll && item) item.scrollIntoView({block:'nearest'});
  }
  function syncName(native, ...targets) {
    const labelledby = native.getAttribute('aria-labelledby');
    const label = native.getAttribute('aria-label') || Array.from(native.labels || []).map(node => node.textContent.trim()).join(' ').trim();
    targets.forEach(target => {
      if (labelledby) { target.setAttribute('aria-labelledby', labelledby); target.removeAttribute('aria-label'); }
      else { target.removeAttribute('aria-labelledby'); if (label) target.setAttribute('aria-label', label); else target.removeAttribute('aria-label'); }
    });
  }
  function restoreNative(native) {
    if (!native || !nativeAttributes) return;
    for (const [name, value] of Object.entries(nativeAttributes)) {
      if (value == null) native.removeAttribute(name); else native.setAttribute(name, value);
    }
  }
  function sync(container, rebuild = false) {
    const {native, ui, button, popup, list, error} = parts(container);
    if (!native || !ui || !button || !popup || !list) return;
    if (native.multiple || native.size > 1) {
      if (popup.matches(':popover-open')) popup.hidePopover();
      ui.hidden = true; delete container.dataset.enhanced;
      restoreNative(native);
      return;
    }
    container.dataset.enhanced = 'true';
    native.setAttribute('aria-hidden', 'true'); native.tabIndex = -1;
    ui.hidden = false;
    button.disabled = native.matches(':disabled');
    if (button.disabled && popup.matches(':popover-open')) popup.hidePopover();
    syncName(native, button, list);
    button.setAttribute('aria-required', String(native.required));
    if (native.getAttribute('aria-invalid') === 'true' || !error.hidden) button.setAttribute('aria-invalid', 'true');
    else button.removeAttribute('aria-invalid');
    const descriptions = [native.getAttribute('aria-describedby'), !error.hidden && error.id].filter(Boolean).join(' ');
    if (descriptions) button.setAttribute('aria-describedby', descriptions); else button.removeAttribute('aria-describedby');
    const chosen = native.selectedOptions[0];
    const value = button.querySelector('[data-hero-select-value]');
    value.textContent = chosen?.textContent || '';
    value.dataset.placeholder = String(!chosen || (chosen.value === '' && chosen.index === 0));
    if (!rebuild) return;
    const oldActive = list.querySelector('[data-active="true"]')?.dataset.index;
    list.replaceChildren();
    function appendOption(option, parent) {
      if (option.hidden) return;
      const index = option.index;
      const item = document.createElement('div');
      item.id = `${native.id}-option-${index}`;
      item.className = 'list-box-item list-box-item--default';
      item.setAttribute('role', 'option');
      item.setAttribute('aria-selected', String(option.selected));
      const disabled = option.disabled || (option.parentElement?.tagName === 'OPTGROUP' && option.parentElement.disabled);
      if (disabled) { item.setAttribute('aria-disabled', 'true'); item.dataset.disabled = 'true'; }
      item.dataset.heroSelectOption = ''; item.dataset.index = String(index);
      const label = document.createElement('span'); label.dataset.slot = 'label'; label.textContent = option.textContent; item.appendChild(label);
      const indicator = document.createElement('span'); indicator.className = 'list-box-item__indicator'; indicator.setAttribute('aria-hidden', 'true'); indicator.hidden = !option.selected;
      const svg = document.createElementNS('http://www.w3.org/2000/svg','svg'); svg.setAttribute('viewBox','0 0 16 16'); svg.setAttribute('fill','none'); svg.dataset.slot = 'list-box-item-indicator--checkmark';
      const path = document.createElementNS('http://www.w3.org/2000/svg','path'); path.setAttribute('d','M3.5 8l3 3 6-6'); path.setAttribute('stroke','currentColor'); path.setAttribute('stroke-width','2'); path.setAttribute('stroke-linecap','round'); path.setAttribute('stroke-linejoin','round'); svg.appendChild(path); indicator.appendChild(svg); item.appendChild(indicator);
      parent.appendChild(item);
    }
    Array.from(native.children).forEach(child => {
      if (child.tagName === 'OPTGROUP') {
        if (child.hidden) return;
        const group = document.createElement('div'); group.className = 'list-box-section'; group.setAttribute('role', 'group'); group.setAttribute('aria-label', child.label);
        const header = document.createElement('div'); header.className = 'header'; header.setAttribute('aria-hidden', 'true'); header.textContent = child.label; group.appendChild(header);
        Array.from(child.children).forEach(option => appendOption(option, group));
        list.appendChild(group);
      } else if (child.tagName === 'OPTION') appendOption(child, list);
    });
    const enabled = enabledItems(list);
    const active = enabled.find(item => item.dataset.index === oldActive) || enabled.find(item => native.options[Number(item.dataset.index)].selected) || enabled[0];
    setActive(button, active);
  }
  function position(container) {
    const {button, popup} = parts(container);
    if (!button || !popup?.matches(':popover-open')) return;
    const anchor = button.getBoundingClientRect();
    popup.style.minWidth = `${Math.min(anchor.width, innerWidth - 16)}px`;
    const box = popup.getBoundingClientRect();
    popup.style.left = `${Math.max(8, Math.min(anchor.left, innerWidth - box.width - 8))}px`;
    popup.style.top = `${anchor.bottom + 4 + box.height <= innerHeight - 8 ? anchor.bottom + 4 : Math.max(8, anchor.top - box.height - 4)}px`;
  }
  function choose(container, item) {
    if (!item || item.getAttribute('aria-disabled') === 'true') return;
    const {native, button, popup, error} = parts(container);
    const previous = native.value;
    native.selectedIndex = Number(item.dataset.index);
    error.hidden = true; error.textContent = '';
    sync(container, true);
    if (popup.matches(':popover-open')) popup.hidePopover();
    button.focus({preventScroll:true});
    if (native.value !== previous) native.dispatchEvent(new Event('change', {bubbles:true}));
  }
  function onClick(event) {
    const item = event.target.closest?.('[data-hero-select-option]');
    if (item && item.closest('[data-hero-select-root]') === root) { choose(item.closest('[data-hero-select-root]'), item); return; }
    const label = event.target.closest?.('label');
    const native = label?.control;
    if (native?.matches('[data-hero-native-select]') && native.closest('[data-hero-select-root]') === root && root.dataset.enhanced === 'true' && !event.target.closest('button, a, input, select')) {
      event.preventDefault(); parts(native.closest('[data-hero-select-root]')).button.focus();
    }
  }
  function onToggle(event) {
    const popup = event.target;
    if (!popup.matches?.('[data-hero-select-popup]') || popup.closest('[data-hero-select-root]') !== root) return;
    const container = popup.closest('[data-hero-select-root]'), {button} = parts(container);
    const open = popup.matches(':popover-open');
    button.setAttribute('aria-expanded', String(open));
    if (open) { sync(container, true); position(container); button.focus({preventScroll:true}); }
    else button.removeAttribute('aria-activedescendant');
  }
  function onKeyDown(event) {
    const button = event.target.closest?.('[data-hero-select-trigger]');
    if (!button || button.closest('[data-hero-select-root]') !== root || button.disabled) return;
    const container = button.closest('[data-hero-select-root]'), {popup, list} = parts(container);
    const open = popup.matches(':popover-open');
    if (!open && (event.key === 'ArrowDown' || event.key === 'ArrowUp')) { event.preventDefault(); popup.showPopover(); return; }
    if (!open) return;
    const items = enabledItems(list), index = items.findIndex(item => item.id === button.getAttribute('aria-activedescendant'));
    if (event.key === 'Escape') { event.preventDefault(); popup.hidePopover(); return; }
    if (event.key === 'Tab') { popup.hidePopover(); return; }
    if (event.key === 'Enter' || event.key === ' ') { event.preventDefault(); choose(container, items[index]); return; }
    let next;
    if (event.key === 'ArrowDown') next = items[Math.min(index + 1, items.length - 1)];
    else if (event.key === 'ArrowUp') next = items[Math.max(index - 1, 0)];
    else if (event.key === 'Home') next = items[0];
    else if (event.key === 'End') next = items.at(-1);
    else if (event.key.length === 1 && !event.ctrlKey && !event.metaKey && !event.altKey) {
      const previous = searches.get(button), query = ((previous && Date.now() - previous.time < 700 ? previous.text : '') + event.key).toLocaleLowerCase();
      searches.set(button, {text:query, time:Date.now()});
      const ordered = [...items.slice(index + 1), ...items.slice(0, index + 1)];
      next = ordered.find(item => item.querySelector('[data-slot="label"]').textContent.trim().toLocaleLowerCase().startsWith(query));
    } else return;
    event.preventDefault(); if (next) setActive(button, next, true);
  }
  function onInvalid(event) {
    const native = event.target;
    if (!native.matches?.('[data-hero-native-select]')) return;
    const container = native.closest('[data-hero-select-root]');
    if (container !== root || container.dataset.enhanced !== 'true') return;
    event.preventDefault();
    const {button, error} = parts(container);
    error.textContent = native.validationMessage; error.hidden = false;
    sync(container); button.focus();
  }
  function syncAll() { if (root?.isConnected) sync(root, true); }
  function reposition() { if (root?.dataset.enhanced === 'true') position(root); }
  return {
    init() {
      root = this.$root;
      const native = parts(root).native;
      if (native) nativeAttributes = {'aria-hidden': native.getAttribute('aria-hidden'), tabindex: native.getAttribute('tabindex')};
      if (supportsPopover) syncAll();
    },
    destroy() {
      if (resetFrame != null) cancelAnimationFrame(resetFrame);
      if (!supportsPopover || !root) return;
      const {native, ui, popup} = parts(root);
      if (popup?.matches(':popover-open')) popup.hidePopover();
      if (ui) ui.hidden = true;
      restoreNative(native);
      delete root.dataset.enhanced;
    },
    click(event) { if (supportsPopover) onClick(event); },
    keydown(event) { if (supportsPopover) onKeyDown(event); },
    toggle(event) { if (supportsPopover) onToggle(event); },
    invalid(event) { if (supportsPopover) onInvalid(event); },
    change(event) { if (supportsPopover && event.target === parts(root).native) syncAll(); },
    reset(event) {
      if (!supportsPopover || event.target !== parts(root).native?.form) return;
      if (resetFrame != null) cancelAnimationFrame(resetFrame);
      resetFrame = requestAnimationFrame(() => { resetFrame = null; syncAll(); });
    },
    sync() { if (supportsPopover) syncAll(); },
    position() { if (supportsPopover) reposition(); }
  };
  });

  Alpine.data('heroScrollShadow', () => ({
    last: null,
    frame: null,
    resizeObserver: null,
    mutationObserver: null,
    observed: new Set(),
    destroyed: false,
    init() {
      if (typeof ResizeObserver !== 'undefined') {
        this.resizeObserver = new ResizeObserver(() => this.schedule());
        this.resizeObserver.observe(this.$root);
      }
      if (typeof MutationObserver !== 'undefined') {
        this.mutationObserver = new MutationObserver(() => this.schedule());
        this.mutationObserver.observe(this.$root, {
          subtree: true, childList: true, characterData: true, attributes: true,
          attributeFilter: ['class', 'style', 'hidden', 'dir']
        });
      }
      this.$nextTick(() => this.schedule());
    },
    destroy() {
      this.destroyed = true;
      this.resizeObserver?.disconnect();
      this.mutationObserver?.disconnect();
      if (this.frame != null) cancelAnimationFrame(this.frame);
      this.observed.clear();
    },
    schedule() {
      if (this.destroyed || !this.$root.isConnected || this.frame != null) return;
      this.frame = requestAnimationFrame(() => {
        this.frame = null;
        if (!this.destroyed && this.$root.isConnected) this.update();
      });
    },
    trackChildren() {
      if (!this.resizeObserver) return;
      const children = new Set(this.$root.children);
      for (const child of this.observed) {
        if (!children.has(child)) { this.resizeObserver.unobserve(child); this.observed.delete(child); }
      }
      for (const child of children) {
        if (!this.observed.has(child)) { this.resizeObserver.observe(child); this.observed.add(child); }
      }
    },
    update() {
      this.trackChildren();
      const element = this.$root, vertical = element.dataset.orientation !== 'horizontal';
      if (element.dataset.scrollShadowMode !== 'auto') {
        const requested = element.dataset.scrollShadowVisibility || 'none';
        const supported = vertical ? ['top', 'bottom', 'both'] : ['left', 'right', 'both'];
        const visibility = supported.includes(requested) ? requested : 'none';
        this.setEdges(vertical, visibility);
        element.dataset.heroScrollShadowCurrent = visibility;
        this.last = null;
        return;
      }
      const extent = vertical ? element.scrollHeight - element.clientHeight : element.scrollWidth - element.clientWidth;
      const position = vertical ? element.scrollTop : Math.abs(element.scrollLeft);
      const offset = Math.max(0, Number(element.dataset.scrollShadowOffset) || 0), tolerance = 0.5;
      const before = extent > tolerance && position > offset + tolerance;
      const after = extent > tolerance && position < extent - offset - tolerance;
      const visibility = before && after ? 'both' : before ? (vertical ? 'top' : 'left') : after ? (vertical ? 'bottom' : 'right') : 'none';
      this.setEdges(vertical, visibility);
      element.dataset.heroScrollShadowCurrent = visibility;
      if (this.last != null && this.last !== visibility) {
        element.dispatchEvent(new CustomEvent('hero:scroll-shadow-change', {bubbles: true, detail: {visibility}}));
        const button = element.querySelector(':scope > [data-hero-scroll-shadow-event]');
        if (button) { button.setAttribute('phx-value-visibility', visibility); button.click(); }
      }
      this.last = visibility;
    },
    setEdges(vertical, visibility) {
      const element = this.$root;
      for (const attr of ['top', 'bottom', 'top-bottom', 'left', 'right', 'left-right']) element.removeAttribute(`data-${attr}-scroll`);
      const attr = visibility === 'both' ? (vertical ? 'top-bottom' : 'left-right') : visibility;
      if (attr !== 'none') element.setAttribute(`data-${attr}-scroll`, 'true');
    }
  }));

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

  Alpine.data('heroToastRegion', () => ({
    cleanup: null,
    init() { this.cleanup = installToast(this.$root); },
    destroy() { this.cleanup?.(); this.cleanup = null; }
  }));

  Alpine.data('heroTooltip', () => ({
    hovering: false,
    focused: false,
    suppressed: false,
    openTimer: null,
    closeTimer: null,
    observer: null,
    init() {
      this.$nextTick(() => {
        if (!this.$root.isConnected || typeof ResizeObserver === 'undefined') return;
        this.observer = new ResizeObserver(() => this.position());
        if (this.$refs.trigger) this.observer.observe(this.$refs.trigger);
        if (this.$refs.content) this.observer.observe(this.$refs.content);
      });
    },
    destroy() {
      clearTimeout(this.openTimer);
      clearTimeout(this.closeTimer);
      this.observer?.disconnect();
      this.hide();
    },
    time(attribute, variable, fallback) {
      const explicit = this.$root.dataset[attribute];
      if (explicit !== undefined && explicit !== '') return Math.max(0, Number(explicit) || 0);
      const value = getComputedStyle(this.$root).getPropertyValue(variable).trim();
      if (!/^(?:\d+\.?\d*|\.\d+)\s*(?:ms|s)$/.test(value)) return fallback;
      const amount = parseFloat(value);
      return value.endsWith('ms') ? amount : amount * 1000;
    },
    enter(event) {
      if (event.pointerType === 'touch') return;
      this.hovering = true;
      clearTimeout(this.closeTimer);
      this.showAfter(this.time('delay', '--tooltip-delay', 1500));
    },
    leave(event) {
      if (event.pointerType === 'touch') return;
      this.hovering = false;
      this.maybeClose();
    },
    focus() {
      this.focused = true;
      clearTimeout(this.closeTimer);
      this.showAfter(0);
    },
    blur(event) {
      if (this.$root.contains(event.relatedTarget)) return;
      this.focused = false;
      this.maybeClose();
    },
    maybeClose() {
      if (this.hovering || this.focused) return;
      this.suppressed = false;
      clearTimeout(this.openTimer);
      clearTimeout(this.closeTimer);
      this.closeTimer = setTimeout(() => this.hide(), this.time('closeDelay', '--tooltip-close-delay', 500));
    },
    escape() {
      if (!this.hovering && !this.focused && !this.$refs.content?.matches(':popover-open')) return;
      this.suppressed = this.hovering || this.focused;
      clearTimeout(this.openTimer);
      clearTimeout(this.closeTimer);
      this.hide();
    },
    showAfter(delay) {
      if (this.suppressed) return;
      clearTimeout(this.openTimer);
      this.openTimer = setTimeout(() => {
        const content = this.$refs.content;
        if (!content || !this.$root.isConnected || (!this.hovering && !this.focused) || this.suppressed) return;
        if (!content.matches(':popover-open')) content.showPopover();
        this.position();
      }, delay);
    },
    hide() {
      const content = this.$refs.content;
      if (content?.matches(':popover-open')) content.hidePopover();
    },
    updated() {
      this.$nextTick(() => {
        if (this.observer) {
          this.observer.disconnect();
          if (this.$refs.trigger) this.observer.observe(this.$refs.trigger);
          if (this.$refs.content) this.observer.observe(this.$refs.content);
        }
        this.position();
      });
    },
    position() {
      const trigger = this.$refs.trigger, content = this.$refs.content;
      if (!trigger || !content?.matches(':popover-open')) return;
      const anchor = trigger.getBoundingClientRect(), box = content.getBoundingClientRect();
      const gap = Number(this.$root.dataset.offset) || 0;
      const margin = 8, width = window.innerWidth, height = window.innerHeight;
      const preferred = this.$root.dataset.requestedPlacement || 'top';
      const opposite = {top: 'bottom', bottom: 'top', left: 'right', right: 'left'};
      const space = {top: anchor.top - margin, bottom: height - anchor.bottom - margin,
                     left: anchor.left - margin, right: width - anchor.right - margin};
      const needed = (preferred === 'top' || preferred === 'bottom' ? box.height : box.width) + gap;
      const side = space[preferred] < needed && space[opposite[preferred]] > space[preferred] ? opposite[preferred] : preferred;
      let left = anchor.left + (anchor.width - box.width) / 2;
      let top = anchor.top + (anchor.height - box.height) / 2;
      if (side === 'top') top = anchor.top - box.height - gap;
      if (side === 'bottom') top = anchor.bottom + gap;
      if (side === 'left') left = anchor.left - box.width - gap;
      if (side === 'right') left = anchor.right + gap;
      left = Math.max(margin, Math.min(left, width - box.width - margin));
      top = Math.max(margin, Math.min(top, height - box.height - margin));
      content.style.left = `${left}px`;
      content.style.top = `${top}px`;
      content.dataset.placement = side;
    }
  }));

  // Selection and removal remain server-controlled; Alpine owns roving focus.
  Alpine.data('heroTagGroup', () => ({
    pendingRemoval: null,
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
    init() { this.sync(); },
    sync() {
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
      } else if (!remove) this.activate(tag, true);
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
      else if ((event.key === ' ' || event.key === 'Enter') && tag.dataset.selectionMode !== 'none') {
        event.preventDefault(); tag.click(); return;
      } else if (event.key === 'Delete' || event.key === 'Backspace') {
        const remove = tag.querySelector('[data-hero-tag-remove]:not(:disabled)');
        if (remove) { event.preventDefault(); remove.click(); }
        return;
      } else return;
      event.preventDefault(); this.activate(next, true);
    }
  }));

  // The real input owns editing, autofill, IME, and form submission.
  Alpine.data('heroInputOTP', () => ({
    previous: null,
    previousInput: null,
    init() { this.$nextTick(() => this.sync()); },
    destroy() {
      delete this.$root.dataset.heroOtpReady;
      delete this.$root.dataset.disabled;
    },
    allowed(value) {
      const pattern = this.$root.dataset.allowedPattern;
      if (!pattern) return true;
      try { return new RegExp(`^(?:${pattern})$`, 'v').test(value); }
      catch (_) {
        try { return new RegExp(`^(?:${pattern})$`, 'u').test(value); }
        catch (_) { return true; }
      }
    },
    render() {
      const input = this.$refs.input;
      if (!input) return;
      this.$root.dataset.heroOtpReady = 'true';
      const disabled = input.matches(':disabled');
      if (disabled) this.$root.dataset.disabled = 'true'; else delete this.$root.dataset.disabled;
      const focused = document.activeElement === input && !disabled;
      const start = input.selectionStart ?? 0, end = input.selectionEnd ?? start;
      const active = Math.min(start, input.maxLength - 1);
      this.$root.querySelectorAll('[data-hero-otp-index]').forEach(slot => {
        const index = Number(slot.dataset.heroOtpIndex), character = input.value[index] || '';
        const value = slot.querySelector('[data-hero-otp-value]');
        const caret = slot.querySelector('[data-hero-otp-caret]');
        if (value.textContent !== character) value.textContent = character;
        value.hidden = !character;
        caret.hidden = !(focused && start === end && index === active && !character);
        if (character) slot.dataset.filled = 'true'; else delete slot.dataset.filled;
        if (focused && index === active) slot.dataset.active = 'true'; else delete slot.dataset.active;
        if (disabled) slot.dataset.disabled = 'true'; else delete slot.dataset.disabled;
        if (this.$root.dataset.invalid === 'true') slot.dataset.invalid = 'true'; else delete slot.dataset.invalid;
      });
    },
    sync() {
      const input = this.$refs.input;
      if (!input) return;
      if (this.previousInput !== input || !this.previous || this.previous.value !== input.value) {
        this.previousInput = input;
        this.previous = {value: input.value, start: input.selectionStart, end: input.selectionEnd};
      }
      this.render();
    },
    onInput(event) {
      const input = this.$refs.input;
      if (event.target !== input || event.isComposing) return;
      const state = this.previous;
      if (!this.allowed(input.value) && state) {
        input.value = state.value;
        input.setSelectionRange(state.start ?? input.value.length, state.end ?? input.value.length);
        event.stopImmediatePropagation();
        this.render();
        return;
      }
      const wasComplete = state?.value.length === input.maxLength;
      this.previous = {value: input.value, start: input.selectionStart, end: input.selectionEnd};
      this.render();
      if (!wasComplete && input.value.length === input.maxLength) {
        input.dispatchEvent(new CustomEvent('hero:otp-complete', {bubbles: true, detail: {value: input.value}}));
      }
    },
    onPointerDown(event) {
      const input = this.$refs.input;
      if (event.target !== input || input.matches(':disabled') || input.readOnly || event.button !== 0) return;
      const slots = [...this.$root.querySelectorAll('[data-hero-otp-index]')];
      if (!slots.length) return;
      const nearest = slots.reduce((best, slot) => {
        const rect = slot.getBoundingClientRect(), distance = Math.abs(event.clientX - (rect.left + rect.width / 2));
        return distance < best.distance ? {slot, distance} : best;
      }, {slot: slots[0], distance: Infinity}).slot;
      event.preventDefault();
      input.focus({preventScroll: true});
      const index = Math.min(Number(nearest.dataset.heroOtpIndex), input.value.length);
      input.setSelectionRange(index, Math.min(index + 1, input.value.length));
      this.render();
    },
    onSelection() {
      const input = this.$refs.input;
      if (document.activeElement !== input) return;
      if (this.previous) { this.previous.start = input.selectionStart; this.previous.end = input.selectionEnd; }
      this.render();
    },
    onFocus() { queueMicrotask(() => { if (this.$root.isConnected) this.render(); }); },
    onReset(event) {
      if (event.target === this.$refs.input?.form) setTimeout(() => { if (this.$root.isConnected) this.sync(); }, 0);
    }
  }));

  // Native dialog retains browser focus trapping and focus restoration.
  Alpine.data('heroDrawer', () => ({
    closing: false,
    animations: [],
    destroy() { this.stopAnimations(); },
    stopAnimations() {
      for (const animation of this.animations) animation.cancel();
      this.animations = [];
    },
    animate(opening) {
      const dialog = this.$root;
      if (typeof dialog.animate !== 'function' || window.matchMedia?.('(prefers-reduced-motion: reduce)').matches) return null;
      const side = dialog.dataset.placement || 'right';
      const direction = {top: 'translateY(-100%)', bottom: 'translateY(100%)', left: 'translateX(-100%)', right: 'translateX(100%)'}[side];
      const start = opening ? direction : 'translate(0, 0)';
      const end = opening ? 'translate(0, 0)' : direction;
      const options = {duration: opening ? 250 : 200, easing: 'cubic-bezier(0.32, 0.72, 0, 1)'};
      const panel = dialog.animate([{transform: start}, {transform: end}], options);
      this.animations = [panel];
      try {
        const backdrop = dialog.animate([{opacity: opening ? 0 : 1}, {opacity: opening ? 1 : 0}], {...options, pseudoElement: '::backdrop'});
        this.animations.push(backdrop);
      } catch (_) {
        // The native backdrop remains usable when pseudo-element animation is unsupported.
      }
      for (const animation of this.animations) animation.finished.catch(() => {});
      return panel;
    },
    openFromTrigger(event) {
      const trigger = event.target.closest?.('[data-hero-dialog-open]');
      if (!trigger || trigger.getAttribute('data-hero-dialog-open') !== this.$root.id ||
          trigger.matches(':disabled, [aria-disabled="true"]')) return;
      if (this.$root.open) {
        if (this.closing) { this.closing = false; this.stopAnimations(); }
        return;
      }
      this.closing = false;
      this.stopAnimations();
      this.$root.showModal();
      this.animate(true);
    },
    close() {
      if (!this.$root.open || this.closing) return;
      this.stopAnimations();
      this.closing = true;
      const panel = this.animate(false);
      const finish = () => {
        if (!this.closing) return;
        this.closing = false;
        this.animations = [];
        if (this.$root.open) this.$root.close();
      };
      if (panel) panel.finished.then(finish, () => {}); else finish();
    },
    onClick(event) {
      const dialog = this.$root;
      const close = event.target.closest?.('[data-hero-dialog-close]');
      if (close && close.closest('dialog') === dialog) {
        this.close();
        return;
      }
      if (event.target !== dialog || dialog.dataset.dismissible !== 'true') return;
      const rect = dialog.getBoundingClientRect();
      if (event.clientX < rect.left || event.clientX > rect.right ||
          event.clientY < rect.top || event.clientY > rect.bottom) this.close();
    },
    onCancel() {
      if (this.$root.dataset.dismissible === 'true') this.close();
    }
  }));

  Alpine.data('heroSearchField', () => ({
    empty: true,
    locked: false,
    sync() {
      const input = this.$refs.input;
      if (!input) return;
      this.empty = input.value === '';
      this.locked = input.matches(':disabled') || input.readOnly;
    },
    clear() {
      const input = this.$refs.input;
      if (!input || this.locked || this.empty) return;
      input.value = '';
      input.dispatchEvent(new Event('input', {bubbles: true}));
      input.focus();
    }
  }));

  Alpine.data('heroNumberField', () => ({
    locked: true,
    disabled: false,
    cannotDecrease: false,
    cannotIncrease: false,
    sync() {
      const input = this.$refs.input;
      if (!input) return;
      this.disabled = input.matches(':disabled');
      this.locked = this.disabled || input.readOnly;
      const cannotStep = direction => {
        const probe = input.cloneNode();
        probe.value = input.value;
        try {
          if (direction === 'up') probe.stepUp(); else probe.stepDown();
          return probe.value === input.value;
        } catch (_) {
          return true;
        }
      };
      this.cannotDecrease = cannotStep('down');
      this.cannotIncrease = cannotStep('up');
    },
    step(direction) {
      const input = this.$refs.input;
      if (!input || input.matches(':disabled') || input.readOnly) return;
      const previous = input.value;
      if (direction === 'up') input.stepUp(); else input.stepDown();
      if (input.value !== previous) input.dispatchEvent(new Event('input', {bubbles: true}));
      this.sync();
    }
  }));

  Alpine.data('heroTabs', () => ({
    selected: null,
    focused: null,
    before: false,
    after: false,
    observer: null,
    init() {
      this.selected = this.$root.dataset.initialKey;
      this.focused = this.selected;
      this.$watch('selected', (key, previous) => {
        if (!previous || matchMedia('(prefers-reduced-motion: reduce)').matches) return;
        const tabs = this.tabs(), from = tabs.find(tab => tab.dataset.key === previous), to = tabs.find(tab => tab.dataset.key === key);
        if (!from || !to) return;
        const start = from.getBoundingClientRect(), end = to.getBoundingClientRect();
        if (!start.width || !start.height || !end.width || !end.height) return;
        this.$nextTick(() => to.querySelector('.tabs__indicator')?.animate([
          {transformOrigin: 'top left', transform: `translate(${start.left - end.left}px, ${start.top - end.top}px) scale(${start.width / end.width}, ${start.height / end.height})`},
          {transformOrigin: 'top left', transform: 'none'}
        ], {duration: 250, easing: 'cubic-bezier(0.22, 1, 0.36, 1)'}));
      });
      this.$nextTick(() => {
        if (typeof ResizeObserver !== 'undefined') {
          this.observer = new ResizeObserver(() => this.updateScroll());
          this.observer.observe(this.$refs.scroller);
          this.observer.observe(this.$refs.list);
        }
        this.updateScroll();
      });
    },
    destroy() { this.observer?.disconnect(); },
    tabs() {
      return [...this.$refs.list.querySelectorAll('[role="tab"]')]
        .filter(tab => tab.closest('[data-hero-tabs]') === this.$root && !tab.disabled);
    },
    sync() {
      const tabs = this.tabs();
      const controlled = this.$root.dataset.controlled === 'true';
      const desired = controlled ? this.$root.dataset.selectedKey : this.selected;
      const available = tabs.find(tab => tab.dataset.key === desired);
      if (controlled || !available) {
        this.selected = (available || tabs[0])?.dataset.key;
        if (!this.$refs.list.contains(document.activeElement) || !tabs.some(tab => tab.dataset.key === this.focused)) this.focused = this.selected;
      }
      this.updateScroll();
    },
    select(key) {
      if (!this.tabs().some(tab => tab.dataset.key === key)) return;
      this.focused = key;
      if (this.selected === key) return;
      if (this.$root.dataset.controlled !== 'true') this.selected = key;
      this.$dispatch('hero:tabs-change', {key});
      const eventButton = this.$refs.changeEvent;
      if (eventButton) { eventButton.setAttribute('phx-value-key', key); eventButton.click(); }
    },
    keydown(event) {
      const tabs = this.tabs(), current = tabs.indexOf(event.target.closest('[role="tab"]'));
      if (current < 0 || !tabs.length) return;
      const vertical = this.$root.dataset.orientation === 'vertical';
      const rtl = getComputedStyle(this.$root).direction === 'rtl';
      let index;
      if (event.key === 'Home') index = 0;
      else if (event.key === 'End') index = tabs.length - 1;
      else if (event.key === (vertical ? 'ArrowDown' : rtl ? 'ArrowLeft' : 'ArrowRight')) index = (current + 1) % tabs.length;
      else if (event.key === (vertical ? 'ArrowUp' : rtl ? 'ArrowRight' : 'ArrowLeft')) index = (current - 1 + tabs.length) % tabs.length;
      else return;
      event.preventDefault();
      const next = tabs[index];
      this.focused = next.dataset.key;
      if (this.$root.dataset.activationMode !== 'manual') this.select(next.dataset.key);
      next.focus({preventScroll: true});
      next.scrollIntoView({block: 'nearest', inline: 'nearest'});
    },
    leave(event) {
      if (!this.$refs.list.contains(event.relatedTarget)) this.focused = this.selected;
    },
    updateScroll() {
      const scroller = this.$refs.scroller;
      if (!scroller) return;
      const vertical = this.$root.dataset.orientation === 'vertical';
      const extent = vertical ? scroller.scrollHeight - scroller.clientHeight : scroller.scrollWidth - scroller.clientWidth;
      const position = vertical ? scroller.scrollTop : Math.abs(scroller.scrollLeft);
      this.before = extent > 0.5 && position > 0.5;
      this.after = extent > 0.5 && position < extent - 0.5;
    },
    scroll(direction) {
      const vertical = this.$root.dataset.orientation === 'vertical';
      const rtl = getComputedStyle(this.$root).direction === 'rtl';
      const amount = (direction === 'previous' ? -1 : 1) * 160;
      const behavior = matchMedia('(prefers-reduced-motion: reduce)').matches ? 'instant' : 'smooth';
      this.$refs.scroller.scrollBy(vertical ? {top: amount, behavior} : {left: rtl ? -amount : amount, behavior});
    }
  }));

  Alpine.data('heroAccordion', () => ({
    expanded: [],
    init() { this.expanded = JSON.parse(this.$root.dataset.initialExpanded); },
    triggers() {
      return [...this.$root.querySelectorAll('[data-accordion-trigger]')]
        .filter(button => button.closest('[data-hero-accordion]') === this.$root && !button.disabled);
    },
    sync() {
      if (this.$root.dataset.controlled === 'true') {
        this.setExpanded(JSON.parse(this.$root.dataset.expandedKeys));
      } else {
        const keys = [...this.$root.querySelectorAll('[data-accordion-trigger]')]
          .filter(button => button.closest('[data-hero-accordion]') === this.$root)
          .map(button => button.dataset.key);
        this.setExpanded(this.expanded.filter(key => keys.includes(key)));
      }
    },
    setExpanded(keys) {
      const panel = document.activeElement?.closest?.('[data-slot="accordion-panel"]');
      if (panel?.closest('[data-hero-accordion]') === this.$root && !keys.includes(panel.dataset.key)) {
        this.triggers().find(button => button.dataset.key === panel.dataset.key)?.focus({preventScroll: true});
      }
      this.expanded = keys;
    },
    toggle(key) {
      if (!this.triggers().some(button => button.dataset.key === key)) return;
      const open = !this.expanded.includes(key);
      const next = open
        ? (this.$root.dataset.multiple === 'true' ? [...this.expanded, key] : [key])
        : this.expanded.filter(value => value !== key);
      if (this.$root.dataset.controlled !== 'true') this.setExpanded(next);
      this.$dispatch('hero:accordion-change', {key, expanded: open, keys: next});
      const eventButton = this.$refs.changeEvent;
      if (eventButton) {
        eventButton.setAttribute('phx-value-key', key);
        eventButton.setAttribute('phx-value-expanded', String(open));
        eventButton.setAttribute('phx-value-keys', JSON.stringify(next));
        eventButton.click();
      }
    },
    keydown(event) {
      const triggers = this.triggers(), index = triggers.indexOf(event.target);
      if (index < 0) return;
      let next;
      if (event.key === 'ArrowDown') next = (index + 1) % triggers.length;
      else if (event.key === 'ArrowUp') next = (index - 1 + triggers.length) % triggers.length;
      else if (event.key === 'Home') next = 0;
      else if (event.key === 'End') next = triggers.length - 1;
      else return;
      event.preventDefault();
      triggers[next].focus();
    }
  }));

  Alpine.data('heroDisclosure', () => ({
    expanded: false,
    init() { this.expanded = this.$root.open; },
    beforeToggle(event) {
      if (this.$root.dataset.disabled === 'true') {
        event.preventDefault();
        event.stopPropagation();
      }
    },
    sync() {
      const details = this.$root;
      const group = details.parentElement;
      if (details.open && group?.matches('[data-hero-disclosure-group][data-allows-multiple-expanded="false"]')) {
        for (const sibling of group.children) {
          if (sibling !== details && sibling.matches('[data-hero-disclosure]') && sibling.open) sibling.open = false;
        }
      }
      if (!details.open && details.querySelector('[data-hero-disclosure-content]')?.contains(document.activeElement)) {
        details.querySelector('[data-hero-disclosure-trigger]')?.focus({preventScroll: true});
      }
      this.expanded = details.open;
    }
  }));
}

import { installToast } from "./toast.js";

/** Register Alpine state used by HeroUI components before calling Alpine.start(). */
export function registerHeroUIAlpine(Alpine) {
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

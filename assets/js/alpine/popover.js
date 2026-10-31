export function registerHeroPopover(Alpine) {
  Alpine.data('heroPopover', () => ({
    ignoredState: null,
    pendingReason: null,
    destroyed: false,
    trigger() {
      const ref = this.$refs.trigger;
      return ref?.matches('[data-hero-popover-trigger]') ? ref : ref?.querySelector('[data-hero-popover-trigger]');
    },
    init() {
      this.$nextTick(() => {
        if (this.destroyed) return;
        const root = this.$root;
        const open = root.dataset.controlled === 'true' ? root.dataset.controlledOpen === 'true' : root.dataset.defaultOpen === 'true';
        if (open) this.setOpen(true);
      });
    },
    destroy() {
      this.destroyed = true;
      const content = this.$refs.content;
      if (content?.matches(':popover-open')) content.hidePopover();
    },
    setOpen(open) {
      const content = this.$refs.content;
      if (!content || typeof content.showPopover !== 'function' || open === content.matches(':popover-open')) return;
      this.ignoredState = open;
      const restoreFocus = !open && content.contains(document.activeElement);
      if (open) content.showPopover(); else content.hidePopover();
      this.updateExpanded();
      if (open) this.position();
      else if (restoreFocus) this.trigger()?.focus({preventScroll:true});
    },
    updateExpanded() {
      const content = this.$refs.content;
      this.trigger()?.setAttribute('aria-expanded', String(!!content?.matches(':popover-open')));
    },
    position() {
      const trigger = this.trigger(), content = this.$refs.content;
      if (!trigger || !content?.matches(':popover-open')) return;
      const anchor = trigger.getBoundingClientRect(), box = content.getBoundingClientRect(), margin = 8;
      let [side, align] = (this.$root.dataset.requestedPlacement || 'bottom').split(' ');
      const offset = Number(this.$root.dataset.offset || 0);
      const opposite = {top:'bottom', bottom:'top', left:'right', right:'left'};
      const fits = {
        top: anchor.top - offset - box.height >= margin,
        bottom: anchor.bottom + offset + box.height <= window.innerHeight - margin,
        left: anchor.left - offset - box.width >= margin,
        right: anchor.right + offset + box.width <= window.innerWidth - margin
      };
      if (this.$root.dataset.shouldFlip !== 'false' && !fits[side] && fits[opposite[side]]) side = opposite[side];
      const rtl = getComputedStyle(trigger).direction === 'rtl';
      let left, top;
      if (side === 'top' || side === 'bottom') {
        top = side === 'top' ? anchor.top - box.height - offset : anchor.bottom + offset;
        if (align === 'start') left = rtl ? anchor.right - box.width : anchor.left;
        else if (align === 'end') left = rtl ? anchor.left : anchor.right - box.width;
        else left = anchor.left + (anchor.width - box.width) / 2;
      } else {
        left = side === 'left' ? anchor.left - box.width - offset : anchor.right + offset;
        if (align === 'start') top = anchor.top;
        else if (align === 'end') top = anchor.bottom - box.height;
        else top = anchor.top + (anchor.height - box.height) / 2;
      }
      content.style.left = `${Math.max(margin, Math.min(left, window.innerWidth - box.width - margin))}px`;
      content.style.top = `${Math.max(margin, Math.min(top, window.innerHeight - box.height - margin))}px`;
      content.dataset.placement = side;
    },
    notify(open, reason) {
      this.$root.dispatchEvent(new CustomEvent('hero:popover-open-change', {bubbles:true, detail:{open, reason}}));
      const button = this.$root.querySelector(':scope > [data-hero-popover-event]');
      if (button) {
        button.setAttribute('phx-value-open', String(open));
        button.setAttribute('phx-value-reason', reason);
        button.click();
      }
    },
    onClick(event) {
      const content = this.$refs.content, trigger = this.trigger();
      if (!content || !trigger) return;
      const targetTrigger = event.target.closest?.('[data-hero-popover-trigger]');
      if (targetTrigger === trigger && !trigger.matches(':disabled, [aria-disabled="true"]')) {
        if (this.$root.dataset.controlled === 'true') {
          event.preventDefault();
          this.notify(!content.matches(':popover-open'), 'trigger');
        } else this.pendingReason = 'trigger';
        return;
      }
      const close = event.target.closest?.('[data-hero-popover-close]');
      if (!close || close.closest('[data-hero-popover]') !== content || !content.matches(':popover-open')) return;
      if (this.$root.dataset.controlled === 'true') this.notify(false, 'close');
      else { this.pendingReason = 'close'; content.hidePopover(); trigger.focus({preventScroll:true}); }
    },
    toggle(event) {
      const content = this.$refs.content;
      if (this.destroyed || event.target !== content) return;
      const open = content.matches(':popover-open');
      this.updateExpanded();
      if (open) { this.position(); this.$refs.dialog?.focus({preventScroll:true}); }
      if (this.ignoredState === open) { this.ignoredState = null; this.pendingReason = null; return; }
      this.ignoredState = null;
      if (this.$root.dataset.controlled === 'true') {
        const expected = this.$root.dataset.controlledOpen === 'true';
        if (open !== expected) { this.notify(open, 'dismiss'); this.setOpen(expected); }
      } else this.notify(open, this.pendingReason || 'dismiss');
      this.pendingReason = null;
    },
    sync() {
      const content = this.$refs.content;
      if (!content) return;
      if (this.$root.dataset.controlled === 'true') this.setOpen(this.$root.dataset.controlledOpen === 'true');
      this.updateExpanded();
      this.position();
    }
  }));
}

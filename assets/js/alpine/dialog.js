export function registerHeroDialog(Alpine) {
  // Native dialog owns focus trapping and restoration; Alpine coordinates LiveView state.
  Alpine.data('heroDialog', () => ({
    ignoredCloseEvents: 0,
    destroyed: false,
    closing: false,
    animations: [],
    init() {
      const dialog = this.$root;
      if (!dialog.hasAttribute('data-hero-modal')) return;
      if (dialog.dataset.controlled === 'true' ? dialog.dataset.controlledOpen === 'true' : dialog.dataset.defaultOpen === 'true') this.show();
    },
    stopAnimations() {
      for (const animation of this.animations) animation.cancel();
      this.animations = [];
    },
    animate(opening) {
      const dialog = this.$root;
      if (typeof dialog.animate !== 'function' || dialog.closest?.('[data-reduce-motion="true"]') || window.matchMedia?.('(prefers-reduced-motion: reduce)').matches) return null;
      const placement = dialog.dataset.placement || 'auto';
      const smallScreen = window.matchMedia?.('(max-width: 639px)').matches;
      const offset = placement === 'top' ? '-0.25rem' : placement === 'bottom' || (placement === 'auto' && smallScreen) ? '0.25rem' : '0';
      const scale = dialog.classList.contains('modal__dialog--full') ? 1 : 1.05;
      const visible = {opacity: 1, transform: 'translate3d(0, 0, 0) scale(1)'};
      const hidden = opening ? {opacity: 0, transform: `translate3d(0, ${offset}, 0) scale(${scale})`} : {opacity: 0, transform: 'translate3d(0, 0, 0) scale(0.95)'};
      const options = {duration: opening ? 250 : 100, easing: 'cubic-bezier(0.25, 0.46, 0.45, 0.94)'};
      const panel = dialog.animate(opening ? [hidden, visible] : [visible, hidden], options);
      this.animations = [panel];
      try {
        this.animations.push(dialog.animate(opening ? [{opacity: 0}, {opacity: 1}] : [{opacity: 1}, {opacity: 0}], {duration: opening ? 150 : 100, easing: 'ease-out', pseudoElement: '::backdrop'}));
      } catch (_) {
        // Some browsers do not support animating native dialog backdrops.
      }
      for (const animation of this.animations) animation.finished.catch(() => {});
      return panel;
    },
    show() {
      if (this.$root.open) {
        if (this.closing) { this.closing = false; this.stopAnimations(); }
        return;
      }
      this.closing = false;
      this.stopAnimations();
      this.$root.showModal();
      if (this.$root.hasAttribute('data-hero-modal')) this.animate(true);
    },
    close() {
      if (!this.$root.open || this.closing) return;
      this.stopAnimations();
      this.closing = true;
      const panel = this.$root.hasAttribute('data-hero-modal') ? this.animate(false) : null;
      const finish = () => {
        if (!this.closing || this.destroyed) return;
        this.closing = false;
        this.animations = [];
        if (this.$root.open) { this.ignoredCloseEvents++; this.$root.close(); }
      };
      if (panel) panel.finished.then(finish, () => {}); else finish();
    },
    notify(open, reason) {
      if (!this.$root.hasAttribute('data-hero-modal')) return;
      this.$root.dispatchEvent(new CustomEvent('hero:modal-open-change', {bubbles: true, detail: {open, reason}}));
      const button = this.$root.querySelector(':scope > [data-hero-modal-event]');
      if (button) {
        button.setAttribute('phx-value-open', String(open));
        button.setAttribute('phx-value-reason', reason);
        button.click();
      }
    },
    request(open, reason) {
      if (open ? this.$root.open && !this.closing : !this.$root.open || this.closing) return;
      if (this.$root.dataset.controlled === 'true') { this.notify(open, reason); return; }
      if (open) this.show(); else this.close();
      this.notify(open, reason);
    },
    openFromTrigger(event) {
      const trigger = event.target.closest?.('[data-hero-dialog-open]');
      if (!trigger || trigger.getAttribute('data-hero-dialog-open') !== this.$root.id ||
          trigger.matches(':disabled, [aria-disabled="true"]')) return;
      this.request(true, 'trigger');
    },
    onClick(event) {
      const dialog = this.$root;
      const close = event.target.closest?.('[data-hero-dialog-close]');
      if (close && close.closest('dialog') === dialog) {
        this.request(false, 'close');
        return;
      }
      if (event.target !== dialog || dialog.dataset.dismissible !== 'true') return;
      const rect = dialog.getBoundingClientRect();
      if (event.clientX < rect.left || event.clientX > rect.right ||
          event.clientY < rect.top || event.clientY > rect.bottom) this.request(false, 'backdrop');
    },
    onCancel(event) {
      if (event.target !== this.$root) return;
      // AlertDialog retains its existing non-dismissible Escape behavior.
      if (!this.$root.hasAttribute('data-hero-modal')) {
        if (this.$root.dataset.dismissible === 'false') event.preventDefault();
        return;
      }
      event.preventDefault();
      if (this.$root.dataset.keyboardDismissDisabled !== 'true') this.request(false, 'escape');
    },
    onNativeClose(event) {
      if (event.target !== this.$root || this.destroyed) return;
      if (this.ignoredCloseEvents > 0) { this.ignoredCloseEvents--; return; }
      this.closing = false;
      this.stopAnimations();
      this.notify(false, 'native');
      if (this.$root.dataset.controlled === 'true' && this.$root.dataset.controlledOpen === 'true') this.show();
    },
    sync() {
      if (this.$root.dataset.controlled !== 'true') return;
      if (this.$root.dataset.controlledOpen === 'true') this.show(); else this.close();
    },
    destroy() { this.destroyed = true; this.stopAnimations(); if (this.$root.open) this.$root.close(); }
  }));
}

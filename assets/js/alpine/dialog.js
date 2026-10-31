export function registerHeroDialog(Alpine) {
  // Native dialog owns focus trapping and restoration; Alpine coordinates LiveView state.
  Alpine.data('heroDialog', () => ({
    ignoredCloseEvents: 0,
    destroyed: false,
    init() {
      const dialog = this.$root;
      if (!dialog.hasAttribute('data-hero-modal')) return;
      if (dialog.dataset.controlled === 'true' ? dialog.dataset.controlledOpen === 'true' : dialog.dataset.defaultOpen === 'true') this.show();
    },
    show() { if (!this.$root.open) this.$root.showModal(); },
    close() {
      if (this.$root.open) { this.ignoredCloseEvents++; this.$root.close(); }
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
      if (this.$root.open === open) return;
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
      this.notify(false, 'native');
      if (this.$root.dataset.controlled === 'true' && this.$root.dataset.controlledOpen === 'true') this.show();
    },
    sync() {
      if (this.$root.dataset.controlled !== 'true') return;
      if (this.$root.dataset.controlledOpen === 'true') this.show(); else this.close();
    },
    destroy() { this.destroyed = true; if (this.$root.open) this.$root.close(); }
  }));
}

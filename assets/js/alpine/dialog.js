export function registerHeroDialog(Alpine) {

  // Keep the native dialog responsible for focus trapping, Escape and focus restoration.
  Alpine.data('heroDialog', () => ({
    openFromTrigger(event) {
      const trigger = event.target.closest?.('[data-hero-dialog-open]');
      if (!trigger || trigger.getAttribute('data-hero-dialog-open') !== this.$root.id ||
          trigger.matches(':disabled, [aria-disabled="true"]') || this.$root.open) return;
      this.$root.showModal();
    },
    onClick(event) {
      const dialog = this.$root;
      const close = event.target.closest?.('[data-hero-dialog-close]');
      if (close && close.closest('dialog') === dialog) {
        if (dialog.open) dialog.close();
        return;
      }
      if (event.target !== dialog || dialog.dataset.dismissible !== 'true') return;
      const rect = dialog.getBoundingClientRect();
      if (event.clientX < rect.left || event.clientX > rect.right ||
          event.clientY < rect.top || event.clientY > rect.bottom) dialog.close();
    },
    onCancel(event) {
      if (event.target === this.$root && this.$root.dataset.dismissible === 'false') event.preventDefault();
    },
    destroy() { if (this.$root.open) this.$root.close(); }
  }));
}

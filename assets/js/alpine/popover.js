export function registerHeroPopover(Alpine) {

  // The browser owns opening, Escape, and light dismissal for auto popovers.
  Alpine.data('heroPopover', () => ({
    position() {
      const trigger = this.$refs.trigger, content = this.$refs.content;
      if (!trigger || !content?.matches(':popover-open')) return;
      const anchor = trigger.getBoundingClientRect(), box = content.getBoundingClientRect();
      const left = Math.max(8, Math.min(anchor.left, window.innerWidth - box.width - 8));
      const below = anchor.bottom + 4;
      const top = below + box.height <= window.innerHeight - 8 ? below : Math.max(8, anchor.top - box.height - 4);
      content.style.left = `${left}px`; content.style.top = `${top}px`;
    },
    toggle(event) {
      const content = this.$refs.content, trigger = this.$refs.trigger;
      if (event.target !== content || !trigger) return;
      const open = content.matches(':popover-open');
      trigger.setAttribute('aria-expanded', String(open));
      if (open) { this.position(); content.focus({preventScroll: true}); }
    },
    close(event) {
      const content = this.$refs.content, button = event.target.closest?.('[data-hero-popover-close]');
      if (!button || button.closest('[data-hero-popover]') !== content || !content.matches(':popover-open')) return;
      content.hidePopover(); this.$refs.trigger?.focus({preventScroll: true});
    },
    sync() {
      const content = this.$refs.content, trigger = this.$refs.trigger;
      if (!content || !trigger) return;
      trigger.setAttribute('aria-expanded', String(content.matches(':popover-open')));
      this.position();
    }
  }));
}

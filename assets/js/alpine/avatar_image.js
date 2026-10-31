export function registerHeroAvatarImage(Alpine) {

  Alpine.data('heroAvatarImage', () => ({
    sync() {
      if (!this.$el.complete) return;
      if (this.$el.naturalWidth) this.$el.removeAttribute('data-failed');
      else this.$el.dataset.failed = 'true';
    },
    init() { this.sync(); }
  }));
}

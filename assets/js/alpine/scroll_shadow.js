export function registerHeroScrollShadow(Alpine) {

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
}

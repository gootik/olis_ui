export function registerOlisDisclosure(Alpine) {
  Alpine.data("olisDisclosure", () => ({
    expanded: false,
    init() {
      this.expanded = this.$root.open;
    },
    beforeToggle(event) {
      if (this.$root.dataset.disabled === "true") {
        event.preventDefault();
        event.stopPropagation();
      }
    },
    sync() {
      const details = this.$root;
      const group = details.parentElement;
      if (
        details.open &&
        group?.matches('[data-olis-disclosure-group][data-allows-multiple-expanded="false"]')
      ) {
        for (const sibling of group.children) {
          if (sibling !== details && sibling.matches("[data-olis-disclosure]") && sibling.open) {
            sibling.open = false;
          }
        }
      }
      if (
        !details.open &&
        details.querySelector("[data-olis-disclosure-content]")?.contains(document.activeElement)
      ) {
        details.querySelector("[data-olis-disclosure-trigger]")?.focus({ preventScroll: true });
      }
      this.expanded = details.open;
    },
  }));
}

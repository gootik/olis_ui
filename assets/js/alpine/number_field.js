export function registerOlisNumberField(Alpine) {
  Alpine.data("olisNumberField", () => ({
    locked: true,
    disabled: false,
    cannotDecrease: false,
    cannotIncrease: false,
    sync() {
      const input = this.$refs.input;
      if (!input) {
        return;
      }
      this.disabled = input.matches(":disabled");
      this.locked = this.disabled || input.readOnly;
      const cannotStep = (direction) => {
        const probe = input.cloneNode();
        probe.value = input.value;
        try {
          if (direction === "up") {
            probe.stepUp();
          } else {
            probe.stepDown();
          }
          return probe.value === input.value;
        } catch (_) {
          return true;
        }
      };
      this.cannotDecrease = cannotStep("down");
      this.cannotIncrease = cannotStep("up");
    },
    step(direction) {
      const input = this.$refs.input;
      if (!input || input.matches(":disabled") || input.readOnly) {
        return;
      }
      const previous = input.value;
      if (direction === "up") {
        input.stepUp();
      } else {
        input.stepDown();
      }
      if (input.value !== previous) {
        input.dispatchEvent(new Event("input", { bubbles: true }));
      }
      this.sync();
    },
  }));
}

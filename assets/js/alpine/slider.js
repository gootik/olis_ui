export function registerOlisSlider(Alpine) {
  // Native range inputs remain the source of truth; Alpine owns pointer gestures.
  Alpine.data("olisSlider", () => ({
    drag: null,
    init() {
      this.sync();
    },
    sync(changed) {
      const slider = this.$root,
        inputs = [...slider.querySelectorAll("[data-olis-slider-input]")];
      if (!inputs.length) {
        return;
      }
      const index = inputs.indexOf(changed);
      if (index >= 0) {
        const lower = index ? Number(inputs[index - 1].value) : Number(changed.min);
        const upper =
          index < inputs.length - 1 ? Number(inputs[index + 1].value) : Number(changed.max);
        changed.value = Math.max(lower, Math.min(upper, Number(changed.value)));
      }
      const min = Number(inputs[0].min),
        max = Number(inputs[0].max);
      const values = inputs.map((input) => Number(input.value));
      const percentages = values.map((value) => ((value - min) / (max - min)) * 100);
      const start = values.length === 1 ? 0 : percentages[0],
        end = percentages.at(-1);
      const vertical = slider.dataset.orientation === "vertical";
      const track = slider.querySelector("[data-olis-slider-track]"),
        fill = slider.querySelector("[data-olis-slider-fill]");
      const rtl = getComputedStyle(slider).direction === "rtl";
      track.dataset.fillStart = String(start === 0);
      track.dataset.fillEnd = String(end === 100);
      fill.style[vertical ? "bottom" : "insetInlineStart"] = `${start}%`;
      fill.style[vertical ? "height" : "width"] = `${end - start}%`;
      slider.querySelectorAll("[data-olis-slider-thumb]").forEach((thumb, i) => {
        thumb.style[vertical ? "bottom" : "insetInlineStart"] = `${percentages[i]}%`;
        inputs[i].setAttribute("aria-valuemin", String(i ? values[i - 1] : min));
        inputs[i].setAttribute(
          "aria-valuemax",
          String(i < values.length - 1 ? values[i + 1] : max),
        );
      });
      slider
        .querySelectorAll('[data-slot="slider-steps"], [data-slot="slider-marks"]')
        .forEach((node) => {
          node.dataset.direction = rtl ? "rtl" : "ltr";
          node.dataset.orientation = slider.dataset.orientation;
        });
      slider
        .querySelectorAll('[data-slot="slider-step"], [data-slot="slider-mark"]')
        .forEach((node) => {
          const value = Number(node.dataset.value);
          node.dataset.filled = String(
            value >= (values.length === 1 ? min : values[0]) && value <= values.at(-1),
          );
        });
      slider.querySelector("[data-olis-slider-output]").textContent = inputs
        .map((input) => input.value)
        .join(" – ");
    },
    input(event) {
      const input = event.target;
      if (
        input.matches?.("[data-olis-slider-input]") &&
        input.closest("[data-olis-slider]") === this.$root
      ) {
        this.sync(input);
      }
    },
    fraction(track, event) {
      const rect = track.getBoundingClientRect(),
        style = getComputedStyle(track),
        vertical = this.$root.dataset.orientation === "vertical";
      const start = parseFloat(vertical ? style.borderBottomWidth : style.borderLeftWidth) || 0;
      const end = parseFloat(vertical ? style.borderTopWidth : style.borderRightWidth) || 0;
      let fraction = vertical
        ? (rect.bottom - start - event.clientY) / (rect.height - start - end)
        : (event.clientX - rect.left - start) / (rect.width - start - end);
      if (!vertical && style.direction === "rtl") {
        fraction = 1 - fraction;
      }
      return Math.max(0, Math.min(1, fraction));
    },
    move(event) {
      if (!this.drag || event.pointerId !== this.drag.pointerId) {
        return;
      }
      const { track, input } = this.drag,
        min = Number(input.min),
        max = Number(input.max),
        step = Number(input.step);
      const value = min + Math.round((this.fraction(track, event) * (max - min)) / step) * step;
      const decimals = (number) => {
        const [coefficient, exponent = "0"] = String(number).toLowerCase().split("e");
        return Math.max(0, (coefficient.split(".")[1]?.length || 0) - Number(exponent));
      };
      const precision = Math.min(15, Math.max(decimals(min), decimals(step)));
      const previous = input.value;
      input.value = String(Number(value.toFixed(precision)));
      if (input.value !== previous) {
        input.dispatchEvent(new Event("input", { bubbles: true }));
      }
    },
    start(event) {
      const track = event.target.closest?.("[data-olis-slider-track]");
      if (
        !track ||
        track.closest("[data-olis-slider]") !== this.$root ||
        event.button !== 0 ||
        this.drag
      ) {
        return;
      }
      const inputs = [...this.$root.querySelectorAll("[data-olis-slider-input]")].filter(
        (input) => !input.matches(":disabled"),
      );
      if (!inputs.length) {
        return;
      }
      const fraction = this.fraction(track, event),
        min = Number(inputs[0].min),
        max = Number(inputs[0].max),
        value = min + fraction * (max - min);
      const input = inputs.reduce((best, candidate) => {
        const distance = Math.abs(Number(candidate.value) - value),
          bestDistance = Math.abs(Number(best.value) - value);
        return distance < bestDistance ||
          (distance === bestDistance && value >= Number(candidate.value))
          ? candidate
          : best;
      });
      event.preventDefault();
      input.focus({ preventScroll: true });
      track.setPointerCapture(event.pointerId);
      this.drag = { track, input, pointerId: event.pointerId, initial: input.value };
      input.nextElementSibling.dataset.dragging = "true";
      this.move(event);
    },
    end(event) {
      if (!this.drag || event.pointerId !== this.drag.pointerId) {
        return;
      }
      const { input, initial } = this.drag;
      delete input.nextElementSibling.dataset.dragging;
      this.drag = null;
      if (input.value !== initial) {
        input.dispatchEvent(new Event("change", { bubbles: true }));
      }
    },
    reset(event) {
      if (
        ![...this.$root.querySelectorAll("[data-olis-slider-input]")].some(
          (input) => input.form === event.target,
        )
      ) {
        return;
      }
      setTimeout(() => {
        if (this.$root.isConnected) {
          this.sync();
        }
      }, 0);
    },
    destroy() {
      if (!this.drag) {
        return;
      }
      const { track, input, pointerId } = this.drag;
      delete input.nextElementSibling.dataset.dragging;
      if (track.hasPointerCapture(pointerId)) {
        track.releasePointerCapture(pointerId);
      }
      this.drag = null;
    },
  }));
}

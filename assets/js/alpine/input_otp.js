export function registerOlisInputOTP(Alpine) {
  // The real input owns editing, autofill, IME, and form submission.
  Alpine.data("olisInputOTP", () => ({
    previous: null,
    previousInput: null,
    init() {
      this.$nextTick(() => this.sync());
    },
    destroy() {
      delete this.$root.dataset.olisOtpReady;
      delete this.$root.dataset.disabled;
    },
    allowed(value) {
      const pattern = this.$root.dataset.allowedPattern;
      if (!pattern) {
        return true;
      }
      try {
        return new RegExp(`^(?:${pattern})$`, "v").test(value);
      } catch (_) {
        try {
          return new RegExp(`^(?:${pattern})$`, "u").test(value);
        } catch (_) {
          return true;
        }
      }
    },
    render() {
      const input = this.$refs.input;
      if (!input) {
        return;
      }
      this.$root.dataset.olisOtpReady = "true";
      const disabled = input.matches(":disabled");
      if (disabled) {
        this.$root.dataset.disabled = "true";
      } else {
        delete this.$root.dataset.disabled;
      }
      const focused = document.activeElement === input && !disabled;
      const start = input.selectionStart ?? 0,
        end = input.selectionEnd ?? start;
      const active = Math.min(start, input.maxLength - 1);
      this.$root.querySelectorAll("[data-olis-otp-index]").forEach((slot) => {
        const index = Number(slot.dataset.olisOtpIndex),
          character = input.value[index] || "";
        const value = slot.querySelector("[data-olis-otp-value]");
        const caret = slot.querySelector("[data-olis-otp-caret]");
        if (value.textContent !== character) {
          value.textContent = character;
        }
        value.hidden = !character;
        caret.hidden = !(focused && start === end && index === active && !character);
        if (character) {
          slot.dataset.filled = "true";
        } else {
          delete slot.dataset.filled;
        }
        if (focused && index === active) {
          slot.dataset.active = "true";
        } else {
          delete slot.dataset.active;
        }
        if (disabled) {
          slot.dataset.disabled = "true";
        } else {
          delete slot.dataset.disabled;
        }
        if (this.$root.dataset.invalid === "true") {
          slot.dataset.invalid = "true";
        } else {
          delete slot.dataset.invalid;
        }
      });
    },
    sync() {
      const input = this.$refs.input;
      if (!input) {
        return;
      }
      if (this.previousInput !== input || !this.previous || this.previous.value !== input.value) {
        this.previousInput = input;
        this.previous = {
          value: input.value,
          start: input.selectionStart,
          end: input.selectionEnd,
        };
      }
      this.render();
    },
    onInput(event) {
      const input = this.$refs.input;
      if (event.target !== input || event.isComposing) {
        return;
      }
      const state = this.previous;
      if (!this.allowed(input.value) && state) {
        input.value = state.value;
        input.setSelectionRange(state.start ?? input.value.length, state.end ?? input.value.length);
        event.stopImmediatePropagation();
        this.render();
        return;
      }
      const wasComplete = state?.value.length === input.maxLength;
      this.previous = { value: input.value, start: input.selectionStart, end: input.selectionEnd };
      this.render();
      if (!wasComplete && input.value.length === input.maxLength) {
        input.dispatchEvent(
          new CustomEvent("olis:otp-complete", { bubbles: true, detail: { value: input.value } }),
        );
      }
    },
    onPointerDown(event) {
      const input = this.$refs.input;
      if (
        event.target !== input ||
        input.matches(":disabled") ||
        input.readOnly ||
        event.button !== 0
      ) {
        return;
      }
      const slots = [...this.$root.querySelectorAll("[data-olis-otp-index]")];
      if (!slots.length) {
        return;
      }
      const nearest = slots.reduce(
        (best, slot) => {
          const rect = slot.getBoundingClientRect(),
            distance = Math.abs(event.clientX - (rect.left + rect.width / 2));
          return distance < best.distance ? { slot, distance } : best;
        },
        { slot: slots[0], distance: Infinity },
      ).slot;
      event.preventDefault();
      input.focus({ preventScroll: true });
      const index = Math.min(Number(nearest.dataset.olisOtpIndex), input.value.length);
      input.setSelectionRange(index, Math.min(index + 1, input.value.length));
      this.render();
    },
    onSelection() {
      const input = this.$refs.input;
      if (document.activeElement !== input) {
        return;
      }
      if (this.previous) {
        this.previous.start = input.selectionStart;
        this.previous.end = input.selectionEnd;
      }
      this.render();
    },
    onFocus() {
      queueMicrotask(() => {
        if (this.$root.isConnected) {
          this.render();
        }
      });
    },
    onReset(event) {
      if (event.target === this.$refs.input?.form) {
        setTimeout(() => {
          if (this.$root.isConnected) {
            this.sync();
          }
        }, 0);
      }
    },
  }));
}

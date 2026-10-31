/** Segmented time input with a native form control as the source of truth. */
export function olisTimeField() {
  let root;
  const states = new WeakMap();
  const fields = () => (root?.matches?.("[data-olis-time-field]") ? [root] : []);
  const parts = (field) => ({
    native: field.querySelector("[data-olis-time-native]"),
    ui: field.querySelector("[data-olis-time-ui]"),
    group: field.querySelector("[data-olis-time-group]"),
    segments: field.querySelector("[data-olis-time-segments]"),
    error: field.querySelector("[data-olis-time-error]"),
  });
  const pad = (value) => String(value).padStart(2, "0");
  const locale = (field) =>
    field.dataset.locale || field.closest("[lang]")?.lang || navigator.language || "en-US";
  function formatter(field) {
    const options = { timeZone: "UTC", numberingSystem: "latn", hour: "numeric" };
    if (field.dataset.granularity !== "hour") {
      options.minute = "2-digit";
    }
    if (field.dataset.granularity === "second") {
      options.second = "2-digit";
    }
    if (field.dataset.hourCycle) {
      options.hourCycle = field.dataset.hourCycle === "12" ? "h12" : "h23";
    }
    try {
      return new Intl.DateTimeFormat(locale(field), options);
    } catch (_) {
      return new Intl.DateTimeFormat("en-US", options);
    }
  }
  function configuration(field) {
    const fmt = formatter(field),
      hour12 = fmt.resolvedOptions().hour12;
    const sample = (hour) => fmt.formatToParts(new Date(Date.UTC(2000, 0, 1, hour, 45, 36)));
    return {
      key: [locale(field), field.dataset.hourCycle, field.dataset.granularity].join("|"),
      hour12,
      parts: sample(13),
      periods: [sample(1), sample(13)].map(
        (parts) => parts.find((p) => p.type === "dayPeriod")?.value || "",
      ),
    };
  }
  function parse(value, config, granularity) {
    const match = /^(\d{2}):(\d{2})(?::(\d{2})(?:\.\d+)?)?$/.exec(value || "");
    if (!match) {
      return { hour: null, minute: null, second: null, dayPeriod: null };
    }
    const hour = Number(match[1]);
    return {
      hour: config.hour12 ? hour % 12 || 12 : hour,
      minute: granularity === "hour" ? null : Number(match[2]),
      second: granularity === "second" ? Number(match[3] || 0) : null,
      dayPeriod: config.hour12 ? (hour >= 12 ? 1 : 0) : null,
    };
  }
  function fieldValue(state, field) {
    const v = state.values,
      granularity = field.dataset.granularity;
    if (
      v.hour == null ||
      (granularity !== "hour" && v.minute == null) ||
      (granularity === "second" && v.second == null)
    ) {
      return "";
    }
    const hour = state.config.hour12 ? (v.hour % 12) + (v.dayPeriod === 1 ? 12 : 0) : v.hour;
    return `${pad(hour)}:${pad(granularity === "hour" ? 0 : v.minute)}${granularity === "second" ? `:${pad(v.second)}` : ""}`;
  }
  function paint(field) {
    const { native, group, segments, error } = parts(field),
      state = states.get(field);
    const disabled = native.matches(":disabled"),
      invalid = native.getAttribute("aria-invalid") === "true" || !error.hidden;
    if (disabled) {
      group.dataset.disabled = "true";
    } else {
      delete group.dataset.disabled;
    }
    if (invalid) {
      group.dataset.invalid = "true";
    } else {
      delete group.dataset.invalid;
    }
    group.classList.toggle("date-input-group--secondary", field.dataset.variant === "secondary");
    group.classList.toggle("date-input-group--primary", field.dataset.variant !== "secondary");
    group.classList.toggle(
      "date-input-group--full-width",
      field.classList.contains("time-field--full-width"),
    );
    const described = [native.getAttribute("aria-describedby"), !error.hidden && error.id]
      .filter(Boolean)
      .join(" ");
    if (described) {
      group.setAttribute("aria-describedby", described);
    } else {
      group.removeAttribute("aria-describedby");
    }
    for (const segment of segments.querySelectorAll("[data-olis-time-segment]")) {
      const type = segment.dataset.olisTimeSegment,
        value = state.values[type],
        min = type === "hour" && state.config.hour12 ? 1 : 0,
        max = type === "hour" ? (state.config.hour12 ? 12 : 23) : type === "dayPeriod" ? 1 : 59;
      segment.textContent =
        type === "dayPeriod"
          ? state.config.periods[value ?? 0] || "AM"
          : value == null
            ? "––"
            : type === "hour" && !state.leadingZero
              ? String(value)
              : pad(value);
      segment.setAttribute("aria-valuemin", String(min));
      segment.setAttribute("aria-valuemax", String(max));
      if (value == null) {
        segment.dataset.placeholder = "true";
        segment.removeAttribute("aria-valuenow");
        segment.setAttribute("aria-valuetext", "Empty");
      } else {
        delete segment.dataset.placeholder;
        segment.setAttribute("aria-valuenow", String(value));
        segment.setAttribute("aria-valuetext", segment.textContent);
      }
      if (disabled) {
        segment.dataset.disabled = "true";
        segment.setAttribute("aria-disabled", "true");
        segment.tabIndex = -1;
        segment.removeAttribute("contenteditable");
      } else {
        delete segment.dataset.disabled;
        segment.removeAttribute("aria-disabled");
        segment.tabIndex = 0;
        segment.setAttribute("contenteditable", native.readOnly ? "false" : "true");
      }
      if (native.readOnly) {
        segment.setAttribute("aria-readonly", "true");
      } else {
        segment.removeAttribute("aria-readonly");
      }
      if (invalid) {
        segment.dataset.invalid = "true";
        segment.setAttribute("aria-invalid", "true");
      } else {
        delete segment.dataset.invalid;
        segment.removeAttribute("aria-invalid");
      }
    }
  }
  function build(field) {
    const { native, segments } = parts(field),
      state = states.get(field),
      focused = document.activeElement?.dataset.olisTimeSegment;
    segments.replaceChildren();
    for (const part of state.config.parts) {
      const span = document.createElement("span");
      span.className = "date-input-group__segment caret-transparent";
      span.dataset.slot = "date-input-group-segment";
      if (["hour", "minute", "second", "dayPeriod"].includes(part.type)) {
        span.dataset.type = part.type;
        span.dataset.olisTimeSegment = part.type;
        span.setAttribute("role", "spinbutton");
        span.id = `${native.id}-${part.type}`;
        span.setAttribute("aria-label", part.type === "dayPeriod" ? "AM/PM" : part.type);
        span.setAttribute("aria-labelledby", `${span.id} ${native.id}-label`);
        if (part.type !== "dayPeriod") {
          span.setAttribute("inputmode", "numeric");
        }
        span.setAttribute("enterkeyhint", "next");
        span.setAttribute("spellcheck", "false");
        span.setAttribute("autocorrect", "off");
      } else {
        span.dataset.type = "literal";
        span.setAttribute("aria-hidden", "true");
        span.textContent = part.value;
      }
      segments.appendChild(span);
    }
    state.leadingZero = state.config.parts.find((part) => part.type === "hour")?.value.length > 1;
    paint(field);
    if (focused) {
      segments
        .querySelector(`[data-olis-time-segment="${focused}"]`)
        ?.focus({ preventScroll: true });
    }
  }
  function setValidity(field) {
    const { native } = parts(field),
      state = states.get(field),
      v = state.values;
    const partial =
      [v.hour, v.minute, v.second].some((value) => value != null) && !fieldValue(state, field);
    if (partial && (!native.validity.customError || state.managedError)) {
      native.setCustomValidity("Enter a complete time.");
      state.managedError = true;
    } else if (!partial && state.managedError) {
      native.setCustomValidity("");
      state.managedError = false;
    }
  }
  function commit(field) {
    const { native, error } = parts(field),
      state = states.get(field);
    if (state.config.hour12 && state.values.hour != null && state.values.dayPeriod == null) {
      state.values.dayPeriod = 0;
    }
    const value = fieldValue(state, field),
      changed = native.value !== value;
    native.value = value;
    state.lastValue = native.value;
    error.hidden = true;
    error.textContent = "";
    setValidity(field);
    paint(field);
    if (changed) {
      native.dispatchEvent(new Event("input", { bubbles: true }));
      native.dispatchEvent(new Event("change", { bubbles: true }));
    }
  }
  function sync(field) {
    const { native, ui, group, segments, error } = parts(field);
    if (!native || !ui || !group || !segments || !error) {
      return;
    }
    const hadFocus = document.activeElement === native,
      config = configuration(field);
    let state = states.get(field);
    if (!state) {
      state = {
        config,
        values: parse(native.value, config, field.dataset.granularity),
        lastValue: native.value,
        buffer: "",
        bufferType: null,
        bufferTime: 0,
        managedError: false,
      };
      states.set(field, state);
      build(field);
    } else if (state.config.key !== config.key) {
      state.config = config;
      state.values = parse(native.value, config, field.dataset.granularity);
      state.lastValue = native.value;
      state.buffer = "";
      build(field);
    } else if (state.lastValue !== native.value) {
      state.values = parse(native.value, config, field.dataset.granularity);
      state.lastValue = native.value;
      state.buffer = "";
      error.hidden = true;
      error.textContent = "";
    }
    field.dataset.enhanced = "true";
    native.setAttribute("aria-hidden", "true");
    native.tabIndex = -1;
    ui.hidden = false;
    setValidity(field);
    paint(field);
    if (hadFocus) {
      segments
        .querySelector("[data-olis-time-segment]:not([aria-disabled])")
        ?.focus({ preventScroll: true });
    }
  }
  function next(segment, direction) {
    const all = [...segment.parentElement.querySelectorAll("[data-olis-time-segment]")];
    all[all.indexOf(segment) + direction]?.focus();
  }
  function digit(field, segment, key) {
    const state = states.get(field),
      type = segment.dataset.olisTimeSegment,
      max = type === "hour" ? (state.config.hour12 ? 12 : 23) : 59,
      now = Date.now();
    let buffer =
      state.bufferType === type && now - state.bufferTime < 1500 ? state.buffer + key : key;
    if (Number(buffer) > max || buffer.length > 2) {
      buffer = key;
    }
    state.buffer = buffer;
    state.bufferType = type;
    state.bufferTime = now;
    const number = Number(buffer);
    state.values[type] = type === "hour" && state.config.hour12 && number === 0 ? null : number;
    commit(field);
    if (buffer.length === 2 || number > Math.floor(max / 10)) {
      state.buffer = "";
      next(segment, 1);
    }
  }
  function onKeyDown(event) {
    const segment = event.target.closest?.("[data-olis-time-segment]");
    if (!segment || !root.contains(segment)) {
      return;
    }
    const field = segment.closest("[data-olis-time-field]"),
      { native } = parts(field),
      state = states.get(field),
      type = segment.dataset.olisTimeSegment;
    if (native.matches(":disabled")) {
      return;
    }
    if (event.key === "ArrowLeft" || event.key === "ArrowRight") {
      event.preventDefault();
      state.buffer = "";
      next(segment, event.key === "ArrowLeft" ? -1 : 1);
      return;
    }
    if (native.readOnly) {
      return;
    }
    if (type === "dayPeriod" && /^[ap]$/i.test(event.key)) {
      event.preventDefault();
      state.values.dayPeriod = event.key.toLowerCase() === "p" ? 1 : 0;
      commit(field);
    } else if (
      type !== "dayPeriod" &&
      /^\d$/.test(event.key) &&
      !event.ctrlKey &&
      !event.metaKey &&
      !event.altKey
    ) {
      event.preventDefault();
      digit(field, segment, event.key);
    } else if (event.key === "Backspace" || event.key === "Delete") {
      event.preventDefault();
      state.buffer = "";
      state.values[type] = null;
      commit(field);
    } else if (["ArrowUp", "ArrowDown", "Home", "End"].includes(event.key)) {
      event.preventDefault();
      state.buffer = "";
      const min = type === "hour" && state.config.hour12 ? 1 : 0,
        max = type === "hour" ? (state.config.hour12 ? 12 : 23) : type === "dayPeriod" ? 1 : 59,
        current = state.values[type];
      state.values[type] =
        event.key === "Home"
          ? min
          : event.key === "End"
            ? max
            : current == null
              ? event.key === "ArrowUp"
                ? min
                : max
              : event.key === "ArrowUp"
                ? current === max
                  ? min
                  : current + 1
                : current === min
                  ? max
                  : current - 1;
      commit(field);
    }
  }
  function onBeforeInput(event) {
    const segment = event.target.closest?.("[data-olis-time-segment]");
    if (!segment || !root.contains(segment)) {
      return;
    }
    const field = segment.closest("[data-olis-time-field]"),
      { native } = parts(field),
      type = segment.dataset.olisTimeSegment;
    if (native.readOnly || native.matches(":disabled")) {
      event.preventDefault();
      return;
    }
    if (
      event.inputType === "insertText" &&
      /^[ap]$/i.test(event.data || "") &&
      type === "dayPeriod"
    ) {
      event.preventDefault();
      states.get(field).values.dayPeriod = event.data.toLowerCase() === "p" ? 1 : 0;
      commit(field);
    } else if (
      event.inputType === "insertText" &&
      /^\d$/.test(event.data || "") &&
      type !== "dayPeriod"
    ) {
      event.preventDefault();
      digit(field, segment, event.data);
    } else if (event.inputType?.startsWith("delete")) {
      event.preventDefault();
      states.get(field).values[type] = null;
      commit(field);
    } else {
      event.preventDefault();
    }
  }
  function onPaste(event) {
    const segment = event.target.closest?.("[data-olis-time-segment]");
    if (!segment || !root.contains(segment)) {
      return;
    }
    const field = segment.closest("[data-olis-time-field]"),
      { native } = parts(field),
      state = states.get(field);
    if (native.readOnly || native.matches(":disabled")) {
      return;
    }
    event.preventDefault();
    const text = event.clipboardData?.getData("text")?.trim();
    if (/^(?:[01]\d|2[0-3]):[0-5]\d(?::[0-5]\d)?$/.test(text || "")) {
      state.values = parse(text, state.config, field.dataset.granularity);
      state.buffer = "";
      commit(field);
    }
  }
  function onFocus(event) {
    const segment = event.target.closest?.("[data-olis-time-segment]");
    if (segment && root.contains(segment)) {
      const state = states.get(segment.closest("[data-olis-time-field]"));
      state.buffer = "";
      state.bufferType = null;
    }
  }
  function onClick(event) {
    const label = event.target.closest?.("label"),
      native = label?.control,
      field = native?.closest("[data-olis-time-field]");
    if (field?.dataset.enhanced === "true" && !native.matches(":disabled")) {
      event.preventDefault();
      parts(field).segments.querySelector("[data-olis-time-segment]")?.focus();
    }
  }
  function onInvalid(event) {
    const native = event.target;
    if (!native.matches?.("[data-olis-time-native]")) {
      return;
    }
    const field = native.closest("[data-olis-time-field]");
    if (field.dataset.enhanced !== "true") {
      return;
    }
    event.preventDefault();
    const { error, segments } = parts(field);
    error.textContent = native.validationMessage;
    error.hidden = false;
    paint(field);
    segments.querySelector("[data-olis-time-segment]:not([aria-disabled])")?.focus();
  }
  function onChange(event) {
    if (event.target.matches?.("[data-olis-time-native]")) {
      sync(event.target.closest("[data-olis-time-field]"));
    }
  }
  function syncAll() {
    fields().forEach(sync);
  }
  function onReset(event) {
    if (!root || parts(root).native?.form !== event.target) {
      return;
    }
    setTimeout(() => {
      if (!root.isConnected) {
        return;
      }
      const { native, error } = parts(root),
        state = states.get(root);
      if (!state) {
        return;
      }
      state.values = parse(native.value, state.config, root.dataset.granularity);
      state.lastValue = native.value;
      state.buffer = "";
      error.hidden = true;
      error.textContent = "";
      sync(root);
    }, 0);
  }
  return {
    init() {
      root = this.$root;
      sync(root);
    },
    keydown(event) {
      onKeyDown(event);
    },
    beforeinput(event) {
      onBeforeInput(event);
    },
    paste(event) {
      onPaste(event);
    },
    focusin(event) {
      onFocus(event);
    },
    click(event) {
      onClick(event);
    },
    invalid(event) {
      onInvalid(event);
    },
    change(event) {
      onChange(event);
    },
    reset(event) {
      onReset(event);
    },
    update() {
      syncAll();
    },
    destroy() {
      if (!root) {
        return;
      }
      const { native, ui } = parts(root),
        state = states.get(root);
      if (state?.managedError) {
        native.setCustomValidity("");
      }
      native.removeAttribute("aria-hidden");
      native.removeAttribute("tabindex");
      ui.hidden = true;
      delete root.dataset.enhanced;
    },
  };
}

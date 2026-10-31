/** Connect a segmented date field to its calendar popover. */
export function installDatePicker(root = document) {
  const pickers = () => root.querySelectorAll("[data-olis-date-picker]");
  const parts = (picker) => ({
    native: picker.querySelector("[data-olis-date-native]"),
    calendar: picker.querySelector("[data-olis-calendar]"),
    trigger: picker.querySelector("[data-olis-date-picker-trigger]"),
    popover: picker.querySelector("[data-olis-date-picker-popover]"),
  });
  function syncCalendar(picker) {
    const { native, calendar, trigger, popover } = parts(picker),
      input = calendar?.querySelector("[data-olis-calendar-native]");
    if (!native || !calendar || !trigger || !popover || !input) {
      return;
    }
    trigger.disabled = native.matches(":disabled");
    if (trigger.disabled && popover.matches(":popover-open")) {
      popover.hidePopover();
    }
    if (input.value !== native.value) {
      input.value = native.value;
      input.dispatchEvent(new Event("change", { bubbles: true }));
    }
  }
  function position(picker) {
    const { trigger, popover } = parts(picker);
    if (!popover?.matches(":popover-open")) {
      return;
    }
    const anchor = trigger.closest("[data-olis-date-group]").getBoundingClientRect(),
      box = popover.getBoundingClientRect(),
      margin = 8,
      gap = 8;
    const below = innerHeight - anchor.bottom - margin,
      above = anchor.top - margin;
    const top =
      below >= box.height + gap || below >= above
        ? anchor.bottom + gap
        : anchor.top - box.height - gap;
    const left = Math.max(margin, Math.min(anchor.left, innerWidth - box.width - margin));
    popover.style.left = `${left}px`;
    popover.style.top = `${Math.max(margin, top)}px`;
    popover.style.maxHeight = `${Math.max(0, innerHeight - margin * 2)}px`;
    popover.dataset.placement = top >= anchor.bottom ? "bottom" : "top";
  }
  function onClick(event) {
    const trigger = event.target.closest?.("[data-olis-date-picker-trigger]"),
      picker = trigger?.closest("[data-olis-date-picker]");
    if (!picker || !root.contains(picker) || trigger.disabled) {
      return;
    }
    const { popover } = parts(picker);
    if (popover.matches(":popover-open")) {
      popover.hidePopover();
    } else {
      syncCalendar(picker);
      popover.showPopover();
      position(picker);
    }
  }
  function onCalendarClick(event) {
    const day = event.target.closest?.("[data-olis-calendar-date]"),
      picker = day?.closest("[data-olis-date-picker]");
    if (!picker || !root.contains(picker)) {
      return;
    }
    const { native, trigger, popover } = parts(picker);
    if (
      day.disabled ||
      day.getAttribute("aria-disabled") === "true" ||
      native.readOnly ||
      native.matches(":disabled")
    ) {
      return;
    }
    queueMicrotask(() => {
      if (popover.matches(":popover-open")) {
        popover.hidePopover();
      }
      if (!trigger.disabled) {
        trigger.focus({ preventScroll: true });
      }
    });
  }
  function onInput(event) {
    const target = event.target,
      picker = target.closest?.("[data-olis-date-picker]");
    if (!picker || !root.contains(picker)) {
      return;
    }
    const { native, calendar } = parts(picker),
      calendarInput = calendar.querySelector("[data-olis-calendar-native]");
    if (target === calendarInput) {
      if (native.value !== calendarInput.value) {
        native.value = calendarInput.value;
        native.dispatchEvent(new Event("input", { bubbles: true }));
        native.dispatchEvent(new Event("change", { bubbles: true }));
      }
    } else if (target === native) {
      syncCalendar(picker);
    }
  }
  function onToggle(event) {
    const popover = event.target;
    if (!popover.matches?.("[data-olis-date-picker-popover]")) {
      return;
    }
    const picker = popover.closest("[data-olis-date-picker]"),
      { native, calendar, trigger } = parts(picker),
      open = popover.matches(":popover-open");
    trigger.setAttribute("aria-expanded", String(open));
    if (open) {
      trigger.dataset.open = "true";
      position(picker);
      calendar.dispatchEvent(
        new CustomEvent("olis-calendar-focus", {
          bubbles: true,
          detail: { value: native.value, focus: true },
        }),
      );
    } else {
      delete trigger.dataset.open;
    }
  }
  function onKeyDown(event) {
    const popover = event.target.closest?.("[data-olis-date-picker-popover]");
    if (!popover || !root.contains(popover) || event.defaultPrevented) {
      return;
    }
    const { trigger } = parts(popover.closest("[data-olis-date-picker]"));
    if (event.key === "Escape") {
      event.preventDefault();
      popover.hidePopover();
      trigger.focus({ preventScroll: true });
    } else if (event.key === "Tab") {
      const targets = [...popover.querySelectorAll('button:not(:disabled), [tabindex="0"]')].filter(
        (el) =>
          el.tabIndex >= 0 &&
          el.getClientRects().length &&
          !el.closest("[inert]") &&
          el.getAttribute("aria-hidden") !== "true",
      );
      if (!targets.length) {
        event.preventDefault();
        popover.focus();
        return;
      }
      const first = targets[0],
        last = targets[targets.length - 1];
      if (
        event.shiftKey &&
        (document.activeElement === first || document.activeElement === popover)
      ) {
        event.preventDefault();
        last.focus();
      } else if (!event.shiftKey && document.activeElement === last) {
        event.preventDefault();
        first.focus();
      }
    }
  }
  function syncAll() {
    pickers().forEach(syncCalendar);
  }
  function reposition() {
    pickers().forEach(position);
  }
  syncAll();
  root.addEventListener("click", onCalendarClick, true);
  root.addEventListener("click", onClick);
  root.addEventListener("input", onInput);
  root.addEventListener("change", onInput);
  root.addEventListener("toggle", onToggle, true);
  root.addEventListener("keydown", onKeyDown);
  document.addEventListener("phx:update", syncAll);
  window.addEventListener("resize", reposition);
  window.addEventListener("scroll", reposition, true);
  return () => {
    root.removeEventListener("click", onCalendarClick, true);
    root.removeEventListener("click", onClick);
    root.removeEventListener("input", onInput);
    root.removeEventListener("change", onInput);
    root.removeEventListener("toggle", onToggle, true);
    root.removeEventListener("keydown", onKeyDown);
    document.removeEventListener("phx:update", syncAll);
    window.removeEventListener("resize", reposition);
    window.removeEventListener("scroll", reposition, true);
    pickers().forEach((picker) => {
      const { popover, trigger } = parts(picker);
      if (popover.matches(":popover-open")) {
        popover.hidePopover();
      }
      trigger.setAttribute("aria-expanded", "false");
      delete trigger.dataset.open;
    });
  };
}

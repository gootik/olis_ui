/** Searchable select enhancement. The native select remains the form control. */
export function olisAutocomplete() {
  let root;
  const supported = typeof HTMLElement.prototype.showPopover === "function";
  const states = new WeakMap(),
    pointerOpen = new WeakMap();
  const fields = () => (root?.matches?.("[data-olis-autocomplete]") ? [root] : []);
  const parts = (field) => ({
    native: field.querySelector("[data-olis-autocomplete-native]"),
    ui: field.querySelector("[data-olis-autocomplete-ui]"),
    group: field.querySelector("[data-olis-autocomplete-group]"),
    trigger: field.querySelector("[data-olis-autocomplete-trigger]"),
    value: field.querySelector("[data-olis-autocomplete-value]"),
    clear: field.querySelector("[data-olis-autocomplete-clear]"),
    popup: field.querySelector("[data-olis-autocomplete-popup]"),
    search: field.querySelector("[data-olis-autocomplete-search]"),
    list: field.querySelector("[data-olis-autocomplete-list]"),
    empty: field.querySelector("[data-olis-autocomplete-empty]"),
    error: field.querySelector("[data-olis-autocomplete-error]"),
  });
  const selected = (native) =>
    [...native.selectedOptions].filter((option) => native.multiple || option.value !== "");
  const selectable = (list) =>
    [...list.querySelectorAll('[role="option"]')].filter(
      (option) => option.getAttribute("aria-disabled") !== "true",
    );
  const normalize = (value) =>
    value
      .normalize("NFD")
      .replace(/[\u0300-\u036f]/g, "")
      .toLocaleLowerCase();
  function formatLabels(labels) {
    try {
      return new Intl.ListFormat(document.documentElement.lang || undefined, {
        style: "long",
        type: "conjunction",
      }).format(labels);
    } catch (_) {
      return labels.join(", ");
    }
  }
  function active(field, item, scroll = false) {
    const { search, list } = parts(field);
    list.querySelectorAll('[role="option"]').forEach((option) => {
      if (option === item) {
        option.dataset.active = "true";
      } else {
        delete option.dataset.active;
      }
    });
    if (item) {
      search.setAttribute("aria-activedescendant", item.id);
    } else {
      search.removeAttribute("aria-activedescendant");
    }
    if (item && scroll) {
      item.scrollIntoView({ block: "nearest" });
    }
  }
  function render(field) {
    const { native, popup, search, list, empty } = parts(field),
      state = states.get(field),
      previous = list.querySelector('[data-active="true"]')?.dataset.index;
    const searchField = search.closest("[data-olis-autocomplete-search-field]"),
      searchClear = field.querySelector("[data-olis-autocomplete-search-clear]");
    searchField.dataset.empty = String(search.value.length === 0);
    searchClear.tabIndex = search.value.length ? 0 : -1;
    searchClear.setAttribute("aria-hidden", String(search.value.length === 0));
    const query = normalize(search.value.trim());
    list.replaceChildren();
    function append(option, parent) {
      if (
        (!native.multiple && option.index === 0) ||
        option.hidden ||
        !normalize(option.textContent.trim()).includes(query)
      ) {
        return false;
      }
      const item = document.createElement("div");
      item.id = `${native.id}-autocomplete-option-${option.index}`;
      item.className = "list-box-item list-box-item--default data-[active=true]:bg-default";
      item.dataset.slot = "list-box-item";
      item.dataset.olisAutocompleteOption = "";
      item.dataset.index = String(option.index);
      item.setAttribute("role", "option");
      item.setAttribute("aria-selected", String(option.selected));
      if (
        option.disabled ||
        (option.parentElement.tagName === "OPTGROUP" && option.parentElement.disabled)
      ) {
        item.dataset.disabled = "true";
        item.setAttribute("aria-disabled", "true");
      }
      const label = document.createElement("span");
      label.dataset.slot = "label";
      label.textContent = option.textContent.trim();
      item.appendChild(label);
      const indicator = document.createElement("span");
      indicator.className = "list-box-item__indicator";
      indicator.dataset.slot = "list-box-item-indicator";
      indicator.setAttribute("aria-hidden", "true");
      indicator.hidden = !option.selected;
      const svg = document.createElementNS("http://www.w3.org/2000/svg", "svg");
      svg.setAttribute("viewBox", "0 0 16 16");
      svg.setAttribute("fill", "none");
      svg.dataset.slot = "list-box-item-indicator--checkmark";
      const path = document.createElementNS("http://www.w3.org/2000/svg", "path");
      path.setAttribute("d", "M3.5 8l3 3 6-6");
      path.setAttribute("stroke", "currentColor");
      path.setAttribute("stroke-width", "2");
      path.setAttribute("stroke-linecap", "round");
      path.setAttribute("stroke-linejoin", "round");
      svg.appendChild(path);
      indicator.appendChild(svg);
      item.appendChild(indicator);
      parent.appendChild(item);
      return true;
    }
    for (const child of native.children) {
      if (child.tagName === "OPTION") {
        append(child, list);
      } else if (child.tagName === "OPTGROUP" && !child.hidden) {
        const group = document.createElement("div");
        group.className = "list-box-section";
        group.setAttribute("role", "group");
        group.setAttribute("aria-label", child.label);
        const header = document.createElement("div");
        header.className = "header";
        header.setAttribute("aria-hidden", "true");
        header.textContent = child.label;
        group.appendChild(header);
        let count = 0;
        for (const option of child.children) {
          if (append(option, group)) {
            count++;
          }
        }
        if (count) {
          list.appendChild(group);
        }
      }
    }
    empty.hidden = list.querySelector('[role="option"]') !== null;
    if (popup.matches(":popover-open")) {
      const enabled = selectable(list),
        item =
          enabled.find((option) => option.dataset.index === previous) ||
          enabled.find((option) => option.getAttribute("aria-selected") === "true") ||
          enabled[0];
      active(field, item);
    } else {
      search.removeAttribute("aria-activedescendant");
    }
    state.optionCount = native.options.length - (native.multiple ? 0 : 1);
  }
  function sync(field) {
    const { native, ui, group, trigger, value, clear, popup, search, list, empty, error } =
      parts(field);
    if (
      !native ||
      !ui ||
      !group ||
      !trigger ||
      !value ||
      !clear ||
      !popup ||
      !search ||
      !list ||
      !empty ||
      !error
    ) {
      return;
    }
    if (!states.has(field)) {
      states.set(field, {});
    }
    const state = states.get(field),
      selection = JSON.stringify(selected(native).map((option) => option.value));
    if (state.selection != null && state.selection !== selection) {
      error.hidden = true;
      error.textContent = "";
    }
    state.selection = selection;
    field.dataset.enhanced = "true";
    native.setAttribute("aria-hidden", "true");
    native.tabIndex = -1;
    ui.hidden = false;
    const disabled = native.matches(":disabled"),
      options = selected(native),
      labels = options.map((option) => option.textContent.trim());
    value.textContent = labels.length ? formatLabels(labels) : field.dataset.placeholder || "";
    if (labels.length) {
      delete value.dataset.placeholder;
    } else {
      value.dataset.placeholder = "true";
    }
    group.classList.toggle("autocomplete__trigger--full-width", field.dataset.fullWidth === "true");
    if (disabled) {
      group.dataset.disabled = "true";
    } else {
      delete group.dataset.disabled;
    }
    trigger.disabled = disabled;
    clear.disabled = disabled;
    clear.hidden = field.dataset.clearable !== "true";
    clear.dataset.empty = String(labels.length === 0);
    clear.setAttribute("aria-hidden", String(labels.length === 0));
    clear.tabIndex = labels.length && !disabled ? 0 : -1;
    search.disabled = disabled;
    search.placeholder = field.dataset.searchPlaceholder || "";
    empty.textContent = field.dataset.emptyMessage || "";
    clear.setAttribute(
      "aria-label",
      `Clear ${field.querySelector("label")?.textContent.trim() || "selection"}`,
    );
    search.setAttribute(
      "aria-label",
      `Search ${field.querySelector("label")?.textContent.trim() || "options"}`,
    );
    if (disabled && popup.matches(":popover-open")) {
      popup.hidePopover();
    }
    search.setAttribute("aria-required", String(native.required));
    const invalid = native.getAttribute("aria-invalid") === "true" || !error.hidden;
    if (invalid) {
      trigger.setAttribute("aria-invalid", "true");
      field.dataset.invalid = "true";
    } else {
      trigger.removeAttribute("aria-invalid");
      delete field.dataset.invalid;
    }
    const described = [
      native.required && `${native.id}-required-hint`,
      native.getAttribute("aria-describedby"),
      !error.hidden && error.id,
    ]
      .filter(Boolean)
      .join(" ");
    if (described) {
      trigger.setAttribute("aria-describedby", described);
    } else {
      trigger.removeAttribute("aria-describedby");
    }
    if (native.multiple) {
      list.setAttribute("aria-multiselectable", "true");
    } else {
      list.removeAttribute("aria-multiselectable");
    }
    render(field);
  }
  function position(field) {
    const { group, popup } = parts(field);
    if (!popup.matches(":popover-open")) {
      return;
    }
    const anchor = group.getBoundingClientRect(),
      margin = 8,
      width = Math.min(anchor.width, innerWidth - margin * 2);
    popup.style.setProperty("--trigger-width", `${width}px`);
    popup.style.maxHeight = `${Math.max(0, innerHeight - margin * 2)}px`;
    const box = popup.getBoundingClientRect();
    popup.style.left = `${Math.max(margin, Math.min(anchor.left, innerWidth - box.width - margin))}px`;
    const below = anchor.bottom + 4,
      above = anchor.top - box.height - 4;
    popup.style.top = `${below + box.height <= innerHeight - margin ? below : Math.max(margin, above)}px`;
  }
  function open(field) {
    const { trigger, popup, search } = parts(field),
      state = states.get(field);
    if (trigger.disabled || (!state.optionCount && field.dataset.allowsEmpty !== "true")) {
      return;
    }
    search.value = "";
    render(field);
    if (!popup.matches(":popover-open")) {
      popup.showPopover();
    }
    render(field);
    position(field);
    search.focus({ preventScroll: true });
  }
  function choose(field, item) {
    if (!item || item.getAttribute("aria-disabled") === "true") {
      return;
    }
    const { native, popup, search, trigger, error } = parts(field),
      option = native.options[Number(item.dataset.index)];
    if (!option) {
      return;
    }
    const changed = native.multiple || native.selectedIndex !== option.index;
    if (native.multiple) {
      option.selected = !option.selected;
    } else {
      native.selectedIndex = option.index;
    }
    error.hidden = true;
    error.textContent = "";
    sync(field);
    if (native.multiple) {
      search.focus({ preventScroll: true });
    } else {
      if (popup.matches(":popover-open")) {
        popup.hidePopover();
      }
      trigger.focus({ preventScroll: true });
    }
    if (changed) {
      native.dispatchEvent(new Event("change", { bubbles: true }));
    }
  }
  function onInput(event) {
    if (!event.target.matches?.("[data-olis-autocomplete-search]")) {
      return;
    }
    event.stopPropagation();
    const field = event.target.closest("[data-olis-autocomplete]");
    render(field);
    position(field);
  }
  function onChange(event) {
    if (event.target.matches?.("[data-olis-autocomplete-search]")) {
      event.stopPropagation();
      return;
    }
    if (event.target.matches?.("[data-olis-autocomplete-native]")) {
      sync(event.target.closest("[data-olis-autocomplete]"));
    }
  }
  function onKeyDown(event) {
    const search = event.target;
    if (
      search.matches?.("[data-olis-autocomplete-trigger]") &&
      ["ArrowDown", "ArrowUp"].includes(event.key)
    ) {
      event.preventDefault();
      const field = search.closest("[data-olis-autocomplete]");
      if (!search.disabled) {
        open(field);
      }
      return;
    }
    if (!search.matches?.("[data-olis-autocomplete-search]")) {
      return;
    }
    const field = search.closest("[data-olis-autocomplete]"),
      { popup, list, trigger } = parts(field);
    if (!popup.matches(":popover-open")) {
      return;
    }
    if (
      event.key === "ArrowDown" ||
      event.key === "ArrowUp" ||
      event.key === "Home" ||
      event.key === "End"
    ) {
      event.preventDefault();
      const options = selectable(list),
        index = options.findIndex(
          (item) => item.id === search.getAttribute("aria-activedescendant"),
        );
      const next =
        event.key === "Home"
          ? 0
          : event.key === "End"
            ? options.length - 1
            : Math.max(
                0,
                Math.min(options.length - 1, index + (event.key === "ArrowDown" ? 1 : -1)),
              );
      active(field, options[next], true);
    } else if (event.key === "Enter") {
      const item = document.getElementById(search.getAttribute("aria-activedescendant"));
      if (item) {
        event.preventDefault();
        choose(field, item);
      } else {
        event.preventDefault();
      }
    } else if (event.key === "Escape") {
      event.preventDefault();
      popup.hidePopover();
      trigger.focus({ preventScroll: true });
    } else if (event.key === "Tab") {
      popup.hidePopover();
    }
  }
  function onPointerDown(event) {
    const trigger = event.target.closest?.("[data-olis-autocomplete-trigger]");
    if (trigger) {
      const field = trigger.closest("[data-olis-autocomplete]");
      pointerOpen.set(field, parts(field).popup.matches(":popover-open"));
    }
    if (event.target.closest?.("[data-olis-autocomplete-option]")) {
      event.preventDefault();
    }
  }
  function onClick(event) {
    const option = event.target.closest?.("[data-olis-autocomplete-option]");
    if (option && root.contains(option)) {
      choose(option.closest("[data-olis-autocomplete]"), option);
      return;
    }
    const searchClear = event.target.closest?.("[data-olis-autocomplete-search-clear]");
    if (searchClear && root.contains(searchClear)) {
      const field = searchClear.closest("[data-olis-autocomplete]"),
        { search } = parts(field);
      search.value = "";
      render(field);
      position(field);
      search.focus({ preventScroll: true });
      return;
    }
    const clear = event.target.closest?.("[data-olis-autocomplete-clear]");
    if (clear && root.contains(clear) && !clear.disabled) {
      const field = clear.closest("[data-olis-autocomplete]"),
        { native, trigger, popup, error } = parts(field),
        changed = selected(native).length > 0;
      if (native.multiple) {
        for (const option of native.options) {
          option.selected = false;
        }
      } else {
        native.selectedIndex = 0;
      }
      error.hidden = true;
      error.textContent = "";
      if (popup.matches(":popover-open")) {
        popup.hidePopover();
      }
      sync(field);
      trigger.focus({ preventScroll: true });
      if (changed) {
        native.dispatchEvent(new Event("change", { bubbles: true }));
      }
      return;
    }
    const trigger = event.target.closest?.("[data-olis-autocomplete-trigger]");
    if (trigger && root.contains(trigger) && !trigger.disabled) {
      const field = trigger.closest("[data-olis-autocomplete]"),
        { popup } = parts(field),
        wasOpen = pointerOpen.has(field) ? pointerOpen.get(field) : popup.matches(":popover-open");
      pointerOpen.delete(field);
      if (wasOpen) {
        if (popup.matches(":popover-open")) {
          popup.hidePopover();
        }
      } else {
        open(field);
      }
      return;
    }
    const label = event.target.closest?.("label"),
      native = label?.control,
      field = native?.closest("[data-olis-autocomplete]");
    if (field?.dataset.enhanced === "true" && !native.matches(":disabled")) {
      event.preventDefault();
      parts(field).trigger.focus();
    }
  }
  function onFocusOut(event) {
    const field = event.target.closest?.("[data-olis-autocomplete]");
    if (!field || field.contains(event.relatedTarget)) {
      return;
    }
    const { popup } = parts(field);
    if (popup.matches(":popover-open")) {
      popup.hidePopover();
    }
  }
  function onToggle(event) {
    const popup = event.target;
    if (!popup.matches?.("[data-olis-autocomplete-popup]") || !root.contains(popup)) {
      return;
    }
    const field = popup.closest("[data-olis-autocomplete]"),
      { trigger, search } = parts(field),
      isOpen = popup.matches(":popover-open");
    trigger.setAttribute("aria-expanded", String(isOpen));
    search.setAttribute("aria-expanded", String(isOpen));
    const indicator = trigger.querySelector(".autocomplete__indicator");
    if (isOpen) {
      indicator.dataset.open = "true";
      render(field);
      position(field);
    } else {
      delete indicator.dataset.open;
      search.removeAttribute("aria-activedescendant");
    }
  }
  function onInvalid(event) {
    const native = event.target;
    if (!native.matches?.("[data-olis-autocomplete-native]")) {
      return;
    }
    const field = native.closest("[data-olis-autocomplete]");
    if (field.dataset.enhanced !== "true") {
      return;
    }
    event.preventDefault();
    const { trigger, error } = parts(field);
    error.textContent = native.validationMessage;
    error.hidden = false;
    sync(field);
    trigger.focus();
  }
  function syncAll() {
    fields().forEach(sync);
  }
  function reposition() {
    fields().forEach(position);
  }
  function onReset(event) {
    if (!root || parts(root).native?.form !== event.target) {
      return;
    }
    setTimeout(() => {
      if (!root.isConnected) {
        return;
      }
      const { popup, search, error } = parts(root);
      if (popup.matches(":popover-open")) {
        popup.hidePopover();
      }
      search.value = "";
      error.hidden = true;
      error.textContent = "";
      sync(root);
    }, 0);
  }
  return {
    init() {
      root = this.$root;
      if (supported) {
        sync(root);
      }
    },
    input(event) {
      if (supported) {
        onInput(event);
      }
    },
    change(event) {
      if (supported) {
        onChange(event);
      }
    },
    keydown(event) {
      if (supported) {
        onKeyDown(event);
      }
    },
    pointerdown(event) {
      if (supported) {
        onPointerDown(event);
      }
    },
    click(event) {
      if (supported) {
        onClick(event);
      }
    },
    focusout(event) {
      if (supported) {
        onFocusOut(event);
      }
    },
    toggle(event) {
      if (supported) {
        onToggle(event);
      }
    },
    invalid(event) {
      if (supported) {
        onInvalid(event);
      }
    },
    reset(event) {
      if (supported) {
        onReset(event);
      }
    },
    update() {
      if (supported) {
        syncAll();
      }
    },
    reposition() {
      if (supported) {
        reposition();
      }
    },
    destroy() {
      if (!supported || !root) {
        return;
      }
      const { native, ui, popup } = parts(root);
      if (popup?.matches(":popover-open")) {
        popup.hidePopover();
      }
      if (ui) {
        ui.hidden = true;
      }
      if (native) {
        native.removeAttribute("aria-hidden");
        native.removeAttribute("tabindex");
      }
      delete root.dataset.enhanced;
    },
  };
}

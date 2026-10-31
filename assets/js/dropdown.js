/** Keyboard, selection and submenu behavior for OlisUI dropdowns. */
export function olisDropdown() {
  let root;
  const supported =
    typeof HTMLElement !== "undefined" && typeof HTMLElement.prototype.showPopover === "function";
  const selector = "[data-olis-dropdown-menu]",
    itemSelector = "[data-olis-dropdown-item]";
  const searches = new WeakMap(),
    hoverTimers = new Map();
  let keyboardNavigation = false;
  const parentMenu = (item) => item?.closest(selector);
  const items = (menu) =>
    [...menu.querySelectorAll(itemSelector)].filter(
      (item) =>
        parentMenu(item) === menu &&
        !item.disabled &&
        item.getAttribute("aria-disabled") !== "true",
    );
  const trigger = (menu) =>
    menu.parentElement?.querySelector(
      ":scope > [data-olis-dropdown-trigger], :scope > [data-olis-dropdown-submenu-trigger]",
    );
  function position(menu) {
    if (!menu.matches(":popover-open")) {
      return;
    }
    const anchor = trigger(menu);
    if (!anchor) {
      return;
    }
    const rect = anchor.getBoundingClientRect(),
      box = menu.getBoundingClientRect(),
      margin = 8;
    let left, top;
    if (menu.hasAttribute("data-olis-dropdown-submenu")) {
      const rtl = getComputedStyle(anchor).direction === "rtl";
      const preferred = rtl ? rect.left - box.width - 4 : rect.right + 4,
        alternate = rtl ? rect.right + 4 : rect.left - box.width - 4;
      left =
        preferred >= margin && preferred + box.width <= innerWidth - margin ? preferred : alternate;
      top = rect.top;
    } else {
      left = rect.left;
      const below = rect.bottom + 4;
      top = below + box.height <= innerHeight - margin ? below : rect.top - box.height - 4;
    }
    menu.style.left = `${Math.max(margin, Math.min(left, innerWidth - box.width - margin))}px`;
    menu.style.top = `${Math.max(margin, Math.min(top, innerHeight - box.height - margin))}px`;
  }
  function closeSubmenus(menu) {
    for (const sub of [
      ...menu.querySelectorAll("[data-olis-dropdown-submenu]:popover-open"),
    ].reverse()) {
      sub.hidePopover();
    }
  }
  function closeTree(menu, restore = true) {
    let current = menu;
    while (current) {
      const invoker = trigger(current),
        parent = invoker?.closest(selector);
      closeSubmenus(current);
      if (current.matches(":popover-open")) {
        current.hidePopover();
      }
      if (!parent) {
        if (restore) {
          invoker?.focus({ preventScroll: true });
        }
        break;
      }
      current = parent;
    }
  }
  function openSubmenu(invoker, focus = true) {
    const menu = document.getElementById(invoker.getAttribute("aria-controls")),
      parent = parentMenu(invoker);
    if (!menu || invoker.disabled || !parent?.matches(":popover-open")) {
      return;
    }
    for (const other of parent.querySelectorAll("[data-olis-dropdown-submenu]:popover-open")) {
      if (other !== menu && parentMenu(trigger(other)) === parent) {
        other.hidePopover();
      }
    }
    if (focus) {
      menu.dataset.focusOnOpen = "true";
    }
    if (!menu.matches(":popover-open")) {
      menu.showPopover();
    } else if (focus) {
      items(menu)[0]?.focus({ preventScroll: true });
    }
    position(menu);
  }
  function selectedKeys(group) {
    return [...group.querySelectorAll('[data-olis-dropdown-item][aria-checked="true"]')]
      .filter((item) => item.closest("[data-olis-dropdown-group]") === group)
      .map((item) => item.dataset.key);
  }
  function select(item) {
    const group = item.closest("[data-olis-dropdown-group]"),
      mode = group?.dataset.selectionMode;
    if (!group || !["single", "multiple"].includes(mode)) {
      return;
    }
    const old = selectedKeys(group),
      key = item.dataset.key,
      wasSelected = item.getAttribute("aria-checked") === "true";
    const next =
      mode === "single"
        ? [key]
        : wasSelected
          ? old.filter((value) => value !== key)
          : [...old, key];
    const changed = JSON.stringify(old) !== JSON.stringify(next);
    if (group.dataset.controlled !== "true") {
      for (const candidate of group.querySelectorAll("[data-olis-dropdown-item][aria-checked]")) {
        if (candidate.closest("[data-olis-dropdown-group]") !== group) {
          continue;
        }
        const checked = next.includes(candidate.dataset.key);
        candidate.setAttribute("aria-checked", String(checked));
        candidate.dataset.selected = String(checked);
        candidate
          .querySelector('[data-slot="menu-item-indicator--checkmark"]')
          ?.classList.toggle("invisible", !checked);
      }
    }
    if (changed) {
      item.dispatchEvent(
        new CustomEvent("olis:dropdown-selection-change", {
          bubbles: true,
          detail: { key, selected: next.includes(key), keys: next },
        }),
      );
      const button = group.querySelector(":scope > [data-olis-dropdown-selection-event]");
      if (button) {
        button.setAttribute("phx-value-key", key);
        button.setAttribute("phx-value-selected", String(next.includes(key)));
        button.setAttribute("phx-value-keys", JSON.stringify(next));
        button.click();
      }
    }
  }
  function onClick(event) {
    const item = event.target.closest?.(itemSelector);
    if (
      !item ||
      !root.contains(item) ||
      item.disabled ||
      item.getAttribute("aria-disabled") === "true"
    ) {
      return;
    }
    const menu = parentMenu(item);
    if (!menu) {
      return;
    }
    if (item.hasAttribute("data-olis-dropdown-submenu-trigger")) {
      event.preventDefault();
      openSubmenu(item);
      return;
    }
    const group = item.closest("[data-olis-dropdown-group]");
    select(item);
    if (group?.dataset.closeOnSelect !== "false") {
      closeTree(menu, item.tagName !== "A");
    }
  }
  function onKeyDown(event) {
    const item = event.target.closest?.(itemSelector),
      menu = parentMenu(item);
    if (item && menu && root.contains(menu)) {
      keyboardNavigation = true;
      for (const timer of hoverTimers.values()) {
        clearTimeout(timer);
      }
      hoverTimers.clear();
      const candidates = items(menu),
        index = candidates.indexOf(item),
        rtl = getComputedStyle(menu).direction === "rtl";
      let next;
      if (event.key === "ArrowDown") {
        next = (index + 1) % candidates.length;
      } else if (event.key === "ArrowUp") {
        next = (index - 1 + candidates.length) % candidates.length;
      } else if (event.key === "Home") {
        next = 0;
      } else if (event.key === "End") {
        next = candidates.length - 1;
      } else if (event.key === " " && item.tagName === "A") {
        event.preventDefault();
        item.click();
        return;
      } else if (
        event.key === (rtl ? "ArrowLeft" : "ArrowRight") &&
        item.hasAttribute("data-olis-dropdown-submenu-trigger")
      ) {
        event.preventDefault();
        openSubmenu(item);
        return;
      } else if (
        (event.key === (rtl ? "ArrowRight" : "ArrowLeft") || event.key === "Escape") &&
        menu.hasAttribute("data-olis-dropdown-submenu")
      ) {
        event.preventDefault();
        closeSubmenus(menu);
        menu.hidePopover();
        trigger(menu)?.focus({ preventScroll: true });
        return;
      } else if (event.key === "Escape") {
        event.preventDefault();
        closeTree(menu);
        return;
      } else if (
        event.key.length === 1 &&
        !event.ctrlKey &&
        !event.metaKey &&
        !event.altKey &&
        event.key !== " "
      ) {
        const last = searches.get(menu),
          query = (
            (last && Date.now() - last.time < 700 ? last.text : "") + event.key
          ).toLocaleLowerCase();
        searches.set(menu, { text: query, time: Date.now() });
        const ordered = [...candidates.slice(index + 1), ...candidates.slice(0, index + 1)];
        const match = ordered.find((candidate) =>
          candidate
            .querySelector('[data-slot="label"]')
            ?.textContent.trim()
            .toLocaleLowerCase()
            .startsWith(query),
        );
        if (match) {
          event.preventDefault();
          match.focus({ preventScroll: true });
          match.scrollIntoView({ block: "nearest" });
        }
        return;
      } else {
        return;
      }
      if (candidates.length) {
        event.preventDefault();
        candidates[next]?.focus({ preventScroll: true });
        candidates[next]?.scrollIntoView({ block: "nearest" });
      }
      return;
    }
    const opener = event.target.closest?.("[data-olis-dropdown-trigger]");
    if (opener && ["ArrowDown", "ArrowUp"].includes(event.key)) {
      const menu = document.getElementById(opener.getAttribute("aria-controls"));
      if (menu && !opener.disabled && !menu.matches(":popover-open")) {
        event.preventDefault();
        menu.dataset.focusLast = String(event.key === "ArrowUp");
        menu.showPopover();
      }
    }
  }
  function onToggle(event) {
    const menu = event.target;
    if (!menu.matches?.(selector) || !root.contains(menu)) {
      return;
    }
    const invoker = trigger(menu),
      open = menu.matches(":popover-open");
    invoker?.setAttribute("aria-expanded", String(open));
    if (open) {
      position(menu);
      if (!menu.hasAttribute("data-olis-dropdown-submenu") || menu.dataset.focusOnOpen === "true") {
        const candidates = items(menu);
        (menu.dataset.focusLast === "true" ? candidates.at(-1) : candidates[0])?.focus({
          preventScroll: true,
        });
      }
      delete menu.dataset.focusLast;
      delete menu.dataset.focusOnOpen;
    } else {
      closeSubmenus(menu);
    }
  }
  function onFocusOut(event) {
    const menu = event.target.closest?.(selector);
    if (!menu?.matches(":popover-open") || !event.relatedTarget) {
      return;
    }
    if (!menu.contains(event.relatedTarget)) {
      menu.hidePopover();
    }
  }
  function onPointerOver(event) {
    if (event.pointerType === "touch" || keyboardNavigation) {
      return;
    }
    const item = event.target.closest?.(itemSelector);
    if (!item || !root.contains(item)) {
      return;
    }
    const menu = parentMenu(item);
    if (!menu || item.contains(event.relatedTarget)) {
      return;
    }
    clearTimeout(hoverTimers.get(menu));
    if (item.hasAttribute("data-olis-dropdown-submenu-trigger")) {
      hoverTimers.set(
        menu,
        setTimeout(() => openSubmenu(item, false), 180),
      );
    } else {
      for (const sub of menu.querySelectorAll("[data-olis-dropdown-submenu]:popover-open")) {
        if (parentMenu(trigger(sub)) === menu) {
          sub.hidePopover();
        }
      }
    }
  }
  function onPointerOut(event) {
    const item = event.target.closest?.("[data-olis-dropdown-submenu-trigger]");
    if (!item || item.contains(event.relatedTarget)) {
      return;
    }
    const menu = parentMenu(item);
    clearTimeout(hoverTimers.get(menu));
  }
  function onPointerMove(event) {
    if (event.pointerType !== "touch") {
      keyboardNavigation = false;
    }
  }
  function reposition() {
    root.querySelectorAll(`${selector}:popover-open`).forEach(position);
  }
  return {
    init() {
      root = this.$root;
    },
    click(event) {
      if (supported) {
        onClick(event);
      }
    },
    keydown(event) {
      if (supported) {
        onKeyDown(event);
      }
    },
    toggle(event) {
      if (supported) {
        onToggle(event);
      }
    },
    focusout(event) {
      if (supported) {
        onFocusOut(event);
      }
    },
    pointerover(event) {
      if (supported) {
        onPointerOver(event);
      }
    },
    pointerout(event) {
      if (supported) {
        onPointerOut(event);
      }
    },
    pointermove(event) {
      if (supported) {
        onPointerMove(event);
      }
    },
    reposition() {
      if (supported) {
        reposition();
      }
    },
    destroy() {
      for (const timer of hoverTimers.values()) {
        clearTimeout(timer);
      }
      hoverTimers.clear();
      if (supported) {
        root.querySelectorAll(`${selector}:popover-open`).forEach((menu) => {
          menu.hidePopover();
        });
      }
    },
  };
}

/** Compatibility adapter for standalone consumers; LiveView components use Alpine bindings. */
export function installDropdown(root = document) {
  const dropdown = olisDropdown();
  dropdown.$root = root;
  dropdown.init();
  const listeners = [
    [root, "click", dropdown.click, true],
    [root, "keydown", dropdown.keydown],
    [root, "toggle", dropdown.toggle, true],
    [root, "focusout", dropdown.focusout],
    [root, "pointerover", dropdown.pointerover],
    [root, "pointerout", dropdown.pointerout],
    [root, "pointermove", dropdown.pointermove],
    [window, "resize", dropdown.reposition],
    [window, "scroll", dropdown.reposition, true],
    [document, "phx:update", dropdown.reposition],
  ];
  if (typeof HTMLElement.prototype.showPopover !== "function") {
    return () => dropdown.destroy();
  }
  listeners.forEach(([target, type, listener, capture]) => {
    target.addEventListener(type, listener, capture);
  });
  return () => {
    listeners.forEach(([target, type, listener, capture]) => {
      target.removeEventListener(type, listener, capture);
    });
    dropdown.destroy();
  };
}

/** Keyboard, selection and submenu behavior for OlisUI dropdowns. */
export function registerOlisDropdown(Alpine) {
  Alpine.data("olisDropdown", () => {
    let root;
    const supported =
      typeof HTMLElement !== "undefined" && typeof HTMLElement.prototype.showPopover === "function";
    const selector = "[data-olis-dropdown-menu]";
    const itemSelector = "[data-olis-dropdown-item]";
    const searches = new WeakMap();
    const hoverTimers = new Map();
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

    const rootMenu = () => root.querySelector(":scope > [data-olis-dropdown-menu]");

    function request(open, reason) {
      const button = root.querySelector(":scope > [data-olis-dropdown-open-event]");

      if (button) {
        button.setAttribute("phx-value-open", String(open));
        button.setAttribute("phx-value-reason", reason);
        button.click();
      }
    }

    function requestSubmenus(keys) {
      const button = root.querySelector(":scope > [data-olis-dropdown-submenus-event]");

      if (button) {
        button.setAttribute("phx-value-keys", JSON.stringify(keys));
        button.click();
      }
    }

    function submenuPath(menu) {
      const path = [];
      let current = menu;

      while (current?.hasAttribute("data-olis-dropdown-submenu")) {
        path.unshift(current.id);
        current = parentMenu(trigger(current));
      }

      return path;
    }

    function sync() {
      const menu = rootMenu();

      if (!menu) {
        return;
      }

      const open = root.dataset.open === "true";

      if (open && !menu.matches(":popover-open")) {
        menu.showPopover();
      } else if (!open && menu.matches(":popover-open")) {
        closeSubmenus(menu);
        menu.hidePopover();
        trigger(menu)?.focus({ preventScroll: true });
      }

      const submenus = [...root.querySelectorAll("[data-olis-dropdown-submenu]")];
      const selected = open ? JSON.parse(root.dataset.openSubmenus) : [];

      for (const submenu of [...submenus].reverse()) {
        if (!selected.includes(submenu.id) && submenu.matches(":popover-open")) {
          submenu.hidePopover();
        }
      }

      for (const submenu of submenus) {
        if (selected.includes(submenu.id) && !submenu.matches(":popover-open")) {
          submenu.showPopover();
        }
      }

      reposition();
    }

    function position(menu) {
      if (!menu.matches(":popover-open")) {
        return;
      }

      const anchor = trigger(menu);

      if (!anchor) {
        return;
      }

      const rect = anchor.getBoundingClientRect();
      const box = menu.getBoundingClientRect();
      const margin = 8;
      let left;
      let top;

      if (menu.hasAttribute("data-olis-dropdown-submenu")) {
        const rtl = getComputedStyle(anchor).direction === "rtl";
        const preferred = rtl ? rect.left - box.width - 4 : rect.right + 4;
        const alternate = rtl ? rect.right + 4 : rect.left - box.width - 4;

        left =
          preferred >= margin && preferred + box.width <= innerWidth - margin
            ? preferred
            : alternate;
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
    function closeTree(menu, restore = true, reason = "selection") {
      let current = menu;

      while (current) {
        const invoker = trigger(current);
        const parent = invoker?.closest(selector);

        if (!parent) {
          request(false, reason);

          if (restore) {
            invoker?.focus({ preventScroll: true });
          }

          break;
        }

        current = parent;
      }
    }
    function openSubmenu(invoker, focus = true) {
      const menu = document.getElementById(invoker.getAttribute("aria-controls"));
      const parent = parentMenu(invoker);

      if (!menu || invoker.disabled || !parent?.matches(":popover-open")) {
        return;
      }

      if (focus) {
        menu.dataset.focusOnOpen = "true";
      }

      if (menu.matches(":popover-open")) {
        if (focus) {
          items(menu)[0]?.focus({ preventScroll: true });
        }
      } else {
        requestSubmenus([...submenuPath(parent), menu.id]);
      }
    }
    function selectedKeys(group) {
      return [...group.querySelectorAll('[data-olis-dropdown-item][aria-checked="true"]')]
        .filter((item) => item.closest("[data-olis-dropdown-group]") === group)
        .map((item) => item.dataset.key);
    }
    function select(item) {
      const group = item.closest("[data-olis-dropdown-group]");
      const mode = group?.dataset.selectionMode;

      if (!group || !["single", "multiple"].includes(mode)) {
        return;
      }

      const old = selectedKeys(group);
      const key = item.dataset.key;
      const wasSelected = item.getAttribute("aria-checked") === "true";
      const next =
        mode === "single"
          ? [key]
          : wasSelected
            ? old.filter((value) => value !== key)
            : [...old, key];
      const changed = JSON.stringify(old) !== JSON.stringify(next);

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
      const opener = event.target.closest?.("[data-olis-dropdown-trigger]");

      if (opener && root.contains(opener) && !opener.disabled) {
        event.preventDefault();
        request(root.dataset.open !== "true", "trigger");
        return;
      }

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
      const item = event.target.closest?.(itemSelector);
      const menu = parentMenu(item);

      if (item && menu && root.contains(menu)) {
        keyboardNavigation = true;

        for (const timer of hoverTimers.values()) {
          clearTimeout(timer);
        }

        hoverTimers.clear();
        const candidates = items(menu);
        const index = candidates.indexOf(item);
        const rtl = getComputedStyle(menu).direction === "rtl";
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
          requestSubmenus(submenuPath(menu).slice(0, -1));
          trigger(menu)?.focus({ preventScroll: true });

          return;
        } else if (event.key === "Escape") {
          event.preventDefault();
          closeTree(menu, true, "escape");

          return;
        } else if (
          event.key.length === 1 &&
          !event.ctrlKey &&
          !event.metaKey &&
          !event.altKey &&
          event.key !== " "
        ) {
          const last = searches.get(menu);
          const query = (
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
          request(true, "keyboard");
        }
      }
    }
    function onToggle(event) {
      const menu = event.target;

      if (!menu.matches?.(selector) || !root.contains(menu)) {
        return;
      }

      const invoker = trigger(menu);
      const open = menu.matches(":popover-open");

      if (menu === rootMenu() && open !== (root.dataset.open === "true")) {
        request(open, "dismiss");
        sync();
        return;
      }

      if (menu.hasAttribute("data-olis-dropdown-submenu") && root.dataset.open === "true") {
        const expected = JSON.parse(root.dataset.openSubmenus).includes(menu.id);

        if (open !== expected) {
          requestSubmenus(open ? submenuPath(menu) : submenuPath(menu).slice(0, -1));
          sync();
          return;
        }
      }

      invoker?.setAttribute("aria-expanded", String(open));

      if (open) {
        position(menu);

        if (
          !menu.hasAttribute("data-olis-dropdown-submenu") ||
          menu.dataset.focusOnOpen === "true"
        ) {
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
        if (menu === rootMenu()) {
          request(false, "focusout");
        } else {
          requestSubmenus(submenuPath(menu).slice(0, -1));
        }
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
        const path = submenuPath(menu);
        const selected = JSON.parse(root.dataset.openSubmenus);

        if (selected.length > path.length) {
          requestSubmenus(path);
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
        if (supported) {
          sync();
        }
      },

      sync() {
        if (supported) {
          sync();
        }
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
  });
}

import assert from "node:assert/strict";
import { registerOlisUIAlpine } from "../assets/js/alpine.js";

const providers = {};
registerOlisUIAlpine({
  data(name, factory) {
    providers[name] = factory;
  },
});
globalThis.HTMLElement = class {
  showPopover() {}
};
globalThis.innerWidth = 800;
globalThis.innerHeight = 600;
let direction = "ltr";
globalThis.getComputedStyle = () => ({ direction });
globalThis.CustomEvent = class {
  constructor(type, options) {
    this.type = type;
    Object.assign(this, options);
  }
};
function eventTarget() {
  return {
    handlers: new Map(),
    addEventListener(type, handler) {
      this.handlers.set(type, handler);
    },
    removeEventListener(type, handler) {
      if (this.handlers.get(type) === handler) {
        this.handlers.delete(type);
      }
    },
  };
}
globalThis.window = eventTarget();
globalThis.document = eventTarget();
const root = eventTarget();
root.contains = () => true;
root.dataset = { open: "false", openSubmenus: "[]" };
const openEvent = {
  attrs: {},
  setAttribute(name, value) {
    this.attrs[name] = value;
  },
  click() {
    this.clicked = true;
  },
};
const submenuEvent = {
  attrs: {},
  setAttribute(name, value) {
    this.attrs[name] = value;
  },
  click() {
    this.clicked = true;
  },
};
const opener = {
  disabled: false,
  attrs: { "aria-controls": "menu" },
  getAttribute(name) {
    return this.attrs[name] ?? null;
  },
  setAttribute(name, value) {
    this.attrs[name] = String(value);
  },
  closest(selector) {
    return selector === "[data-olis-dropdown-trigger]" ? this : null;
  },
  focus() {
    this.focused = true;
  },
  getBoundingClientRect() {
    return { left: 20, right: 120, top: 20, bottom: 40 };
  },
};
root.querySelector = (selector) => {
  if (selector === ":scope > [data-olis-dropdown-menu]") {
    return menu;
  }
  if (selector === ":scope > [data-olis-dropdown-open-event]") {
    return openEvent;
  }
  if (selector === ":scope > [data-olis-dropdown-submenus-event]") {
    return submenuEvent;
  }
  return opener;
};
function createMenu(parentElement, submenu = false) {
  return {
    parentElement,
    dataset: {},
    style: {},
    open: false,
    entries: [],
    submenus: [],
    matches(selector) {
      return selector === ":popover-open" ? this.open : selector === "[data-olis-dropdown-menu]";
    },
    hasAttribute(name) {
      return name === "data-olis-dropdown-submenu" && submenu;
    },
    getBoundingClientRect() {
      return { width: 120, height: 80 };
    },
    showPopover() {
      this.open = true;
    },
    hidePopover() {
      this.open = false;
    },
    querySelectorAll(selector) {
      if (selector === "[data-olis-dropdown-item]") {
        return this.entries;
      }
      if (selector === "[data-olis-dropdown-submenu]:popover-open") {
        return this.submenus.filter((m) => m.open);
      }
      return [];
    },
  };
}
const menu = createMenu(root);
root.querySelectorAll = (selector) =>
  selector === "[data-olis-dropdown-submenu]"
    ? menu.submenus
    : [menu, ...menu.submenus].filter((m) => m.open);
const byId = { menu };
document.getElementById = (id) => byId[id];
function item(label, owner = menu) {
  return {
    tagName: "BUTTON",
    disabled: false,
    dataset: {},
    attrs: {},
    focused: false,
    owner,
    group: null,
    closest(selector) {
      if (selector === "[data-olis-dropdown-menu]") {
        return this.owner;
      }
      if (selector === "[data-olis-dropdown-item]") {
        return this;
      }
      if (selector === "[data-olis-dropdown-group]") {
        return this.group;
      }
      return null;
    },
    getAttribute(name) {
      return this.attrs[name] ?? null;
    },
    setAttribute(name, value) {
      this.attrs[name] = String(value);
    },
    hasAttribute(name) {
      return name === "data-olis-dropdown-submenu-trigger" && !!this.submenu;
    },
    querySelector(selector) {
      if (selector === '[data-slot="label"]') {
        return { textContent: label };
      }
      if (selector === '[data-slot="menu-item-indicator--checkmark"]') {
        return { classList: { toggle() {} } };
      }
      return null;
    },
    contains(other) {
      return other === this;
    },
    getBoundingClientRect() {
      return { left: 150, right: 200, top: 100, bottom: 120 };
    },
    focus() {
      this.focused = true;
    },
    scrollIntoView() {},
    dispatchEvent(event) {
      this.dispatched = event;
    },
  };
}
const first = item("First"),
  last = item("Last");
menu.entries = [first, last];
const dropdown = providers.olisDropdown();
dropdown.$root = root;
dropdown.init();
assert.equal(root.handlers.size, 0, "Alpine owns the listeners");
let prevented = false;
dropdown.keydown({
  target: opener,
  key: "ArrowDown",
  preventDefault() {
    prevented = true;
  },
});
assert.equal(prevented, true);
assert.equal(menu.open, false);
assert.equal(openEvent.attrs["phx-value-open"], "true");
root.dataset.open = "true";
dropdown.sync();
assert.equal(menu.open, true);
dropdown.toggle({ target: menu });
assert.equal(first.focused, true);
assert.equal(opener.attrs["aria-expanded"], "true");
const added = item("Added");
menu.entries.push(added);
dropdown.keydown({ target: first, key: "End", preventDefault() {} });
assert.equal(added.focused, true);
dropdown.click({ target: added });
assert.equal(menu.open, true);
assert.equal(openEvent.attrs["phx-value-open"], "false");
root.dataset.open = "false";
dropdown.sync();
assert.equal(menu.open, false);
assert.equal(opener.focused, true);

// A native dismissal is a request; the menu stays open until LiveView accepts it.
root.dataset.open = "true";
dropdown.sync();
menu.open = false;
dropdown.toggle({ target: menu });
assert.equal(openEvent.attrs["phx-value-reason"], "dismiss");
assert.equal(openEvent.attrs["phx-value-open"], "false");
assert.equal(menu.open, true);
root.dataset.open = "false";
dropdown.sync();
assert.equal(menu.open, false);

// RTL keyboard navigation opens a submenu to the left and Escape restores focus.
const subtrigger = item("Share");
subtrigger.submenu = true;
subtrigger.attrs["aria-controls"] = "submenu";
const subparent = {
  querySelector() {
    return subtrigger;
  },
};
const submenu = createMenu(subparent, true);
submenu.id = "submenu";
byId.submenu = submenu;
menu.submenus.push(submenu);
const subitem = item("Copy", submenu);
submenu.entries = [subitem];
menu.entries.push(subtrigger);
menu.open = true;
root.dataset.open = "true";
direction = "rtl";
prevented = false;
dropdown.keydown({
  target: subtrigger,
  key: "ArrowLeft",
  preventDefault() {
    prevented = true;
  },
});
assert.equal(prevented, true);
assert.equal(submenu.open, false);
assert.equal(submenuEvent.attrs["phx-value-keys"], '["submenu"]');
root.dataset.openSubmenus = '["submenu"]';
dropdown.sync();
assert.equal(submenu.open, true);
assert.equal(submenu.style.left, "26px");
dropdown.toggle({ target: submenu });
assert.equal(subitem.focused, true);

const nestedTrigger = item("More", submenu);
nestedTrigger.submenu = true;
nestedTrigger.attrs["aria-controls"] = "deep-menu";
submenu.entries.push(nestedTrigger);
const deepMenu = createMenu({ querySelector: () => nestedTrigger }, true);
deepMenu.id = "deep-menu";
byId["deep-menu"] = deepMenu;
menu.submenus.push(deepMenu);
dropdown.keydown({ target: nestedTrigger, key: "ArrowLeft", preventDefault() {} });
assert.equal(submenuEvent.attrs["phx-value-keys"], '["submenu","deep-menu"]');
assert.equal(deepMenu.open, false);
root.dataset.openSubmenus = '["submenu","deep-menu"]';
dropdown.sync();
assert.equal(deepMenu.open, true);

dropdown.keydown({ target: subitem, key: "Escape", preventDefault() {} });
assert.equal(submenu.open, true);
assert.equal(submenuEvent.attrs["phx-value-keys"], "[]");
root.dataset.openSubmenus = "[]";
dropdown.sync();
assert.equal(submenu.open, false);
assert.equal(deepMenu.open, false);
assert.equal(subtrigger.focused, true);
direction = "ltr";

// Selection changes include the entire next set and controlled groups stay server-owned.
const selectionButton = {
  attrs: {},
  setAttribute(key, value) {
    this.attrs[key] = value;
  },
  click() {
    this.clicked = true;
  },
};
const group = {
  dataset: { selectionMode: "multiple", closeOnSelect: "false" },
  entries: [],
  querySelectorAll(selector) {
    if (selector === '[data-olis-dropdown-item][aria-checked="true"]') {
      return this.entries.filter((i) => i.attrs["aria-checked"] === "true");
    }
    if (selector === "[data-olis-dropdown-item][aria-checked]") {
      return this.entries;
    }
    return [];
  },
  querySelector() {
    return selectionButton;
  },
};
const one = item("One"),
  two = item("Two");
one.group = two.group = group;
one.dataset.key = "one";
two.dataset.key = "two";
one.attrs["aria-checked"] = "true";
two.attrs["aria-checked"] = "false";
group.entries = [one, two];
dropdown.click({ target: two });
assert.equal(two.attrs["aria-checked"], "false");
assert.deepEqual(two.dispatched.detail, { key: "two", selected: true, keys: ["one", "two"] });
assert.equal(selectionButton.attrs["phx-value-keys"], '["one","two"]');
assert.equal(selectionButton.clicked, true);
two.attrs["aria-checked"] = "false";
dropdown.click({ target: two });
assert.equal(two.attrs["aria-checked"], "false");
assert.deepEqual(two.dispatched.detail.keys, ["one", "two"]);

// Pending hover-open timers are cancelled when Alpine removes the component.
let cancelled = false;
const nativeSetTimeout = globalThis.setTimeout,
  nativeClearTimeout = globalThis.clearTimeout;
globalThis.setTimeout = () => 123;
globalThis.clearTimeout = (timer) => {
  if (timer === 123) {
    cancelled = true;
  }
};
dropdown.pointermove({ pointerType: "mouse" });
dropdown.pointerover({ target: subtrigger, pointerType: "mouse", relatedTarget: null });
menu.open = true;
dropdown.destroy();
assert.equal(cancelled, true);
assert.equal(menu.open, false);
globalThis.setTimeout = nativeSetTimeout;
globalThis.clearTimeout = nativeClearTimeout;
delete globalThis.HTMLElement.prototype.showPopover;
const fallback = providers.olisDropdown();
fallback.$root = root;
fallback.init();
menu.open = false;
fallback.keydown({
  target: opener,
  key: "ArrowDown",
  preventDefault() {
    throw Error("unsupported");
  },
});
assert.equal(menu.open, false);
fallback.destroy();

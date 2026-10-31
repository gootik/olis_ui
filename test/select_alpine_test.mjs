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
let resetFrame;
globalThis.requestAnimationFrame = (fn) => {
  resetFrame = fn;
  return 1;
};
globalThis.cancelAnimationFrame = () => {
  resetFrame = null;
};
class Element {
  constructor(tag = "div") {
    this.tagName = tag.toUpperCase();
    this.dataset = {};
    this.attrs = {};
    this.children = [];
    this.hidden = false;
    this.style = {};
    this.textContent = "";
  }
  setAttribute(name, value) {
    this.attrs[name] = String(value);
  }
  getAttribute(name) {
    return this.attrs[name] ?? null;
  }
  removeAttribute(name) {
    delete this.attrs[name];
  }
  appendChild(child) {
    this.children.push(child);
    child.parentElement = this;
    return child;
  }
  replaceChildren() {
    this.children = [];
  }
  querySelectorAll(selector) {
    const found = [];
    for (const child of this.children) {
      if (selector === '[role="option"]' && child.attrs.role === "option") {
        found.push(child);
      }
      found.push(...child.querySelectorAll(selector));
    }
    return found;
  }
  querySelector(selector) {
    if (selector === '[data-active="true"]') {
      return this.querySelectorAll('[role="option"]').find((i) => i.dataset.active === "true");
    }
    if (selector === '[data-slot="label"]') {
      return this.children.find((i) => i.dataset.slot === "label");
    }
    return null;
  }
  matches(selector) {
    if (selector === ":popover-open") {
      return !!this.open;
    }
    if (selector === ":disabled") {
      return !!this.disabled;
    }
    if (selector === "[data-olis-native-select]") {
      return this === native;
    }
    return false;
  }
  closest(selector) {
    if (selector === "[data-olis-select-root]") {
      return root;
    }
    if (selector === "[data-olis-select-option]") {
      return this.dataset.olisSelectOption !== undefined ? this : null;
    }
    if (selector === "[data-olis-select-trigger]") {
      return this === button ? this : null;
    }
    return null;
  }
  focus() {
    this.focused = true;
  }
  getBoundingClientRect() {
    return { left: 20, top: 20, bottom: 40, width: 100, height: 20 };
  }
  scrollIntoView() {}
  showPopover() {
    this.open = true;
  }
  hidePopover() {
    this.open = false;
  }
}
const value = new Element("span"),
  native = new Element("select"),
  ui = new Element(),
  button = new Element("button"),
  popup = new Element(),
  list = new Element(),
  error = new Element("span"),
  root = new Element();
error.hidden = true;
native.setAttribute("tabindex", "3");
native.setAttribute("aria-hidden", "false");
native.id = "plan";
native.labels = [{ textContent: "Plan" }];
native.required = true;
native.size = 1;
native.multiple = false;
native.form = {};
native.tabIndex = 0;
const options = [
  ["", "Choose", false],
  ["basic", "Basic", false],
  ["disabled", "Disabled", true],
  ["pro", "Pro", false],
].map(([v, t, disabled], index) =>
  Object.assign(new Element("option"), { value: v, textContent: t, disabled, index }),
);
let selectedIndex = 0;
Object.defineProperty(native, "selectedIndex", {
  get() {
    return selectedIndex;
  },
  set(n) {
    selectedIndex = n;
  },
});
Object.defineProperty(native, "selectedOptions", {
  get() {
    return [options[selectedIndex]];
  },
});
Object.defineProperty(native, "value", {
  get() {
    return options[selectedIndex].value;
  },
});
options.forEach((option, index) => {
  option.parentElement = native;
  Object.defineProperty(option, "selected", {
    get() {
      return selectedIndex === index;
    },
  });
});
native.options = options;
native.children = options;
let changes = 0;
native.dispatchEvent = (event) => {
  if (event.type === "change") {
    changes++;
  }
};
button.attrs["aria-controls"] = "plan-listbox";
button.querySelector = (selector) => (selector === "[data-olis-select-value]" ? value : null);
popup.closest = () => root;
popup.matches = (selector) =>
  selector === "[data-olis-select-popup]"
    ? true
    : selector === ":popover-open"
      ? !!popup.open
      : false;
root.isConnected = true;
root.querySelector = (selector) =>
  ({
    "[data-olis-native-select]": native,
    "[data-olis-select-ui]": ui,
    "[data-olis-select-trigger]": button,
    "[data-olis-select-popup]": popup,
    "[data-olis-select-list]": list,
    "[data-olis-select-error]": error,
  })[selector] || null;
root.contains = () => true;
globalThis.document = {
  getElementById: () => list,
  createElement: (tag) => new Element(tag),
  createElementNS: (_ns, tag) => new Element(tag),
};
const select = providers.olisSelect();
select.$root = root;
select.init();
assert.equal(root.dataset.enhanced, "true");
assert.equal(value.textContent, "Choose");
assert.equal(button.attrs["aria-label"], "Plan");
assert.equal(list.querySelectorAll('[role="option"]').length, 4);
let prevented = false;
select.keydown({
  target: button,
  key: "ArrowDown",
  preventDefault() {
    prevented = true;
  },
});
assert.equal(prevented, true);
assert.equal(popup.open, true);
select.toggle({ target: popup });
assert.equal(button.attrs["aria-expanded"], "true");
select.keydown({ target: button, key: "ArrowDown", preventDefault() {} });
select.keydown({ target: button, key: "Enter", preventDefault() {} });
assert.equal(native.value, "basic");
assert.equal(value.textContent, "Basic");
assert.equal(changes, 1);
assert.equal(popup.open, false);
assert.equal(button.focused, true);
selectedIndex = 3;
select.change({ target: native });
assert.equal(value.textContent, "Pro");
select.reset({ target: native.form });
selectedIndex = 0;
resetFrame();
assert.equal(value.textContent, "Choose");
select.destroy();
assert.equal(root.dataset.enhanced, undefined);
assert.equal(ui.hidden, true);
assert.equal(native.getAttribute("aria-hidden"), "false");
assert.equal(native.getAttribute("tabindex"), "3");
delete globalThis.HTMLElement.prototype.showPopover;
const fallback = providers.olisSelect();
fallback.$root = root;
fallback.init();
assert.equal(root.dataset.enhanced, undefined);
fallback.destroy();
console.log("Select Alpine enhancement, selection, form reset and fallback passed");

import assert from "node:assert/strict";
import { registerOlisUIAlpine } from "../assets/js/alpine.js";
const providers = {};
registerOlisUIAlpine({
  data(name, factory) {
    providers[name] = factory;
  },
});
globalThis.CustomEvent = class {
  constructor(type, options) {
    this.type = type;
    Object.assign(this, options);
  }
};
const selectionButton = {
  isConnected: true,
  attrs: {},
  setAttribute(k, v) {
    this.attrs[k] = v;
  },
  click() {
    this.clicked = true;
  },
};
const actionButton = {
  isConnected: true,
  attrs: {},
  setAttribute(k, v) {
    this.attrs[k] = v;
  },
  click() {
    this.clicked = true;
  },
};
const root = {
  isConnected: true,
  attrs: {},
  options: [],
  focused: false,
  events: [],
  dataset: { selectionMode: "multiple", controlled: "false", selectedKeys: '["c"]' },
  querySelectorAll() {
    return this.options;
  },
  querySelector(selector) {
    return selector === "[data-olis-listbox-selection-event]"
      ? selectionButton
      : selector === "[data-olis-listbox-action-event]"
        ? actionButton
        : null;
  },
  dispatchEvent(event) {
    this.events.push(event);
  },
  getAttribute(name) {
    return this.attrs[name] ?? null;
  },
  setAttribute(name, value) {
    this.attrs[name] = String(value);
  },
  removeAttribute(name) {
    delete this.attrs[name];
  },
  closest() {
    return this;
  },
  focus() {
    this.focused = true;
  },
};
function item(id, label, disabled = false, selected = false, owner = root) {
  const indicator = { hidden: !selected };
  return {
    id,
    dataset: { key: id, textValue: label },
    clicks: 0,
    scrolled: false,
    indicator,
    attrs: { "aria-disabled": String(disabled), "aria-selected": String(selected) },
    getAttribute(name) {
      return this.attrs[name] ?? null;
    },
    setAttribute(k, v) {
      this.attrs[k] = String(v);
    },
    closest(selector) {
      return selector === "[data-olis-listbox]" ? owner : this;
    },
    querySelector(selector) {
      return selector === "[data-olis-listbox-indicator]" ? indicator : { textContent: label };
    },
    scrollIntoView() {
      this.scrolled = true;
    },
    click() {
      this.clicks++;
      listbox.click({ target: this });
    },
  };
}
const alpha = item("a", "Alpha"),
  disabled = item("b", "Beta", true),
  charlie = item("c", "Charlie", false, true),
  nested = item("x", "Nested", false, false, {});
root.options = [alpha, disabled, charlie, nested];
const listbox = providers.olisListbox();
listbox.$root = root;
listbox.$nextTick = (fn) => fn();
listbox.init();
assert.equal(root.attrs["aria-activedescendant"], "c");
assert.equal(charlie.dataset.active, "true");
assert.equal(nested.dataset.active, undefined);
function key(key) {
  let prevented = false;
  listbox.keydown({
    target: root,
    key,
    preventDefault() {
      prevented = true;
    },
  });
  return prevented;
}
assert.equal(key("ArrowDown"), true);
assert.equal(root.attrs["aria-activedescendant"], "a");
assert.equal(key("ArrowUp"), true);
assert.equal(root.attrs["aria-activedescendant"], "c");
assert.equal(key("Home"), true);
assert.equal(root.attrs["aria-activedescendant"], "a");
assert.equal(key("End"), true);
assert.equal(root.attrs["aria-activedescendant"], "c");
assert.equal(key("a"), true);
assert.equal(root.attrs["aria-activedescendant"], "a");
assert.equal(alpha.scrolled, true);
assert.equal(key("Enter"), true);
assert.equal(alpha.clicks, 1);
assert.deepEqual(listbox.keys, ["c", "a"]);
assert.equal(alpha.attrs["aria-selected"], "true");
assert.equal(alpha.indicator.hidden, false);
assert.deepEqual(root.events.at(-2).detail, { keys: ["c", "a"], value: "a", selected: true });
await Promise.resolve();
assert.equal(selectionButton.attrs["phx-value-keys"], '["c","a"]');
assert.equal(selectionButton.value, "a");
assert.equal(actionButton.value, "a");
root.dataset.controlled = "true";
root.dataset.selectedKeys = '["c"]';
listbox.sync();
listbox.click({ target: alpha });
assert.deepEqual(listbox.keys, ["c"]);
assert.equal(alpha.attrs["aria-selected"], "false");
assert.deepEqual(root.events.at(-2).detail.keys, ["c", "a"]);
root.dataset.selectionMode = "none";
const previous = root.events.length;
listbox.click({ target: alpha });
assert.equal(root.events.length, previous + 1);
assert.equal(root.events.at(-1).type, "olis:listbox-action");
root.options = [alpha, disabled];
root.attrs["aria-activedescendant"] = "removed";
listbox.sync();
assert.equal(root.attrs["aria-activedescendant"], "a");
alpha.attrs["aria-disabled"] = "true";
listbox.sync();
assert.equal(root.attrs["aria-activedescendant"], undefined);
assert.equal(alpha.dataset.active, "false");
root.attrs["aria-disabled"] = "true";
assert.equal(key("ArrowDown"), false);
listbox.click({ target: alpha });
assert.equal(root.attrs["aria-activedescendant"], undefined);
console.log("Listbox keyboard, local and controlled selection, actions and reconciliation passed");

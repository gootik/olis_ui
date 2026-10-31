import assert from "node:assert/strict";
import { registerOlisToggleButtonGroup } from "../assets/js/alpine/toggle_button_group.js";
const providers = {};
registerOlisToggleButtonGroup({
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
let direction = "ltr";
globalThis.getComputedStyle = () => ({ direction });
function createGroup(mode = "single", controlled = false, selected = []) {
  const events = [],
    sent = [],
    buttons = [];
  const root = {
    isConnected: true,
    dataset: {
      selectionMode: mode,
      orientation: "horizontal",
      controlled: String(controlled),
      selectedKeys: JSON.stringify(selected),
      disallowEmpty: "false",
    },
    attrs: {},
    querySelectorAll() {
      return buttons;
    },
    querySelector() {
      return eventButton;
    },
    setAttribute(k, v) {
      this.attrs[k] = String(v);
    },
    dispatchEvent(e) {
      events.push(e);
    },
  };
  const eventButton = {
    setAttribute(k, v) {
      this[k] = v;
    },
    click() {
      sent.push(JSON.parse(this["phx-value-keys"]));
    },
  };
  const add = (key, disabled = false, owner = root) => {
    const classes = new Set(["toggle-button--md"]);
    const button = {
      id: "",
      disabled,
      attrs: { value: key },
      tabIndex: 0,
      dataset: {},
      classes,
      classList: {
        remove(...names) {
          names.forEach((name) => {
            classes.delete(name);
          });
        },
        add(name) {
          classes.add(name);
        },
      },
      matches(selector) {
        return selector === ":disabled" && (this.disabled || !!this.inheritedDisabled);
      },
      closest(selector) {
        return selector === "[data-olis-toggle-group]" ? owner : this;
      },
      getAttribute(k) {
        return this.attrs[k] ?? null;
      },
      setAttribute(k, v) {
        this.attrs[k] = String(v);
      },
      removeAttribute(k) {
        delete this.attrs[k];
      },
      focus() {
        this.focused = true;
      },
    };
    buttons.push(button);
    return button;
  };
  const group = providers.olisToggleButtonGroup();
  group.$root = root;
  group.$nextTick = (fn) => fn();
  return { root, group, buttons, events, sent, add };
}
const state = createGroup("single", false, ["one"]);
const a = state.add("one"),
  disabled = state.add("skip", true),
  b = state.add("two");
state.group.init();
assert.equal(state.root.attrs.role, "radiogroup");
assert.equal(a.attrs["aria-checked"], "true");
assert.equal(b.attrs["aria-checked"], "false");
assert.equal(a.tabIndex, 0);
assert.equal(disabled.tabIndex, -1);
state.group.click({ target: b });
assert.deepEqual(state.group.keys, ["one"]);
assert.equal(b.attrs["aria-checked"], "false");
state.root.dataset.selectedKeys = '["two"]';
state.group.sync();
assert.equal(b.attrs["aria-checked"], "true");
assert.deepEqual(state.sent, [["two"]]);
assert.equal(state.events[0].type, "olis:toggle-button-group-change");
state.root.dataset.disallowEmpty = "true";
state.group.click({ target: b });
assert.deepEqual(state.group.keys, ["two"]);
assert.equal(state.sent.length, 1);
let prevented = false,
  stopped = false;
state.group.keydown({
  target: b,
  key: "ArrowRight",
  preventDefault() {
    prevented = true;
  },
  stopPropagation() {
    stopped = true;
  },
});
assert.equal(prevented, true);
assert.equal(stopped, true);
assert.equal(a.focused, true);
assert.deepEqual(state.group.keys, ["two"]);
assert.deepEqual(state.sent.at(-1), ["one"]);
const controlled = createGroup("multiple", true, ["a"]);
const x = controlled.add("a"),
  y = controlled.add("b");
controlled.group.init();
assert.equal(controlled.root.attrs.role, "toolbar");
controlled.group.click({ target: y });
assert.deepEqual(controlled.group.keys, ["a"]);
assert.deepEqual(controlled.sent, [["a", "b"]]);
assert.equal(y.attrs["aria-pressed"], "false");
controlled.root.dataset.selectedKeys = '["a","b"]';
controlled.group.sync();
assert.equal(y.attrs["aria-pressed"], "true");
direction = "rtl";
controlled.group.keydown({
  target: x,
  key: "ArrowLeft",
  preventDefault() {},
  stopPropagation() {},
});
assert.equal(y.focused, true);
assert.deepEqual(controlled.group.keys, ["a", "b"]);
const inherited = controlled.add("inherited");
inherited.inheritedDisabled = true;
controlled.group.sync();
assert.equal(inherited.tabIndex, -1);
assert.ok(!controlled.group.enabled().includes(inherited));
const nested = controlled.add("outside", false, {});
controlled.group.sync();
assert.equal(nested.attrs["aria-pressed"], undefined);
const sizing = createGroup(null, false, []);
const inherit = sizing.add("one"),
  override = sizing.add("two");
override.dataset.olisToggleSize = "lg";
sizing.root.dataset.olisToggleSize = "sm";
sizing.group.init();
assert.ok(inherit.classes.has("toggle-button--sm"));
assert.ok(override.classes.has("toggle-button--lg"));
assert.equal(inherit.tabIndex, 0);
assert.equal(sizing.root.attrs.role, undefined);
sizing.root.dataset.olisToggleSize = "md";
sizing.group.sync();
assert.ok(inherit.classes.has("toggle-button--md"));
assert.ok(override.classes.has("toggle-button--lg"));


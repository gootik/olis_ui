import assert from "node:assert/strict";
import { registerOlisDialog } from "../assets/js/alpine/dialog.js";

let factory;
registerOlisDialog({
  data(_name, value) {
    factory = value;
  },
});
globalThis.CustomEvent = class {
  constructor(type, options) {
    this.type = type;
    Object.assign(this, options);
  }
};
function fixture({
  initial = false,
  dismissible = true,
  keyboardDisabled = false,
  modal = true,
} = {}) {
  const changes = [],
    button = {
      attrs: {},
      setAttribute(k, v) {
        this.attrs[k] = v;
      },
      click() {
        changes.push({ ...this.attrs });
      },
    };
  const dialog = {
    id: "settings",
    open: false,
    dataset: {
      open: String(initial),
      dismissible: String(dismissible),
      keyboardDismissDisabled: String(keyboardDisabled),
    },
    hasAttribute(name) {
      return name === "data-olis-modal" && modal;
    },
    showModal() {
      this.open = true;
    },
    close() {
      this.open = false;
    },
    dispatchEvent(event) {
      this.event = event;
    },
    querySelector() {
      return button;
    },
    getBoundingClientRect() {
      return { left: 100, right: 300, top: 100, bottom: 300 };
    },
  };
  const instance = factory();
  instance.$root = dialog;
  instance.init();
  const trigger = {
    getAttribute() {
      return "settings";
    },
    matches() {
      return false;
    },
  };
  return { instance, dialog, changes, trigger };
}
const local = fixture();
local.instance.openFromTrigger({ target: { closest: () => local.trigger } });
assert.equal(local.dialog.open, false);
assert.deepEqual(local.dialog.event.detail, { open: true, reason: "trigger" });
local.dialog.dataset.open = "true";
local.instance.sync();
assert.equal(local.dialog.open, true);
let prevented = false;
local.instance.onCancel({
  target: local.dialog,
  preventDefault() {
    prevented = true;
  },
});
assert.equal(prevented, true);
assert.equal(local.dialog.open, true);
assert.deepEqual(local.changes.at(-1), { "phx-value-open": "false", "phx-value-reason": "escape" });
local.dialog.dataset.open = "false";
local.instance.sync();
local.instance.onNativeClose({ target: local.dialog });
assert.equal(local.changes.length, 2);
const controlled = fixture({ initial: true, dismissible: false });
assert.equal(controlled.dialog.open, true);
controlled.instance.onClick({ target: controlled.dialog, clientX: 0, clientY: 0 });
assert.equal(controlled.changes.length, 0);
controlled.instance.onCancel({ target: controlled.dialog, preventDefault() {} });
assert.equal(controlled.dialog.open, true);
assert.equal(controlled.changes.at(-1)["phx-value-reason"], "escape");
controlled.dialog.dataset.open = "false";
controlled.instance.sync();
assert.equal(controlled.dialog.open, false);
controlled.instance.onNativeClose({ target: controlled.dialog });
assert.equal(controlled.changes.length, 1);
const locked = fixture({ initial: true, keyboardDisabled: true });
locked.instance.onCancel({ target: locked.dialog, preventDefault() {} });
assert.equal(locked.changes.length, 0);
locked.dialog.close();
locked.instance.onNativeClose({ target: locked.dialog });
assert.equal(locked.dialog.open, true, "native close cannot bypass server-controlled state");
assert.equal(locked.changes.at(-1)["phx-value-reason"], "native");
const alert = fixture({ modal: false, dismissible: false });
let alertPrevented = false;
alert.instance.onCancel({
  target: alert.dialog,
  preventDefault() {
    alertPrevented = true;
  },
});
assert.equal(alertPrevented, true);
local.instance.destroy();
controlled.instance.destroy();
locked.instance.destroy();
alert.instance.destroy();

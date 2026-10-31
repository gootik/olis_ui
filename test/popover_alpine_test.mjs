import assert from "node:assert/strict";
import { registerOlisPopover } from "../assets/js/alpine/popover.js";
let make;
registerOlisPopover({
  data(_name, factory) {
    make = factory;
  },
});
globalThis.window = { innerWidth: 800, innerHeight: 600 };
globalThis.document = { activeElement: null };
globalThis.getComputedStyle = () => ({ direction: "ltr" });
globalThis.CustomEvent = class {
  constructor(type, options) {
    this.type = type;
    Object.assign(this, options);
  }
};
const root = {
  dataset: {
    requestedPlacement: "bottom",
    offset: "8",
    shouldFlip: "true",
    open: "false",
  },
  events: [],
  querySelector() {
    return null;
  },
  dispatchEvent(event) {
    this.events.push(event.detail);
  },
};
const trigger = {
  attrs: {},
  matches(selector) {
    return selector === "[data-olis-popover-trigger]";
  },
  setAttribute(k, v) {
    this.attrs[k] = v;
  },
  focus() {
    this.focused = true;
  },
  getBoundingClientRect() {
    return { left: 200, right: 300, top: 100, bottom: 140, width: 100, height: 40 };
  },
};
const dialog = {
  focus() {
    this.focused = true;
  },
};
const content = {
  style: {},
  dataset: {},
  open: false,
  matches() {
    return this.open;
  },
  contains() {
    return false;
  },
  showPopover() {
    this.open = true;
  },
  hidePopover() {
    this.open = false;
  },
  getBoundingClientRect() {
    return { width: 200, height: 120 };
  },
};
const popover = make();
popover.$root = root;
popover.$refs = { trigger, content, dialog };
popover.$nextTick = (f) => f();
popover.init();
root.dataset.open = "true";
popover.sync();
popover.toggle({ target: content });
assert.deepEqual(
  [content.style.left, content.style.top, content.dataset.placement],
  ["150px", "148px", "bottom"],
);
assert.equal(trigger.attrs["aria-expanded"], "true");
assert.equal(dialog.focused, true);
assert.equal(root.events.length, 0);
root.dataset.requestedPlacement = "left start";
popover.position();
assert.deepEqual(
  [content.style.left, content.style.top, content.dataset.placement],
  ["308px", "100px", "right"],
);
root.dataset.shouldFlip = "false";
popover.position();
assert.equal(content.dataset.placement, "left");
content.open = false;
root.dataset.open = "false";
let prevented = false;
popover.onClick({
  target: { closest: () => trigger },
  preventDefault() {
    prevented = true;
  },
});
assert.equal(prevented, true);
assert.equal(content.open, false);
assert.deepEqual(root.events.at(-1), { open: true, reason: "trigger" });
root.dataset.open = "true";
popover.sync();
assert.equal(content.open, true);
popover.toggle({ target: content });
const count = root.events.length;
content.open = false;
popover.toggle({ target: content });
assert.deepEqual(root.events.at(-1), { open: false, reason: "dismiss" });
assert.equal(content.open, true);
popover.toggle({ target: content });
assert.equal(root.events.length, count + 1);
root.dataset.open = "false";
popover.sync();
popover.toggle({ target: content });
assert.equal(content.open, false);
assert.equal(root.events.length, count + 1);
// A LiveView replacement can dispatch an update before Alpine removes the old listener.
popover.$root = undefined;
assert.doesNotThrow(() => {
  popover.sync();
  popover.position();
  popover.toggle({ target: content });
});
popover.$root = root;
popover.destroy();

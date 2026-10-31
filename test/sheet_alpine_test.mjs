import assert from "node:assert/strict";
import { registerOlisUIAlpine } from "../assets/js/alpine.js";

const classes = new Set(),
  sheets = [];
globalThis.document = {
  contains: () => true,
  documentElement: {
    classList: {
      contains: (name) => classes.has(name),
      add: (name) => classes.add(name),
      remove: (name) => classes.delete(name),
    },
  },
  querySelectorAll: () => sheets,
};
globalThis.window = { matchMedia: () => ({ matches: true }) };
function sheet(id) {
  const content = {
    dataset: {},
    style: {
      removeProperty(name) {
        delete this[name];
      },
    },
    hasAttribute: () => false,
    getBoundingClientRect: () => ({ width: 300, height: 300 }),
  };
  const backdrop = {
    dataset: {},
    style: {
      removeProperty(name) {
        delete this[name];
      },
    },
  };
  return {
    id,
    open: false,
    isConnected: true,
    dataset: {
      placement: "bottom",
      open: "true",
      snapPointsJson: "[]",
    },
    showModal() {
      this.open = true;
    },
    close() {
      this.open = false;
    },
    querySelectorAll() {
      return [];
    },
    querySelector(selector) {
      if (selector === ":scope > [data-olis-sheet-content]") {
        return content;
      }
      if (selector === ":scope > [data-olis-sheet-backdrop]") {
        return backdrop;
      }
      return null;
    },
    content,
    backdrop,
  };
}
const providers = {};
registerOlisUIAlpine({
  data(name, factory) {
    providers[name] = factory;
  },
});
const first = sheet("one"),
  second = sheet("two");
first.dataset.snapPointsJson = "[100,200]";
first.dataset.snapIndex = "0";
first.dataset.dismissible = "false";
const snapEvent = {
  attrs: {},
  setAttribute(name, value) {
    this.attrs[name] = value;
  },
  click() {
    this.clicked = true;
  },
};
const originalQuery = first.querySelector;
first.querySelector = (selector) =>
  selector === ":scope > [data-olis-sheet-snap-event]" ? snapEvent : originalQuery(selector);
const handle = {
  dataset: {},
  closest(selector) {
    return selector === "[data-olis-sheet-handle]" ? this : first;
  },
  setPointerCapture() {},
  hasPointerCapture: () => true,
  releasePointerCapture() {},
};
sheets.push(first, second);
const a = providers.olisSheet(),
  b = providers.olisSheet();
a.$root = first;
b.$root = second;
a.init();
b.init();
assert.equal(first.open, true);
assert.equal(first.content.style.transform, "translateY(200px)");
let now = 0;
globalThis.performance = { now: () => now };
const pointer = (y) => ({
  target: handle,
  pointerType: "mouse",
  button: 0,
  pointerId: 1,
  clientY: y,
  preventDefault() {},
});
a.pointerdown(pointer(0));
now = 1000;
a.pointermove(pointer(-100));
a.pointerup(pointer(-100));
assert.equal(snapEvent.attrs["phx-value-index"], "1");
assert.equal(first.content.style.transform, "translateY(200px)", "snap waits for LiveView");
first.dataset.snapIndex = "1";
a.sync();
assert.equal(first.content.style.transform, "translateY(100px)");
first.dataset.snapIndex = "-1";
a.sync();
assert.equal(first.content.style.transform, "translateY(0px)");
assert.equal(second.open, true);
assert.equal(first.backdrop.dataset.stackIndex, "0");
assert.equal(second.backdrop.dataset.stackIndex, "1");
assert.ok(classes.has("overflow-hidden"));
a.destroy();
assert.equal(first.open, false);
assert.equal(second.open, true);
assert.ok(classes.has("overflow-hidden"));
assert.equal(second.backdrop.dataset.stackIndex, "0");
b.destroy();
assert.equal(second.open, false);
assert.ok(!classes.has("overflow-hidden"));

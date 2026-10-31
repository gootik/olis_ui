import assert from "node:assert/strict";
import { registerOlisUIAlpine } from "../assets/js/alpine.js";

const classes = new Set(),
  sheets = [];
globalThis.document = {
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
      controlled: "false",
      defaultOpen: "true",
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
sheets.push(first, second);
const a = providers.olisSheet(),
  b = providers.olisSheet();
a.$root = first;
b.$root = second;
a.init();
b.init();
assert.equal(first.open, true);
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
console.log("Sheet providers share stack and scroll lock across component instances");

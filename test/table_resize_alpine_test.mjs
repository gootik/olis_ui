import assert from "node:assert/strict";
import { registerOlisTable } from "../assets/js/alpine/table.js";
let make;
registerOlisTable({
  data(_, factory) {
    make = factory;
  },
});
globalThis.document = {
  addEventListener() {},
  removeEventListener() {},
  activeElement: null,
  body: {},
  hasFocus: () => true,
};
globalThis.CustomEvent = class {
  constructor(type, options) {
    this.type = type;
    Object.assign(this, options);
  }
};
let direction = "ltr";
globalThis.getComputedStyle = () => ({ direction });
const eventButton = {
  attrs: {},
  setAttribute(k, v) {
    this.attrs[k] = v;
  },
  click() {
    this.clicked = true;
  },
};
const col = (key, min, max) => ({
  dataset: { tableColumnKey: key, minWidth: String(min), maxWidth: String(max) },
  style: {},
});
const columns = [col("name", 100, 300), col("role", 80, 350)];
const handle = {
  dataset: { tableResizer: "name" },
  attrs: {},
  closest: () => root,
  setAttribute(k, v) {
    this.attrs[k] = String(v);
  },
  removeAttribute(k) {
    delete this.attrs[k];
  },
  focus() {},
  setPointerCapture(id) {
    this.capture = id;
  },
  hasPointerCapture(id) {
    return this.capture === id;
  },
  releasePointerCapture() {
    this.capture = null;
  },
};
const headers = [
  { getBoundingClientRect: () => ({ width: 200 }), querySelector: () => handle },
  { getBoundingClientRect: () => ({ width: 200 }), querySelector: () => null },
];
const table = {
  style: {},
  querySelectorAll() {
    return columns;
  },
};
const root = {
  isConnected: true,
  dataset: {},
  querySelector(selector) {
    return selector === "table"
      ? table
      : selector === "[data-olis-table-resize-event]"
        ? eventButton
        : null;
  },
  dispatchEvent(event) {
    this.event = event;
  },
};
const instance = make();
instance.$root = root;
instance.headers = () => headers;
instance.syncFocus = () => {};
instance.init();
assert.equal(handle.attrs["aria-valuenow"], "200");
const key = (key, extra = {}) => {
  const e = {
    key,
    currentTarget: handle,
    preventDefault() {
      this.prevented = true;
    },
    stopPropagation() {
      this.stopped = true;
    },
    ...extra,
  };
  instance.resizeKey(e);
  return e;
};
assert.ok(key("ArrowRight").prevented);
assert.equal(columns[0].style.width, "210px");
assert.equal(table.style.width, "410px");
assert.deepEqual(root.event.detail, { key: "name", width: 210, widths: { name: 210, role: 200 } });
assert.equal(eventButton.attrs["phx-value-column"], "name");
assert.equal(eventButton.attrs["phx-value-width"], "210");
key("End");
assert.equal(columns[0].style.width, "300px");
key("Home");
assert.equal(columns[0].style.width, "100px");
direction = "rtl";
key("ArrowLeft");
assert.equal(columns[0].style.width, "110px");
key("ArrowRight", { shiftKey: true });
assert.equal(columns[0].style.width, "109px");
const start = { button: 0, currentTarget: handle, pointerId: 3, clientX: 300, preventDefault() {} };
instance.resizeStart(start);
assert.equal(handle.capture, 3);
assert.equal(handle.attrs["data-resizing"], "true");
instance.resizeMove({ pointerId: 3, clientX: 280, preventDefault() {} });
assert.equal(columns[0].style.width, "129px");
instance.resizeCancel({ pointerId: 3 });
assert.equal(columns[0].style.width, "109px");
assert.equal(handle.capture, null);
instance.resizeStart(start);
instance.resizeMove({ pointerId: 3, clientX: 260, preventDefault() {} });
instance.resizeEnd({ pointerId: 3 });
assert.equal(columns[0].style.width, "149px");
assert.equal(root.event.detail.width, 149);
assert.equal(handle.capture, null);
// A LiveView patch may replace column DOM nodes; locally chosen sizes are reapplied by key.
const replacement = col("name", 100, 300);
columns[0] = replacement;
instance.sync();
assert.equal(replacement.style.width, "149px");
instance.destroy();
console.log("Table column resize bounds, pointer, RTL, events and patch reconciliation passed");

import assert from "node:assert/strict";
import { registerOlisTable } from "../assets/js/alpine/table.js";
let factory;
registerOlisTable({
  data(name, value) {
    assert.equal(name, "olisTable");
    factory = value;
  },
});
globalThis.document = { addEventListener() {}, removeEventListener() {} };
globalThis.CustomEvent = class {
  constructor(type, options) {
    this.type = type;
    Object.assign(this, options);
  }
};
const label = { dataset: {} };
const selectAll = {
  checked: false,
  indeterminate: false,
  disabled: false,
  matches: (s) => s === "[data-olis-table-select-all]",
  closest: (s) => (s === ".checkbox" ? label : root),
};
const eventButton = {
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
  dataset: { selectionMode: "multiple", selectedKeys: '["a","outside"]' },
  dispatched: [],
  rows: [],
  querySelectorAll(s) {
    return s === "[data-olis-table-row]" ? this.rows : [];
  },
  querySelector(s) {
    return s === "[data-olis-table-select-all]"
      ? selectAll
      : s === "[data-olis-table-selection-event]"
        ? eventButton
        : null;
  },
  dispatchEvent(event) {
    this.dispatched.push(event);
  },
};
function row(key, disabled = false) {
  const row = {
    dataset: { key },
    attrs: {},
    setAttribute(k, v) {
      this.attrs[k] = v;
    },
    closest: () => root,
  };
  const input = {
    checked: false,
    disabled,
    matches: (s) => s === "[data-olis-table-select-row]",
    closest: (s) => (s === "[data-olis-table-row]" ? row : root),
    click() {
      this.clicked = true;
    },
  };
  row.querySelector = () => input;
  return { row, input };
}
const a = row("a"),
  b = row("b"),
  c = row("c", true);
root.rows = [a.row, b.row, c.row];
const table = factory();
table.$root = root;
table.init();
assert.equal(a.input.checked, true);
assert.equal(b.input.checked, false);
assert.equal(selectAll.indeterminate, true);
b.input.checked = true;
table.selectionChange({ target: b.input });
assert.deepEqual(table.keys, ["a", "outside"]);
assert.equal(b.input.checked, false, "selection waits for LiveView");
await Promise.resolve();
assert.equal(eventButton.attrs["phx-value-keys"], '["a","outside","b"]');
root.dataset.selectedKeys = '["a","outside","b"]';
table.sync();
assert.equal(selectAll.checked, true);
selectAll.checked = false;
table.selectionChange({ target: selectAll });
assert.deepEqual(root.dispatched.at(-1).detail.keys, ["outside"]);
root.dataset.selectedKeys = '["b"]';
table.sync();
assert.equal(a.input.checked, false);
assert.equal(b.input.checked, true);
assert.equal(selectAll.indeterminate, true);
a.input.checked = true;
table.selectionChange({ target: a.input });
assert.equal(a.input.checked, false, "input is restored until LiveView responds");
assert.deepEqual(root.dispatched.at(-1).detail.keys, ["b", "a"]);
root.dataset.selectionMode = "single";
b.input.checked = false;
table.selectionChange({ target: b.input });
assert.deepEqual(root.dispatched.at(-1).detail.keys, []);

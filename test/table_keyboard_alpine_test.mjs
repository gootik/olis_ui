import assert from "node:assert/strict";
import { registerOlisTable } from "../assets/js/alpine/table.js";
let factory;
registerOlisTable({
  data(_name, value) {
    factory = value;
  },
});
globalThis.document = {
  activeElement: null,
  body: {},
  hasFocus: () => true,
  addEventListener() {},
  removeEventListener() {},
};
globalThis.getComputedStyle = () => ({ direction: "ltr", visibility: "visible" });
const table = {
  tabIndex: 0,
  controls: [],
  headers: [],
  closest: () => table,
  querySelectorAll(selector) {
    return selector === "thead th" ? this.headers : this.controls;
  },
};
const root = {
  isConnected: true,
  dataset: { selectionMode: "multiple", selectedKeys: "[]", controlled: "false" },
  dataRows: [],
  querySelectorAll(selector) {
    return selector === "[data-olis-table-row]" ? this.dataRows : [];
  },
  querySelector(selector) {
    return selector === "table" ? table : null;
  },
};
function makeNode(kind, row = null) {
  return {
    kind,
    row,
    tabIndex: 0,
    attrs: {},
    isConnected: true,
    closest(selector) {
      if (selector === "table") {
        return table;
      }
      if (selector === "[data-olis-table]") {
        return root;
      }
      if (selector === "[data-olis-table-row]") {
        return this.row || (this.kind === "row" ? this : null);
      }
      if (selector === "th, td, tr") {
        return this;
      }
      return null;
    },
    matches(selector) {
      return selector === "td, th" && this.kind === "cell";
    },
    getAttribute(key) {
      return this.attrs[key] ?? null;
    },
    setAttribute(key, value) {
      this.attrs[key] = String(value);
    },
    removeAttribute(key) {
      delete this.attrs[key];
    },
    querySelector() {
      return null;
    },
    focus() {
      document.activeElement = this;
    },
  };
}
function makeRow(key) {
  const row = makeNode("row");
  row.id = key;
  row.dataset = { key };
  row.children = [makeNode("cell", row), makeNode("cell", row)];
  return row;
}
const first = makeRow("one"),
  second = makeRow("two");
const headerA = makeNode("header"),
  headerB = makeNode("header");
table.headers = [headerA, headerB];
root.dataRows = [first, second];
const grid = factory();
grid.$root = root;
grid.init();
assert.equal(table.tabIndex, 0);
assert.equal(first.tabIndex, -1);
grid.focusIn({ target: table });
assert.equal(document.activeElement, first);
assert.equal(first.tabIndex, 0);
function press(key, target = document.activeElement, extra = {}) {
  const event = {
    key,
    target,
    preventDefault() {
      this.defaultPrevented = true;
    },
    ...extra,
  };
  grid.keyDown(event);
  return event;
}
press("ArrowDown");
assert.equal(document.activeElement, second);
press("ArrowRight");
assert.equal(document.activeElement, second.children[0]);
press("ArrowRight");
assert.equal(document.activeElement, second.children[1]);
press("ArrowUp");
assert.equal(document.activeElement, first.children[1]);
press("ArrowUp");
assert.equal(document.activeElement, headerB);
press("Home");
assert.equal(document.activeElement, headerA);
press("ArrowDown");
assert.equal(document.activeElement, first.children[0]);
press("ArrowLeft");
assert.equal(document.activeElement, first);
press("End");
assert.equal(document.activeElement, second);
press("Home", document.activeElement, { ctrlKey: true });
assert.equal(document.activeElement, first);
// Inserting a streamed row before the focused row keeps the same roving target.
const added = makeRow("new");
root.dataRows.unshift(added);
grid.sync();
assert.equal(first.tabIndex, 0);
assert.equal(added.tabIndex, -1);
// A LiveView patch can replace a focused header. Focus is restored to its replacement.
grid.focusNode(headerB);
grid.focusIn({ target: headerB });
const replacedHeader = makeNode("header");
table.headers = [headerA, replacedHeader];
document.activeElement = document.body;
grid.sync();
assert.equal(document.activeElement, replacedHeader);
// Multiple controls in one cell can all be reached without adding extra grid tab stops.
const cell = second.children[1];
function control() {
  const input = makeNode("input", second);
  input.closest = (selector) =>
    selector === "table" ? table : selector === "th, td" ? cell : null;
  input.matches = () => false;
  input.getClientRects = () => [1];
  return input;
}
const a = control(),
  b = control(),
  c = control();
cell.querySelectorAll = () => [a, b, c];
cell.contains = () => false;
table.controls = [a, b, c];
// An outer dialog around the entire table does not make its cell controls inaccessible.
const outerDialog = {};
for (const node of [a, b, c]) {
  const closest = node.closest;
  node.closest = (selector) => (selector.includes("[popover]") ? outerDialog : closest(selector));
}
grid.sync();
grid.focusNode(cell);
press("Enter");
assert.equal(document.activeElement, a);
press("Tab");
assert.equal(document.activeElement, b);
press("Tab");
assert.equal(document.activeElement, c);
press("Tab", c, { shiftKey: true });
assert.equal(document.activeElement, b);
press("Escape");
assert.equal(document.activeElement, cell);
// Native text inputs retain their arrow keys instead of grid navigation.
const input = makeNode("input", first);
input.closest = (selector) =>
  selector === "table" ? table : selector === "th, td, tr" ? first.children[0] : null;
const inputEvent = press("ArrowDown", input);
assert.equal(inputEvent.defaultPrevented, undefined);
grid.destroy();
assert.equal(first.getAttribute("tabindex"), null);
console.log("Table keyboard row/cell/header navigation and stream focus passed");

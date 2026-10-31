import assert from "node:assert/strict";
import { registerOlisTabs } from "../assets/js/alpine/tabs.js";

let createTabs;
registerOlisTabs({
  data(_name, factory) {
    createTabs = factory;
  },
});

const root = { dataset: { selectedKey: "first" } };
const first = { dataset: { key: "first" }, disabled: false, closest: () => root };
const second = { dataset: { key: "second" }, disabled: false, closest: () => root };
const changeEvent = {
  setAttribute(name, value) {
    this[name] = value;
  },
  click() {
    this.clicked = true;
  },
};
const list = {
  querySelectorAll: () => [first, second],
  contains: () => false,
};
const tabs = createTabs();
Object.assign(tabs, {
  $root: root,
  $refs: { list, changeEvent },
  $dispatch() {},
  selected: "first",
  focused: "first",
});

tabs.select("second");
assert.equal(tabs.selected, "first", "selection waits for LiveView");
assert.equal(changeEvent["phx-value-key"], "second");
assert.equal(changeEvent.clicked, true);

root.dataset.selectedKey = "second";
globalThis.document = { activeElement: null };
tabs.updateScroll = () => {};
tabs.sync();
assert.equal(tabs.selected, "second", "selection follows the LiveView update");

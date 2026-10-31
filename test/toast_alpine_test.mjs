import assert from "node:assert/strict";
import { registerOlisToastRegion } from "../assets/js/alpine/toast_region.js";

globalThis.window = new EventTarget();
globalThis.CSS = { escape: (value) => value };
globalThis.document = { hidden: true, activeElement: null, hasFocus: () => true };
const button = {
  attrs: {},
  setAttribute(name, value) {
    this.attrs[name] = value;
  },
  click() {
    this.clicked = true;
  },
};
const region = {
  id: "notices",
  dataset: { toasts: "[]", timeout: "4000", gap: "12", maxVisible: "3", indicators: "[]" },
  querySelector(selector) {
    return selector === ":scope > [data-olis-toast-dismiss]" ? button : null;
  },
};
let create;
registerOlisToastRegion({
  data(_name, factory) {
    create = factory;
  },
});
const queue = create();
queue.$root = region;
queue.$nextTick = (callback) => callback();
queue.init();

region.dataset.toasts = JSON.stringify([{ id: "save", title: "Saving", is_loading: true }]);
queue.sync();
assert.equal(queue.items[0].data.title, "Saving");
assert.equal(queue.items[0].remaining, null);
queue.close(queue.items[0]);
assert.equal(button.attrs["phx-value-id"], "save");
assert.equal(button.attrs["phx-value-reason"], "dismiss");
assert.equal(queue.items[0].exiting, false, "dismissal waits for LiveView");

region.dataset.toasts = JSON.stringify([
  { id: "save", title: "Saved", variant: "success", is_loading: false },
]);
queue.sync();
assert.equal(queue.items[0].data.title, "Saved");
assert.equal(queue.items[0].remaining, 4000);
const setTimer = globalThis.setTimeout;
let timeoutCallback;
globalThis.setTimeout = (callback) => {
  timeoutCallback = callback;
  return 1;
};
document.hidden = false;
queue.start(queue.items[0]);
timeoutCallback();
assert.equal(button.attrs["phx-value-reason"], "timeout");
assert.equal(queue.items[0].exiting, false, "timeout also waits for LiveView");
timeoutCallback = null;
queue.sync();
assert.equal(timeoutCallback, null, "a rejected timeout is not retried on unrelated updates");
document.hidden = true;
globalThis.setTimeout = setTimer;
region.dataset.toasts = JSON.stringify([
  { id: "second", title: "Second", timeout: 0 },
  { id: "save", title: "Saved", variant: "success", is_loading: false },
]);
queue.sync();
assert.deepEqual(
  queue.items.map((item) => item.id),
  ["second", "save"],
);
region.dataset.toasts = JSON.stringify([
  { id: "save", title: "Saved", variant: "success", is_loading: false },
  { id: "second", title: "Second", timeout: 0 },
]);
queue.sync();
assert.deepEqual(
  queue.items.map((item) => item.id),
  ["save", "second"],
);
region.dataset.toasts = "[]";
queue.sync();
assert.equal(queue.items[0].exiting, true, "the server removes the toast");
queue.destroy();

import assert from "node:assert/strict";
import { createPopupState } from "../assets/js/alpine/popup_state.js";

const sent = [];
const button = {
  attrs: {},
  setAttribute(name, value) {
    this.attrs[name] = value;
  },
  click() {
    sent.push({ ...this.attrs });
  },
};
const field = { dataset: { open: "false" }, querySelector: () => button };
const popup = {
  open: false,
  matches: () => popup.open,
  showPopover() {
    this.open = true;
  },
  hidePopover() {
    this.open = false;
  },
};
const state = createPopupState();
state.request(field, true, "focus");
assert.equal(state.desired(field), true);
state.request(field, true, "input");
assert.equal(sent.length, 1, "duplicate requests are suppressed");
assert.equal(popup.open, false, "opening waits for LiveView");
state.request(field, false, "blur");
assert.equal(state.desired(field), false);
assert.equal(sent.length, 2, "a close is sent even before the open is accepted");
field.dataset.open = "true";
state.sync(field, popup, false);
assert.equal(popup.open, true);
field.dataset.open = "false";
state.sync(field, popup, false);
assert.equal(popup.open, false);

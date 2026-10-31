import assert from "node:assert/strict";
const { registerOlisUIAlpine } = await import("../assets/js/alpine.js");
const providers = {};
registerOlisUIAlpine({
  data(name, factory) {
    providers[name] = factory;
  },
});
let reduced = false;
globalThis.window = {
  matchMedia() {
    return { matches: reduced };
  },
};
globalThis.getComputedStyle = (element) => ({ transform: element.style.transform || "none" });
let pending = [],
  closes = 0;
const dialog = {
  id: "settings",
  open: false,
  dataset: { placement: "right", dismissible: "true" },
  offsetWidth: 300,
  offsetHeight: 400,
  style: {
    transform: "",
    removeProperty(name) {
      if (name === "transform") {
        this.transform = "";
      }
    },
  },
  captured: null,
  setPointerCapture(id) {
    this.captured = id;
  },
  hasPointerCapture(id) {
    return this.captured === id;
  },
  releasePointerCapture(id) {
    if (this.captured === id) {
      this.captured = null;
    }
  },
  dispatchEvent() {},
  querySelector() {
    return null;
  },
  showModal() {
    this.open = true;
  },
  close() {
    this.open = false;
    closes++;
  },
  getBoundingClientRect() {
    return { left: 20, top: 20, right: 100, bottom: 100 };
  },
  animate(keyframes, options) {
    let resolve, reject;
    const finished = new Promise((yes, no) => {
      resolve = yes;
      reject = no;
    });
    const animation = {
      keyframes,
      options,
      finished,
      resolve,
      cancel() {
        reject(new Error("cancelled"));
      },
    };
    pending.push(animation);
    return animation;
  },
};
const drawer = providers.olisDrawer();
drawer.$root = dialog;
const trigger = {
  getAttribute() {
    return "settings";
  },
  matches() {
    return false;
  },
};
const event = {
  target: {
    closest() {
      return trigger;
    },
  },
};
drawer.openFromTrigger(event);
assert.equal(dialog.open, true);
assert.equal(pending[0].keyframes[0].transform, "translateX(100%)");
assert.equal(pending[1].options.pseudoElement, "::backdrop");
assert.equal(pending[0].options.duration, 250);
drawer.close();
assert.equal(dialog.open, true, "native dialog remains modal while exiting");
assert.equal(pending[2].options.duration, 200);
assert.equal(pending[2].keyframes[1].transform, "translateX(100%)");
pending[2].resolve();
await Promise.resolve();
assert.equal(dialog.open, false);
assert.equal(closes, 1);
drawer.openFromTrigger(event);
drawer.close();
drawer.openFromTrigger(event); // A reopened drawer must not be closed by a stale animation.
await Promise.resolve();
assert.equal(dialog.open, true);
reduced = true;
drawer.close();
assert.equal(dialog.open, false, "reduced motion closes immediately");
pending = [];
drawer.openFromTrigger(event);
assert.equal(pending.length, 0, "reduced motion does not animate");
dialog.dataset.dismissible = "false";
drawer.onCancel();
assert.equal(dialog.open, true);
const close = {
  closest() {
    return dialog;
  },
};
drawer.onClick({
  target: {
    closest() {
      return close;
    },
  },
});
assert.equal(dialog.open, false, "explicit close still works");

// A controlled swipe requests closure without closing until LiveView accepts it.
dialog.dataset.dismissible = "true";
dialog.dataset.controlled = "true";
dialog.open = true;
const events = [];
dialog.dispatchEvent = (event) => events.push(event.detail);
const zone = {
  closest() {
    return dialog;
  },
};
const target = {
  closest(selector) {
    return selector === "[data-olis-drawer-drag]" ? zone : null;
  },
};
const pointer = (x) => ({
  target,
  button: 0,
  pointerId: 7,
  clientX: x,
  clientY: 0,
  preventDefault() {},
});
drawer.pointerDown(pointer(0));
drawer.pointerMove(pointer(120));
drawer.pointerUp(pointer(120));
assert.equal(dialog.open, true, "controlled swipe waits for the server");
assert.equal(dialog.style.transform, "", "rejected swipe returns to rest");
assert.deepEqual(events, [{ open: false, reason: "swipe" }]);
assert.equal(dialog.captured, null, "pointer capture is released");
dialog.dataset.controlledOpen = "false";
drawer.sync();
assert.equal(dialog.open, false, "server acceptance closes the drawer");

// Cancelled gestures always return to rest without dispatching a close.
dialog.dataset.controlled = "false";
dialog.open = true;
events.length = 0;
drawer.pointerDown(pointer(0));
drawer.pointerMove(pointer(120));
drawer.pointerCancel(pointer(120));
assert.equal(dialog.open, true);
assert.equal(dialog.style.transform, "");
assert.deepEqual(events, []);
const interactive = {
  closest(selector) {
    return selector === "[data-olis-drawer-drag]" ? zone : this;
  },
};
drawer.pointerDown({ ...pointer(0), target: interactive });
assert.equal(drawer.drag, null, "interactive descendants do not start dragging");
console.log("Drawer backdrop and motion checks passed");

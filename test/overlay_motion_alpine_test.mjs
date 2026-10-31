import assert from "node:assert/strict";
import { registerOlisDialog } from "../assets/js/alpine/dialog.js";
import { registerOlisPopover } from "../assets/js/alpine/popover.js";

const providers = {};
registerOlisDialog({
  data(name, factory) {
    providers[name] = factory;
  },
});
registerOlisPopover({
  data(name, factory) {
    providers[name] = factory;
  },
});
let reduce = false;
globalThis.window = {
  matchMedia(query) {
    return { matches: query.includes("prefers-reduced-motion") && reduce };
  },
};
globalThis.CustomEvent = class {
  constructor(type, options) {
    this.type = type;
    Object.assign(this, options);
  }
};
const made = [];
const dialog = {
  open: false,
  dataset: { controlled: "false", placement: "bottom" },
  classList: { contains: () => false },
  hasAttribute: (name) => name === "data-olis-modal",
  closest: () => null,
  showModal() {
    this.open = true;
  },
  close() {
    this.open = false;
  },
  querySelector: () => null,
  dispatchEvent() {},
  animate(frames, options) {
    const { promise, resolve, reject } = Promise.withResolvers();
    const animation = {
      frames,
      options,
      finished: promise,
      resolve,
      cancel() {
        reject(new Error("cancelled"));
      },
    };
    made.push(animation);
    return animation;
  },
};
const modal = providers.olisDialog();
modal.$root = dialog;
modal.init();
modal.request(true, "trigger");
assert.equal(dialog.open, true);
assert.equal(made[0].options.duration, 250);
assert.match(made[0].frames[0].transform, /0.25rem/);
modal.request(false, "close");
assert.equal(dialog.open, true, "native dialog stays open during its exit");
assert.equal(modal.closing, true);
assert.equal(made[2].options.duration, 100);
modal.request(true, "trigger");
assert.equal(dialog.open, true);
assert.equal(modal.closing, false, "reopening cancels a pending exit");
modal.request(false, "close");
made[4].resolve();
await Promise.resolve();
assert.equal(dialog.open, false, "the native dialog closes after the panel animation");
reduce = true;
modal.request(true, "trigger");
modal.request(false, "close");
assert.equal(dialog.open, false, "reduced motion closes immediately");
modal.destroy();

const content = { dataset: {}, closest: () => null, matches: () => false };
const popover = providers.olisPopover();
popover.$refs = { content };
reduce = false;
popover.beforeToggle({ target: content, newState: "open" });
assert.equal(content.dataset.entering, "true");
popover.beforeToggle({ target: content, newState: "closed" });
assert.equal(content.dataset.entering, undefined);
assert.equal(content.dataset.exiting, "true");
popover.animationEnd({ target: {}, animationName: "olis-overlay-exit" });
assert.equal(content.dataset.exiting, "true", "nested animations cannot clear overlay state");
popover.animationEnd({ target: content, animationName: "olis-overlay-exit" });
assert.equal(content.dataset.exiting, undefined);
reduce = true;
popover.beforeToggle({ target: content, newState: "open" });
assert.equal(content.dataset.entering, undefined);
popover.destroy();
console.log("Overlay motion exit, interruption and reduced-motion checks passed");

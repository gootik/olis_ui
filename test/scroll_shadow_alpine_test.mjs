import assert from "node:assert/strict";
import { registerOlisUIAlpine } from "../assets/js/alpine.js";
const providers = {};
registerOlisUIAlpine({
  data(name, factory) {
    providers[name] = factory;
  },
});
let frame = null;
globalThis.requestAnimationFrame = (fn) => {
  frame = fn;
  return 1;
};
globalThis.cancelAnimationFrame = () => {
  frame = null;
};
const flush = () => {
  const fn = frame;
  frame = null;
  fn?.();
};
const resizeObservers = [],
  mutationObservers = [];
globalThis.ResizeObserver = class {
  constructor(callback) {
    this.callback = callback;
    this.nodes = new Set();
    this.disconnected = false;
    resizeObservers.push(this);
  }
  observe(node) {
    this.nodes.add(node);
  }
  unobserve(node) {
    this.nodes.delete(node);
  }
  disconnect() {
    this.nodes.clear();
    this.disconnected = true;
  }
};
globalThis.MutationObserver = class {
  constructor(callback) {
    this.callback = callback;
    this.disconnected = false;
    mutationObservers.push(this);
  }
  observe(root, options) {
    this.root = root;
    this.options = options;
  }
  disconnect() {
    this.disconnected = true;
  }
};
globalThis.CustomEvent = class {
  constructor(type, options) {
    this.type = type;
    Object.assign(this, options);
  }
};
const attrs = {},
  events = [],
  sent = [];
const eventButton = {
  setAttribute(name, value) {
    this[name] = value;
  },
  click() {
    sent.push(this["phx-value-visibility"]);
  },
};
const first = {},
  second = {};
const root = {
  isConnected: true,
  dataset: { orientation: "vertical", scrollShadowMode: "auto", scrollShadowOffset: "0" },
  children: [first],
  scrollHeight: 300,
  clientHeight: 100,
  scrollTop: 0,
  scrollWidth: 400,
  clientWidth: 100,
  scrollLeft: 0,
  setAttribute(name, value) {
    attrs[name] = value;
  },
  removeAttribute(name) {
    delete attrs[name];
  },
  dispatchEvent(event) {
    events.push(event);
  },
  querySelector() {
    return eventButton;
  },
};
const shadow = providers.olisScrollShadow();
shadow.$root = root;
shadow.$nextTick = (fn) => fn();
shadow.init();
flush();
assert.equal(attrs["data-bottom-scroll"], "true");
assert.equal(events.length, 0, "initial measurement does not emit");
assert.ok(resizeObservers[0].nodes.has(first));
root.scrollTop = 60;
shadow.schedule();
shadow.schedule();
flush();
assert.equal(attrs["data-top-bottom-scroll"], "true");
assert.equal(events.at(-1).type, "olis:scroll-shadow-change");
assert.equal(events.at(-1).detail.visibility, "both");
assert.deepEqual(sent, ["both"]);
root.scrollTop = 200;
resizeObservers[0].callback([]);
flush();
assert.equal(attrs["data-top-scroll"], "true");
root.children = [second];
mutationObservers[0].callback([]);
flush();
assert.ok(!resizeObservers[0].nodes.has(first));
assert.ok(resizeObservers[0].nodes.has(second));
root.dataset.orientation = "horizontal";
root.dataset.scrollShadowMode = "manual";
root.dataset.scrollShadowVisibility = "both";
shadow.schedule();
flush();
assert.equal(attrs["data-left-right-scroll"], "true");
root.dataset.scrollShadowMode = "auto";
root.scrollLeft = -30;
shadow.schedule();
flush();
assert.equal(attrs["data-left-right-scroll"], "true");
assert.deepEqual(sent, ["both", "top"], "entering auto from manual resets the baseline");
shadow.schedule();
shadow.destroy();
assert.equal(frame, null);
assert.equal(resizeObservers[0].disconnected, true);
assert.equal(mutationObservers[0].disconnected, true);
// ResizeObserver and MutationObserver are optional; LiveView and scroll events still schedule measurement.
delete globalThis.ResizeObserver;
delete globalThis.MutationObserver;
const fallback = providers.olisScrollShadow();
fallback.$root = root;
fallback.$nextTick = (fn) => fn();
fallback.init();
flush();
assert.equal(root.dataset.olisScrollShadowCurrent, "both");
fallback.destroy();

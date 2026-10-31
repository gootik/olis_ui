import assert from 'node:assert/strict';
import {registerHeroToolbar} from '../assets/js/alpine/toolbar.js';

let factory;
registerHeroToolbar({data(_name, make) { factory = make; }});
let mutation, resize;
globalThis.MutationObserver = class {
  constructor(callback) { this.callback = callback; this.targets = []; mutation = this; }
  observe(target, options) { this.targets.push({target, options}); }
  disconnect() { this.disconnected = true; }
};
globalThis.ResizeObserver = class {
  constructor(callback) { this.callback = callback; this.targets = new Set(); resize = this; }
  observe(target) { this.targets.add(target); }
  unobserve(target) { this.targets.delete(target); }
  disconnect() { this.disconnected = true; this.targets.clear(); }
};
globalThis.document = {activeElement: null};
globalThis.getComputedStyle = element => ({visibility: element.visible ? 'visible' : 'hidden', direction: 'ltr'});
const parent = {parentElement: null};
const root = {parentElement: parent, dataset: {}, items: [], querySelectorAll(selector) {
  return selector === '[aria-disabled="true"]' ? [] : this.items;
}};
function button(name) {
  return {
    name, visible: true, isConnected: true, tabIndex: 0, attrs: {},
    closest(selector) { return selector === '[data-hero-toolbar]' ? root : null; },
    matches() { return false; },
    getClientRects() { return this.visible && !parent.hidden ? [1] : []; },
    getAttribute(key) { return key === 'tabindex' ? (Object.hasOwn(this.attrs, key) ? this.attrs[key] : null) : null; },
    setAttribute(key, value) { this.attrs[key] = String(value); if (key === 'tabindex') this.tabIndex = Number(value); },
    removeAttribute(key) { delete this.attrs[key]; }
  };
}
const one = button('one'), two = button('two'); root.items = [one, two];
const toolbar = factory(); toolbar.$root = root; toolbar.init();
assert.deepEqual([one.tabIndex, two.tabIndex], [0, -1]);
assert.ok(mutation.targets.find(t => t.target === root).options.attributeFilter.includes('class'));
assert.ok(mutation.targets.find(t => t.target === parent).options.attributeFilter.includes('style'));
assert.ok(resize.targets.has(root) && resize.targets.has(one) && resize.targets.has(two));
one.visible = false; mutation.callback();
assert.equal(two.tabIndex, 0, 'hiding the active control transfers the tab stop');
one.visible = true; mutation.callback();
assert.deepEqual([one.tabIndex, two.tabIndex], [-1, 0], 'revealing a control preserves one tab stop');
two.visible = false; resize.callback();
assert.equal(one.tabIndex, 0, 'responsive visibility changes transfer the tab stop');
root.items = [one]; two.isConnected = false; mutation.callback();
assert.ok(!resize.targets.has(two), 'removed controls are no longer observed');
toolbar.destroy();
assert.ok(mutation.disconnected && resize.disconnected);
assert.ok(!Object.hasOwn(one.attrs, 'tabindex'), 'destroy restores the original tabindex');
console.log('Toolbar visibility changes, resize and cleanup passed');

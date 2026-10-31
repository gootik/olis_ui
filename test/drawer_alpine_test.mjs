import assert from 'node:assert/strict';
const {registerHeroUIAlpine} = await import('../assets/js/alpine.js');
const providers = {};
registerHeroUIAlpine({data(name, factory) { providers[name] = factory; }});
let reduced = false;
globalThis.window = {matchMedia() {return {matches: reduced};}};
let pending = [], closes = 0;
const dialog = {
  id: 'settings', open: false, dataset: {placement:'right', dismissible:'true'},
  showModal() {this.open = true;}, close() {this.open = false; closes++;},
  getBoundingClientRect() {return {left:20, top:20, right:100, bottom:100};},
  animate(keyframes, options) {
    let resolve, reject;
    const finished = new Promise((yes, no) => {resolve = yes; reject = no;});
    const animation = {keyframes, options, finished, resolve, cancel() {reject(new Error('cancelled'));}};
    pending.push(animation);
    return animation;
  }
};
const drawer = providers.heroDrawer(); drawer.$root = dialog;
const trigger = {getAttribute() {return 'settings';}, matches() {return false;}};
const event = {target: {closest() {return trigger;}}};
drawer.openFromTrigger(event);
assert.equal(dialog.open, true);
assert.equal(pending[0].keyframes[0].transform, 'translateX(100%)');
assert.equal(pending[1].options.pseudoElement, '::backdrop');
assert.equal(pending[0].options.duration, 250);
drawer.close();
assert.equal(dialog.open, true, 'native dialog remains modal while exiting');
assert.equal(pending[2].options.duration, 200);
assert.equal(pending[2].keyframes[1].transform, 'translateX(100%)');
pending[2].resolve(); await Promise.resolve();
assert.equal(dialog.open, false);
assert.equal(closes, 1);
drawer.openFromTrigger(event); drawer.close();
drawer.openFromTrigger(event); // A reopened drawer must not be closed by a stale animation.
await Promise.resolve(); assert.equal(dialog.open, true);
reduced = true; drawer.close(); assert.equal(dialog.open, false, 'reduced motion closes immediately');
pending = []; drawer.openFromTrigger(event); assert.equal(pending.length, 0, 'reduced motion does not animate');
dialog.dataset.dismissible = 'false'; drawer.onCancel(); assert.equal(dialog.open, true);
const close = {closest() {return dialog;}};
drawer.onClick({target: {closest() {return close;}}}); assert.equal(dialog.open, false, 'explicit close still works');
console.log('Drawer backdrop and motion checks passed');

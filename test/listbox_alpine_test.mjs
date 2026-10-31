import assert from 'node:assert/strict';
import {registerHeroUIAlpine} from '../assets/js/alpine.js';
const providers = {};
registerHeroUIAlpine({data(name, factory) {providers[name] = factory;}});
const root = {isConnected:true, attrs:{}, options:[], focused:false,
  querySelectorAll() {return this.options;}, getAttribute(name) {return this.attrs[name] ?? null;},
  setAttribute(name,value) {this.attrs[name]=String(value);}, removeAttribute(name) {delete this.attrs[name];},
  closest() {return this;}, focus() {this.focused=true;}};
function item(id, label, disabled=false, selected=false, owner=root) {
  return {id, dataset:{}, clicks:0, scrolled:false, attrs:{'aria-disabled':String(disabled), 'aria-selected':String(selected)},
    getAttribute(name) {return this.attrs[name] ?? null;}, closest(selector) {return selector==='[data-hero-listbox]'?owner:this;},
    querySelector() {return {textContent:label};}, scrollIntoView() {this.scrolled=true;}, click() {this.clicks++;}};
}
const alpha=item('a','Alpha'), disabled=item('b','Beta',true), charlie=item('c','Charlie',false,true), nested=item('x','Nested',false,false,{});
root.options=[alpha,disabled,charlie,nested];
const listbox=providers.heroListbox(); listbox.$root=root; listbox.$nextTick=fn=>fn(); listbox.init();
assert.equal(root.attrs['aria-activedescendant'],'c');
assert.equal(charlie.dataset.active,'true'); assert.equal(nested.dataset.active,undefined);
function key(key) {let prevented=false; listbox.keydown({target:root,key,preventDefault(){prevented=true;}}); return prevented;}
assert.equal(key('ArrowDown'),true); assert.equal(root.attrs['aria-activedescendant'],'a');
assert.equal(key('ArrowUp'),true); assert.equal(root.attrs['aria-activedescendant'],'c');
assert.equal(key('Home'),true); assert.equal(root.attrs['aria-activedescendant'],'a');
assert.equal(key('End'),true); assert.equal(root.attrs['aria-activedescendant'],'c');
assert.equal(key('a'),true); assert.equal(root.attrs['aria-activedescendant'],'a'); assert.equal(alpha.scrolled,true);
assert.equal(key('Enter'),true); assert.equal(alpha.clicks,1, 'selection remains owned by the LiveView click');
listbox.click({target:disabled}); assert.equal(root.attrs['aria-activedescendant'],'a');
listbox.click({target:charlie}); assert.equal(root.attrs['aria-activedescendant'],'c'); assert.equal(root.focused,true);
root.options=[alpha,disabled]; root.attrs['aria-activedescendant']='removed'; alpha.attrs['aria-selected']='true'; listbox.sync(); assert.equal(root.attrs['aria-activedescendant'],'a');
alpha.attrs['aria-disabled']='true'; listbox.sync(); assert.equal(root.attrs['aria-activedescendant'],undefined); assert.equal(alpha.dataset.active,'false');
root.attrs['aria-disabled']='true'; assert.equal(key('ArrowDown'),false); listbox.click({target:alpha}); assert.equal(root.attrs['aria-activedescendant'],undefined);
console.log('Listbox Alpine keyboard, selection, disabled and LiveView reconciliation checks passed');

import assert from 'node:assert/strict';
import { toast, toastPromise, updateToast, dismissToast, heroToastRegion } from '../assets/js/toast.js';

globalThis.window = new EventTarget();
globalThis.CSS = {escape: value => value};
const region = {id: 'notices', dataset: {timeout: '4000', gap: '12', maxVisible: '3', indicators: '["star"]'}, querySelector() {return null;}};
globalThis.document = {hidden: true, activeElement: null, hasFocus() {return true;}, querySelector() {return region;}};
const queue = heroToastRegion();
queue.$root = region;
queue.$nextTick = callback => callback();
queue.init();
window.addEventListener('hero:toast', event => queue.show(event.detail));
window.addEventListener('hero:toast-update', event => queue.update(event.detail));
window.addEventListener('hero:toast-close', event => queue.closeEvent(event.detail));
const item = id => queue.items.find(value => value.id === id && !value.exiting);
const flush = async () => {await Promise.resolve(); await Promise.resolve();};

const id = toast.promise(Promise.resolve({name: 'File'}), {loading: 'Uploading', success: value => `${value.name} saved`, error: 'Failed'}, {region: 'notices'});
assert.equal(item(id).data.isLoading, true);
assert.equal(item(id).remaining, null);
await flush();
assert.equal(item(id).data.title, 'File saved');
assert.equal(item(id).data.variant, 'success');
assert.equal(item(id).data.isLoading, false);
assert.equal(item(id).remaining, 4000);

const failed = toastPromise(Promise.reject(new Error('network')), {loading: 'Sending', success: 'Done', error: error => error.message}, {region: 'notices', timeout: 0});
await flush();
assert.equal(item(failed).data.title, 'network');
assert.equal(item(failed).data.variant, 'danger');
assert.equal(item(failed).remaining, null);

let firstResolve, secondResolve;
const messages = {loading: 'Working', success: value => value, error: 'Failed'};
toast.promise(new Promise(resolve => {firstResolve = resolve;}), messages, {id: 'reused', region: 'notices'});
toast.promise(new Promise(resolve => {secondResolve = resolve;}), messages, {id: 'reused', region: 'notices'});
firstResolve('Old'); await flush();
assert.equal(item('reused').data.title, 'Working', 'older promise cannot overwrite a reused ID');
secondResolve('New'); await flush();
assert.equal(item('reused').data.title, 'New');

let manualResolve;
const manual = toast.promise(new Promise(resolve => {manualResolve = resolve;}), messages, {region: 'notices'});
updateToast(manual, {region: 'notices', title: 'Manually completed', variant: 'success'});
assert.equal(item(manual).data.isLoading, false);
assert.equal(item(manual).remaining, 4000);
manualResolve('Late result'); await flush();
assert.equal(item(manual).data.title, 'Manually completed', 'manual completion invalidates the pending update');

let dismissedResolve;
const dismissed = toast.promise(new Promise(resolve => {dismissedResolve = resolve;}), messages, {region: 'notices'});
dismissToast(dismissed, 'notices'); dismissedResolve('Too late'); await flush();
assert.equal(item(dismissed), undefined, 'a dismissed promise toast is not recreated');

const loading = toast.loading('Saving', {region: 'notices'});
assert.equal(item(loading).remaining, null);
assert.equal(queue.loading(item(loading)), true);
updateToast(loading, {region: 'notices', isLoading: false, title: 'Saved'});
assert.equal(item(loading).remaining, 4000);
assert.equal(queue.customIndicator({data: {indicator: 'star'}}), true);
assert.equal(queue.customIndicator({data: {indicator: 'unknown'}}), false);
queue.destroy();
console.log('Toast promise, loading, stale updates and indicators passed');

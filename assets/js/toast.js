/** Toast events are plain text; they can be sent by LiveView or by these helpers. */
let nextToastId = 0;
export function toast(title, options = {}) {
  const id = String(options.id ?? `toast-${Date.now()}-${++nextToastId}`);
  window.dispatchEvent(new CustomEvent('hero:toast', {detail:{...options, title, id}}));
  return id;
}
export function updateToast(id, options = {}) { window.dispatchEvent(new CustomEvent('hero:toast-update', {detail:{...options, id:String(id)}})); }
export function dismissToast(id, region) { window.dispatchEvent(new CustomEvent('hero:toast-close', {detail:{id:String(id), region}})); }
export function clearToasts(region) { window.dispatchEvent(new CustomEvent('hero:toast-clear', {detail:{region}})); }

/** Show one persistent toast while a promise settles, returning its toast ID. */
export function toastPromise(work, messages, options = {}) {
  if (!messages || typeof messages.loading !== 'string' || !messages.loading.trim() ||
      !['string', 'function'].includes(typeof messages.success) || !['string', 'function'].includes(typeof messages.error)) {
    throw new TypeError('toast.promise requires loading, success and error messages');
  }
  const token = `promise-${Date.now()}-${++nextToastId}`;
  const id = toast(messages.loading, {...options, isLoading:true, timeout:0, __heroPromiseToken:token});
  const text = (value, result, fallback) => {
    try {
      const message = typeof value === 'function' ? value(result) : value;
      return typeof message === 'string' && message.trim() ? message : fallback;
    } catch (_) { return fallback; }
  };
  const settle = (variant, title) => updateToast(id, {
    region:options.region, title, variant, isLoading:false, __heroIfPromiseToken:token,
    ...(Object.prototype.hasOwnProperty.call(options, 'timeout') ? {timeout:options.timeout} : {})
  });
  let promise;
  try { promise = typeof work === 'function' ? work() : work; }
  catch (error) { promise = Promise.reject(error); }
  Promise.resolve(promise).then(
    result => settle('success', text(messages.success, result, 'Completed')),
    error => settle('danger', text(messages.error, error, 'Something went wrong'))
  );
  return id;
}
toast.promise = toastPromise;
toast.loading = (title, options = {}) => toast(title, {...options, isLoading:true, timeout:options.timeout ?? 0});

const icons = {
  info:'M8 13.5a5.5 5.5 0 1 0 0-11a5.5 5.5 0 0 0 0 11M8 15A7 7 0 1 0 8 1a7 7 0 0 0 0 14m1-9.5a1 1 0 1 1-2 0a1 1 0 0 1 2 0m-.25 3a.75.75 0 0 0-1.5 0V11a.75.75 0 0 0 1.5 0z',
  success:'M13.5 8a5.5 5.5 0 1 1-11 0a5.5 5.5 0 0 1 11 0M15 8A7 7 0 1 1 1 8a7 7 0 0 1 14 0m-3.9-1.55a.75.75 0 1 0-1.2-.9L7.419 8.858L6.03 7.47a.75.75 0 0 0-1.06 1.06l2 2a.75.75 0 0 0 1.13-.08z',
  warning:'M7.134 2.994L2.217 11.5a1 1 0 0 0 .866 1.5h9.834a1 1 0 0 0 .866-1.5L8.866 2.993a1 1 0 0 0-1.732 0m3.03-.75c-.962-1.665-3.366-1.665-4.329 0L.918 10.749c-.963 1.666.24 3.751 2.165 3.751h9.834c1.925 0 3.128-2.085 2.164-3.751zM8 5a.75.75 0 0 1 .75.75v2a.75.75 0 0 1-1.5 0v-2A.75.75 0 0 1 8 5m1 5.75a1 1 0 1 1-2 0a1 1 0 0 1 2 0',
  danger:'M8 13.5a5.5 5.5 0 1 0 0-11a5.5 5.5 0 0 0 0 11M8 15A7 7 0 1 0 8 1a7 7 0 0 0 0 14m1-4.5a1 1 0 1 1-2 0a1 1 0 0 1 2 0M8.75 5a.75.75 0 0 0-1.5 0v2.5a.75.75 0 0 0 1.5 0z',
};

/** Per-region queue; Alpine renders the keyed toast nodes in the server template. */
export function heroToastRegion() {
  let region, tick, active = true;
  return {
    items: [], serial: 0, hover: false, focused: false, lastFocus: null,
    init() { region=this.$root; tick=this.$nextTick; },
    accepts(detail = {}) {
      return detail.region ? detail.region === region.id : document.querySelector('[data-hero-toast-region]') === region;
    },
    element(item) { return region.querySelector(`[data-toast-uid="${CSS.escape(item.uid)}"]`); },
    iconPath(variant) { return icons[variant] || icons.info; },
    variant(value) { return ['default','accent','success','warning','danger'].includes(value) ? value : 'default'; },
    loading(item) { return item.data.isLoading === true || item.data.is_loading === true; },
    customIndicator(item) {
      try { return typeof item.data.indicator === 'string' && JSON.parse(region.dataset.indicators || '[]').includes(item.data.indicator); }
      catch (_) { return false; }
    },
    actionCommand(item) {
      const action=item.data.action || {};
      if (typeof action.event !== 'string' || !/^[\w:.-]+$/.test(action.event)) return null;
      const value=Object.create(null);
      if (action.params && typeof action.params === 'object') for (const [key,param] of Object.entries(action.params)) {
        if (/^[a-zA-Z0-9_-]+$/.test(key) && ['string','number','boolean'].includes(typeof param)) value[key]=String(param);
      }
      return JSON.stringify([["push",{event:action.event,value}]]);
    },
    style(item) {
      return {'--offset-collapsed':`${item.collapsed || 0}px`,'--offset-expanded':`${item.offset || 0}px`,
        '--scale-collapsed':String(item.scale ?? 1),'--front-height':`${item.frontHeight || 0}px`,
        '--toast-height':`${item.height || 0}px`,zIndex:item.z || 1};
    },
    paused() { return this.hover || this.focused || document.hidden || !document.hasFocus(); },
    pause(item) {
      if (item.timer) { clearTimeout(item.timer); item.timer=null; item.remaining=Math.max(0,item.remaining-(performance.now()-item.started)); }
    },
    start(item) {
      if (item.exiting || item.remaining == null || item.timer || this.paused()) return;
      item.started=performance.now();
      item.timer=setTimeout(() => { item.timer=null; this.close(item,'timeout'); },Math.max(0,item.remaining));
    },
    reconcile() { this.items.forEach(item => this.paused() ? this.pause(item) : this.start(item)); },
    layout() {
      const active=this.items.filter(item=>!item.exiting), expanded=region.dataset.expanded === 'true' || this.hover || this.focused;
      const gap=Math.max(0,Number(region.dataset.gap) || 0), max=Math.max(1,Number(region.dataset.maxVisible) || 3);
      const heights=active.map(item => {
        const el=this.element(item); if (!el) return 0;
        el.style.height='auto'; const height=el.offsetHeight; el.style.removeProperty('height'); return height;
      });
      const front=heights[0] || 0; let before=0;
      active.forEach((item,index) => {
        Object.assign(item,{index,expanded,hidden:index>=max,collapsed:index*gap,offset:before+index*gap,
          scale:Math.max(0,1-index*0.05),frontHeight:front,height:heights[index],z:active.length-index});
        before+=heights[index];
      });
    },
    show(detail) {
      if (!detail || typeof detail.title !== 'string' || !detail.title.trim() || !this.accepts(detail)) return;
      const id=String(detail.id ?? `toast-${Date.now()}-${++nextToastId}`), previous=this.items.find(item=>item.id===id && !item.exiting);
      if (previous) { this.update({...detail,id}); return; }
      const timeout=Number(detail.timeout ?? ((detail.isLoading === true || detail.is_loading === true) ? 0 : region.dataset.timeout));
      const item={id,uid:`${region.id}-toast-${++this.serial}`,data:{...detail},remaining:Number.isFinite(timeout) && timeout>0 ? timeout : null,
        timer:null,entering:true,exiting:false,index:0,hidden:false,expanded:false};
      this.items.unshift(item);
      const current=this.items[0];
      tick(() => {
        if (!active || !this.element(current)) return;
        this.layout();
        requestAnimationFrame(() => requestAnimationFrame(() => { current.entering=false; }));
        this.start(current);
      });
    },
    update(detail) {
      if (!detail || !this.accepts(detail)) return;
      const item=this.items.find(x=>x.id===String(detail.id) && !x.exiting); if (!item) return;
      if (Object.prototype.hasOwnProperty.call(detail,'__heroIfPromiseToken') && detail.__heroIfPromiseToken !== item.data.__heroPromiseToken) return;
      const focused=this.element(item)?.contains(document.activeElement);
      const wasLoading=this.loading(item), next={...item.data,...detail};
      if (!Object.prototype.hasOwnProperty.call(detail,'__heroIfPromiseToken') &&
          !Object.prototype.hasOwnProperty.call(detail,'__heroPromiseToken') &&
          (typeof detail.title === 'string' || Object.prototype.hasOwnProperty.call(detail,'isLoading') || Object.prototype.hasOwnProperty.call(detail,'is_loading'))) delete next.__heroPromiseToken;
      delete next.__heroIfPromiseToken;
      if (Object.prototype.hasOwnProperty.call(detail,'isLoading')) next.is_loading = false;
      else if (Object.prototype.hasOwnProperty.call(detail,'is_loading')) next.isLoading = false;
      else if (wasLoading && typeof detail.title === 'string' && detail.title !== item.data.title) { next.isLoading=false; next.is_loading=false; }
      item.data=next;
      if (Object.prototype.hasOwnProperty.call(detail,'timeout') || (wasLoading && !this.loading(item))) {
        this.pause(item); const timeout=Number(Object.prototype.hasOwnProperty.call(detail,'timeout') ? detail.timeout : region.dataset.timeout);
        item.remaining=Number.isFinite(timeout) && timeout>0 ? timeout : null;
      }
      tick(() => { if (!active) return; this.layout(); if (focused) this.element(item)?.focus({preventScroll:true}); this.start(item); });
    },
    close(item,reason='dismiss') {
      if (!item || item.exiting) return;
      this.pause(item); const el=this.element(item); item.exiting=true;
      if (el?.contains(document.activeElement)) {
        const other=this.items.find(x=>x!==item && !x.exiting && !x.hidden);
        (this.element(other || {}) || (this.lastFocus?.isConnected && this.lastFocus) || region).focus({preventScroll:true});
      }
      tick(() => { if (active) this.layout(); });
      item.removeTimer=setTimeout(() => { if (!active) return; this.items=this.items.filter(x=>x.uid!==item.uid); tick(() => { if (active) this.layout(); }); },250);
      window.dispatchEvent(new CustomEvent('hero:toast-closed',{detail:{id:item.id,region:region.id,reason}}));
    },
    closeEvent(detail) { if (this.accepts(detail || {})) this.close(this.items.find(x=>x.id===String(detail?.id)),'dismiss'); },
    clearEvent(detail) { if (this.accepts(detail || {})) this.items.forEach(item=>this.close(item,'clear')); },
    action(item) {
      window.dispatchEvent(new CustomEvent('hero:toast-action',{detail:{id:item.id,region:region.id}}));
      if (item.data.action?.close_on_action !== false) setTimeout(()=>{ if (active) this.close(item,'action'); },0);
    },
    pointerEnter(event) { if (event.pointerType === 'touch' || this.hover) return; this.hover=true; this.layout(); this.reconcile(); },
    pointerLeave(event) { if (event.pointerType === 'touch') return; this.hover=false; this.layout(); this.reconcile(); },
    focusIn(event) { if (!region.contains(event.relatedTarget)) this.lastFocus=event.relatedTarget; this.focused=true; this.layout(); this.reconcile(); },
    focusOut(event) { if (region.contains(event.relatedTarget)) return; this.focused=false; this.layout(); this.reconcile(); },
    keydown(event) {
      if (event.altKey && !event.ctrlKey && !event.metaKey && !event.shiftKey && event.code === 'KeyT') {
        const first=[...document.querySelectorAll('[data-hero-toast-region]')].find(el=>el.querySelector('[data-hero-toast]:not([data-exiting])'));
        if (first === region) { event.preventDefault(); this.lastFocus=document.activeElement; region.focus(); }
      } else if (event.key === 'Escape' && event.target instanceof Node && region.contains(event.target)) {
        // Match HeroUI: collapse the stack and release focus without dismissing a toast.
        if (region.contains(document.activeElement)) document.activeElement.blur();
        this.hover=false; this.focused=false; this.layout(); this.reconcile();
      }
    },
    destroy() { active=false; this.items.forEach(item=>{ this.pause(item); clearTimeout(item.removeTimer); }); this.items=[]; }
  };
}

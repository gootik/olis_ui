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

export function installToast(root = document) {
  const states = new Map(); let serial = 0;
  const paths = {
    info:'M8 13.5a5.5 5.5 0 1 0 0-11a5.5 5.5 0 0 0 0 11M8 15A7 7 0 1 0 8 1a7 7 0 0 0 0 14m1-9.5a1 1 0 1 1-2 0a1 1 0 0 1 2 0m-.25 3a.75.75 0 0 0-1.5 0V11a.75.75 0 0 0 1.5 0z',
    success:'M13.5 8a5.5 5.5 0 1 1-11 0a5.5 5.5 0 0 1 11 0M15 8A7 7 0 1 1 1 8a7 7 0 0 1 14 0m-3.9-1.55a.75.75 0 1 0-1.2-.9L7.419 8.858L6.03 7.47a.75.75 0 0 0-1.06 1.06l2 2a.75.75 0 0 0 1.13-.08z',
    warning:'M7.134 2.994L2.217 11.5a1 1 0 0 0 .866 1.5h9.834a1 1 0 0 0 .866-1.5L8.866 2.993a1 1 0 0 0-1.732 0m3.03-.75c-.962-1.665-3.366-1.665-4.329 0L.918 10.749c-.963 1.666.24 3.751 2.165 3.751h9.834c1.925 0 3.128-2.085 2.164-3.751zM8 5a.75.75 0 0 1 .75.75v2a.75.75 0 0 1-1.5 0v-2A.75.75 0 0 1 8 5m1 5.75a1 1 0 1 1-2 0a1 1 0 0 1 2 0',
    danger:'M8 13.5a5.5 5.5 0 1 0 0-11a5.5 5.5 0 0 0 0 11M8 15A7 7 0 1 0 8 1a7 7 0 0 0 0 14m1-4.5a1 1 0 1 1-2 0a1 1 0 0 1 2 0M8.75 5a.75.75 0 0 0-1.5 0v2.5a.75.75 0 0 0 1.5 0z',
    close:'M3.47 3.47a.75.75 0 0 1 1.06 0L8 6.94l3.47-3.47a.75.75 0 1 1 1.06 1.06L9.06 8l3.47 3.47a.75.75 0 1 1-1.06 1.06L8 9.06l-3.47 3.47a.75.75 0 0 1-1.06-1.06L6.94 8 3.47 4.53a.75.75 0 0 1 0-1.06Z'
  };
  function node(tag, className, text) { const el = document.createElement(tag); if (className) el.className = className; if (text != null) el.textContent = String(text); return el; }
  function icon(type) { const svg=document.createElementNS('http://www.w3.org/2000/svg','svg'), path=document.createElementNS('http://www.w3.org/2000/svg','path'); svg.setAttribute('viewBox','0 0 16 16'); svg.setAttribute('width','16'); svg.setAttribute('height','16'); svg.setAttribute('aria-hidden','true'); svg.dataset.slot=type === 'close' ? 'close-button-icon' : 'toast-default-icon'; path.setAttribute('d',paths[type] || paths.info); path.setAttribute('fill','currentColor'); path.setAttribute('fill-rule','evenodd'); path.setAttribute('clip-rule','evenodd'); svg.appendChild(path); return svg; }
  function stateFor(region) {
    if (!states.has(region)) states.set(region,{region,items:[],hover:false,focus:false,lastFocus:null});
    return states.get(region);
  }
  function regions() { return [...root.querySelectorAll('[data-hero-toast-region]')]; }
  function selectedRegion(detail) { const all=regions(); return detail.region ? all.find(el => el.id === detail.region) : all[0]; }
  function paused(state) { return state.hover || state.focus || document.hidden || !document.hasFocus(); }
  function pauseItem(item) { if (item.timer) { clearTimeout(item.timer); item.timer=null; item.remaining=Math.max(0,item.remaining-(performance.now()-item.started)); } }
  function startItem(state,item) { if (item.exiting || item.remaining == null || item.timer || paused(state)) return; item.started=performance.now(); item.timer=setTimeout(() => { item.timer=null; close(state,item,'timeout'); },Math.max(0,item.remaining)); }
  function reconcileTimers(state) { state.items.forEach(item => paused(state) ? pauseItem(item) : startItem(state,item)); }
  function itemContent(item) {
    const {el,data,uid}=item, variant=['default','accent','success','warning','danger'].includes(data.variant) ? data.variant : 'default';
    el.className=`toast toast--${item.state.region.dataset.placement} toast--${variant}`; el.replaceChildren();
    if (data.indicator !== false) { const indicator=node('div','toast__indicator'); indicator.dataset.slot='toast-indicator'; indicator.appendChild(icon(variant === 'success' || variant === 'warning' || variant === 'danger' ? variant : 'info')); el.appendChild(indicator); }
    const content=node('div','toast__content'); content.dataset.slot='toast-content'; content.setAttribute('role','alert'); content.setAttribute('aria-atomic','true');
    const title=node('span','toast__title',data.title); title.id=`${uid}-title`; title.dataset.slot='toast-title'; content.appendChild(title); el.setAttribute('aria-labelledby',title.id);
    if (data.description) { const description=node('span','toast__description',data.description); description.id=`${uid}-description`; description.dataset.slot='toast-description'; content.appendChild(description); el.setAttribute('aria-describedby',description.id); } else el.removeAttribute('aria-describedby');
    el.appendChild(content);
    if (data.action?.label) {
      const action=node('button','button button--md button--tertiary toast__action',data.action.label); action.type='button'; action.dataset.slot='toast-action-button'; action.dataset.heroToastAction='';
      if (typeof data.action.event === 'string' && /^[\w:.-]+$/.test(data.action.event)) action.setAttribute('phx-click',data.action.event);
      if (data.action.params && typeof data.action.params === 'object') Object.entries(data.action.params).forEach(([key,value]) => { if (/^[a-zA-Z0-9_-]+$/.test(key) && ['string','number','boolean'].includes(typeof value)) action.setAttribute(`phx-value-${key}`,String(value)); });
      el.appendChild(action);
    }
    const closeButton=node('button','close-button close-button--default toast__close-button'); closeButton.type='button'; closeButton.dataset.slot='toast-close'; closeButton.dataset.heroToastClose=''; closeButton.setAttribute('aria-label','Close'); closeButton.appendChild(icon('close')); el.appendChild(closeButton);
  }
  function layout(state) {
    const active=state.items.filter(item=>!item.exiting), expanded=state.region.dataset.expanded === 'true' || state.hover || state.focus, gap=Math.max(0,Number(state.region.dataset.gap) || 0), max=Math.max(1,Number(state.region.dataset.maxVisible) || 3);
    const heights=active.map(item => { item.el.style.height='auto'; const height=item.el.offsetHeight; item.el.style.removeProperty('height'); return height; });
    const front=heights[0] || 0; let before=0;
    active.forEach((item,index) => {
      const el=item.el, hidden=index >= max; el.dataset.index=String(index); el.dataset.frontmost=String(index===0); el.dataset.placement=state.region.dataset.placement;
      if (expanded) el.dataset.expanded='true'; else delete el.dataset.expanded;
      if (hidden) { el.dataset.hidden='true'; el.setAttribute('aria-hidden','true'); el.inert=true; } else { delete el.dataset.hidden; el.removeAttribute('aria-hidden'); el.inert=false; }
      el.tabIndex = !hidden && (index===0 || expanded) ? 0 : -1;
      el.style.setProperty('--offset-collapsed',`${index*gap}px`); el.style.setProperty('--offset-expanded',`${before+index*gap}px`); el.style.setProperty('--scale-collapsed',String(Math.max(0,1-index*0.05)));
      el.style.setProperty('--front-height',`${front}px`); el.style.setProperty('--toast-height',`${heights[index]}px`); el.style.zIndex=String(active.length-index); before+=heights[index];
    });
  }
  function close(state,item,reason='dismiss') {
    if (!item || item.exiting) return;
    pauseItem(item); item.exiting=true; item.el.dataset.exiting='true';
    if (item.el.contains(document.activeElement)) { const other=state.items.find(x=>x!==item && !x.exiting && !x.el.inert); (other?.el || (state.lastFocus?.isConnected && state.lastFocus) || state.region).focus({preventScroll:true}); }
    item.el.setAttribute('aria-hidden','true'); item.el.inert=true;
    layout(state); item.removeTimer=setTimeout(() => { item.li.remove(); state.items=state.items.filter(x=>x!==item); layout(state); },250);
    window.dispatchEvent(new CustomEvent('hero:toast-closed',{detail:{id:item.id,region:state.region.id,reason}}));
  }
  function show(detail) {
    if (!detail || typeof detail.title !== 'string' || !detail.title.trim()) return;
    const region=selectedRegion(detail); if (!region) return;
    const state=stateFor(region), id=String(detail.id ?? `toast-${Date.now()}-${++nextToastId}`), previous=state.items.find(item=>item.id===id && !item.exiting);
    if (previous) { update({...detail,id}); return; }
    const li=node('li'); li.style.display='contents'; const el=node('div','toast'); el.dataset.slot='toast'; el.dataset.heroToast=''; el.setAttribute('role','alertdialog'); el.setAttribute('aria-modal','false'); li.appendChild(el);
    const item={id,uid:`${region.id}-toast-${++serial}`,li,el,data:{...detail},state,remaining:null,timer:null,exiting:false}; itemContent(item); state.items.unshift(item); region.querySelector('[data-hero-toast-list]').prepend(li);
    const timeout=Number(detail.timeout ?? region.dataset.timeout); item.remaining=Number.isFinite(timeout) && timeout > 0 ? timeout : null;
    el.dataset.entering='true'; layout(state); requestAnimationFrame(() => requestAnimationFrame(() => { if (el.isConnected) delete el.dataset.entering; })); startItem(state,item);
  }
  function update(detail) {
    const region=selectedRegion(detail || {}), state=region && states.get(region), item=state?.items.find(x=>x.id===String(detail.id) && !x.exiting); if (!item) return;
    const focused=item.el.contains(document.activeElement); item.data={...item.data,...detail}; itemContent(item); if (focused) item.el.focus({preventScroll:true});
    if (Object.prototype.hasOwnProperty.call(detail,'timeout')) { pauseItem(item); const timeout=Number(detail.timeout); item.remaining=Number.isFinite(timeout) && timeout > 0 ? timeout : null; }
    layout(state); startItem(state,item);
  }
  function onToast(event) { show(event.detail); }
  function onUpdate(event) { update(event.detail); }
  function onCloseEvent(event) { const region=selectedRegion(event.detail || {}), state=region && states.get(region); if (state) close(state,state.items.find(x=>x.id===String(event.detail?.id)),'dismiss'); }
  function onClear(event) { const region=selectedRegion(event.detail || {}), state=region && states.get(region); state?.items.forEach(item=>close(state,item,'clear')); }
  function onClick(event) {
    const button=event.target.closest?.('[data-hero-toast-close], [data-hero-toast-action]'), el=button?.closest('[data-hero-toast]'), region=el?.closest('[data-hero-toast-region]'), state=region && states.get(region), item=state?.items.find(x=>x.el===el); if (!item) return;
    if (button.hasAttribute('data-hero-toast-close')) close(state,item,'dismiss');
    else { window.dispatchEvent(new CustomEvent('hero:toast-action',{detail:{id:item.id,region:region.id}})); if (item.data.action?.close_on_action !== false) setTimeout(()=>close(state,item,'action'),0); }
  }
  function onPointerOver(event) { const region=event.target.closest?.('[data-hero-toast-region]'), state=region && states.get(region); if (!state || region.contains(event.relatedTarget) || event.pointerType === 'touch') return; state.hover=true; layout(state); reconcileTimers(state); }
  function onPointerOut(event) { const region=event.target.closest?.('[data-hero-toast-region]'), state=region && states.get(region); if (!state || region.contains(event.relatedTarget) || event.pointerType === 'touch') return; state.hover=false; layout(state); reconcileTimers(state); }
  function onFocusIn(event) { const region=event.target.closest?.('[data-hero-toast-region]'), state=region && states.get(region); if (!state) return; if (!region.contains(event.relatedTarget)) state.lastFocus=event.relatedTarget; state.focus=true; layout(state); reconcileTimers(state); }
  function onFocusOut(event) { const region=event.target.closest?.('[data-hero-toast-region]'), state=region && states.get(region); if (!state || region.contains(event.relatedTarget)) return; state.focus=false; layout(state); reconcileTimers(state); }
  function onKeyDown(event) {
    if (event.altKey && !event.ctrlKey && !event.metaKey && !event.shiftKey && event.code === 'KeyT') { const region=regions().find(el=>states.get(el)?.items.some(item=>!item.exiting)); if (region) { event.preventDefault(); stateFor(region).lastFocus=document.activeElement; region.focus(); } }
    else if (event.key === 'Escape') { const el=event.target.closest?.('[data-hero-toast]'), region=el?.closest('[data-hero-toast-region]'), state=region && states.get(region); if (state) { event.preventDefault(); close(state,state.items.find(item=>item.el===el),'dismiss'); } }
  }
  function syncAll() { for (const [region,state] of states) if (!region.isConnected) { state.items.forEach(item=>{pauseItem(item); clearTimeout(item.removeTimer);}); states.delete(region); } }
  function onVisibility() { states.forEach(reconcileTimers); }
  function onResize() { states.forEach(layout); }
  ['hero:toast','phx:hero:toast'].forEach(name=>window.addEventListener(name,onToast)); ['hero:toast-update','phx:hero:toast-update'].forEach(name=>window.addEventListener(name,onUpdate)); ['hero:toast-close','phx:hero:toast-close'].forEach(name=>window.addEventListener(name,onCloseEvent)); ['hero:toast-clear','phx:hero:toast-clear'].forEach(name=>window.addEventListener(name,onClear));
  root.addEventListener('click',onClick); root.addEventListener('pointerover',onPointerOver); root.addEventListener('pointerout',onPointerOut); root.addEventListener('focusin',onFocusIn); root.addEventListener('focusout',onFocusOut); root.addEventListener('keydown',onKeyDown); document.addEventListener('phx:update',syncAll); document.addEventListener('visibilitychange',onVisibility); window.addEventListener('focus',onVisibility); window.addEventListener('blur',onVisibility); window.addEventListener('resize',onResize);
  return () => { ['hero:toast','phx:hero:toast'].forEach(name=>window.removeEventListener(name,onToast)); ['hero:toast-update','phx:hero:toast-update'].forEach(name=>window.removeEventListener(name,onUpdate)); ['hero:toast-close','phx:hero:toast-close'].forEach(name=>window.removeEventListener(name,onCloseEvent)); ['hero:toast-clear','phx:hero:toast-clear'].forEach(name=>window.removeEventListener(name,onClear)); root.removeEventListener('click',onClick); root.removeEventListener('pointerover',onPointerOver); root.removeEventListener('pointerout',onPointerOut); root.removeEventListener('focusin',onFocusIn); root.removeEventListener('focusout',onFocusOut); root.removeEventListener('keydown',onKeyDown); document.removeEventListener('phx:update',syncAll); document.removeEventListener('visibilitychange',onVisibility); window.removeEventListener('focus',onVisibility); window.removeEventListener('blur',onVisibility); window.removeEventListener('resize',onResize); states.forEach(state=>state.items.forEach(item=>{pauseItem(item); clearTimeout(item.removeTimer); item.li.remove();})); states.clear(); };
}

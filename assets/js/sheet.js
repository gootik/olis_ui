/** Native modal sheets with pointer dragging and optional LiveView-controlled state. */
export function installSheet(root = document) {
  const selector='dialog[data-hero-sheet]', states=new Map(), stack=[];
  let addedScrollLock=false;
  const sheets=()=>root.querySelectorAll(selector);
  const parts=sheet=>({content:sheet.querySelector(':scope > [data-hero-sheet-content]'),backdrop:sheet.querySelector(':scope > [data-hero-sheet-backdrop]'),handle:sheet.querySelector(':scope > [data-hero-sheet-content] [data-hero-sheet-handle]'),body:sheet.querySelector(':scope > [data-hero-sheet-content] [data-hero-sheet-body]'),event:sheet.querySelector(':scope > [data-hero-sheet-event]')});
  const reduced=()=>window.matchMedia?.('(prefers-reduced-motion: reduce)').matches;
  const horizontal=sheet=>['left','right'].includes(sheet.dataset.placement);
  const outward=sheet=>['top','left'].includes(sheet.dataset.placement) ? -1 : 1;
  const axis=sheet=>horizontal(sheet) ? 'X' : 'Y';
  function notify(sheet,open,reason) {
    sheet.dispatchEvent(new CustomEvent('hero:sheet-open-change',{bubbles:true,detail:{open,reason}}));
    const button=parts(sheet).event; if (button) { button.setAttribute('phx-value-open',String(open)); button.setAttribute('phx-value-reason',reason); button.click(); }
  }
  function parsePoints(sheet) { try { const values=JSON.parse(sheet.dataset.snapPointsJson || '[]'); return Array.isArray(values) ? values : []; } catch (_) { return []; } }
  function lengthInPixels(point,full,content) {
    if (typeof point==='number') return point;
    const match=/^(\d+(?:\.\d+)?)(px|%|vh|vw|rem|em)$/.exec(point); if (!match) return 0;
    const amount=Number(match[1]);
    switch (match[2]) {
      case '%': return full*amount/100;
      case 'vh': return innerHeight*amount/100;
      case 'vw': return innerWidth*amount/100;
      case 'rem': return parseFloat(getComputedStyle(document.documentElement).fontSize)*amount;
      case 'em': return parseFloat(getComputedStyle(content).fontSize)*amount;
      default: return amount;
    }
  }
  function geometry(sheet) {
    const {content}=parts(sheet), rect=content.getBoundingClientRect(), full=horizontal(sheet) ? rect.width : rect.height;
    let points=parsePoints(sheet); const last=points.at(-1);
    if (last===1 || last==='1' || last==='100%') points=points.slice(0,-1);
    const entries=points.map((point,index)=>({index,value:Math.max(0,Math.min(full,lengthInPixels(point,full,content)))})).filter(entry=>entry.value>0 && entry.value<full-0.5);
    const resolved=entries.map(entry=>entry.value);
    return {full,entries,points:resolved,stops:[...new Set([...resolved,full])].sort((a,b)=>a-b)};
  }
  function updateStack() {
    for (let i=stack.length-1;i>=0;i--) if (!stack[i].open) stack.splice(i,1);
    for (const sheet of document.querySelectorAll(selector)) if (sheet.open && !stack.includes(sheet)) stack.push(sheet);
    if (stack.length && !document.documentElement.classList.contains('overflow-hidden')) { document.documentElement.classList.add('overflow-hidden'); addedScrollLock=true; }
    else if (!stack.length && addedScrollLock) { document.documentElement.classList.remove('overflow-hidden'); addedScrollLock=false; }
    stack.forEach((sheet,index)=>{ const {backdrop}=parts(sheet); if (backdrop) backdrop.dataset.stackIndex=String(index); sheet.dataset.sheetNested=String(index>0); });
  }
  function apply(sheet,distance) {
    const state=states.get(sheet), {content,backdrop}=parts(sheet), {full,points,entries}=geometry(sheet);
    if (!state || !content || full<=0) return;
    state.full=full; state.entries=entries;
    state.distance=Math.max(0,Math.min(full,distance));
    content.style.transform=`translate${axis(sheet)}(${outward(sheet)*state.distance}px)`;
    if (state.distance<=0.5) content.dataset.expanded='true'; else delete content.dataset.expanded;
    if (backdrop) {
      const last=points.length ? Math.max(...points) : full, visible=full-state.distance;
      backdrop.style.opacity=String(points.length ? Math.max(0,Math.min(1,(visible-last)/Math.max(1,full-last))) : 1);
    }
  }
  function animateTo(sheet,distance,done) {
    const state=states.get(sheet), {content}=parts(sheet); if (!state || !content) return;
    state.animation?.cancel(); const from=state.distance || 0; apply(sheet,distance);
    if (!content.animate || reduced() || Math.abs(from-distance)<0.5) { state.animation=null; done?.(); return; }
    const sign=outward(sheet), a=axis(sheet), animation=content.animate([{transform:`translate${a}(${sign*from}px)`},{transform:`translate${a}(${sign*state.distance}px)`}],{duration:220,easing:'cubic-bezier(.32,.72,0,1)'});
    state.animation=animation; animation.finished.then(()=>{ if (state.animation===animation) { state.animation=null; done?.(); } }).catch(()=>{});
  }
  function show(sheet) {
    const state=states.get(sheet), {content}=parts(sheet); if (!state || !content || sheet.open) return;
    state.animation?.cancel(); sheet.showModal(); updateStack();
    const {full,points}=geometry(sheet), visible=points[0] ?? full; state.distance=full;
    apply(sheet,full); animateTo(sheet,full-visible);
    sheet.querySelectorAll(selector).forEach(sync);
  }
  function closeDescendants(sheet) {
    for (const child of [...sheet.querySelectorAll(selector)].reverse()) {
      if (!child.open) continue;
      const state=states.get(child); if (state) { state.animation?.cancel(); state.animation=null; state.closing=false; }
      child.close(); notify(child,false,'parent');
    }
  }
  function hide(sheet) {
    const state=states.get(sheet); if (!state || !sheet.open || state.closing) return;
    state.closing=true; closeDescendants(sheet); const {full}=geometry(sheet);
    animateTo(sheet,full,()=>{ state.closing=false; if (sheet.open) sheet.close(); updateStack(); });
  }
  function request(sheet,open,reason) {
    const state=states.get(sheet); if (!state) return;
    if (sheet.dataset.controlled==='true') { notify(sheet,open,reason); return; }
    if (open && !sheet.open) { show(sheet); notify(sheet,true,reason); }
    else if (!open && sheet.open && !state.closing) { hide(sheet); notify(sheet,false,reason); }
  }
  function sync(sheet) {
    if (!parts(sheet).content) return;
    let state=states.get(sheet);
    if (!state) { state={distance:0,drag:null,animation:null,closing:false,initialized:false,configuration:null}; states.set(sheet,state); }
    const parent=sheet.parentElement?.closest(selector); if (parent && (!parent.open || states.get(parent)?.closing)) return;
    const configuration=[sheet.dataset.placement,sheet.dataset.snapPointsJson,parts(sheet).content.hasAttribute('data-detached')].join('|');
    if (state.configuration && state.configuration!==configuration && sheet.open && !state.closing) {
      state.animation?.cancel(); state.animation=null; const {full,points}=geometry(sheet); apply(sheet,full-(points[0] ?? full));
    }
    state.configuration=configuration;
    if (!state.initialized) { state.initialized=true; if (sheet.dataset.controlled==='true' ? sheet.dataset.controlledOpen==='true' : sheet.dataset.defaultOpen==='true') show(sheet); }
    else if (sheet.dataset.controlled==='true') {
      if (sheet.dataset.controlledOpen==='true' && !sheet.open) show(sheet);
      else if (sheet.dataset.controlledOpen==='true' && sheet.open && state.closing) { state.closing=false; state.animation?.cancel(); state.animation=null; animateTo(sheet,0); }
      else if (sheet.dataset.controlledOpen!=='true' && sheet.open) hide(sheet);
    }
  }
  function onClick(event) {
    const opener=event.target.closest?.('[data-hero-sheet-open]');
    if (opener && root.contains(opener)) { const id=opener.getAttribute('data-hero-sheet-open'),sheet=document.getElementById(id); if (sheet?.matches(selector) && root.contains(sheet)) { sync(sheet); request(sheet,true,'trigger'); } return; }
    const closer=event.target.closest?.('[data-hero-sheet-close]');
    if (closer && root.contains(closer)) { const sheet=closer.closest(selector); if (sheet) request(sheet,false,'close'); return; }
    const backdrop=event.target.closest?.('[data-hero-sheet-backdrop]'),sheet=backdrop?.parentElement;
    if (sheet?.matches(selector) && sheet.dataset.dismissible==='true') request(sheet,false,'backdrop');
  }
  function onCancel(event) { const sheet=event.target; if (!sheet.matches?.(selector)) return; event.preventDefault(); if (sheet.dataset.dismissible==='true') request(sheet,false,'escape'); }
  function onClose(event) {
    const sheet=event.target, state=states.get(sheet); if (!state) return;
    closeDescendants(sheet);
    state.drag=null; state.touch=null; state.closing=false; state.animation?.cancel(); state.animation=null; const {content,handle}=parts(sheet); if (content) content.style.removeProperty('transform'); if (handle) delete handle.dataset.dragging; updateStack();
  }
  function onPointerDown(event) {
    const handle=event.target.closest?.('[data-hero-sheet-handle]'); if (!handle || !root.contains(handle) || (event.pointerType==='mouse' && event.button!==0)) return;
    const sheet=handle.closest(selector), state=states.get(sheet); if (!state || !sheet.open || state.closing) return;
    event.preventDefault(); state.animation?.cancel(); state.animation=null; const coordinate=horizontal(sheet) ? event.clientX : event.clientY;
    state.drag={id:event.pointerId,start:coordinate,previous:coordinate,time:performance.now(),velocity:0,initial:state.distance}; handle.dataset.dragging='true'; handle.setPointerCapture(event.pointerId);
  }
  function onPointerMove(event) {
    const handle=event.target.closest?.('[data-hero-sheet-handle]'); if (!handle) return;
    const sheet=handle.closest(selector),state=states.get(sheet),drag=state?.drag; if (!drag || drag.id!==event.pointerId) return;
    event.preventDefault(); const coordinate=horizontal(sheet) ? event.clientX : event.clientY, now=performance.now(), delta=outward(sheet)*(coordinate-drag.start);
    drag.velocity=outward(sheet)*(coordinate-drag.previous)/Math.max(1,now-drag.time); drag.previous=coordinate; drag.time=now; apply(sheet,drag.initial+delta);
  }
  function finishDrag(event,cancelled=false) {
    const handle=event.target.closest?.('[data-hero-sheet-handle]'); if (!handle) return;
    const sheet=handle.closest(selector),state=states.get(sheet),drag=state?.drag; if (!drag || drag.id!==event.pointerId) return;
    state.drag=null; delete handle.dataset.dragging; if (handle.hasPointerCapture(event.pointerId)) handle.releasePointerCapture(event.pointerId);
    settleDrag(sheet,drag,cancelled);
  }
  function settleDrag(sheet,drag,cancelled) {
    const state=states.get(sheet);
    const {full,stops}=geometry(sheet), current=full-state.distance;
    if (!cancelled && sheet.dataset.dismissible==='true' && (current<Math.min(full*0.6,stops[0]*0.5) || (drag.velocity>0.7 && state.distance>20))) {
      if (sheet.dataset.controlled==='true') { notify(sheet,false,'swipe'); animateTo(sheet,drag.initial); }
      else request(sheet,false,'swipe');
      return;
    }
    const projected=cancelled ? full-drag.initial : current-drag.velocity*120;
    const nearest=stops.reduce((best,point)=>Math.abs(point-projected)<Math.abs(best-projected) ? point : best,stops[0]);
    animateTo(sheet,full-nearest);
  }
  function onTouchStart(event) {
    if (event.touches.length!==1 || event.target.closest?.('[data-hero-sheet-handle], button, a, input, textarea, select, [contenteditable="true"]')) return;
    const body=event.target.closest?.('[data-hero-sheet-body]'), sheet=body?.closest(selector), state=states.get(sheet);
    if (!sheet || !state || !sheet.open || state.closing || !root.contains(sheet)) return;
    const touch=event.touches[0], coordinate=horizontal(sheet) ? touch.clientX : touch.clientY, cross=horizontal(sheet) ? touch.clientY : touch.clientX;
    state.touch={id:touch.identifier,start:coordinate,cross,previous:coordinate,time:performance.now(),velocity:0,initial:state.distance,body,target:event.target,mode:null};
  }
  function canScrollOutward(target,body,sheet) {
    if (horizontal(sheet)) return false;
    for (let node=target; node && body.contains(node); node=node.parentElement) {
      const max=node.scrollHeight-node.clientHeight, overflow=getComputedStyle(node).overflowY;
      if (max>0.5 && /auto|scroll/.test(overflow) && (outward(sheet)>0 ? node.scrollTop>0.5 : node.scrollTop<max-0.5)) return true;
      if (node===body) break;
    }
    return false;
  }
  function onTouchMove(event) {
    const body=event.target.closest?.('[data-hero-sheet-body]'),sheet=body?.closest(selector),state=states.get(sheet),drag=state?.touch; if (!drag) return;
    const touch=[...event.changedTouches].find(item=>item.identifier===drag.id); if (!touch) return;
    const coordinate=horizontal(sheet) ? touch.clientX : touch.clientY, cross=horizontal(sheet) ? touch.clientY : touch.clientX;
    const delta=outward(sheet)*(coordinate-drag.start), crossDelta=Math.abs(cross-drag.cross);
    if (!drag.mode) {
      if (Math.abs(delta)<5 && crossDelta<5) return;
      if (crossDelta>Math.abs(delta)) { drag.mode='scroll'; return; }
      const expanded=state.distance<=0.5;
      if (expanded && (delta<0 || canScrollOutward(drag.target,body,sheet))) { drag.mode='scroll'; return; }
      drag.mode='drag'; state.animation?.cancel(); state.animation=null;
    }
    if (drag.mode!=='drag') return;
    event.preventDefault(); const now=performance.now(); drag.velocity=outward(sheet)*(coordinate-drag.previous)/Math.max(1,now-drag.time); drag.previous=coordinate; drag.time=now; apply(sheet,drag.initial+delta);
  }
  function finishTouch(event,cancelled=false) {
    const body=event.target.closest?.('[data-hero-sheet-body]'),sheet=body?.closest(selector),state=states.get(sheet),drag=state?.touch; if (!drag) return;
    if (![...event.changedTouches].some(item=>item.identifier===drag.id)) return;
    state.touch=null; if (drag.mode==='drag') settleDrag(sheet,drag,cancelled);
  }
  function onTouchEnd(event) { finishTouch(event); }
  function onTouchCancel(event) { finishTouch(event,true); }
  function onResize() {
    for (const [sheet,state] of states) {
      if (!sheet.open || state.drag || state.touch || state.closing) continue;
      state.animation?.cancel(); state.animation=null;
      const oldVisible=(state.full || 0)-state.distance, oldEntries=[...(state.entries || []),{index:-1,value:state.full || 0}];
      const selected=oldEntries.reduce((best,entry)=>Math.abs(entry.value-oldVisible)<Math.abs(best.value-oldVisible) ? entry : best,oldEntries[0]);
      const {full,entries}=geometry(sheet), visible=selected.index===-1 ? full : (entries.find(entry=>entry.index===selected.index)?.value ?? full);
      apply(sheet,full-visible);
    }
  }
  function onPointerCancel(event) { finishDrag(event,true); }
  function syncAll() { sheets().forEach(sync); for (const sheet of states.keys()) if (!sheet.isConnected) { states.get(sheet).animation?.cancel(); states.delete(sheet); } }
  syncAll(); root.addEventListener('click',onClick); root.addEventListener('cancel',onCancel,true); root.addEventListener('close',onClose,true); root.addEventListener('pointerdown',onPointerDown); root.addEventListener('pointermove',onPointerMove); root.addEventListener('pointerup',finishDrag); root.addEventListener('pointercancel',onPointerCancel); root.addEventListener('touchstart',onTouchStart,{passive:true}); root.addEventListener('touchmove',onTouchMove,{passive:false}); root.addEventListener('touchend',onTouchEnd); root.addEventListener('touchcancel',onTouchCancel); window.addEventListener('resize',onResize); document.addEventListener('phx:update',syncAll);
  return ()=>{ root.removeEventListener('click',onClick); root.removeEventListener('cancel',onCancel,true); root.removeEventListener('close',onClose,true); root.removeEventListener('pointerdown',onPointerDown); root.removeEventListener('pointermove',onPointerMove); root.removeEventListener('pointerup',finishDrag); root.removeEventListener('pointercancel',onPointerCancel); root.removeEventListener('touchstart',onTouchStart); root.removeEventListener('touchmove',onTouchMove); root.removeEventListener('touchend',onTouchEnd); root.removeEventListener('touchcancel',onTouchCancel); window.removeEventListener('resize',onResize); document.removeEventListener('phx:update',syncAll); states.forEach((state,sheet)=>{ state.animation?.cancel(); if (sheet.open) sheet.close(); }); states.clear(); stack.length=0; if (addedScrollLock) document.documentElement.classList.remove('overflow-hidden'); };
}

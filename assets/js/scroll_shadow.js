/** Keep HeroUI scroll-shadow edge attributes in sync with the scroll container. */
export function installScrollShadow(root = document) {
  const selector = '[data-hero-scroll-shadow]';
  const states = new Map();
  let frame = null;
  const pending = new Set();
  const resizeObserver = typeof ResizeObserver === 'undefined' ? null : new ResizeObserver(entries => {
    for (const {target} of entries) {
      const owner = target.matches?.(selector) ? target : target.parentElement?.closest(selector);
      if (owner) schedule(owner);
      const parent = owner?.parentElement?.closest(selector);
      if (parent) schedule(parent);
    }
  });
  function fields() {
    const found = [...root.querySelectorAll(selector)];
    if (root.matches?.(selector)) found.unshift(root);
    return found;
  }
  function track(element) {
    let state = states.get(element);
    if (!state) { state={last:null, children:new Set()}; states.set(element,state); resizeObserver?.observe(element); }
    const children = new Set(element.children);
    for (const child of state.children) if (!children.has(child)) { resizeObserver?.unobserve(child); state.children.delete(child); }
    for (const child of children) if (!state.children.has(child)) { resizeObserver?.observe(child); state.children.add(child); }
    return state;
  }
  function forget(element) {
    const state=states.get(element); if (!state) return;
    resizeObserver?.unobserve(element);
    for (const child of state.children) if (!states.has(child)) resizeObserver?.unobserve(child);
    states.delete(element); pending.delete(element);
  }
  function schedule(element) {
    if (!element || !root.contains(element)) return;
    pending.add(element);
    if (frame == null) frame=requestAnimationFrame(() => { frame=null; const work=[...pending]; pending.clear(); work.forEach(update); });
  }
  function update(element) {
    if (!root.contains(element)) { forget(element); return; }
    const state=track(element), vertical=element.dataset.orientation !== 'horizontal';
    if (element.dataset.scrollShadowMode !== 'auto') {
      const visibility=element.dataset.scrollShadowVisibility || 'none';
      const supported=vertical ? ['top','bottom','both'] : ['left','right','both'];
      const actual=supported.includes(visibility) ? visibility : 'none';
      setEdges(element,vertical,actual); element.dataset.heroScrollShadowCurrent=actual; state.last=null; return;
    }
    const extent=vertical ? element.scrollHeight-element.clientHeight : element.scrollWidth-element.clientWidth;
    const position=vertical ? element.scrollTop : Math.abs(element.scrollLeft);
    const offset=Math.max(0,Number(element.dataset.scrollShadowOffset) || 0), tolerance=0.5;
    const before=extent>tolerance && position>offset+tolerance;
    const after=extent>tolerance && position<extent-offset-tolerance;
    const visibility=before && after ? 'both' : before ? (vertical ? 'top' : 'left') : after ? (vertical ? 'bottom' : 'right') : 'none';
    setEdges(element,vertical,visibility);
    element.dataset.heroScrollShadowCurrent=visibility;
    if (state.last != null && state.last !== visibility) {
      element.dispatchEvent(new CustomEvent('hero:scroll-shadow-change',{bubbles:true,detail:{visibility}}));
      const button=element.querySelector(':scope > [data-hero-scroll-shadow-event]');
      if (button) { button.setAttribute('phx-value-visibility',visibility); button.click(); }
    }
    state.last=visibility;
  }
  function setEdges(element,vertical,visibility) {
    for (const attr of ['top','bottom','top-bottom','left','right','left-right']) element.removeAttribute(`data-${attr}-scroll`);
    const attr=visibility === 'both' ? (vertical ? 'top-bottom' : 'left-right') : visibility;
    if (attr !== 'none') element.setAttribute(`data-${attr}-scroll`,'true');
  }
  function syncAll() {
    for (const element of fields()) schedule(element);
    for (const element of states.keys()) if (!root.contains(element)) forget(element);
  }
  function onScroll(event) { if (event.target.matches?.(selector)) schedule(event.target); }
  function onResize() { syncAll(); }
  function onLoad(event) { const owner=event.target.closest?.(selector); if (owner) schedule(owner); }
  const observer = typeof MutationObserver === 'undefined' ? null : new MutationObserver(records => {
    let scan=false;
    for (const record of records) {
      const owner=(record.target.nodeType === Node.ELEMENT_NODE ? record.target : record.target.parentElement)?.closest?.(selector);
      if (owner) schedule(owner);
      if (record.type === 'childList') {
        for (const node of [...record.addedNodes,...record.removedNodes]) {
          if (node.nodeType === Node.ELEMENT_NODE && (node.matches(selector) || node.querySelector(selector))) { scan=true; break; }
        }
      }
    }
    if (scan) syncAll();
  });
  observer?.observe(root === document ? document.documentElement : root,{subtree:true,childList:true,characterData:true,attributes:true,attributeFilter:['class','style','hidden','dir']});
  root.addEventListener('scroll',onScroll,true);
  root.addEventListener('load',onLoad,true);
  window.addEventListener('resize',onResize);
  document.addEventListener('phx:update',syncAll);
  syncAll();
  return () => {
    observer?.disconnect(); resizeObserver?.disconnect(); if (frame != null) cancelAnimationFrame(frame);
    root.removeEventListener('scroll',onScroll,true); root.removeEventListener('load',onLoad,true);
    window.removeEventListener('resize',onResize); document.removeEventListener('phx:update',syncAll);
    states.clear(); pending.clear();
  };
}

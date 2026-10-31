/** Progressive enhancement for native disclosure elements. */
export function installDisclosure(root = document) {
  const states=new WeakMap(), known=new Set();
  const disclosures=()=>root.querySelectorAll('[data-hero-disclosure]');
  const parts=details=>({trigger:details.querySelector(':scope > [data-hero-disclosure-trigger]'),content:details.querySelector(':scope > [data-hero-disclosure-content]')});
  const reduced=()=>window.matchMedia?.('(prefers-reduced-motion: reduce)').matches;
  function stateFor(details) { let state=states.get(details); if (!state) { state={open:details.open,closing:false,animation:null}; states.set(details,state); known.add(details); } return state; }
  function sync(details) {
    const {trigger,content}=parts(details); if (!trigger || !content) return;
    const state=stateFor(details), expanded=details.open && !state.closing;
    if (expanded) { details.dataset.expanded='true'; content.dataset.expanded='true'; }
    else { delete details.dataset.expanded; delete content.dataset.expanded; }
    trigger.setAttribute('role','button'); trigger.setAttribute('aria-expanded',String(expanded));
    trigger.setAttribute('phx-value-expanded',String(!expanded));
  }
  function animateOpen(details) {
    const {content}=parts(details), state=stateFor(details); if (!content?.animate || reduced()) return;
    state.animation?.cancel();
    const height=content.scrollHeight;
    const animation=content.animate([{height:'0px',opacity:0},{height:`${height}px`,opacity:1}],{duration:200,easing:'ease-out'});
    state.animation=animation; animation.finished.then(()=>{ if (state.animation===animation) state.animation=null; }).catch(()=>{});
  }
  function onClick(event) {
    const trigger=event.target.closest?.('[data-hero-disclosure-trigger]'), details=trigger?.parentElement;
    if (!details?.matches('[data-hero-disclosure]') || !root.contains(details)) return;
    const state=stateFor(details), {content}=parts(details);
    if (details.dataset.disabled === 'true') { event.preventDefault(); event.stopPropagation(); return; }
    if (state.closing) {
      event.preventDefault(); state.animation?.cancel(); state.animation=null; state.closing=false; delete details.dataset.heroClosing; sync(details);
      trigger.setAttribute('phx-value-expanded','true');
      return;
    }
    trigger.setAttribute('phx-value-expanded',String(!details.open));
    if (!details.open || !content?.animate || reduced()) return;
    event.preventDefault(); state.animation?.cancel(); state.closing=true; details.dataset.heroClosing='true'; sync(details); trigger.setAttribute('phx-value-expanded','false');
    const animation=content.animate([{height:`${content.scrollHeight}px`,opacity:1},{height:'0px',opacity:0}],{duration:200,easing:'ease-out'});
    state.animation=animation;
    animation.finished.then(()=>{
      if (state.animation!==animation) return;
      state.animation=null; state.closing=false; delete details.dataset.heroClosing; details.open=false; sync(details);
    }).catch(()=>{});
  }
  function onToggle(event) {
    const details=event.target; if (!details.matches?.('[data-hero-disclosure]') || !root.contains(details)) return;
    const state=stateFor(details), wasOpen=state.open; state.open=details.open;
    const group=details.parentElement;
    if (details.open && group?.matches('[data-hero-disclosure-group][data-allows-multiple-expanded="false"]')) {
      for (const sibling of group.children) if (sibling !== details && sibling.matches('[data-hero-disclosure]') && sibling.open) sibling.open=false;
    }
    if (!details.open && state.closing) { state.animation?.cancel(); state.animation=null; state.closing=false; delete details.dataset.heroClosing; }
    sync(details);
    if (details.open && !wasOpen) animateOpen(details);
  }
  function syncAll() { disclosures().forEach(sync); for (const details of known) if (!details.isConnected) { stateFor(details).animation?.cancel(); known.delete(details); } }
  syncAll(); root.addEventListener('click',onClick,true); root.addEventListener('toggle',onToggle,true); document.addEventListener('phx:update',syncAll);
  return ()=>{ root.removeEventListener('click',onClick,true); root.removeEventListener('toggle',onToggle,true); document.removeEventListener('phx:update',syncAll); known.forEach(details=>{ const state=states.get(details), {trigger}=parts(details); state?.animation?.cancel(); trigger?.removeAttribute('role'); trigger?.removeAttribute('aria-expanded'); delete details.dataset.heroClosing; }); known.clear(); };
}

/** Keyboard and focus management for server-controlled tag groups. */
export function installTagGroup(root = document) {
  const pendingRemovals = new Map();
  const tags = group => Array.from(group.querySelectorAll('[data-hero-tag]')).filter(tag => tag.closest('[data-hero-tag-group]') === group && tag.getAttribute('aria-disabled') !== 'true');
  function activate(group, tag, focus = false) {
    const enabled = tags(group);
    if (!enabled.includes(tag)) tag = enabled[0];
    enabled.forEach(item => { item.tabIndex = item === tag ? 0 : -1; });
    group.tabIndex = enabled.length || group.getAttribute('aria-disabled') === 'true' ? -1 : 0;
    if (focus && tag) tag.focus();
  }
  function sync() {
    root.querySelectorAll('[data-hero-tag-group]').forEach(group => {
      const enabled = tags(group), pending = pendingRemovals.get(group.id);
      if (pending) {
        pendingRemovals.delete(group.id);
        if (!group.querySelector(`[id="${CSS.escape(pending.id)}"]`)) {
          const next = enabled[Math.min(pending.index, enabled.length - 1)];
          activate(group, next, pending.focus);
          if (!next && pending.focus) group.focus();
          return;
        }
      }
      const focused = document.activeElement?.closest?.('[data-hero-tag]');
      activate(group, enabled.includes(focused) ? focused : enabled.find(tag => tag.tabIndex === 0) || enabled.find(tag => tag.getAttribute('aria-selected') === 'true'));
    });
  }
  function onFocus(event) {
    const tag = event.target.closest?.('[data-hero-tag]'), group = tag?.closest('[data-hero-tag-group]');
    if (group && root.contains(group) && tag.getAttribute('aria-disabled') !== 'true') activate(group, tag);
  }
  function onClick(event) {
    const tag = event.target.closest?.('[data-hero-tag]'), group = tag?.closest('[data-hero-tag-group]');
    if (!group || !root.contains(group) || tag.getAttribute('aria-disabled') === 'true') return;
    const remove = event.target.closest?.('[data-hero-tag-remove]');
    if (remove && !remove.disabled) {
      pendingRemovals.set(group.id, {id:tag.id, index:tags(group).indexOf(tag), focus:group.contains(document.activeElement)});
    } else if (!remove) activate(group, tag, true);
  }
  function onKeyDown(event) {
    const tag = event.target.closest?.('[data-hero-tag]'), group = tag?.closest('[data-hero-tag-group]');
    if (!group || !root.contains(group) || event.target !== tag || tag.getAttribute('aria-disabled') === 'true') return;
    const enabled = tags(group), index = enabled.indexOf(tag);
    let next;
    if (event.key === 'ArrowRight' || event.key === 'ArrowDown') next = enabled[Math.min(index + 1, enabled.length - 1)];
    else if (event.key === 'ArrowLeft' || event.key === 'ArrowUp') next = enabled[Math.max(index - 1, 0)];
    else if (event.key === 'Home') next = enabled[0];
    else if (event.key === 'End') next = enabled.at(-1);
    else if ((event.key === ' ' || event.key === 'Enter') && tag.dataset.selectionMode !== 'none') {
      event.preventDefault(); tag.click(); return;
    } else if (event.key === 'Delete' || event.key === 'Backspace') {
      const remove = tag.querySelector('[data-hero-tag-remove]:not(:disabled)');
      if (remove) { event.preventDefault(); remove.click(); }
      return;
    } else return;
    event.preventDefault(); activate(group, next, true);
  }
  sync();
  root.addEventListener('focusin', onFocus);
  root.addEventListener('click', onClick);
  root.addEventListener('keydown', onKeyDown);
  document.addEventListener('phx:update', sync);
  return () => {
    root.removeEventListener('focusin', onFocus); root.removeEventListener('click', onClick);
    root.removeEventListener('keydown', onKeyDown); document.removeEventListener('phx:update', sync);
    pendingRemovals.clear();
  };
}

/** A progressively enhanced Gregorian calendar backed by a native date input. */
export function installCalendar(root = document) {
  const states = new WeakMap();
  const fields = () => root.querySelectorAll('[data-hero-calendar]');
  const parts = field => ({native:field.querySelector('[data-hero-calendar-native]'), end:field.querySelector('[data-hero-calendar-end]'), ui:field.querySelector('[data-hero-calendar-ui]'), view:field.querySelector('[data-hero-calendar-view]'), error:field.querySelector('[data-hero-calendar-error]')});
  const make = (year, month, day = 1) => { const date = new Date(0); date.setUTCHours(0,0,0,0); date.setUTCFullYear(year, month, day); return date; };
  const parse = value => { const match = /^(\d{4})-(\d{2})-(\d{2})$/.exec(value || ''); if (!match) return null; const date = make(Number(match[1]), Number(match[2])-1, Number(match[3])); return iso(date) === value ? date : null; };
  const iso = date => `${String(date.getUTCFullYear()).padStart(4,'0')}-${String(date.getUTCMonth()+1).padStart(2,'0')}-${String(date.getUTCDate()).padStart(2,'0')}`;
  const plusDays = (date, days) => make(date.getUTCFullYear(), date.getUTCMonth(), date.getUTCDate()+days);
  const monthStart = date => make(date.getUTCFullYear(), date.getUTCMonth(), 1);
  const addMonths = (date, months) => { const first = make(date.getUTCFullYear(), date.getUTCMonth()+months, 1); const last = make(first.getUTCFullYear(), first.getUTCMonth()+1, 0).getUTCDate(); return make(first.getUTCFullYear(), first.getUTCMonth(), Math.min(date.getUTCDate(),last)); };
  const localToday = () => { const now = new Date(); return make(now.getFullYear(), now.getMonth(), now.getDate()); };
  const element = (tag, className, text) => { const el = document.createElement(tag); if (className) el.className = className; if (text != null) el.textContent = text; return el; };
  function localeFor(field) { return field.dataset.locale || field.closest('[lang]')?.lang || navigator.language || 'en-US'; }
  function formatter(locale, options) {
    try { return new Intl.DateTimeFormat(locale, {calendar:'gregory',timeZone:'UTC',...options}); }
    catch (_) { return new Intl.DateTimeFormat('en-US', {calendar:'gregory',timeZone:'UTC',...options}); }
  }
  function weekStart(field, locale) {
    if (field.dataset.weekStart !== undefined && field.dataset.weekStart !== '') return Number(field.dataset.weekStart);
    try { const item = new Intl.Locale(locale); return (item.getWeekInfo?.() || item.weekInfo)?.firstDay % 7 || 0; }
    catch (_) { return 0; }
  }
  function unavailable(field) { try { const dates = JSON.parse(field.dataset.unavailable || '[]'); return new Set(Array.isArray(dates) ? dates : []); } catch (_) { return new Set(); } }
  function clamp(date, native) {
    const min = parse(native.min), max = parse(native.max);
    if (min && date < min) return min;
    if (max && date > max) return max;
    return date;
  }
  function signature(field, native) {
    return JSON.stringify([native.value,parts(field).end?.value,native.min,native.max,native.matches(':disabled'),native.readOnly,native.required,native.getAttribute('aria-invalid'),native.getAttribute('aria-describedby'),field.dataset.locale,field.dataset.weekStart,field.dataset.weeks,field.dataset.yearPicker,field.dataset.focusedDate,field.dataset.today,field.dataset.unavailable,field.dataset.allowsNonContiguousRanges,field.dataset.label,field.querySelector('label')?.textContent]);
  }
  function syncValidity(field, native, state) {
    const blocked = !!native.value && unavailable(field).has(native.value);
    if (blocked && (!native.validity.customError || state.managedError)) { native.setCustomValidity('This date is unavailable.'); state.managedError = true; }
    else if (!blocked && state.managedError) { native.setCustomValidity(''); state.managedError = false; }
  }
  function rangeBlocked(field, start, end) {
    if (!start || !end) return false;
    const lo = start < end ? start : end, hi = start < end ? end : start;
    return [...unavailable(field)].some(date => date >= lo && date <= hi);
  }
  function syncRangeValidity(field, end, state) {
    if (!end) return;
    const start = parts(field).native.value;
    const message = end.value && unavailable(field).has(end.value) ? 'This date is unavailable.' :
      start && end.value && start > end.value ? 'End date must be on or after start date.' :
      start && end.value && field.dataset.allowsNonContiguousRanges !== 'true' && rangeBlocked(field,start,end.value) ? 'This range includes unavailable dates.' : '';
    if (message && (!end.validity.customError || state.rangeError)) { end.setCustomValidity(message); state.rangeError=true; }
    else if (!message && state.rangeError) { end.setCustomValidity(''); state.rangeError=false; }
  }
  function paintRange(field, preview = null) {
    const {native,end,view} = parts(field); if (!end) return;
    let start = native.value, finish = end.value || preview || start;
    if (start && finish && finish < start) [start,finish] = [finish,start];
    view.querySelectorAll('[data-hero-calendar-date]').forEach(button => {
      const value=button.dataset.heroCalendarDate, selected=!!start && value >= start && value <= finish && button.dataset.outsideMonth !== 'true';
      for (const key of ['selected','selectionStart','selectionEnd','selectionInRange']) delete button.dataset[key];
      button.parentElement.removeAttribute('aria-selected');
      if (!button.dataset.baseLabel) button.dataset.baseLabel=button.getAttribute('aria-label').replace(/, selected$/, '');
      button.setAttribute('aria-label',button.dataset.baseLabel + (selected ? ', selected' : ''));
      if (selected) {
        button.dataset.selected='true'; button.parentElement.setAttribute('aria-selected','true');
        if (value === start) button.dataset.selectionStart='true';
        if (value === finish) button.dataset.selectionEnd='true';
        if (value !== start && value !== finish) button.dataset.selectionInRange='true';
      }
    });
  }
  function icon(direction, prefix = 'calendar') {
    const svg = document.createElementNS('http://www.w3.org/2000/svg','svg'); svg.setAttribute('viewBox','0 0 16 16'); svg.setAttribute('aria-hidden','true'); svg.classList.add(`${prefix}__nav-button-icon`); svg.dataset.slot = `${prefix}-nav-button-icon`;
    const path = document.createElementNS('http://www.w3.org/2000/svg','path'); path.setAttribute('fill','currentColor'); path.setAttribute('fill-rule','evenodd'); path.setAttribute('clip-rule','evenodd');
    path.setAttribute('d', direction < 0 ? 'M10.53 2.97a.75.75 0 0 1 0 1.06L6.56 8l3.97 3.97a.75.75 0 1 1-1.06 1.06l-4.5-4.5a.75.75 0 0 1 0-1.06l4.5-4.5a.75.75 0 0 1 1.06 0' : 'M5.47 2.97a.75.75 0 0 1 1.06 0l4.5 4.5a.75.75 0 0 1 0 1.06l-4.5 4.5a.75.75 0 1 1-1.06-1.06L9.44 8 5.47 4.03a.75.75 0 0 1 0-1.06Z'); svg.appendChild(path); return svg;
  }
  function yearBounds(native) { return {min:parse(native.min)?.getUTCFullYear() || 1, max:parse(native.max)?.getUTCFullYear() || 9999}; }
  function yearWindow(state, native, year) {
    const {min,max} = yearBounds(native), start = Math.max(min, Math.floor(year/100)*100-100);
    state.yearStart = Math.max(min, Math.min(start, max));
    state.yearEnd = Math.min(max, Math.max(state.yearStart+199, year));
    if (year < state.yearStart) state.yearStart = year;
    state.yearActive = year;
  }
  function yearCell(field, year) {
    const {native} = parts(field), state = states.get(field), label = state.yearFormat.format(make(year,0,1));
    const button = element('button','calendar-year-picker__year-cell',label);
    button.type='button'; button.dataset.slot='calendar-year-picker-year-cell'; button.dataset.heroCalendarYear=String(year);
    button.setAttribute('role','option'); button.setAttribute('aria-label',label); button.setAttribute('aria-selected',String(year === state.focus.getUTCFullYear()));
    if (year === state.focus.getUTCFullYear()) button.dataset.selected='true';
    button.tabIndex = year === state.yearActive ? 0 : -1;
    button.disabled = native.matches(':disabled');
    return button;
  }
  function keepYearVisible(grid, cell) {
    const box=grid.getBoundingClientRect(), item=cell.getBoundingClientRect();
    if (item.top < box.top) grid.scrollTop -= box.top-item.top;
    else if (item.bottom > box.bottom) grid.scrollTop += item.bottom-box.bottom;
  }
  function extendYears(field, grid, direction) {
    const {native}=parts(field), state=states.get(field), {min,max}=yearBounds(native);
    if (direction < 0 && state.yearStart > min) {
      const start=Math.max(min,state.yearStart-99), fragment=document.createDocumentFragment(), oldHeight=grid.scrollHeight;
      for (let year=start; year<state.yearStart; year++) fragment.appendChild(yearCell(field,year));
      grid.prepend(fragment); state.yearStart=start; grid.scrollTop += grid.scrollHeight-oldHeight;
    } else if (direction > 0 && state.yearEnd < max) {
      const end=Math.min(max,state.yearEnd+99), fragment=document.createDocumentFragment();
      for (let year=state.yearEnd+1; year<=end; year++) fragment.appendChild(yearCell(field,year));
      grid.appendChild(fragment); state.yearEnd=end;
    }
  }
  function render(field, focus = null) {
    const {native, end, view, error} = parts(field), state = states.get(field), prefix = end ? 'range-calendar' : 'calendar';
    const previousFocus = view.contains(document.activeElement) ? document.activeElement : null;
    const restoreDate = previousFocus?.dataset.heroCalendarDate, restoreNav = previousFocus?.dataset.heroCalendarNav;
    const restoreYear = previousFocus?.dataset.heroCalendarYear, restoreTrigger = previousFocus?.hasAttribute('data-hero-calendar-year-trigger');
    const previousYearGrid = view.querySelector('[data-hero-calendar-year-grid]');
    const previousScroll = previousYearGrid?.scrollTop;
    const locale = localeFor(field), firstDay = weekStart(field, locale), blocked = unavailable(field);
    const headingFormat = formatter(locale,{month:'long',year:'numeric'}), dateFormat = formatter(locale,{weekday:'long',year:'numeric',month:'long',day:'numeric'}), dayFormat = formatter(locale,{day:'numeric'}), weekdayFormat = formatter(locale,{weekday:'short'});
    state.yearFormat = formatter(locale,{year:'numeric'});
    const title = headingFormat.format(state.month), label = field.dataset.label || field.querySelector('label')?.textContent.trim() || 'Date';
    view.setAttribute('aria-label',`${label}, ${title}`); view.replaceChildren();
    const header = element('div',`${prefix}__header`); header.dataset.slot = `${prefix}-header`;
    if (field.dataset.yearPicker === 'true') {
      const trigger=element('button','calendar-year-picker__trigger'); trigger.type='button'; trigger.dataset.slot='calendar-year-picker-trigger'; trigger.dataset.heroCalendarYearTrigger=''; trigger.setAttribute('aria-label',`${title}, year selector`); trigger.setAttribute('aria-expanded',String(state.yearOpen)); trigger.setAttribute('aria-controls',`${native.id}-year-grid`); trigger.disabled=native.matches(':disabled');
      if (state.yearOpen) trigger.dataset.open='true';
      const heading=element('span','calendar-year-picker__trigger-heading',title); heading.dataset.slot='calendar-year-picker-trigger-heading';
      const indicator=element('span','calendar-year-picker__trigger-indicator'); indicator.dataset.slot='calendar-year-picker-trigger-indicator'; indicator.setAttribute('aria-hidden','true'); const arrow=icon(1); arrow.classList.remove('calendar__nav-button-icon'); arrow.setAttribute('width','1em'); arrow.setAttribute('height','1em'); indicator.appendChild(arrow);
      trigger.append(heading,indicator); header.appendChild(trigger);
    } else {
      const heading = element('h2',`${prefix}__heading`,title); heading.dataset.slot = `${prefix}-heading`; heading.setAttribute('aria-live','polite'); header.appendChild(heading);
    }
    for (const direction of [-1,1]) {
      const nav = element('button',`${prefix}__nav-button`); nav.type = 'button'; nav.dataset.slot = `${prefix}-nav-button`; nav.dataset.heroCalendarNav = String(direction); nav.setAttribute('aria-label',direction < 0 ? 'Previous month' : 'Next month');
      const candidate = addMonths(state.month,direction), end = addMonths(candidate,1); end.setUTCDate(0);
      nav.disabled = native.matches(':disabled') || (direction < 0 && (candidate.getUTCFullYear() < 1 || (native.min && iso(end) < native.min))) || (direction > 0 && (candidate.getUTCFullYear() > 9999 || (native.max && iso(candidate) > native.max)));
      if (state.yearOpen) { nav.tabIndex=-1; nav.setAttribute('aria-hidden','true'); }
      nav.appendChild(icon(direction,prefix)); header.appendChild(nav);
    }
    view.appendChild(header);
    const table = element('table',`${prefix}__grid`); table.dataset.slot = `${prefix}-grid`; if (end) table.setAttribute('aria-multiselectable','true'); table.setAttribute('role','grid'); table.setAttribute('aria-label',`${label}, ${title}`); table.setAttribute('cellpadding','0'); table.tabIndex=-1;
    if (state.yearOpen) { table.inert=true; table.setAttribute('aria-hidden','true'); }
    if (native.readOnly) table.setAttribute('aria-readonly','true');
    if (native.getAttribute('aria-invalid') === 'true' || !error.hidden) table.setAttribute('aria-invalid','true');
    const describedby = [native.getAttribute('aria-describedby'), !error.hidden && error.id].filter(Boolean).join(' '); if (describedby) table.setAttribute('aria-describedby',describedby);
    const thead = element('thead',`${prefix}__grid-header`); thead.dataset.slot = `${prefix}-grid-header`; thead.setAttribute('aria-hidden','true'); const headerRow = element('tr');
    for (let day=0; day<7; day++) { const th = element('th',`${prefix}__header-cell`,weekdayFormat.format(make(2023,0,1+(firstDay+day)%7))); th.dataset.slot = `${prefix}-header-cell`; headerRow.appendChild(th); }
    thead.appendChild(headerRow); table.appendChild(thead);
    const tbody = element('tbody',`${prefix}__grid-body`); tbody.dataset.slot = `${prefix}-grid-body`;
    const offset = (state.month.getUTCDay()-firstDay+7)%7, lastDay = make(state.month.getUTCFullYear(),state.month.getUTCMonth()+1,0).getUTCDate();
    const weeks = Math.max(Math.ceil((offset+lastDay)/7), Number(field.dataset.weeks) || 0);
    const today = iso(parse(field.dataset.today) || localToday()), min = native.min || '0001-01-01', max = native.max || '9999-12-31';
    for (let week=0; week<weeks; week++) {
      const row = element('tr');
      for (let column=0; column<7; column++) {
        const date = plusDays(state.month,week*7+column-offset), dateISO = iso(date), outside = date.getUTCMonth() !== state.month.getUTCMonth(), isUnavailable = blocked.has(dateISO);
        const disabled = outside || dateISO < min || dateISO > max || native.matches(':disabled');
        const td = element('td'); td.setAttribute('role','gridcell'); if (dateISO === native.value) td.setAttribute('aria-selected','true'); if (disabled || isUnavailable) td.setAttribute('aria-disabled','true');
        const button = element('button',`${prefix}__cell`,end ? null : dayFormat.format(date)); button.type='button'; button.dataset.slot=`${prefix}-cell`; if (end) { const inner=element('span','range-calendar__cell-button',dayFormat.format(date)); inner.dataset.slot='range-calendar-cell-button'; button.appendChild(inner); } button.dataset.heroCalendarDate=dateISO;
        button.disabled = disabled; button.tabIndex = !disabled && dateISO === iso(state.focus) ? 0 : -1;
        button.setAttribute('aria-label',`${dateISO === today ? 'Today, ' : ''}${dateFormat.format(date)}${dateISO === native.value ? ', selected' : ''}`);
        if (dateISO === today) { button.dataset.today='true'; button.setAttribute('aria-current','date'); }
        if (dateISO === native.value) button.dataset.selected='true';
        if (outside) button.dataset.outsideMonth='true';
        if (disabled) button.dataset.disabled='true';
        if (isUnavailable) { button.dataset.unavailable='true'; button.setAttribute('aria-disabled','true'); }
        td.appendChild(button); row.appendChild(td);
      }
      tbody.appendChild(row);
    }
    table.appendChild(tbody); view.appendChild(table); if (end) paintRange(field);
    let yearGrid;
    if (state.yearOpen && field.dataset.yearPicker === 'true') {
      const bounds=yearBounds(native), activeYear=state.yearActive ?? state.focus.getUTCFullYear();
      if (state.yearStart == null || activeYear < state.yearStart || activeYear > state.yearEnd || state.yearStart < bounds.min || state.yearEnd > bounds.max) yearWindow(state,native,Math.max(bounds.min,Math.min(bounds.max,activeYear)));
      yearGrid=element('div','calendar-year-picker__year-grid'); yearGrid.id=`${native.id}-year-grid`; yearGrid.dataset.slot='calendar-year-picker-grid'; yearGrid.dataset.heroCalendarYearGrid=''; yearGrid.dataset.open='true'; yearGrid.setAttribute('role','listbox'); yearGrid.setAttribute('aria-label','Year'); yearGrid.tabIndex=-1;
      const fragment=document.createDocumentFragment(); for (let year=state.yearStart; year<=state.yearEnd; year++) fragment.appendChild(yearCell(field,year)); yearGrid.appendChild(fragment); view.appendChild(yearGrid);
      yearGrid.style.top=`${table.offsetTop}px`; yearGrid.style.height=`${table.offsetHeight}px`;
      if (previousScroll != null) yearGrid.scrollTop=previousScroll;
    } else if (field.dataset.yearPicker === 'true') {
      const closed=element('div','calendar-year-picker__year-grid'); closed.id=`${native.id}-year-grid`; closed.dataset.slot='calendar-year-picker-grid'; closed.setAttribute('role','listbox'); closed.setAttribute('aria-label','Year'); closed.setAttribute('aria-hidden','true'); closed.hidden=true; view.appendChild(closed);
    }
    const target = focus?.date ? view.querySelector(`[data-hero-calendar-date="${focus.date}"]`) : focus?.nav ? view.querySelector(`[data-hero-calendar-nav="${focus.nav}"]`) : focus?.year != null ? view.querySelector(`[data-hero-calendar-year="${focus.year}"]`) : focus?.yearTrigger ? view.querySelector('[data-hero-calendar-year-trigger]') : restoreDate && !state.yearOpen ? view.querySelector(`[data-hero-calendar-date="${restoreDate}"]`) : restoreNav && !state.yearOpen ? view.querySelector(`[data-hero-calendar-nav="${restoreNav}"]`) : restoreYear && state.yearOpen ? view.querySelector(`[data-hero-calendar-year="${restoreYear}"]`) : restoreTrigger ? view.querySelector('[data-hero-calendar-year-trigger]') : null;
    if (target && !target.disabled) target.focus({preventScroll:true});
    else if (restoreYear && state.yearOpen) view.querySelector(`[data-hero-calendar-year="${state.yearActive}"]`)?.focus({preventScroll:true});
    else if (focus?.nav && target?.disabled) (view.querySelector('[data-hero-calendar-nav]:not(:disabled)') || view.querySelector('[data-hero-calendar-date][tabindex="0"]'))?.focus({preventScroll:true});
    if (yearGrid && target?.hasAttribute('data-hero-calendar-year')) keepYearVisible(yearGrid,target);
  }
  function sync(field) {
    const {native, end, ui, view, error} = parts(field); if (!native || !ui || !view || !error) return;
    const nativeHadFocus = document.activeElement === native || document.activeElement === end;
    const dateHadFocus = view.contains(document.activeElement) && document.activeElement?.hasAttribute("data-hero-calendar-date");
    let focusChanged = false, state = states.get(field), next = signature(field,native);
    if (!state) {
      const focus = clamp(parse(field.dataset.focusedDate) || parse(native.value) || parse(field.dataset.today) || localToday(),native);
      state = {focus, month:monthStart(focus), value:native.value, externalFocus:field.dataset.focusedDate, managedError:false, signature:null, yearOpen:false, yearStart:null, yearEnd:null, yearActive:null}; states.set(field,state);
    } else {
      if (state.value !== native.value) { state.value = native.value; const selected = parse(native.value); if (selected) { state.focus = clamp(selected,native); state.month = monthStart(state.focus); focusChanged = true; } }
      if (state.externalFocus !== field.dataset.focusedDate) { state.externalFocus = field.dataset.focusedDate; const requested = parse(field.dataset.focusedDate); if (requested) { state.focus = clamp(requested,native); state.month = monthStart(state.focus); focusChanged = true; } }
      const clamped = clamp(state.focus,native);
      if (iso(clamped) !== iso(state.focus)) { state.focus = clamped; state.month = monthStart(clamped); focusChanged = true; }
    }
    syncValidity(field,native,state); syncRangeValidity(field,end,state);
    if (field.dataset.yearPicker !== 'true' || native.matches(':disabled')) state.yearOpen=false;
    field.dataset.enhanced='true'; native.setAttribute('aria-hidden','true'); native.tabIndex=-1; if (end) { end.setAttribute('aria-hidden','true'); end.tabIndex=-1; field.querySelector('[data-hero-calendar-native-group]')?.setAttribute('aria-hidden','true'); } ui.hidden=false;
    if (state.signature !== next) { state.signature = next; render(field, focusChanged && dateHadFocus ? {date:iso(state.focus)} : null); }
    if (nativeHadFocus) (view.querySelector('[data-hero-calendar-date][tabindex="0"]') || view.querySelector('[role="grid"]'))?.focus({preventScroll:true});
  }
  function onClick(event) {
    const yearTrigger=event.target.closest?.('[data-hero-calendar-year-trigger]'), year=event.target.closest?.('[data-hero-calendar-year]');
    const nav = event.target.closest?.('[data-hero-calendar-nav]'), day = event.target.closest?.('[data-hero-calendar-date]');
    const field = (yearTrigger || year || nav || day)?.closest('[data-hero-calendar]');
    if (field && root.contains(field)) {
      const {native,end,error} = parts(field), state = states.get(field); if (native.matches(':disabled')) return;
      if (yearTrigger && !yearTrigger.disabled) {
        state.yearOpen=!state.yearOpen;
        if (state.yearOpen) { yearWindow(state,native,state.focus.getUTCFullYear()); render(field,{year:state.yearActive}); }
        else render(field,{yearTrigger:true});
      } else if (year && state.yearOpen && !year.disabled) {
        const selectedYear=Number(year.dataset.heroCalendarYear), date=clamp(addMonths(state.focus,(selectedYear-state.focus.getUTCFullYear())*12),native);
        state.focus=date; state.month=monthStart(date); state.yearOpen=false; render(field,{date:iso(date)});
      } else if (nav && !nav.disabled) { const date = clamp(addMonths(state.focus,Number(nav.dataset.heroCalendarNav)),native); state.focus=date; state.month=monthStart(date); render(field,{nav:nav.dataset.heroCalendarNav}); }
      else if (day && !day.disabled && day.getAttribute('aria-disabled') !== 'true' && !native.readOnly) {
        const value = day.dataset.heroCalendarDate; state.focus=parse(value); state.month=monthStart(state.focus);
        let changed, target=native;
        if (end) {
          const oldStart=native.value, oldEnd=end.value;
          if (!oldStart || oldEnd) { native.value=value; end.value=''; }
          else {
            if (field.dataset.allowsNonContiguousRanges !== 'true' && rangeBlocked(field,oldStart,value)) return;
            if (value < oldStart) { native.value=value; end.value=oldStart; }
            else end.value=value;
            target=end;
          }
          changed=oldStart !== native.value || oldEnd !== end.value;
        } else { changed=native.value !== value; native.value=value; }
        state.value=native.value; error.hidden=true; error.textContent=''; syncValidity(field,native,state); syncRangeValidity(field,end,state); state.signature=signature(field,native); render(field,{date:value});
        if (changed) { target.dispatchEvent(new Event('input',{bubbles:true})); target.dispatchEvent(new Event('change',{bubbles:true})); }
      }
      return;
    }
    const label = event.target.closest?.('label'), native = label?.control;
    if (native?.matches('[data-hero-calendar-native]') && native.closest('[data-hero-calendar]')?.dataset.enhanced === 'true' && !native.matches(':disabled')) { event.preventDefault(); const field=native.closest('[data-hero-calendar]'), state=states.get(field); if (state.yearOpen) { state.yearOpen=false; render(field,{date:iso(state.focus)}); } else parts(field).view.querySelector('[data-hero-calendar-date][tabindex="0"]')?.focus(); }
  }
  function onKeyDown(event) {
    const year=event.target.closest?.('[data-hero-calendar-year]'), trigger=event.target.closest?.('[data-hero-calendar-year-trigger]');
    const yearField=(year || trigger)?.closest('[data-hero-calendar]');
    if (yearField && root.contains(yearField)) {
      const state=states.get(yearField), {native,view}=parts(yearField);
      if (event.key === 'Escape' && state.yearOpen) { event.preventDefault(); state.yearOpen=false; render(yearField,{yearTrigger:true}); return; }
      if (!year || !state.yearOpen || year.disabled) return;
      const bounds=yearBounds(native), current=Number(year.dataset.heroCalendarYear); let next;
      if (event.key === 'ArrowLeft') next=current-1;
      else if (event.key === 'ArrowRight') next=current+1;
      else if (event.key === 'ArrowUp') next=current-3;
      else if (event.key === 'ArrowDown') next=current+3;
      else if (event.key === 'Home') next=bounds.min;
      else if (event.key === 'End') next=bounds.max;
      else return;
      event.preventDefault(); next=Math.max(bounds.min,Math.min(bounds.max,next)); state.yearActive=next;
      if (next < state.yearStart || next > state.yearEnd) { yearWindow(state,native,next); render(yearField,{year:next}); }
      else { const grid=view.querySelector('[data-hero-calendar-year-grid]'), target=grid.querySelector(`[data-hero-calendar-year="${next}"]`); grid.querySelectorAll('[data-hero-calendar-year]').forEach(item => { item.tabIndex=item === target ? 0 : -1; }); target?.focus({preventScroll:true}); if (target) keepYearVisible(grid,target); }
      return;
    }
    const button = event.target.closest?.('[data-hero-calendar-date]'); if (!button || button.disabled || !root.contains(button)) return;
    const field = button.closest('[data-hero-calendar]'), {native,view} = parts(field), state = states.get(field), date = parse(button.dataset.heroCalendarDate);
    const rtl = getComputedStyle(view).direction === 'rtl', first = weekStart(field,localeFor(field)); let next;
    if (event.key === 'ArrowLeft') next = plusDays(date,rtl ? 1 : -1);
    else if (event.key === 'ArrowRight') next = plusDays(date,rtl ? -1 : 1);
    else if (event.key === 'ArrowUp') next = plusDays(date,-7);
    else if (event.key === 'ArrowDown') next = plusDays(date,7);
    else if (event.key === 'Home') next = plusDays(date,-((date.getUTCDay()-first+7)%7));
    else if (event.key === 'End') next = plusDays(date,6-((date.getUTCDay()-first+7)%7));
    else if (event.key === 'PageUp') next = addMonths(date,event.shiftKey ? -12 : -1);
    else if (event.key === 'PageDown') next = addMonths(date,event.shiftKey ? 12 : 1);
    else return;
    event.preventDefault(); next = clamp(next,native);
    if (next.getUTCFullYear() < 1 || next.getUTCFullYear() > 9999) return;
    state.focus=next; state.month=monthStart(next); render(field,{date:iso(next)});
  }
  function onFocusIn(event) {
    const year=event.target.closest?.('[data-hero-calendar-year]');
    if (year && root.contains(year)) { const field=year.closest('[data-hero-calendar]'), state=states.get(field), grid=year.closest('[data-hero-calendar-year-grid]'); if (state && grid) { state.yearActive=Number(year.dataset.heroCalendarYear); grid.querySelectorAll('[data-hero-calendar-year]').forEach(item => { item.tabIndex=item === year ? 0 : -1; }); } return; }
    const button = event.target.closest?.('[data-hero-calendar-date]'); if (!button || button.disabled || !root.contains(button)) return;
    const field = button.closest('[data-hero-calendar]'), state = states.get(field); if (!state) return;
    state.focus=parse(button.dataset.heroCalendarDate);
    parts(field).view.querySelectorAll('[data-hero-calendar-date]').forEach(day => { if (!day.disabled) day.tabIndex = day === button ? 0 : -1; });
  }
  function onInvalid(event) {
    const native=event.target; if (!native.matches?.('[data-hero-calendar-native], [data-hero-calendar-end]')) return;
    const field=native.closest('[data-hero-calendar]'); if (field.dataset.enhanced !== 'true') return;
    event.preventDefault(); const {error,view}=parts(field); error.textContent=native.validationMessage; error.hidden=false; states.get(field).yearOpen=false; render(field); (view.querySelector('[data-hero-calendar-date][tabindex="0"]') || view.querySelector('[role="grid"]'))?.focus();
  }
  function onChange(event) { if (event.target.matches?.('[data-hero-calendar-native], [data-hero-calendar-end]')) sync(event.target.closest('[data-hero-calendar]')); }
  function onPointerOver(event) {
    const day=event.target.closest?.('[data-hero-calendar-date]'), field=day?.closest('[data-hero-calendar]');
    if (!field || !root.contains(field)) return;
    const {native,end}=parts(field), value=day.dataset.heroCalendarDate;
    if (!end || !native.value || end.value || day.disabled || day.getAttribute('aria-disabled') === 'true') return;
    if (field.dataset.allowsNonContiguousRanges !== 'true' && rangeBlocked(field,native.value,value)) return;
    paintRange(field,value);
  }
  function onPointerOut(event) {
    const field=event.target.closest?.('[data-hero-calendar]');
    if (field && !field.contains(event.relatedTarget) && parts(field).end) paintRange(field);
  }
  function onScroll(event) {
    const grid=event.target; if (!grid.matches?.('[data-hero-calendar-year-grid]') || !root.contains(grid)) return;
    const field=grid.closest('[data-hero-calendar]'), state=states.get(field); if (!state?.yearOpen) return;
    if (grid.scrollTop < 32) extendYears(field,grid,-1);
    if (grid.scrollHeight-grid.scrollTop-grid.clientHeight < 32) extendYears(field,grid,1);
  }
  function onRequestFocus(event) {
    const field=event.target.closest?.('[data-hero-calendar]'); if (!field || !root.contains(field)) return;
    const state=states.get(field), {native}=parts(field); if (!state) return;
    const requested=parse(event.detail?.value) || parse(field.dataset.focusedDate) || parse(field.dataset.today) || localToday();
    state.focus=clamp(requested,native); state.month=monthStart(state.focus); state.yearOpen=false;
    render(field,event.detail?.focus ? {date:iso(state.focus)} : null);
  }
  function syncAll() { fields().forEach(sync); }
  function onReset() { setTimeout(() => { fields().forEach(field => { const {native,error}=parts(field),state=states.get(field); if (!state) return; state.focus=clamp(parse(native.value) || parse(field.dataset.today) || localToday(),native); state.month=monthStart(state.focus); state.yearOpen=false; state.signature=null; error.hidden=true; error.textContent=''; }); syncAll(); },0); }
  syncAll(); root.addEventListener('click',onClick); root.addEventListener('hero-calendar-focus',onRequestFocus); root.addEventListener('pointerover',onPointerOver); root.addEventListener('pointerout',onPointerOut); root.addEventListener('keydown',onKeyDown); root.addEventListener('focusin',onFocusIn); root.addEventListener('change',onChange); root.addEventListener('invalid',onInvalid,true); root.addEventListener('reset',onReset); root.addEventListener('scroll',onScroll,true); document.addEventListener('phx:update',syncAll);
  return () => { root.removeEventListener('click',onClick); root.removeEventListener('hero-calendar-focus',onRequestFocus); root.removeEventListener('pointerover',onPointerOver); root.removeEventListener('pointerout',onPointerOut); root.removeEventListener('keydown',onKeyDown); root.removeEventListener('focusin',onFocusIn); root.removeEventListener('change',onChange); root.removeEventListener('invalid',onInvalid,true); root.removeEventListener('reset',onReset); root.removeEventListener('scroll',onScroll,true); document.removeEventListener('phx:update',syncAll); fields().forEach(field => { const {native,end,ui}=parts(field),state=states.get(field); if (state?.managedError) native.setCustomValidity(''); native.removeAttribute('aria-hidden'); native.removeAttribute('tabindex'); if (end) { if (state?.rangeError) end.setCustomValidity(''); end.removeAttribute('aria-hidden'); end.removeAttribute('tabindex'); field.querySelector('[data-hero-calendar-native-group]')?.removeAttribute('aria-hidden'); } ui.hidden=true; delete field.dataset.enhanced; }); };
}

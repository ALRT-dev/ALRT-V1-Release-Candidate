// ALRT prototype v3: the approved canvas boards are the screens. This file is the shell,
// the DOM helpers, and the per-board bindings that put live backend data into the designed markup.
let R; const $ = (s, r = document) => r.querySelector(s); const $$ = (s, r = document) => [...r.querySelectorAll(s)];
const esc = (s) => String(s ?? '').replace(/[&<>"]/g, (c) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' }[c]));
const st = { screen: 'Splash', tab: 'Main', token: '', user: null, access: null, hazards: [], circles: [], sos: [], journeys: [], notes: [], offline: false, lastSync: null, sheet: null, toast: '', onb: { level: 'official', who: 'family', agreed: [] }, pts: null, places: [], detail: null, ask: null, lock: null, seenNotes: 0, paywallCtx: null, circleId: null, filters: null, followed: [], plan: null, primed: false, drill: null };
try { st.token = localStorage.getItem('alrt_tok') || ''; } catch {}
const money = (n) => 'A$' + n.toFixed(2);
const when = (t) => new Date(t).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
const ago = (h) => h.minutesAgo < 60 ? `${h.minutesAgo} min ago` : h.minutesAgo < 1440 ? `${Math.round(h.minutesAgo / 60)} hr${Math.round(h.minutesAgo / 60) > 1 ? 's' : ''} ago` : 'yesterday';

async function api(p, o = {}) {
  if (st.offline && !p.startsWith('/__')) return { ok: false, status: 0, data: { code: 'OFFLINE' } };
  const r = await fetch('/api' + p, { method: o.method || (o.body ? 'POST' : 'GET'), headers: { 'content-type': 'application/json', authorization: st.token ? 'Bearer ' + st.token : '' }, body: o.body ? JSON.stringify(o.body) : undefined });
  let d = {}; try { d = await r.json(); } catch {}
  return { ok: r.ok, status: r.status, data: d };
}
const toast = (t) => { st.toast = t; draw(); setTimeout(() => { if (st.toast === t) { st.toast = ''; draw(); } }, 2800); };
const circ = () => st.circles.find((c) => c.circleId === st.circleId) || st.circles[0];
const me = () => st.user?.id;
const nm = (id) => circ()?.members.find((m) => m.id === id)?.name || 'Member';
function myCohorts() { try { return JSON.parse(localStorage.getItem('alrt_cohorts') || '[]'); } catch { return []; } }
function mySos() { return st.sos.find((s) => s.userId === me() && s.active); }
function mySosAny() { return st.sos.find((s) => s.active && (s.userId === me() || (circ() && s.circleId === circ().circleId))); }
const bandColor = (h) => (h.source === 'community' ? R.categories[h.category]?.color || '#C233DB' : R.bands[h.band]);
const bandText = { critical: '#B3141F', action: '#9A4A00', monitor: '#6B5400', info: '#3A3A42' };

// ---------- design tokens taken from the boards
const FONT = "Figtree, system-ui, sans-serif";
const LAB = 'font-size: 12px; font-weight: 700; letter-spacing: 0.6px; text-transform: uppercase; color: #B84500';
const CARD = 'background: #FFFFFF; border-radius: 18px; padding: 16px; box-shadow: 0 1px 3px rgba(0,0,0,0.06); display: flex; flex-direction: column; gap: 10px';
const SHADOW = 'box-shadow: 0 1px 3px rgba(0,0,0,0.06)';
const chev = '<svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#5C5C66" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><path d="m9 6 6 6-6 6"/></svg>';
const backSvg = '<svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="#1C1C1E" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><path d="m15 6-6 6 6 6"/></svg>';
const checkSvg = (c = '#16A34A') => `<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="${c}" stroke-width="3" stroke-linecap="round" stroke-linejoin="round" style="flex: none"><path d="m5 12 5 5 9-9"/></svg>`;
function shape(src, color, sz = 22) {
  const c = `fill="${color}" stroke="#fff" stroke-width="1.5"`;
  const m = { aws: `<path d="M12 3 22 20H2z" ${c}/>`, official: `<path d="M12 2 22 12 12 22 2 12z" ${c}/>`, community: `<circle cx="12" cy="12" r="9" ${c}/>`, global: `<rect x="3" y="3" width="18" height="18" rx="4" ${c}/>`, intel: `<path d="M12 2 4 5v6c0 5 3.4 9 8 11 4.6-2 8-6 8-11V5z" ${c}/>` };
  return `<svg width="${sz}" height="${sz}" viewBox="0 0 24 24">${m[src]}</svg>`;
}
// page pieces in the boards' language
const page = (inner, bg = '#F5F5F7') => `<div style="width: 390px; min-height: 844px; box-sizing: border-box; position: relative; background: ${bg}; font-family: ${FONT}; color: #1C1C1E; display: flex; flex-direction: column">${inner}<div style="height: 96px; flex: none"></div></div>`;
const hdr = (title, backTo, right = '', sub = '') => `<header style="padding: 52px 16px 12px; background: #FFFFFF; display: flex; flex-direction: column; gap: 4px"><div style="display: flex; align-items: center; justify-content: space-between; gap: 8px">${backTo ? `<a href="#" data-nav="${backTo}" aria-label="Back" data-testid="back" style="width: 40px; height: 40px; display: flex; align-items: center; justify-content: center; text-decoration: none; margin-left: -8px">${backSvg}</a>` : ''}<h1 style="margin: 0; flex: 1; font-size: 24px; font-weight: 700; letter-spacing: -0.3px">${title}</h1>${right}</div>${sub ? `<div style="font-size: 14px; color: #5C5C66">${sub}</div>` : ''}</header>`;
const body = (inner, gap = 14) => `<div style="padding: 14px 16px 0; display: flex; flex-direction: column; gap: ${gap}px">${inner}</div>`;
const card = (inner, extra = '') => `<section style="${CARD}; ${extra}">${inner}</section>`;
const label = (t, extra = '') => `<span style="${LAB}; ${extra}">${t}</span>`;
const muted = (t, size = 13) => `<div style="font-size: ${size}px; color: #5C5C66; line-height: 1.45">${t}</div>`;
const primary = (t, act, data = '', color = '#E8622A', shadow = 'rgba(232,98,42,0.25)') => `<button data-act="${act}" ${data} style="height: 54px; border: 0; border-radius: 14px; background: ${color}; color: #FFFFFF; font: 700 16px ${FONT}; display: flex; align-items: center; justify-content: center; gap: 8px; cursor: pointer; width: 100%; box-shadow: 0 6px 16px ${shadow}">${t}</button>`;
const secondary = (t, act, data = '') => `<button data-act="${act}" ${data} style="height: 48px; border: 1px solid #D9D6D0; border-radius: 14px; background: #FFFFFF; font: 600 14px ${FONT}; color: #1C1C1E; display: flex; align-items: center; justify-content: center; gap: 8px; cursor: pointer; width: 100%">${t}</button>`;
const ghost = (t, act, data = '') => `<button data-act="${act}" ${data} style="height: 44px; border: 0; background: transparent; font: 600 14px ${FONT}; color: #5C5C66; cursor: pointer; width: 100%">${t}</button>`;
const small = (t, act, data = '') => `<button data-act="${act}" ${data} style="height: 36px; padding: 0 14px; border: 1px solid #E3E6EA; border-radius: 10px; background: #FFFFFF; font: 600 13px ${FONT}; cursor: pointer">${t}</button>`;
const chip = (t, on, act, data = '', color = '#1C1C1E', tint = '#FAF9F7') => `<span data-act="${act}" ${data} style="height: 40px; padding: 0 16px; border-radius: 20px; border: ${on ? `2px solid ${color}; background: ${tint}; font-weight: 700` : '1.5px solid #E3E6EA; background: #FFFFFF; font-weight: 600'}; display: inline-flex; align-items: center; gap: 8px; font-size: 14px; cursor: pointer; box-sizing: border-box; color: ${on ? color : '#1C1C1E'}">${t}</span>`;
const group = (title, rows, bg = '#FFFFFF') => `<div style="display: flex; flex-direction: column; gap: 8px">${title ? label(title, 'padding: 0 4px') : ''}<div style="background: ${bg}; border-radius: 18px; display: flex; flex-direction: column; border: 1px solid rgba(0,0,0,0.04)">${rows.join('<div style="height: 1px; background: rgba(0,0,0,0.06); margin: 0 16px"></div>')}</div></div>`;
const row = (t, sub, act, data = '', subColor = '#5C5C66', right = chev) => `<a href="#" data-act="${act}" ${data} style="display: flex; align-items: center; gap: 12px; padding: 0 16px; min-height: 58px; text-decoration: none; color: #1C1C1E"><span style="flex: 1; display: flex; flex-direction: column; gap: 1px; padding: 10px 0"><span style="font-size: 15px; font-weight: 700">${t}</span>${sub ? `<span style="font-size: 12px; color: ${subColor}; font-weight: 500">${sub}</span>` : ''}</span>${right}</a>`;
const person = (initial, title, sub, right = '', color = '#E8622A', data = '') => `<div ${data} style="background: #FFFFFF; border-radius: 18px; ${SHADOW}; display: flex; align-items: center; gap: 12px; padding: 12px 16px; cursor: pointer"><span style="width: 44px; height: 44px; border-radius: 50%; background: ${color}; color: #FFFFFF; display: flex; align-items: center; justify-content: center; font-weight: 700; font-size: 16px; flex: none">${initial}</span><span style="flex: 1; display: flex; flex-direction: column; gap: 2px; min-width: 0"><span style="font-size: 16px; font-weight: 700">${title}</span><span style="font-size: 13px; color: #5C5C66">${sub}</span></span>${right}</div>`;
const pill = (t, bg = '#F0EEEA', color = '#3A3A42') => `<span style="height: 26px; padding: 0 10px; border-radius: 13px; background: ${bg}; font-size: 12px; font-weight: 700; color: ${color}; display: inline-flex; align-items: center">${t}</span>`;
const note = (t, bg = '#F0EEEA', color = '#3A3A42') => `<div style="padding: 12px 14px; background: ${bg}; border-radius: 14px; font-size: 13px; line-height: 1.45; color: ${color}">${t}</div>`;
const input = (id, ph, extra = '', val = '') => `<input id="${id}" ${extra} placeholder="${ph}" value="${esc(val)}" style="height: 48px; padding: 0 14px; border: 1.5px solid #E3E6EA; border-radius: 14px; font: 500 15px ${FONT}; outline: 0; box-sizing: border-box; width: 100%; background: #FFFFFF">`;
const radio = (title, sub, on, act, data = '') => `<div data-act="${act}" ${data} style="display: flex; align-items: flex-start; gap: 12px; padding: 14px 16px; border-radius: 16px; cursor: pointer; ${on ? 'border: 2px solid #1C1C1E; background: #FFFFFF; box-shadow: 0 6px 16px rgba(0,0,0,0.08)' : 'border: 1.5px solid #E3E6EA; background: #FFFFFF'}"><span style="width: 20px; height: 20px; border-radius: 50%; border: ${on ? '6px solid #1C1C1E' : '2px solid #D5D9DE'}; box-sizing: border-box; flex: none; margin-top: 2px"></span><span style="display: flex; flex-direction: column; gap: 4px"><span style="font-size: 15px; font-weight: 700">${title}</span>${sub ? `<span style="font-size: 13px; color: #3A3A42; line-height: 1.45">${sub}</span>` : ''}</span></div>`;
const toggle = (on, act, data = '') => `<span data-act="${act}" ${data} role="switch" aria-checked="${on}" style="width: 44px; height: 26px; border-radius: 13px; background: ${on ? '#16A34A' : '#D5D9DE'}; position: relative; flex: none; cursor: pointer"><span style="position: absolute; top: 3px; left: ${on ? '21px' : '3px'}; width: 20px; height: 20px; border-radius: 50%; background: #FFFFFF; box-shadow: 0 1px 3px rgba(0,0,0,0.2)"></span></span>`;

// ---------- DOM helpers for binding into board markup
const walk = (root, fn) => { const it = document.createNodeIterator(root, NodeFilter.SHOW_ELEMENT); let n; while ((n = it.nextNode())) if (fn(n)) return n; return null; };
const ownText = (el) => [...el.childNodes].filter((n) => n.nodeType === 3).map((n) => n.textContent).join('').trim();
const byText = (root, text) => walk(root, (el) => ownText(el) === text);
const byTextStart = (root, text) => walk(root, (el) => ownText(el).startsWith(text));
const byTextIn = (root, text, sel) => walk(root, (el) => ownText(el) === text && el.closest(sel));
const setText = (root, old, val) => { const el = byText(root, old); if (el) { [...el.childNodes].filter((n) => n.nodeType === 3).forEach((n) => (n.textContent = '')); el.appendChild(document.createTextNode(val)); } return el; };
function act(el, action, data = {}, testid) { if (!el) return; const t = el.closest('a,button') || el; t.dataset.act = action; delete t.dataset.nav; Object.entries(data).forEach(([k, v]) => (t.dataset[k] = v)); if (testid) t.dataset.testid = testid; t.style.cursor = 'pointer'; return t; }
function navTo(el, name, testid) { if (!el) return; const t = el.closest('a,button') || el; t.dataset.nav = name; delete t.dataset.act; if (testid) t.dataset.testid = testid; t.style.cursor = 'pointer'; return t; }
const html = (s) => { const d = document.createElement('div'); d.innerHTML = s; return d.firstElementChild; };

// Family circle state: red while an SOS is live, teal when a check-in is asked of you, indigo at rest (Sarah 9 Oct: not orange).
function famState() { if (st.sos.some((s) => s.active && (s.userId === me() || st.circles.some((c) => c.circleId === s.circleId)))) return 'sos'; if ((st.ciReqs || []).some((x) => x.waitingOn.some((w) => w.id === me())) || (st.circles || []).some((c) => c.waitingOnMe)) return 'ask'; return 'idle'; }

// ---------- footer (from the Main board)
const TAB_OF = { Main: 'Main', Places: 'Main', selectloc: 'Main', route: 'Main', travelling: 'Main', Feed: 'Feed', Offline: 'Feed', notes: 'Feed', Detail: 'Feed', Ex1: 'Feed', Ex2: 'Feed', Ex3: 'Feed', Community: 'Feed', Report: 'Report', Posted: 'Report', Ready: 'Ready', Learn: 'Ready', guide: 'Ready', Plan: 'Ready', Drill: 'Ready', Safety: 'Ready', Family: 'Family', FamilyEmpty: 'Family', journey: 'Family', invite: 'Family', groupsettings: 'Family', switchgroup: 'Family', circleprofile: 'Family', sharing: 'Family', famplaces: 'Family', soslists: 'Family', soslistedit: 'Family', sosreceiver: 'Family', sosresolved: 'Family', soshistory: 'Family', sharedjourney: 'Family', grouppaused: 'Family', plan_cover: 'Family', rollcall: 'Family', Profile: 'Profile', managenotes: 'Profile', accessible: 'Profile', points: 'Profile', leaderboard: 'Profile', badges: 'Profile', childmode: 'Profile', blocked: 'Profile', support: 'Profile', deleteacct: 'Profile', manage: 'Profile', myalrts: 'Profile' };
function footer(active) {
  if (st.igFooter) return igFooter(active);
  const el = html(window.NAV); el.style.position = 'absolute'; el.style.pointerEvents = 'auto';
  const links = $$('a[data-nav]', el);
  const ON = 'rgba(232,98,42,0.10)';
  links.forEach((a) => {
    const target = a.dataset.nav; const isFam = target === 'Family';
    const on = (target === active) || (isFam && active === 'Family');
    if (a.getAttribute('aria-label') === 'Me') { const av = a.firstElementChild; av.textContent = (st.user?.name || 'S')[0].toUpperCase(); av.style.boxShadow = on ? '0 0 0 2px #FFFFFF, 0 0 0 4px #E8622A' : ''; a.dataset.testid = 'tab-me'; return; }
    if (target === 'Report') { a.dataset.testid = 'tab-report'; if (st.user?.childMode) a.style.display = 'none'; return; }
    const fs = famState();
    a.style.background = on ? (isFam ? (fs === 'sos' ? 'rgba(218,31,45,0.12)' : fs === 'ask' ? 'rgba(13,148,136,0.12)' : 'rgba(61,61,223,0.10)') : ON) : '';
    a.style.color = isFam ? (fs === 'sos' ? '#DA1F2D' : fs === 'ask' ? R.brand.teal : '#3D3DDF') : on ? '#E8622A' : '#5C5C66';
    if (isFam) { a.dataset.state = fs; let dot = a.querySelector('span'); if (fs !== 'idle') { if (!dot) { dot = document.createElement('span'); a.appendChild(dot); } dot.style.cssText = `position: absolute; top: 7px; right: 14px; width: 8px; height: 8px; border-radius: 50%; border: 1.5px solid #FFFFFF; background: ${fs === 'sos' ? '#DA1F2D' : R.brand.teal}`; } else if (dot) dot.remove(); }
    a.dataset.testid = 'tab-' + { Main: 'alerts', Feed: 'feed', Ready: 'ready', Family: 'family' }[target];
    if (target === 'Feed') { const dot = $('span', a); if (dot) dot.style.display = st.notes.length > st.seenNotes ? '' : 'none'; }
  });
  return el;
}

// Instagram-style alternative (dev toggle): same six elements and colours, icon only, flat frosted bar.
function igFooter(active) {
  const el = html(window.NAV); el.style.position = 'absolute'; el.style.pointerEvents = 'auto';
  const bar = el.firstElementChild; bar.style.borderRadius = '0'; bar.style.height = '58px'; bar.style.margin = '0 -16px -12px'; bar.style.boxShadow = 'none'; bar.style.border = '0'; bar.style.borderTop = '1px solid rgba(0,0,0,0.06)'; bar.style.background = 'rgba(255,255,255,0.96)';
  $$('a[data-nav]', el).forEach((a) => {
    const target = a.dataset.nav; const isFam = target === 'Family'; const on = target === active;
    [...a.childNodes].forEach((n) => { if (n.nodeType === 3) n.remove(); });
    a.style.background = ''; a.style.fontSize = '0';
    const svg = a.querySelector('svg'); if (svg && target !== 'Report') { svg.setAttribute('width', '27'); svg.setAttribute('height', '27'); if (on) svg.setAttribute('fill', 'currentColor'); }
    if (a.getAttribute('aria-label') === 'Me') { const av = a.firstElementChild; av.textContent = (st.user?.name || 'S')[0].toUpperCase(); av.style.width = av.style.height = '28px'; av.style.boxShadow = on ? '0 0 0 2px #FFFFFF, 0 0 0 3.5px #E8622A' : ''; a.dataset.testid = 'tab-me'; return; }
    if (target === 'Report') { a.dataset.testid = 'tab-report'; if (st.user?.childMode) a.style.display = 'none'; return; }
    const fs2 = famState(); a.style.color = isFam ? (fs2 === 'sos' ? '#DA1F2D' : fs2 === 'ask' ? R.brand.teal : '#3D3DDF') : on ? '#E8622A' : '#2B2B30'; if (isFam) a.dataset.state = fs2;
    a.dataset.testid = 'tab-' + { Main: 'alerts', Feed: 'feed', Ready: 'ready', Family: 'family' }[target];
    if (target === 'Feed') { const dot = $('span', a); if (dot) { dot.style.display = st.notes.length > st.seenNotes ? '' : 'none'; dot.style.top = '10px'; } }
  });
  return el;
}

// ---------- rendering
function draw(soft) {
  const scr = $('#screen'); if (!scr || !R) return;
  const name = st.screen === 'main' ? st.tab : st.screen;
  let node;
  if (window.BOARDS[name]) { node = html(window.BOARDS[name]); if (BIND[name]) BIND[name](node); }
  else if (typeof EXTRA !== 'undefined' && EXTRA[name]) { node = html(EXTRA[name]()); }
  else node = html(page(hdr('Not built', 'Main')));
  if (st.screen === 'main' && !['Main', 'Places'].includes(name) && !node.querySelector('[data-spacer]')) { const sp = document.createElement('div'); sp.dataset.spacer = '1'; sp.style.cssText = 'height: 96px; flex: none'; node.appendChild(sp); }
  const strips = st.screen === 'main' ? stripsHtml() : '';
  const over = sheetHtml() + (st.toast ? `<div data-testid="toast" style="position: absolute; left: 16px; right: 16px; top: 54px; z-index: 40; background: #1C1C1E; color: #FFFFFF; padding: 12px 14px; border-radius: 14px; font: 500 14px ${FONT}; box-shadow: 0 10px 30px rgba(0,0,0,0.2)">${esc(st.toast)}</div>` : '') + (st.lock ? lockHtml() : '');
  const out = strips + node.outerHTML;
  const ov = $('#overlay'); if (ov.dataset.last !== over) { ov.dataset.last = over; ov.innerHTML = over; }
  const keep = scr.scrollTop;
  if (soft && scr.dataset.last === out) return;
  scr.dataset.last = out; scr.innerHTML = out; if (soft) scr.scrollTop = keep; else scr.scrollTop = 0;
  const nw = $('#navwrap'); nw.innerHTML = ''; if (st.screen === 'main' && TAB_OF[name] && !st.lock) nw.appendChild(footer(TAB_OF[name]));
  const b = $('#bill'); if (b) b.textContent = st.access ? (st.access.billingEnabled ? 'on' : 'off') : 'on';
  const o = $('#off'); if (o) o.textContent = st.offline ? 'on' : 'off';
}
function stripsHtml() {
  let s = '';
  if (st.offline) s += `<div data-testid="offline" style="position: sticky; top: 0; z-index: 30; background: #1C1C1E; color: #FFFFFF; padding: 10px 16px; font: 600 13px ${FONT}">Offline. Showing alerts as of ${st.lastSync ? st.lastSync.toTimeString().slice(0, 5) : 'earlier'}.</div>`;
  const s0 = mySos();
  if (s0) { const left = Math.max(0, s0.endsAt - s0.serverNow); s += `<div data-testid="sos-banner" style="position: sticky; top: 0; z-index: 30; background: linear-gradient(145deg, #C8102E, #7A0012); color: #FFFFFF; padding: 12px 16px; font: 600 13px ${FONT}; display: flex; flex-wrap: wrap; gap: 8px; align-items: center"><span style="flex: 1">Your SOS is live. Ends in ${String(Math.floor(left / 60000)).padStart(2, '0')} min.${s0.endingSoon ? ' <b data-testid="ending-soon">Ending soon</b>' : ''}</span>${pill('Extend 1 hour', 'rgba(255,255,255,0.2)', '#FFFFFF').replace('<span', `<span data-act="sosextend" data-id="${s0.id}" data-testid="sos-extend" style="cursor:pointer;`)}${pill('End my SOS', '#FFFFFF', '#7A0012').replace('<span', `<span data-act="sosstop" data-id="${s0.id}" data-testid="sos-stop" style="cursor:pointer;`)}</div>`; }
  else if (st.tab !== 'sosreceiver') { const sa = mySosAny(); if (sa) s += `<div data-act="viewsosbanner" data-testid="sos-strip" style="position: sticky; top: 0; z-index: 30; background: linear-gradient(145deg, #C8102E, #7A0012); color: #FFFFFF; padding: 12px 16px; font: 600 13px ${FONT}; cursor: pointer">SOS from ${esc(nm(sa.userId))} is live. Tap to respond.</div>`; }
  if ((st.locReqs || []).length && !st.sheet) s += `<div data-act="openlocreq" data-testid="loc-strip" style="position: sticky; top: 0; z-index: 30; background: #FFF4EE; color: #B84500; padding: 12px 16px; font: 600 13px ${FONT}; cursor: pointer">${esc(st.locReqs[0].requester.name)} asked where you are. Tap to answer.</div>`;
  return s;
}
function lockHtml() { const n = st.notes[0]; return `<div data-act="unlock" data-testid="lock" style="position: absolute; inset: 0; z-index: 50; background: linear-gradient(#26324a, #0f1522); color: #FFFFFF; padding: 70px 16px; font-family: ${FONT}"><div style="font-size: 64px; font-weight: 300; text-align: center; letter-spacing: -2px">9:41</div><div style="text-align: center; opacity: .7; font-size: 14px">Thursday 8 October</div>${n ? `<div style="margin-top: 24px; background: rgba(255,255,255,0.16); border-radius: 18px; padding: 12px 14px; backdrop-filter: blur(8px); display: flex; gap: 10px"><span style="width: 36px; height: 36px; border-radius: 9px; background: linear-gradient(135deg, #FF6B00, #FF0004); flex: none"></span><span><b>${esc(n.title)}</b><div style="font-size: 14px; opacity: .9">${esc(n.body)}</div></span></div>` : '<div style="margin-top: 24px; text-align: center; opacity: .7">No notifications</div>'}<div style="text-align: center; margin-top: 24px; opacity: .6; font-size: 13px">Tap to close</div></div>`; }

// ---------- per-board bindings
const BIND = {};
BIND.Splash = (r) => { navTo(byText(r, 'Get started'), 'Onb1', 'onb-next'); navTo(byText(r, 'I already have an account'), 'Onb5', 'have-account'); };
BIND.Onb1 = (r) => {
  r.dataset.testid = 'onb0';
  ['Just me', 'My family', 'My team'].forEach((t) => { const el = byText(r, t); if (!el) return; const on = st.onb.who === { 'Just me': 'me', 'My family': 'family', 'My team': 'team' }[t]; act(el, 'onbwho', { who: { 'Just me': 'me', 'My family': 'family', 'My team': 'team' }[t] }); if (on) { el.style.border = '2px solid #1C1C1E'; el.style.background = '#FAF9F7'; el.style.fontWeight = '700'; } else { el.style.border = '1.5px solid #E3E6EA'; el.style.background = '#FFFFFF'; } });
  navTo(byText(r, 'Get started'), 'Onb2', 'onb-next');
};
BIND.Onb2 = (r) => {
  r.dataset.testid = 'onb1';
  const items = ['ALRT is not an emergency service', 'Your location leaves your phone only when you send it', 'Community reports are not verified by authorities'];
  items.forEach((t, i) => { const el = byText(r, t); if (!el) return; const cardEl = el.closest('div[style*="box-shadow"]'); act(cardEl, 'onbagree', { i }); const box = cardEl.firstElementChild; if (st.onb.agreed.includes(i)) { box.innerHTML = checkSvg('#FFFFFF'); box.style.background = '#16A34A'; } });
  const age = byText(r, 'I am 16 or older, or local law allows me to use this app'); if (age) { const cardEl = age.closest('div[style*="box-shadow"]'); act(cardEl, 'onbagree', { i: 3 }, 'age'); const box = cardEl.firstElementChild; if (st.onb.agreed.includes(3)) { box.style.background = '#1C1C1E'; box.style.border = '0'; box.innerHTML = checkSvg('#FFFFFF'); } }
  const btn = byText(r, 'Agree and continue'); const all = st.onb.agreed.length === 4; act(btn, 'onbagreego', {}, 'onb-next'); if (btn) btn.style.opacity = all ? '1' : '0.45';
};
BIND.Onb3 = (r) => {
  r.dataset.testid = 'onb2';
  const map = { 'Official warnings only': 'official', 'Official and community': 'all', 'Keep it quiet': 'quiet' };
  Object.entries(map).forEach(([t, id]) => { const el = byText(r, t); if (!el) return; const cardEl = el.closest('div[style*="border-radius: 16px"]'); act(cardEl, 'lvl', { id }); cardEl.dataset.id = id; const on = st.onb.level === id; cardEl.style.border = on ? '2px solid #1C1C1E' : '1.5px solid #E3E6EA'; cardEl.style.boxShadow = on ? '0 6px 16px rgba(0,0,0,0.08)' : ''; cardEl.firstElementChild.style.border = on ? '6px solid #1C1C1E' : '2px solid #D5D9DE'; });
  act(byText(r, 'Turn on alerts'), 'onbprime', {}, 'onb-next'); navTo(byText(r, 'Not now'), 'Onb4', 'onb-later');
};
BIND.Onb4 = (r) => { r.dataset.testid = 'onb3'; navTo(byText(r, 'Continue with ALRT Free'), 'Onb5', 'onb-next'); navTo(byText(r, 'See ALRT + plans'), 'Choose', 'onb-plans'); };
BIND.Onb5 = (r) => {
  r.dataset.testid = 'onb4';
  act(byText(r, 'Continue with Apple'), 'oauth', { p: 'apple' }); act(byText(r, 'Continue with Google'), 'oauth', { p: 'google' }); act(byText(r, 'Continue with Microsoft'), 'oauth', { p: 'microsoft' });
  const em = byText(r, 'Continue with Email'); if (em) em.remove();
  const sub0 = byText(r, 'An account keeps your places, settings and points across phones. You can also just look around.'); if (sub0) sub0.textContent = 'An account keeps your places, settings and points across phones. ALRT never creates or stores a password: you sign in with Apple, Google or Microsoft.';
  const g = byTextStart(r, 'Look around first'); if (g) g.remove(); const gn = byTextStart(r, 'Guest mode is not built'); if (gn) gn.remove();
  const ap = byText(r, 'Continue with Apple'); if (ap) ap.dataset.testid = 'oauth-apple'; const go0 = byText(r, 'Continue with Google'); if (go0) go0.dataset.testid = 'oauth-google';
  const sub = byText(r, 'Alerts on · you choose your places on the map next'); if (sub && !st.primed) sub.textContent = 'You can turn alerts on later in Notifications';
};
BIND.Choose = (r) => {
  navTo(byText(r, 'For myself'), 'Paywall', 'pick-ind'); navTo(byText(r, 'Cover a group'), 'GroupPaywall', 'pick-grp');
  act(r.querySelector('a[aria-label="Back"]'), 'closepay', {}, 'back'); act(byText(r, 'Continue with ALRT Free'), 'closepay', {}, 'continue-free');
  setText(r, 'A$5.99 a month · 2-week free trial', `${money(R.plans.individual.priceAud)} a month · ${R.plans.individual.trialDays / 7}-week free trial`);
  setText(r, 'from A$15.99 a month', `from ${money(R.plans.family.priceAud)} a month`);
};
const CTX = { place: 'Free includes 1 saved place. ALRT + has no limit.', ask: `Free includes ${3} questions a day. ALRT + includes ${10}.`, circle: 'Check in, Check on, SOS and Journey in a group need ALRT + for each person, or a plan covering the group.', me: '' };
BIND.Paywall = (r) => {
  r.dataset.testid = 'paywall-ind';
  navTo(r.querySelector('a[aria-label="Back"]'), 'Choose', 'back');
  setText(r, 'A$5.99', money(R.plans.individual.priceAud)); setText(r, 'Start 2 weeks free', `Start ${R.plans.individual.trialDays / 7} weeks free`);
  const b = byTextStart(r, 'Start '); act(b, 'buy', {}, 'buy'); if (b) b.dataset.testid = 'buy';
  act(byText(r, 'Restore purchases'), 'restore', {}, 'restore');
  const box = byTextStart(r, 'Covers you, wherever you are'); if (box && CTX[st.paywallCtx]) { const c = box.cloneNode(true); c.textContent = CTX[st.paywallCtx]; c.dataset.testid = 'ctx'; c.style.background = '#FFF4EE'; box.parentElement.insertBefore(c, box); }
  const pr = byText(r, 'A$5.99'); if (pr) pr.dataset.testid = 'price';
  const foot = byTextStart(r, 'Eligible subscribers only'); if (foot) foot.textContent = `Eligible subscribers only. A$0.00 today, then ${money(R.plans.individual.priceAud)}/month after ${R.plans.individual.trialDays / 7} weeks. Renews automatically unless cancelled. Manage or cancel in your App Store account.`;
};
BIND.GroupPaywall = (r) => {
  r.dataset.testid = 'paywall-grp';
  navTo(r.querySelector('a[aria-label="Back"]'), 'Choose', 'back');
  const c = circ(); const tier = st.grpTier || 'family';
  setText(r, 'Nixon group', c ? c.name : 'No group yet'); setText(r, '4 people · you host', c ? `${c.peopleCount} people · ${c.ownerId === me() ? 'you host' : 'hosted by ' + nm(c.ownerId)}` : 'Create a group in Family first');
  const cards = [['Family', 'family'], ['Group 20', 'group20'], ['Group 50', 'group50']];
  cards.forEach(([t, k]) => { const el = byText(r, t); if (!el) return; const cardEl = el.parentElement; act(cardEl, 'grptier', { k }, 'buy-' + k); const on = tier === k; cardEl.style.border = on ? '2px solid transparent' : '1.5px solid #E3E6EA'; cardEl.style.background = on ? 'linear-gradient(135deg, #05603B, #17A96A)' : '#FFFFFF'; cardEl.style.boxShadow = on ? '0 8px 18px rgba(10,127,79,0.3)' : ''; [...cardEl.children].forEach((ch, i) => { ch.style.color = on ? (i === 0 || i === 2 ? '#FFFFFF' : 'rgba(255,255,255,0.85)') : (i === 0 || i === 2 ? '#1C1C1E' : '#5C5C66'); }); });
  const cap = R.plans[tier].capacity; const info = byTextStart(r, 'Covers everyone in'); if (info) info.textContent = `Covers everyone in ${c ? c.name : 'your group'}, up to ${cap} people, you included. It does not change anyone's own saved places or Ask ALRT questions; those come with ALRT +.`;
  const sub = byTextStart(r, 'Subscribe for'); if (sub) { sub.textContent = `Subscribe for ${money(R.plans[tier].priceAud)}/month`; act(sub, 'buygrp', { k: tier }, 'buy-grp'); }
  const t0 = byText(r, 'ALRT + Family'); if (t0) t0.textContent = R.plans[tier].label;
};

// Alerts tab (Feed board)
function feedRow(h) {
  const colour = bandColor(h); const label = { aws: h.level || 'Advice', official: 'Official', community: 'Community · Unverified', global: 'Global', intel: 'ALRT Assessment' }[h.source];
  const icon = h.source === 'aws' ? `<span style="width: 0; height: 0; border-left: 7px solid transparent; border-right: 7px solid transparent; border-bottom: 12px solid ${colour}"></span>`
    : h.source === 'official' ? `<span style="width: 10px; height: 10px; background: ${colour}; transform: rotate(45deg); border-radius: 2px; margin: 0 2px"></span>`
    : h.source === 'community' ? `<span style="width: 22px; height: 22px; border-radius: 50%; background: radial-gradient(circle at 35% 30%, rgba(255,255,255,0.45), rgba(255,255,255,0) 55%), ${colour}; display: flex; align-items: center; justify-content: center"></span>`
    : h.source === 'global' ? `<span style="width: 12px; height: 12px; border-radius: 3px; background: ${colour}"></span>`
    : shape('intel', colour, 16);
  const lc = h.source === 'aws' ? bandText[h.band] : h.source === 'community' ? '#B84500' : '#3A3A42';
  const sub = h.source === 'community' ? `Confirmed by ×${h.confirmations} · ${h.distance || 'near you'}` : `${esc(h.agency || '')}${h.distance ? ' · ' + h.distance : ''}`;
  return `<a href="#" data-act="open" data-id="${h.id}" data-testid="alert-${h.source}" style="display: block; text-decoration: none; color: #1C1C1E; background: #FFFFFF; border-radius: 18px; overflow: hidden; box-shadow: 0 1px 3px rgba(0,0,0,0.06)">${h.source === 'community' ? '' : `<div style="height: 5px; background: ${colour}"></div>`}<div style="padding: 12px 14px; display: flex; flex-direction: column; gap: 6px"><div style="display: flex; align-items: center; gap: 8px">${icon}<span style="font-size: 12px; font-weight: 700; letter-spacing: 0.4px; text-transform: uppercase; color: ${lc}">${label}</span><span style="margin-left: auto; font-size: 12px; color: #5C5C66">${ago(h)}</span></div><div style="font-size: 17px; font-weight: 700; line-height: 1.25">${esc(h.title)}</div><div style="display: flex; align-items: center; gap: 8px; font-size: 13px; color: #5C5C66">${h.source === 'official' && h.category ? `<span style="width: 8px; height: 8px; border-radius: 50%; background: ${R.categories[h.category]?.color}"></span>` : ''}${sub}</div></div></a>`;
}
function visibleHazards() { const f = st.filters; return st.hazards.filter((h) => !f || (f.sources.includes(h.source) && (h.source === 'community' || f.bands.includes(h.band)) && f.cats.includes(h.category))); }
BIND.Feed = (r) => {
  const first = r.querySelector('a[data-nav]'); const list = first.parentElement; list.innerHTML = '';
  const hz = visibleHazards(); if (!hz.length) list.innerHTML = note('Nothing near you right now. Save a place to see alerts there.');
  hz.forEach((h) => list.insertAdjacentHTML('beforeend', feedRow(h)));
  const filt = r.querySelector('button[aria-label="Filters"]'); act(filt, 'openfilters', {}, 'filters-btn');
  const bell = filt.cloneNode(true); bell.setAttribute('aria-label', 'Notifications'); bell.innerHTML = '<svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#1C1C1E" stroke-width="2" stroke-linecap="round"><path d="M18 8a6 6 0 0 0-12 0c0 7-3 9-3 9h18s-3-2-3-9"/><path d="M13.7 21a2 2 0 0 1-3.4 0"/></svg>'; act(bell, 'opennotes', {}, 'bell'); filt.parentElement.insertBefore(bell, filt);
  const ask = filt.cloneNode(true); ask.setAttribute('aria-label', 'Ask ALRT'); ask.style.background = '#FFF1E8'; ask.style.border = '0'; ask.innerHTML = '<svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#E8622A" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 3l1.8 4.6L18.5 9.5l-4.7 1.9L12 16l-1.8-4.6L5.5 9.5l4.7-1.9z"/></svg>'; act(ask, 'ask', {}, 'ask-btn'); filt.parentElement.insertBefore(ask, bell);
};
BIND.Offline = (r) => {
  const t = st.lastSync ? st.lastSync.toTimeString().slice(0, 5) : '9:14 am';
  setText(r, 'Showing alerts from 9:14 am.', `Showing alerts from ${t}.`); $$('span', r).forEach((s) => { if (ownText(s) === 'As of 9:14 am') s.textContent = 'As of ' + t; });
  act(byText(r, 'Retry'), 'retry', {}, 'retry');
};
BIND.Main = (r) => {
  r.dataset.testid = 'map';
  const hz = visibleHazards(); const warn = hz.filter((h) => ['critical', 'action'].includes(h.band) && h.source !== 'community').length;
  const ban = byTextStart(r, '1 warning near you'); if (ban) { ban.textContent = warn ? `${warn} warning${warn > 1 ? 's' : ''} near you. See what to do` : 'No warnings near you right now'; ban.dataset.nav = 'Feed'; ban.dataset.testid = 'map-banner'; const dot = ban.previousElementSibling; if (dot) dot.style.background = warn ? '#DA1F2D' : '#16A34A'; }
  const lab = r.querySelector('label[for="map-search"]'); if (lab) { const inp = lab.querySelector('input'); if (inp) { inp.setAttribute('readonly', ''); act(inp, 'tab', { tab: 'Places' }, 'places-btn'); } }
  const askB = r.querySelector('button[aria-label="Ask ALRT"]'); act(askB, 'ask', {}, 'ask-btn');
  const mic = askB.cloneNode(true); mic.setAttribute('aria-label', 'Speak to search'); mic.style.background = '#F5F5F7'; mic.innerHTML = '<svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#3A3A42" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="9" y="3" width="6" height="11" rx="3"/><path d="M5 11a7 7 0 0 0 14 0M12 18v3"/></svg>'; act(mic, 'voice', {}, 'mic-btn'); askB.insertAdjacentElement('beforebegin', mic);
  const inp0 = lab && lab.querySelector('input'); if (inp0 && st.voiceText) inp0.value = st.voiceText;
  act(r.querySelector('button[aria-label="Map layers"]'), 'openfilters', {}, 'filters-btn'); navTo(r.querySelector('button[aria-label="List view"]'), 'Feed', 'view-toggle'); act(r.querySelector('button[aria-label="Map key"]'), 'mapkey'); act(r.querySelector('button[aria-label="My location"]'), 'toast', { m: 'Centred on you. Location is only used on your phone.' });
  const myLoc = r.querySelector('button[aria-label="My location"]'); const rt = myLoc.cloneNode(true); rt.setAttribute('aria-label', 'Check a route'); rt.innerHTML = '<svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="#1C1C1E" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="6" cy="19" r="2.5"/><circle cx="18" cy="5" r="2.5"/><path d="M8 18h6a3 3 0 0 0 0-6h-4a3 3 0 0 1 0-6h6"/></svg>'; act(rt, 'tab', { tab: 'route' }, 'route-btn'); myLoc.insertAdjacentElement('afterend', rt);
  // pins: bind the designed markers to live hazards by shape
  const pins = $$('div[style*="position: absolute"][style*="top: 300px"], div[style*="top: 360px"], div[style*="top: 470px"], div[style*="top: 520px"]', r);
  const bySrc = (s) => hz.find((h) => h.source === s);
  const targets = [bySrc('aws'), bySrc('official'), hz.find((h) => h.source === 'community' && h.category === 'traffic') || bySrc('community'), hz.find((h) => h.source === 'community' && h.category === 'weather') || bySrc('intel')];
  pins.forEach((p, i) => { const h = targets[i]; if (h) { act(p, 'open', { id: h.id }, 'pin-' + h.source); } else p.style.display = 'none'; });
  const done = [st.primed, st.places.length > 0, myCohorts().length > 0, false]; const n = done.filter(Boolean).length;
  setText(r, '1 of 4 done', `${n} of 4 done`);
  const chips = $$('a[data-nav]', r).filter((a) => a.style.width === '148px');
  const targetsChip = ['Places', 'Safety', 'accessible']; chips.forEach((c, i) => { c.dataset.nav = targetsChip[i]; if (done[i + 1] || (i === 2 && false)) c.style.opacity = '0.55'; });
};
BIND.Places = (r) => {
  const rows = r.querySelector('div[style*="border: 1px solid #ECEEF1"]'); const tpl = rows.children[2];
  while (rows.children.length > 1) rows.lastElementChild.remove();
  st.places.forEach((p) => { rows.insertAdjacentHTML('beforeend', '<div style="height: 1px; background: #ECEEF1; margin: 0 16px"></div>'); const row2 = tpl.cloneNode(true); row2.dataset.testid = 'place-row'; setText(row2, 'Scarborough', p.name); setText(row2, 'Scarborough WA 6019 · 2 alerts now', `${p.radiusKm} km radius`); const b = row2.querySelector('button'); b.textContent = 'Remove'; act(b, 'unsub', { id: p.id }); rows.appendChild(row2); });
  act(rows.querySelector('button'), 'toast', { m: 'Radius is set in Notifications' });
  const lab = r.querySelector('label[for="add-place"]'); const inp = lab.querySelector('input'); inp.dataset.testid = 'place-name'; inp.id = 'pn'; lab.removeAttribute('for');
  const add = html(small('Add', 'addplace', 'data-testid="add-place"')); lab.lastElementChild.replaceWith(add);
  const up = byText(r, 'One saved place on ALRT Free'); const upsell = up && up.parentElement;
  if (upsell) { if (st.access?.personal?.plan === 'individual' || !st.access?.billingEnabled) upsell.style.display = 'none'; else { act(upsell.querySelector('a'), 'paywall', { ctx: 'place' }, 'see-plus'); } }
  const hint = byText(r, 'Swipe a place left to remove it.'); if (hint) hint.textContent = st.places.length ? 'Tap Remove to stop alerts for a place.' : 'Search above to add your first place.';
  act(r.querySelector('div[style*="rgba(23,23,26,0.35)"]'), 'tab', { tab: 'Main' });
};
BIND.Report = (r) => {
  r.dataset.testid = 'report';
  const rep = st.rep || (st.rep = { obs: null });
  navTo(r.querySelector('a[aria-label="Close"]'), 'Main', 'report-close');
  const catNames = { Weather: 'weather', 'Health and air': 'health', 'Security and crime': 'security', 'Traffic and transport': 'traffic', Utilities: 'utilities', Community: 'community', Other: 'other' };
  Object.entries(catNames).forEach(([t, k]) => { const el = byText(r, t); if (!el) return; act(el, 'repcat', { k }, 'cat-' + k); const on = rep.cat === k; const col = R.categories[k].color; el.style.border = on ? `2px solid ${col}` : '1.5px solid #E3E6EA'; el.style.background = on ? col + '1A' : ''; el.style.fontWeight = on ? '700' : '600'; });
  const OBS = { traffic: ['Crash', 'Road blocked', 'Heavy traffic', 'Broken down vehicle', 'Something else'], weather: ['Water over the road', 'Fallen tree', 'Hail', 'Flooding', 'Something else'], health: ['Smoke', 'Bad air', 'Chemical smell', 'Something else'], security: ['Suspicious activity', 'Break-in', 'Fight', 'Something else'], utilities: ['Power outage', 'Burst water main', 'Gas smell', 'Something else'], community: ['Lost pet', 'Event', 'Road works', 'Something else'], other: ['Something else'] };
  const obsWrap = byText(r, 'Crash').parentElement; obsWrap.innerHTML = (OBS[rep.cat] || OBS.traffic).map((o) => `<span data-act="repobs" data-o="${esc(o)}" style="height: 40px; padding: 0 16px; border-radius: 20px; display: flex; align-items: center; font-size: 14px; font-weight: 600; cursor: pointer; ${rep.obs === o ? 'border: 2px solid #1C1C1E; background: #1C1C1E; color: #FFFFFF' : 'border: 1.5px solid #E3E6EA'}">${esc(o)}</span>`).join('');
  [['Minor', 'minor'], ['Significant', 'significant'], ['Dangerous', 'dangerous']].forEach(([t, k]) => { const el = byText(r, t); if (!el) return; const cardEl = el.parentElement; act(cardEl, 'repsev', { k }); const on = (rep.sev || 'significant') === k; cardEl.style.border = on ? '2px solid #1C1C1E' : '1.5px solid #E3E6EA'; cardEl.style.background = on ? '#FAF9F7' : ''; });
  const loc = 'Scarborough'; st.loc = loc; const adj = byText(r, 'Adjust'); if (adj) adj.remove(); setText(r, 'Your current location · suburb only', 'Where you are now · suburb only · reports are posted from your actual location'); const locRow = byText(r, 'Scarborough'); if (locRow) locRow.closest('div[style*="border-radius: 18px"]').dataset.testid = 'rep-loc';
  const head = byTextStart(r, 'Crash reported in'); if (head) head.textContent = `${rep.obs || (rep.cat ? R.categories[rep.cat].name : 'Something')} reported in ${loc}`;
  const ta = r.querySelector('textarea'); if (ta) { ta.id = 'rb'; ta.value = rep.text || ''; }
  act(byText(r, 'Submit report'), 'post', {}, 'post');
};
BIND.Posted = (r) => { r.dataset.testid = 'posted'; navTo(byText(r, 'Back to the map'), 'Main', 'done'); act(byText(r, 'See my reports'), 'loadmine', {}, 'mine-open'); act(byText(r, 'How points work'), 'loadpoints'); setText(r, '+10', `+${R.points.reportApproved}`); setText(r, '+5', `+${R.points.confirmedByNeighbour}`); setText(r, '+15', `+${R.points.matchesOfficial}`); const pts = st.pts?.points || 0; setText(r, '20 of 50 points', `${pts} points`); };
BIND.Profile = (r) => {
  const u = st.user || {}; const pl = st.access?.personal; const pts = st.pts?.points || 0; const lvl = [...R.points.levels].reverse().find((l) => pts >= l[1]); const next = R.points.levels.find((l) => l[1] > pts);
  const avEl = byText(r, 'S'); if (avEl) { if (u.photo) { avEl.textContent = ''; avEl.style.background = `url(${u.photo}) center/cover`; avEl.dataset.testid = 'profile-photo'; } else avEl.textContent = (u.name || 'S')[0].toUpperCase(); }
  setText(r, 'Sarah Nixon', u.name || ''); const ready = readiness();
  setText(r, 'ALRT Free · 62% ready', `${pl?.plan === 'individual' ? R.plans.individual.label + (pl.isTrial ? ' trial' : '') : R.plans.free.label} · ${ready.pct}% ready`);
  act(byText(r, 'Edit'), 'sheet', { sheet: 'photo' }, 'edit-profile');
  const xp = byTextStart(r, '340'); if (xp) { xp.firstChild.textContent = pts + ' '; xp.dataset.testid = 'points'; }
  const bar = r.querySelector('div[style*="width: 34%"]'); if (bar) bar.style.width = Math.min(100, Math.round((pts / 1500) * 100)) + '%';
  setText(r, 'Watcher', lvl[0]); const toNext = byTextStart(r, '410 XP to'); if (toNext) toNext.textContent = next ? `${next[1] - pts} XP to ${next[0]}` : 'Top level reached';
  act(byText(r, 'How points work'), 'loadpoints', {}, 'points-open');
  const plus = byText(r, 'Unlimited saved places. Try 2 weeks free.'); const plusCard = plus && plus.closest('a');
  if (plusCard) { if (pl?.plan === 'individual') { plus.textContent = 'You have ALRT +. Manage plans and group coverage.'; byText(plusCard, 'Explore').textContent = 'My plans'; act(plusCard, 'loadmanage', {}, 'manage-open'); } else { act(plusCard, 'paywall', { ctx: 'me' }, 'see-plus'); } }
  const left = 4 - ready.done; setText(r, '3 left', `${left} left`); const prog = byText(r, 'Finish setting up'); if (prog) { const tiles = prog.parentElement.nextElementSibling.children; const acts = [['Places', 'Save a place'], ['Safety', 'Safety profile'], ['accessible', 'Sound and vibration'], ['widgets', 'Add a widget']]; const doneList = [st.places.length > 0, myCohorts().length > 0, !!st.acc?.vib, !!st.widgetAdded]; [...tiles].forEach((tile, i) => { tile.style.background = doneList[i] ? '#E6F6EC' : '#FFFFFF'; tile.style.cursor = 'pointer'; navTo(tile, acts[i][0]); }); }
  const R2 = (t, action, data, testid, sub) => { const el = byTextIn(r, t, 'a'); if (!el) return; const a = el.closest('a'); if (action.startsWith('nav:')) navTo(a, action.slice(4), testid); else act(a, action, data || {}, testid); if (sub !== undefined) { const s = el.nextElementSibling; if (s) s.textContent = sub; } return a; };
  const lvlLabel = R.notifications.levels.find((l) => l.id === (u.settings?.level || 'official'))?.label || '';
  R2('Notifications', 'loadnotes', {}, 'notes-open', lvlLabel + ' · sound and vibration inside');
  R2('Saved places', 'nav:Places', {}, 'places-open', pl?.plan === 'individual' ? `${st.places.length} saved · no limit` : `${st.places.length} of 1 free used`);
  R2('Safety profile', 'nav:Safety', {}, 'safety-open', myCohorts().length ? `${myCohorts().length} selected · stored on your phone` : 'Not set up · stored on your phone');
  R2('Home screen widget', 'nav:widgets', {}, 'widgets-open');
  const c = circ(); R2('Family and check-ins', 'nav:Family', {}, 'family-open', c ? `${c.name} · ${c.peopleCount} people` : 'No group yet. Creating one is free.');
  R2('Journey sharing', 'nav:journey', {}, 'journey-open', st.journeys.length ? 'A journey is running' : 'Shared journeys and live trips');
  R2('Your points', 'loadpoints', {}, 'points-open2', `${pts} XP · see where they came from`);
  R2('Share ALRT', 'sheet', { sheet: 'sharealrt' }, 'share-open');
  R2('Help and feedback', 'nav:support', {}, 'support-open');
  R2('Child mode', 'nav:childmode', {}, 'child-open', u.childMode ? 'On · Report hidden' : 'Map, SOS and check-ins only');
  R2('Blocked accounts', 'loadblocked', {}, 'blocked-open');
  R2('Terms and privacy', 'sheet', { sheet: 'legal' }, 'legal-open');
  // rows the board did not draw: My plans, My ALRTs, Language, Accessible alerts
  const acct = byText(r, 'Your points').closest('div[style*="border-radius: 18px"]');
  const addRow = (t, sub, action, data, testid, navName) => { const a = acct.firstElementChild.cloneNode(true); setText(a, 'Your points', t); const s = byText(a, 'Your points') || a.querySelector('span span'); const subEl = a.querySelector('span span:last-child'); if (subEl) subEl.textContent = sub; if (navName) navTo(a, navName, testid); else act(a, action, data, testid); acct.insertAdjacentHTML('beforeend', '<div style="height: 1px; background: rgba(0,0,0,0.06); margin: 0 16px"></div>'); acct.appendChild(a); };
  addRow('My plans', pl?.plan === 'individual' ? 'Personal plan and group coverage' : 'ALRT Free · group coverage', 'loadmanage', {}, 'manage-open');
  addRow('My ALRTs', 'Reports you posted', 'loadmine', {}, 'mine-open');
  addRow('Accessible alerts', 'Strong vibration, read aloud', null, {}, 'accessible-open', 'accessible');
  addRow('Language', (u.language || 'en') === 'es' ? 'Español' : 'English', 'sheet', { sheet: 'language' }, 'language-open');
  act(byText(r, 'Log out'), 'logoutsheet', {}, 'signout'); act(byText(r, 'Delete account'), 'tab', { tab: 'deleteacct' }, 'delete-open');
};
function readiness() { const done = [st.primed, st.places.length > 0, !!circ() && circ().peopleCount > 1, !!st.plan, !!st.drill].filter(Boolean).length; return { done, pct: Math.round((done / 5) * 100) }; }
BIND.Ready = (r) => {
  const rd = readiness(); setText(r, '62%', rd.pct + '%'); const s = byTextStart(r, '3 of 5 steps done'); if (s) s.textContent = `${rd.done} of 5 steps done. Households with a plan act about twice as fast in an emergency.`;
  setText(r, 'Well on your way', rd.done >= 4 ? 'Nearly there' : rd.done >= 2 ? 'Well on your way' : 'Getting started');
  const steps = [['Turn on alerts', st.primed, 'sheet', { sheet: 'priming' }], ['Save home', st.places.length > 0, 'nav', 'Places'], ['Add one family member', !!circ() && circ().peopleCount > 1, 'nav', 'Family'], ['Pick a meeting point', !!st.plan, 'nav', 'Plan'], ['Run a family drill', !!st.drill, 'nav', 'Drill']];
  steps.forEach(([t, done, kind, v]) => { const el = byText(r, t); if (!el) return; const rowEl = el.closest('div[style*="display: flex"]'); if (kind === 'nav') navTo(rowEl, v); else act(rowEl, kind, v); const ic = rowEl.firstElementChild; if (ic) { ic.style.background = done ? '#16A34A' : '#FFFFFF'; ic.style.border = done ? '0' : '2px solid #D5D9DE'; ic.innerHTML = done ? checkSvg('#FFFFFF') : ''; } });
  navTo(byText(r, 'Set it now'), 'Plan', 'make-plan'); navTo(byText(r, 'Family drill'), 'Drill', 'drill-open'); navTo(byText(r, 'All guides'), 'Learn', 'learn-open'); navTo(byText(r, 'My plan'), 'Plan'); navTo(byText(r, 'Safety profile'), 'Safety');
  const g = byText(r, 'Bushfire: being prepared'); if (g) { navTo(g.closest('a, div[style*="cursor"]') || g.parentElement, 'Learn', 'learn-Bushfire'); }
};
BIND.Learn = (r) => {
  navTo(r.querySelector('a[data-nav="Ready"]'), 'Ready', 'back');
  const done = Object.keys(st.user?.guides || {}).length; setText(r, '2 of 27 guides read', `${done} of 27 guides read`); setText(r, '20 XP', `${done * R.points.guideComplete} XP`);
  act(byText(r, 'Read the guide'), 'guideopen', { t: 'Bushfire' }, 'guide-open');
  ['Flood: being prepared', 'Flood: during a flood', 'Flood: after a flood'].forEach((t) => { const el = byText(r, t); if (el) act(el.closest('div[style*="border-radius"]') || el.parentElement, 'guideopen', { t }); });
  $$('a[data-nav="Learn"]', r).forEach((a) => act(a, 'toast', { m: 'Guide list opens for this hazard' }));
};
BIND.Plan = (r) => {
  const opts = ['Leave early', 'Check in, then decide', 'Collect the kids first']; const sel = st.planPick || opts[0];
  opts.forEach((t) => { const el = byText(r, t); if (!el) return; const cardEl = el.closest('label'); act(cardEl, 'planpick', { t }); const on = sel === t; cardEl.style.border = on ? '2px solid #E8622A' : '2px solid #E3E6EA'; cardEl.style.background = on ? '#FFF4EE' : '#FFFFFF'; const rd = cardEl.querySelector('input'); if (rd) { rd.checked = on; rd.setAttribute('tabindex', '-1'); } });
  act(byText(r, 'Save and continue'), 'plansave', {}, 'plan-save'); navTo(byText(r, 'Do this later'), 'Ready');
};
BIND.Drill = (r) => {
  const c = circ(); setText(r, 'Family circle · 3 members', c ? `${c.name} · ${c.peopleCount} members` : 'No family circle yet');
  act(byText(r, 'Start drill'), 'drillstart', {}, 'drill-start'); act(byText(r, 'Schedule'), 'toast', { m: 'Drill scheduled for Saturday 10 am. Everyone gets one reminder.' });
  if (st.drill) { setText(r, 'Last drill · 14 Sep', 'Last drill · today'); }
  if (c) { const rowsWrap = byText(r, 'Sarah') && byText(r, 'Sarah').closest('div[style*="border-radius"]')?.parentElement; if (rowsWrap) { const tpl = rowsWrap.firstElementChild; rowsWrap.innerHTML = ''; c.members.forEach((m, i) => { const x = tpl.cloneNode(true); const nameEl = byText(x, 'Sarah'); if (nameEl) nameEl.textContent = m.id === me() ? (m.name) : m.name; const ini = byText(x, 'SN'); if (ini) ini.textContent = m.name.slice(0, 2).toUpperCase(); const t = byTextStart(x, 'Out in'); if (t) t.textContent = st.drill ? `Out in ${1 + i} min ${10 + i * 15} s` : 'No drill yet'; const d = byText(x, 'Done'); if (d) d.textContent = st.drill ? 'Done' : 'Waiting'; rowsWrap.appendChild(x); }); } }
  const ins = byTextStart(r, 'Isabella has no phone'); if (ins) ins.textContent = c && c.peopleCount < 2 ? 'Add one family member first so there is someone to practise with.' : 'Everyone who practises once responds about twice as fast in a real alert.';
};
BIND.Safety = (r) => {
  navTo(r.querySelector('a[data-nav="Profile"]'), 'Profile', 'back');
  setText(r, 'Older adult', 'Older person'); setText(r, 'Away from home', 'Visitor');
  const sel = myCohorts();
  R.safetyProfile.cohorts.forEach(([k, t, tint, col]) => { const el = byText(r, t); if (!el) return; act(el, 'cohort', { k }, 'cohort-' + k); const on = sel.includes(k); el.style.border = on ? `2px solid ${col}` : '1.5px solid #E3E6EA'; el.style.background = on ? tint : '#FFFFFF'; el.style.color = on ? col : '#1C1C1E'; const dot = el.querySelector('span'); if (dot) dot.style.background = col; });
  navTo(byText(r, 'Save my profile'), 'Ready', 'safety-save'); act(byText(r, 'Skip, show all advice equally'), 'cohortclear', {}, 'safety-skip');
  // For you examples follow the selection
  const fy = byText(r, 'FOR YOU'); if (fy) { const cardEl = fy.closest('section, div[style*="border-radius"]'); if (cardEl) { const items = sel.map((k) => R.safetyProfile.cohorts.find((c) => c[0] === k)).filter(Boolean); const t = byText(cardEl, 'Children'); if (t && items.length) { const names = [...cardEl.querySelectorAll('span')].filter((s) => ['Children', 'Pets'].includes(ownText(s))); names.forEach((n, i) => { if (items[i]) n.textContent = items[i][1]; else n.parentElement.style.display = 'none'; }); } } }
};
BIND.FamilyEmpty = (r) => { r.dataset.testid = 'family-empty'; act(byText(r, 'Create a group'), 'sheet', { sheet: 'creategroup' }, 'make-circle-open'); act(byText(r, 'I have an invite code'), 'sheet', { sheet: 'joingroup' }, 'join-open'); };
BIND.Family = (r) => {
  const c = circ(); if (!c) return;
  const host = c.ownerId === me(); const al = c.connectionAccess;
  const fs = famState(); const hd = r.querySelector('header'); if (hd && fs !== 'idle') { hd.style.background = fs === 'sos' ? 'linear-gradient(165deg, #C8102E, #7A0012)' : 'linear-gradient(165deg, #0D9488, #0F766E)'; hd.dataset.state = fs; }
  const gp = c.photoUrl ? `<span style="width: 36px; height: 36px; border-radius: 12px; background: url(${c.photoUrl}) center/cover; flex: none" data-testid="group-photo"></span>` : '';
  const title = r.querySelector('header button'); if (title) { if (gp) title.insertAdjacentHTML('afterbegin', gp); title.firstChild.textContent = c.name; act(title, st.circles.length > 1 ? 'tab' : 'toast', st.circles.length > 1 ? { tab: 'switchgroup' } : { m: 'Join or create another circle from Add a person' }, st.circles.length > 1 ? 'switch' : 'circle-title'); if (st.circles.length > 1) { const h = html(`<span data-testid="circle-title" hidden>${esc(c.name)}</span>`); title.appendChild(h); } }
  act(r.querySelector('button[aria-label="Group settings"]'), 'tab', { tab: 'groupsettings' }, 'gsettings');
  const cover = c.sponsorship.live ? `Covered by ${R.plans[c.sponsorship.tier].label}` : al.allowed ? (st.access?.billingEnabled ? 'Using your own ALRT +' : 'Billing off') : al.reason === 'GROUP_PLAN_ENDED' ? 'Group plan ended' : 'Not covered yet';
  setText(r, '1 person · you host', `${c.peopleCount} ${c.peopleCount === 1 ? 'person' : 'people'} · ${host ? 'you host' : 'hosted by ' + nm(c.ownerId)} · ${cover}`);
  act(byText(r, 'Check in'), 'cisheet', {}, 'checkin'); act(byText(r, 'Ask'), 'askcisheet', {}, 'askall'); act(byText(r, 'Journey'), 'tab', { tab: 'journey' }, 'journey-open'); act(byText(r, 'Daily'), 'loadprofile', {}, 'daily-open');
  const sosEl = byText(r, 'SOS'); if (sosEl) act(sosEl.closest('section'), 'sosopen', {}, 'sos-open');
  const list = byText(r, 'Members').parentElement; const tpl = list.children[1]; [...list.children].slice(1).forEach((x) => x.remove());
  c.members.forEach((m) => { const x = tpl.cloneNode(true); x.dataset.testid = 'member-row'; const av = x.firstElementChild; if (m.photo) { av.textContent = ''; av.style.background = `url(${m.photo}) center/cover`; av.dataset.testid = 'member-photo'; } else { setText(x, 'S', (m.nickname || m.name)[0].toUpperCase()); av.style.background = m.colorHex || '#E8622A'; } const sosLive = st.sos.some((s) => s.active && s.userId === m.id); const asked = (st.ciReqs || []).some((q) => q.waitingOn.some((w) => w.id === m.id)); av.style.boxShadow = sosLive ? '0 0 0 3px #FFFFFF, 0 0 0 6px #DA1F2D' : asked ? '0 0 0 3px #FFFFFF, 0 0 0 6px #E8622A' : ''; av.dataset.state = sosLive ? 'sos' : asked ? 'ask' : 'idle'; setText(x, 'Sarah (you)', (m.nickname || m.name) + (m.id === me() ? ' (you)' : '') + (c.ownerId === m.id ? ' · host' : '')); setText(x, 'Not checked in today', m.lastCheckInAt ? `Checked in ${when(m.lastCheckInAt)}${m.snapshot ? ' · ' + m.snapshot.label + ' until ' + when(m.snapshot.expiresAt) : ''}` : 'Not checked in today'); const p = x.lastElementChild; if (m.lastCheckInAt) { p.textContent = 'Checked in'; p.style.background = '#E6F6EC'; p.style.color = '#15803D'; } else if (m.id !== me()) { p.textContent = 'Check on'; p.style.background = '#EEEEFB'; p.style.color = '#3D3DDF'; act(p, 'checkon', { uid: m.id, id: c.circleId }, 'checkon'); } act(x, m.id === me() ? 'loadprofile' : 'membersheet', { id: m.id }); if (m.id === me()) x.dataset.testid = 'member-me'; list.appendChild(x); });
  // dynamic cards the board could not show: waiting on, shared journeys, uncovered
  const waiting = (st.ciReqs || []).filter((x) => x.waitingOn.length); const myReq = waiting.find((x) => x.waitingOn.some((w) => w.id === me()));
  const extras = [];
  if (myReq) extras.push(`<section style="${CARD}; border-left: 5px solid #E8622A" data-testid="waiting-you"><span style="font-size: 15px; font-weight: 700">${esc(myReq.requestedBy)} asked you to check in</span><div style="display: flex; gap: 8px">${small('Check in', 'cisheet', `data-req="${myReq.id}" data-testid="ci-from-req"`)}${small('See who has', 'rollcall', `data-id="${myReq.id}"`)}</div></section>`);
  waiting.filter((x) => x !== myReq).forEach((x) => extras.push(`<a href="#" data-act="rollcall" data-id="${x.id}" data-testid="waiting-row" style="${CARD}; flex-direction: row; align-items: center; text-decoration: none; color: #1C1C1E"><span style="flex: 1"><span style="font-size: 15px; font-weight: 700">Waiting on ${x.waitingOn.length}</span><div style="font-size: 12px; color: #5C5C66">${esc(x.requestedBy)} asked ${x.targets.length ? x.targets.length + ' people' : 'everyone'} · ${when(x.at)}</div></span>${chev}</a>`));
  (st.sharedJ || []).forEach((j) => extras.push(`<a href="#" data-act="viewjourney" data-id="${j.id}" data-testid="shared-journey" style="${CARD}; flex-direction: row; align-items: center; text-decoration: none; color: #1C1C1E; border-left: 5px solid #3D3DDF"><span style="flex: 1"><span style="font-size: 15px; font-weight: 700">${esc(j.memberName)} is sharing a journey</span><div style="font-size: 12px; color: #5C5C66">${j.live ? 'Live' : 'Updates every 10 min'}</div></span>${chev}</a>`));
  if (!al.allowed) extras.push(note(al.reason === 'GROUP_PLAN_ENDED' ? "This group's plan has ended. Renew it, or use your own ALRT +." : `Check in, Check on, SOS and Journey in this group need ${R.plans.individual.label} for each person, or a plan covering the group.`, '#FFF4EE', '#B84500').replace('<div', '<div data-testid="uncovered"'));
  const firstSection = r.querySelector('section'); extras.reverse().forEach((h) => firstSection.insertAdjacentHTML('beforebegin', h));
  act(byText(r, 'Add a person'), 'goinvite', {}, 'invite-open'); act(byText(r, 'Join with code'), 'sheet', { sheet: 'joingroup' }, 'join-open');
  // more rows
  const more = html(group('More', [row('Who my SOS reaches', (st.sosLists || []).length ? st.sosLists.length + ' lists' : 'Set up your SOS lists', 'loadsoslists', 'data-testid="soslists-open"'), row('Family places', 'Arrive and leave notices', 'loadplaces', 'data-testid="places-open"'), row('Plan and cover', c.sponsorship.live ? 'Covered by ' + R.plans[c.sponsorship.tier].label : 'Cover this group', 'tab', 'data-tab="plan_cover" data-testid="plan-open"'), row('Past SOS', 'Last 30 days', 'loadhist', 'data-testid="hist-open"')]));
  byText(r, 'Add a person').parentElement.insertAdjacentElement('beforebegin', more);
};
function detailBind(r, h) {
  navTo(r.querySelector('a[data-nav="Feed"]'), st.backTo || 'Feed', 'back');
  const f = byText(r, 'Follow'); if (f) { const on = st.followed.includes(h.id); act(f, 'follow', {}, 'follow'); f.textContent = on ? 'Following' : 'Follow'; }
  act(byText(r, 'Show on map'), 'tab', { tab: 'Main' });
  const c = circ(); setText(r, 'Nixon group · 3 people', c ? `${c.name} · ${c.peopleCount} people` : 'No group yet');
  act(byText(r, 'Send to my group'), 'sharefam', {}, 'share-fam'); act(byText(r, 'Check in'), 'cihazard', {}, 'ci-hazard'); act(byText(r, 'Share a link'), 'sheet', { sheet: 'sharealert' }, 'share');
  if (st.ciDone === h.id) { const ci = byText(r, 'Check in'); if (ci) { ci.textContent = 'Checked in'; ci.dataset.testid = 'ci-done'; } }
  // For you follows the Safety Profile
  const fy = byText(r, 'FOR YOU'); if (fy) { const sec = fy.closest('section') || fy.parentElement.parentElement; const sel = myCohorts(); if (!sel.length) { const gen = byTextStart(sec, 'General guidance'); if (gen) gen.textContent = 'Add a Safety profile in Me to see advice that fits you first. General guidance from ALRT, not part of the official warning.'; } }
}
BIND.Detail = (r) => { const h = st.hazards.find((x) => x.id === st.detail) || st.hazards[0]; if (!h) return; r.dataset.testid = 'detail';
  if (h.board !== 'Detail') { setText(r, 'Bushfire near Wanneroo Rd, Neerabup', h.title); setText(r, 'Emergency Warning', h.source === 'aws' ? h.level : h.source === 'official' ? 'Official' : h.source === 'intel' ? 'ALRT Assessment' : 'Global'); setText(r, 'DFES · 12 min ago', `${h.agency || ''} · ${ago(h)}`); const pl = byTextStart(r, 'A fire is moving toward homes'); if (pl) pl.textContent = h.plain || h.body || ''; setText(r, 'Neerabup, Wanneroo, Carabooda · 8.4 km from you', h.distance ? `${h.distance} from you` : 'Near you'); const k1 = byTextStart(r, 'Burning in bushland'); if (k1) k1.textContent = h.know || h.body || ''; const k2 = byTextStart(r, 'Ember attack likely'); if (k2) k2.remove(); const d1 = byTextStart(r, 'You are in danger and need to act'); if (d1) d1.textContent = h.todo || 'Follow the advice of the agency.'; ['If you are not prepared to defend', 'Do not drive through smoke'].forEach((t) => { const e = byTextStart(r, t); if (e) e.remove(); }); const ww = byText(r, 'DFES, word for word'); if (ww) ww.textContent = (h.agency || 'Agency') + ', word for word'; const src = byTextStart(r, 'Source: DFES'); if (src) src.textContent = `Source: ${h.agency || 'official feed'}. ${h.source === 'official' ? 'ALRT shows colour for the level and never writes a band word for this source.' : 'ALRT adds the plain-terms line, which is not official advice.'} ALRT never contacts emergency services for you.`;
    const band = r.querySelector('div[style*="background: #DA1F2D"], span[style*="#DA1F2D"]'); $$('[style*="#DA1F2D"]', r).forEach((e) => { e.style.cssText = e.style.cssText.replace(/#DA1F2D/g, bandColor(h)); }); }
  detailBind(r, h); };
BIND.Ex1 = (r) => { const h = st.hazards.find((x) => x.board === 'Ex1') || st.hazards[0]; r.dataset.testid = 'detail'; detailBind(r, h); };
BIND.Ex2 = (r) => { const h = st.hazards.find((x) => x.board === 'Ex2') || st.hazards[0]; r.dataset.testid = 'detail'; detailBind(r, h); };
BIND.Ex3 = (r) => { const h = st.hazards.find((x) => x.board === 'Ex3') || st.hazards[0]; r.dataset.testid = 'detail'; detailBind(r, h); };
BIND.Community = (r) => {
  const h = st.hazards.find((x) => x.id === st.detail) || st.hazards.find((x) => x.source === 'community'); if (!h) return; r.dataset.testid = 'detail';
  navTo(r.querySelector('a[data-nav="Feed"]'), 'Feed', 'back');
  setText(r, 'Crash on West Coast Hwy near Scarborough Beach Rd', h.title); setText(r, 'Traffic and transport', R.categories[h.category]?.name || 'Community'); setText(r, 'Unverified · 25 min ago', `Unverified · ${ago(h)}`); setText(r, 'Confirmed by ×3', `Confirmed by ×${h.confirmations}`); setText(r, 'Scarborough · about 900 m from you', h.distance ? `${h.locationName || 'Near you'} · about ${h.distance} from you` : 'Suburb only · posted anonymously');
  $$('[style*="#00CC96"]', r).forEach((e) => { e.style.cssText = e.style.cssText.replace(/#00CC96/g, bandColor(h)); });
  act(byText(r, 'I see it'), 'vote', { v: 'see', id: h.id }, 'vote-see'); act(byText(r, "I don't see it"), 'vote', { v: 'nosee', id: h.id }, 'vote-nosee');
  const f = byText(r, 'Follow'); if (f) { act(f, 'follow', {}, 'follow'); if (st.followed.includes(h.id)) f.textContent = 'Following'; }
  act(byText(r, 'Listen'), 'readaloud');
  if (h.authorId !== me()) { const l = byText(r, 'Listen'); if (l) { const rep = (l.closest('button') || l).cloneNode(true); rep.innerHTML = rep.innerHTML.replace('Listen', 'Report'); act(rep, 'flagsheet', {}, 'overflow'); (l.closest('button') || l).insertAdjacentElement('afterend', rep); } }
  const disc = byTextStart(r, 'Community reports are not verified'); if (disc) disc.textContent = R.wording.communityDisclaimer + ' This report disappears when its time runs out.';
  if (st.circles.length) { const strip = html(`<section style="${CARD}; margin: 0 16px; border-left: 5px solid #3D3DDF" data-testid="family-strip"><span style="font-size: 15px; font-weight: 700">Near this alert?</span>${muted('You can check in with your group.')}${st.ciDone === h.id ? `<div data-testid="ci-done" style="font-size: 13px; color: #15803D; font-weight: 600">Checked in. Your circle has been notified.</div>` : small('Check in', 'cihazard', 'data-testid="ci-hazard"')}</section>`); (disc ? disc.closest('div') : r).insertAdjacentElement('beforebegin', strip); }
};

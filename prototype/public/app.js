// ALRT prototype front end. Reads every rule, price, limit and phrase from /rules.json.
let R; const $ = (s, r = document) => r.querySelector(s);
const esc = (s) => String(s ?? '').replace(/[&<>"]/g, (c) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' }[c]));
const st = { screen: 'splash', tab: 'alerts', token: localStorage.getItem('alrt_tok') || '', user: null, access: null, hazards: [], circles: [], sos: [], journeys: [], notes: [], offline: false, lastSync: null, view: 'map', sheet: null, toast: '', onb: {}, pts: null, places: [], detail: null, ask: null, lock: null, seenNotes: 0, paywallCtx: null };
const money = (n) => '$' + n.toFixed(2);

async function api(p, o = {}) {
  if (st.offline && !p.startsWith('/__')) return { ok: false, status: 0, data: { code: 'OFFLINE' } };
  const r = await fetch('/api' + p, { method: o.method || (o.body ? 'POST' : 'GET'), headers: { 'content-type': 'application/json', authorization: st.token ? 'Bearer ' + st.token : '' }, body: o.body ? JSON.stringify(o.body) : undefined });
  let d = {}; try { d = await r.json(); } catch {}
  return { ok: r.ok, status: r.status, data: d };
}
const toast = (t) => { st.toast = t; draw(); setTimeout(() => { if (st.toast === t) { st.toast = ''; draw(); } }, 2800); };

// ---------- icons: one system, outline -> filled when active
const ICON = {
  alerts: (f) => `<svg viewBox="0 0 24 24" fill="${f ? 'currentColor' : 'none'}" stroke="currentColor" stroke-width="1.8" stroke-linejoin="round"><path d="M12 3 2.8 19.5h18.4z"/>${f ? '' : '<path d="M12 10v4.2M12 16.8v.2" stroke-linecap="round"/>'}</svg>`,
  ready: (f) => `<svg viewBox="0 0 24 24" fill="${f ? 'currentColor' : 'none'}" stroke="currentColor" stroke-width="1.8" stroke-linejoin="round"><path d="M12 2.8 4.5 5.6v6c0 4.6 3.1 8.1 7.5 9.6 4.4-1.5 7.5-5 7.5-9.6v-6z"/>${f ? '<path d="m8.6 12 2.5 2.5 4.4-4.8" stroke="#fff" fill="none" stroke-linecap="round"/>' : '<path d="m8.6 12 2.5 2.5 4.4-4.8" stroke-linecap="round"/>'}</svg>`,
  report: () => `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round"><rect x="3.5" y="3.5" width="17" height="17" rx="5"/><path d="M12 8v8M8 12h8"/></svg>`,
  family: (f) => `<svg viewBox="0 0 24 24" fill="${f ? 'currentColor' : 'none'}" stroke="currentColor" stroke-width="1.8" stroke-linejoin="round"><circle cx="12" cy="12" r="8.5"/><circle cx="12" cy="9.5" r="2.4" ${f ? 'fill="#fff" stroke="#fff"' : ''}/><path d="M7.6 17c.8-2.3 2.4-3.3 4.4-3.3s3.6 1 4.4 3.3" ${f ? 'stroke="#fff"' : ''} fill="none"/></svg>`,
};
function shape(src, color, sz = 22) {
  const c = `fill="${color}" stroke="#fff" stroke-width="1.5"`;
  const m = { aws: `<path d="M12 3 22 20H2z" ${c}/>`, official: `<path d="M12 2 22 12 12 22 2 12z" ${c}/>`, community: `<circle cx="12" cy="12" r="9" ${c}/>`, global: `<rect x="3" y="3" width="18" height="18" rx="4" ${c}/>`, intel: `<path d="M12 2 4 5v6c0 5 3.4 9 8 11 4.6-2 8-6 8-11V5z" ${c}/>` };
  return `<svg width="${sz}" height="${sz}" viewBox="0 0 24 24">${m[src]}</svg>`;
}
const bandColor = (h) => (h.source === 'community' ? R.categories[h.category]?.color || '#C233DB' : R.bands[h.band]);

// ---------- app shell
async function boot() {
  R = await (await fetch('/rules.json')).json();
  if (st.token) { await refresh(); st.screen = st.user ? 'main' : 'splash'; }
  draw();
  if (st.screen === 'splash') setTimeout(() => { if (st.screen === 'splash') { st.screen = 'onb0'; draw(); } }, 900);
  setInterval(poll, 1200);
}
async function refresh() {
  const [pr, ac, hz, ci, so, nf, jr, pl] = await Promise.all([api('/user/profile'), api('/access'), api('/alert/geo'), api('/family/circles'), api('/family/sos/active'), api('/notification/feed'), api('/family/journeys/me'), api('/user/location-subscriptions')]);
  if (pr.status === 401) { st.token = ''; st.user = null; return; }
  if (pr.ok) st.user = pr.data;
  if (ac.ok) st.access = ac.data;
  if (hz.ok) { st.hazards = hz.data.filter((h) => h.status === 'live'); st.lastSync = new Date(); }
  if (ci.ok) st.circles = ci.data;
  if (so.ok) st.sos = so.data.filter((s) => s.userId === st.user.id || true);
  if (nf.ok) st.notes = nf.data;
  if (jr.ok) st.journeys = jr.data;
  if (pl.ok) st.places = pl.data;
  const xp = await api('/xpPoints/summary'); if (xp.ok) st.pts = xp.data;
}
async function poll() {
  if (!st.token || st.offline || st.sheet === 'sos-hold') return;
  const before = st.notes.length; await refresh(); if (typeof loadFamily === 'function' && st.tab === 'family') { const c = circ(); if (c) { st.ciReqs = (await api('/family/check-in/requests?circleId=' + c.circleId)).data; st.locReqs = (await api('/family/location-requests/pending')).data; st.sharedJ = (await api('/family/journeys/shared')).data; } } else if (st.user) st.locReqs = (await api('/family/location-requests/pending')).data;
  if (st.notes.length > before && st.screen === 'main') toast(st.notes[0].title);
  draw(true);
}

function draw(soft) {
  const app = $('#app'); if (!app) return;
  const keepScroll = $('.body')?.scrollTop;
  const sc = st.screen;
  let html = '';
  if (sc === 'splash') html = splash();
  else if (sc.startsWith('onb')) html = onb(+sc.slice(3));
  else if (sc === 'paywall-choose') html = paywallChoose();
  else if (sc === 'paywall-ind') html = paywallInd();
  else if (sc === 'paywall-grp') html = paywallGrp();
  else if (sc === 'forgot') html = `<div class="body" style="background:#fff">${EXTRA.forgot()}</div>`;
  else html = main();
  html += sheetHtml();
  if (st.toast) html += `<div class="toast" data-testid="toast">${esc(st.toast)}</div>`;
  if (st.lock) html += lockHtml();
  if (soft && app.dataset.last === html) return;
  app.dataset.last = html; app.innerHTML = html;
  const b = $('.body'); if (b && keepScroll) b.scrollTop = keepScroll;
  $('#bill').textContent = st.access ? (st.access.billingEnabled ? 'on' : 'off') : 'on';
  $('#off').textContent = st.offline ? 'on' : 'off';
  $('#clock').textContent = '';
}

// ---------- splash + onboarding (no location prompt, no prices, sign in last)
const splash = () => `<div class="splash" data-testid="splash"><img src="data:image/svg+xml;utf8,${encodeURIComponent('<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64"><defs><linearGradient id="g" x1="0" y1="0" x2="1" y2="1"><stop offset="0" stop-color="#FF6B00"/><stop offset="1" stop-color="#FF0004"/></linearGradient></defs><path d="M32 6 4 56h56z" fill="url(#g)"/></svg>')}" width="84"><h1 style="margin:0;letter-spacing:.2em">ALRT</h1><div class="muted" style="font-size:11px;letter-spacing:.18em">${R.brand.tagline}</div></div>`;
function onb(i) {
  const dots = `<div class="dots" style="text-align:center;padding:14px">${[0, 1, 2, 3, 4].map((k) => `<span class="${k === i ? 'on' : ''}"></span>`).join('')}</div>`;
  const next = (label, act = 'onb-next') => `<div style="padding:0 16px 22px"><button class="btn" data-act="${act}" data-testid="onb-next">${label}</button></div>`;
  const wrap = (inner, foot) => `<div class="body" style="background:#fff;padding:24px 20px" data-testid="onb${i}">${inner}</div>${dots}${foot}`;
  if (i === 0) return wrap(`<h1 style="font-size:30px">Welcome to ALRT</h1><p>Know what is happening near the places and people that matter to you, in plain terms.</p><div class="card" style="margin:12px 0"><b>Official first.</b><div class="muted">Warnings from the agencies that issue them.</div></div><div class="card" style="margin:12px 0"><b>Your neighbours too.</b><div class="muted">Community reports are always marked Unverified.</div></div><div class="warn" style="margin:12px 0">${esc(R.wording.notAnEmergencyService)}</div>`, next('Continue'));
  if (i === 1) return wrap(`<h1>Our promises</h1><div class="card" style="margin:10px 0">${esc(R.wording.locationPromise)}</div><div class="card" style="margin:10px 0">Your Safety Profile stays on your phone.</div><div class="card" style="margin:10px 0">ALRT never contacts emergency services for you.</div><label class="row" style="margin-top:14px"><input type="checkbox" id="age" style="width:auto" data-testid="age"> <span>${esc(R.wording.ageGate)}</span></label>`, next('I agree', 'onb-agree'));
  if (i === 2) return wrap(`<h1>How many alerts do you want?</h1><p class="muted">You can change this any time.</p>${R.notifications.levels.map((l) => `<div class="lvl ${(st.onb.level || 'official') === l.id ? 'on' : ''}" data-act="lvl" data-id="${l.id}"><div><b>${esc(l.label)}</b><div class="muted">${l.id === 'official' ? 'Only warnings from official sources.' : l.id === 'all' ? 'Official plus confirmed community reports.' : 'Emergency Warnings only.'}</div></div></div>`).join('')}<div class="muted">Emergency Warnings always reach you.</div>`, next('Continue'));
  if (i === 3) return wrap(`<h1>ALRT is free to use</h1><div class="card" style="margin:10px 0"><b>${R.plans.free.savedPlaces} saved place</b> and <b>${R.plans.free.askPerDay} Ask ALRT questions a day</b>.</div><div class="card" style="margin:10px 0"><b>${esc(R.plans.individual.label)}</b> removes the limits. Try it free for ${R.plans.individual.trialDays / 7} weeks any time, in the app. Price shown by your app store.</div><div class="card" style="margin:10px 0">Creating or joining a group is always free.</div>`, next('Continue'));
  return wrap(`<h1>Sign in to start</h1><input id="em" placeholder="Email" data-testid="email"><input id="pw" type="password" placeholder="Password" data-testid="password"><button class="btn" data-act="register" data-testid="register">Create account</button><div style="height:8px"></div><button class="btn sec" data-act="login" data-testid="login">Sign in</button><div style="height:8px"></div><div class="row"><button class="btn sec" data-act="oauth" data-p="google">Google</button><button class="btn sec" data-act="oauth" data-p="apple">Apple</button></div><div class="muted" style="margin-top:10px"><span data-act="tab" data-tab="forgot" data-testid="forgot-link" style="text-decoration:underline;cursor:pointer">Forgot password?</span> · We ask for your location only later, inside the app, when you choose to use it.</div>`, '');
}

// ---------- main shell + tabs
function main() {
  const t = st.tab; let inner = '';
  if (t === 'alerts') inner = alertsTab(); else if (t === 'ready') inner = readyTab(); else if (t === 'family') inner = familyTab(); else if (t === 'me') inner = meTab(); else if (t === 'detail') inner = detailTab();
  else if (t === 'notes') inner = notesTab(); else if (t === 'places') inner = placesTab(); else if (t === 'widgets') inner = widgetsTab(); else if (t === 'learn') inner = learnTab(); else if (t === 'drill') inner = drillTab(); else if (t === 'plan') inner = planTab(); else if (t === 'plan_cover') inner = planCover(); else if (typeof EXTRA !== 'undefined' && EXTRA[t]) inner = EXTRA[t](); else if (t === 'posted') inner = postedTab(); else if (t === 'journey') inner = journeyTab();
  if (st.forceUpdate) return EXTRA.forceupdate();
  if (st.user?.isScheduledForDeletion && t !== 'deleted') { st.tab = 'deleted'; return main(); }
  const sosBanner = mySos() ? sosBannerHtml() : (typeof mySosAny === 'function' && mySosAny()) ? `<div class="banner sos" data-act="viewsosbanner" data-testid="sos-strip" style="cursor:pointer">SOS from ${esc(nm(mySosAny().userId))} is live. Tap to respond.</div>` : '';
  const pendingLoc = (st.locReqs || []).length && !st.sheet ? `<div class="banner" style="background:#FFF1EA;color:#B84500;cursor:pointer" data-act="openlocreq" data-testid="loc-strip">${esc(st.locReqs[0].requester.name)} asked where you are. Tap to answer.</div>` : '';
  const unread = st.notes.length > st.seenNotes;
  const FAM = ['rollcall','invite','groupsettings','switchgroup','circleprofile','sharing','famplaces','soslists','soslistedit','sosreceiver','sosresolved','soshistory','sharedjourney','grouppaused','journey','plan','plan_cover'];
  const ME = ['widgets','manage','managenotes','accessible','points','leaderboard','badges','childmode','blocked','support','deleteacct','deleted','myalrts'];
  const act = ['detail', 'notes', 'places', 'selectloc', 'forgot'].includes(t) ? 'alerts' : FAM.includes(t) ? 'family' : ME.includes(t) ? 'me' : ['learn', 'drill'].includes(t) ? 'ready' : t === 'posted' ? 'alerts' : t;
  const btn = (k, label, ic, cls = '') => `<button class="${cls} ${act === k ? 'on' : ''}" data-act="tab" data-tab="${k}" aria-label="${label}" data-testid="tab-${k}">${ic}${k === 'alerts' && unread ? '<span class="dot"></span>' : ''}</button>`;
  return `${st.offline ? `<div class="banner off" data-testid="offline">Offline. Showing alerts as of ${st.lastSync ? st.lastSync.toTimeString().slice(0, 5) : 'earlier'}.</div>` : ''}${sosBanner}${pendingLoc}<div class="body">${inner}</div>
  <nav class="tabbar">${btn('alerts', 'Alerts', ICON.alerts(act === 'alerts'))}${btn('ready', 'Ready', ICON.ready(act === 'ready'))}${st.user?.childMode ? '' : btn('report', 'Report', ICON.report(), 'rep')}${btn('family', 'Family', ICON.family(act === 'family'), 'fam')}<button class="${act === 'me' ? 'on' : ''}" data-act="tab" data-tab="me" aria-label="Me" data-testid="tab-me"><span class="av">${esc((st.user?.name || 'Me')[0].toUpperCase())}</span></button></nav>`;
}
const hdr = (title, right = '') => `<div class="hdr"><h1>${title}</h1>${right}</div>`;
const back = (to) => `<button class="ib" data-act="tab" data-tab="${to}" aria-label="Back" data-testid="back">‹</button>`;

function alertsTab() {
  const f = st.filters; const list = st.hazards.filter((h) => !f || (f.sources.includes(h.source) && (h.source === 'community' || f.bands.includes(h.band)) && f.cats.includes(h.category)));
  const pos = (h) => ({ x: 8 + ((h.lng % 90) / 90) * 84, y: 10 + ((h.lat % 90) / 90) * 78 });
  return `${hdr('Alerts', `<button class="ib" data-act="ask" aria-label="Ask ALRT" data-testid="ask-btn">?</button><button class="ib" data-act="tab" data-tab="notes" data-testid="bell">🔔</button><button class="ib" data-act="openfilters" data-testid="filters-btn">⚲</button><button class="ib" data-act="view" data-testid="view-toggle">${st.view === 'map' ? 'List' : 'Map'}</button>`)}
  <div class="row" style="padding:0 16px 8px;background:#fff"><button class="chip" data-act="tab" data-tab="places" data-testid="places-btn">Saved places (${st.places.length})</button><span class="muted">Level: ${esc(R.notifications.levels.find((l) => l.id === (st.user?.settings?.level || 'official'))?.label)}</span></div>
  ${st.view === 'map' ? `<div class="map" data-testid="map">${list.map((h) => { const p = pos(h); return `<button class="pin" style="left:${p.x}%;top:${p.y}%" data-act="open" data-id="${h.id}" data-testid="pin-${h.source}">${shape(h.source, bandColor(h), 28)}</button>`; }).join('')}</div>` : ''}
  <div class="sect">Near you</div>${list.map(alertRow).join('') || '<div class="card muted">Nothing near you right now.</div>'}`;
}
function alertRow(h) {
  const aws = h.source === 'aws';
  const label = { aws: h.level || 'Advice', official: 'Official', community: 'Community report', global: 'Global feed', intel: 'ALRT Assessment' }[h.source];
  return `<div class="alertrow" data-act="open" data-id="${h.id}" data-testid="alert-${h.source}">${shape(h.source, bandColor(h), 30)}<div class="grow"><div><b>${esc(h.title)}</b></div><div class="muted"><span class="tag">${esc(label)}</span>${h.source === 'community' ? '<span class="tag">Unverified</span>' : ''}${h.minutesAgo} min ago</div></div></div>`;
}
function detailTab() {
  const h = st.hazards.find((x) => x.id === st.detail); if (!h) return hdr('Alert', back('alerts'));
  const label = { aws: h.level, official: 'Official alert', community: 'Community report', global: 'Global feed', intel: 'ALRT Assessment' }[h.source];
  let body = '';
  if (h.source === 'community') {
    body = `<div class="card"><b>${esc(h.title)}</b><div class="muted">${esc(h.body || '')}</div><div style="margin-top:8px"><span class="tag">Unverified</span><span class="tag">${h.confirmations} neighbour${h.confirmations === 1 ? '' : 's'} see it</span></div></div>
    <div class="row" style="padding:0 16px"><button class="btn sec" data-act="vote" data-v="see" data-id="${h.id}" data-testid="vote-see">I see it</button><button class="btn sec" data-act="vote" data-v="nosee" data-id="${h.id}">I don't see it</button></div>
    <div class="warn">${esc(R.wording.communityDisclaimer)}</div>`;
  } else {
    body = `<div class="plain"><b>${esc(R.wording.plainTermsLabel)}</b><div style="margin-top:6px;font-size:16px">${esc(h.plain || h.body || '')}</div></div>
    ${h.know ? `<div class="sect">What we know</div><div class="card">${esc(h.know)}</div>` : ''}${h.todo ? `<div class="sect">What to do</div><div class="card">${esc(h.todo)}</div>` : ''}
    <div class="sect">For you <span class="tag">${esc(R.wording.forYouTag)}</span></div><div class="card muted">${forYou()}</div>
    <div class="map" style="height:120px;margin-top:8px"><div style="position:absolute;left:50%;top:50%;transform:translate(-50%,-50%)">${shape(h.source, bandColor(h), 34)}</div></div>`;
  }
  const following = (st.followed || []).includes(h.id);
  const famStrip = st.circles.length ? `<div class="card" style="border-left:6px solid #3D3DDF" data-testid="family-strip"><b>Near this alert?</b><div class="muted">You can check in with your group.</div>${st.ciDone === h.id ? '<div class="muted" data-testid="ci-done">Checked in. Your circle has been notified.</div>' : `<button class="chip" data-act="cihazard" data-testid="ci-hazard">${R.wording.checkIn}</button>`}</div>` : '';
  const guide = h.source !== 'community' ? `<div class="card row" data-act="learn" data-t="${esc(TOPICS[0])}" style="cursor:pointer" data-testid="guide-strip"><div class="grow"><b>Open the safety guide</b><div class="muted">Before, during and after. +${R.points.guideComplete} points</div></div>›</div>` : '';
  const mine = h.authorId === st.user?.id;
  return `<div class="hdr">${back('alerts')}<h1>${esc(label || 'Alert')}</h1><button class="ib" data-act="follow" data-testid="follow" title="Follow">${following ? '★' : '☆'}</button><button class="ib" data-act="readaloud" title="Read aloud">🔊</button>${h.source === 'community' && !mine ? '<button class="ib" data-act="flagsheet" data-testid="overflow">⋯</button>' : ''}</div><div class="card row">${shape(h.source, bandColor(h), 34)}<div><b>${esc(h.title)}</b><div class="muted">${esc(h.agency || '')} · ${h.minutesAgo} min ago${following ? ' · Following' : ''}</div></div></div>${body}${famStrip}${guide}
  <div style="padding:8px 16px"><button class="btn dark" data-act="sharesheet" data-id="${h.id}" data-testid="share">Share</button>${mine ? '<div class="muted" style="margin-top:8px">Your report. Alerts cannot be edited once live.</div>' : ''}</div>`;
}
function myCohorts() { try { return JSON.parse(localStorage.getItem('alrt_cohorts') || '[]'); } catch { return []; } }
function forYou() { const c = myCohorts(); if (!c.length) return 'Add a Safety Profile in Me to see advice that fits you.'; return c.map((k) => R.safetyProfile.cohorts.find((x) => x[0] === k)?.[1]).filter(Boolean).map((n) => `Advice tuned for: ${esc(n)}.`).join('<br>'); }

function notesTab() {
  st.seenNotes = st.notes.length;
  return `${hdr('Notifications', back('alerts'))}${st.notes.map((n) => `<div class="card" data-testid="note-${n.kind}"><b>${esc(n.title)}</b><div class="muted">${esc(n.body)}</div></div>`).join('') || '<div class="card muted">Nothing yet.</div>'}`;
}
function placesTab() {
  return `${hdr('Saved places', back('alerts'))}${st.places.map((p) => `<div class="card row"><div class="grow"><b>${esc(p.name)}</b><div class="muted">${p.radiusKm} km</div></div></div>`).join('')}<div style="padding:8px 16px"><input id="pn" placeholder="Place name" data-testid="place-name"><button class="btn" data-act="addplace" data-testid="add-place">Add a place</button></div><div class="muted" style="padding:0 16px">Free includes ${R.plans.free.savedPlaces} saved place. ${esc(R.plans.individual.label)} has no limit.</div>`;
}

// ---------- report
function reportSheet() {
  const cats = Object.entries(R.categories);
  return `<h2 style="margin-top:0">Report something</h2><div class="muted">Choose a category. Everything else is optional. Your report is anonymous.</div><div style="margin:8px 0">${cats.map(([k, v]) => `<span class="chip ${st.rep?.cat === k ? 'on' : ''}" data-act="repcat" data-k="${k}" data-testid="cat-${k}" style="border-left:6px solid ${v.color}">${esc(v.name)}</span>`).join('')}</div>
  <div class="muted">How serious? (optional)</div><div>${Object.entries(R.community.severityWording).map(([k, v]) => `<span class="chip ${st.rep?.sev === k ? 'on' : ''}" data-act="repsev" data-k="${k}">${esc(v)}</span>`).join('')}</div>
  <div class="card row" data-act="tab" data-tab="selectloc" data-back="report" style="cursor:pointer;margin:8px 0" data-testid="rep-loc"><div class="grow"><b>${esc(st.loc || 'Your location')}</b><div class="muted">Tap to change</div></div>›</div><textarea id="rb" rows="2" placeholder="What can you see? (optional)"></textarea><div class="warn" style="margin:6px 0">${esc(R.wording.communityDisclaimer)}</div>
  <button class="btn" data-act="post" data-testid="post">Post report</button><button class="btn sec" style="margin-top:8px" data-act="close">Cancel</button>`;
}
function postedTab() { return `${hdr('Posted', '')}<div class="card"><b>Thanks, it is posted.</b><div class="muted">People nearby who chose community alerts have been notified. Neighbours can confirm it. You earned ${R.points.reportApproved} points.</div></div><div style="padding:8px 16px"><button class="btn" data-act="tab" data-tab="alerts" data-testid="done">Back to alerts</button><div style="height:8px"></div><button class="btn sec" data-act="loadpoints">How points work</button></div>`; }

// ---------- ready (shield)
const TOPICS = ['Bushfire', 'Flood', 'Storm', 'Heatwave', 'Power outage'];
function readyTab() {
  return `${hdr('Get ready')}<div class="card"><b>One next step</b><div class="muted">If an alert is issued near home, then I will pack my go bag and tell my family circle.</div><div style="height:8px"></div><button class="btn" data-act="tab" data-tab="plan" data-testid="make-plan">Make my plan</button></div>
  <div class="sect">Practice</div><div class="card row" data-act="tab" data-tab="drill" style="cursor:pointer" data-testid="drill-open"><div class="grow"><b>Two minute drill</b><div class="muted">Practice what you would do</div></div>›</div>
  <div class="sect">Learn</div>${TOPICS.map((t) => `<div class="card row" data-act="learn" data-t="${t}" style="cursor:pointer" data-testid="learn-${t}"><div class="grow"><b>${t}</b></div>›</div>`).join('')}`;
}
function planTab() {
  const c = circ();
  return `${hdr('Family plan', back('ready'))}<div class="card">${c ? `Share this plan with <b>${esc(c.name)}</b> in Family.` : 'Create a family circle first. It is free.'}</div><div class="card muted">Meeting place · Go bag · Who to call. Stays on your phone.</div>`;
}
function drillTab() { return `${hdr('Two minute drill', back('ready'))}<div class="card"><b>An alert just arrived: Watch and Act.</b><div class="muted">What do you do first?</div></div><div style="padding:8px 16px"><button class="btn sec" data-act="toast" data-m="Good. Getting ready early gives you time.">Get my go bag</button><div style="height:8px"></div><button class="btn sec" data-act="toast" data-m="Check official advice first, then decide.">Wait and see</button></div>`; }
function learnTab() { return `${hdr(esc(st.learnT || 'Learn'), back('ready'))}<div class="card">Plain steps for ${esc(st.learnT || 'this topic')}. Before, during and after.</div><div style="padding:8px 16px"><button class="btn" data-act="guidedone" data-testid="guide-done">Mark as read</button></div>`; }

// ---------- family
function mySos() { return st.sos.find((s) => s.userId === st.user?.id && s.active); }
function sosBannerHtml() {
  const s = mySos(); const left = Math.max(0, s.endsAt - s.serverNow); const mm = String(Math.floor(left / 60000)).padStart(2, '0');
  return `<div class="banner sos" data-testid="sos-banner">SOS active. Ends in ${mm} min.${s.endingSoon ? ' <b data-testid="ending-soon">Ending soon</b>' : ''} <button class="chip" data-act="sosextend" data-id="${s.id}" data-testid="sos-extend">Extend 1 hour</button><button class="chip" data-act="sosstop" data-id="${s.id}" data-testid="sos-stop">End my SOS</button></div>`;
}
function familyTab() {
  const c = circ();
  if (!c) return `<div class="fam-hero"><h2 style="margin:0">Your people, in one place</h2><div style="opacity:.85">Creating or joining a group is free.</div></div><div class="card"><input id="cn" placeholder="Group name" data-testid="circle-name"><button class="btn" data-act="mkcircle" data-testid="make-circle">Create a group</button></div><div class="card"><input id="jc" placeholder="Invite code" data-testid="join-code"><button class="btn sec" data-act="join" data-testid="join">Join with a code</button><div style="height:8px"></div><button class="btn sec" data-act="toast" data-m="Camera opens to scan the invite QR">Scan invite QR</button></div><div class="card muted"><b>What a Family circle gives you</b><br>Check in, Check on, SOS to the people you choose, and journeys. No price to look. Joining is always free.</div>`;
  if (c.hostTransition) return EXTRA.grouppaused();
  const al = c.connectionAccess; const host = c.ownerId === st.user.id;
  const cover = c.sponsorship.live ? `Covered by ${R.plans[c.sponsorship.tier].label}` : al.allowed ? (st.access?.billingEnabled ? 'Using your own ALRT +' : 'Billing off: everything open') : al.reason === 'GROUP_PLAN_ENDED' ? 'Group plan ended' : 'Not covered yet';
  const waiting = (st.ciReqs || []).filter((x) => x.waitingOn.length);
  const myReq = waiting.find((x) => x.waitingOn.some((w) => w.id === st.user.id));
  const sj = (st.sharedJ || []);
  return `<div class="fam-hero"><div class="row"><div class="grow"><div style="color:#fff9;font-size:12px">${esc(cover)}</div><h2 style="margin:2px 0" data-testid="circle-title">${esc(c.name)}</h2><div>${c.peopleCount}${c.capacity ? ' of ' + c.capacity : ''} people${host ? ' · you host' : ''}</div></div>${st.circles.length > 1 ? `<button class="chip" data-act="tab" data-tab="switchgroup" data-testid="switch">Switch</button>` : ''}<button class="chip" data-act="tab" data-tab="groupsettings" data-testid="gsettings">⚙</button></div></div>
  ${myReq ? `<div class="card" style="border-left:6px solid #E8622A" data-testid="waiting-you"><b>${esc(myReq.requestedBy)} asked you to check in</b><div class="row" style="margin-top:6px"><button class="chip on" data-act="cisheet" data-req="${myReq.id}" data-testid="ci-from-req">${R.wording.checkIn}</button><button class="chip" data-act="rollcall">See who has</button></div></div>` : ''}
  ${waiting.filter((x) => x !== myReq).map((x) => `<div class="card row" data-act="rollcall" data-id="${x.id}" style="cursor:pointer" data-testid="waiting-row"><div class="grow"><b>Waiting on ${x.waitingOn.length}</b><div class="muted">${esc(x.requestedBy)} asked ${x.targets.length ? x.targets.length + ' people' : 'everyone'} · ${when(x.at)}</div></div>›</div>`).join('')}
  ${sj.map((j) => `<div class="card row" data-act="viewjourney" data-id="${j.id}" style="cursor:pointer;border-left:6px solid #3D3DDF" data-testid="shared-journey"><div class="grow"><b>${esc(j.memberName)} is sharing a journey</b><div class="muted">${j.live ? 'Live' : 'Updates every 10 min'}</div></div>›</div>`).join('')}
  <div class="row" style="padding:12px 16px"><button class="btn dark" data-act="cisheet" data-testid="checkin">${R.wording.checkIn}</button><button class="btn" style="background:linear-gradient(135deg,#C8102E,#7A0012)" data-act="sosopen" data-testid="sos-open">SOS</button></div>
  <div class="row" style="padding:0 16px"><button class="btn sec" data-act="askcisheet" data-testid="askall">${R.wording.checkOn}</button><button class="btn sec" data-act="tab" data-tab="journey" data-testid="journey-open">Journey</button></div>
  <div class="sect">People</div>${c.members.map((m) => `<div class="card row" data-act="${m.id !== st.user.id ? 'membersheet' : 'loadprofile'}" data-id="${m.id}" style="cursor:pointer" data-testid="member-row"><span style="width:10px;height:10px;border-radius:50%;background:${m.colorHex || '#E8622A'}"></span><div class="grow"><b>${esc(m.nickname || m.name)}</b><div class="muted">${m.lastCheckInAt ? 'Checked in ' + when(m.lastCheckInAt) : 'No check-in yet'}${m.snapshot ? ' · ' + esc(m.snapshot.label) + ' until ' + when(m.snapshot.expiresAt) : ''}${c.ownerId === m.id ? ' · host' : ''}</div></div>${m.id !== st.user.id ? `<button class="chip" data-act="checkon" data-uid="${m.id}" data-id="${c.circleId}" data-testid="checkon">${R.wording.checkOn}</button>` : '<span class="pill">You</span>'}</div>`).join('')}
  <div style="padding:4px 16px"><button class="btn sec" data-act="goinvite" data-testid="invite-open">Add a member</button></div>
  <div class="sect">More</div>${row('Who my SOS reaches', (st.sosLists || []).length ? (st.sosLists.length + ' lists') : 'Set up your SOS lists', 'loadsoslists', 'data-testid="soslists-open"')}${row('Family places', 'Arrive and leave notices', 'loadplaces', 'data-testid="places-open"')}${row('Plan and cover', c.sponsorship.live ? 'Covered' : 'Cover this group', 'tab', 'data-tab="plan_cover" data-testid="plan-open"')}${row('Past SOS', 'Last 30 days', 'loadhist', 'data-testid="hist-open"')}
  ${c.sponsorship.live || al.allowed ? '' : `<div class="warn" data-testid="uncovered">${al.reason === 'GROUP_PLAN_ENDED' ? "This group's plan has ended. Renew it, or use your own ALRT +." : esc(R.wording.checkIn) + ', ' + esc(R.wording.checkOn) + ', SOS and Journey in this group need ' + esc(R.plans.individual.label) + ' for each person, or a plan covering the group.'}</div>`}
  <div class="warn">${esc(R.wording.sosDisclaimer)}</div>`;
}
const codeOf = (c) => c.code || '';
function planCover() { const c = circ(); const sp = c.sponsorship; return `${hdr('Plan and cover', back('family'))}<div class="card" data-testid="cover-status">${sp.live ? 'Covered by ' + esc(R.plans[sp.tier].label) + '. Members join free.' : 'This group has no plan yet.'}</div>${sp.live ? '' : '<div style="padding:8px 16px"><button class="btn" data-act="go" data-s="paywall-grp" data-testid="cover-group">Cover this group</button></div>'}`; }
function journeyTab() {
  const c = circ(); const j = st.journeys[0];
  return `${hdr('Journey', back('family'))}${j ? `<div class="card" data-testid="journey-active"><b>Journey active</b><div class="muted">Ends in ${Math.max(0, Math.round((j.endsAt - (st.access?.serverNow || Date.now())) / 60000))} min. ${j.live ? 'Live sharing is on.' : 'Points are snapped every ' + R.timings.journeySnapPointMinutes + ' minutes.'}</div></div><div class="row" style="padding:0 16px"><button class="btn sec" data-act="jext" data-id="${j.id}" data-testid="jext">Extend 1 hour</button><button class="btn sec" data-act="jstop" data-id="${j.id}" data-testid="jstop">Stop</button></div>` :
  `<div class="card"><div class="muted">Who sees it</div>${(c?.members || []).filter((m) => m.id !== st.user.id).map((m) => `<span class="chip ${(st.jRecips || []).includes(m.id) ? 'on' : ''}" data-act="jrecip" data-id="${m.id}" data-testid="jr">${esc(m.name)}</span>`).join('') || '<div class="muted">Everyone in the group</div>'}<div class="muted" style="margin-top:8px">How long will you be?</div>${R.timings.journeyInitialMinutes.map((m) => `<span class="chip ${st.jmin === m ? 'on' : ''}" data-act="jmin" data-m="${m}" data-testid="jm-${m}">${m} min</span>`).join('')}<label class="row" style="margin-top:8px"><input type="checkbox" id="jlive" style="width:auto"> Share live location (optional)</label></div><div style="padding:8px 16px"><button class="btn" data-act="jstart" data-id="${c?.circleId}" data-testid="jstart">Start journey</button></div>`}`;
}

// ---------- me
function meTab() {
  const lvl = st.user?.settings?.level || 'official'; const pts = st.pts?.points || 0;
  const pl = st.access?.personal;
  return `${hdr('Me', '<button class="ib" data-act="tab" data-tab="widgets" data-testid="widgets-open">▦</button>')}
  <div class="card row"><span class="av" style="width:44px;height:44px;border-radius:50%;background:linear-gradient(135deg,#FF6B00,#FF0004);color:#fff;display:flex;align-items:center;justify-content:center;font-weight:700">${esc((st.user?.name || 'M')[0].toUpperCase())}</span><div class="grow"><b>${esc(st.user?.name)}</b><div class="muted" data-testid="points">${esc(st.pts?.level || 'Watcher')} · ${pts} points</div></div></div>
  <div class="plus-hero" data-testid="plan-card"><div style="opacity:.8;font-size:12px">YOUR PLAN</div><h2 style="margin:2px 0" data-testid="plan-name">${pl?.plan === 'individual' ? R.plans.individual.label + (pl.isTrial ? ' trial' : '') : R.plans.free.label}</h2>${pl?.plan === 'individual' ? '<div>No limits on saved places. 10 Ask ALRT questions a day.</div>' : `<div>${R.plans.free.savedPlaces} saved place · ${R.plans.free.askPerDay} Ask ALRT a day</div><div style="height:10px"></div><button class="btn sec" data-act="paywall" data-ctx="me" data-testid="see-plus">See ${esc(R.plans.individual.label)}</button>`}</div>
  <div class="sect">Alerts I want</div><div style="padding:0 16px">${R.notifications.levels.map((l) => `<div class="lvl ${lvl === l.id ? 'on' : ''}" data-act="setlevel" data-id="${l.id}" data-testid="level-${l.id}"><b>${esc(l.label)}</b></div>`).join('')}</div>
  <div class="sect">Safety Profile <span class="tag">${esc(R.wording.forYouTag)}</span></div><div style="padding:0 16px">${R.safetyProfile.cohorts.map((c) => `<span class="chip ${myCohorts().includes(c[0]) ? 'on' : ''}" data-act="cohort" data-k="${c[0]}" data-testid="cohort-${c[0]}" style="${myCohorts().includes(c[0]) ? `background:${c[2]};color:${c[3]};border-color:${c[3]}` : ''}">${esc(c[1])}</span>`).join('')}</div>
  ${row('Accessible alerts', 'Strong vibration, read aloud', 'tab', 'data-tab="accessible"')}
  <div class="sect">Activity</div>${row('My ALRTs', 'Reports you posted', 'loadmine', 'data-testid="mine-open"')}${row('Points and badges', (st.pts?.points || 0) + ' points · ranks only, no names, no streaks', 'loadpoints', 'data-testid="points-open"')}
  <div class="sect">Plans</div>${row('My plans', 'Personal plan and group coverage', 'loadmanage', 'data-testid="manage-open"')}
  <div class="sect">Settings</div>${row('Manage notifications', 'Fine-tune types, categories, places', 'loadnotes', 'data-testid="notes-open"')}${row('Add widget to your home screen', '', 'sheet', 'data-sheet="addwidget"')}${row('Share ALRT', '+' + R.points.shareInstall + ' points per friend who installs', 'sheet', 'data-sheet="sharealrt"')}${row('Child mode', st.user?.childMode ? 'On' : 'Off', 'tab', 'data-tab="childmode" data-testid="child-open"')}${row('Language', (st.user?.language || 'en') === 'es' ? 'Español' : 'English', 'sheet', 'data-sheet="language"')}${row('Blocked accounts', '', 'loadblocked', 'data-testid="blocked-open"')}${row('Support', 'Ask a question or report a problem', 'tab', 'data-tab="support" data-testid="support-open"')}${row('Legal', 'Terms, privacy, emergency services disclaimer', 'sheet', 'data-sheet="legal"')}
  <div style="padding:8px 16px"><button class="btn sec" data-act="logoutsheet" data-testid="signout">Sign out</button><div style="height:8px"></div><button class="btn sec" data-act="tab" data-tab="deleteacct" data-testid="delete-open" style="color:#C8102E">Delete account</button></div>`;
}
function widgetsTab() {
  const lastCi = st.notes.find((n) => n.kind === 'checkin');
  return `${hdr('Home screen widgets', back('me'))}<div class="wid a" data-testid="w-alert"><b>Watch and Act</b><div>Bushfire near you</div><div style="opacity:.8">12 min ago</div></div><div class="wid c" data-testid="w-critical"><b>Emergency Warning</b><div>Act now. Follow official advice.</div></div><div class="wid s" data-testid="w-sos"><b>SOS</b><div>Opens the app. Sending needs a 3 second hold inside the app.</div></div><div class="wid f" data-testid="w-family"><b>Family</b><div>${lastCi ? esc(lastCi.title) : 'Checked in 2:10 pm'}</div></div>`;
}

// ---------- paywalls
function paywallChoose() {
  return `<div class="body" style="background:#fff"><div class="hdr" style="background:#fff">${back('main')}<h1>${R.copy.choose}</h1></div>
  <div class="plus-hero" data-act="go" data-s="paywall-ind" style="cursor:pointer" data-testid="pick-ind"><h3 style="margin:0">${R.copy.indHead}</h3><div>${esc(R.plans.individual.label)} for you. ${R.plans.individual.trialDays / 7} week free trial.</div></div>
  <div class="plus-hero" style="background:linear-gradient(150deg,#05603B,#17A96A);cursor:pointer" data-act="go" data-s="paywall-grp" data-testid="pick-grp"><h3 style="margin:0">${R.copy.grpHead}</h3><div>One plan for a family or group. Members join free.</div></div></div>`;
}
function ctxLine() { return { place: 'Free includes 1 saved place.', ask: `Free includes ${R.plans.free.askPerDay} questions a day. ${R.plans.individual.label} includes ${R.plans.individual.askPerDay}.`, circle: 'Check in, Check on, SOS and Journey in a group need ALRT + for each person, or a plan covering the group.', me: '' }[st.paywallCtx] || ''; }
function paywallInd() {
  const p = R.plans.individual;
  return `<div class="body" style="background:#fff"><div class="hdr" style="background:#fff">${back('main')}<h1>${R.copy.indHead}</h1></div><div class="plus-hero"><h2 style="margin:0">${esc(p.label)}</h2><div data-testid="ctx">${esc(ctxLine())}</div><ul><li>Unlimited saved places</li><li>${p.askPerDay} Ask ALRT questions a day</li><li>Check in, Check on, SOS and Journey in any group</li></ul><div>${p.trialDays / 7}-week free trial, then <b data-testid="price">${money(p.priceAud)}/month</b></div></div>
  <div style="padding:0 16px"><button class="btn" data-act="buy" data-testid="buy">Start 2-week free trial</button><div class="muted" style="text-align:center;margin-top:8px">Price from your app store. Cancel any time.</div></div></div>`;
}
function paywallGrp() {
  const tiers = ['family', 'group20', 'group50'];
  return `<div class="body" style="background:#fff"><div class="hdr" style="background:#fff">${back('main')}<h1>${R.copy.grpHead}</h1></div><div class="card muted">One plan covers one group. It gives nobody personal benefits, including you.</div>${tiers.map((k) => `<div class="card row" style="border-left:6px solid ${R.plans[k].color}"><div class="grow"><b>${esc(R.plans[k].label)}</b><div class="muted">Up to ${R.plans[k].capacity} people</div></div><button class="btn sm" data-act="buygrp" data-k="${k}" data-testid="buy-${k}">${money(R.plans[k].priceAud)}/month</button></div>`).join('')}<div class="card"><b>Or fund it yourself</b><div class="muted">Everyone uses their own ALRT +. Up to 20 people.</div><button class="btn sec" data-act="selffund" data-testid="selffund" style="margin-top:8px">Use my ALRT +</button></div></div>`;
}

// ---------- sheets
function sheetHtml() {
  if (!st.sheet) return '';
  let inner = '';
  if (st.sheet === 'report') inner = reportSheet();
  else if (st.sheet === 'ask') inner = `<h2 style="margin-top:0">Ask ALRT</h2><div class="muted" data-testid="ask-left">${st.ask ? st.ask.remaining + ' of ' + st.ask.limit + ' left today' : ''}</div><input id="aq" placeholder="Ask about what is happening near you" data-testid="ask-input"><button class="btn" data-act="askgo" data-testid="ask-go">Ask</button>${st.askAns ? `<div class="card" data-testid="ask-answer">${esc(st.askAns)}</div>` : ''}<button class="btn sec" style="margin-top:8px" data-act="close">Close</button>`;
  else if (st.sheet === 'sos') inner = sosSheet();
  else if (st.sheet === 'sos-hold') inner = sosSheet();
  else if (typeof SHEETS !== 'undefined' && SHEETS[st.sheet]) inner = SHEETS[st.sheet]();
  return `<div class="sheet" data-testid="sheet"><div>${inner}</div></div>`;
}
function sosSheet() {
  const c = circ(); const o = st.sosOpt || { loc: 0, prec: 0 }; const pv = st.sosPreview;
  return `<h2 style="margin-top:0;color:#C8102E">Send SOS to ${esc(c?.name)}</h2>${(st.sosLists || []).length ? `<div>${[['', 'Everyone here'], ...(st.sosLists || []).map((l) => [l.id, l.name])].map(([id, n]) => `<span class="chip ${(o.list || '') === id ? 'on' : ''}" data-act="soslist" data-id="${id}">${esc(n)}</span>`).join('')}</div>` : ''}${pv ? `<div class="muted" data-testid="sos-recips">Reaches ${pv.recipients.map((r0) => esc(r0.name)).join(', ') || 'nobody yet'}${pv.preset ? ' (list: ' + esc(pv.preset.name) + ')' : ''}</div>` : ''}<div class="muted">${esc(R.wording.sosDisclaimer)}</div><div class="sect" style="margin-left:0">Share location</div>${R.sos.locationChoices.map((l, i) => `<span class="chip ${o.loc === i ? 'on' : ''}" data-act="sosloc" data-i="${i}" data-testid="sosloc-${i}">${l}</span>`).join('')}${o.loc > 0 ? `<div class="sect" style="margin-left:0">Precision</div>${R.sos.precisionChoices.map((l, i) => `<span class="chip ${o.prec === i ? 'on' : ''}" data-act="sosprec" data-i="${i}">${l}</span>`).join('')}` : ''}
  <div style="height:14px"></div><div class="hold" id="hold" data-testid="hold"><i id="holdfill"></i><span style="position:relative">Hold for 3 seconds to send</span></div><button class="btn sec" style="margin-top:10px" data-act="close">Cancel</button>`;
}
function lockHtml() { const n = st.notes[0]; return `<div class="lock" data-act="unlock" data-testid="lock"><div style="font-size:54px;font-weight:300;text-align:center">9:41</div>${n ? `<div class="n"><b>${esc(n.title)}</b><div>${esc(n.body)}</div></div>` : '<div class="n">No notifications</div>'}<div style="text-align:center;margin-top:24px;opacity:.7">Tap to close</div></div>`; }

// ---------- actions
const A = {
  async 'onb-next'() { const i = +st.screen.slice(3); st.screen = 'onb' + (i + 1); },
  'onb-agree'() { if (!$('#age').checked) return toast('Please confirm to continue'); st.screen = 'onb2'; },
  lvl(e) { st.onb.level = e.dataset.id; },
  async register() { st.wasOnboarding = true; await auth('/auth/email-password/register'); },
  async login() { st.wasOnboarding = false; await auth('/auth/email-password/login'); },
  async oauth(e) { await auth('/auth/oauth/' + e.dataset.p, true); },
  tab(e) { const t = e.dataset.tab; if (t === 'forgot' && !st.user) { st.screen = 'forgot'; return; } if (t === 'alerts' && st.screen === 'forgot') { st.screen = 'onb4'; return; } if (e.dataset.back) { st.locBack = e.dataset.back; st.sheet = null; } if (t === 'report') { st.sheet = 'report'; st.rep = st.rep || {}; } else if (t === 'plan2') st.tab = 'plan_cover'; else if (t === 'family') { st.tab = 'family'; if (typeof loadFamily === 'function') loadFamily().then(() => draw()); } else st.tab = t; },
  async open(e) { st.detail = e.dataset.id; st.tab = 'detail'; await api('/hazard/' + e.dataset.id + '/view', { method: 'POST', body: {} }); },
  view() { st.view = st.view === 'map' ? 'list' : 'map'; },
  async vote(e) { await api('/hazard/' + e.dataset.id + '/vote', { body: { vote: e.dataset.v } }); await refresh(); },
  share(e) { toast('Shared with your family circle'); },
  close() { st.sheet = null; },
  repcat(e) { st.rep.cat = e.dataset.k; }, repsev(e) { st.rep.sev = e.dataset.k; },
  async post() {
    if (!st.rep.cat) return toast('Choose a category first');
    st.rep.body = { category: st.rep.cat, severity: st.rep.sev, body: $('#rb')?.value, title: R.categories[st.rep.cat].name, lat: st.loc === 'Scarborough WA' ? -31.89 : 0, lng: st.loc === 'Scarborough WA' ? 115.76 : 0 };
    const r = await api('/hazard', { body: st.rep.body });
    st.sheet = null; if (r.ok) { st.tab = 'posted'; await refresh(); } else if (r.status === 409) { st.dup = r.data.details || r.data; st.sheet = 'duplicate'; } else refusal(r.data);
  },
  async ask() { st.sheet = 'ask'; st.askAns = ''; const r = await api('/ask-alrt/allowance'); if (r.ok) st.ask = { remaining: r.data.remaining, limit: r.data.limit }; },
  async askgo() {
    const r = await api('/ask-alrt', { body: { question: $('#aq').value || 'What is happening near me?' } });
    if (r.status === 429 && r.data.code === 'ask_limit') return refusal({ code: 'ASK_LIMIT' }, 'ask');
    if (r.ok) { st.askAns = r.data.answer; const a = await api('/ask-alrt/allowance'); st.ask = { remaining: a.data.remaining, limit: a.data.limit }; }
  },
  async addplace() {
    const r = await api('/user/subscribe-location', { body: { name: $('#pn').value || 'Home' } });
    if (r.status === 402) return refusal(r.data, 'place'); await refresh();
  },
  paywall(e) { st.paywallCtx = e.dataset.ctx; st.screen = 'paywall-ind'; },
  go(e) { st.screen = e.dataset.s; },
  async buy() {
    // Simulates the store sheet then the RevenueCat webhook the real backend receives.
    await api('/revenuecat/webhook', { body: { event: { type: 'INITIAL_PURCHASE', app_user_id: st.user.id, product_id: 'individual_monthly', is_trial_period: true } } });
    await api('/access/reconcile', { body: {} }); await refresh(); st.screen = 'main'; toast('Welcome to ALRT +. Your free trial has started.');
  },
  async buygrp(e) {
    const c = circ(); if (!c) { st.screen = 'main'; st.tab = 'family'; return toast('Create a group first. It is free.'); }
    const si = await api('/access/sponsorship-intents', { body: { tier: e.dataset.k, circleId: c.circleId } });
    if (!si.ok) { st.screen = 'main'; st.tab = 'family'; return refusal(si.data); }
    // store sheet (simulated) then RevenueCat webhook, then bind
    await api('/revenuecat/webhook', { body: { event: { type: 'INITIAL_PURCHASE', app_user_id: st.user.id, product_id: 'alrt_' + e.dataset.k + '_monthly' } } });
    const r = await api('/access/sponsorships/' + si.data.id + '/bind', { body: { circleId: c.circleId } });
    if (r.status === 409 && r.data.details?.replaceable) { const r2 = await api('/access/sponsorships/' + si.data.id + '/bind', { body: { circleId: c.circleId, replaceExisting: true } }); if (!r2.ok) { st.screen = 'main'; return refusal(r2.data); } }
    else if (!r.ok) { st.screen = 'main'; st.tab = 'family'; return refusal(r.data); }
    await refresh(); st.screen = 'main'; st.tab = 'family'; toast('This group is covered. Members join free.');
  },
  async selffund() {
    const c = st.circles[0]; if (!c) { st.screen = 'main'; return; }
    const r = await api('/access/groups/' + c.circleId + '/individual-funding', { body: {} });
    if (r.status === 402) { st.screen = 'paywall-ind'; return; } toast(r.ok ? 'Using your ALRT +' : r.data.message); st.screen = 'main'; st.tab = 'family';
  },
  async mkcircle() { await api('/family/circles', { body: { name: $('#cn').value || 'My group' } }); await refresh(); },
  async join() { const r = await api('/family/join', { body: { code: $('#jc').value.trim().toUpperCase() } }); if (!r.ok) toast(r.data.message); await refresh(); },
  
  async checkon(e) { const r = await api('/family/circles/' + e.dataset.id + '/check-in/request', { body: { memberIds: [e.dataset.uid] } }); st.sheet = null; if (r.status === 402) return refusal(r.data, 'circle'); toast('Asked them to check in'); if (typeof loadFamily === 'function') await loadFamily(); },
  async sosopen() { const c = circ(); if (c && !c.connectionAccess.allowed) return refusal({ code: c.connectionAccess.reason }, 'circle'); const lst = st.sosOpt?.list; const pv = await api('/family/sos/preview?circleId=' + c.circleId + (lst ? '&sosListId=' + lst : '')); if (pv.ok && ['noPeople', 'noneEligible'].includes(pv.data.state)) return refusal({ code: 'NO_SOS_RECIPIENTS' }); st.sosPreview = pv.data; st.sosLists = st.sosLists || (await api('/family/sos-lists')).data; st.sheet = 'sos'; st.sosOpt = { loc: 0, prec: 0, list: lst || null }; },
  sosloc(e) { st.sosOpt.loc = +e.dataset.i; }, sosprec(e) { st.sosOpt.prec = +e.dataset.i; }, soslist(e) { st.sosOpt.list = e.dataset.id || null; A.sosopen(); },
  async sosextend(e) { await api('/family/sos/' + e.dataset.id + '/extend', { body: {} }); await refresh(); if (st.tab === 'sosreceiver') st.viewSos = (await api('/family/sos/' + e.dataset.id)).data; },
  async sosstop(e) { const r = await api('/family/sos/' + e.dataset.id + '/resolve', { body: {} }); if (!r.ok) return toast(r.data.message); await refresh(); if (st.tab === 'sosreceiver') { st.viewSos = (await api('/family/sos/' + e.dataset.id)).data; st.tab = 'sosresolved'; } },
  jmin(e) { st.jmin = +e.dataset.m; },
  async jstart(e) { const r = await api('/family/circles/' + e.dataset.id + '/journeys', { body: { minutes: st.jmin || 30, live: $('#jlive')?.checked, recipientMemberIds: st.jRecips || [] } }); if (r.status === 402) return refusal(r.data, 'circle'); if (!r.ok) return refusal(r.data); await refresh(); },
  async jext(e) { const r = await api('/family/journeys/' + e.dataset.id + '/extend', { body: {} }); if (r.status === 402) return refusal(r.data, 'circle'); if (!r.ok) toast(r.data.message); await refresh(); },
  async jstop(e) { await api('/family/journeys/' + e.dataset.id + '/stop', { body: {} }); await refresh(); },
  async setlevel(e) { await api('/user/push-notification-settings', { method: 'PUT', body: { level: e.dataset.id } }); await refresh(); },
  cohort(e) { const c = myCohorts(); const k = e.dataset.k; const n = c.includes(k) ? c.filter((x) => x !== k) : [...c, k]; localStorage.setItem('alrt_cohorts', JSON.stringify(n)); },
  learn(e) { st.learnT = e.dataset.t; st.tab = 'learn'; },
  async guidedone() { await api('/guide/' + st.learnT + '/complete', { body: {} }); await refresh(); toast('Nice. +' + R.points.guideComplete + ' points'); st.tab = 'ready'; },
  toast(e) { toast(e.dataset.m); },
  unlock() { st.lock = null; },
  sheet(e) { st.sheet = e.dataset.sheet; },
  async signout() { await api('/notification/push-notification-token', { method: 'DELETE', body: {} }); st.token = ''; localStorage.removeItem('alrt_tok'); st.user = null; st.sheet = null; st.circles = []; st.sos = []; st.notes = []; st.circleId = null; st.screen = 'onb0'; st.tab = 'alerts'; },
};
async function findCode(id) { const r = await api('/family/circles'); return r.data.find((c) => c.circleId === id)?.code || ''; }
async function auth(p, oauth) {
  const em = $('#em')?.value, pw = $('#pw')?.value;
  const r = await api(p, { body: oauth ? {} : { email: em, password: pw, name: em?.split('@')[0] } });
  if (!r.ok) return toast(r.data.message || 'Could not sign in');
  st.token = r.data.token; localStorage.setItem('alrt_tok', st.token); await refresh();
  if (st.onb.level) await api('/user/push-notification-settings', { method: 'PUT', body: { level: st.onb.level } });
  await api('/onboarding/accept-disclaimer', { body: { ok: true } }); await api('/onboarding/accept-tos', { body: { ok: true } });
  st.screen = 'main'; st.tab = st.wasOnboarding === false ? 'alerts' : 'onbdone';
}
function gate(d, ctx) {
  st.sheet = null; st.paywallCtx = ctx;
  st.screen = d.code === 'INDIVIDUAL_REQUIRED' ? 'paywall-choose' : 'paywall-ind';
}

document.addEventListener('click', async (ev) => {
  const d = ev.target.closest('[data-dev]');
  if (d) return dev(d.dataset.dev);
  const t = ev.target.closest('[data-act]'); if (!t) return;
  const f = A[t.dataset.act]; if (!f) return;
  await f(t); draw();
});
async function dev(k) {
  if (k === 'reset') { await api('/__reset', { method: 'POST', body: {} }); localStorage.clear(); st.token = ''; st.user = null; st.screen = 'onb0'; st.circles = []; st.sos = []; st.notes = []; st.seenNotes = 0; st.places = []; }
  if (k.startsWith('advance')) { await api('/__advance', { body: { ms: { advance10: 10, advance50: 50, advance61: 61 }[k] * 60000 } }); await refresh(); }
  if (k === 'billing') { await api('/__billing', { body: { on: !(st.access?.billingEnabled) } }); await refresh(); }
  if (k === 'offline') st.offline = !st.offline;
  if (k === 'friend') { const c = st.circles[0]; if (!c) return toast('Create a group first'); const r = await api('/auth/email-password/register', { body: { email: 'friend' + Date.now() + '@example.com', password: 'x', name: 'Alex' } }); await api('/revenuecat/webhook', { body: { event: { type: 'INITIAL_PURCHASE', app_user_id: r.data.user.id, product_id: 'individual_monthly' } } }); await api('/family/join', { body: { code: await findCode(c.circleId) } }); /* friend joins via their own token */ await fetch('/api/family/join', { method: 'POST', headers: { 'content-type': 'application/json', authorization: 'Bearer ' + r.data.token }, body: JSON.stringify({ code: await findCode(c.circleId) }) }); await refresh(); }
  if (k === 'confirm') { const h = st.hazards.find((x) => x.source === 'community' && x.authorId === st.user?.id) || st.hazards.find((x) => x.source === 'community'); if (h) { await api('/hazard/' + h.id + '/vote', { body: { vote: 'see' } }); await refresh(); } }
  if (k === 'push') st.lock = true;
  if (k === 'expire') { await api('/__expire-plan', { body: {} }); await refresh(); }
  if (k === 'billissue') { await api('/__billing-issue', { body: { userId: st.user.id } }); await refresh(); }
  if (k === 'forceupdate') st.forceUpdate = !st.forceUpdate;
  if (k.startsWith('friend') && k !== 'friend') {
    const ft = (await api('/__friend-token')).data; const c = circ(); if (!ft.token || !c) return toast('Add a friend to your group first');
    const call = (p, body) => fetch('/api' + p, { method: 'POST', headers: { 'content-type': 'application/json', authorization: 'Bearer ' + ft.token }, body: JSON.stringify(body) });
    if (k === 'friendsos') await call('/family/circles/' + c.circleId + '/sos', { heldMs: 3000, location: 'once', precision: 'exact' });
    if (k === 'friendask') await call('/family/members/' + st.user.id + '/location-request', { circleId: c.circleId });
    if (k === 'friendjourney') await call('/family/circles/' + c.circleId + '/journeys', { minutes: 30, recipientMemberIds: [st.user.id] });
    await loadFamily();
  }
  draw();
}
// hold-to-send SOS (real 3 second hold)
let holdT, holdStart;
document.addEventListener('pointerdown', (e) => {
  const h = e.target.closest('#hold'); if (!h) return;
  holdStart = Date.now(); const fill = $('#holdfill');
  fill.style.transition = `width ${R.timings.sosHoldMs}ms linear`; fill.style.width = '100%';
  holdT = setTimeout(async () => {
    const c = circ(); const o = st.sosOpt || { loc: 0, prec: 0 };
    const r = await api('/family/circles/' + c.circleId + '/sos', { body: { sosListId: o.list || undefined, heldMs: Date.now() - holdStart, location: ['none', 'once', 'live'][o.loc], precision: ['exact', 'suburb'][o.prec] } });
    st.sheet = null; if (!r.ok) refusal(r.data, 'circle'); else toast('SOS sent to ' + c.name);
    await refresh(); draw();
  }, R.timings.sosHoldMs);
});
const cancelHold = () => { clearTimeout(holdT); const f = $('#holdfill'); if (f) { f.style.transition = 'none'; f.style.width = '0'; } };
document.addEventListener('pointerup', cancelHold); document.addEventListener('pointercancel', cancelHold);

boot();

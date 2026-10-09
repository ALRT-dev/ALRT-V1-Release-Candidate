// Actions: every tap in the prototype ends here and talks to the mock backend (same routes as the real API).
const PRE = ['Splash', 'Onb1', 'Onb2', 'Onb3', 'Onb4', 'Onb5', 'forgot', 'onbdone'];
const OVERLAY = ['Choose', 'Paywall', 'GroupPaywall'];
function go(name) {
  if (OVERLAY.includes(name)) { st.screen = name; return; }
  if (PRE.includes(name)) { st.screen = name; return; }
  if (!st.user) { st.screen = 'Onb5'; return; }
  st.screen = 'main'; st.tab = name === 'Family' && !circ() ? 'FamilyEmpty' : name;
  if (name === 'Family') loadFamily().then(() => draw(true));
}
async function loadFamily() { await refresh(); const c = circ(); if (c) { st.ciReqs = (await api('/family/check-in/requests?circleId=' + c.circleId)).data; st.locReqs = (await api('/family/location-requests/pending')).data; st.sharedJ = (await api('/family/journeys/shared')).data; st.sosLists = (await api('/family/sos-lists')).data; } }
async function refresh() {
  const [pr, ac, hz, ci, so, nf, jr, pl] = await Promise.all([api('/user/profile'), api('/access'), api('/alert/geo'), api('/family/circles'), api('/family/sos/active'), api('/notification/feed'), api('/family/journeys/me'), api('/user/location-subscriptions')]);
  if (pr.status === 401) { st.token = ''; st.user = null; return; }
  if (pr.ok) st.user = pr.data;
  if (ac.ok) st.access = ac.data;
  if (hz.ok) { st.hazards = hz.data.filter((h) => h.status === 'live'); st.lastSync = new Date(); }
  if (ci.ok) st.circles = ci.data;
  if (so.ok) st.sos = so.data;
  if (nf.ok) st.notes = nf.data;
  if (jr.ok) st.journeys = jr.data;
  if (pl.ok) st.places = pl.data;
  const xp = await api('/xpPoints/summary'); if (xp.ok) st.pts = xp.data;
  if (st.user) st.locReqs = (await api('/family/location-requests/pending')).data;
}
async function boot() {
  R = await (await fetch('/rules.json')).json();
  try { st.filters = JSON.parse(localStorage.getItem('alrt_filters')) || null; st.followed = JSON.parse(localStorage.getItem('followed_alert_ids')) || []; st.plan = JSON.parse(localStorage.getItem('alrt_plan')) || null; st.primed = localStorage.getItem('alrt_primed') === '1'; } catch {}
  if (!st.filters) st.filters = { sources: ['aws', 'official', 'community', 'global', 'intel'], bands: Object.keys(R.bands), cats: Object.keys(R.categories) };
  if (st.token) { await refresh(); if (st.user) { st.screen = 'main'; st.tab = 'Main'; } }
  draw();
  setInterval(poll, 1500);
}
async function poll() {
  if (!st.token || st.offline || st.sheet === 'sos' || st.lock) return;
  const before = st.notes.length; await refresh();
  if (st.screen === 'main' && ['Family', 'rollcall'].includes(st.tab)) { const c = circ(); if (c) { st.ciReqs = (await api('/family/check-in/requests?circleId=' + c.circleId)).data; st.sharedJ = (await api('/family/journeys/shared')).data; } }
  if (st.notes.length > before && st.screen === 'main' && st.notes[0].kind !== 'test') toast(st.notes[0].title);
  draw(true);
}
function cohortsSet(a) { try { localStorage.setItem('alrt_cohorts', JSON.stringify(a)); } catch {} }

const A = {
  // onboarding
  onbwho(e) { st.onb.who = e.dataset.who; },
  onbagree(e) { const i = +e.dataset.i; const k = st.onb.agreed.indexOf(i); k >= 0 ? st.onb.agreed.splice(k, 1) : st.onb.agreed.push(i); },
  onbagreego() { if (st.onb.agreed.length < 4) return toast('Tap all four to continue'); go('Onb3'); },
  lvl(e) { st.onb.level = e.dataset.id; },
  onbprime() { st.primed = true; try { localStorage.setItem('alrt_primed', '1'); } catch {} go('Onb4'); },
  emailsheet() { st.authMode = 'register'; st.sheet = 'emailauth'; },
  authmode(e) { st.authMode = e.dataset.m; },
  forgotopen() { st.sheet = null; go('forgot'); },
  async register() { st.wasOnboarding = true; await auth('/auth/email-password/register'); },
  async login() { st.wasOnboarding = false; await auth('/auth/email-password/login'); },
  async oauth(e) { st.wasOnboarding = true; await auth('/auth/oauth/' + e.dataset.p, true); },
  async forgot() { await api('/auth/password-reset/request', { body: { email: $('#fe')?.value } }); st.forgotSent = true; },
  onbgo() { st.screen = 'main'; st.tab = 'Main'; if (!st.primed) st.sheet = 'priming'; },
  primeon() { st.primed = true; try { localStorage.setItem('alrt_primed', '1'); } catch {} st.sheet = null; toast('Alerts are on'); api('/notification/push-notification-token', { body: { token: 'demo-token' } }); },
  primelater() { st.sheet = null; },
  async recover() { const r = await api('/user/account/cancel-deletion', { body: {} }); if (r.ok) { toast('Your account has been recovered'); await refresh(); st.tab = 'Main'; } },
  // navigation
  tab(e) { const t = e.dataset.tab; if (e.dataset.back) { st.locBack = e.dataset.back; } st.sheet = null; if (t === 'Family') return go('Family'); st.screen = 'main'; st.tab = t; },
  go(e) { go(e.dataset.s); },
  closepay() { st.screen = st.user ? 'main' : 'Onb4'; },
  close() { st.sheet = null; },
  noop() {},
  toast(e) { toast(e.dataset.m); },
  unlock() { st.lock = null; },
  sheet(e) { st.sheet = e.dataset.sheet; },
  retry() { st.offline = false; refresh().then(() => draw()); },
  // alerts
  async open(e) { const h = st.hazards.find((x) => x.id === e.dataset.id); if (!h) return; st.detail = h.id; st.screen = 'main'; st.tab = h.source === 'community' ? 'Community' : (h.board && window.BOARDS[h.board]) ? h.board : 'Detail'; await api('/hazard/' + h.id + '/view', { method: 'POST', body: {} }); },
  openfilters() { st.sheet = 'filters'; }, mapkey() { st.sheet = 'mapkey'; },
  filt(e) { const arr = st.filters[e.dataset.k]; const i = arr.indexOf(e.dataset.v); i >= 0 ? arr.splice(i, 1) : arr.push(e.dataset.v); try { localStorage.setItem('alrt_filters', JSON.stringify(st.filters)); } catch {} },
  filtreset() { st.filters = { sources: ['aws', 'official', 'community', 'global', 'intel'], bands: Object.keys(R.bands), cats: Object.keys(R.categories) }; try { localStorage.setItem('alrt_filters', JSON.stringify(st.filters)); } catch {} },
  opennotes() { st.seenNotes = st.notes.length; st.screen = 'main'; st.tab = 'notes'; },
  async vote(e) { await api('/hazard/' + e.dataset.id + '/vote', { body: { vote: e.dataset.v } }); toast(e.dataset.v === 'see' ? 'Thanks. You confirmed this alert.' : 'Thanks. Noted.'); await refresh(); },
  follow() { const f = st.followed; const i = f.indexOf(st.detail); i >= 0 ? f.splice(i, 1) : f.push(st.detail); try { localStorage.setItem('followed_alert_ids', JSON.stringify(f)); } catch {} },
  readaloud() { const h = st.hazards.find((x) => x.id === st.detail); toast('Reading aloud: ' + (h?.plain || h?.body || '')); },
  sharefam() { st.sheet = null; toast('Shared with your family circle'); },
  async cihazard() { const c = circ(); if (!c) { go('Family'); return; } const r = await api('/family/circles/' + c.circleId + '/check-in', { body: { hazardId: st.detail } }); if (r.status === 402) return refusal(r.data, 'circle'); if (!r.ok) return toast(r.data.message); st.ciDone = st.detail; toast('Checked in. Your circle has been notified.'); },
  flagsheet() { st.sheet = 'flagblock'; st.flagReason = 'misleading'; }, flagr(e) { st.flagReason = e.dataset.r; },
  async flag() { const r = await api('/hazard/' + st.detail + '/flag', { body: { reason: st.flagReason } }); st.sheet = null; toast(r.ok ? 'Thanks. This report has been sent for review.' : r.data.message); await refresh(); if (!st.hazards.find((x) => x.id === st.detail)) st.tab = 'Feed'; },
  async block() { const r = await api('/user/blocked', { body: { hazardId: st.detail } }); st.sheet = null; toast(r.ok ? 'Blocked. You will not see their reports.' : r.data.message); },
  async ask() { st.sheet = 'ask'; st.askAns = ''; const r = await api('/ask-alrt/allowance'); if (r.ok) st.ask = { remaining: r.data.remaining, limit: r.data.limit }; },
  async askgo() { st.askQ = $('#aq')?.value || ''; const r = await api('/ask-alrt', { body: { question: st.askQ || 'What is happening near me?' } }); if (r.status === 429 && r.data.code === 'ask_limit') return refusal({ code: 'ASK_LIMIT' }, 'ask'); if (!r.ok) return refusal(r.data); st.askAns = r.data.answer; st.askSrc = r.data.source || 'ai'; const a = await api('/ask-alrt/allowance'); st.ask = { remaining: a.data.remaining, limit: a.data.limit }; },
  async addplace() { const name = $('#pn')?.value || 'Home'; const r = await api('/user/subscribe-location', { body: { name } }); if (r.status === 402) return refusal(r.data, 'place'); if (!r.ok) return refusal(r.data); toast(`ALRT will keep an eye on ${name} even when you're away.`); await refresh(); },
  async unsub(e) { await api('/user/unsubscribe', { body: { id: e.dataset.id } }); await refresh(); },
  locpick(e) { st.loc = e.dataset.n === 'Scarborough WA' ? 'Scarborough' : e.dataset.n; st.screen = 'main'; st.tab = st.locBack || 'Main'; },
  routemode(e) { (st.route ||= {}).mode = e.dataset.m; },
  routego() { st.route = { ...(st.route || {}), from: $('#rfrom')?.value, to: $('#rto')?.value || 'Perth CBD' }; const n = visibleHazards().filter((h) => ['critical', 'action'].includes(h.band)).length; st.route.result = { crosses: Math.min(n, 1) }; },
  // report
  repcat(e) { st.rep = st.rep || {}; st.rep.cat = e.dataset.k; st.rep.obs = null; st.rep.text = $('#rb')?.value || st.rep.text; },
  repobs(e) { st.rep.obs = e.dataset.o; st.rep.text = $('#rb')?.value || st.rep.text; if (e.dataset.o === 'Something else') setTimeout(() => $('#rb')?.focus(), 50); },
  repsev(e) { st.rep.sev = e.dataset.k; st.rep.text = $('#rb')?.value || st.rep.text; },
  async post() {
    const rep = st.rep || {}; if (!rep.cat) return toast('Choose a category first');
    rep.text = $('#rb')?.value || '';
    rep.body = { category: rep.cat, severity: rep.sev || 'significant', body: rep.text, title: `${rep.obs || R.categories[rep.cat].name} reported in ${st.loc || 'Scarborough'}`, lat: -31.89, lng: 115.76, locationName: st.loc || 'Scarborough' };
    const r = await api('/hazard', { body: rep.body });
    if (r.ok) { st.rep = {}; st.tab = 'Posted'; await refresh(); } else if (r.status === 409) { st.dup = r.data.details || r.data; st.sheet = 'duplicate'; } else refusal(r.data);
  },
  async dupconfirm() { await api('/hazard/' + st.dup.existingHazardId + '/vote', { body: { vote: 'see' } }); st.sheet = null; toast('Thanks. You confirmed this alert.'); st.rep = {}; st.tab = 'Feed'; await refresh(); },
  async dupforce() { const r = await api('/hazard', { body: { ...st.rep.body, force: true } }); st.sheet = null; if (r.ok) { st.rep = {}; st.tab = 'Posted'; await refresh(); } else refusal(r.data); },
  async loadmine() { st.mine = (await api('/hazard/mine')).data; st.screen = 'main'; st.tab = 'myalrts'; },
  // ready
  guideopen(e) { st.learnT = e.dataset.t.split(':')[0]; st.tab = 'guide'; },
  async guidedone() { await api('/guide/' + st.learnT + '/complete', { body: {} }); await refresh(); toast('Nice. +' + R.points.guideComplete + ' points'); },
  planpick(e) { st.planPick = e.dataset.t; },
  plansave() { st.plan = { first: st.planPick || 'Leave early' }; try { localStorage.setItem('alrt_plan', JSON.stringify(st.plan)); } catch {} toast('Plan saved on your phone'); st.tab = 'Ready'; },
  drillstart() { st.drill = Date.now(); toast('Practice alert sent to your circle. No real emergency, no alarm.'); },
  cohort(e) { const c = myCohorts(); const k = e.dataset.k; const n = c.includes(k) ? c.filter((x) => x !== k) : [...c, k]; cohortsSet(n); },
  cohortclear() { cohortsSet([]); st.tab = 'Ready'; },
  // family
  async mkcircle() { const r = await api('/family/circles', { body: { name: $('#cn')?.value || 'My group' } }); st.sheet = null; await refresh(); st.circleId = r.data.circleId; go('Family'); },
  async join() { const r = await api('/family/join', { body: { code: ($('#jc')?.value || '').trim().toUpperCase() } }); st.sheet = null; if (!r.ok) return refusal(r.data); await refresh(); st.circleId = r.data.circleId; go('Family'); },
  async join2() { const r = await api('/family/join', { body: { code: ($('#jc2')?.value || '').trim().toUpperCase() } }); if (!r.ok) return refusal(r.data); await refresh(); st.circleId = r.data.circleId; go('Family'); },
  async mkcircle2() { const r = await api('/family/circles', { body: { name: $('#cn2')?.value || 'Another circle' } }); await refresh(); st.circleId = r.data.circleId; go('Family'); },
  pickcircle(e) { st.circleId = e.dataset.id; go('Family'); },
  cisheet(e) { st.ciReq = e?.dataset?.req || null; st.sheet = 'checkin'; },
  async ci(e) { const c = circ(); const mode = e.dataset.mode; const body = { requestId: st.ciReq || undefined }; if (mode === 'help') body.status = 'needsHelp'; if (mode === 'exact' || mode === 'suburb') { body.latitude = -31.89; body.precision = mode; } const r = await api('/family/circles/' + c.circleId + '/check-in', { body }); st.sheet = null; if (r.status === 402) return refusal(r.data, 'circle'); if (!r.ok) return toast(r.data.message); toast(mode === 'help' ? 'Your circle has been told you need help.' : 'Checked in. Your circle has been notified.'); await loadFamily(); if (st.tab === 'rollcall') st.tab = 'Family'; },
  askcisheet() { st.askSel = []; st.askMsg = ''; st.sheet = 'askcheckin'; },
  asksel(e) { st.askMsg = $('#askmsg')?.value || ''; const i = st.askSel.indexOf(e.dataset.id); i >= 0 ? st.askSel.splice(i, 1) : st.askSel.push(e.dataset.id); },
  async askgo2() { const c = circ(); const r = await api('/family/circles/' + c.circleId + '/check-in/request', { body: { memberIds: st.askSel, message: $('#askmsg')?.value } }); st.sheet = null; if (r.status === 402) return refusal(r.data, 'circle'); if (!r.ok) return toast(r.data.message); await loadFamily(); st.rollId = r.data.id; st.tab = 'rollcall'; },
  async checkon(e) { const r = await api('/family/circles/' + e.dataset.id + '/check-in/request', { body: { memberIds: [e.dataset.uid] } }); st.sheet = null; if (r.status === 402) return refusal(r.data, 'circle'); if (!r.ok) return toast(r.data.message); toast('Asked them to check in'); await loadFamily(); },
  async rollcall(e) { await loadFamily(); if (e?.dataset?.id) st.rollId = e.dataset.id; st.tab = 'rollcall'; },
  async rccancel(e) { await api('/family/check-in/request/' + e.dataset.id, { method: 'DELETE', body: {} }); await loadFamily(); st.tab = 'Family'; toast('Check-in ask cancelled'); },
  async locreq(e) { const c = circ(); const r = await api('/family/members/' + e.dataset.id + '/location-request', { body: { circleId: c.circleId } }); st.sheet = null; if (r.status === 402) return refusal(r.data, 'circle'); toast(r.ok ? 'Asked ' + nm(e.dataset.id) + ' for a one-time location' : r.data.message); },
  openlocreq() { st.sheet = 'locrequest'; },
  async locresp(e) { const r = await api('/family/location-requests/' + e.dataset.id + '/respond', { body: { share: e.dataset.share === '1' } }); st.sheet = null; if (r.status === 402) return refusal(r.data, 'circle'); toast(e.dataset.share === '1' ? 'Snapshot shared. It expires in 1 hour.' : 'Declined. Nothing was sent.'); await loadFamily(); },
  membersheet(e) { st.memberId = e.dataset.id; st.sheet = 'member'; },
  async removem(e) { const r = await api('/family/members/' + e.dataset.id, { method: 'DELETE', body: { circleId: circ().circleId } }); st.sheet = null; if (!r.ok) return refusal(r.data); await loadFamily(); toast('Removed'); },
  async goinvite() { st.sheet = null; st.invites = (await api('/family/invites?circleId=' + circ().circleId)).data; st.screen = 'main'; st.tab = 'invite'; },
  async mkinvite() { const r = await api('/family/invites', { body: { circleId: circ().circleId } }); if (!r.ok) return refusal(r.data); st.invites = (await api('/family/invites?circleId=' + circ().circleId)).data; await refresh(); },
  async revoke(e) { const r = await api('/family/invites/' + e.dataset.id + '/revoke', { body: {} }); if (!r.ok) return refusal(r.data); st.invites = (await api('/family/invites?circleId=' + circ().circleId)).data; },
  async gtoggle(e) { const c = circ(); const s = { ...c.settings }; s[e.dataset.k] = !s[e.dataset.k]; const r = await api('/family/circle', { method: 'PUT', body: { circleId: c.circleId, ...s } }); if (!r.ok) return refusal(r.data); await refresh(); },
  async gsave() { const r = await api('/family/circle', { method: 'PUT', body: { circleId: circ().circleId, name: $('#gname').value } }); if (!r.ok) return refusal(r.data); await refresh(); toast('Saved'); },
  async transfer() { const r = await api('/family/circle/transfer-candidates?circleId=' + circ().circleId); if (!r.ok) return refusal(r.data); st.candidates = r.data.candidates; st.sheet = 'transfer'; },
  async transferto(e) { const r = await api('/family/circle/transfer-ownership', { body: { circleId: circ().circleId, newOwnerMemberId: e.dataset.id } }); st.sheet = null; if (!r.ok) return refusal(r.data); await loadFamily(); toast(nm(e.dataset.id) + ' now hosts this circle'); st.tab = 'Family'; },
  async closecircle() { const r = await api('/family/circle', { method: 'DELETE', body: { circleId: circ().circleId } }); if (!r.ok) return refusal(r.data); await refresh(); st.circleId = null; go('Family'); },
  leavesheet() { st.sheet = 'leave'; },
  async leave() { const r = await api('/family/circle/leave', { body: { circleId: circ().circleId } }); st.sheet = null; await refresh(); st.circleId = null; go('Family'); toast(r.data.outcome === 'hostTransition' ? 'You left. Members have 7 days to choose a new host.' : 'You left the circle'); },
  async takeover() { const r = await api('/family/circle/take-over', { body: { circleId: circ().circleId } }); if (!r.ok) return toast(r.data.message); await loadFamily(); st.tab = 'Family'; toast('You now host this circle'); },
  async loadprofile() { st.sched = (await api('/family/scheduled-check-ins')).data; st.screen = 'main'; st.tab = 'circleprofile'; },
  setcolor(e) { st.pendingColor = e.dataset.h; circ().members.find((x) => x.id === me()).colorHex = e.dataset.h; },
  async savenick() { await api('/family/members/me', { method: 'PUT', body: { circleId: circ().circleId, nickname: $('#nick').value, colorHex: st.pendingColor } }); await refresh(); toast('Saved'); },
  async schedadd() { const r = await api('/family/scheduled-check-ins', { body: { timeOfDay: $('#schedt').value } }); if (!r.ok) return toast(r.data.message); st.sched = (await api('/family/scheduled-check-ins')).data; },
  async scheddel(e) { await api('/family/scheduled-check-ins/' + e.dataset.id, { method: 'DELETE', body: {} }); st.sched = (await api('/family/scheduled-check-ins')).data; },
  async setsharing(e) { await api('/family/members/me', { method: 'PUT', body: { circleId: circ().circleId, sharingLevel: e.dataset.k } }); await refresh(); },
  async loadplaces() { st.famPlaces = (await api('/family/places?circleId=' + circ().circleId)).data; st.screen = 'main'; st.tab = 'famplaces'; },
  async fpadd() { const r = await api('/family/places', { body: { circleId: circ().circleId, name: $('#fpn').value, address: st.loc || '' } }); if (!r.ok) return toast(r.data.message); st.famPlaces = (await api('/family/places?circleId=' + circ().circleId)).data; await refresh(); },
  async fpdel(e) { await api('/family/places/' + e.dataset.id, { method: 'DELETE', body: {} }); st.famPlaces = (await api('/family/places?circleId=' + circ().circleId)).data; },
  async fpprefs(e) { const p0 = st.famPlaces.find((x) => x.id === e.dataset.id); const on = !(p0.prefs[me()]?.notifyArrivals); await api('/family/places/' + e.dataset.id + '/prefs', { method: 'PUT', body: { subjectMemberId: me(), notifyArrivals: on, notifyDepartures: on } }); st.famPlaces = (await api('/family/places?circleId=' + circ().circleId)).data; },
  async loadsoslists() { st.sosLists = (await api('/family/sos-lists')).data; st.recips = (await api('/family/sos-recipients')).data; st.screen = 'main'; st.tab = 'soslists'; },
  async sosedit(e) { if (!st.recips) st.recips = (await api('/family/sos-recipients')).data; const l = (st.sosLists || []).find((x) => x.id === e.dataset.id); st.editList = l ? { ...l, memberIds: [...l.memberIds] } : { id: '', name: '', memberIds: [], isDefault: false }; st.tab = 'soslistedit'; },
  slsel(e) { st.editList.name = $('#sln')?.value ?? st.editList.name; const a = st.editList.memberIds; const i = a.indexOf(e.dataset.id); i >= 0 ? a.splice(i, 1) : a.push(e.dataset.id); },
  sldef() { st.editList.name = $('#sln')?.value ?? st.editList.name; st.editList.isDefault = !st.editList.isDefault; },
  async slsave() { const l = st.editList; const body = { name: $('#sln')?.value || 'My list', memberIds: l.memberIds, isDefault: l.isDefault }; const r = l.id ? await api('/family/sos-lists/' + l.id, { method: 'PUT', body }) : await api('/family/sos-lists', { body }); if (!r.ok) return refusal(r.data); st.sosLists = (await api('/family/sos-lists')).data; st.tab = 'soslists'; },
  async sldel() { await api('/family/sos-lists/' + st.editList.id, { method: 'DELETE', body: {} }); st.sosLists = (await api('/family/sos-lists')).data; st.tab = 'soslists'; },
  async sosopen() { const c = circ(); if (!c) return go('Family'); if (!c.connectionAccess.allowed) return refusal({ code: c.connectionAccess.reason }, 'circle'); const lst = st.sosOpt?.list; const pv = await api('/family/sos/preview?circleId=' + c.circleId + (lst ? '&sosListId=' + lst : '')); if (pv.ok && ['noPeople', 'noneEligible'].includes(pv.data.state)) return refusal({ code: 'NO_SOS_RECIPIENTS' }); st.sosPreview = pv.data; st.sosLists = st.sosLists || (await api('/family/sos-lists')).data; st.sheet = 'sos'; st.sosOpt = { loc: 0, prec: 0, list: lst || null }; },
  sosloc(e) { st.sosOpt.loc = +e.dataset.i; }, sosprec(e) { st.sosOpt.prec = +e.dataset.i; }, soslist(e) { st.sosOpt.list = e.dataset.id || null; A.sosopen(); },
  async sosextend(e) { const r = await api('/family/sos/' + e.dataset.id + '/extend', { body: {} }); if (!r.ok) return refusal(r.data); await refresh(); if (st.tab === 'sosreceiver') st.viewSos = (await api('/family/sos/' + e.dataset.id)).data; },
  async sosstop(e) { const r = await api('/family/sos/' + e.dataset.id + '/resolve', { body: {} }); if (!r.ok) return toast(r.data.message); await refresh(); if (st.tab === 'sosreceiver') { st.viewSos = (await api('/family/sos/' + e.dataset.id)).data; st.tab = 'sosresolved'; } },
  async viewsos(e) { const r = await api('/family/sos/' + e.dataset.id); st.viewSos = r.data; st.screen = 'main'; st.tab = r.data.active ? 'sosreceiver' : 'sosresolved'; },
  async viewsosbanner() { const s = mySosAny(); if (s) { st.viewSos = (await api('/family/sos/' + s.id)).data; st.screen = 'main'; st.tab = 'sosreceiver'; } },
  async sosresp(e) { const r = await api('/family/sos/' + e.dataset.id + '/respond', { body: { type: e.dataset.t } }); if (!r.ok) return toast(r.data.message); toast({ seen: 'They know you have seen it', onMyWay: 'They know you are on your way', called: 'Noted' }[e.dataset.t]); st.viewSos = (await api('/family/sos/' + e.dataset.id)).data; },
  async loadhist() { st.sosHist = (await api('/family/sos/history')).data; st.screen = 'main'; st.tab = 'soshistory'; },
  async viewjourney(e) { const r = await api('/family/journeys/' + e.dataset.id); if (!r.ok) return toast(r.data.message); st.viewJ = r.data; st.screen = 'main'; st.tab = 'sharedjourney'; },
  jrecip(e) { const a = (st.jRecips ||= []); const i = a.indexOf(e.dataset.id); i >= 0 ? a.splice(i, 1) : a.push(e.dataset.id); },
  jmin(e) { st.jmin = +e.dataset.m; }, jlivetoggle() { st.jlive = !st.jlive; },
  async jstart(e) { const r = await api('/family/circles/' + e.dataset.id + '/journeys', { body: { minutes: st.jmin || 60, live: !!st.jlive, recipientMemberIds: st.jRecips || [] } }); if (r.status === 402) return refusal(r.data, 'circle'); if (!r.ok) return refusal(r.data); await refresh(); },
  async jext(e) { const r = await api('/family/journeys/' + e.dataset.id + '/extend', { body: {} }); if (r.status === 402) return refusal(r.data, 'circle'); if (!r.ok) toast(r.data.message); await refresh(); },
  async jstop(e) { await api('/family/journeys/' + e.dataset.id + '/stop', { body: {} }); await refresh(); },
  // plans
  paywall(e) { st.paywallCtx = e.dataset.ctx; go('Paywall'); },
  grptier(e) { st.grpTier = e.dataset.k; },
  async buy() {
    if (!st.user) { st.screen = 'Onb5'; return toast('Sign in first, then start your free trial'); }
    await api('/revenuecat/webhook', { body: { event: { type: 'INITIAL_PURCHASE', app_user_id: st.user.id, product_id: 'alrt_individual_monthly', is_trial_period: true } } });
    await api('/access/reconcile', { body: {} }); await refresh(); st.screen = 'main'; toast(`Welcome to ALRT +. Your ${R.plans.individual.trialDays / 7} week free trial has started.`);
  },
  async buygrp(e) {
    const c = circ(); if (!st.user) { st.screen = 'Onb5'; return toast('Sign in first'); } if (!c) { st.screen = 'main'; go('Family'); return toast('Create a group first. It is free.'); }
    const tier = e.dataset.k || st.grpTier || 'family';
    const si = await api('/access/sponsorship-intents', { body: { tier, circleId: c.circleId } });
    if (!si.ok) { st.screen = 'main'; st.tab = 'Family'; return refusal(si.data); }
    await api('/revenuecat/webhook', { body: { event: { type: 'INITIAL_PURCHASE', app_user_id: st.user.id, product_id: 'alrt_' + tier + '_monthly' } } });
    const r = await api('/access/sponsorships/' + si.data.id + '/bind', { body: { circleId: c.circleId } });
    if (r.status === 409 && r.data.details?.replaceable) { const r2 = await api('/access/sponsorships/' + si.data.id + '/bind', { body: { circleId: c.circleId, replaceExisting: true } }); if (!r2.ok) { st.screen = 'main'; return refusal(r2.data); } }
    else if (!r.ok) { st.screen = 'main'; st.tab = 'Family'; return refusal(r.data); }
    await loadFamily(); st.screen = 'main'; st.tab = 'Family'; toast('This group is covered. Members join free.');
  },
  async selffund() { const c = circ(); const r = await api('/access/groups/' + c.circleId + '/individual-funding', { body: {} }); if (r.status === 402) return refusal({ code: 'INDIVIDUAL_REQUIRED' }, 'circle'); if (!r.ok) return refusal(r.data); toast('Everyone here uses their own ALRT +'); st.tab = 'Family'; },
  async loadmanage() { await refresh(); st.screen = 'main'; st.tab = 'manage'; },
  async bind(e) { const r = await api('/access/sponsorships/' + e.dataset.s + '/bind', { body: { circleId: e.dataset.c } }); if (r.status === 409 && r.data.details?.replaceable) { st.up = { sid: e.dataset.s, cid: e.dataset.c, from: 'family', to: st.access.unboundSponsorships.find((x) => x.id === e.dataset.s)?.tier }; st.sheet = 'upgrade'; return; } if (!r.ok) return refusal(r.data); await refresh(); toast('This group is covered. Members join free.'); },
  async upgradego() { const r = await api('/access/sponsorships/' + st.up.sid + '/bind', { body: { circleId: st.up.cid, replaceExisting: true } }); st.sheet = null; if (!r.ok) return refusal(r.data); await refresh(); toast('Plan replaced'); },
  async restore() { await api('/access/reconcile', { body: {} }); await refresh(); toast('Purchases checked with the store'); },
  refusalgo() { const r0 = st.refusal; st.sheet = null; st.paywallCtx = r0.ctx; if (!r0.go) return; if (OVERLAY.includes(r0.go)) go(r0.go); else if (r0.go === 'manage') A.loadmanage(); else if (r0.go === 'invite') A.goinvite(); else if (r0.go === 'soslists') A.loadsoslists(); },
  // me
  async loadnotes() { st.pushSettings = (await api('/user/push-notification-settings')).data; st.screen = 'main'; st.tab = 'managenotes'; },
  async setlevel(e) { st.pushSettings = (await api('/user/push-notification-settings', { method: 'PUT', body: { level: e.dataset.id } })).data; await refresh(); },
  async pushf(e) { if (e.dataset.locked) return; const f = { ...st.pushSettings }; delete f.level; f[e.dataset.k] = !f[e.dataset.k]; st.pushSettings = (await api('/user/push-notification-settings', { method: 'PUT', body: f })).data; await refresh(); },
  async pushcat(e) { const f = { ...st.pushSettings }; delete f.level; const a = [...(f.subscribedCategoryIds || [])]; const i = a.indexOf(e.dataset.k); i >= 0 ? a.splice(i, 1) : a.push(e.dataset.k); f.subscribedCategoryIds = a; st.pushSettings = (await api('/user/push-notification-settings', { method: 'PUT', body: f })).data; },
  async testpush() { await api('/notification/test', { body: {} }); toast('Test sent to your phones. Nothing was sent to anyone else.'); },
  accvib() { st.acc = st.acc || {}; st.acc.vib = !st.acc.vib; }, accra() { st.acc = st.acc || {}; st.acc.ra = !st.acc.ra; },
  async loadpoints() { st.breakdown = (await api('/xpPoints/breakdown')).data; st.badges = (await api('/xpPoints/badges')).data.badges; st.screen = 'main'; st.tab = 'points'; },
  async loadlb() { st.lb = (await api('/xpPoints/leaderboard')).data; st.tab = 'leaderboard'; },
  async childtoggle() { await api('/user/profile', { method: 'PUT', body: { childMode: !st.user.childMode } }); await refresh(); try { if (st.user.childMode && $('#pin')?.value) localStorage.setItem('child_mode_pin', $('#pin').value); } catch {} },
  async loadblocked() { st.blockedList = (await api('/user/blocked')).data.blocked; st.screen = 'main'; st.tab = 'blocked'; },
  async unblock(e) { await api('/user/blocked/' + e.dataset.id, { method: 'DELETE', body: {} }); st.blockedList = (await api('/user/blocked')).data.blocked; },
  suptype(e) { st.supType = e.dataset.k; },
  async supsend() { const r = await api('/support', { body: { requestType: st.supType || 'support', details: $('#supd').value } }); if (!r.ok) return toast(r.data.message); st.supSent = true; },
  async delacct() { await api('/user/account', { method: 'DELETE', body: {} }); await refresh(); st.tab = 'deleted'; },
  async setlang(e) { await api('/user/profile', { method: 'PUT', body: { language: e.dataset.k } }); await refresh(); st.sheet = null; },
  logoutsheet() { st.sheet = 'logout'; },
  widgetadd() { st.widgetAdded = true; st.sheet = null; toast('Widget added to your home screen'); },
  async signout() { await api('/notification/push-notification-token', { method: 'DELETE', body: {} }); st.token = ''; try { localStorage.removeItem('alrt_tok'); } catch {} Object.assign(st, { user: null, sheet: null, circles: [], sos: [], notes: [], circleId: null, access: null, places: [], tab: 'Main', screen: 'Splash', onb: { level: 'official', who: 'family', agreed: [] } }); },
};
async function auth(p, oauth) {
  const em = $('#em')?.value, pw = $('#pw')?.value;
  const r = await api(p, { body: oauth ? {} : { email: em, password: pw, name: em?.split('@')[0] } });
  if (!r.ok) return toast(r.data.message || 'Could not sign in');
  st.token = r.data.token; try { localStorage.setItem('alrt_tok', st.token); } catch {}
  st.sheet = null; await refresh();
  if (st.onb.level) await api('/user/push-notification-settings', { method: 'PUT', body: { level: st.onb.level } });
  await api('/onboarding/accept-disclaimer', { body: { ok: true } }); await api('/onboarding/accept-tos', { body: { ok: true } });
  if (st.primed) await api('/notification/push-notification-token', { body: { token: 'demo-token' } });
  if (st.wasOnboarding === false) { st.screen = 'main'; st.tab = 'Main'; } else { st.screen = 'onbdone'; }
}

// ---------- events
document.addEventListener('click', async (ev) => {
  const d = ev.target.closest('[data-dev]'); if (d) return dev(d.dataset.dev);
  const n = ev.target.closest('[data-nav]'); if (n && !ev.target.closest('[data-act]')) { ev.preventDefault(); go(n.dataset.nav); draw(); return; }
  const t = ev.target.closest('[data-act]'); if (!t) return;
  if (t.tagName === 'A') ev.preventDefault();
  const f = A[t.dataset.act]; if (!f) return;
  await f(t); draw();
});
let holdT, holdStart;
document.addEventListener('pointerdown', (e) => {
  const h = e.target.closest('#hold'); if (!h) return;
  holdStart = Date.now(); const fill = $('#holdfill'); fill.style.transition = `width ${R.timings.sosHoldMs}ms linear`; fill.style.width = '100%';
  holdT = setTimeout(async () => {
    const c = circ(); const o = st.sosOpt || { loc: 0, prec: 0 };
    const r = await api('/family/circles/' + c.circleId + '/sos', { body: { sosListId: o.list || undefined, heldMs: Date.now() - holdStart, location: ['none', 'once', 'live'][o.loc], precision: ['exact', 'suburb'][o.prec] } });
    st.sheet = null; if (!r.ok) refusal(r.data, 'circle'); else toast('SOS sent to ' + c.name);
    await refresh(); draw();
  }, R.timings.sosHoldMs);
});
const cancelHold = () => { clearTimeout(holdT); const f = $('#holdfill'); if (f) { f.style.transition = 'none'; f.style.width = '0'; } };
document.addEventListener('pointerup', cancelHold); document.addEventListener('pointercancel', cancelHold);

// ---------- dev panel beside the phone
async function dev(k) {
  if (k === 'reset') { await api('/__reset', { method: 'POST', body: {} }); try { localStorage.clear(); } catch {} Object.assign(st, { token: '', user: null, screen: 'Splash', tab: 'Main', circles: [], sos: [], notes: [], seenNotes: 0, places: [], circleId: null, sheet: null, plan: null, primed: false, drill: null, onb: { level: 'official', who: 'family', agreed: [] } }); }
  if (k.startsWith('advance')) { await api('/__advance', { body: { ms: { advance10: 10, advance50: 50, advance61: 61 }[k] * 60000 } }); await refresh(); }
  if (k === 'billing') { await api('/__billing', { body: { on: !(st.access?.billingEnabled) } }); await refresh(); }
  if (k === 'offline') st.offline = !st.offline;
  if (k === 'friend') { const c = circ(); if (!c) return toast('Create a group first'); const r = await api('/auth/email-password/register', { body: { email: 'friend' + Date.now() + '@example.com', password: 'x', name: 'Alex' } }); await api('/revenuecat/webhook', { body: { event: { type: 'INITIAL_PURCHASE', app_user_id: r.data.user.id, product_id: 'alrt_individual_monthly' } } }); const code = (await api('/family/circles')).data.find((x) => x.circleId === c.circleId)?.code; await fetch('/api/family/join', { method: 'POST', headers: { 'content-type': 'application/json', authorization: 'Bearer ' + r.data.token }, body: JSON.stringify({ code }) }); await loadFamily(); }
  if (k === 'confirm') { const h = st.hazards.find((x) => x.source === 'community' && x.authorId === st.user?.id) || st.hazards.find((x) => x.source === 'community'); if (h) { await api('/hazard/' + h.id + '/vote', { body: { vote: 'see' } }); await refresh(); } }
  if (k === 'push') st.lock = true;
  if (k === 'expire') { await api('/__expire-plan', { body: {} }); await loadFamily(); }
  if (k === 'billissue') { await api('/__billing-issue', { body: { userId: st.user.id } }); await refresh(); }
  if (k === 'igfooter') { st.igFooter = !st.igFooter; }
  if (k === 'forceupdate') { st.forceUpdate = !st.forceUpdate; st.tab = st.forceUpdate ? 'forceupdate' : 'Main'; }
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
boot();

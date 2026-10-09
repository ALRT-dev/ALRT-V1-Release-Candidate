// ALRT UI prototype: mock backend mirroring the real /api routes and rules.
// Zero dependencies. Run: node prototype/server.js   (PORT default 4173)
// Set ALRT_API=https://api-test.safetyalrt.com to proxy /api to the TEST API instead of the mock.
// Never point this at production. No secrets live here.
const http = require('http');
const fs = require('fs');
const path = require('path');
const R = require('./rules.json');

const PORT = process.env.PORT || 4173;
const PUB = path.join(__dirname, 'public');
let offset = 0; let c0; // virtual clock, advanced by tests only
const now = () => Date.now() + offset;
const T = R.timings;

const uid = (p) => p + Math.random().toString(36).slice(2, 9);
let S;
function seed() {
  offset = 0;
  S = {
    users: {}, tokens: {}, hazards: [], circles: [], sos: [], journeys: [], checkins: [],
    notifications: [], pushTokens: [], billingEnabled: true, webhookLog: [], sponsorships: [],
    asks: {}, places: {}, xp: {}, invites: [], locReqs: [], sosLists: [], famPlaces: [], sched: [], blocked: {}, flags: {}, support: [], reportTimes: {}, guides: ['Bushfire','Flood','Storm','Heatwave','Power outage'], checkinReqs: [], trips: [],
  };
  const t = now();
  const h = (title, source, band, cat, mins, lat, lng, extra = {}) => ({
    id: uid('h_'), title, source, band, category: cat, createdAt: t - mins * 60000, lat, lng,
    status: 'live', confirmations: 0, ...extra,
  });
  S.hazards.push(
    h('Bushfire near Wanneroo Rd, Neerabup', 'aws', 'critical', 'weather', 12, 8, 18, { board: 'Detail', level: 'Emergency Warning', agency: 'DFES', distance: '8.4 km away', locationName: 'Neerabup', plain: 'A fire is moving toward homes in these suburbs. This is the highest level. If you are in the area, act now.', know: 'Burning in bushland east of Wanneroo Rd, heading south-west. Ember attack likely in nearby suburbs.', todo: 'You are in danger and need to act immediately to survive. If you are not prepared to defend your property, leave now if the way is clear.' }),
    h('Bushfire Watch and Act, Toodyay', 'aws', 'action', 'weather', 50, 30, 70, { board: 'Ex1', level: 'Watch and Act', agency: 'DFES', distance: '68 km away', locationName: 'Toodyay', plain: 'A bushfire near Toodyay is getting worse. DFES says start acting now, before it becomes an emergency.', know: 'DFES has issued a Watch and Act for parts of Toodyay, east of the townsite.', todo: 'There is a possible threat to lives and homes. Leave now if the way is clear, or get ready to actively defend.' }),
    h('Lane closure on Mitchell Fwy northbound', 'official', 'monitor', 'traffic', 60, 20, 40, { agency: 'Main Roads WA', distance: '3.1 km away', locationName: 'Stirling', plain: 'One lane is closed. Expect delays on the freeway heading north.', know: 'Roadworks between Hutton St and Karrinyup Rd until 6 pm.', todo: 'Allow extra time or use Marmion Ave.' }),
    h('M1 closed both directions, Wyong', 'official', 'action', 'traffic', 35, 55, 30, { board: 'Ex2', agency: 'Transport for NSW', distance: '35 km away', locationName: 'Wyong NSW', plain: 'A serious crash has closed the motorway. Plan around it.', know: 'Transport for NSW reports the M1 is closed in both directions at Wyong after a multi-vehicle crash.', todo: 'Avoid the area and use the Pacific Highway instead.' }),
    h('Air quality: Very Poor, Perth Hills', 'official', 'monitor', 'health', 180, 70, 55, { board: 'Ex3', agency: 'WA air quality network', distance: '18 km away', locationName: 'Perth Hills', plain: 'The air outside is bad enough to affect anyone, not just people with health conditions.', know: 'The air in the Perth Hills is heavily affected by smoke this morning.', todo: 'Stay indoors and skip outdoor exercise while the smoke is this heavy.' }),
    h('Water over the road on Scarborough Beach Rd', 'community', 'info', 'weather', 25, 45, 80, { confirmations: 2, distance: '940 m', locationName: 'Scarborough', body: 'Water across both lanes near the roundabout.' }),
    h('Smoke may affect the northern suburbs tonight', 'intel', 'action', 'health', 120, 85, 10, { agency: 'ALRT Assessment · based on DFES and BoM', distance: 'sources inside', plain: 'Wind change this evening is likely to push smoke from the Neerabup fire over the northern suburbs.', know: 'DFES fire ground reports and BoM wind forecast for 7 pm.', todo: 'Close windows before evening. People with asthma may wish to keep medication close.' }),
    h('Official alert with urgent wording', 'official', 'info', 'community', 90, 30, 90, { agency: 'City of Stirling', distance: '2 km away', locationName: 'Scarborough', body: 'Urgent: road works, avoid the area.', plain: 'Sounds urgent but this is road works only. No danger to people.', know: 'Lane closures until Friday.', todo: 'Plan another route.' }),
    h('Flooding in a distant region', 'global', 'info', 'weather', 240, 85, 60, { agency: 'GDACS · verbatim', distance: 'international', body: 'Orange alert: river flooding affecting 40,000 people.' }),
  );
}
seed();

const json = (res, code, obj) => { res.writeHead(code, { 'content-type': 'application/json' }); res.end(JSON.stringify(obj)); };
const err = (res, code, errCode, message, extra = {}) => json(res, code, { error: { code: errCode, message }, code: errCode, message, ...extra });
const body = (req) => new Promise((ok) => { let d = ''; req.on('data', (c) => (d += c)); req.on('end', () => { try { ok(d ? JSON.parse(d) : {}); } catch { ok({}); } }); });

function plan(u) {
  const s = S.sponsorships.find((x) => x.sponsorUserId === u.id && x.live && x.funding === 'individual');
  if (u.plan === 'individual') {
    return { plan: 'individual', reason: u.trial ? 'trial' : 'subscription', isTrial: !!u.trial, expiresAt: u.expiresAt, willRenew: !u.cancelled, extraSavedPlaces: 0, askPerDay: R.plans.individual.askPerDay };
  }
  return { plan: 'free', reason: 'default', isTrial: false, expiresAt: null, willRenew: false, extraSavedPlaces: 0, askPerDay: R.plans.free.askPerDay };
}
function covered(c) { return S.sponsorships.some((x) => x.circleId === c.id && x.live && x.expiresAt > now()); }
function planEnded(c) { return S.sponsorships.some((x) => x.circleId === c.id && x.live && x.expiresAt <= now()); }
function circleView(c, u) {
  const sp = S.sponsorships.find((x) => x.circleId === c.id && x.live);
  const cap = sp ? R.plans[sp.tier].capacity : null;
  const personal = plan(u);
  const allowed = !S.billingEnabled || covered(c) || personal.plan === 'individual';
  const reasonCode = allowed ? (covered(c) ? 'group_covered' : 'individual') : planEnded(c) ? 'GROUP_PLAN_ENDED' : 'INDIVIDUAL_REQUIRED';
  return {
    circleId: c.id, name: c.name, role: c.ownerId === u.id ? 'owner' : 'member', fundingMode: sp ? sp.funding : 'none',
    peopleCount: c.members.length, capacity: cap, code: c.code, ownerId: c.ownerId, settings: c.settings || { anyoneCanRequestSnapshot: true, journeysSnapPointsOnly: true, themeColor: '#3D3DDF' }, hostTransition: c.hostTransition || null,
    photoUrl: c.photoUrl || null,
    members: c.members.map((id) => ({ id, name: S.users[id]?.name, photo: S.users[id]?.photo || null, role: c.ownerId === id ? 'owner' : 'adult', ...member(c, id), snapshot: member(c, id).snapshot && member(c, id).snapshot.expiresAt > now() ? member(c, id).snapshot : null })),
    sponsorship: sp ? { tier: sp.tier, live: true, status: 'active', expiresAt: sp.expiresAt, coveredBy: sp.sponsorUserId === u.id ? 'you' : 'sponsor', youPay: sp.sponsorUserId === u.id } : { tier: null, live: false, status: 'none', expiresAt: null, coveredBy: null, youPay: false },
    connectionAccess: { allowed, reason: reasonCode },
  };
}
function gateCircle(res, c, u) {
  const v = circleView(c, u);
  if (!v.connectionAccess.allowed) {
    if (planEnded(c) && plan(u).plan !== 'individual') err(res, 402, 'GROUP_PLAN_ENDED', 'This group\'s plan has ended. Renew it, or use your own ALRT +.', { circleId: c.id });
    else err(res, 402, 'INDIVIDUAL_REQUIRED', 'Check in, Check on, SOS and Journey in this group need ALRT + for each person, or a plan covering the group.', { circleId: c.id });
    return false;
  }
  return true;
}
function push(u, title, bodyText, kind, extra = {}) {
  const n = { id: uid('n_'), userId: u.id, title, body: bodyText, kind, createdAt: now(), ...extra };
  S.notifications.push(n);
  return n;
}
const member = (c, uid) => (c.memberMeta ||= {})[uid] ||= { sharingLevel: 'approximate', nickname: null, colorHex: '#E8622A', lastCheckInAt: null, snapshot: null };
const award = (u, pts, why) => { S.xp[u.id] = (S.xp[u.id] || 0) + pts; (S.xpLog ||= []).push({ userId: u.id, pts, why }); };
const hazardView = (h) => { const { authorId, ...rest } = h; return { ...rest, authorId, minutesAgo: Math.round((now() - h.createdAt) / 60000), authorPhoto: null, authorName: null }; };

function sosView(s) {
  const ends = s.createdAt + T.sosDurationMs + s.extendedMs;
  return { ...s, serverNow: now(), endsAt: ends, endingSoon: now() >= ends - T.sosEndingSoonLeadMs && now() < ends, active: s.status === 'active' && now() < ends, expired: s.status === 'active' && now() >= ends };
}

async function api(req, res, url) {
  const p = url.pathname.replace(/^\/api/, '');
  const m = req.method;
  const b = ['POST', 'PUT', 'PATCH', 'DELETE'].includes(m) ? await body(req) : {};
  const tok = (req.headers.authorization || '').replace('Bearer ', '');
  const u = S.tokens[tok] ? S.users[S.tokens[tok]] : null;
  const need = () => { if (!u) { err(res, 401, 'UNAUTHORIZED', 'Sign in to continue'); return false; } return true; };

  if (p === '/app/version-policy') return json(res, 200, { minVersion: '1.0.0', latest: '1.0.0', force: false });

  // ---- auth
  if (p === '/auth/email-password/register' && m === 'POST') {
    if (!b.email || !b.password) return err(res, 400, 'BAD_REQUEST', 'Email and password required');
    if (Object.values(S.users).some((x) => x.email === b.email)) return err(res, 409, 'EXISTS', 'Account exists');
    const nu = { id: uid('u_'), email: b.email, name: b.name || b.email.split('@')[0], plan: 'free', onboarding: {}, settings: { level: 'official' } };
    S.users[nu.id] = nu; const t = uid('tok_'); S.tokens[t] = nu.id; award(nu, R.points.firstSetup, 'first setup');
    return json(res, 201, { token: t, user: nu });
  }
  if (p === '/auth/email-password/login' && m === 'POST') {
    const x = Object.values(S.users).find((z) => z.email === b.email);
    if (!x) return err(res, 401, 'BAD_CREDENTIALS', 'Wrong email or password');
    const t = uid('tok_'); S.tokens[t] = x.id; return json(res, 200, { token: t, user: x });
  }
  if (p === '/auth/password-reset/request' && m === 'POST') return json(res, 200, { message: 'If that email exists, a reset link is on its way.' });
  if (p.startsWith('/auth/oauth/')) {
    const email = `${p.split('/').pop()}.demo@example.com`;
    let x = Object.values(S.users).find((z) => z.email === email);
    if (!x) { x = { id: uid('u_'), email, name: p.endsWith('apple') ? 'Sarah' : 'Sarah', plan: 'free', onboarding: {}, settings: { level: 'official' } }; S.users[x.id] = x; award(x, R.points.firstSetup, 'first setup'); }
    const t = uid('tok_'); S.tokens[t] = x.id; return json(res, 200, { token: t, user: x });
  }

  // ---- revenuecat webhook (billing only)
  if (p === '/revenuecat/webhook' && m === 'POST') {
    const ev = b.event || {};
    S.webhookLog.push(ev);
    const target = Object.values(S.users).find((x) => x.id === ev.app_user_id);
    if (!target) return json(res, 200, { ok: true, ignored: true });
    const prod = ev.product_id || '';
    if (['INITIAL_PURCHASE', 'RENEWAL', 'NON_RENEWING_PURCHASE'].includes(ev.type)) {
      if (prod.includes('family') || prod.includes('group')) { const tier = prod.includes('family') ? 'family' : prod.includes('group50') ? 'group50' : 'group20'; const si = S.sponsorships.find((x) => x.sponsorUserId === target.id && x.tier === tier && !x.live && !x.purchased) || (S.sponsorships.push({ id: uid('si_'), sponsorUserId: target.id, tier, funding: 'group', live: false, circleId: null }), S.sponsorships[S.sponsorships.length - 1]); si.purchased = true; si.expiresAt = now() + 30 * 86400000; target.billingIssue = false; }
      if (prod.startsWith('individual') || prod.includes('individual')) { target.trialUsed = true; target.billingIssue = false; target.plan = 'individual'; target.trial = !!ev.is_trial_period; target.expiresAt = now() + (ev.is_trial_period ? R.plans.individual.trialDays * 86400000 : 30 * 86400000); target.cancelled = false; }
    }
    if (['EXPIRATION'].includes(ev.type)) { target.plan = 'free'; target.trial = false; }
    if (ev.type === 'CANCELLATION') target.cancelled = true;
    if (ev.type === 'BILLING_ISSUE') target.billingIssue = true;
    return json(res, 200, { ok: true });
  }

  if (p === '/__billing' && m === 'POST') { S.billingEnabled = !!b.on; return json(res, 200, { billingEnabled: S.billingEnabled }); }
  if (p === '/__advance' && m === 'POST') { offset += Number(b.ms) || 0; return json(res, 200, { offset }); }
  if (p === '/__expire-plan' && m === 'POST') { S.sponsorships.filter((x) => x.live).forEach((x) => (x.expiresAt = now() - 1)); return json(res, 200, { ok: true }); }
  if (p === '/__billing-issue' && m === 'POST') { const x = Object.values(S.users).find((z) => z.id === b.userId); if (x) x.billingIssue = true; return json(res, 200, { ok: true }); }
  if (p === '/__reset' && m === 'POST') { seed(); return json(res, 200, { ok: true }); }
  if (p === '/__friend-token' && m === 'GET') { const f = Object.values(S.users).find((x) => x.name === 'Alex'); const t = uid('tok_'); if (f) S.tokens[t] = f.id; return json(res, 200, { token: f ? t : null, id: f?.id }); }
  if (p === '/__state' && m === 'GET') return json(res, 200, { users: Object.keys(S.users).length, notifications: S.notifications.length, webhookLog: S.webhookLog, xp: S.xp, offset });

  if (!need()) return;

  // ---- access
  if (p === '/access' && m === 'GET') {
    const mine = S.circles.filter((c) => c.members.includes(u.id));
    return json(res, 200, { billingEnabled: S.billingEnabled, trialEligible: !u.trialUsed, personal: plan(u), groups: mine.map((c) => circleView(c, u)), unboundSponsorships: S.sponsorships.filter((x) => x.sponsorUserId === u.id && x.purchased && !x.live).map((x) => ({ id: x.id, tier: x.tier, expiresAt: x.expiresAt })), billingIssue: !!u.billingIssue, computedAt: new Date(now()).toISOString(), serverNow: now() });
  }
  if (p === '/access/reconcile' && m === 'POST') return json(res, 200, { store: { checked: false, confirmedChanges: 0, unrecorded: [], products: [] } });
  if (p === '/access/sponsorship-intents' && m === 'POST') {
    const tc = S.circles.find((x) => x.id === b.circleId);
    if (tc && tc.ownerId !== u.id) return err(res, 403, 'HOST_ONLY', 'Only the host can cover this group');
    if (tc && tc.members.length > R.plans[b.tier].capacity) return err(res, 409, 'PLAN_TOO_SMALL', 'That plan is smaller than this group', { peopleCount: tc.members.length });
    const cur = tc && S.sponsorships.find((x) => x.circleId === tc.id && x.live);
    if (cur && cur.sponsorUserId === u.id && ['family', 'group20', 'group50'].indexOf(b.tier) < ['family', 'group20', 'group50'].indexOf(cur.tier)) return err(res, 409, 'CHANGE_IN_STORE', 'Downgrade this plan in your app store');
    if (cur && cur.sponsorUserId !== u.id) return err(res, 409, 'GROUP_ALREADY_COVERED', 'Someone else already covers this group');
    const si = { id: uid('si_'), sponsorUserId: u.id, tier: b.tier, funding: 'group', live: false, circleId: null };
    S.sponsorships.push(si); return json(res, 201, si);
  }
  const bind = p.match(/^\/access\/sponsorships\/([^/]+)\/bind$/);
  if (bind && m === 'POST') {
    const si = S.sponsorships.find((x) => x.id === bind[1]); const c = S.circles.find((x) => x.id === b.circleId);
    if (!si || !c) return err(res, 404, 'NOT_FOUND', 'Not found');
    if (si.sponsorUserId !== u.id) return err(res, 403, 'PAYER_ONLY', 'Only the payer can choose the group');
    if (c.ownerId !== u.id) return err(res, 403, 'HOST_ONLY', 'Only the host can cover this group');
    const ex = S.sponsorships.find((x) => x.circleId === c.id && x.live && x.id !== si.id);
    if (ex && !b.replaceExisting) return err(res, 409, 'GROUP_ALREADY_COVERED', 'This group already has a plan', { replaceable: ex.sponsorUserId === u.id });
    if (ex) ex.live = false;
    if (c.members.length > R.plans[si.tier].capacity) return err(res, 409, 'GROUP_FULL', 'That plan is smaller than this group');
    si.circleId = c.id; si.live = true; si.expiresAt = si.expiresAt || now() + 30 * 86400000; return json(res, 200, { id: si.id, boundCircleId: c.id, tier: si.tier, replaced: ex ? { id: ex.id, tier: ex.tier } : null });
  }
  const ind = p.match(/^\/access\/groups\/([^/]+)\/individual-funding$/);
  if (ind && m === 'POST') {
    const c = S.circles.find((x) => x.id === ind[1]);
    if (!c) return err(res, 404, 'NOT_FOUND', 'Not found');
    if (plan(u).plan !== 'individual') return err(res, 402, 'INDIVIDUAL_REQUIRED', 'ALRT + needed');
    if (c.members.length > 20) return err(res, 409, 'GROUP_FULL', 'Individually funded groups are capped at 20 people');
    return json(res, 200, { ok: true });
  }

  // ---- onboarding & user
  if (p.startsWith('/onboarding/')) { u.onboarding[p.split('/').pop()] = b; return json(res, 200, { ok: true }); }
  if (p === '/user/profile' && m === 'GET') return json(res, 200, { ...u, points: S.xp[u.id] || 0, isScheduledForDeletion: !!u.scheduledDeletionAt, daysUntilDeletion: u.scheduledDeletionAt ? Math.ceil((u.scheduledDeletionAt - now()) / 86400000) : null });
  if (p === '/user/push-notification-settings') {
    const lv = (l) => R.notifications.levels.find((x) => x.id === l).fields;
    u.settings.fields ||= { ...lv(u.settings.level), subscribedCategoryIds: Object.keys(R.categories) };
    if (m === 'PUT' || m === 'PATCH' || m === 'POST') {
      if (b.level) { u.settings.level = b.level; u.settings.fields = { ...lv(b.level), subscribedCategoryIds: u.settings.fields.subscribedCategoryIds }; }
      else { u.settings.fields = { ...u.settings.fields, ...b }; const f = u.settings.fields; u.settings.level = f.userReported ? 'all' : (f.awsWatchAndAct || f.awsAdvice || f.officialNonAws) ? 'official' : 'quiet'; }
      return json(res, 200, { level: u.settings.level, ...u.settings.fields });
    }
    return json(res, 200, { level: u.settings.level, ...u.settings.fields });
  }
  if (p === '/notification/push-notification-token') { S.pushTokens.push({ userId: u.id, token: b.token }); return json(res, 200, { ok: true }); }
  if (p === '/user/location-subscriptions' && m === 'GET') return json(res, 200, S.places[u.id] || []);
  if (p === '/user/subscribe-location' && m === 'POST') {
    const list = (S.places[u.id] ||= []);
    const limit = plan(u).plan === 'individual' || !S.billingEnabled ? Infinity : R.plans.free.savedPlaces;
    if (list.length >= limit) return err(res, 402, 'SAVED_PLACE_LIMIT', 'Free includes 1 saved place. ALRT + has no limit.', { limit: R.plans.free.savedPlaces });
    const pl = { id: uid('pl_'), name: b.name || 'Saved place', radiusKm: b.radiusKm || 10 }; list.push(pl); award(u, 0, 'place'); return json(res, 201, pl);
  }
  if (p === '/user/unsubscribe' && m === 'POST') { S.places[u.id] = (S.places[u.id] || []).filter((x) => x.id !== b.id); return json(res, 200, { ok: true }); }

  // ---- alerts
  if (p === '/alert/geo' || p === '/hazard') {
    if (m === 'GET') return json(res, 200, S.hazards.filter((h) => h.status === 'live' && (h.source !== 'community' || h.confirmations >= 1 || h.authorId === u.id)).map(hazardView));
    if (m === 'POST') {
      if (!b.category) return err(res, 400, 'BAD_REQUEST', 'Choose a category');
      const times = (S.reportTimes[u.id] ||= []).filter((t0) => t0 > now() - 86400000); S.reportTimes[u.id] = times;
      if (times.filter((t0) => t0 > now() - 3600000).length >= 3) return err(res, 429, 'RATE_LIMIT', 'You can post 3 reports an hour and 10 a day. Try again later.');
      if (times.length >= 10) return err(res, 429, 'RATE_LIMIT', 'You can post 3 reports an hour and 10 a day. Try again later.');
      const dup = S.hazards.find((x) => x.source === 'community' && x.category === b.category && x.status === 'live' && Math.hypot((x.lat || 0) - (b.lat || 0), (x.lng || 0) - (b.lng || 0)) < 0.005 && !b.force);
      if (dup) return err(res, 409, 'DUPLICATE', 'A similar report is already live nearby', { existingHazardId: dup.id, existingTitle: dup.title, existingCategoryName: R.categories[dup.category].name, canConfirm: dup.authorId !== u.id });
      times.push(now());
      const h = { id: uid('h_'), title: b.title || b.category, source: 'community', band: 'info', category: b.category, createdAt: now(), lat: b.lat || 0, lng: b.lng || 0, status: 'live', confirmations: 0, authorId: u.id, body: b.body || '', severity: b.severity || 'minor', anonymous: true };
      S.hazards.push(h); award(u, R.points.reportApproved, 'report');
      // Sarah's ruling: push after the first neighbour confirms; a Dangerous report pushes at once to people within 2 km.
      if (h.severity === 'dangerous') Object.values(S.users).forEach((x) => { if (x.settings.level === 'all' && x.id !== u.id) push(x, 'Community report | ' + h.title, (h.body || 'Risk to people reported nearby.') + ' Unverified.', 'community', { hazardId: h.id, within2km: true }); });
      push(u, 'ALRT Approved! \u{1F389}', 'Your alert is now live - community notified', 'approved', { hazardId: h.id });
      return json(res, 201, hazardView(h));
    }
  }
  if (p === '/hazard/mine') return json(res, 200, S.hazards.filter((h) => h.authorId === u.id).map((h) => ({ ...hazardView(h), reviewStatus: h.reviewStatus || 'accepted' })));
  const flag = p.match(/^\/hazard\/([^/]+)\/flag$/);
  if (flag && m === 'POST') {
    const h = S.hazards.find((x) => x.id === flag[1]); if (!h) return err(res, 404, 'NOT_FOUND', 'Not found');
    if (h.source !== 'community') return err(res, 400, 'BAD_REQUEST', 'Official alerts cannot be reported');
    if (h.authorId === u.id) return err(res, 400, 'BAD_REQUEST', 'You cannot report your own alert');
    const f = (S.flags[h.id] ||= new Set()); f.add(u.id); const sent = f.size >= 3; if (sent) { h.status = 'pending'; h.reviewStatus = 'pending'; }
    return json(res, 200, { flagged: true, flagCount: f.size, sentForReview: sent });
  }
  const view = p.match(/^\/hazard\/([^/]+)\/view$/);
  if (view && m === 'POST') { const h = S.hazards.find((x) => x.id === view[1]); if (h) h.views = (h.views || 0) + 1; return json(res, 200, { message: 'ok', isViewRecorded: !!h }); }
  if (p === '/hazard-categories/parent') return json(res, 200, Object.entries(R.categories).map(([k, v]) => ({ id: k, name: v.name, color: v.color })));
  if (p === '/user/blocked' && m === 'GET') return json(res, 200, { blocked: Object.keys(S.blocked[u.id] || {}).map((id) => ({ userId: id, name: 'Community member', blockedAt: S.blocked[u.id][id] })) });
  if (p === '/user/blocked' && m === 'POST') { const h = b.hazardId && S.hazards.find((x) => x.id === b.hazardId); const target = b.userId || (h && h.authorId); if (!target) return err(res, 404, 'NOT_FOUND', 'Nothing to block'); if (target === u.id) return err(res, 400, 'BAD_REQUEST', 'You cannot block yourself'); (S.blocked[u.id] ||= {})[target] = now(); return json(res, 200, { blocked: true }); }
  const unb = p.match(/^\/user\/blocked\/([^/]+)$/);
  if (unb && m === 'DELETE') { delete (S.blocked[u.id] || {})[unb[1]]; return json(res, 200, { blocked: false }); }
  if (p === '/support' && m === 'POST') { if (!b.details) return err(res, 400, 'BAD_REQUEST', 'Tell us what happened'); S.support.push({ userId: u.id, ...b, at: now() }); return json(res, 200, { message: 'Request submitted' }); }
  if (p === '/user/account' && m === 'DELETE') { u.scheduledDeletionAt = now() + 30 * 86400000; return json(res, 200, { message: 'scheduled', scheduledDeletionAt: u.scheduledDeletionAt }); }
  if (p === '/user/account/cancel-deletion' && m === 'POST') { if (!u.scheduledDeletionAt) return err(res, 400, 'BAD_REQUEST', 'Nothing scheduled'); u.scheduledDeletionAt = null; return json(res, 200, { message: 'Your account has been recovered' }); }
  if (p === '/user/account/deletion-status') return json(res, 200, { isScheduledForDeletion: !!u.scheduledDeletionAt, scheduledDeletionAt: u.scheduledDeletionAt || null, daysRemaining: u.scheduledDeletionAt ? Math.ceil((u.scheduledDeletionAt - now()) / 86400000) : null });
  if (p === '/user/profile-picture' && m === 'PUT') { if (b.dataUrl && !/^data:image\//.test(b.dataUrl)) return err(res, 400, 'BAD_REQUEST', 'Not an image'); u.photo = b.dataUrl || u.photo || null; if (b.name) u.name = b.name; return json(res, 200, { ...u, photoVisibility: 'group members only' }); }
  if (p === '/user/profile-picture' && m === 'DELETE') { u.photo = null; return json(res, 200, { ok: true }); }
  if (p === '/family/circle/photo' && (m === 'PUT' || m === 'DELETE')) { const c = S.circles.find((x) => (b.circleId ? x.id === b.circleId : true) && x.members.includes(u.id)); if (!c) return err(res, 404, 'NOT_FOUND', 'No group'); if (c.ownerId !== u.id) return err(res, 403, 'HOST_ONLY', 'Only the host can change the group photo'); c.photoUrl = m === 'DELETE' ? null : (b.dataUrl || null); return json(res, 200, circleView(c, u)); }
  if (p === '/user/profile' && (m === 'PUT' || m === 'PATCH')) { if (b.name) u.name = b.name; if (b.language) u.language = b.language; if (b.childMode !== undefined) u.childMode = !!b.childMode; return json(res, 200, u); }
  if (p === '/xpPoints/breakdown' || p === '/xp/breakdown') { const log = (S.xpLog || []).filter((x) => x.userId === u.id); const by = {}; log.forEach((x) => (by[x.why] = (by[x.why] || 0) + x.pts)); return json(res, 200, { currentXpPoints: S.xp[u.id] || 0, byType: Object.entries(by).map(([type, points]) => ({ type, points })), rank: 1, totalUsers: Object.keys(S.users).length }); }
  if (p === '/xpPoints/badges' || p === '/xp/badges') return json(res, 200, { badges: [{ id: 'accurate_5', name: 'Reliable reporter', earned: false, threshold: 5 }, { id: 'corroborated_25', name: 'Neighbourhood eyes', earned: false, threshold: 25 }] });
  if (p === '/guide/topics') return json(res, 200, { topics: S.guides.map((g) => ({ slug: g, title: g, completed: !!(u.guides || {})[g], xpReward: R.points.guideComplete })), completedCount: Object.keys(u.guides || {}).length, totalCount: S.guides.length });
  if (p === '/notification/push-notification-token' && m === 'DELETE') { S.pushTokens = S.pushTokens.filter((x) => x.userId !== u.id); return json(res, 200, { removed: true }); }
  const vote = p.match(/^\/hazard\/([^/]+)\/vote$/);
  if (vote && m === 'POST') {
    const h = S.hazards.find((x) => x.id === vote[1]); if (!h) return err(res, 404, 'NOT_FOUND', 'Not found');
    if (b.vote === 'see') {
      h.confirmations += 1;
      if (h.authorId) award({ id: h.authorId }, R.points.confirmedByNeighbour, 'confirmed');
      // confirmations earn the confirmer nothing
      if (h.source === 'community' && h.confirmations === 1 && h.severity !== 'dangerous') Object.values(S.users).forEach((x) => { if (x.settings.level === 'all' && x.id !== h.authorId) push(x, 'Community report | ' + h.title, (h.body || 'Reported nearby.') + ' Confirmed by a neighbour. Unverified.', 'community', { hazardId: h.id }); });
    } else h.confirmations = Math.max(0, h.confirmations - 1);
    return json(res, 200, hazardView(h));
  }

  // ---- ask alrt
  if (p === '/ask-alrt/allowance') {
    const used = S.asks[u.id] || 0; const lim = plan(u).askPerDay; return json(res, 200, { used, limit: lim, remaining: Math.max(0, lim - used) });
  }
  if (p === '/ask-alrt' && m === 'POST') {
    const used = S.asks[u.id] || 0; const lim = plan(u).askPerDay;
    const q = (b.question || '').toLowerCase();
    if (/emergency number|call .*police|ambulance|fire brigade|000|triple zero/.test(q)) return json(res, 200, { answer: 'In danger? Call your local emergency number. ALRT never contacts emergency services for you.', source: 'emergency_lookup', usedAI: false, remainingToday: Math.max(0, lim - used) });
    if (/what is (an? )?(emergency warning|watch and act|advice)|what does unverified mean|how do points work/.test(q)) return json(res, 200, { answer: 'Emergency Warning is the highest AWS level: you are in danger and need to act immediately. Watch and Act: conditions are changing, start taking action. Advice: an incident has started, stay informed. Community reports are always Unverified.', source: 'library', usedAI: false, remainingToday: Math.max(0, lim - used) });
    if (S.billingEnabled && used >= lim) return err(res, 429, 'ask_limit', `Free includes ${R.plans.free.askPerDay} questions a day. ALRT + includes ${R.plans.individual.askPerDay}.`, { used, limit: lim });
    S.asks[u.id] = used + 1;
    return json(res, 200, { answer: `Plain terms: ${(b.question || '').slice(0, 60)}. Based on official sources near you. ALRT is not an emergency service. In danger? Call your local emergency number.`, source: 'ai', usedAI: true, remaining: Math.max(0, lim - used - 1), remainingToday: Math.max(0, lim - used - 1) });
  }

  const gc = p.match(/^\/guide\/([^/]+)\/complete$/);
  if (gc && m === 'POST') { u.guides = u.guides || {}; if (!u.guides[gc[1]]) { u.guides[gc[1]] = 1; award(u, R.points.guideComplete, 'guide'); } return json(res, 200, { ok: true });}
  // ---- maps: routes and trips (Sarah 9 Oct: alerts pop up en route while travelling). Real app proxies Google Routes through /api/maps; the mock scores each option by the hazards it crosses.
  if (p === '/maps/routes' && m === 'POST') {
    const hz = S.hazards.filter((h) => h.status === 'live');
    const sev = hz.filter((h) => ['critical', 'action'].includes(h.band) && h.source !== 'community'); const com = hz.filter((h) => h.source === 'community');
    const options = [
      { id: 'r1', mins: 24, km: 18.2, via: 'Mitchell Fwy', hazardIds: sev.slice(0, 2).map((h) => h.id), path: 'M30 160 C 90 150, 140 110, 200 90 S 300 40, 330 30' },
      { id: 'r2', mins: 31, km: 21.5, via: 'Marmion Ave', hazardIds: com.slice(0, 1).map((h) => h.id), path: 'M30 160 C 60 120, 90 70, 170 60 S 300 60, 330 30' },
      { id: 'r3', mins: 38, km: 24.9, via: 'Wanneroo Rd', hazardIds: [], path: 'M30 160 C 100 170, 200 170, 260 120 S 320 60, 330 30' },
    ].map((o) => ({ ...o, hazards: o.hazardIds.map((id) => hazardView(hz.find((h) => h.id === id))) }));
    return json(res, 200, { from: b.from || 'Your location', to: b.to || 'Perth CBD', mode: b.mode || 'Drive', options });
  }
  if (p === '/maps/trips' && m === 'POST') {
    S.trips.filter((t) => t.userId === u.id && t.status === 'active').forEach((t) => { t.status = 'ended'; });
    const t = { id: uid('trip_'), userId: u.id, to: b.to || 'Perth CBD', mode: b.mode || 'Drive', option: b.option || { id: 'r1', via: 'Mitchell Fwy', mins: 24, km: 18.2, hazardIds: [] }, startedAt: now(), status: 'active', shown: [], dismissed: [] };
    S.trips.push(t); return json(res, 200, t);
  }
  const tp = p.match(/^\/maps\/trips\/([^/]+)(?:\/(ahead|avoid|dismiss))?$/);
  if (tp) {
    const t = S.trips.find((x) => x.id === tp[1] && x.userId === u.id); if (!t) return err(res, 404, 'NOT_FOUND', 'No trip');
    if (m === 'DELETE') { t.status = 'ended'; t.endedAt = now(); return json(res, 200, t); }
    if (tp[2] === 'ahead') {
      // the next alert the route crosses that the traveller has not dealt with; Emergency Warnings always pop, other bands follow the notification level
      if (t.status !== 'active') return json(res, 200, { hazard: null });
      const age = now() - t.startedAt; if (age < 2000 && !t.forced) return json(res, 200, { hazard: null, trip: t });
      const ids = (t.option.hazardIds || []).filter((id) => !t.dismissed.includes(id));
      const h = ids.map((id) => S.hazards.find((x) => x.id === id)).filter(Boolean)[0];
      if (!h) return json(res, 200, { hazard: null, trip: t });
      const km = +(Math.max(0.4, 6.2 - age / 10000)).toFixed(1);
      if (!t.shown.includes(h.id)) { t.shown.push(h.id); push(u, 'Ahead on your route: ' + h.title, `${km} km ahead on ${t.option.via}. Tap to see it and choose another way.`, 'enroute', { hazardId: h.id, tripId: t.id }); }
      return json(res, 200, { hazard: hazardView(h), distanceKm: km, trip: t });
    }
    if (tp[2] === 'dismiss' && m === 'POST') { if (b.hazardId && !t.dismissed.includes(b.hazardId)) t.dismissed.push(b.hazardId); return json(res, 200, t); }
    if (tp[2] === 'avoid' && m === 'POST') {
      // reroute: the option that avoids this alert; the mock swaps to the clearest alternative
      if (b.hazardId && !t.dismissed.includes(b.hazardId)) t.dismissed.push(b.hazardId);
      const alts = [{ id: 'r3', via: 'Wanneroo Rd', mins: 38, km: 24.9, hazardIds: [] }, { id: 'r2', via: 'Marmion Ave', mins: 31, km: 21.5, hazardIds: [] }];
      t.option = alts.find((o) => o.id !== t.option.id) || alts[0]; t.rerouted = (t.rerouted || 0) + 1; t.startedAt = now();
      return json(res, 200, t);
    }
    return json(res, 200, t);
  }
  if (p === '/__hazard-ahead' && m === 'POST') { const t = S.trips.find((x) => x.userId === u.id && x.status === 'active'); if (!t) return json(res, 200, { ok: false }); const h = S.hazards.find((x) => x.source === 'aws' && x.band === 'critical') || S.hazards[0]; if (!t.option.hazardIds.includes(h.id)) t.option.hazardIds.unshift(h.id); t.dismissed = t.dismissed.filter((id) => id !== h.id); t.shown = t.shown.filter((id) => id !== h.id); t.forced = true; return json(res, 200, { ok: true, hazardId: h.id }); }
  // ---- notifications / points
  if (p === '/notification/feed') return json(res, 200, S.notifications.filter((n) => n.userId === u.id).sort((a, b2) => b2.createdAt - a.createdAt));
  if (p === '/notification/test' && m === 'POST') return json(res, 200, push(u, 'Test', 'Test notification', 'test'));
  if (p === '/xp/summary' || p === '/xpPoints/summary') { const pts = S.xp[u.id] || 0; const lv = [...R.points.levels].reverse().find((l) => pts >= l[1]); return json(res, 200, { points: pts, level: lv[0], streak: null }); }
  if (p.endsWith('/leaderboard')) return json(res, 200, Object.keys(S.xp).map((k, i) => ({ rank: i + 1, points: S.xp[k] })).sort((a, b2) => b2.points - a.points)); // never identities

  // ---- family
  if (p === '/family/circles' && m === 'GET') return json(res, 200, S.circles.filter((c) => c.members.includes(u.id)).map((c) => circleView(c, u)));
  if (p === '/family/circles' && m === 'POST') {
    const c = { id: uid('c_'), name: b.name || 'My group', ownerId: u.id, members: [u.id], code: Math.random().toString(36).slice(2, 8).toUpperCase() };
    S.circles.push(c); return json(res, 201, circleView(c, u));
  }
  if (p === '/family/join' && m === 'POST') {
    const c = S.circles.find((x) => x.code === b.code); if (!c) return err(res, 404, 'NOT_FOUND', 'Invite not found');
    const sp = S.sponsorships.find((x) => x.circleId === c.id && x.live);
    if (sp && c.members.length >= R.plans[sp.tier].capacity) return err(res, 409, 'GROUP_FULL', 'This group is full');
    if (!c.members.includes(u.id)) c.members.push(u.id);
    return json(res, 200, circleView(c, u)); // joining is free
  }

  // ---- family extras
  const myCircle = (cid) => S.circles.find((x) => (cid ? x.id === cid : true) && x.members.includes(u.id));
  const cidQ = url.searchParams.get('circleId') || b.circleId;
  if (p === '/family/invites' && m === 'POST') { const c = myCircle(cidQ); if (!c) return err(res, 404, 'NOT_FOUND', 'No group'); if (c.ownerId !== u.id) return err(res, 403, 'HOST_ONLY', 'Only the host can invite'); if (c.hostTransition) return err(res, 403, 'HOST_TRANSITION', 'Choose a new host first'); const inv = { id: uid('inv_'), circleId: c.id, code: 'ALRT-' + Math.random().toString(36).slice(2, 7).toUpperCase(), maxUses: 20, useCount: 0, expiresAt: now() + 7 * 86400000, isRevoked: false }; S.invites.push(inv); c.code = inv.code; return json(res, 201, inv); }
  if (p === '/family/invites' && m === 'GET') { const c = myCircle(cidQ); return json(res, 200, S.invites.filter((i) => c && i.circleId === c.id && !i.isRevoked && i.expiresAt > now())); }
  const rev = p.match(/^\/family\/invites\/([^/]+)\/revoke$/);
  if (rev && m === 'POST') { const inv = S.invites.find((i) => i.id === rev[1]); if (!inv) return err(res, 404, 'NOT_FOUND', 'Not found'); const c = S.circles.find((x) => x.id === inv.circleId); if (c.ownerId !== u.id) return err(res, 403, 'HOST_ONLY', 'Only the host can revoke'); inv.isRevoked = true; return json(res, 200, inv); }
  if (p === '/family/circle' && m === 'PUT') { const c = myCircle(cidQ); if (!c) return err(res, 404, 'NOT_FOUND', 'No group'); if (c.ownerId !== u.id) return err(res, 403, 'HOST_ONLY', 'Only the host can change these'); c.settings = { ...(c.settings || { anyoneCanRequestSnapshot: true, journeysSnapPointsOnly: true, themeColor: '#3D3DDF' }), ...b }; if (b.name) c.name = b.name; return json(res, 200, circleView(c, u)); }
  if (p === '/family/circle' && m === 'DELETE') { const c = myCircle(cidQ); if (!c) return err(res, 404, 'NOT_FOUND', 'No group'); if (c.ownerId !== u.id) return err(res, 403, 'HOST_ONLY', 'Only the host can close the group'); S.circles = S.circles.filter((x) => x !== c); return json(res, 200, { success: true }); }
  if (p === '/family/circle/leave' && m === 'POST') { const c = myCircle(cidQ); if (!c) return err(res, 404, 'NOT_FOUND', 'No group'); c.members = c.members.filter((id) => id !== u.id); S.sos.filter((x) => x.userId === u.id && x.circleId === c.id).forEach((x) => (x.status = 'resolved')); let outcome = 'left'; if (!c.members.length) { S.circles = S.circles.filter((x) => x !== c); outcome = 'deleted'; } else if (c.ownerId === u.id) { c.hostTransition = { startedAt: now(), hostName: u.name, daysLeft: 7 }; outcome = 'hostTransition'; c.members.forEach((id) => push(S.users[id], 'Family circle update', 'Your host left. Choose a new host within 7 days.', 'circleUpdate', { circleId: c.id })); } return json(res, 200, { success: true, outcome, circleId: c.id }); }
  if (p === '/family/circle/transfer-candidates') { const c = myCircle(cidQ); if (!c || c.ownerId !== u.id) return err(res, 403, 'HOST_ONLY', 'Host only'); return json(res, 200, { circleId: c.id, candidates: c.members.filter((id) => id !== u.id).map((id) => ({ memberId: id, name: S.users[id].name, eligible: true })) }); }
  if (p === '/family/circle/transfer-ownership' && m === 'POST') { const c = myCircle(cidQ); if (!c || c.ownerId !== u.id) return err(res, 403, 'HOST_ONLY', 'Host only'); if (!c.members.includes(b.newOwnerMemberId)) return err(res, 404, 'NOT_FOUND', 'Not a member'); c.ownerId = b.newOwnerMemberId; c.hostTransition = null; c.members.forEach((id) => push(S.users[id], c.name, S.users[c.ownerId].name + ' is now hosting this circle', 'circleUpdate', { circleId: c.id })); return json(res, 200, circleView(c, u)); }
  if (p === '/family/circle/take-over' && m === 'POST') { const c = myCircle(cidQ); if (!c) return err(res, 404, 'NOT_FOUND', 'No group'); if (!c.hostTransition) return err(res, 400, 'BAD_REQUEST', 'Not in transition'); c.ownerId = u.id; c.hostTransition = null; return json(res, 200, circleView(c, u)); }
  if (p === '/family/members/me' && m === 'PUT') { const c = myCircle(cidQ); if (!c) return err(res, 404, 'NOT_FOUND', 'No group'); const mm = member(c, u.id); if (b.sharingLevel) { mm.sharingLevel = b.sharingLevel; if (b.sharingLevel === 'off') mm.snapshot = null; } if (b.nickname !== undefined) mm.nickname = b.nickname; if (b.colorHex) mm.colorHex = b.colorHex; return json(res, 200, { id: u.id, ...mm }); }
  const rm = p.match(/^\/family\/members\/([^/]+)$/);
  if (rm && m === 'DELETE') { const c = myCircle(cidQ); if (!c || c.ownerId !== u.id) return err(res, 403, 'HOST_ONLY', 'Host only'); if (rm[1] === u.id) return err(res, 400, 'BAD_REQUEST', 'Use Leave instead'); c.members = c.members.filter((id) => id !== rm[1]); c.members.forEach((id) => push(S.users[id], 'Family circle update', S.users[rm[1]].name + ' was removed from your family circle', 'circleUpdate')); return json(res, 200, { success: true }); }
  const lreq = p.match(/^\/family\/members\/([^/]+)\/location-request$/);
  if (lreq && m === 'POST') { const c = myCircle(cidQ); if (!c) return err(res, 404, 'NOT_FOUND', 'No group'); if (!gateCircle(res, c, u)) return; if (lreq[1] === u.id) return err(res, 400, 'BAD_REQUEST', 'That is you'); if (!c.settings?.anyoneCanRequestSnapshot && c.settings && c.ownerId !== u.id) return err(res, 403, 'HOST_ONLY', 'Only the host can ask for snapshots in this group'); if (member(c, lreq[1]).sharingLevel === 'off') return err(res, 400, 'SHARING_OFF', 'They have location sharing off'); const lr = S.locReqs.find((x) => x.targetId === lreq[1] && x.requesterId === u.id && x.status === 'pending') || (S.locReqs.push({ id: uid('lr_'), circleId: c.id, requesterId: u.id, targetId: lreq[1], status: 'pending', expiresAt: now() + 86400000 }), S.locReqs[S.locReqs.length - 1]); push(S.users[lreq[1]], u.name + ' asked where you are', 'Share a one-time snapshot of your location? It expires after 1 hour.', 'locationRequest', { locationRequestId: lr.id, requesterName: u.name, circleId: c.id }); return json(res, 201, lr); }
  if (p === '/family/location-requests/pending') return json(res, 200, S.locReqs.filter((x) => x.targetId === u.id && x.status === 'pending' && x.expiresAt > now()).map((x) => ({ ...x, requester: { id: x.requesterId, name: S.users[x.requesterId].name } })));
  const lres = p.match(/^\/family\/location-requests\/([^/]+)\/respond$/);
  if (lres && m === 'POST') { const lr = S.locReqs.find((x) => x.id === lres[1]); if (!lr || lr.targetId !== u.id) return err(res, 404, 'NOT_FOUND', 'Not found'); if (lr.status !== 'pending') return err(res, 400, 'BAD_REQUEST', 'No longer active'); const c = S.circles.find((x) => x.id === lr.circleId); if (b.share) { if (!gateCircle(res, c, u)) return; const mm = member(c, u.id); mm.snapshot = { sharedAt: now(), expiresAt: now() + T.snapshotExpiryMs, precision: mm.sharingLevel === 'precise' ? 'exact' : 'suburb', label: b.label || 'Scarborough WA' }; lr.status = 'shared'; push(S.users[lr.requesterId], 'Snapshot shared', u.name + ' shared a one-time location snapshot with the circle.', 'locationShared', { circleId: c.id }); } else lr.status = 'declined'; return json(res, 200, lr); }
  const lcan = p.match(/^\/family\/location-requests\/([^/]+)$/);
  if (lcan && m === 'DELETE') { const lr = S.locReqs.find((x) => x.id === lcan[1]); if (!lr) return err(res, 404, 'NOT_FOUND', 'Not found'); if (lr.requesterId !== u.id) return err(res, 403, 'FORBIDDEN', 'Not yours'); lr.status = 'cancelled'; return json(res, 200, { cancelled: true }); }
  // check-in requests (roll call)
  if (p === '/family/check-ins') { const c = myCircle(cidQ); return json(res, 200, S.checkins.filter((x) => c && x.circleId === c.id).slice(-30).reverse().map((x) => ({ ...x, name: S.users[x.userId].name, lat: x.at > now() - 3600000 ? x.lat : null }))); }
  if (p === '/family/check-in/requests') { const c = myCircle(cidQ); return json(res, 200, S.checkinReqs.filter((x) => c && x.circleId === c.id && x.at > now() - 86400000).map((x) => ({ ...x, requestedBy: S.users[x.requestedById].name, responded: c.members.filter((id) => S.checkins.some((ci) => ci.requestId === x.id && ci.userId === id)).map((id) => S.users[id].name), waitingOn: (x.targets.length ? x.targets : c.members.filter((id) => id !== x.requestedById)).filter((id) => !S.checkins.some((ci) => ci.requestId === x.id && ci.userId === id)).map((id) => ({ id, name: S.users[id].name })) }))); }
  const creq = p.match(/^\/family\/check-in\/request\/([^/]+)$/);
  if (creq && m === 'DELETE') { const x = S.checkinReqs.find((q) => q.id === creq[1]); if (!x) return err(res, 404, 'NOT_FOUND', 'Not found'); if (x.requestedById !== u.id) return err(res, 403, 'FORBIDDEN', 'Not yours'); S.checkinReqs = S.checkinReqs.filter((q) => q !== x); return json(res, 200, { cancelled: true }); }
  if (p === '/family/scheduled-check-ins' && m === 'GET') return json(res, 200, S.sched.filter((x) => x.userId === u.id));
  if (p === '/family/scheduled-check-ins' && m === 'POST') { if (S.sched.filter((x) => x.userId === u.id).length >= 3) return err(res, 400, 'BAD_REQUEST', 'Up to 3 daily check-ins'); const sc = { id: uid('sc_'), userId: u.id, timeOfDay: b.timeOfDay || '09:00', mode: b.mode || 'prompted' }; S.sched.push(sc); return json(res, 201, sc); }
  const sdel = p.match(/^\/family\/scheduled-check-ins\/([^/]+)$/);
  if (sdel && m === 'DELETE') { S.sched = S.sched.filter((x) => !(x.id === sdel[1] && x.userId === u.id)); return json(res, 200, { deleted: true }); }
  // family places
  if (p === '/family/places' && m === 'GET') { const c = myCircle(cidQ); return json(res, 200, S.famPlaces.filter((x) => c && x.circleId === c.id)); }
  if (p === '/family/places' && m === 'POST') { const c = myCircle(cidQ); if (!c) return err(res, 404, 'NOT_FOUND', 'No group'); if (!b.name) return err(res, 400, 'BAD_REQUEST', 'Give the place a name first'); const fp = { id: uid('fp_'), circleId: c.id, name: b.name, icon: b.icon || 'home', radiusMeters: b.radiusMeters || 300, address: b.address || '', prefs: {} }; S.famPlaces.push(fp); award(u, R.points.savedPlaceAdded, 'family place'); return json(res, 201, fp); }
  const fpm = p.match(/^\/family\/places\/([^/]+)(\/prefs)?$/);
  if (fpm) { const fp = S.famPlaces.find((x) => x.id === fpm[1]); if (!fp) return err(res, 404, 'NOT_FOUND', 'Not found'); if (fpm[2] && m === 'PUT') { fp.prefs[b.subjectMemberId || u.id] = { notifyArrivals: !!b.notifyArrivals, notifyDepartures: !!b.notifyDepartures }; return json(res, 200, fp); } if (m === 'PUT') { Object.assign(fp, b); return json(res, 200, fp); } if (m === 'DELETE') { S.famPlaces = S.famPlaces.filter((x) => x !== fp); return json(res, 200, { success: true }); } }
  if (p === '/__place-event' && m === 'POST') { const fp = S.famPlaces[0]; const c = fp && S.circles.find((x) => x.id === fp.circleId); if (c) c.members.filter((id) => id !== u.id).forEach((id) => push(S.users[id], u.name + ' arrived at ' + fp.name, 'Arrived safely.', 'placeEvent', { placeId: fp.id })); return json(res, 200, { ok: !!fp }); }
  // sos lists
  const myCircles = () => S.circles.filter((x) => x.members.includes(u.id));
  if (p === '/family/sos-recipients') return json(res, 200, myCircles().map((c) => ({ circleId: c.id, name: c.name, members: c.members.filter((id) => id !== u.id).map((id) => ({ memberId: id, name: S.users[id].name })) })));
  if (p === '/family/sos-lists' && m === 'GET') return json(res, 200, S.sosLists.filter((l) => l.ownerUserId === u.id).map((l) => { const cs = new Set(l.memberIds.map((id) => myCircles().find((c) => c.members.includes(id))?.id)); return { ...l, circleId: cs.size === 1 ? [...cs][0] : null, needsRepair: cs.size > 1 ? 'multipleGroups' : !l.memberIds.length ? 'empty' : null }; }));
  if (p === '/family/sos-lists' && m === 'POST') { if (S.sosLists.filter((l) => l.ownerUserId === u.id).length >= 4) return err(res, 400, 'BAD_REQUEST', 'Up to 4 lists'); const cs = new Set((b.memberIds || []).map((id) => myCircles().find((c) => c.members.includes(id))?.id)); if (cs.has(undefined)) return err(res, 400, 'BAD_REQUEST', 'Someone is not in your groups'); if (cs.size > 1) return err(res, 422, 'SOS_PRESET_OTHER_GROUP', 'Pick people from one group only'); const l = { id: uid('sl_'), ownerUserId: u.id, name: b.name || 'My list', memberIds: b.memberIds || [], isDefault: !!b.isDefault }; if (l.isDefault) S.sosLists.filter((x) => x.ownerUserId === u.id).forEach((x) => (x.isDefault = false)); S.sosLists.push(l); return json(res, 201, l); }
  const slm = p.match(/^\/family\/sos-lists\/([^/]+)$/);
  if (slm) { const l = S.sosLists.find((x) => x.id === slm[1] && x.ownerUserId === u.id); if (!l) return err(res, 404, 'NOT_FOUND', 'Not found'); if (m === 'DELETE') { S.sosLists = S.sosLists.filter((x) => x !== l); return json(res, 200, { deleted: true }); } const cs = new Set((b.memberIds || l.memberIds).map((id) => myCircles().find((c) => c.members.includes(id))?.id)); if (cs.size > 1) return err(res, 422, 'SOS_PRESET_OTHER_GROUP', 'Pick people from one group only'); Object.assign(l, b); if (l.isDefault) S.sosLists.filter((x) => x.ownerUserId === u.id && x !== l).forEach((x) => (x.isDefault = false)); return json(res, 200, l); }
  if (p === '/family/sos/preview') { const lid = url.searchParams.get('sosListId'); const l = lid && S.sosLists.find((x) => x.id === lid); const c = l ? myCircles().find((x) => x.members.includes(l.memberIds[0])) : myCircle(cidQ); if (!c) return json(res, 200, { state: 'noPeople', recipients: [] }); const recips = (l ? l.memberIds : c.members.filter((id) => id !== u.id)).filter((id) => c.members.includes(id)); const sv = circleView(c, u); return json(res, 200, { circleId: c.id, state: !sv.connectionAccess.allowed ? 'senderNoAccess' : !recips.length ? (c.members.length > 1 ? 'noneEligible' : 'noPeople') : 'ok', senderAccess: sv.connectionAccess, preset: l ? { id: l.id, name: l.name, state: l.memberIds.every((id) => c.members.includes(id)) ? 'ok' : 'repair', removedCount: l.memberIds.filter((id) => !c.members.includes(id)).length } : null, recipients: recips.map((id) => ({ memberId: id, name: S.users[id].name })) }); }
  if (p === '/family/sos/history') return json(res, 200, S.sos.filter((x) => myCircles().some((c) => c.id === x.circleId) && x.createdAt > now() - 30 * 86400000 && x.status !== 'active').slice(-20).reverse().map((x) => ({ id: x.id, senderName: S.users[x.userId]?.name, createdAt: x.createdAt, resolvedAt: x.resolvedAt, status: x.status, location: x.location, precision: x.precision, responses: (x.responses || []).map((r0) => ({ name: S.users[r0.userId]?.name, type: r0.type })) })));
  const sget = p.match(/^\/family\/sos\/([^/]+)$/);
  if (sget && m === 'GET' && !['active', 'history', 'preview'].includes(sget[1])) { const x = S.sos.find((z) => z.id === sget[1]); if (!x) return err(res, 404, 'NOT_FOUND', 'Not found'); const mineS = x.userId === u.id; return json(res, 200, { ...sosView(x), senderName: S.users[x.userId]?.name, responses: (x.responses || []).filter((r0) => !mineS || r0.type === 'seen').map((r0) => ({ name: S.users[r0.userId]?.name, type: r0.type })) }); }
  if (p === '/family/journeys/shared') return json(res, 200, S.journeys.filter((j) => j.status === 'active' && (j.recipients || []).includes(u.id)).map((j) => ({ ...j, memberName: S.users[j.userId].name })));
  const jget = p.match(/^\/family\/journeys\/([^/]+)$/);
  if (jget && m === 'GET' && jget[1] !== 'me') { const j = S.journeys.find((x) => x.id === jget[1]); if (!j) return err(res, 404, 'NOT_FOUND', 'Not found'); if (j.userId !== u.id && !(j.recipients || []).includes(u.id)) return err(res, 403, 'FORBIDDEN', 'Not shared with you'); return json(res, 200, { ...j, memberName: S.users[j.userId].name, serverNow: now() }); }
  const cm = p.match(/^\/family\/circles\/([^/]+)\/(check-in|check-in\/request|sos|journeys|location)$/);
  if (cm) {
    const c = S.circles.find((x) => x.id === cm[1] && x.members.includes(u.id)); if (!c) return err(res, 404, 'NOT_FOUND', 'Group not found');
    if (!gateCircle(res, c, u)) return;
    const kind = cm[2];
    if (kind === 'check-in' && m === 'POST') {
      if (b.hazardId && !S.hazards.find((x) => x.id === b.hazardId)) return err(res, 400, 'BAD_REQUEST', 'That alert does not exist');
      const needs = b.status === 'needsHelp';
      const ci = { id: uid('ci_'), circleId: c.id, userId: u.id, at: now(), status: needs ? 'needsHelp' : 'safe', text: needs ? 'Needs help' : R.wording.checkedIn, lat: b.latitude || null, precision: b.precision || null, hazardId: b.hazardId || null, requestId: b.requestId || null, message: b.message || '' }; S.checkins.push(ci);
      member(c, u.id).lastCheckInAt = now(); if (b.latitude) member(c, u.id).snapshot = { sharedAt: now(), expiresAt: now() + T.snapshotExpiryMs, precision: b.precision || 'exact', label: b.label || 'Scarborough WA' };
      c.members.filter((id) => id !== u.id).forEach((id) => push(S.users[id], needs ? `${u.name} needs help` : `${u.name} checked in`, needs ? 'Reach out now. Open ALRT for details.' : 'Open ALRT to see their check-in.', 'checkin', { circleId: c.id, checkInId: ci.id, critical: needs }));
      return json(res, 201, ci);
    }
    if (kind === 'check-in/request' && m === 'POST') {
      const targets = b.memberIds || (b.userId ? [b.userId] : []);
      if (targets.some((id) => !c.members.includes(id))) return err(res, 400, 'BAD_REQUEST', 'Someone is not in this group');
      const rq = { id: uid('cr_'), circleId: c.id, requestedById: u.id, targets, at: now(), hazardId: b.hazardId || null, message: b.message || '' }; S.checkinReqs.push(rq);
      (targets.length ? targets : c.members.filter((id) => id !== u.id)).forEach((id) => push(S.users[id], 'Check-in requested', b.message || `${u.name} asked ${targets.length ? 'you' : 'everyone'} to check in.`, 'checkon', { circleId: c.id, requestId: rq.id }));
      return json(res, 201, rq);
    }
    if (kind === 'sos' && m === 'POST') {
      if (b.heldMs !== undefined && b.heldMs < T.sosHoldMs) return err(res, 400, 'HOLD_REQUIRED', 'Hold for 3 seconds to send SOS');
      const lst = b.sosListId && S.sosLists.find((x) => x.id === b.sosListId && x.ownerUserId === u.id);
      if (b.sosListId && !lst) return err(res, 404, 'NOT_FOUND', 'List not found');
      const recipients = lst ? lst.memberIds.filter((id) => c.members.includes(id)) : c.members.filter((id) => id !== u.id);
      if (lst && lst.memberIds.some((id) => !c.members.includes(id)) && !recipients.length) return err(res, 422, 'SOS_PRESET_OTHER_GROUP', 'This list points at another group', { sosListId: lst.id });
      if (!recipients.length) return err(res, 422, 'NO_SOS_RECIPIENTS', 'Your SOS has nobody to reach yet', { hasCandidates: c.members.length > 1, presetState: lst ? 'repair' : null });
      const other = S.sos.find((s) => s.listId === (b.listId || 'default') && s.circleId !== c.id && s.status === 'active' && sosView(s).active);
      if (other) return err(res, 409, 'SOS_PRESET_OTHER_GROUP', 'An SOS list can notify one group only');
      const s = { id: uid('sos_'), circleId: c.id, userId: u.id, listId: b.listId || 'default', createdAt: now(), extendedMs: 0, status: 'active', location: b.location || 'none', precision: b.precision || 'exact', trail: [], messageSent: 'SOS' };
      S.sos.push(s);
      s.recipients = recipients; recipients.forEach((id) => push(S.users[id], 'SOS from ' + u.name, 'Needs help now. Check on them. Call your local emergency number if needed.', 'sos', { circleId: c.id, critical: true, sosId: s.id }));
      return json(res, 201, sosView(s));
    }
    if (kind === 'journeys' && m === 'POST') {
      const min = b.minutes || b.durationMinutes || 30; if (!T.journeyInitialMinutes.includes(min)) return err(res, 400, 'BAD_REQUEST', 'Choose 15, 30 or 60 minutes');
      if (b.live && (c.settings || { journeysSnapPointsOnly: true }).journeysSnapPointsOnly) return err(res, 409, 'LIVE_JOURNEY_NOT_ALLOWED', 'This group allows periodic updates only');
      const recips = (b.recipientMemberIds && b.recipientMemberIds.length ? b.recipientMemberIds : c.members.filter((id) => id !== u.id));
      if (recips.some((id) => !c.members.includes(id))) return err(res, 400, 'BAD_REQUEST', 'Someone is not in this group');
      S.journeys.filter((x) => x.userId === u.id && x.status === 'active').forEach((x) => (x.status = 'ended'));
      const j = { id: uid('j_'), circleId: c.id, userId: u.id, createdAt: now(), endsAt: now() + min * 60000, live: !!b.live, points: [], status: 'active', dest: b.dest || '', recipients: recips, maxTotalMinutes: T.journeyMaxMinutes };
      S.journeys.push(j); recips.forEach((id) => push(S.users[id], u.name + ' is sharing a journey', j.live ? 'You can watch their live location until they arrive or stand down.' : "You'll see when they leave and arrive.", 'journey', { journeyId: j.id, circleId: c.id }));
      return json(res, 201, j);
    }
    if (kind === 'location' && m === 'POST') return json(res, 200, { sharedAt: now(), expiresAt: now() + T.snapshotExpiryMs });
  }
  const sosAct = p.match(/^\/family\/sos\/([^/]+)\/(extend|resolve|trail|location|location-consent|respond)$/);
  if (sosAct) {
    const s = S.sos.find((x) => x.id === sosAct[1]); if (!s) return err(res, 404, 'NOT_FOUND', 'Not found');
    if (sosAct[2] === 'respond') { if (s.userId === u.id) return err(res, 400, 'BAD_REQUEST', 'Own SOS'); if (s.status !== 'active' || !sosView(s).active) return err(res, 400, 'BAD_REQUEST', 'This SOS has ended'); const type = b.type || 'seen'; (s.responses ||= []).push({ userId: u.id, type }); if (type === 'seen') push(S.users[s.userId], u.name + ' has seen your SOS', 'They can see what you shared.', 'sosResponse', { sosId: s.id }); else (s.recipients || []).filter((id) => id !== u.id && id !== s.userId).forEach((id) => push(S.users[id], 'SOS update', u.name + (type === 'onMyWay' ? ' is on their way' : ' has called ' + S.users[s.userId].name), 'sosResponse', { sosId: s.id })); return json(res, 200, { ok: true }); }
    if (sosAct[2] === 'extend') { if (T.sosDurationMs + s.extendedMs + T.sosExtendMs > T.sosTotalCapMs) return err(res, 400, 'MAX_DURATION', 'An SOS can run 4 hours at most'); s.extendedMs += T.sosExtendMs; return json(res, 200, sosView(s)); }
    if (sosAct[2] === 'resolve') { const cc = S.circles.find((x) => x.id === s.circleId); if (s.userId !== u.id && !(cc && cc.ownerId === u.id)) return err(res, 403, 'FORBIDDEN', 'Only the sender or the host can end an SOS'); s.status = 'resolved'; s.resolvedAt = now(); c0 = S.circles.find((x) => x.id === s.circleId); c0.members.filter((id) => id !== u.id).forEach((id) => push(S.users[id], 'SOS ended', (s.userId === u.id ? u.name + ' ended their SOS.' : u.name + ' (host) ended ' + S.users[s.userId].name + "'s SOS."), 'sosResolved', { sosId: s.id })); return json(res, 200, sosView(s)); }
    if (sosAct[2] === 'trail') { if (b.capturedAt && b.capturedAt < now() - 120000) return err(res, 400, 'STALE_POINT', 'Point too old'); s.trail.push(b); return json(res, 200, { ok: true }); }
    return json(res, 200, sosView(s));
  }
  if (p === '/family/sos/active') return json(res, 200, S.sos.filter((s) => s.status === 'active').map(sosView));
  const jAct = p.match(/^\/family\/journeys\/([^/]+)\/(extend|stop|point)$/);
  if (jAct) {
    const j = S.journeys.find((x) => x.id === jAct[1]); if (!j) return err(res, 404, 'NOT_FOUND', 'Not found');
    if (jAct[2] === 'extend') { const total = (j.endsAt + 3600000 - j.createdAt) / 60000; if (total > T.journeyMaxMinutes) return err(res, 400, 'MAX_DURATION', 'Journeys can run 4 hours at most'); j.endsAt += 3600000; return json(res, 200, j); }
    if (jAct[2] === 'stop') { j.status = 'ended'; j.endedAt = now(); return json(res, 200, j); }
    j.points.push(b); return json(res, 200, { ok: true });
  }
  if (p === '/family/journeys/me') return json(res, 200, S.journeys.filter((j) => j.userId === u.id && j.status === 'active' && j.endsAt > now()).map((j) => ({ ...j, serverNow: now() })));

  return err(res, 404, 'NOT_FOUND', 'No such route in the prototype: ' + m + ' ' + p);
}

const MIME = { '.html': 'text/html', '.js': 'text/javascript', '.css': 'text/css', '.json': 'application/json', '.svg': 'image/svg+xml' };
http.createServer(async (req, res) => {
  const url = new URL(req.url, 'http://x');
  try {
    if (url.pathname.startsWith('/api') || url.pathname.startsWith('/__')) {
      if (process.env.ALRT_API && url.pathname.startsWith('/api')) {
        const r = await fetch(process.env.ALRT_API + url.pathname + url.search, { method: req.method, headers: { 'content-type': 'application/json', authorization: req.headers.authorization || '' }, body: ['GET', 'HEAD'].includes(req.method) ? undefined : await new Promise((ok) => { let d = ''; req.on('data', (c) => (d += c)); req.on('end', () => ok(d)); }) });
        res.writeHead(r.status, { 'content-type': 'application/json' }); return res.end(await r.text());
      }
      if (url.pathname.startsWith('/__')) url.pathname = '/api' + url.pathname;
      return await api(req, res, url);
    }
    if (url.pathname === '/rules.json') return res.writeHead(200, { 'content-type': 'application/json' }), res.end(fs.readFileSync(path.join(__dirname, 'rules.json')));
    let f = path.join(PUB, url.pathname === '/' ? 'index.html' : url.pathname);
    if (!f.startsWith(PUB) || !fs.existsSync(f)) f = path.join(PUB, 'index.html');
    res.writeHead(200, { 'content-type': MIME[path.extname(f)] || 'application/octet-stream' }); res.end(fs.readFileSync(f));
  } catch (e) { err(res, 500, 'SERVER', String(e)); }
}).listen(PORT, () => console.log('ALRT prototype on http://localhost:' + PORT + (process.env.ALRT_API ? ' proxying ' + process.env.ALRT_API : ' (mock backend)')));

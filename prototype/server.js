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
let offset = 0; // virtual clock, advanced by tests only
const now = () => Date.now() + offset;
const T = R.timings;

const uid = (p) => p + Math.random().toString(36).slice(2, 9);
let S;
function seed() {
  offset = 0;
  S = {
    users: {}, tokens: {}, hazards: [], circles: [], sos: [], journeys: [], checkins: [],
    notifications: [], pushTokens: [], billingEnabled: true, webhookLog: [], sponsorships: [],
    asks: {}, places: {}, xp: {},
  };
  const t = now();
  const h = (title, source, band, cat, mins, lat, lng, extra = {}) => ({
    id: uid('h_'), title, source, band, category: cat, createdAt: t - mins * 60000, lat, lng,
    status: 'live', confirmations: 0, ...extra,
  });
  S.hazards.push(
    h('Bushfire: Watch and Act', 'aws', 'action', 'weather', 12, 8, 18, { level: 'Watch and Act', agency: 'AWS feed', body: 'A fire is burning near the highway. Conditions are changing.', plain: 'A fire is close and could reach homes. Be ready to leave.', know: 'Fire front moving north east. Embers likely.', todo: 'Get ready to leave. Check on neighbours. Listen to local radio.' }),
    h('Road closed after crash', 'official', 'action', 'traffic', 25, 20, 40, { agency: 'State traffic authority', body: 'Both lanes closed.', plain: 'The road is shut. Use another route.', know: 'Crash cleared in about 2 hours.', todo: 'Take the detour. Allow extra time.' }),
    h('Power outage reported', 'community', 'info', 'utilities', 40, 55, 30, { confirmations: 2, body: 'Whole street without power.' }),
    h('Air quality poor: smoke', 'official', 'monitor', 'health', 60, 70, 55, { agency: 'Environment agency', body: 'Smoke haze across the region.', plain: 'The air is unhealthy for sensitive people.', know: 'Haze likely to ease by evening.', todo: 'Keep windows closed. Reduce outdoor exercise.' }),
    h('Official alert with urgent wording', 'official', 'info', 'community', 90, 30, 70, { agency: 'City council', body: 'Urgent: road works, avoid the area.', plain: 'Sounds urgent but this is road works only. No danger to people.', know: 'Lane closures until Friday.', todo: 'Plan another route.' }),
    h('Global: flooding in a distant region', 'global', 'info', 'weather', 180, 85, 10, { agency: 'Humanitarian feed', body: 'Verbatim from source.' }),
    h('ALRT Assessment: avoid river road tonight', 'intel', 'monitor', 'security', 30, 45, 80, { body: 'Plain-terms read of the situation.' }),
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
function circleView(c, u) {
  const sp = S.sponsorships.find((x) => x.circleId === c.id && x.live);
  const cap = sp ? R.plans[sp.tier].capacity : null;
  const personal = plan(u);
  const allowed = !S.billingEnabled || covered(c) || personal.plan === 'individual';
  return {
    circleId: c.id, name: c.name, role: c.ownerId === u.id ? 'owner' : 'member', fundingMode: sp ? sp.funding : 'none',
    peopleCount: c.members.length, capacity: cap,
    sponsorship: sp ? { tier: sp.tier, live: true, status: 'active', expiresAt: sp.expiresAt, coveredBy: sp.sponsorUserId === u.id ? 'you' : 'sponsor', youPay: sp.sponsorUserId === u.id } : { tier: null, live: false, status: 'none', expiresAt: null, coveredBy: null, youPay: false },
    connectionAccess: { allowed, reason: allowed ? (covered(c) ? 'group_covered' : 'individual') : 'INDIVIDUAL_REQUIRED' },
  };
}
function gateCircle(res, c, u) {
  const v = circleView(c, u);
  if (!v.connectionAccess.allowed) {
    err(res, 402, 'INDIVIDUAL_REQUIRED', 'Check in, Check on, SOS and Journey in this group need ALRT + for each person, or a plan covering the group.', { circleId: c.id });
    return false;
  }
  return true;
}
function push(u, title, bodyText, kind, extra = {}) {
  const n = { id: uid('n_'), userId: u.id, title, body: bodyText, kind, createdAt: now(), ...extra };
  S.notifications.push(n);
  return n;
}
const award = (u, pts, why) => { S.xp[u.id] = (S.xp[u.id] || 0) + pts; (S.xpLog ||= []).push({ userId: u.id, pts, why }); };
const hazardView = (h) => ({ ...h, minutesAgo: Math.round((now() - h.createdAt) / 60000) });

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
  if (p.startsWith('/auth/oauth/')) {
    const email = `${p.split('/').pop()}.demo@example.com`;
    let x = Object.values(S.users).find((z) => z.email === email);
    if (!x) { x = { id: uid('u_'), email, name: 'Demo user', plan: 'free', onboarding: {}, settings: { level: 'official' } }; S.users[x.id] = x; award(x, R.points.firstSetup, 'first setup'); }
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
      if (prod.startsWith('individual')) { target.plan = 'individual'; target.trial = !!ev.is_trial_period; target.expiresAt = now() + (ev.is_trial_period ? R.plans.individual.trialDays * 86400000 : 30 * 86400000); target.cancelled = false; }
    }
    if (['EXPIRATION'].includes(ev.type)) { target.plan = 'free'; target.trial = false; }
    if (ev.type === 'CANCELLATION') target.cancelled = true;
    return json(res, 200, { ok: true });
  }

  if (p === '/__billing' && m === 'POST') { S.billingEnabled = !!b.on; return json(res, 200, { billingEnabled: S.billingEnabled }); }
  if (p === '/__advance' && m === 'POST') { offset += Number(b.ms) || 0; return json(res, 200, { offset }); }
  if (p === '/__reset' && m === 'POST') { seed(); return json(res, 200, { ok: true }); }
  if (p === '/__state' && m === 'GET') return json(res, 200, { users: Object.keys(S.users).length, notifications: S.notifications.length, webhookLog: S.webhookLog, xp: S.xp, offset });

  if (!need()) return;

  // ---- access
  if (p === '/access' && m === 'GET') {
    const mine = S.circles.filter((c) => c.members.includes(u.id));
    return json(res, 200, { billingEnabled: S.billingEnabled, personal: plan(u), groups: mine.map((c) => circleView(c, u)), unboundSponsorships: [], computedAt: new Date(now()).toISOString(), serverNow: now() });
  }
  if (p === '/access/reconcile' && m === 'POST') return json(res, 200, { ok: true });
  if (p === '/access/sponsorship-intents' && m === 'POST') {
    const si = { id: uid('si_'), sponsorUserId: u.id, tier: b.tier, funding: 'group', live: false, circleId: null };
    S.sponsorships.push(si); return json(res, 201, si);
  }
  const bind = p.match(/^\/access\/sponsorships\/([^/]+)\/bind$/);
  if (bind && m === 'POST') {
    const si = S.sponsorships.find((x) => x.id === bind[1]); const c = S.circles.find((x) => x.id === b.circleId);
    if (!si || !c) return err(res, 404, 'NOT_FOUND', 'Not found');
    if (covered(c)) return err(res, 409, 'GROUP_ALREADY_COVERED', 'This group already has a plan');
    if (c.members.length > R.plans[si.tier].capacity) return err(res, 409, 'GROUP_FULL', 'That plan is smaller than this group');
    si.circleId = c.id; si.live = true; si.expiresAt = now() + 30 * 86400000; return json(res, 200, si);
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
  if (p === '/user/profile') return json(res, 200, { ...u, points: S.xp[u.id] || 0 });
  if (p === '/user/push-notification-settings') {
    if (m === 'PUT' || m === 'PATCH' || m === 'POST') { u.settings.level = b.level || u.settings.level; return json(res, 200, u.settings); }
    return json(res, 200, u.settings);
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
      const h = { id: uid('h_'), title: b.title || b.category, source: 'community', band: 'info', category: b.category, createdAt: now(), lat: b.lat || 0, lng: b.lng || 0, status: 'live', confirmations: 0, authorId: u.id, body: b.body || '', severity: b.severity || 'minor', anonymous: true };
      S.hazards.push(h); award(u, R.points.reportApproved, 'report'); return json(res, 201, hazardView(h));
    }
  }
  const vote = p.match(/^\/hazard\/([^/]+)\/vote$/);
  if (vote && m === 'POST') {
    const h = S.hazards.find((x) => x.id === vote[1]); if (!h) return err(res, 404, 'NOT_FOUND', 'Not found');
    if (b.vote === 'see') {
      h.confirmations += 1;
      if (h.authorId) award({ id: h.authorId }, R.points.confirmedByNeighbour, 'confirmed');
      // confirmations earn the confirmer nothing
      if (h.source === 'community' && h.confirmations === 1) {
        Object.values(S.users).forEach((x) => { if (x.settings.level === 'all' && x.id !== h.authorId) push(x, 'Community report', `${h.title} near you. Unverified.`, 'community', { hazardId: h.id }); });
      }
    } else h.confirmations = Math.max(0, h.confirmations - 1);
    return json(res, 200, hazardView(h));
  }

  // ---- ask alrt
  if (p === '/ask-alrt/allowance') {
    const used = S.asks[u.id] || 0; const lim = plan(u).askPerDay; return json(res, 200, { used, limit: lim, remaining: Math.max(0, lim - used) });
  }
  if (p === '/ask-alrt' && m === 'POST') {
    const used = S.asks[u.id] || 0; const lim = plan(u).askPerDay;
    if (S.billingEnabled && used >= lim) return err(res, 402, 'ASK_LIMIT', `Free includes ${R.plans.free.askPerDay} questions a day. ALRT + includes ${R.plans.individual.askPerDay}.`, { used, limit: lim });
    S.asks[u.id] = used + 1;
    return json(res, 200, { answer: `Plain terms: ${(b.question || '').slice(0, 60)}. Based on official sources near you. ALRT is not an emergency service. In danger? Call your local emergency number.`, remaining: Math.max(0, lim - used - 1) });
  }

  const gc = p.match(/^\/guide\/([^/]+)\/complete$/);
  if (gc && m === 'POST') { u.guides = u.guides || {}; if (!u.guides[gc[1]]) { u.guides[gc[1]] = 1; award(u, R.points.guideComplete, 'guide'); } return json(res, 200, { ok: true });}
  // ---- notifications / points
  if (p === '/notification/feed') return json(res, 200, S.notifications.filter((n) => n.userId === u.id).sort((a, b2) => b2.createdAt - a.createdAt));
  if (p === '/notification/test' && m === 'POST') return json(res, 200, push(u, 'Test', 'Test notification', 'test'));
  if (p === '/xp/summary' || p === '/xpPoints/summary') { const pts = S.xp[u.id] || 0; const lv = [...R.points.levels].reverse().find((l) => pts >= l[1]); return json(res, 200, { points: pts, level: lv[0], streak: null }); }
  if (p.endsWith('/leaderboard')) return json(res, 200, Object.keys(S.xp).map((k, i) => ({ rank: i + 1, points: S.xp[k] })).sort((a, b2) => b2.points - a.points)); // never identities

  // ---- family
  if (p === '/family/circles' && m === 'GET') return json(res, 200, S.circles.filter((c) => c.members.includes(u.id)).map((c) => ({ ...circleView(c, u), code: c.code, members: c.members.map((id) => ({ id, name: S.users[id].name })) })));
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
  const cm = p.match(/^\/family\/circles\/([^/]+)\/(check-in|check-in\/request|sos|journeys|location)$/);
  if (cm) {
    const c = S.circles.find((x) => x.id === cm[1] && x.members.includes(u.id)); if (!c) return err(res, 404, 'NOT_FOUND', 'Group not found');
    if (!gateCircle(res, c, u)) return;
    const kind = cm[2];
    if (kind === 'check-in' && m === 'POST') {
      const ci = { id: uid('ci_'), circleId: c.id, userId: u.id, at: now(), text: R.wording.checkedIn }; S.checkins.push(ci);
      c.members.filter((id) => id !== u.id).forEach((id) => push(S.users[id], `${u.name} ${R.wording.checkedIn.toLowerCase()}`, 'Tap to see when.', 'checkin', { circleId: c.id }));
      return json(res, 201, ci);
    }
    if (kind === 'check-in/request' && m === 'POST') {
      const target = b.userId; if (!c.members.includes(target)) return err(res, 400, 'BAD_REQUEST', 'Not in group');
      push(S.users[target], R.wording.checkOn + ': ' + u.name, `${u.name} would like you to check in.`, 'checkon', { circleId: c.id });
      return json(res, 201, { ok: true });
    }
    if (kind === 'sos' && m === 'POST') {
      if (b.heldMs !== undefined && b.heldMs < T.sosHoldMs) return err(res, 400, 'HOLD_REQUIRED', 'Hold for 3 seconds to send SOS');
      const other = S.sos.find((s) => s.listId === (b.listId || 'default') && s.circleId !== c.id && s.status === 'active' && sosView(s).active);
      if (other) return err(res, 409, 'SOS_PRESET_OTHER_GROUP', 'An SOS list can notify one group only');
      const s = { id: uid('sos_'), circleId: c.id, userId: u.id, listId: b.listId || 'default', createdAt: now(), extendedMs: 0, status: 'active', location: b.location || 'none', precision: b.precision || 'exact', trail: [], messageSent: 'SOS' };
      S.sos.push(s);
      c.members.filter((id) => id !== u.id).forEach((id) => push(S.users[id], 'SOS from ' + u.name, 'Needs help now. Check on them. Call your local emergency number if needed.', 'sos', { circleId: c.id, critical: true, sosId: s.id }));
      return json(res, 201, sosView(s));
    }
    if (kind === 'journeys' && m === 'POST') {
      const min = b.minutes || 30; if (!T.journeyInitialMinutes.includes(min)) return err(res, 400, 'BAD_REQUEST', 'Choose 15, 30 or 60 minutes');
      const j = { id: uid('j_'), circleId: c.id, userId: u.id, createdAt: now(), endsAt: now() + min * 60000, live: !!b.live, points: [], status: 'active', dest: b.dest || '' };
      S.journeys.push(j); c.members.filter((id) => id !== u.id).forEach((id) => push(S.users[id], u.name + ' started a journey', `Back by ${new Date(j.endsAt).toISOString().slice(11, 16)} UTC.`, 'journey'));
      return json(res, 201, j);
    }
    if (kind === 'location' && m === 'POST') return json(res, 200, { sharedAt: now(), expiresAt: now() + T.snapshotExpiryMs });
  }
  const sosAct = p.match(/^\/family\/sos\/([^/]+)\/(extend|resolve|trail|location|location-consent)$/);
  if (sosAct) {
    const s = S.sos.find((x) => x.id === sosAct[1]); if (!s) return err(res, 404, 'NOT_FOUND', 'Not found');
    if (sosAct[2] === 'extend') { s.extendedMs += T.sosExtendMs; return json(res, 200, sosView(s)); }
    if (sosAct[2] === 'resolve') { s.status = 'resolved'; return json(res, 200, sosView(s)); }
    if (sosAct[2] === 'trail') { if (b.capturedAt && b.capturedAt < now() - 120000) return err(res, 400, 'STALE_POINT', 'Point too old'); s.trail.push(b); return json(res, 200, { ok: true }); }
    return json(res, 200, sosView(s));
  }
  if (p === '/family/sos/active') return json(res, 200, S.sos.filter((s) => s.status === 'active').map(sosView));
  const jAct = p.match(/^\/family\/journeys\/([^/]+)\/(extend|stop|point)$/);
  if (jAct) {
    const j = S.journeys.find((x) => x.id === jAct[1]); if (!j) return err(res, 404, 'NOT_FOUND', 'Not found');
    if (jAct[2] === 'extend') { const total = (j.endsAt + 3600000 - j.createdAt) / 60000; if (total > T.journeyMaxMinutes) return err(res, 400, 'MAX_DURATION', 'Journeys can run 4 hours at most'); j.endsAt += 3600000; return json(res, 200, j); }
    if (jAct[2] === 'stop') { j.status = 'stopped'; return json(res, 200, j); }
    j.points.push(b); return json(res, 200, { ok: true });
  }
  if (p === '/family/journeys/me') return json(res, 200, S.journeys.filter((j) => j.userId === u.id && j.status === 'active'));

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

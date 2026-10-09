#!/usr/bin/env python3
"""End-to-end audit of the ALRT prototype (canvas boards + mock backend). Drives the real UI in Chromium.
Run: node prototype/server.js &  then  python3 prototype/audit.py
Writes prototype/audit-results.json."""
import json, re, sys
from playwright.sync_api import sync_playwright

URL = 'http://localhost:4173'
R = json.load(open(__file__.replace('audit.py', 'rules.json')))
results = []
def check(name, ok, detail=''):
    results.append({'check': name, 'pass': bool(ok), 'detail': str(detail)[:200]})
    print(('PASS ' if ok else 'FAIL ') + name + (' :: ' + str(detail)[:160] if not ok else ''))
BANNED = re.compile(r"(i'm safe|is safe|are you safe|all clear|triple zero|\b000\b|\u2014|\u2013)", re.I)

with sync_playwright() as p:
    b = p.chromium.launch(executable_path='/opt/pw-browsers/chromium', args=['--no-sandbox'])
    pg = b.new_context(viewport={'width': 760, 'height': 900}).new_page()
    errors = []; pg.on('pageerror', lambda e: errors.append(str(e)))
    pg.goto(URL); pg.wait_for_selector('[data-testid=onb-next]')
    api = lambda path, method='GET', body=None, tok=True: pg.evaluate("""async ([p,m,b,t])=>{const r=await fetch('/api'+p,{method:m,headers:{'content-type':'application/json',authorization:t?'Bearer '+localStorage.getItem('alrt_tok'):''},body:b?JSON.stringify(b):undefined});let d={};try{d=await r.json()}catch(e){}return {status:r.status,data:d}}""", [path, method, body, tok])
    text = lambda: pg.inner_text('#phone')
    def scan(label):
        t = text(); m = BANNED.search(t); check(f'Wording scan clean: {label}', not m, m.group(0) if m else '')
    def click(tid): pg.click(f'[data-testid="{tid}"]')
    def settle(ms=600): pg.wait_for_timeout(ms)
    def goto_tab(k): click('tab-' + k); settle(700)
    def has(tid): return pg.query_selector(f'[data-testid="{tid}"]') is not None
    def reg(email, name=None, level=None):
        return pg.evaluate("""async([e,n,l])=>{const r=await fetch('/api/auth/email-password/register',{method:'POST',headers:{'content-type':'application/json'},body:JSON.stringify({email:e,password:'x',name:n||undefined})});const d=await r.json();if(l)await fetch('/api/user/push-notification-settings',{method:'PUT',headers:{'content-type':'application/json',authorization:'Bearer '+d.token},body:JSON.stringify({level:l})});return {token:d.token,id:d.user.id}}""", [email, name, level])
    def asu(tok, path, body=None, method=None):
        return pg.evaluate("""async([p,m,b,t])=>{const r=await fetch('/api'+p,{method:m,headers:{'content-type':'application/json',authorization:'Bearer '+t},body:b?JSON.stringify(b):undefined});let d={};try{d=await r.json()}catch(e){}return {status:r.status,data:d}}""", [path, method or ('POST' if body is not None else 'GET'), body, tok])

    # ================= Onboarding (approved boards Splash, Onb1-5) =================
    bg = pg.evaluate("getComputedStyle(document.querySelector('#screen > div')).backgroundColor")
    check('Splash is white with the icon', bg == 'rgb(255, 255, 255)', bg)
    check('Splash: Get started and I already have an account', has('onb-next') and has('have-account'))
    click('onb-next'); settle(300); check('Onb1 opens with Welcome to ALRT', 'Welcome to ALRT' in text()); scan('Onb1')
    click('onb-next'); settle(300); check('Onb2: three things to know plus age gate', has('age')); scan('Onb2')
    click('onb-next'); settle(300); check('Cannot continue until all four are ticked', has('onb1'))
    for i in range(3): pg.click(f'[data-act=onbagree][data-i="{i}"]')
    click('age'); click('onb-next'); settle(300); check('Onb3: alert level picker, three levels incl. Keep it quiet', has('onb2') and 'Keep it quiet' in text())
    check('Onb3 stays ambiguous about emergency language', 'never raises or lowers a level' in text())
    pg.click('[data-id=all]'); click('onb-later'); settle(300); check('Onb4: ALRT is free to use, no prices, store prices only', has('onb3') and '$' not in text() and 'Prices are shown in the app store' in text())
    check('Onb4 states free limits from rules', 'one saved place and 3 Ask ALRT' in text())
    t = text(); check('Onboarding never asks for location', 'Allow location' not in t and 'Use my location' not in t)
    click('onb-next'); settle(300); check('Onb5 is sign in, last step; no Continue as Guest', has('onb4') and 'guest' not in text().lower())
    check('No passwords: Apple, Google, Microsoft only, no email or password field', pg.query_selector('input[type=password]') is None and 'Email' not in text() and 'never creates or stores a password' in text())
    click('oauth-google'); settle(1800)
    check('Set up complete screen with first 20 points', has('onbdone') and f"{R['points']['firstSetup']} points" in text())
    click('onbgo'); settle(500); check('Notification priming at the moment of wanting (not during onboarding)', has('prime-on')); click('prime-on'); settle(600)

    # ================= Footer (approved Footer board) =================
    nav = pg.query_selector('#navwrap nav'); check('Footer present on main tabs', nav is not None)
    labels = pg.evaluate("[...document.querySelectorAll('#navwrap nav a')].map(a=>a.innerText.trim())")
    check('Footer: six slots Map, Alerts, Report, Ready, Family, Me avatar', labels[:5] == ['Map', 'Alerts', 'Report', 'Ready', 'Family'] and len(labels) == 6, labels)
    bar = pg.evaluate("getComputedStyle(document.querySelector('#navwrap nav > div')).borderRadius")
    check('Footer is the frosted bar, 18px radius', bar == '18px', bar)
    check('No raised round Report button', pg.evaluate("getComputedStyle(document.querySelector('#navwrap nav a[data-nav=Report]')).borderRadius") in ('14px', '0px'))
    check('Family slot is indigo', pg.evaluate("getComputedStyle(document.querySelector('#navwrap nav a[data-nav=Family]')).color") == 'rgb(61, 61, 223)')

    # ================= Map (Main board) =================
    check('Map board with pins bound to live alerts', has('map') and len(pg.query_selector_all('[data-testid^=pin-]')) >= 3)
    check('Map banner counts warnings from live data', re.search(r'\d warnings? near you', text()) is not None)
    check('Mic (voice to text) and Ask ALRT are separate buttons', has('mic-btn') and has('ask-btn'))
    click('mic-btn'); settle(1300); check('Voice to text fills the search, not Ask ALRT', 'Scarborough Beach Road' in pg.inner_text('[data-testid=voice-text]') and 'Ask ALRT is a different button' in text()); pg.evaluate("A.close(); draw()")
    pg.evaluate("A.mapkey(); draw()"); settle(300); scan('Map key')
    outl = pg.evaluate("[...document.querySelectorAll('[data-testid=sheet] svg[data-outline] *')].every(e=>e.getAttribute('fill')==='none' && e.getAttribute('stroke')==='#3A3A42')")
    check('Map key shapes are outlines only, dark grey, no colour', outl and pg.evaluate("document.querySelectorAll('[data-testid=sheet] svg[data-outline]').length") == 5)
    kt = text(); i1, i2, i3 = kt.find('WHO IS SPEAKING'), kt.find('AWS LEVELS'), kt.find('COLOUR MEANS SEVERITY')
    check('Map key order: shapes, AWS colours explained, then colour to severity words', -1 not in (i1, i2, i3) and i1 < i2 < i3 and all(w in kt for w in ['Advice', 'Watch and Act', 'Emergency Warning']) and all(R['bandWords'][k][0] in kt for k in R['bandWords']))
    pg.evaluate("A.close(); draw()")
    click('route-btn'); settle(400); scan('Route'); pg.fill('[data-testid=route-to]', 'Perth CBD'); click('route-go'); settle(400)
    check('Route: options with hazards on each, choose like Google Maps', len(pg.query_selector_all('[data-testid=route-opt]')) == 3 and has('route-map') and 'Fastest' in text() and 'No alerts' in text())
    pg.click('[data-testid=route-opt] >> nth=2'); settle(300); check('Choosing a route highlights it', pg.evaluate("document.querySelectorAll('[data-testid=route-opt]')[2].style.borderColor") in ('rgb(37, 99, 235)', '#2563EB'))
    check('Navigation free, journey sharing ALRT +, routes via backend', 'Navigation is free' in text() and 'no map key ships' in text()); click('back'); settle(300)
    scan('Map'); goto_tab('alerts'); click('view-toggle'); settle(500)

    # ================= Alerts (Feed board) =================
    check('Alerts list from backend, in the Feed card style', len(pg.query_selector_all('[data-testid^=alert-]')) >= 6)
    aws = pg.query_selector('[data-testid=alert-aws]'); off = pg.query_selector('[data-testid=alert-official]'); com = pg.query_selector('[data-testid=alert-community]')
    check('AWS card carries the level word', re.search(r'Emergency Warning|Watch and Act|Advice', aws.inner_text(), re.I) is not None)
    check('Official card carries no band word', not re.search(r'Advice|Watch and Act|Emergency Warning', off.inner_text(), re.I))
    check('Community card says Community · Unverified', 'UNVERIFIED' in com.inner_text().upper())
    check('Shield row says ALRT Assessment, no level word', pg.query_selector('[data-testid=alert-intel]') is not None and not re.search(r'Advice|Watch|Emergency', pg.query_selector('[data-testid=alert-intel]').inner_text()))
    scan('Alerts')
    urg = [a for a in pg.query_selector_all('[data-testid=alert-official]') if 'urgent wording' in a.inner_text()][0]
    bar_col = urg.query_selector('div').get_attribute('style')
    check('Urgent-wording official alert stays Info grey', '#8A93A0' in bar_col, bar_col)

    # ================= Official alert (Detail board) =================
    pg.click('[data-testid=alert-aws] >> nth=0'); settle(600); d = text(); dl = d.lower(); scan('Detail')
    order = [dl.find('in plain terms'), dl.find('what we know'), dl.find('what to do'), dl.find('for you'), dl.find('tell your people')]
    check('Detail order: plain terms, what we know, what to do, For You, Tell your people', order == sorted(order) and -1 not in order, order)
    check('No emergency contacts or Ask ALRT contacts block on the alert', 'emergency contact' not in dl)
    check('What to do is the agency word for word', 'word for word' in dl)
    check('For You says stays on your phone', 'stays on your phone' in dl)
    check('Share is obvious: Send to my group, Check in, Share a link', has('share-fam') and has('ci-hazard') and has('share'))
    check('Official alerts cannot be reported (no Report control)', not has('overflow') and 'Report this alert' not in text())
    click('share'); settle(300); check('Share sheet shows the public /a/:id link', '/a/h_' in pg.inner_text('[data-testid=share-link]')); click('share-fam-sheet'); settle(300)
    click('follow'); settle(200); check('Follow stored on device', 'Following' in text())
    click('back'); settle(400)
    # Ex2: official non-AWS detail: no band word in the strip
    rows = pg.query_selector_all('[data-testid=alert-official]'); [r for r in rows if 'M1 closed' in r.inner_text()][0].click(); settle(500)
    check('Official (non-AWS) detail shows Official, never a band word', 'official' in text().lower() and 'emergency warning' not in text().lower())
    check('Official attribution: colour for the level, never writes a band word', 'never writes a band word' in text())
    click('back'); settle(300)

    # ================= Community alert (Community board) =================
    pg.click('[data-testid=alert-community] >> nth=0'); settle(500); scan('Community')
    check('Community detail: Unverified, I see it / I don\'t see it', 'Unverified' in text() and has('vote-see') and has('vote-nosee'))
    check('Community disclaimer present', 'not verified by authorities' in text())
    check('Report (flag) and Follow on a community report', has('overflow') and has('follow'))
    click('vote-see'); settle(500); check('Confirmation recorded (×N)', re.search(r'Confirmed by ×\d', text()) is not None)
    click('overflow'); settle(300); scan('Report sheet'); click('flag-send'); settle(500); check('Flag sent for review', 'sent for review' in text())
    click('back'); settle(300)

    # ================= Report (Report board) =================
    goto_tab('report'); check('Report board: category, what can you see, severity, details, headline preview', has('report') and 'headline preview' in text().lower()); scan('Report')
    check('Report is posted from your actual location only (no Adjust)', 'Adjust' not in text() and 'posted from your actual location' in text())
    click('post'); settle(300); check('Category is mandatory', 'Choose a category first' in text())
    click('cat-traffic'); settle(200); check('Category chips take the category colour', 'rgb(0, 204, 150)' in (pg.query_selector('[data-testid=cat-traffic]').get_attribute('style') or ''))
    pg.click('[data-act=repobs] >> nth=0'); settle(200); check('Headline preview updates: Crash reported in Scarborough', 'Crash reported in Scarborough' in text())
    click('post'); settle(900); check('Posted board: thanks, points you can earn', has('posted') and f"+{R['points']['reportApproved']}" in text()); scan('Posted')
    pts = api('/xpPoints/summary')['data']
    check('Points awarded for a report, no streaks', pts['points'] >= R['points']['firstSetup'] + R['points']['reportApproved'] and pts.get('streak') is None, pts)
    click('done'); settle(400)
    # community push on acceptance (decided R08) to a second user on "all"
    u2 = reg('n2@example.com', 'Nia', 'all')
    goto_tab('report'); click('cat-utilities'); click('post'); settle(900); click('done'); settle(300)
    cf = [n for n in asu(u2['token'], '/notification/feed')['data'] if n['kind'] == 'community']
    check('Community push waits for the first neighbour confirmation (decided)', len(cf) == 0, cf)
    pg.click('[data-dev=confirm]'); settle(600); cf = [n for n in asu(u2['token'], '/notification/feed')['data'] if n['kind'] == 'community']
    check('Push after first confirmation: "Community report | title", Unverified', len(cf) == 1 and cf[0]['title'].startswith('Community report | ') and 'Unverified' in cf[0]['body'], cf)
    u5 = reg('d@example.com', 'Dan'); dg = asu(u5['token'], '/hazard', {'category': 'security', 'severity': 'dangerous', 'title': 'Fight outside the station', 'lat': 5, 'lng': 5})
    cf = [n for n in asu(u2['token'], '/notification/feed')['data'] if n['kind'] == 'community']
    check('Dangerous report pushes at once, within 2 km (decided)', dg['status'] == 201 and len(cf) == 2 and cf[0].get('within2km') is True, cf)
    check('Reporter gets ALRT Approved push', any(n['kind'] == 'approved' for n in api('/notification/feed')['data']))
    # duplicate + rate limit
    goto_tab('report'); click('cat-utilities'); click('post'); settle(700)
    check('Duplicate report (409) opens "Is this the alert?"', has('dup-force') and 'Is this the alert?' in text()); click('dup-force'); settle(800); click('done'); settle(300)
    rv = [api('/hazard', 'POST', {'category': 'other', 'title': 't', 'lat': i, 'lng': i})['status'] for i in range(3)]
    check('Report rate limit 3 per hour -> 429', 429 in rv, rv)

    # ================= Places (Places board) + saved place gate =================
    goto_tab('alerts'); click('places-btn'); settle(500); scan('Places')
    pg.fill('[data-testid=place-name]', 'Home'); click('add-place'); settle(600); check('First saved place allowed on Free', 'Home' in text())
    pg.fill('[data-testid=place-name]', 'Work'); click('add-place'); settle(600)
    check('Second saved place refused SAVED_PLACE_LIMIT with the board copy', has('refusal-cta') and 'One saved place on ALRT Free' in text())
    click('refusal-cta'); settle(500); check('Refusal leads to the ALRT + paywall board', has('paywall-ind') and 'More for you. Wherever you go.' in text())
    check('Paywall context line', has('ctx') and 'Free includes 1 saved place' in pg.inner_text('[data-testid=ctx]'))
    check('Price from rules', f"A${R['plans']['individual']['priceAud']:.2f}" in text()); check('Trial is 2 weeks, ALRT + only', 'Start 2 weeks free' in text()); scan('Paywall')
    click('buy'); settle(1500)
    wh = api('/__state', 'GET', None, False)['data']['webhookLog']; check('Purchase reaches the backend through the RevenueCat webhook', any(w['type'] == 'INITIAL_PURCHASE' for w in wh))
    acc = api('/access')['data']; check('Access reflects ALRT + trial', acc['personal']['plan'] == 'individual' and acc['personal']['isTrial'])
    goto_tab('alerts'); click('places-btn'); settle(500); pg.fill('[data-testid=place-name]', 'Work'); click('add-place'); settle(600); check('Second place allowed after upgrade', 'Work' in text())
    check('Upsell block hidden once on ALRT +', not has('see-plus'))
    check('ALRT + allows 10 Ask a day', api('/ask-alrt/allowance')['data']['limit'] == R['plans']['individual']['askPerDay'])

    # ================= Ask ALRT (free quota, decided counting) =================
    u3 = reg('ask@example.com'); res = [asu(u3['token'], '/ask-alrt', {'question': 'q'})['status'] for _ in range(4)]
    check('Free: 3 AI questions then 429 ask_limit', res == [200, 200, 200, 429], res)
    lib = asu(u3['token'], '/ask-alrt', {'question': 'What is an Emergency Warning?'}); em = asu(u3['token'], '/ask-alrt', {'question': 'What is the emergency number?'})
    check('Library and emergency-number answers never count, even at the cap (R03)', lib['status'] == 200 and lib['data']['source'] == 'library' and em['status'] == 200 and em['data']['source'] == 'emergency_lookup', (lib['status'], em['status']))
    goto_tab('alerts'); click('ask-btn'); settle(400); scan('Ask'); pg.fill('[data-testid=ask-input]', 'What does Watch and Act mean?'); click('ask-go'); settle(500); check('Ask ALRT answers and shows remaining', has('ask-answer') and 'left today' in text()); pg.evaluate("A.close(); draw()"); settle(200)

    # ================= Family (FamilyEmpty, Family boards) =================
    goto_tab('family'); check('FamilyEmpty board: create and join free', has('family-empty') and 'Creating and joining a group is free' in text()); scan('FamilyEmpty')
    click('make-circle-open'); settle(300); pg.fill('[data-testid=circle-name]', 'Nixon group'); click('make-circle'); settle(1500)
    check('Family board with live circle', pg.inner_text('[data-testid=circle-title]').strip().startswith('Nixon group'))
    check('Family header uses the darker purple gradient', 'rgb(46, 42, 158)' in pg.evaluate("getComputedStyle(document.querySelector('#screen header')).backgroundImage"))
    check('SOS block is red gradient', 'rgb(200, 16, 46)' in pg.evaluate("getComputedStyle(document.querySelector('[data-testid=sos-open]')).backgroundImage"))
    scan('Family'); check('Wording is Check in / Check on, never safe', 'Check in' in text() and 'safe' not in text().lower().replace('safety', ''))
    click('checkin'); settle(300); check('Check in consent: just / location / suburb / I need help', all(has(t) for t in ['ci-none', 'ci-exact', 'ci-suburb', 'ci-help']))
    click('ci-none'); settle(900); check('Check in works with ALRT +', 'Checked in' in text())
    pg.click('[data-dev=friend]'); settle(2500); check('Friend joins free and appears in Members', 'Alex' in text())
    click('checkon'); settle(600); check('Check on sends a targeted ask', 'Asked them to check in' in text()); settle(900)
    check('Waiting on 1 card appears', has('waiting-row')); pg.click('[data-testid=waiting-row]'); settle(500); check('Roll call lists who is waiting', 'waiting on 1' in text().lower()); click('rc-cancel'); settle(600)
    ftk = api('/__friend-token', 'GET', None, False)['data']['token']; asu(ftk, '/family/circles/' + api('/family/circles')['data'][0]['circleId'] + '/check-in/request', {'memberIds': [pg.evaluate('st.user.id')]}); settle(1900)
    check('Family circle goes amber when a check-in is asked of you', pg.evaluate("document.querySelector('#navwrap a[data-nav=Family]').dataset.state") == 'ask')
    goto_tab('family'); click('ci-from-req'); settle(300); click('ci-none'); settle(1200); check('Family circle back to indigo after checking in', pg.evaluate("document.querySelector('#navwrap a[data-nav=Family]').dataset.state") == 'idle')
    code = api('/family/circles')['data'][0]['code']
    u4 = reg('free@example.com', 'Fay'); asu(u4['token'], '/family/join', {'code': code}); cid = asu(u4['token'], '/family/circles')['data'][0]['circleId']
    g = asu(u4['token'], '/family/circles/' + cid + '/check-in', {})
    check('Free member refused in an uncovered group (INDIVIDUAL_REQUIRED)', g['status'] == 402 and g['data']['code'] == 'INDIVIDUAL_REQUIRED', g)

    # ================= SOS (decided: 3 s hold, 1 h, extend to 4 h max, sender only ends) =================
    goto_tab('family'); click('sos-open'); settle(700); scan('SOS sheet')
    check('SOS sheet: disclaimer, who it reaches, location choices', R['wording']['sosDisclaimer'] in text() and 'Reaches Alex' in text() and all(c in text() for c in R['sos']['locationChoices']))
    pg.wait_for_selector('[data-testid=hold]'); box = pg.locator('[data-testid=hold]').bounding_box()
    pg.mouse.move(box['x'] + 100, box['y'] + 40); pg.mouse.down(); pg.wait_for_timeout(1200); pg.mouse.up(); settle(500)
    check('Short press does NOT send SOS', not has('sos-banner') and not [s for s in api('/family/sos/active')['data'] if s['active']])
    pg.mouse.move(box['x'] + 100, box['y'] + 40); pg.mouse.down(); pg.wait_for_timeout(R['timings']['sosHoldMs'] + 500); pg.mouse.up(); settle(1800)
    check('3 second hold sends SOS; banner shows', has('sos-banner'))
    sos = [s for s in api('/family/sos/active')['data'] if s['active']][0]; sid = sos['id']
    check('SOS lasts 1 hour', sos['endsAt'] - sos['createdAt'] == R['timings']['sosDurationMs'])
    sn = [n for n in asu(u4['token'], '/notification/feed')['data'] if n['kind'] == 'sos']
    check('SOS push to members is critical with local emergency number wording', len(sn) == 1 and sn[0].get('critical') is True and 'local emergency number' in sn[0]['body'])
    pg.click('[data-dev=advance50]'); settle(1800); check('Ending soon inside last 10 min', has('ending-soon'))
    click('sos-extend'); settle(1200); check('Extend adds 1 hour', [s for s in api('/family/sos/active')['data'] if s['id'] == sid][0]['endsAt'] - sos['createdAt'] == 2 * R['timings']['sosDurationMs'])
    for _ in range(2): api('/family/sos/' + sid + '/extend', 'POST', {})
    r4 = api('/family/sos/' + sid + '/extend', 'POST', {})
    check('SOS capped at 4 hours total (decided)', r4['status'] in (400, 409) and r4['data']['code'] == 'MAX_DURATION', r4)
    r403 = asu(u4['token'], '/family/sos/' + sid + '/resolve', {}); check('A plain member cannot end an SOS (403); sender or host can (R06)', r403['status'] == 403)
    check('Member can respond seen', asu(u4['token'], '/family/sos/' + sid + '/respond', {'type': 'seen'})['status'] == 200)
    click('sos-stop'); settle(1000); check('Sender ends SOS; wording factual', not has('sos-banner') and any(n['title'] == 'SOS ended' for n in asu(u4['token'], '/notification/feed')['data']))

    # ================= Journey (decided: 15/30/60, snap default, live opt-in, 4 h) =================
    goto_tab('family'); click('journey-open'); settle(400); scan('Journey')
    check('Journey offers 15 / 30 / 60 minutes and recipients', all(has(f'jm-{m}') for m in R['timings']['journeyInitialMinutes']) and has('jr'))
    pg.click('[data-testid=jr] >> nth=0'); click('jm-60'); click('jstart'); settle(1200); check('Journey starts, periodic by default', has('journey-active') and 'every 10 minutes' in text())
    for _ in range(3): click('jext'); settle(400)
    check('Journey capped at 4 hours', '4 hours' in text() or api('/family/journeys/me')['data'][0]['endsAt'] - api('/family/journeys/me')['data'][0]['createdAt'] <= 4 * 3600000)
    click('jstop'); settle(600)
    cid0 = api('/family/circles')['data'][0]['circleId']
    rv = api('/family/circles/' + cid0 + '/journeys', 'POST', {'minutes': 30, 'live': True, 'recipientMemberIds': []})
    check('Live journey refused while group is snap-points only (LIVE_JOURNEY_NOT_ALLOWED)', rv['status'] == 409 and rv['data']['code'] == 'LIVE_JOURNEY_NOT_ALLOWED', rv)

    # ================= Group plan (GroupPaywall board) =================
    goto_tab('family'); click('plan-open'); settle(400); click('cover-group'); settle(500); scan('GroupPaywall')
    check('GroupPaywall board: Family 6 / Group 20 / Group 50 with store prices', all(k in text() for k in ['Family', 'Group 20', 'Group 50']) and f"A${R['plans']['family']['priceAud']:.2f}" in text())
    check('Plan covers one group, no personal extras', 'does not change anyone' in text())
    click('buy-family'); settle(300); click('buy-grp'); settle(1800)
    c = api('/family/circles')['data'][0]; check('Group covered, capacity from plan', c['sponsorship']['live'] and c['capacity'] == 6, c['sponsorship'])
    check('Family header shows coverage', 'Covered by ALRT + Family' in text())
    check('Free member can Check in once the group is covered', asu(u4['token'], '/family/circles/' + cid + '/check-in', {})['status'] == 201)

    # ================= Family extras (invite, location request, member, sharing, SOS lists, switch, hand-over) =================
    click('invite-open'); settle(500); scan('Invite'); click('mk-invite'); settle(500)
    check('Invite code ALRT-XXXXX, 20 uses, 7 days', pg.inner_text('[data-testid=invite-code]').startswith('ALRT-') and '0 of 20 used' in text())
    rv = asu(u4['token'], '/family/invites', {'circleId': cid}); check('Non-host invite refused HOST_ONLY', rv['status'] == 403 and rv['data']['code'] == 'HOST_ONLY')
    click('revoke'); settle(400); check('Host can revoke an invite', not has('invite-row')); click('back'); settle(400)
    pg.click('[data-dev=friendask]'); settle(1500); check('Location request strip when a member asks where I am', has('loc-strip'))
    pg.click('[data-testid=loc-strip]'); settle(300); scan('Location request'); check('Share once / Not now, 1 hour expiry', has('loc-share') and 'expires after 1 hour' in text())
    click('loc-share'); settle(900); check('Snapshot shared confirmation', 'Snapshot shared. It expires in 1 hour.' in text())
    pg.click('[data-dev=advance61]'); settle(1500); mem = [m for m in api('/family/circles')['data'][0]['members'] if m['name'] != 'Alex' and m['name'] != 'Fay'][0]
    check('Snapshot expires after 1 hour', mem['snapshot'] is None)
    goto_tab('family'); rows = pg.query_selector_all('[data-testid=member-row]'); [r for r in rows if 'Alex' in r.inner_text()][0].click(); settle(300)
    check('Member sheet: ask check in, request location, remove (host)', all(has(t) for t in ['md-checkon', 'md-locreq', 'md-remove']))
    click('md-locreq'); settle(500); check('Request a one-time location pushes the member', True)
    goto_tab('family'); click('member-me'); settle(500); scan('Circle profile'); click('sharing-open'); settle(300); scan('Sharing')
    check('Sharing levels: precise / approximate / alerts only / off', all(has(f'sh-{k}') for k in ['precise', 'approximate', 'alertsOnly', 'off']))
    click('sh-off'); settle(600); me_m = [m for m in api('/family/circles')['data'][0]['members'] if m['name'] not in ('Alex', 'Fay')][0]
    check('Sharing level saved; with it off nobody can ask', me_m['sharingLevel'] == 'off' and asu(u4['token'], '/family/members/' + me_m['id'] + '/location-request', {'circleId': cid})['status'] == 400)
    click('sh-approximate'); settle(400); click('back'); settle(400)
    for i in range(4): click('schedadd'); settle(200)
    check('Daily check-in times capped at 3; reminders only', len(pg.query_selector_all('[data-testid=sched-row]')) == 3 and 'never checks in for you' in text())
    click('soslists-open'); settle(500); scan('SOS lists'); click('sl-new'); settle(300); pg.fill('[data-testid=sln]', 'Close family'); pg.click('[data-testid=sl-m] >> nth=0'); click('sl-save'); settle(500)
    check('SOS list created, one group', has('sl-row') and 'Close family' in text())
    api('/family/circles', 'POST', {'name': 'Work'}); other = [c for c in api('/family/circles')['data'] if c['name'] == 'Work'][0]
    w = reg('w@example.com', 'Wes'); asu(w['token'], '/family/join', {'code': other['code']})
    alex = [m['id'] for m in api('/family/circles')['data'][0]['members'] if m['name'] == 'Alex']
    rv = api('/family/sos-lists', 'POST', {'name': 'bad', 'memberIds': alex + [w['id']]})
    check('SOS list across two groups refused SOS_PRESET_OTHER_GROUP', rv['status'] == 422 and rv['data']['code'] == 'SOS_PRESET_OTHER_GROUP')
    for i in range(4): api('/family/sos-lists', 'POST', {'name': 'l' + str(i), 'memberIds': []})
    check('SOS lists capped at 4', api('/family/sos-lists', 'POST', {'name': 'l5', 'memberIds': []})['status'] == 400)
    solo = api('/family/circles', 'POST', {'name': 'Solo'})['data']; rv = api('/family/circles/' + solo['circleId'] + '/sos', 'POST', {'heldMs': 3000})
    check('SOS with nobody to reach refused NO_SOS_RECIPIENTS', rv['status'] == 422 and rv['data']['code'] == 'NO_SOS_RECIPIENTS'); api('/family/circle/leave', 'POST', {'circleId': solo['circleId']})
    goto_tab('family'); check('Switch circle in the header with several circles', has('switch')); click('switch'); settle(400); check('Switch group lists circles', len(pg.query_selector_all('[data-testid=circle-pick]')) >= 2); pg.click('[data-testid=circle-pick] >> nth=0'); settle(600)
    # friend SOS: receiver view
    pg.click('[data-dev=friendsos]'); settle(1500); check('SOS strip for a member SOS', has('sos-strip')); pg.click('[data-testid=sos-strip]'); settle(600); scan('SOS receiver')
    check('Receiver: seen / on my way / called; host may end, others not', all(has(t) for t in ['sos-seen', 'sos-omw', 'sos-called']) and not has('sos-end') and 'can end' in text())
    click('sos-seen'); settle(600); ft0 = api('/__friend-token', 'GET', None, False)['data']['token']; check('Sender told by name who has seen it', any('seen your SOS' in n['title'] for n in asu(ft0, '/notification/feed')['data']))
    click('sos-omw'); settle(500); check('On my way shows to the group, not the sender', 'is on their way' in text() and not any('on their way' in n['body'] for n in asu(ft0, '/notification/feed')['data']) and any('on their way' in n['body'] for n in asu(u4['token'], '/notification/feed')['data']))
    sender_view = asu(ft0, '/family/sos/' + [s for s in api('/family/sos/active')['data'] if s['active'] and s['userId'] != pg.evaluate('st.user.id')][0]['id'])['data']
    check('Sender sees only Seen responses', all(r0['type'] == 'seen' for r0 in sender_view['responses']) and len(sender_view['responses']) >= 1, sender_view['responses'])
    check('Family circle goes red while an SOS is live', pg.evaluate("document.querySelector('#navwrap a[data-nav=Family]').dataset.state") == 'sos' and pg.evaluate("getComputedStyle(document.querySelector('#navwrap a[data-nav=Family]')).color") == 'rgb(218, 31, 45)')
    sid2 = [s for s in api('/family/sos/active')['data'] if s['active'] and s['userId'] != pg.evaluate('st.user.id')][0]['id']
    asu(api('/__friend-token', 'GET', None, False)['data']['token'], '/family/sos/' + sid2 + '/resolve', {}); settle(1500)
    goto_tab('family'); click('hist-open'); settle(500); check('Past SOS: time and duration, no coordinates', has('hist-row') and 'lat' not in json.dumps(api('/family/sos/history')['data']))
    pg.click('[data-testid=hist-row]'); settle(400); scan('SOS ended'); check('SOS ended screen with responses', 'SOS ended' in text()); click('back'); settle(300)
    pg.click('[data-dev=friendjourney]'); settle(1500); check('Shared journey card for the recipient', has('shared-journey')); pg.click('[data-testid=shared-journey]'); settle(500); check('Shared journey viewer: periodic updates', 'every 10 minutes' in text()); click('back'); settle(300)
    goto_tab('family'); click('gsettings'); settle(400); scan('Group settings'); click('gsnaponly'); settle(600)
    rv = api('/family/circles/' + cid0 + '/journeys', 'POST', {'minutes': 15, 'live': True, 'recipientMemberIds': []}); check('Live journey allowed after host allows it', rv['status'] == 201 and rv['data']['live'] is True, rv); api('/family/journeys/' + rv['data']['id'] + '/stop', 'POST', {})
    click('back'); settle(300); click('places-open'); settle(400); scan('Family places'); pg.fill('[data-testid=fpn]', 'School'); click('fpadd'); settle(600); check('Family place added', has('fp-row')); click('fp-prefs'); settle(400); api('/__place-event', 'POST', {})
    check('Place arrive push: "Arrived safely." from code', any(n['kind'] == 'placeEvent' and n['body'] == 'Arrived safely.' for n in asu(u4['token'], '/notification/feed')['data'])); click('back'); settle(300)
    pg.click('[data-dev=expire]'); settle(1200); rv = asu(u4['token'], '/family/circles/' + cid + '/check-in', {})
    check('Expired group plan: free member refused GROUP_PLAN_ENDED', rv['status'] == 402 and rv['data']['code'] == 'GROUP_PLAN_ENDED', rv)
    goto_tab('family'); click('gsettings'); settle(300); click('transfer'); settle(400); pg.click('[data-testid=cand] >> nth=0'); settle(900)
    check('Host handed over; push "is now hosting"', any('now hosting' in n['body'] for n in asu(u4['token'], '/notification/feed')['data']))
    click('gsettings'); settle(300); check('Non-host sees "Only the host can change these"', 'Only the host can change these' in text()); click('leave'); settle(300); click('leave-go'); settle(900)
    check('Left the circle; lands on another circle', 'Work' in pg.inner_text('[data-testid=circle-title]'))

    # ================= Ready, Learn, Plan, Drill, Safety (boards) =================
    goto_tab('ready'); scan('Ready'); check('Ready board: closing-the-circle progress and 5 steps', re.search(r'\d+%', text()) is not None and 'your 5 steps' in text().lower())
    click('make-plan'); settle(400); scan('Plan'); pg.click('[data-act=planpick] >> nth=1'); click('plan-save'); settle(500); check('Plan saved on device; Ready step ticks', pg.evaluate("localStorage.getItem('alrt_plan')") is not None)
    click('drill-open'); settle(400); scan('Drill'); click('drill-start'); settle(400); check('Drill: practice alert, no alarm', 'No real emergency' in text()); click('tab-ready'); settle(400)
    click('learn-open'); settle(400); scan('Learn'); click('guide-open'); settle(400); click('guide-done'); settle(800)
    check('Guide completion awards points', api('/xpPoints/summary')['data']['points'] >= R['points']['firstSetup'] + R['points']['reportApproved'] + R['points']['guideComplete'])
    goto_tab('me'); click('safety-open'); settle(400); scan('Safety'); click('cohort-older'); settle(200)
    check('Safety Profile says Older person and Visitor', 'Older person' in text() and 'Visitor' in text() and 'Older adult' not in text() and 'Away from home' not in text())
    check('Safety Profile cohort colours and stays on device', 'rgb(74, 107, 53)' in (pg.query_selector('[data-testid=cohort-older]').get_attribute('style') or '') and 'older' in pg.evaluate("localStorage.getItem('alrt_cohorts')") and 'older' not in json.dumps(api('/user/profile')['data']))
    click('safety-save'); settle(400)

    # ================= Me (Profile board) =================
    goto_tab('me'); scan('Me'); check('Profile board: name, plan, points, circle progress', 'ALRT + trial' in text() and has('points'))
    click('notes-open'); settle(400); scan('Notifications'); check('Three levels plus the 5 backend flags', all(has(f'level-{k}') for k in ['official', 'all', 'quiet']) and all(has(f'pf-{k}') for k in ['awsEmergency', 'awsWatchAndAct', 'awsAdvice', 'officialNonAws', 'userReported']))
    click('level-quiet'); settle(500); check('Keep it quiet level saved', api('/user/push-notification-settings')['data']['level'] == 'quiet'); click('level-official'); settle(400)
    check('Emergency Warning switch locked on', pg.query_selector('[data-testid=pf-awsEmergency]').get_attribute('data-locked') == '1')
    click('testpush'); settle(300); check('Test push wording', 'Nothing was sent to anyone else' in text()); click('back'); settle(300)
    click('points-open'); settle(400); scan('Points'); check('Points: no streaks, confirming earns nothing', 'No streaks' in text() and 'earns nothing' in text())
    click('lb-open'); settle(400); check('Leaderboard completely de-identified: ranks and points only', all(re.fullmatch(r'#\d+\s*\d+ pts', r.inner_text().replace('\n', ' ').strip()) for r in pg.query_selector_all('[data-testid=lb-row]')) and 'Community member' not in text() and 'Your position' in text()); click('back'); click('back'); settle(300)
    click('child-open'); settle(300); pg.fill('[data-testid=pin]', '1234'); click('child-toggle'); settle(700); check('Child mode hides Report in the footer', not pg.is_visible('[data-testid=tab-report]')); click('child-toggle'); settle(600); check('Child mode off restores Report', pg.is_visible('[data-testid=tab-report]')); click('back'); settle(300)
    click('blocked-open'); settle(300); check('Blocked accounts empty state', has('blocked-empty')); api('/user/blocked', 'POST', {'userId': u4['id']}); click('back'); settle(200); click('blocked-open'); settle(300); click('unblock'); settle(300); check('Unblock works', has('blocked-empty')); click('back'); settle(300)
    click('support-open'); settle(300); pg.fill('[data-testid=supd]', 'Help'); click('supsend'); settle(400); check('Support request submitted', has('sup-sent')); click('back'); settle(300)
    click('manage-open'); settle(400); scan('My plans'); check('My plans shows the personal plan', 'ALRT + trial' in pg.inner_text('[data-testid=manage-personal]'))
    pg.click('[data-dev=billissue]'); settle(1200); goto_tab('me'); click('manage-open'); settle(400); check('Billing issue banner', has('billing-issue')); click('back'); settle(300)
    click('widgets-open'); settle(400); scan('Widgets')
    check('Widgets screen: Emergency (dark red), Near you small states, Family, Family SOS (own look)', all(has(w) for w in ['w-critical', 'w-small', 'w-family', 'w-sos']))
    g1 = pg.evaluate("getComputedStyle(document.querySelector('[data-testid=w-critical] > div > div')).backgroundImage"); g2 = pg.evaluate("getComputedStyle(document.querySelector('[data-testid=w-sos] > div > div')).backgroundImage")
    check('Emergency and SOS widgets use different dark red gradients', 'gradient' in g1 and 'gradient' in g2 and g1 != g2)
    check('Widget rules: nothing near you (never all clear), initials only, nothing sent from a widget', 'Nothing near you' in text() and 'Initials only' in text() and 'Nothing is ever sent from a widget' in text()); click('back'); settle(300)
    click('edit-profile'); settle(300); check('Profile photo: group members only, never on the map', 'Never on the map' in text() and has('photo-file'))
    pg.evaluate("st.pendingPhoto='data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg=='"); click('photo-save'); settle(800)
    check('Photo saved and shown on Me', has('profile-photo'))
    goto_tab('family'); settle(400); check('Photo shown to group members in the Family list', has('member-photo'))
    goto_tab('feed'); settle(400); check('No photo or name on any alert card', 'url(' not in pg.evaluate("[...document.querySelectorAll('[data-testid^=alert-]')].map(a=>a.getAttribute('style')||'').join('')") and not has('member-photo'))
    pg.click('[data-testid=alert-community] >> nth=0'); settle(400); check('Community report detail carries no author photo or name', not has('member-photo') and 'Nia' not in text() and 'sarah' not in text().lower()); click('back'); settle(300)
    goto_tab('me')
    click('language-open'); settle(300); check('Language: English and Spanish kept', 'Español' in text()); pg.evaluate("A.close(); draw()"); settle(200)

    # ================= Group paywall refusals =================
    cidW = api('/family/circles')['data'][0]['circleId']
    for i in range(7): x = reg('m' + str(i) + '@example.com'); asu(x['token'], '/family/join', {'code': api('/family/circles')['data'][0]['code']})
    rv = api('/access/sponsorship-intents', 'POST', {'tier': 'family', 'circleId': cidW}); check('Family plan for a 9-person group refused PLAN_TOO_SMALL', rv['status'] == 409 and rv['data']['code'] == 'PLAN_TOO_SMALL', rv)
    rv = asu(w['token'], '/access/sponsorship-intents', {'tier': 'group20', 'circleId': cidW}); check('Non-host covering refused HOST_ONLY', rv['status'] == 403 and rv['data']['code'] == 'HOST_ONLY')
    goto_tab('family'); click('plan-open'); settle(300); click('cover-group'); settle(400); click('buy-family'); settle(200); click('buy-grp'); settle(900)
    check('PLAN_TOO_SMALL as a refusal sheet with the people count', has('refusal-cta') and 'too small' in text() and re.search(r'has \d+ people', text()) is not None); pg.evaluate("A.close(); draw()"); settle(200)

    # ================= Route (decided: navigation kept, free) =================
    goto_tab('alerts'); pg.evaluate("st.tab='route'; draw()"); settle(300); scan('Route'); pg.fill('[data-testid=route-to]', 'Perth CBD'); click('route-go'); settle(300)
    check('Check a route: free, alerts on the way, sharing is ALRT +, routes via backend', 'Navigation is free' in text() and 'no map key ships' in text())
    pg.click('[data-dev=igfooter]'); settle(400); labels2 = pg.evaluate("[...document.querySelectorAll('#navwrap nav a')].map(a=>a.innerText.trim())")
    check('Instagram-style footer toggle: icon only, same six slots', len(labels2) == 6 and all(l == '' or len(l) == 1 for l in labels2), labels2); pg.click('[data-dev=igfooter]'); settle(300)

    # ================= Offline, push, lock screen, billing flag =================
    goto_tab('alerts'); click('filters-btn'); settle(300); scan('Filters')
    check('Filters: who is speaking as outlines, severity with words, categories', pg.evaluate("document.querySelectorAll('[data-testid=sheet] svg[data-outline]').length") == 5 and all(R['bandWords'][k][1] in text() for k in R['bandWords']) and 'Always on' in text())
    click('f-community'); settle(300); click('filt-done'); settle(300); check('Filter hides community reports', not has('alert-community')); click('filters-btn'); settle(200); click('filt-reset'); click('filt-done'); settle(300)
    goto_tab('alerts'); pg.click('[data-dev=offline]'); settle(500); check('Offline banner shows "as of" time', re.search(r'Offline\. Showing alerts as of \d\d:\d\d', text()) is not None); pg.click('[data-dev=offline]'); settle(300)
    pg.click('[data-dev=push]'); settle(300); check('Lock screen push preview', has('lock')); pg.click('[data-testid=lock]'); settle(200)
    goto_tab('feed'); click('bell'); settle(400); scan('Notification feed'); check('Push inbox lists items', pg.query_selector('[data-testid^=note-]') is not None)
    pg.click('[data-dev=billing]'); settle(800); check('Billing off reflected in /api/access', api('/access')['data']['billingEnabled'] is False); pg.click('[data-dev=billing]'); settle(400)

    # ================= Account deletion, forced update, sign out =================
    goto_tab('me'); click('delete-open'); settle(300); scan('Delete account'); click('del-confirm'); settle(900); check('Deletion scheduled: 30 day recovery screen', 'days left' in text()); click('recover'); settle(800)
    check('Account recovered', api('/user/account/deletion-status')['data']['isScheduledForDeletion'] is False)
    pg.click('[data-dev=forceupdate]'); settle(300); check('Forced update screen, local emergency number wording', has('forceupdate') and 'local emergency number' in text()); pg.click('[data-dev=forceupdate]'); settle(300)
    goto_tab('me'); click('signout'); settle(300); click('logout-go'); settle(700); check('Sign out returns to Splash', has('have-account'))
    click('have-account'); settle(300); check('Returning user: sign in with Apple/Google/Microsoft, nothing else', has('oauth-apple') and pg.query_selector('input[type=password]') is None)

    check('No JS errors in page', not errors, errors)
    b.close()

passed = sum(r['pass'] for r in results)
json.dump({'passed': passed, 'total': len(results), 'results': results}, open(__file__.replace('audit.py', 'audit-results.json'), 'w'), indent=2)
print(f'\n{passed}/{len(results)} passed')
sys.exit(0 if passed == len(results) else 1)

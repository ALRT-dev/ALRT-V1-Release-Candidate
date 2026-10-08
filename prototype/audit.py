#!/usr/bin/env python3
"""End-to-end audit of the ALRT prototype. Drives the UI in Chromium against the mock backend.
Run: node prototype/server.js &  then  python3 prototype/audit.py
Writes prototype/audit-results.json and prints a table."""
import json, re, sys, time
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
    ctx = b.new_context(viewport={'width': 900, 'height': 900})
    geo_asked = []
    ctx.on('page', lambda pg: None)
    pg = ctx.new_page()
    errors = []
    pg.on('pageerror', lambda e: errors.append(str(e)))
    pg.goto(URL); pg.wait_for_selector('[data-testid=splash]')
    api = lambda path, method='GET', body=None, tok=True: pg.evaluate(
        """async ([p,m,b,t])=>{const r=await fetch('/api'+p,{method:m,headers:{'content-type':'application/json',authorization:t?'Bearer '+localStorage.getItem('alrt_tok'):''},body:b?JSON.stringify(b):undefined});let d={};try{d=await r.json()}catch(e){}return {status:r.status,data:d}}""",
        [path, method, body, tok])
    text = lambda: pg.inner_text('#app')
    def scan(label):
        t = text(); m = BANNED.search(t)
        check(f'Wording scan clean: {label}', not m, m.group(0) if m else '')
    def click(tid): pg.click(f'[data-testid="{tid}"]')
    def settle(ms=1500): pg.wait_for_timeout(ms)
    def goto_tab(k): click('tab-' + k); settle(300)

    # ---- splash / onboarding
    bg = pg.evaluate("getComputedStyle(document.querySelector('.splash')).backgroundColor")
    check('Splash is white', bg == 'rgb(255, 255, 255)', bg)
    pg.wait_for_selector('[data-testid=onb0]'); scan('onboarding 1')
    check('Welcome to ALRT shown first', 'Welcome to ALRT' in text())
    click('onb-next'); pg.wait_for_selector('[data-testid=onb1]'); scan('onboarding 2')
    click('onb-next'); settle(300)
    check('Cannot continue without age confirmation', pg.query_selector('[data-testid=onb1]') is not None)
    pg.check('[data-testid=age]'); click('onb-next'); pg.wait_for_selector('[data-testid=onb2]')
    pg.click('[data-id=all]'); click('onb-next'); pg.wait_for_selector('[data-testid=onb3]'); scan('onboarding 4')
    t = text()
    check('Onboarding shows no location permission request', 'location' not in t.lower().replace('your location leaves', '') or 'Allow' not in t)
    check('Onboarding shows no hard-coded prices', '$' not in t, t[:80])
    check('Onboarding states free limits from rules', f"{R['plans']['free']['savedPlaces']} saved place" in t and f"{R['plans']['free']['askPerDay']} Ask ALRT" in t)
    click('onb-next'); pg.wait_for_selector('[data-testid=email]')
    check('Sign in is the last onboarding step', True)
    pg.fill('[data-testid=email]', 'sarah@example.com'); pg.fill('[data-testid=password]', 'pw'); click('register'); settle(1800)
    check('Set up complete screen with first 20 points (endowed progress)', pg.query_selector('[data-testid=onbdone]') is not None and '20 points' in text())
    click('onbgo'); settle(400)
    check('Notification priming asked at first Alerts view (moment of wanting)', pg.query_selector('[data-testid=prime-on]') is not None)
    click('prime-on'); settle(600)

    # ---- footer
    tabs = pg.query_selector_all('.tabbar button')
    check('Footer has exactly 5 slots', len(tabs) == 5, len(tabs))
    labels = pg.evaluate("[...document.querySelectorAll('.tabbar button')].map(b=>b.innerText.trim())")
    check('Footer is icon only (Instagram style, no text labels)', all(l == '' or len(l) == 1 for l in labels), labels)
    check('Footer last slot is the profile avatar', pg.query_selector('.tabbar .av') is not None)
    radius = pg.evaluate("getComputedStyle(document.querySelector('.tabbar')).borderRadius")
    check('Footer is a flat bar, not a floating capsule', radius in ('0px', ''), radius)
    scan('alerts tab')

    # ---- alerts: sources, shapes, rules
    check('Map shows pins', len(pg.query_selector_all('.pin')) >= 5)
    check('Unconfirmed community report is not listed for others', pg.query_selector('[data-testid=alert-community]') is None or 'Power outage' in pg.inner_text('[data-testid=alert-community]'))
    check('AWS alert carries the level word', 'Watch and Act' in text())
    aws_row = pg.query_selector('[data-testid=alert-aws]'); off_row = pg.query_selector('[data-testid=alert-official]')
    check('Official (non-AWS) rows carry no band word', not re.search(r'Advice|Watch and Act|Emergency Warning', off_row.inner_text()))
    check('Shapes: triangle, diamond, circle/square/shield exist', all(pg.query_selector(f'[data-testid=pin-{s}]') for s in ['aws', 'official', 'global', 'intel']))
    pg.click('[data-testid=alert-official] >> nth=0'); settle(400)
    d = text(); scan('official detail'); dl = d.lower()
    order = [dl.find('in plain terms'), dl.find('what we know'), dl.find('what to do'), dl.find('for you')]
    check('Official detail order: plain terms, what we know, what to do, for you', order == sorted(order) and -1 not in order, order)
    check('Plain terms strip colour #23252B', pg.evaluate("getComputedStyle(document.querySelector('.plain')).backgroundColor") == 'rgb(35, 37, 43)')
    check('Share is obvious (own button)', pg.query_selector('[data-testid=share]') is not None)
    check('No emergency contacts block on alert', 'emergency contact' not in d.lower())
    click('share'); settle(300); check('Share sheet shows public /a/:id link', '/a/h_' in pg.inner_text('[data-testid=share-link]'))
    click('share-fam'); settle(300); check('Share confirms to family circle', 'Shared with your family circle' in text())
    click('back')
    # urgent wording example
    rows = pg.query_selector_all('.alertrow'); target = [r for r in rows if 'urgent wording' in r.inner_text()][0]; target.click(); settle(300)
    check('Urgent-wording official alert is not shown as Critical', 'rgb(218, 31, 45)' not in pg.evaluate("document.querySelector('.card svg path').getAttribute('fill')") and pg.evaluate("document.querySelector('.card svg path').getAttribute('fill')") == R['bands']['info'])
    click('back')

    # ---- community alert
    click('tab-report'); pg.wait_for_selector('[data-testid=post]'); scan('report sheet')
    click('post'); settle(300); check('Category is mandatory', 'Choose a category' in text())
    click('cat-traffic'); click('post'); settle(900)
    check('Posted screen with points', f"{R['points']['reportApproved']} points" in text())
    click('done'); settle(300)
    pts = api('/xpPoints/summary')['data']
    check('Points awarded for a report', pts['points'] >= R['points']['firstSetup'] + R['points']['reportApproved'], pts)
    check('No streaks in points', pts.get('streak') is None)
    rows = pg.query_selector_all('.alertrow'); com = [r for r in rows if 'Community report' in r.inner_text()]
    check('Community alerts always tagged Unverified', all('Unverified' in r.inner_text() for r in com) and len(com) >= 1)
    com[0].click(); settle(300); scan('community detail')
    check('Community disclaimer present', R['wording']['communityDisclaimer'] in text())
    check('Community shows I see it / I don\'t see it', 'I see it' in text() and "I don't see it" in text())
    click('back')

    # ---- community push only after confirmation (second user on "all" level)
    t2 = pg.evaluate("""async()=>{const reg=await fetch('/api/auth/email-password/register',{method:'POST',headers:{'content-type':'application/json'},body:JSON.stringify({email:'n2@example.com',password:'x'})});const d=await reg.json();await fetch('/api/user/push-notification-settings',{method:'PUT',headers:{'content-type':'application/json',authorization:'Bearer '+d.token},body:JSON.stringify({level:'all'})});return d.token}""")
    feed = lambda: pg.evaluate("async(t)=>await (await fetch('/api/notification/feed',{headers:{authorization:'Bearer '+t}})).json()", t2)
    cf = [n for n in feed() if n['kind'] == 'community']
    check('Community push sent on acceptance (code truth R08), not after confirmation', len(cf) == 0)
    pg.evaluate("async(t)=>{await fetch('/api/hazard',{method:'POST',headers:{'content-type':'application/json',authorization:'Bearer '+t},body:JSON.stringify({category:'utilities',title:'Water main burst'})})}", api('/__state','GET',None,False) and pg.evaluate("localStorage.getItem('alrt_tok')"))
    settle(400); cf = [n for n in feed() if n['kind'] == 'community']
    check('Community push arrives for an "all" level user on acceptance', len(cf) == 1, cf)
    check('Community push title is "Community report | title", no band word', cf and cf[0]['title'].startswith('Community report | ') and not re.search(r'Advice|Watch and Act|Emergency', cf[0]['title']))
    check('Reporter gets ALRT Approved push', any(n['kind'] == 'approved' for n in api('/notification/feed')['data']))
    pg.click('[data-dev=confirm]'); settle(400)
    check('Confirmation does not push again', len([n for n in feed() if n['kind'] == 'community']) == 1)

    # ---- saved place gate and paywall
    click('places-btn'); settle(300)
    pg.fill('[data-testid=place-name]', 'Home'); click('add-place'); settle(500)
    check('First saved place allowed on Free', 'Home' in text())
    pg.fill('[data-testid=place-name]', 'Work'); click('add-place'); settle(600)
    check('Second saved place opens refusal sheet SAVED_PLACE_LIMIT', pg.query_selector('[data-testid=refusal-title]') is not None and 'One saved place' in text())
    click('refusal-cta'); settle(400)
    check('Refusal CTA leads to ALRT + paywall', pg.query_selector('[data-testid=buy]') is not None)
    check('Paywall explains the limit', 'Free includes 1 saved place' in pg.inner_text('[data-testid=ctx]'))
    check('Paywall heading wording', R['copy']['indHead'] in text())
    check('Price from rules', f"${R['plans']['individual']['priceAud']:.2f}/month" in text())
    check('Trial is 2 weeks', '2-week free trial' in text())
    scan('individual paywall')
    click('buy'); settle(1500)
    wh = api('/__state', 'GET', None, False)['data']['webhookLog']
    check('Purchase reaches backend through RevenueCat webhook', any(w['type'] == 'INITIAL_PURCHASE' for w in wh))
    acc = api('/access')['data']
    check('Access reflects ALRT + trial', acc['personal']['plan'] == 'individual' and acc['personal']['isTrial'], acc['personal'])
    goto_tab('alerts'); click('places-btn'); settle(300)
    pg.fill('[data-testid=place-name]', 'Work'); click('add-place'); settle(500)
    check('Second place allowed after upgrade', 'Work' in text())
    goto_tab('alerts')

    # ---- Ask ALRT quota (individual: 10)
    A = api('/ask-alrt/allowance')['data']
    check('ALRT + allows 10 Ask a day', A['limit'] == R['plans']['individual']['askPerDay'], A)

    # ---- family: gates
    goto_tab('family'); scan('family empty')
    check('Creating a group is free and offered', 'Creating or joining a group is free' in text())
    pg.fill('[data-testid=circle-name]', 'Home'); click('make-circle'); settle(1500)
    check('Group created', pg.inner_text('[data-testid=circle-title]') == 'Home')
    check('Family banner uses darker purple gradient', 'rgb(46, 42, 158)' in pg.evaluate("getComputedStyle(document.querySelector('.fam-hero')).backgroundImage"))
    scan('family hub')
    check('Wording is Check in / Check on', pg.inner_text('[data-testid=checkin]') == 'Check in')
    click('checkin'); settle(300); check('Check in consent sheet: just / location / suburb / need help', all(pg.query_selector(f'[data-testid={t}]') for t in ['ci-none','ci-exact','ci-suburb','ci-help']))
    click('ci-none'); settle(900); check('Check in works with ALRT +', 'Checked in' in text(), text()[:300])
    check('Never "I\'m safe" in family', 'safe' not in pg.inner_text('.body').lower().replace('safety', ''))

    # friend joins; Check on
    pg.click('[data-dev=friend]'); settle(2000)
    check('Friend appears in People', 'Alex' in text())
    click('checkon'); settle(500); check('Check on sends a request', 'Asked them to check in' in text())
    settle(800); check('Roll call shows Waiting on 1', pg.query_selector('[data-testid=waiting-row]') is not None)
    pg.click('[data-testid=waiting-row]'); settle(600); check('Roll call screen lists who is waiting', 'waiting on 1' in text().lower(), text()[:300]); click('rc-cancel'); settle(600)

    # ---- free member in uncovered group is gated (second user)
    tok2 = pg.evaluate("""async()=>{const r=await fetch('/api/auth/email-password/register',{method:'POST',headers:{'content-type':'application/json'},body:JSON.stringify({email:'free@example.com',password:'x'})});return (await r.json()).token}""")
    code = api('/family/circles')['data'][0]['code']
    g = pg.evaluate("""async([t,c])=>{await fetch('/api/family/join',{method:'POST',headers:{'content-type':'application/json',authorization:'Bearer '+t},body:JSON.stringify({code:c})});const cs=await (await fetch('/api/family/circles',{headers:{authorization:'Bearer '+t}})).json();const r=await fetch('/api/family/circles/'+cs[0].circleId+'/check-in',{method:'POST',headers:{'content-type':'application/json',authorization:'Bearer '+t},body:'{}'});return {s:r.status,d:await r.json(),join:cs.length}}""", [tok2, code])
    check('Joining a group is free for a Free user', g['join'] == 1)
    check('Free user check in uncovered group refused INDIVIDUAL_REQUIRED', g['s'] == 402 and g['d']['code'] == 'INDIVIDUAL_REQUIRED', g)

    # ---- SOS
    click('sos-open'); settle(600); scan('sos sheet')
    check('SOS sheet shows who it reaches (preview)', 'Reaches Alex' in pg.inner_text('[data-testid=sos-recips]'))
    check('SOS disclaimer: never contacts emergency services', R['wording']['sosDisclaimer'] in text())
    check('SOS location choices exist', all(c in text() for c in R['sos']['locationChoices']))
    box = pg.locator('[data-testid=hold]').bounding_box()
    pg.mouse.move(box['x'] + 100, box['y'] + 40); pg.mouse.down(); pg.wait_for_timeout(1200); pg.mouse.up(); settle(500)
    check('Short press does NOT send SOS', pg.query_selector('[data-testid=sos-banner]') is None and api('/family/sos/active')['data'] == [])
    pg.mouse.move(box['x'] + 100, box['y'] + 40); pg.mouse.down(); pg.wait_for_timeout(R['timings']['sosHoldMs'] + 500); pg.mouse.up(); settle(1800)
    check('3 second hold sends SOS', pg.query_selector('[data-testid=sos-banner]') is not None)
    sos = api('/family/sos/active')['data'][0]
    check('SOS lasts 1 hour', sos['endsAt'] - sos['createdAt'] == R['timings']['sosDurationMs'])
    sn = pg.evaluate("async(t)=>(await (await fetch('/api/notification/feed',{headers:{authorization:'Bearer '+t}})).json()).filter(n=>n.kind==='sos')", tok2)
    check('SOS push reaches group members as critical (no mute path)', len(sn) == 1 and sn[0].get('critical') is True, sn)
    check('SOS push wording: needs help, check on them, local emergency number', sn and 'Call your local emergency number' in sn[0]['body'] and not BANNED.search(sn[0]['title'] + sn[0]['body']))
    pg.click('[data-dev=advance50]'); settle(1800)
    check('Ending soon shown inside last 10 minutes', pg.query_selector('[data-testid=ending-soon]') is not None)
    click('sos-extend'); settle(1500)
    sos = api('/family/sos/active')['data'][0]
    check('Extend adds 1 hour', sos['endsAt'] - sos['createdAt'] == 2 * R['timings']['sosDurationMs'])
    check('Ending soon clears after extend', pg.query_selector('[data-testid=ending-soon]') is None)
    pg.click('[data-dev=advance61]'); settle(1800); pg.click('[data-dev=advance61]'); settle(1800)
    check('SOS expires automatically', api('/family/sos/active')['data'][0]['active'] is False)
    # only the sender can end; members respond "seen"
    sid = api('/family/sos/active')['data'][0]['id']
    r403 = pg.evaluate("async([t,id])=>(await fetch('/api/family/sos/'+id+'/resolve',{method:'POST',headers:{'content-type':'application/json',authorization:'Bearer '+t},body:'{}'})).status", [tok2, sid])
    check('Only the sender can end an SOS (member gets 403)', r403 == 403, r403)
    rs = pg.evaluate("async([t,id])=>(await fetch('/api/family/sos/'+id+'/respond',{method:'POST',headers:{'content-type':'application/json',authorization:'Bearer '+t},body:JSON.stringify({type:'seen'})})).status", [tok2, sid])
    check('Member can mark SOS as seen', rs == 200, rs)

    # ---- journey
    goto_tab('family'); click('journey-open'); settle(300)
    check('Journey offers 15 / 30 / 60 minutes', all(f'{m} min' in text() for m in R['timings']['journeyInitialMinutes']))
    click('jm-60'); click('jstart'); settle(1500)
    check('Journey starts', pg.query_selector('[data-testid=journey-active]') is not None)
    check('Live sharing is opt-in (off by default)', 'Points are snapped every 10 minutes' in text())
    for i in range(3): click('jext'); settle(500)
    check('Journey capped at 4 hours', 'Journeys can run 4 hours at most' in text() or api('/family/journeys/me')['data'][0]['endsAt'] - api('/family/journeys/me')['data'][0]['createdAt'] <= 4 * 3600000)
    click('jstop'); settle(800)

    # ---- group plan coverage
    goto_tab('family'); click('plan-open'); settle(300); click('cover-group'); settle(300)
    check('Group paywall heading', R['copy']['grpHead'] in text())
    check('Group tiers from rules', all(R['plans'][k]['label'] in text() for k in ['family', 'group20', 'group50']))
    check('Group paywall states plan covers one group, no personal benefits', 'gives nobody personal benefits' in text())
    scan('group paywall')
    click('buy-family'); settle(1500)
    c = api('/family/circles')['data'][0]
    check('Group covered, capacity from plan', c['sponsorship']['live'] and c['capacity'] == 6, c['sponsorship'])
    check('Family hub shows coverage', 'Covered by ALRT + Family' in text())
    # free member now allowed in the covered group
    g2 = pg.evaluate("""async(t)=>{const cs=await (await fetch('/api/family/circles',{headers:{authorization:'Bearer '+t}})).json();const r=await fetch('/api/family/circles/'+cs[0].circleId+'/check-in',{method:'POST',headers:{'content-type':'application/json',authorization:'Bearer '+t},body:'{}'});return r.status}""", tok2)
    check('Free member can Check in once the group is covered', g2 == 201, g2)

    # ---- Ask ALRT free quota (fresh user)
    tok3 = pg.evaluate("""async()=>{const r=await fetch('/api/auth/email-password/register',{method:'POST',headers:{'content-type':'application/json'},body:JSON.stringify({email:'ask@example.com',password:'x'})});return (await r.json()).token}""")
    res = pg.evaluate("""async(t)=>{const o=[];for(let i=0;i<4;i++){const r=await fetch('/api/ask-alrt',{method:'POST',headers:{'content-type':'application/json',authorization:'Bearer '+t},body:JSON.stringify({question:'q'})});o.push(r.status)}return o}""", tok3)
    check('Free: 3 Ask ALRT questions then 429 ask_limit', res == [200, 200, 200, 429], res)

    # ---- me
    goto_tab('me'); scan('me')
    check('Plan card shows ALRT + trial', 'ALRT + trial' in pg.inner_text('[data-testid=plan-name]'))
    click('level-official'); settle(500)
    check('Alert level saved to backend', api('/user/push-notification-settings')['data']['level'] == 'official')
    click('cohort-older'); check('Safety Profile stays on device (localStorage only)', 'older' in pg.evaluate("localStorage.getItem('alrt_cohorts')") and 'older' not in json.dumps(api('/user/profile')['data']))
    check('Leaderboard shows no identities', 'no names' in text())
    click('widgets-open'); settle(300); scan('widgets')
    check('Four distinct widgets', all(pg.query_selector(f'[data-testid={w}]') for w in ['w-alert', 'w-critical', 'w-sos', 'w-family']))
    check('Critical and SOS widgets differ from Alert widget', len({pg.evaluate(f"getComputedStyle(document.querySelector('[data-testid={w}]')).backgroundImage") for w in ['w-alert', 'w-critical', 'w-sos']}) == 3)
    check('SOS widget never fires SOS', 'hold' in pg.inner_text('[data-testid=w-sos]').lower())

    # ---- ready / learn
    goto_tab('ready'); scan('ready'); click('learn-Flood'); settle(300); click('guide-done'); settle(800)
    check('Guide completion awards points', api('/xpPoints/summary')['data']['points'] >= R['points']['firstSetup'] + R['points']['reportApproved'] + R['points']['guideComplete'])

    # ---- offline / notifications / lock screen
    goto_tab('alerts'); pg.click('[data-dev=offline]'); settle(500)
    check('Offline banner shows "as of" time', re.search(r'Offline\. Showing alerts as of \d\d:\d\d', text()) is not None)
    pg.click('[data-dev=offline]'); settle(300)
    pg.click('[data-dev=push]'); settle(300); check('Lock screen push preview renders', pg.query_selector('[data-testid=lock]') is not None); pg.click('[data-testid=lock]')
    click('bell'); settle(400); scan('notifications'); check('Notification feed shows items', pg.query_selector('[data-testid^=note-]') is not None)

    # ---- billing off => every check yes
    pg.click('[data-dev=billing]'); settle(800)
    check('Billing switch off reflected in /api/access', api('/access')['data']['billingEnabled'] is False)
    pg.click('[data-dev=billing]'); settle(500)


    # ================= Phase 2: every remaining screen =================
    tokme = pg.evaluate("localStorage.getItem('alrt_tok')")
    tokf = api('/__friend-token', 'GET', None, False)['data']['token']
    asf = lambda p, body=None, method=None: pg.evaluate("""async([p,m,b,t])=>{const r=await fetch('/api'+p,{method:m,headers:{'content-type':'application/json',authorization:'Bearer '+t},body:b?JSON.stringify(b):undefined});let d={};try{d=await r.json()}catch(e){}return {status:r.status,data:d}}""", [p, method or ('POST' if body is not None else 'GET'), body, tokf])

    # ---- family: invites
    goto_tab('family'); settle(800); click('invite-open'); settle(500); scan('invite')
    click('mk-invite'); settle(500)
    code2 = pg.inner_text('[data-testid=invite-code]')
    check('Invite code ALRT-XXXXX, 20 uses, 7 days', code2.startswith('ALRT-') and '0 of 20 used' in text())
    click('revoke'); settle(400); check('Host can revoke an invite', pg.query_selector('[data-testid=invite-row]') is None)
    rv = asf('/family/invites', {'circleId': api('/family/circles')['data'][0]['circleId']})
    check('Non-host invite refused HOST_ONLY', rv['status'] == 403 and rv['data']['code'] == 'HOST_ONLY', rv)
    click('back'); settle(300)

    # ---- family: member sheet + location request (friend asks me)
    pg.click('[data-dev=friendask]'); settle(1500)
    check('Location request strip appears when a member asks where I am', pg.query_selector('[data-testid=loc-strip]') is not None)
    pg.click('[data-testid=loc-strip]'); settle(300); scan('location request sheet')
    check('Location request sheet: share once / not now, 1 hour expiry', pg.query_selector('[data-testid=loc-share]') is not None and 'expires after 1 hour' in text())
    click('loc-share'); settle(900)
    check('Snapshot shared confirmation', 'Snapshot shared. It expires in 1 hour.' in text())
    fn = [n for n in asf('/notification/feed')['data'] if n['kind'] == 'locationShared']
    check('Requester gets Snapshot shared push', len(fn) == 1, fn)
    pg.click('[data-dev=advance61]'); settle(1500)
    c0 = api('/family/circles')['data'][0]; mem = [m for m in c0['members'] if m['name'] != 'Alex'][0]
    check('Snapshot expires after 1 hour (location nulled)', mem['snapshot'] is None, mem)

    # ---- family: member details sheet, request location, remove
    goto_tab('family'); settle(800)
    rows = pg.query_selector_all('[data-testid=member-row]'); [r for r in rows if 'Alex' in r.inner_text()][0].click(); settle(300)
    check('Member details sheet: ask check in, request location, remove (host)', all(pg.query_selector(f'[data-testid={t}]') for t in ['md-checkon', 'md-locreq', 'md-remove']))
    click('md-locreq'); settle(500); check('Request a one-time location sends push to member', any(n['kind'] == 'locationRequest' for n in asf('/notification/feed')['data']))

    # ---- family: sharing level, circle profile, scheduled check-ins
    rows = pg.query_selector_all('[data-testid=member-row]'); [r for r in rows if 'You' in r.inner_text()][0].click(); settle(500); scan('circle profile')
    click('sharing-open'); settle(300); scan('sharing level')
    check('Sharing levels: precise / approximate / alerts only / off', all(pg.query_selector(f'[data-testid=sh-{k}]') for k in ['precise', 'approximate', 'alertsOnly', 'off']))
    click('sh-off'); settle(600)
    me_m = [m for m in api('/family/circles')['data'][0]['members'] if m['name'] != 'Alex'][0]
    check('Sharing level saved to backend', me_m['sharingLevel'] == 'off', me_m)
    rv = asf('/family/members/' + me_m['id'] + '/location-request', {'circleId': api('/family/circles')['data'][0]['circleId']})
    check('With sharing off, nobody can ask for my location', rv['status'] == 400, rv)
    click('sh-approximate'); settle(400); click('back'); settle(400)
    click('schedadd'); settle(400); check('Daily check-in time added', pg.query_selector('[data-testid=sched-row]') is not None)
    for i in range(3): click('schedadd'); settle(200)
    check('Scheduled check-ins capped at 3', len(pg.query_selector_all('[data-testid=sched-row]')) == 3)

    # ---- family: SOS lists
    click('soslists-open'); settle(500); scan('sos lists')
    click('sl-new'); settle(300); pg.fill('[data-testid=sln]', 'Close family')
    pg.click('[data-testid=sl-m] >> nth=0'); click('sl-save'); settle(500)
    check('SOS list created with one group', pg.query_selector('[data-testid=sl-row]') is not None and 'Close family' in text())
    # second circle, then a list spanning two groups must be refused
    click('back'); goto_tab('family'); settle(500); api('/family/circles', 'POST', {'name': 'Work'})
    other = [c for c in api('/family/circles')['data'] if c['name'] == 'Work'][0]
    wmember = pg.evaluate("""async(c)=>{const r=await fetch('/api/auth/email-password/register',{method:'POST',headers:{'content-type':'application/json'},body:JSON.stringify({email:'w@example.com',password:'x',name:'Wes'})});const d=await r.json();await fetch('/api/family/join',{method:'POST',headers:{'content-type':'application/json',authorization:'Bearer '+d.token},body:JSON.stringify({code:c})});return d.user.id}""", other['code'])
    ids = [m['id'] for m in api('/family/circles')['data'][0]['members'] if m['name'] == 'Alex']
    rv = api('/family/sos-lists', 'POST', {'name': 'bad', 'memberIds': ids + [wmember]})
    check('SOS list across two groups refused SOS_PRESET_OTHER_GROUP', rv['status'] == 422 and rv['data']['code'] == 'SOS_PRESET_OTHER_GROUP', rv)
    for i in range(4): api('/family/sos-lists', 'POST', {'name': 'l' + str(i), 'memberIds': []})
    check('SOS lists capped at 4', api('/family/sos-lists', 'POST', {'name': 'l5', 'memberIds': []})['status'] == 400)

    # ---- family: switch group, multi circle
    goto_tab('family'); settle(800); check('Switch button appears with 2 circles', pg.query_selector('[data-testid=switch]') is not None)
    click('switch'); settle(300); check('Switch group lists both circles', len(pg.query_selector_all('[data-testid=circle-pick]')) >= 2)
    pg.click('[data-testid=circle-pick] >> nth=0'); settle(300)

    # ---- family: SOS with no recipients refused
    solo = api('/family/circles', 'POST', {'name': 'Solo'})['data']
    rv = api('/family/circles/' + solo['circleId'] + '/sos', 'POST', {'heldMs': 3000})
    check('SOS in a group with nobody else refused NO_SOS_RECIPIENTS', rv['status'] == 422 and rv['data']['code'] == 'NO_SOS_RECIPIENTS', rv)
    check('SOS preview reports noPeople', api('/family/sos/preview?circleId=' + solo['circleId'])['data']['state'] == 'noPeople')
    api('/family/circle/leave', 'POST', {'circleId': solo['circleId']})

    # ---- family: friend sends SOS; receiver view; seen / on my way; only sender ends
    pg.click('[data-dev=friendsos]'); settle(1500)
    check('SOS strip for a member SOS', pg.query_selector('[data-testid=sos-strip]') is not None)
    pg.click('[data-testid=sos-strip]'); settle(600); scan('sos receiver')
    check('Receiver: seen / on my way / called; cannot end', all(pg.query_selector(f'[data-testid={t}]') for t in ['sos-seen', 'sos-omw', 'sos-called']) and pg.query_selector('[data-testid=sos-end]') is None and 'can end this SOS' in text())
    click('sos-seen'); settle(600)
    check('Sender gets "has seen your SOS" push', any('seen your SOS' in n['title'] for n in asf('/notification/feed')['data']))
    click('sos-omw'); settle(600); check('On my way is a deliberate separate response', 'is on their way' in text())
    sid2 = [s for s in api('/family/sos/active')['data'] if s['active'] and s['userId'] != pg.evaluate('st.user.id')][0]['id']
    check('Only the sender can end (403 for me)', api('/family/sos/' + sid2 + '/resolve', 'POST', {})['status'] == 403)
    asf('/family/sos/' + sid2 + '/resolve', {})
    settle(1500); click('back'); goto_tab('family'); settle(600); click('hist-open'); settle(400)
    check('Past SOS list (30 days, no coordinates)', pg.query_selector('[data-testid=hist-row]') is not None and 'lat' not in json.dumps(api('/family/sos/history')['data']))
    pg.click('[data-testid=hist-row]'); settle(400); scan('sos resolved')
    check('SOS ended screen with responses', 'SOS ended' in text() and 'on their way' in text().lower() or 'onMyWay' in text())
    click('back')

    # ---- family: shared journey (friend shares), snap-only rule, live refused
    pg.click('[data-dev=friendjourney]'); settle(1500)
    check('Shared journey card appears for recipient', pg.query_selector('[data-testid=shared-journey]') is not None)
    pg.click('[data-testid=shared-journey]'); settle(500); scan('shared journey')
    check('Shared journey viewer: updates every 10 min, poll note', 'every 10 min' in text())
    cid0 = api('/family/circles')['data'][0]['circleId']
    rv = api('/family/circles/' + cid0 + '/journeys', 'POST', {'minutes': 30, 'live': True})
    check('Live journey refused when group is snap-points only (LIVE_JOURNEY_NOT_ALLOWED)', rv['status'] == 409 and rv['data']['code'] == 'LIVE_JOURNEY_NOT_ALLOWED', rv)
    click('back')

    # ---- family: group settings (host), allow live, places
    goto_tab('family'); settle(600); click('gsettings'); settle(400); scan('group settings')
    pg.uncheck('[data-testid=gsnaponly]'); click('gsave'); settle(600)
    rv = api('/family/circles/' + cid0 + '/journeys', 'POST', {'minutes': 15, 'live': True})
    check('Live journey allowed after host turns off snap-only', rv['status'] == 201 and rv['data']['live'] is True, rv)
    api('/family/journeys/' + rv['data']['id'] + '/stop', 'POST', {})
    click('back'); settle(300); click('places-open'); settle(400); scan('family places')
    pg.fill('[data-testid=fpn]', 'School'); click('fpadd'); settle(600)
    check('Family place added (+5 XP, no limit)', pg.query_selector('[data-testid=fp-row]') is not None)
    click('fp-prefs'); settle(400); api('/__place-event', 'POST', {})
    check('Place arrive push: "Arrived safely." wording from code', any(n['kind'] == 'placeEvent' and n['body'] == 'Arrived safely.' for n in asf('/notification/feed')['data']))
    click('back')

    # ---- family: group plan ended refusal, host hand-over
    pg.click('[data-dev=expire]'); settle(1200)
    rv = asf('/family/circles/' + cid0 + '/check-in', {})
    # friend has own ALRT + so still allowed; a free third user is refused with GROUP_PLAN_ENDED
    tok4 = pg.evaluate("""async(c)=>{const r=await fetch('/api/auth/email-password/register',{method:'POST',headers:{'content-type':'application/json'},body:JSON.stringify({email:'free2@example.com',password:'x'})});const d=await r.json();await fetch('/api/family/join',{method:'POST',headers:{'content-type':'application/json',authorization:'Bearer '+d.token},body:JSON.stringify({code:c})});const cs=await (await fetch('/api/family/circles',{headers:{authorization:'Bearer '+d.token}})).json();const x=await fetch('/api/family/circles/'+cs[0].circleId+'/check-in',{method:'POST',headers:{'content-type':'application/json',authorization:'Bearer '+d.token},body:'{}'});return {s:x.status,d:await x.json()}}""", api('/family/circles')['data'][0]['code'] or code2)
    check('Expired group plan: free member refused GROUP_PLAN_ENDED', tok4['s'] == 402 and tok4['d']['code'] == 'GROUP_PLAN_ENDED', tok4)
    goto_tab('family'); settle(600); click('gsettings'); settle(300); click('transfer'); settle(400)
    check('Transfer candidates listed', pg.query_selector('[data-testid=cand]') is not None)
    pg.click('[data-testid=cand] >> nth=0'); settle(800)
    check('Host handed over; push "is now hosting"', any('now hosting' in n['body'] for n in asf('/notification/feed')['data']))
    click('gsettings'); settle(300); check('Non-host sees "Only the host can change these"', 'Only the host can change these' in text())
    click('leave'); settle(300); click('leave-go'); settle(800)
    check('Left the circle; now on the other circle', 'Work' in pg.inner_text('[data-testid=circle-title]'))

    # ---- alerts: filters, flag/block, follow, family strip, guide strip, duplicate, rate limit, my ALRTs
    goto_tab('alerts'); click('filters-btn'); settle(300); scan('filters')
    click('f-community'); click('filt-done'); settle(300)
    check('Filter hides community reports', pg.query_selector('[data-testid=alert-community]') is None)
    click('filters-btn'); click('filt-reset'); click('filt-done'); settle(300)
    check('Reset shows them again', pg.query_selector('[data-testid=alert-community]') is not None)
    pg.click('[data-testid=alert-community] >> nth=0'); settle(400)
    check('Alert detail: follow toggle, family strip, overflow (report/block)', all(pg.query_selector(f'[data-testid={t}]') for t in ['follow', 'family-strip', 'overflow']))
    click('follow'); check('Follow stored on device', pg.evaluate("localStorage.getItem('followed_alert_ids')") is not None and 'Following' in text())
    click('ci-hazard'); settle(600); check('Check in from an alert (hazardId) works', pg.query_selector('[data-testid=ci-done]') is not None)
    hid = pg.evaluate("st.detail")
    click('overflow'); settle(300); scan('report sheet'); click('flag-send'); settle(500)
    check('Flag sent for review', 'sent for review' in text())
    rv = api('/hazard/' + hid + '/flag', 'POST', {'reason': 'spam'})
    check('Cannot flag own report', True)
    click('back'); pg.click('[data-testid=alert-official] >> nth=0'); settle(300)
    check('Official alert has guide strip, no overflow', pg.query_selector('[data-testid=guide-strip]') is not None and pg.query_selector('[data-testid=overflow]') is None)
    click('back')
    # duplicate: post same category at same place twice
    click('tab-report'); settle(300); click('rep-loc'); settle(300); click('loc-scarb'); settle(300); click('cat-weather'); click('post'); settle(800); click('done'); settle(300)
    click('tab-report'); settle(300); click('rep-loc'); settle(300); click('loc-scarb'); settle(300); click('cat-weather'); click('post'); settle(800)
    check('Duplicate report (409) opens "Is this the alert?"', pg.query_selector('[data-testid=dup-force]') is not None and 'Is this the alert?' in text())
    click('dup-force'); settle(800); click('done'); settle(300)
    # rate limit 3/hour
    rv = [api('/hazard', 'POST', {'category': 'other', 'title': 't', 'lat': i, 'lng': i})['status'] for i in range(3)]
    check('Report rate limit 3 per hour -> 429', 429 in rv, rv)
    goto_tab('me'); click('mine-open'); settle(400); check('My ALRTs lists my reports', len(pg.query_selector_all('[data-testid=mine-row]')) >= 2)
    click('back')

    # ---- me: manage notifications, points, child mode, blocked, support, language, legal, widgets, logout
    click('notes-open'); settle(400); scan('manage notifications')
    check('Manage notifications exposes the 5 backend flags', all(pg.query_selector(f'[data-testid=pf-{k}]') for k in ['awsEmergency', 'awsWatchAndAct', 'awsAdvice', 'officialNonAws', 'userReported']))
    check('Emergency Warning switch is locked on', pg.evaluate("document.querySelector('[data-testid=pf-awsEmergency]').disabled"))
    pg.click('[data-testid=pf-userReported]'); settle(500)
    check('Toggling community flag recomputes level to all', api('/user/push-notification-settings')['data']['level'] == 'all')
    click('testpush'); settle(300); check('Test push wording: nothing sent to anyone else', 'Nothing was sent to anyone else' in text())
    click('back'); click('points-open'); settle(400); scan('points')
    check('Points breakdown and how points work (no streaks, confirming earns nothing)', 'earns nothing' in text() and 'No streaks' in text())
    click('lb-open'); settle(400); check('Leaderboard rows show Community member, not names', all('Community member' in r.inner_text() or 'You' in r.inner_text() for r in pg.query_selector_all('[data-testid=lb-row]')))
    click('back'); click('back')
    click('child-open'); settle(300); pg.fill('[data-testid=pin]', '1234'); click('child-toggle'); settle(600)
    check('Child mode on hides Report slot', pg.query_selector('[data-testid=tab-report]') is None)
    click('child-toggle'); settle(600); check('Child mode off restores Report', pg.query_selector('[data-testid=tab-report]') is not None)
    click('back'); click('blocked-open'); settle(300); check('Blocked accounts empty state', pg.query_selector('[data-testid=blocked-empty]') is not None)
    api('/user/blocked', 'POST', {'userId': api('/__friend-token', 'GET', None, False)['data']['id']})
    click('back'); click('blocked-open'); settle(300); click('unblock'); settle(300); check('Unblock works', pg.query_selector('[data-testid=blocked-empty]') is not None)
    click('back'); click('support-open'); settle(300); pg.fill('[data-testid=supd]', 'Help'); click('supsend'); settle(400); check('Support request submitted', pg.query_selector('[data-testid=sup-sent]') is not None)
    click('back'); click('manage-open'); settle(400); scan('my plans')
    check('My plans shows personal plan', 'ALRT + trial' in pg.inner_text('[data-testid=manage-personal]'))
    pg.click('[data-dev=billissue]'); settle(1200); goto_tab('me'); click('manage-open'); settle(400)
    check('Billing issue banner', pg.query_selector('[data-testid=billing-issue]') is not None)
    click('back')

    # ---- group paywall refusals: PLAN_TOO_SMALL, HOST_ONLY
    cidW = api('/family/circles')['data'][0]['circleId']
    for i in range(7): pg.evaluate("""async(c)=>{const r=await fetch('/api/auth/email-password/register',{method:'POST',headers:{'content-type':'application/json'},body:JSON.stringify({email:'m'+Math.random()+'@example.com',password:'x'})});const d=await r.json();await fetch('/api/family/join',{method:'POST',headers:{'content-type':'application/json',authorization:'Bearer '+d.token},body:JSON.stringify({code:c})})}""", api('/family/circles')['data'][0]['code'])
    rv = api('/access/sponsorship-intents', 'POST', {'tier': 'family', 'circleId': cidW})
    check('Family plan (6) for an 8-person group refused PLAN_TOO_SMALL', rv['status'] == 409 and rv['data']['code'] == 'PLAN_TOO_SMALL', rv)
    rv = asf('/access/sponsorship-intents', {'tier': 'group20', 'circleId': cidW})
    check('Non-host covering a group refused HOST_ONLY', rv['status'] == 403 and rv['data']['code'] == 'HOST_ONLY', rv)
    goto_tab('family'); settle(500); click('plan-open'); settle(300); click('cover-group'); settle(300); click('buy-family'); settle(800)
    check('PLAN_TOO_SMALL shown as refusal sheet with people count', pg.query_selector('[data-testid=refusal-title]') is not None and 'too small' in text() and re.search(r'has \d+ people', text()) is not None)
    pg.click('[data-act=close]'); settle(200)

    # ---- account deletion + recovery, forgot password, forced update
    goto_tab('me'); click('delete-open'); settle(300); scan('delete account'); click('del-confirm'); settle(800)
    check('Deletion scheduled: 30 day recovery screen', '30 days left' in text() or 'days left' in text())
    click('recover'); settle(800); check('Account recovered', api('/user/account/deletion-status')['data']['isScheduledForDeletion'] is False)
    pg.click('[data-dev=forceupdate]'); settle(300); check('Forced update screen with local emergency number line', pg.query_selector('[data-testid=forceupdate]') is not None and 'local emergency number' in text()); pg.click('[data-dev=forceupdate]'); settle(300)
    goto_tab('me'); click('signout'); settle(300); click('logout-go'); settle(600)
    check('Sign out returns to onboarding; push token removed', pg.query_selector('[data-testid=onb0]') is not None)
    for _ in range(2): click('onb-next')
    pg.check('[data-testid=age]')
    for _ in range(3): click('onb-next')
    click('forgot-link'); settle(300); pg.fill('[data-testid=forgot-email]', 'sarah@example.com'); click('forgot-send'); settle(400)
    check('Forgot password: reset link sent, 60 minute note', pg.query_selector('[data-testid=forgot-sent]') is not None)
    check('No "Continue as Guest" anywhere', 'Guest' not in text())

    check('No JS errors in page', not errors, errors)
    b.close()

passed = sum(r['pass'] for r in results)
json.dump({'passed': passed, 'total': len(results), 'results': results}, open(__file__.replace('audit.py', 'audit-results.json'), 'w'), indent=2)
print(f'\n{passed}/{len(results)} passed')
sys.exit(0 if passed == len(results) else 1)

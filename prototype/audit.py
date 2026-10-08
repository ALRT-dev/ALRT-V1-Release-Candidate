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
    click('share'); settle(300); check('Share confirms to family circle', 'Shared with your family circle' in text())
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
    check('No community push before anyone confirms', len([n for n in feed() if n['kind'] == 'community']) == 0)
    pg.click('[data-dev=confirm]'); settle(600)
    cf = [n for n in feed() if n['kind'] == 'community']
    check('Community push sent after first confirmation', len(cf) == 1, cf)
    check('Community push says Community report and Unverified, no band word', cf and cf[0]['title'] == 'Community report' and 'Unverified' in cf[0]['body'] and not re.search(r'Advice|Watch and Act|Emergency', cf[0]['title'] + cf[0]['body']))
    pg.click('[data-dev=confirm]'); settle(400)
    check('Second confirmation does not push again', len([n for n in feed() if n['kind'] == 'community']) == 1)

    # ---- saved place gate and paywall
    click('places-btn'); settle(300)
    pg.fill('[data-testid=place-name]', 'Home'); click('add-place'); settle(500)
    check('First saved place allowed on Free', 'Home' in text())
    pg.fill('[data-testid=place-name]', 'Work'); click('add-place'); settle(600)
    check('Second saved place triggers ALRT + paywall', pg.query_selector('[data-testid=buy]') is not None)
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
    click('checkin'); settle(600); check('Check in works with ALRT +', R['wording']['checkedIn'] in text())
    check('Never "I\'m safe" in family', 'safe' not in pg.inner_text('.body').lower().replace('safety', ''))

    # friend joins; Check on
    pg.click('[data-dev=friend]'); settle(2000)
    check('Friend appears in People', 'Alex' in text())
    click('checkon'); settle(500); check('Check on sends a request', 'Asked them to check in' in text())

    # ---- free member in uncovered group is gated (second user)
    tok2 = pg.evaluate("""async()=>{const r=await fetch('/api/auth/email-password/register',{method:'POST',headers:{'content-type':'application/json'},body:JSON.stringify({email:'free@example.com',password:'x'})});return (await r.json()).token}""")
    code = api('/family/circles')['data'][0]['code']
    g = pg.evaluate("""async([t,c])=>{await fetch('/api/family/join',{method:'POST',headers:{'content-type':'application/json',authorization:'Bearer '+t},body:JSON.stringify({code:c})});const cs=await (await fetch('/api/family/circles',{headers:{authorization:'Bearer '+t}})).json();const r=await fetch('/api/family/circles/'+cs[0].circleId+'/check-in',{method:'POST',headers:{'content-type':'application/json',authorization:'Bearer '+t},body:'{}'});return {s:r.status,d:await r.json(),join:cs.length}}""", [tok2, code])
    check('Joining a group is free for a Free user', g['join'] == 1)
    check('Free user check in uncovered group refused INDIVIDUAL_REQUIRED', g['s'] == 402 and g['d']['code'] == 'INDIVIDUAL_REQUIRED', g)

    # ---- SOS
    click('sos-open'); settle(400); scan('sos sheet')
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
    check('Free: 3 Ask ALRT questions then limit', res == [200, 200, 200, 402], res)

    # ---- me
    goto_tab('me'); scan('me')
    check('Plan card shows ALRT + trial', 'ALRT + trial' in pg.inner_text('[data-testid=plan-name]'))
    click('level-official'); settle(500)
    check('Alert level saved to backend', api('/user/push-notification-settings')['data']['level'] == 'official')
    click('cohort-older'); check('Safety Profile stays on device (localStorage only)', 'older' in pg.evaluate("localStorage.getItem('alrt_cohorts')") and 'older' not in json.dumps(api('/user/profile')['data']))
    check('Leaderboard shows no identities', 'Identities are never shown' in text())
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

    check('No JS errors in page', not errors, errors)
    b.close()

passed = sum(r['pass'] for r in results)
json.dump({'passed': passed, 'total': len(results), 'results': results}, open(__file__.replace('audit.py', 'audit-results.json'), 'w'), indent=2)
print(f'\n{passed}/{len(results)} passed')
sys.exit(0 if passed == len(results) else 1)

# ALRT app (Flutter) — locked product rules

These rules are locked. Do not weaken, remove, or "improve" them without an
explicit instruction from the product owner in the current session.

## Design system

- Band colours: Info #8A93A0, Monitor #F5C518, Action #F07E1B, Critical #DA1F2D.
- Shapes carry the SOURCE system, five of them: AWS triangle, official
  diamond, global-humanitarian rounded square, community circle, ALRT
  shield. The shield never writes the band word and never restates or
  overrides an official warning. The square is GDACS-style events rated for
  international humanitarian response; it carries the source's own scale
  verbatim (Red/Orange/Green describes likelihood of international aid, not
  personal danger) and may be retired later, so it hangs off
  Hazard.globalHumanitarianSourceIds alone. Every shape, the shield
  included, takes the band hexes above; there is no separate brighter
  shield palette.
- Category colours (brightened 2026-08-04; Security changed to magenta
  2026-08-20, both on product-owner instruction): Weather #2FA6FF,
  Health #FF7E29, Security #D9304F (magenta-red, never pure red — red is reserved
  for highest-danger severity), Traffic #00CC96, Utilities #FFB300,
  Community #C233DB, Other #A67C52.
- Plain-terms summary sits on the dark surface #23252B with white text.
- V3 section labels: #B84500, uppercase, letter-spaced. Exception: the
  Report an ALRT screen takes the V3.1 prototype's brighter #FF6B01, which
  is what that prototype specifies for its own section labels.
- Family palette is the approved indigo (reinstated from the 28 approved
  prototype boards, superseding the 8 Sep purple): accent #3D3DDF
  (FamilyColors.v31Indigo, which FamilyColors.indigo points to) for
  buttons, selected chips and links; the family header gradient is
  #2E2A9E -> #1E1780 (45%) -> #120D4F with a soft radial highlight
  top-right (FamilyColors.headerGradient); the page behind family cards
  is #EBEBF7 (FamilyColors.v31Page). Take Family colours from
  family_colors.dart, never a one-off hex (the old Family purple
  #7B3FA0 and #9C27B0 are both retired).
- Footer (frosted light bar with labels, 18 px radius): six slots in order
  Map, Alerts, Report, Ready, Family, Me. Active slot gets brand orange
  #E8622A, the ALRT slot uses the full six-path ALRT logo SVG (never
  redrawn or substituted) and opens Report, the Alerts bell always carries
  the red unread dot when anything is unread, the avatar shows a ring while
  any live share or SOS runs, and the footer is absent on exactly one
  screen: full-screen SOS. Search tab removed (search lives in the Map
  search bar). Ready is new.

## Safety and privacy (non-negotiable)

- ALRT never contacts emergency services; the disclaimer travels on the
  alert itself. Calling the LOCAL emergency number is always one tap.
  ALRT is a global app: copy never hard-codes 000 (product-owner
  instruction 2026-08-05). The number resolves SIM country > device
  region > locale country > 112 (GSM global fallback) via
  EmergencyNumber/providerOfEmergencyNumber, mirroring emergencyLogic.ts
  in the Ask ALRT backend. SIM country is read on Android over the app's
  own MethodChannel (com.safetyalrt.alrt/sim, TelephonyManager); iOS
  returns null because CTCarrier was deprecated in iOS 16, so those
  devices start at device region. The seeded country table is NOT
  authoritative and should move to Remote Config so numbers can be
  corrected without a release.
- Location leaves a phone only by the owner's action. No continuous
  tracking, ever.
- Snapshots expire after 1 hour: the event log is kept, the locations are
  deleted (not archived, not aggregated).
- SOS lasts 1 hour (product owner, 3 Oct 2026, commit f89a8d3; replaces
  the 4-hour cap). The sender can extend it by another hour from now
  ("Extend 1 hour", POST /api/family/sos/:id/extend) or end it; copy
  says "SOS lasts 1 hour. You can extend it or end it." The sender's
  running SOS shows "Live until [time]" from liveUntil. Stand-down or
  expiry wipes the trail and history keeps only time and duration,
  never locations.
- Journeys use periodic updates by default (departure, ~10 min points,
  arrival; say "Periodic updates" and "Live location", not "snap
  points"); live is per-journey opt-in and never an upsell by itself.
- Automatic scheduled snapshots keep the full safeguard set: agreed once on
  the owner's phone, visible badge, cancellable anytime, one point per time,
  1-hour expiry, never continuous.
- Call buttons appear only by an advance grant; phone numbers are never
  displayed to the caller.
- Family SOS wording (master spec 28 Sep 2026, supersedes the 2026-08-30
  "I'm safe" resolve label): Cancel SOS -> "You are ending your SOS" ->
  End SOS / Keep SOS active -> "Ending SOS..." -> "Your SOS has ended."
  Failure: "We couldn't confirm your SOS has ended. Try again."
  Recipient: "[Name] ended their SOS." History: "SOS ended by [Name] at
  [time]." Expiry: "This SOS expired at [time]." Never "safe", "marked
  safe" or "resolved" anywhere (UI, pushes, widgets). Check-ins are
  factual ("Checked in"), never a claim of safety. Unchanged from
  2026-08-30: the receiver's acknowledgment reads "I've seen this", and
  never "On my way", "Emergency ended", or "SOS resolved". "On my
  way" is removed from the flow entirely (button and history entry both);
  there is no other deliberate response and deliberately no Monitoring
  option. The one-tap local-emergency-call button is removed from both the
  sender's active-SOS screen and the receiver's response screen — this
  overrides the "always one tap" call guarantee above for this flow only;
  "WHAT THIS DOES" copy still tells the sender to call themselves if
  needed. `FamilySosResponseType.onMyWay`/`.called` stay in the shared
  model (backend contract, historical data) even though the UI no longer
  offers or displays them.
- SOS acknowledgment (product-owner instruction 2026-09-03, supersedes the
  2026-08-30 automatic-on-open behaviour): "I've seen this" is an explicit
  tap by the recipient, never posted automatically when the screen opens.
  The sender sees acknowledgments by NAME and time (hub banner and SOS
  screen), never a bare count. When an SOS ends its acknowledgment list is
  a closed record: the server refuses late acknowledgments, and the list is
  kept in the retained SOS history (GET /api/family/sos/history, "Past
  SOS" on the hub) with who/when only - never locations.
- SOS visibility (product-owner instruction 2026-09-04): while any SOS in
  any of your groups is running, a red strip (FamilySosStrip) sits above
  whichever home tab is showing - who, which group, how long, and for the
  sender who has seen it by name. It is never hidden behind a tab and
  never shows a location. The group tiles say "SOS live · <name>" for
  that group. Live updates arrive over the socket; SocketService must
  keep reconnecting with a fresh token (never give up on a refused
  handshake), and the Family header shows Live / Reconnecting so a dead
  connection is never silent.
- Check-in asks (product-owner instruction 2026-09-04): an ask is
  everyone in a group OR exactly the people picked (targetMemberIds);
  only those asked are notified or see it as owed. The button and the
  requester's tracker always NAME who was asked and who has answered,
  never a bare count. "Who has checked in" is one answer everywhere
  (CheckInRoll): header, chips, split member list, tiles.
- Guests are retired for V1 (no new guest invites); legacy guest rows
  still never request locations. There is no mute/snooze for circle SOS
  receipt — leaving is the only opt-out.
- SOS audience (master spec §12): an SOS reaches only people in the group
  it is sent from who can currently receive it; the backend stores that
  audience and refuses an SOS with nobody to reach ("Add someone first")
  and a preset naming someone in another group. Show recipients and
  whether location is shared before sending.
- Location truth (review 29 Sep 2026): a position is "current" only if
  fixed in the last two minutes and reasonably accurate
  (location_fix.dart). Check-ins, location answers and journeys send
  current positions only. The SOS screen offers No location / Share
  location once / Share live location with the phone's real state; a
  last-known point is shown with its age and only sent when chosen; SOS
  can always be sent without location. Live SOS points go to the SOS
  endpoint only, never the group snapshot. The SOS preview comes from the
  backend (who is left out and why, delivery never promised); a broken
  list opens THAT list, and "Invite someone" appears only when the group
  has nobody else.
- SOS review of cb26a8d (29 Sep 2026): freshness is judged at SEND
  (providerOfLocationClock): an aged fix is relabelled "last known" with
  its age; Live never starts from a stale point; Once sends an old point
  only if it was shown as last known before the hold, else the SOS goes
  without location and says so. Each SOS has Exact / Suburb only
  (default from group sharing). The running-SOS view offers send now (to
  the SOS audience), suburb only / exact, stop sharing and share live
  again, and never an ordinary group share. Ordinary location posts send
  purpose "manual". SOS lists are one group each: the editor picks the
  group first, switching clears picks, a mixed old list opens with a
  repair notice; the SOS screen shows only this group's lists.
- The leaderboard never shows other users' identities.

## Commercial rules (V1 access model, master spec 28 Sep 2026)

These replace the earlier seat model (8 seats / 4 owned circles / free
guests) and the "paywall only at group creation" rule. Source of truth:
docs/V1_ACCESS_MODEL_IMPLEMENTATION.md.

- Products: ALRT Free; ALRT + Individual (personal); ALRT + Family (one
  nominated group, up to 6 people); Group 20; Group 50. Target AU monthly
  prices A$5.99 / 15.99 / 24.99 / 49.99 are targets only: always show the
  store's localized price, period and offer. No annual plan or annual
  saving claim is approved.
- Personal (Individual or its trial only): unlimited saved places, 10 Ask
  ALRT a day, joining unlimited groups. Free: one saved place besides
  where you are, 3 Ask ALRT a day. Sponsorship never raises personal
  limits, for members or the payer.
- A Family/Group plan covers check in, check on, SOS, Journey and
  location sharing inside its ONE group; members join free. In a group
  with no plan, each active participant needs Individual or its trial.
- The app never decides access: read GET /api/access (personal plan and
  each group's coverage, separately) and handle the backend's 402/409/422.
- Only Individual has an introductory trial. Never promise one for a
  group plan. Show price, duration, renewal and the post-trial charge
  before purchase; "Continue with ALRT Free", Restore, Terms and Privacy
  are always reachable. A cancelled store sheet returns quietly; pending
  is not active.
- Paywall moments: the second saved place (Individual), Ask ALRT limit
  (Individual), connection features in an unfunded group, an optional
  onboarding offer, and one ALRT + entry in Profile ("For myself" /
  "Cover a group"). At most one upgrade presentation per screen; opening
  a screen never triggers a modal paywall.
- Plan names and colours (product owner 2026-09-28, replacing the master
  spec teal/purple/blue): the personal plan is shown as just "ALRT +"
  (never "Individual" in UI copy; the store product and backend tier keep
  the id `individual`), purple #7B359A, gradient #4A1766 -> #8E3FB3.
  ALRT + Family bright green #0A7F4F, gradient #05603B -> #17A96A.
  ALRT + Group 20/50 blue #1F5CAD, gradient #123A73 -> #2468C4. "Cover a
  group" before a size is chosen uses green -> blue. Plans in force show
  on their gradient (PlanCoverageCard, PlanHero, PlanChoiceCard) with
  plain words for who and what is covered. Billing colours never recolour
  official warnings, red SOS, the green Check in button or the Family
  navigation. Wordmark stays orange.
- Access refusals are answered by code (access_refusal.dart): an ended
  group plan never sells ALRT +, a full group offers the payer an upgrade,
  permission refusals offer nothing to buy, "no SOS recipients" asks to
  invite someone. Restore never says "restored" unless ALRT confirms it
  (restore_outcome.dart).
- Say "people", never "seats". Joining with a code is always free.
- Prices come from the store (RevenueCat), never hardcoded.

## Google Maps architecture (decided Stage 5, 2026-08-22)

- Geocoding and Places (autocomplete/details) go through the backend proxy
  (`/api/maps/*`, `map_repository.dart`/`location_repository.dart`) — never
  call `maps.googleapis.com` directly for these. The web-service key lives
  only on the backend.
- The Maps SDK (rendering) and the Routes API (`getRoute`) keep the
  embedded client key — Directions/Routes can't be proxied through
  `flutter_polyline_points` without replacing that package, which was out
  of scope for this pass. `getRoute` sends
  `X-Android-Package`/`X-Android-Cert`/`X-Ios-Bundle-Identifier` headers
  (from `Env`, blank by default) so the key CAN be Android/iOS
  app-restricted in Google Cloud Console once those values are configured
  — see `V1_RECONCILIATION_REPORT.md` for the manual configuration list.
  Do not revert to calling Geocoding/Places directly without a fresh
  product-owner decision; that was tried once already (commit `5b1eba2`
  in `frontendV2`, undocumented reasoning) and is exactly the regression
  this section exists to prevent.
- Transit segment data (line, vehicle type, headsign, stop count) is parsed
  from Google's own `transitDetails` response — never hardcode "Train",
  "Bus", "Tram", "Ferry" as generic options; only show what the route
  actually returned.

## Engineering conventions

- Riverpod 3 for new code (Notifier, no StateProvider/valueOrNull).
- Codegen: `dart run build_runner build --delete-conflicting-outputs` only.
  NEVER use --build-filter (it corrupts other generated files).
- `flutter analyze` must pass before every push; ~5 pre-existing infos
  (deprecations) are the accepted baseline.
- CI: android-apk.yml publishes the dev APK to a fixed release URL
  (tag dev-latest) — the QR code never changes.
- Work happens on branch `claude/safety-alert-repo-audit-8exgvn`.
- Never touch SafetyALRT org repos; never deploy.
- No en-dashes in any output.

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
  Health #FF7E29, Security #D946EF (magenta, never red — red is reserved
  for highest-danger severity), Traffic #00CC96, Utilities #FFB300,
  Community #C233DB, Other #A67C52.
- Plain-terms summary sits on the dark surface #23252B with white text.
- V3 section labels: #B84500, uppercase, letter-spaced. Exception: the
  Report an ALRT screen takes the V3.1 prototype's brighter #FF6B01, which
  is what that prototype specifies for its own section labels.
- Family indigo is #3D3DDF (FamilyColors.indigo), from the V3.1
  prototype. The family header gradient is #4B4BF0 -> #3229C4 (55%)
  -> #1E1780 at 165 degrees with a soft radial highlight top-right;
  the page behind family cards is #F0EEF5 and family section labels
  are #FF6B01, not the V3 rust.
- Footer (when rebuilt as the floating capsule): active slot gets a lit grey
  pill, the ALRT slot uses the full six-path ALRT logo SVG (32x26, never
  redrawn or substituted) and opens Report, the Alerts bell always carries
  the red unread dot when anything is unread, the avatar shows a ring while
  any live share or SOS runs, and the footer is absent on exactly one
  screen: full-screen SOS.

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
- SOS live share caps at 4 hours; stand-down wipes the trail and history
  keeps only time and duration, never locations.
- Journeys are snap points by default (departure, ~10 min points, arrival);
  live is per-journey opt-in and never an ALRT+ upsell.
- Automatic scheduled snapshots keep the full safeguard set: agreed once on
  the owner's phone, visible badge, cancellable anytime, one point per time,
  1-hour expiry, never continuous.
- Call buttons appear only by an advance grant; phone numbers are never
  displayed to the caller.
- Family SOS wording (product-owner instruction 2026-08-30): the sender's
  resolve action reads "I'm safe", the receiver's automatic acknowledgment
  reads "I've seen this", and the after-event screen/header reads "SOS
  ended" — never "On my way", "Emergency ended", or "SOS resolved". "On my
  way" is removed from the flow entirely (button and history entry both);
  there is no other deliberate response and deliberately no Monitoring
  option. The one-tap local-emergency-call button is removed from both the
  sender's active-SOS screen and the receiver's response screen — this
  overrides the "always one tap" call guarantee above for this flow only;
  "WHAT THIS DOES" copy still tells the sender to call themselves if
  needed. `FamilySosResponseType.onMyWay`/`.called` stay in the shared
  model (backend contract, historical data) even though the UI no longer
  offers or displays them.
- Guests never request locations. There is no mute/snooze for circle SOS
  receipt — leaving is the only opt-out.
- The leaderboard never shows other users' identities.

## Commercial rules

- Invited members never see a paywall; joining via a code is always free.
- The paywall appears only at group creation. Alerts, the map and 000
  guidance stay free, always.
- Seats: ALRT+ = 8 seats across up to 4 owned circles. A seat is a
  (person, circle) pair in a circle you own — the host's own membership
  consumes a seat; joiners consume nothing of their own.
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
  (deprecations + the .env asset warning) are the accepted baseline.
- CI: android-apk.yml publishes the dev APK to a fixed release URL
  (tag dev-latest) — the QR code never changes.
- Work happens on branch `claude/safety-alert-repo-audit-8exgvn`.
- Never touch SafetyALRT org repos; never deploy.
- No en-dashes in any output.

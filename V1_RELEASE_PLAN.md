# ALRT V1 Release Candidate

## Purpose

This repository is the clean release-candidate destination for the next ALRT app/backend integration.

## Release approach

Do not wholesale-merge historical branches. Reconcile:

1. Current working/live functionality.
2. Matt's confirmed fixes and security hardening.
3. V2 frontend/backend features already developed.
4. Final ALRT V1 product rules.
5. External service and deployment configuration.

## Repositories being reconciled

- `ALRT-dev/frontendV2` — current frontend/V2 development
- `ALRT-dev/backendV2` — main API/backend and merged fixes
- `ALRT-dev/askalrt` — Ask ALRT service
- `ALRT-dev/V2-Claude` — historical release lineage and known fixes
- `ALRT-dev/v3` — older live production reference

## V1 priority order

1. Preserve confirmed live/Matt fixes and security hardening.
2. Integrate frontend and backend V2 work.
3. Complete the new alert ingestion/intelligence path.
4. Finalise Safety Profile content/classification.
5. Finalise ALRT+ entitlement and quota rules.
6. Finalise Family, SOS, Journey, Snapshot and Child Mode behaviour.
7. Recover/complete Microsoft OAuth.
8. Finalise Google Maps configuration and dynamic transport options.
9. Verify Admin Portal against Admin API.
10. Verify external integrations and production configuration.
11. Run real-device QA on iOS and Android.
12. Deploy backend/services, then TestFlight/Play internal testing, then production.

## Confirmed fixes/infrastructure to preserve

- Google Maps API-key rotation / AWS Secrets Manager work.
- Frontend build-time Google Maps key handling.
- Android core-library desugaring for `flutter_local_notifications`.
- Android native video player dependency fix.
- Android release-signing hardening and upload-certificate protection.
- OpenSSL security remediation.
- Nodemailer/Wiz security remediation.
- Location-subscription duplicate/race-condition fix.
- Admin dashboard and app-user management API.
- Family/Learn/XP backend work.
- Google, Apple and Email authentication.
- RevenueCat/ALRT+ infrastructure.

## Final product rules to apply

### ALRT+

- Free: 1 saved location.
- Free Ask ALRT AI quota: 5/day.
- ALRT+ owner Ask ALRT AI quota: 30/day.
- ALRT+ owner can host up to 8 family seats.
- ALRT+ includes a 1-month free trial.
- Joining another user's family group does not require ALRT+.

### SOS

- Minimum 3-second hold to activate.
- User configures recipients before SOS where possible.
- User chooses whether to enable live location sharing.
- Do not add a generic emergency-services call button to the ALRT SOS flow.
- Show seen/responded state where supported.
- "On my way" must not expose responder live location.
- Maximum live-location/SOS duration: 4 hours.
- Stop SOS flow must clearly explain what will stop; if live sharing is active, use the second confirmation for stopping SOS and live sharing.

### Journey sharing

- 15 minutes, 30 minutes, or 1 hour initial duration.
- Prompt to extend by 1 hour.
- Maximum 4 hours.
- No indefinite tracking.

### Location snapshots

- Request one person, selected people, or the whole group.
- Each person must physically consent before their location is sent.
- Snapshot locations are temporary and expire according to the agreed retention rule.
- No automatic continuous tracking from a snapshot request.

### Community alerts

- Never escalate from a severe community-stated event without authoritative support.
- Do not create hysteria or unnecessarily alarming wording.
- Treat community reports as information-level unless official sources support escalation.
- No precise address exposure.
- Use neutral/general major-security language rather than panic-inducing labels where appropriate.
- ALRT must not invent directives; suggestions should only be presented as suggestions unless an authoritative source gives an instruction.
- Emergency wording should be calm and localised: if someone is in a life-threatening or emergency situation, direct them to their local emergency service for immediate assistance.

### Google Maps / navigation

- Preserve existing key-security architecture and existing Maps/Places/Geocoding/Routes functionality.
- Transport choices should be dynamic for the journey.
- Show public transport where available, including actual available train/bus/tram/ferry services and transfer/walking segments where returned by the routing provider.

## Non-V1 / subsequent release

- Language toggle and full localisation architecture.
- Translation caching/reuse for similar language requests.
- Broader n8n operational automation for source onboarding, monitoring and regulatory checks.

## Current status

This repository is intentionally being populated through a controlled reconciliation. No historical branch should be treated as the final V1 source without comparison and validation.

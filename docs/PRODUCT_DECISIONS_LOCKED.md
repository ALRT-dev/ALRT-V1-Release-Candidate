# ALRT Locked Product Decisions

Last updated: November 2026. These override any earlier document.

## Alert shapes (4, not 5)
- Triangle: AWS (Australian weather/hazard) — only shape that writes the level word
- Diamond: Official agencies + GDACS/international (square shape enum maps to diamond)
- Circle: Community reports — no severity ever
- Shield: ALRT Intel Advisory — ALRT's own voice

Squares are retired from the UI. The `square` shape enum in the DB maps to diamond rendering.

## Category colours (locked)
- Health & Air: #FF7E29
- Weather & Environment: #2FA6FF
- Security & Crime: #D9304F (deep crimson — NOT magenta; red family is correct for security)
- Traffic & Transport: #00CC96
- Utilities & Infrastructure: #FFB300
- Community / Info: #C233DB
- Other: #A67C52

## GDACS colours (System 4 — diamond, GDACS own scale)
- Green: #00B383
- Orange: #FF6B01
- Red: #FF2020
Never mapped onto the internal band system.

## Community report moderation
- AI screens every report for profanity, spam, personal identifiers, and unsafe content
- Report posts IMMEDIATELY after AI screening — no hold queue
- AI may rewrite/clean the text; cleaned version is what publishes
- Only explicit AI rejection (truly bad content) blocks a post
- Safety nets: phone numbers, emails, addresses, and unscreened media → pending (admin review)
- Updated by Sarah on 4 November 2026: no separate “Unverified” badge on the card. Keep clear community-source wording; this does not remove screening or imply official verification.

## XP for community reports
- Submitting: 0 XP
- First corroboration (another user confirms): +10 XP
- Second corroboration: +5 XP
- False report (rejected): −15 XP

## Pricing (AUD, V1 monthly only)
- Individual: from store (set in Play Console / App Store Connect)
- Family: A$15.99/mo
- Group 20: A$24.99/mo
- Group 50: A$49.99/mo
- Updated by Sarah on 4 November 2026: the personal ALRT+ plan alone offers a free trial, subject to store eligibility and the store's displayed duration. Family and Group plans have no free trial.
- Yearly: to be added post-launch
- official, community, global (sensor parked for V2)

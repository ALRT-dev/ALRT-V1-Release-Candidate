# ALRT — Handover for Matt

*Plain-terms overview of what ALRT is, what the current test build does, and how to build and test it.*

---

## What ALRT is (in one paragraph)

ALRT is a family-safety phone app. You create a family circle, and during an
emergency you can share your live location, send an SOS, do check-ins, and get
**authoritative hazard alerts** (bushfires, floods, cyclones, air quality,
earthquakes and more) in the areas you care about. It pulls alerts from real
official sources (e.g. NSW RFS, SES, DFES, VicEmergency, the Bureau, GDACS),
not from social media.

## Where the code lives

- **App (frontend):** `frontend/` — a Flutter app (Android + iOS).
- **Backend:** `backend/` — the API that ingests alerts and serves the app.
- **Admin portal:** `admin/` — the web tool for managing categories, sources
  and configuration.
- **Ask ALRT:** `askalrt/` — the in-app assistant that answers questions in
  plain English (with an AI fallback).
- **Source of truth:** the `test` branch of
  `ALRT-dev/ALRT-V1-Release-Candidate`. **This is the release source.**
- There is an OLDER "live" codebase (`SafetyALRT/alrtap-frontend` +
  `alrtap-backend`). **Do not mix them up** — all new work goes into the
  `test` build.

## What the current test build does

The app is functional end-to-end and ready to test on a phone. Highlights:

- **Family circles** — create a circle, invite people, see who's safe, share
  location during SOS / journeys / check-ins.
- **Hazard alerts** — live alerts on a map and a feed, colour-coded by how
  urgent they are. The shape tells you the source (official, community, global).
- **The alert detail screen** (recently improved) shows:
  - **"What we know"** — the agency's own facts, with a "Show all facts"
    expander so nothing is cut off.
  - **"What to do"** — two modes. If the agency gave instructions, you see
    **their** words (ranked so the life-safety ones like "Leave now" always
    come first, with a "Show all" expander). If they didn't, you see **ALRT's
    relevant "Consider" guidance** (grab bag, plan up to date, safe route).
  - A bold **"DFES advises:"** lead-in and plain bullet points.
  - A **Key facts** strip (distance, time window, wind, size, water level)
    pulled from the source.
  - A **"See full alert"** link showing the complete original text + a link to
    the source page.
  - **For You** — advice tailored to the reader's safety profile (older adult,
    children, mobility, medical, deaf/hard of hearing, vision, visitor,
    essential worker, pets). This is on-device only and never leaves the phone.
  - **Attribution** at the bottom (source, licence, copyright).
- **Global/GDACS alerts** read correctly for people in other countries (no
  Australia-specific wording).
- **Ask ALRT** — ask a question in your own words, get a clear answer. Free
  users get 5 a day; ALRT+ get 30.
- **ALRT+ subscription** — unlocks unlimited saved areas, more Ask ALRT, and
  hosting up to 8 family seats. (Pricing is set in the App/Play stores.)
- **Admin portal** — self-serve for categories (name, colour, icon) and alert
  sources, without a new app release.

## The severity colours (the "level" system)

Every alert has a colour telling you how urgent it is:

| Level | Colour | What it means |
|---|---|---|
| Info | grey | Just information |
| Monitor / Advice | yellow | Be aware |
| Action / Watch and Act | orange | Act now |
| Critical / Emergency Warning | red | Danger — act immediately |

For the official Australian Warning System (AWS) alerts, the words **Advice /
Watch and Act / Emergency Warning** always show, straight from the source.
Red is reserved for the most severe level — never used for a category colour.

## How to build and test it

The build runs automatically on GitHub when you push to `test`. You can also
trigger it manually from the Actions tab, or with:

- **Android test build:** `Android Test Build` workflow
- **iOS test build:** `iOS Dev TestFlight` workflow

Builds take roughly 10–15 minutes. The Android build gates on `flutter analyze`
(it fails if a changed file has any lint issue); the iOS build does not.

## Key product decisions (so we stay consistent)

- **Free tier:** 1 saved area + 5 Ask ALRT a day. **ALRT+:** unlimited areas,
  30 Ask ALRT a day, up to 8 family seats, 1-month free trial.
- **Joining a family circle is always free** — only *hosting* is an ALRT+ gate.
- **Ask ALRT** answers from a pre-written library first (free), then emergency
  numbers, then AI as a last resort. The AI path is the only one that costs
  money.
- **Privacy:** safety-profile details never leave the phone. Community report
  locations are rounded to about 1 km (no precise addresses). This is
  deliberate — to stop any doxing or targeted postings.
- **Official wording is never changed.** ALRT's own guidance is clearly
  labelled as *not part of the official warning*.

## Known items / things to watch

- **iOS widget + smartwatch** were temporarily removed from the iOS build so
  the iOS build passes. The Android widget is in. Bringing iOS widget/watch
  back is a separate piece of work.
- **Severity *words*** for non-AWS alerts are currently hardcoded in the code
  (the AWS words come from the source and should stay as-is). Making them
  editable from the admin portal is a possible future enhancement.
- **The older "live" app** is not the release source — don't deploy from it.

## Asking for help

If something looks wrong, the best place to start is the `test` branch and the
docs in the repo root (`V1_RELEASE_PLAN.md`, `V1_RECONCILIATION_REPORT.md`,
`TEST_BUILD_51_ACCEPTANCE.md`). The admin portal and Ask ALRT can be
configured without a new app release.

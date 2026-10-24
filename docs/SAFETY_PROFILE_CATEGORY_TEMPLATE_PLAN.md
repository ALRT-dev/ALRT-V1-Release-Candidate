# ALRT Safety Profile category-template plan

Date: 21 October 2026
Status: review draft
Owner: Sarah
Scope: build out Safety Profile / For You information so it is linked to hazard categories and rendered from template data, not improvised by prompts.

---

## 1. Decision

Build the Safety Profile content as **category-linked template data**.

Do **not** rely on the AI prompt to invent or infer Safety Profile guidance.
Do **not** treat broad parent categories as sufficient for all alert types.
Use the backend category / subcategory ids as the source of truth, then attach:

1. **general ALRT information** for that hazard family, and
2. **Safety Profile rows** for cohorts that genuinely need different guidance.

This keeps the alert detail experience deterministic, reviewable, and editable.

---

## 2. What already exists

### Existing source-of-truth category system
Backend category ids already exist in:
- `backend/src/services/hazard_category.service.ts`

This file defines the main categories and their subcategory ids.

### Existing template/guidance path
The backend already supports category-linked guidance entries through:
- `backend/src/utils/alert_template_seed.util.ts`
- `backend/src/utils/alert_templates.util.ts`
- `backend/src/services/hazard.service.ts`

The template guidance system already supports:
- `categoryIds`
- `profileTags`
- country scoping
- band scoping
- approved vs unapproved status

### Existing frontend render path
The frontend already renders published guidance through:
- `frontend/lib/features/shared/models/hazard_model.dart`
- `frontend/lib/features/shared/views/screens/view_hazard_screen.dart`
- `frontend/lib/features/profile/views/widgets/for_you_card.dart`

### Existing fallback library
There is also a bundled on-device fallback library in:
- `frontend/lib/features/profile/models/for_you_library.dart`

This should remain a fallback, not the long-term master content system.

---

## 3. Current gap

The plumbing exists, but coverage is incomplete.

### Current backend coverage is still sparse
The seeded template guidance currently contains only a small number of approved category-linked profile rows.

### Current frontend fallback has limited hazard buckets
The bundled `ForYouLibrary` currently covers a finite set of hazard buckets rather than the full backend category/subcategory system.

### Result
Many alerts can render without any Safety Profile card even when we conceptually know what the cohort guidance should be.

This is especially visible for:
- transport / traffic disruptions
- planned events / sporting events
- some community-information alerts

---

## 4. Product rule to preserve

The For You card must stay aligned with these rules:

- It is **on-device only**.
- It is **not AI-generated at render time**.
- It only appears where there is a **real cohort-specific difference**.
- If a hazard has no genuine cohort difference, it is valid for the card not to render.
- Broad parent categories must not force irrelevant advice onto unrelated alerts.

This avoids fluff and keeps the card trusted.

---

## 5. Recommended content model

For each hazard category or subcategory, define **two layers** of template content.

### Layer A — general ALRT information
Purpose:
- hazard-linked fallback information
- planning guidance when the source gives no direct official actions
- category-specific context

Data shape:
- `profileTags: []`

Examples:
- road closure → check route and allow extra time
- public transport disruption → check service updates before travelling
- sporting event → confirm venue/service updates before changing plans

### Layer B — Safety Profile guidance
Purpose:
- cohort-specific lines for users who have ticked Safety Profile chips

Data shape:
- `profileTags: ['older']`, `['kids']`, etc.

Supported cohorts:
- `older`
- `kids`
- `mobility`
- `medical`
- `deaf`
- `vision`
- `visitor`
- `worker`
- `pets`

---

## 6. Category strategy

### Important rule
Do **not** attach most guidance only to broad parent categories like:
- `trafficAndTransport`
- `communityInfo`

That is too broad and causes unrelated alerts to inherit the same advice.

### Correct rule
Attach profile guidance primarily at the **subcategory level**.

That is what makes the system truly “templated based on the hazard.”

---

## 7. Recommended implementation phases

## Phase 1 — highest-value subcategories first

Build out template coverage for the hazard families where cohort guidance is clearly useful.

### Fire / smoke
Target ids:
- `bushfire`
- `plannedBurn`
- `otherFire`
- `smoke`
- `smokePlume`
- `fireWeather`

### Flood / storm / weather
Target ids:
- `flood`
- `waterOverRoad`
- `heavyRain`
- `storm`
- `damagingWinds`
- `strongWinds`
- `cyclone`
- `riverRise`
- `hailStorm`
- `largeHail`
- `dustStorm`
- `coastalHazard`
- `hazardousSurf`

### Health / air / water
Target ids:
- `airQualityAlert`
- `publicHealthAlert`
- `diseaseOutbreak`
- `heatHealthAlert`
- `extremeHeat`
- `asthmaAlert`
- `boilWaterNotice`
- `boilWaterAlert`

### Transport / closure / disruption
Target ids:
- `roadClosure`
- `roadWork`
- `roadDamage`
- `changedTrafficConditions`
- `speedReduction`
- `publicTransportCrowding`
- `railDisruption`
- `trainDelay`
- `detour`
- `trafficCongestion`

### Event / venue
Target ids:
- `largeSportingEvent`
- `concertFestival`
- `venueEvacuation`

---

## 8. Categories that should stay empty by design unless explicitly documented

Recommended empty-by-design set:
- `crash`
- `accident`
- `rescueRoad`
- `protest`
- `rally`
- `demonstration`
- generic `communityInfo`

Reason:
- limited stable cohort difference
- high risk of padding or misleading advice
- better no card than weak card

If product-approved cohort wording already exists for any of these, they can be reconsidered later.

---

## 9. Proposed cohort intent by hazard family

This section is not final wording. It is the intended shape of the content.

## Transport / road closure family
Useful cohorts:
- older
- kids
- mobility
- medical
- deaf
- vision
- visitor
- worker
- pets

Guidance themes:
- longer travel time
- changed pickup/drop-off plans
- accessible parking / step-free detours
- medication if away longer
- text/live service updates instead of relying on audio
- unfamiliar routes and temporary barriers
- local road rules / detour signage for visitors
- work-route disruption
- pets in cars during long delays

## Planned event / sporting event family
Useful cohorts:
- older
- kids
- mobility
- medical
- deaf
- vision
- visitor
- worker
- pets

Guidance themes:
- crowding and queue length
- meeting points for children
- accessible parking, lifts, longer entry time
- medication, hydration, time away from home
- visual signage instead of PA announcements
- crowded unfamiliar environments
- local venue/transport expectations for visitors
- event-area access changes for workers
- avoid bringing animals into noisy crowded areas

## Public transport crowding family
Useful cohorts:
- older
- kids
- mobility
- medical
- deaf
- vision
- visitor
- worker
- pets

Guidance themes:
- off-peak travel
- crowd navigation
- accessible boarding changes
- delay tolerance
- text/service updates
- station familiarity
- worker commute timing

---

## 10. What this does NOT fix by itself

This plan fixes **Safety Profile / For You coverage**.

It does **not** by itself fix poor wording in:
- `In plain terms`
- `What we know`
- `What to do`

Those issues are a separate content-shaping problem, especially for sources like Live Traffic NSW planned events.
That work should be handled through source/category templates and extraction rules, not through Safety Profile rows.

---

## 11. Files to change

### Primary implementation files
- `backend/src/utils/alert_template_seed.util.ts`
  - add approved guidance rows by category/subcategory
  - add both general ALRT rows and profile-tagged rows

- `backend/src/services/hazard_category.service.ts`
  - use as the canonical id list when deciding which hazards get rows
  - only change if category structure itself needs refinement

### Existing logic already sufficient
- `backend/src/utils/alert_templates.util.ts`
- `backend/src/services/hazard.service.ts`
- `frontend/lib/features/shared/models/hazard_model.dart`
- `frontend/lib/features/profile/views/widgets/for_you_card.dart`

### Optional fallback update later
- `frontend/lib/features/profile/models/for_you_library.dart`

Recommendation: do **not** lead with frontend fallback changes. Build out the backend category-linked template system first.

---

## 12. Recommended next steps

1. Approve the category strategy in this document.
2. Pick the first implementation wave:
   - Fire / smoke
   - Flood / storm
   - Health / air
   - Transport / event
3. Seed approved `profileGuidance` rows for that wave.
4. Publish a TEST template version.
5. Verify on real alerts that:
   - the right categories now show For You
   - empty-by-design categories remain empty
   - no unrelated hazard inherits the wrong cohort lines
6. After that, tackle the separate “What we know / What to do / In plain terms” source-template cleanup.

---

## 13. Suggested owner decision points

Please review and confirm:

1. Should `largeSportingEvent` and `concertFestival` carry Safety Profile rows?  
2. Should `publicTransportCrowding` carry Safety Profile rows?  
3. Should `protest` / `rally` remain empty by design?  
4. Should `roadClosure` / `roadWork` / `detour` all carry Safety Profile rows?  
5. Do you want the backend template system to become the primary long-term source, with the frontend bundled library reduced to fallback only?  

---

## 14. Working recommendation

My recommendation is:
- **yes** to category-linked backend templates as the main system
- **yes** to subcategory-level guidance rather than broad parent-only guidance
- **yes** to transport / event Safety Profile rows where there is real cohort difference
- **no** to forcing a card on crashes / protests / generic notices unless product-approved wording already exists

That gets you the cleanest, most reviewable version of “Safety ALRT pieces of information linked to each category.”

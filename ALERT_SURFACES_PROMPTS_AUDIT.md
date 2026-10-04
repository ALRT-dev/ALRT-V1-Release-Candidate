# Alert surfaces, AI prompts and Safety Profile: audit

Audit date: 27 September 2026. Code audited: `test` at `ea93889`. This is an
audit only; no code, prompt, configuration or server was changed.

Mock-ups of every surface, with the findings marked on them:
https://claude.ai/artifact/6q1ZFceyG1y8DxF9M5by16 (private until shared).
They are reconstructed from the source code: the real strings, colours and
section order. They are not phone screenshots. Nothing here has been checked
on a device or on the deployed TEST server.

## 1. Findings

IDs match the mock-up page. S = severity, V = view, P = prompt,
SP = Safety Profile.

### Safety

| ID | Finding | Evidence |
|---|---|---|
| S1 | The "info override" words are matched inside other words, and they run before the Critical phrases. `test` matches "latest" and "protest", `exercise` matches "exercise caution", `cleared` matches "cleared land". This sets the band for **every official alert outside the Australian Warnings System**. Run in this session against the real word lists: "Latest update: fire is burning out of control. Leave immediately." comes out as **Info**. The Monitor phrase "check the latest conditions" can never fire. | `backend/src/utils/ingestion.severity.util.ts:216-256`, called from `ingestion.util.ts:3552` |
| V6 | The home-screen widget is refreshed from the map's last load: its current view and category filters (`map_provider.dart:299`). It also skips any alert without a single point, such as area warnings. After panning, filtering, or during a region-wide warning, it can show "You're all clear · No warnings near you." | `frontend/lib/features/home_screen_widget/home_widget_sync.dart` |
| P1 | All 22 seeded prompts store `model: "gpt-5-nano"`, while `AI_PROVIDER` defaults to `bedrock`. Bedrock is then sent that model name and rejects it. Every AI step fails: community reports all go to manual review and official summaries are lost. Flagged in reconciliation §20.6; still open. | `ai-prompt.service.ts:670-754`, `bedrock.service.ts:136`, `config.ts:146` |
| P14 | No code checks the AI output against the prompt rules. Nothing empties community calls to action, strips specific emergency numbers, or blocks movement words. | `hazard.service.ts` (`reviewHazard`, `summarizeHazard`) |

### Consistency and wording

| ID | Finding | Evidence |
|---|---|---|
| V1 | "In plain terms" always ends "Their advice is in this alert", even when there is no advice and the "What to do" section is hidden. The grammar also fails: "has issued a Emergency Warning", "a Advice". | `alert_card_style.dart` `plainTermsOf`, `view_hazard_screen.dart:1290` |
| V2 | Push titles for official non-AWS alerts print the band word ("Monitor \| …", "Critical \| …"). The app never writes band words for those sources. GDACS alerts don't get their "GDACS {colour}" wording. | `notification.service.ts:545-559` |
| V3 | Each source's push policy is stored but never read by the push code. Community reports push on acceptance, although the stored rule is "only after nearby confirmation". GDACS Green pushes, and ALRT Intel pushes normally. | `schema.prisma` `SourcePushPolicy`, `notification.service.ts` |
| V4 | A community report's title is the category name in the list and detail views, but the AI title in the push and the widget. | `common_hazards_list_item.dart:528`, `home_widget_mapper.dart` |
| V5 | The widget has no source type, so community reports look official and aren't marked unverified. It writes band words for official agencies. Its colours differ from the app's locked hexes: Action #F26522 instead of #F07E1B, Monitor #E9B500 instead of #F5C518, and Info is drawn amber. | `AlrtAlertsWidget.swift:76-95`, `AlrtAlertsWidgetProvider.kt`, `models/home_widget_alert.dart` |
| V7 | The push data contains the whole alert, minus coordinates. The push data limit is about 4 KB, so long alerts may fail to send. The reporter's own "Approved" push sends the full alert, coordinates included. | `notification.service.ts:310`, `hazard.controller.ts:620` |
| V8 | Community "Security & crime" pins use #D9304F, close to the Critical red. The rules say community reports are never red-treated. | `hazard_category_model.dart:126` |
| V10 | "Listen" reads a community report's raw description aloud; the screen hides that text on purpose. | `view_hazard_screen.dart:891` |
| V11 | An em dash appears in the check-in message `Safe — near "title"`, and in the Safety Profile copy. | family safe strip, `safety_profile_screen.dart` |
| V12 | "Your alert is now live - community notified" is sent even when nobody was notified. | `hazard.controller.ts:618` |

### AI prompts

| ID | Finding | Evidence |
|---|---|---|
| P2 | The official summary prompt's output format asks for "callsToAction (2–4 dot points)". The same prompt says to return `[]` when the source gives no instruction. The conflict invites invented advice. | `ai-prompt.util.ts:408-415` |
| P3 | The shared introduction asks for "actionable summaries … an appropriate call to action", which contradicts "ALRT never writes its own advice". | `ai-prompt.util.ts:363` |
| P4 | The AWS and non-AWS official prompts get identical text (8 copies). | `ai-prompt.service.ts:707-782` |
| P5 | "Never provide medical treatment instructions beyond 'call emergency services'" conflicts with the "your local emergency number" rule. | `ai-prompt.util.ts:391` |
| P6 | The Smartraveller examples write movement advice ("If already there, consider leaving", "leave immediately") and hard-code DFAT 1300 555 135. The source is disabled, but the prompts are seeded and would go live if it were re-enabled. Smartraveller alerts also never expire. | `ai-prompt.util.ts:278-361`, `ingestion.service.ts:764` |
| P7 | The air quality prompts are unused, because air quality is templated. Their examples write ALRT's own advice ("Stay indoors immediately"). They are still visible and editable in Admin. | `ai-prompt.util.ts:192-272` |
| P8 | The location-extraction and SI prompts say "in Australia"; V1 is worldwide. | `ai-prompt.util.ts:7`, `:435` |
| P9 | The SI Extraction prompt is seeded but `extractHazardInfo` is never called. `severity_scan.service.ts` is also unused. | `si_extraction.service.ts:100` |
| P10 | The community review prompt is stored as four identical copies, chosen by description keywords; editing one silently diverges from the others. | `ai-prompt.service.ts:665-700` |
| P11 | AI summaries are cached for 30 days by content, so a prompt fix doesn't reach alerts already summarised. | `hazard_cache.service.ts:235` |
| P12 | Prompts are seeded only into an empty table, so the live text on a server can differ from the code (see `COMMUNITY_REPORT_MODERATION_AUDIT.md` §4). | `ai-prompt.service.ts:571` |
| P13 | A missing location name is sent to the AI as "- undefined" or "- ". | `hazard.service.ts:664` |

### Safety Profile

| ID | Finding | Evidence |
|---|---|---|
| SP1 | "Never leaves this device" isn't strictly true. The profile is kept in SharedPreferences / UserDefaults, which Android auto-backup (on by default; no `allowBackup="false"`) and iPhone backups copy. ALRT itself never receives it: no API or backend code reads it. | `safety_profile_provider.dart`, `AndroidManifest.xml` |
| SP2 | The profile screen says "Guidance for other groups stays one tap away on every alert, so nothing is hidden". In fact only ticked groups are ever shown; the expander only reveals ticked groups beyond three. | `for_you_card.dart:62-80` |
| SP3 | "Skip — show all guidance equally" shows no guidance; you get a setup prompt instead. | `for_you_card.dart:58` |
| SP4 | The hazard type is picked by word fragments. Checked: "Industrial fire" gives dust storm guidance, "Fuel reduction burn" gives fuel shortage guidance, "Fire near Westmead Hospital" gives hospital capacity guidance. | `for_you_library.dart:23-90` |
| SP5 | Australia-only wording: the "Visiting Australia" group, "This alert season", and lines that assume Australian warning levels. | `safety_cohort.dart`, `for_you_library.dart` |
| SP6 | The library is ALRT-authored advice, including advice to move ("Leaving early … is advisable"). That conflicts with the locked rule "ALRT never writes its own advice". It is an approved document (Aug 2026), but no written ruling makes it the exception, and the card doesn't label it as general guidance. | `for_you_library.dart:1-9`, `backend/CLAUDE.md` |

## 2. What each surface shows

Full detail, with mock-ups, is on the page linked above. In short:

- **Map:** one pin per alert, in the source's shape (triangle for AWS, diamond for official agencies, circle for community, rounded square for GDACS, shield for ALRT Intel). Official pins take the band colour, community pins the category colour. Tapping a pin opens the list card.
- **List card:** coloured header with a source pill (the level word appears for AWS only); "In plain terms" (official only); icon, title, time and distance; a freshness chip (green only within an hour of a real update). Community cards add votes, "Confirmed by ×N" and "Is this alert still active?". Solid red is for official Critical only, a dashed outline for official Action.
- **Full alert:** header; "In plain terms"; location; What we know (the source's own words); What to do (only when the source instructs); family check-in strip; For You; media; Share/Follow/Listen; source and licence. The reporter also sees Edit, Delete and Reviewer feedback.
- **Notification:** title "{level or band} \| {title}", or "Community report \| {AI title}"; body is the AI summary, falling back to the description. Action and Critical use the urgent channel and are time-sensitive on iOS. Lock screen is private; no coordinates in the payload. Emergency Warnings skip the 10-per-15-minute cap. One push per person per event.
- **Widget:** Nearby Alerts shows the most important alert within 50 km, with "+N more", or "All clear". The Family widget shows up to 4 circles, ordered SOS first, and never shows names, locations or profile details.
- **Safety Profile:** 9 groups, on-device only; 243 reviewed lines (27 hazard types × 9 groups). Ticking deaf or vision groups turns on strong vibration or read-aloud until you set those yourself.

## 3. Decisions needed

1. Severity: match the override words as whole words only, and let Critical phrases win (S1).
2. Widget: feed it from your location and saved places, include area warnings, and show "Couldn't check" instead of a false all-clear (V6).
3. Start enforcing each source's stored push policy, and set the community confirmation threshold; none exists today (V3).
4. Remove band words from push titles and the widget for non-AWS sources, and show the source on the widget (V2, V5).
5. Say "Their advice is in this alert" only when advice exists, and fix "a Emergency" (V1).
6. Prompt clean-up: fix the official output format, retire the air quality prompts, rewrite or remove Smartraveller, and use or delete SI Extraction (P2-P9).
7. Choose the AI provider and model for TEST and production, and align the stored prompts with it (P1).
8. Safety Profile wording and backup exclusion. Should un-ticked guidance be available, as the screen promises (SP1-SP3)?
9. Confirm the For You library as the approved exception to "no ALRT advice", label it, and adapt it for use outside Australia (SP5, SP6).
10. One community title everywhere: the category name or the AI title (V4).

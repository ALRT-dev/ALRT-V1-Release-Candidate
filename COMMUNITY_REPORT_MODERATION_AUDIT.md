# Community report submission, moderation and publication: audit

Audit date: 27 September 2026. Baseline: `test` at `ea93889` (still the tip
of `test`; no newer commits). This is an audit only. No code, prompt,
configuration, TEST resource or production resource was changed.

## Evidence levels

| Label | Meaning |
|---|---|
| **Code** | Read in this repository at `ea93889`. |
| **Local run** | Executed in this session: the real backend code from `ea93889`, run on a throwaway local Postgres + PostGIS database, with a mock AI endpoint, a mock S3 endpoint and a probe that records Firebase sends instead of sending them. Every report was titled `LOCALTEST`, and the only push "recipient" was a fake token. This proves how the code behaves. It does **not** prove anything about the deployed TEST server, its prompts or its credentials. |
| **Deployed** | Seen on the live TEST API or Admin. **Nothing in this report reaches this level**: the session's network policy refused `api-test.safetyalrt.com` and `alrt-v1-release-candidate.pages.dev`. |
| **Device** | Passed on a phone. Nothing here reaches this level. |

---

## 1. How it works today, in plain English

1. **Writing the report.** The person writes a title and description, picks
   a category and location, and can attach photos or video. Limits are 10
   files of 50 MB each, images or video only.
2. **Sending.** The app shows "ALRT Submitted! … submitted for review"
   straight away, **before the server has answered**. The upload continues
   in the background.
3. **The server checks** that the person is signed in, that the fields are
   valid (title up to 100 characters, description up to 1,000) and that the
   general API rate limit hasn't been hit. There is no posting limit per
   person, no duplicate check and no difference for new accounts.
4. **Automatic checks**, in this order:
   - The AI may **change the category** it thinks fits better.
   - **Every photo and video is sent to Sightengine.** Any file that
     crosses a rule is **removed from the report**, but the report carries
     on.
   - The AI **reviews the text** and answers `accepted` or `rejected`, with
     a cleaned-up title and summary.
5. **Decision.**
   - The AI says `accepted`: the report is **published immediately** for 30
     minutes.
   - The AI says `rejected`: the report is hidden and the reporter is told
     why.
   - The report goes to **pending** (manual review) only when something went
     wrong: the AI failed or timed out, the AI's answer was unusable, the
     media could not be screened, or the TEST "skip AI" flag was set.
6. **Publishing.** A published report appears on the map and in the feed.
   Nearby people who have community alerts switched on for that category
   get one push, subject to the per-person rate cap. Families with members
   or saved places nearby are alerted. The reporter gets "ALRT Approved!".
7. **Afterwards.**
   - Other people can vote. Each upvote adds 1 minute to the expiry; each
     downvote removes 30 seconds.
   - Three different people flagging a report sends it back to pending.
   - The author can edit it, which runs the AI review again.
   - An admin can approve, reject or delete a report in the Admin portal.
   - Approved reports disappear from lists when they expire.

**The system is already built as "publish automatically unless a rule says
otherwise".** The manual review you are seeing is caused by the specific
reasons in §4, not by a rule that requires approval.

---

## 2. Requirement table

"Local run" results are from the scenario run described above (17
scenarios; results in §7).

| Requirement | Frontend | Backend | Evidence | Outstanding |
|---|---|---|---|---|
| Report with location, photos, video | Yes | Yes (`POST /api/hazards`, multer, S3) | Code. Local run: a photo upload stored through mock S3 | Device test. Real S3 on TEST |
| Frontend validation | Partial: form fields and a location fallback | n/a | Code | None needed; the backend is the gate |
| Backend validation and auth | n/a | `requireAuth`, Zod (`hazard.validator.ts`) | Code. Local run | None |
| Abuse limits | None | General API limiter only. **No per-user post limit, no duplicate detection** | Local run DUP-1: the same report sent twice made **2 alerts and 2 pushes** | Decision D4 |
| AI text review decides publication | n/a | `reviewHazard` (`hazard.service.ts:488`), prompt in the database | Code. Local run AUTO-1, REJ-1 | Check the **deployed** prompt text (§4.2) |
| Media moderation | n/a | `checkMediasForProblems` (Sightengine) | Code. Local run MEDIA-1 (service unreachable, so pending) | Inappropriate-image rules not run (Sightengine unreachable). Faces rule, D5 |
| Failure means review, never publish | n/a | Yes, for AI failure and for media screening failure | Local run FAIL-1, PROMPT-1, MEDIA-1 | Bedrock has **no request timeout** (§5) |
| New users treated differently | No | No. Account history changes the confidence score only, not publication | Code | Decision D3 |
| Publishes to map/feed only when accepted | Yes | Yes. The list query shows accepted reports, plus the viewer's own reports in any state (`hazard.util.ts:677-695`) | Local run AUTO-1, REJ-1, FAIL-1 | None |
| Pending/rejected hidden from others everywhere | n/a | **No.** `GET /api/hazards/:id` has no visibility check | Local run VIS-1: another user opened a **rejected** report by id (200) | Fix (P0) |
| Expired reports excluded | Yes | Lists: yes. **Single report by id: no** | Local run EXP-1: an expired report still opened by id | Fix (P1) |
| Pending reports expire | n/a | **No.** Pending reports have no expiry | Local run EXP-2: 6 pending reports with no expiry | Decision D6 |
| Push only for published reports | n/a | Yes, when created as accepted | Local run AUTO-1: 1 push; REJ-1/FAIL-1: 0 | See the next two rows |
| Push when an admin approves | n/a | **No push, no socket event, no family alert, no reporter notice** | Local run ADM-2: 0 pushes | Decision D7 |
| Push when an edit makes a report visible | n/a | **No** | Local run EDIT-2: 0 pushes | Decision D7 |
| Edits re-assessed | Yes (edit screen) | Yes: the AI runs again and new media is screened | Local run EDIT-1 | Existing media is not re-screened (fine) |
| Admin decision stands after an edit | n/a | **No.** The author's edit overwrites an admin rejection | Local run EDIT-3: an admin-rejected report became **accepted** after the author edited it | Fix (P0) |
| User can report inappropriate alerts | Yes ("Report this alert" sheet) | Yes: `POST /hazards/:id/flag`, 3 distinct flags send it to pending | Local run FLAG-1 | Reason not recorded; admin cannot see flags (§5) |
| Reporter sees published/pending/rejected | Toasts for accepted/rejected only. The "My ALRTs" screen has **Accepted and Rejected tabs only** | Status is in the response | Code | Pending is invisible to the reporter (P1) |
| No success claimed before the server confirms | **No.** "ALRT Submitted!" shows before the request completes. An upload failure appears only as a toast if Home is mounted | n/a | Code (`create_update_report_provider.dart:83`) | Fix (P1) |
| Rejection reason and edit/retry | Rejected list shows `reviewFeedback`, with an edit button | Yes | Code | Copy (§6) |
| Community vs official distinguishable | Yes: "Community report" push title, community colour, raw description hidden, "unverified" wording | Title prefix in push | Code | The "Listen" button reads the **raw, unsanitised** description aloud (`view_hazard_screen.dart:891`) |
| Android/iOS consistent | Same Dart code | Same API | Code only | Device test. The reporter push carries the whole hazard object as data (`hazard.controller.ts:620`), which may go over the 4 KB push data limit. Untested |
| Admin exception queue with reasons | Pending tab exists | `GET /admin/hazards?reviewStatus=pending` | Local run ADM-1 | **The pending tab hides the reason column.** Flagged reports show no reason. No flag counts. Limited to 100 rows, no paging |
| Admin audit trail | **No viewer** | Review is audited. **Delete is not** | Local run ADM-2 (1 audit row), ADM-3 (0 rows on delete) | Read API and screen. Audit deletes |
| Admin override/remove without approving everything | Approve/reject on pending only. Delete on the Alerts page | `PATCH …/review` accepts any status. `DELETE` is a hard delete | Code. Local run | "Remove" for a published report in Moderation. Delete leaves S3 files behind |
| TEST isolation | n/a | Separate database and prompts (in that database). Shared Firebase project. S3 bucket, Sightengine and AI accounts unverified | Code and docs | Confirm on TEST (§5) |

---

## 3. The exact existing rules and where they are defined

### 3.1 Publication decision

| Rule | Where |
|---|---|
| The AI answer's `reviewStatus` decides. Only the literal strings `"accepted"` and `"rejected"` are trusted. Anything else means **pending** | `mapAiReviewStatus`, `backend/src/utils/hazard.util.ts:1109` |
| AI call throws, times out or returns invalid JSON: **pending**, with "We're sorry, but we couldn't review your alrt at this time…" | `hazard.controller.ts:433-441` (create), same in update |
| Media could not be screened and the AI said accepted: **pending**, with "…attached media could not be automatically screened." | `hazard.controller.ts:445-452` |
| TEST only: `useDummyAi: true` and `NODE_ENV=test`: AI skipped, **pending** | `hazard.controller.ts:342`, `hazard.service.ts:511-526` |
| Accepted on creation: expires **30 minutes** after posting | `hazard.controller.ts:521-523` |
| Accepted by an admin: expires by severity. Community reports are `unknown` severity, so **6 hours** | `reviewHazardForAdmin` → `getHazardExpiryDateFromSeverity`, `hazard.util.ts:1036` |
| Pending and rejected: **no expiry** | same places (expiry is only set on accept) |
| Votes from others: +1 minute per upvote, −30 seconds per downvote. The expiry is never set in the past; it is left unchanged instead | `voteHazard`, `hazard.controller.ts:1096-1112` |
| 3 distinct flags on an accepted report: **pending**. Official alerts cannot be flagged. Nobody can flag their own report | `FLAGS_TO_AUTO_HIDE = 3`, `community_safety.service.ts` |

### 3.2 AI text rules (the prompt)

Source default: `getUserReportedAlertReviewAndSummarizationPrompt`,
`backend/src/utils/ai-prompt.util.ts:53`. It is seeded into the `AIPrompt`
table as four identical copies (`[INFO]`, `[MONITOR]`, `[ACTION]` and
`[CRITICAL]` "User Reported Alert Review and Summarization"). A copy is
chosen by a keyword-derived band from the description
(`getSeverityBandFromDescription`). **The live rules are whatever text is in
the database**, which admins can edit in the Admin portal's AI Prompts page.

- **Rejected when the report is clearly:** spam; an advertisement; a
  test/nonsense submission with no real content; an attempt to instruct or
  jailbreak the AI; a direct personal attack; or another person's private
  information (a name, phone number or exact home address).
- **Accepted otherwise**, *including* profane, discriminatory or offensive
  submissions that still describe a real hazard. These are published with a
  neutral title ("Uncensored alert") and a sanitised summary. The raw
  description is still stored and returned by the API.
- The prompt never asks for manual review. The AI can only accept or reject.
- `callsToAction` must always be `[]`. This is enforced by the prompt only,
  not by code (already noted in `V1_RECONCILIATION_REPORT.md` §25).
- Confidence high/medium/low is stored. It affects ranking only, not
  publication.

### 3.3 Media rules

`backend/src/services/image_video_detection.service.ts`. Images are scored by
Sightengine with a **0.5 probability threshold**. Any hit **removes that file**;
the report continues without it:

- Sexual activity, sexual display, erotica.
- Nazi, confederate, supremacist or terrorist symbols; middle finger.
- Self-harm.
- **Any face at all.**
- Probable minor.
- Text in the image containing profanity, personal information (names,
  number plates), extremism, violence or self-harm.
- A QR code containing personal information.

**Video** uses a Sightengine *workflow* (`SIGHTENGINE_WORKFLOW_ID`). Its
rules live in the Sightengine dashboard, not in this repository:
**unverified.** Any Sightengine error means pending (fail-safe).

### 3.4 Where the documentation and the code differ

| Documentation says | Code does |
|---|---|
| `community_safety.service.ts` and the `HazardFlag` schema comments: "AI review and media screening stop most objectionable content before it publishes" | The prompt deliberately **accepts** profane and discriminatory reports and only sanitises their title and summary |
| `ModerationPage.tsx` header: "Community-reported hazards awaiting a human decision" | Most pending reports are service failures or TEST bypasses, not rule decisions. The page cannot tell them apart |
| `backend/CLAUDE.md`: "callsToAction is always []" | Prompt instruction only; no code override |
| `V1_RECONCILIATION_REPORT.md` §23: "on accept, backfills expiresAt from severity the same way create/update already do" | Create uses a flat 30 minutes; admin accept uses 6 hours. They differ |
| `backend/CLAUDE.md` names `npm run reset-ai-prompts` as the prompt fix | That script only **repoints** configuration to existing rows. It does not update prompt **text**. It also hardcodes `.env.dev` (`package.json:22`), so as written it cannot target TEST |
| The review prompt is titled "AI profanity checker" | Profanity is published, not rejected |

---

## 4. What causes unnecessary manual approval

In likely order of impact:

1. **The TEST apps are built to skip AI review.** Both
   `.github/workflows/android-test.yml:334` and
   `.github/workflows/ios-test-testflight.yml:235` write
   `USE_DUMMY_AI_FOR_REPORTS=true`. The app then sends `useDummyAi: true`
   (`hazard_repository.dart:28-52`), and the TEST server (`NODE_ENV=test`)
   returns **pending for every report**. Local run DUMMY-1 confirms this.
   **On TEST today, every report from build 51 needs a human.**
2. **An old prompt in a database.** Prompts are seeded only into an empty
   `AIPrompt` table (`initializeAIPrompts`, `ai-prompt.service.ts:571-576`).
   The prompt inherited from `backendV2` had **no `reviewStatus` field**
   (checked in git history). Before 22 August the code hardcoded
   "accepted". Since commit `f2e93c4` it trusts `reviewStatus`, so a database
   still holding the old text sends **every** report to pending. Local run
   PROMPT-1 confirms this. Any database created before 22 August is exposed,
   **production included, once this code is deployed there**. Whether the
   TEST database has the new text is **unverified**. It was created later,
   so it probably does.
3. **AI credentials missing or failing on the server.** Any AI error means
   pending. `.env.test.example` leaves the AI keys blank, and §33.2 of the
   reconciliation report recorded a TEST report landing pending "as expected
   with no real AI provider credentials". Deployed TEST credentials:
   **unverified.**
4. **Media screening unavailable.** Any Sightengine failure makes a report
   with media pending (MEDIA-1). Deployed TEST Sightengine keys:
   **unverified.**
5. **Flagged reports** go back to pending, which is correct. But the queue
   shows no reason, so they look the same as failures.

Nothing in the code forces every report into manual approval by rule.

---

## 5. Missing safeguards, configuration and access

**Privacy and correctness (P0)**
- `GET /api/hazards/:id` returns pending, rejected and expired reports to
  any signed-in user, and serves them from a 5-minute cache. The list is
  protected; the single-report route is not.
- An author's edit replaces an admin rejection with a fresh AI decision
  (EDIT-3). The same applies after 3 flags: an edit can republish a report
  the community flagged.
- Flag-driven hiding does not clear the caches (`flagHazard` never calls
  `invalidateHazardCaches`), so it can take up to 60 seconds in lists and 5
  minutes by id.

**Reliability**
- The Bedrock client (the production default, `AI_PROVIDER=bedrock`) has
  retries but **no request timeout** (`bedrock_client.util.ts`). OpenAI has
  a 15-second timeout. Submission runs the category AI, media screening and
  the review AI one after another.
- No idempotency key on `POST /api/hazards`, and no near-duplicate check.
  A retry or double tap makes two alerts and two pushes (DUP-1).
- Pending reports never expire. A days-old report approved late goes live
  as new, with a fresh 6-hour expiry and no push.

**Moderation tooling**
- The Admin pending queue hides `reviewFeedback`, so the reason is invisible
  on the one tab where it matters. It shows no flags, no flag reasons, no
  "media unscreened" marker and no age. It is capped at 100 rows with no
  paging.
- There is no way to remove a published report from Moderation (only delete
  on Alerts).
- Delete is a hard delete, **not audited**, leaves S3 media behind, sends
  no socket removal and does not tell the reporter.
- There is no audit-log read API or screen (known since §24.6).
- Flags carry a reason in the database, but no admin endpoint returns them.

**Reporter experience**
- Success is shown before the server confirms.
- Pending is never shown to the reporter; "My ALRTs" has only Accepted and
  Rejected tabs.
- The reporter push says "Your alert is now live - community notified" even
  when nobody was notified. It attaches the full hazard as data (a size
  risk).

**Content**
- Raw descriptions (possibly profane) are returned by the API to every
  viewer and read aloud by "Listen".
- Blocking a reporter hides their reports in lists, but pushes still go to
  the person who blocked them.

**Configuration and access I could not verify**

| Item | Needed to verify |
|---|---|
| The live prompt text in the TEST `AIPrompt` table and `Configuration.aiPrompts` | TEST Admin, AI Prompts page, or read-only database access |
| TEST AI provider and credentials (`AI_PROVIDER`, Bedrock/OpenAI keys) | TEST server environment |
| TEST Sightengine keys and the video workflow rules | Sightengine dashboard |
| TEST S3 bucket is not the production bucket | TEST environment and AWS console |
| TEST pushes stay on TEST devices (shared Firebase project `alrt-a6539`) | A device test |
| Production prompt text, before any production deploy of `f2e93c4` or later | Production Admin (read only) |

The TEST API and Admin hosts were blocked by this session's network policy.
Allowing them, and supplying a TEST admin login, would let a later session
run §7's scenarios on the real TEST server.

---

## 6. Plan: rules-based automatic publication (TEST first)

No thresholds are invented and moderation is not weakened. Every item keeps
the existing rules.

### P0: stop the unnecessary manual approvals on TEST (configuration; needs your approval)
1. Rebuild the TEST apps with `USE_DUMMY_AI_FOR_REPORTS=false`, or add a
   workflow input defaulting to false. Keep the dummy path only for a
   labelled "no-AI" run. (D1)
2. On TEST, confirm the AI prompt rows contain the `reviewStatus` rules
   (§3.2). If they don't, update the **content** of the four user-report
   prompts to the repository default, through the Admin AI Prompts page, and
   record it. Do the same check on production **before** any production
   deploy of the current backend. (D2)
3. Confirm TEST has working AI and Sightengine credentials. Without them,
   every report is pending by design.

### P0: code fixes that protect the rules (TEST only)
4. `GET /api/hazards/:id`: apply the same visibility rule as the list
   (accepted and not expired, or your own report; admins bypass).
5. Edits: if the last decision was made by an admin (`reviewedById` is an
   admin id) or the report is flagged, keep the admin's rejection, or send
   the report to pending, rather than letting the AI decide again. (D8)
6. Clear the hazard caches when flags change a report's status.

### P1: exception review that works
7. Record **why** a report is pending, in a machine field
   (`ai_unavailable`, `ai_no_decision`, `media_unscreened`, `flagged`,
   `test_bypass`), and show it in the Admin queue with age, flag count and
   flag reasons, oldest first, with paging.
8. A "Remove" action for published reports in Moderation, recorded in the
   audit log. Audit deletes too. Delete S3 media on delete, or use a soft
   delete.
9. An audit-log read endpoint and screen (read-only).
10. When an admin approves, or an edit makes a report visible, publish
    exactly as creation does: push once, socket, family alerts and a
    reporter notice. Use the same expiry rule as creation, counted from the
    original submission time. (D6, D7)
11. A timeout on the Bedrock client, matching OpenAI's 15 seconds, so an
    outage becomes pending quickly.

### P1: the reporter's view
12. Show "Sending…" until the server answers. Then show one of:
    - **Live:** "Your report is live. People nearby with community alerts on will see it."
    - **Being checked:** "We're checking your report. It isn't public yet."
    - **Not published:** the reason, with **Edit and resubmit**.
    - **Didn't send:** "Your report didn't send. Nothing was posted." with **Try again**.
13. Add a **Pending** tab to My ALRTs.
14. Send an idempotency key with each submission, so a retry cannot post
    twice.
15. Make "Listen" read the sanitised summary for community reports, not the
    raw description.

### P2
16. A per-person posting limit and near-duplicate grouping (D4).
17. Decide the faces rule (D5) and document the video workflow rules in the
    repository.

---

## 7. Local scenario results (not TEST)

Run on 27 September 2026 against `ea93889` backend code. Throwaway database,
mock AI (answers set by keyword), mock S3, Firebase sends recorded by a
probe. No real device, person or TEST resource was involved. The scripts are
in the session scratchpad and can be added to the repository if you want
them.

| ID | Scenario | Result |
|---|---|---|
| AUTO-1 | Benign report | accepted, expires in 30 min, visible to others, 1 push |
| REJ-1 | Spam | rejected, "This submission does not describe a hazard.", hidden, 0 pushes |
| VIS-1 | Other user opens the rejected report by id | **200, report returned** (defect) |
| FAIL-1 | AI returns HTTP 500 | pending, hidden from others, visible to the reporter |
| PROMPT-1 | AI answer without `reviewStatus` (old prompt shape) | pending, no feedback text |
| DUMMY-1 | `useDummyAi` on a TEST server | pending, "TEST bypass…" |
| MEDIA-1 | Photo attached, screening service unreachable | pending, photo kept, "media could not be automatically screened" |
| DUP-1 | The same report twice | **2 alerts, 2 pushes** |
| EDIT-1 | Approved report edited into spam | rejected, hidden |
| EDIT-2 | Rejected report edited into acceptable text | accepted and visible, **0 pushes** |
| ADM-1 | Admin pending queue | lists all pending; flagged and no-status reports show an empty reason |
| ADM-2 | Admin approves a pending report | accepted, audited, 6-hour expiry, **0 pushes, no reporter notice** |
| EDIT-3 | Author edits after an admin rejection | **accepted** (the admin decision was overturned) |
| FLAG-1 | 3 flags from 3 people | pending, hidden, no reason recorded |
| EXP-1 | Expired report | gone from lists; **still returned by id** |
| EXP-2 | Pending reports' expiry | **6 pending reports with no expiry** |
| ADM-3 | Admin delete | deleted, **no audit row** |

Not run locally: inappropriate-image screening (Sightengine unreachable,
and no mock without a code change) and real push delivery.

### TEST scenarios to run once access is available

Use accounts named `TEST moderation …`, a location with no real subscribers
(or only testers' own phones), titles starting "TEST, not a real alert",
and a TEST build with `USE_DUMMY_AI_FOR_REPORTS=false`. Run the 17 rows
above, plus:

- **MEDIA-2:** a clearly labelled harmless photo containing a face. Expect the photo to be removed and the report to publish, per the current rule.
- **MEDIA-3:** a landscape photo. Expect it to be kept and the report to publish.
- **FAIL-2:** temporarily blank the AI key on TEST only. Expect pending within about 20 seconds.

Record the server log line, the Admin queue entry and a screenshot of both
phones for each.

---

## 8. Decisions I need from you

| # | Decision | My recommendation |
|---|---|---|
| D1 | Turn off the TEST "skip AI" build flag so TEST reports get the real rules? | Yes. Keep a separate, clearly labelled no-AI build only if needed. |
| D2 | If the TEST or production database holds the old prompt text, may I update the four user-report prompts to the repository default (content only), on TEST first? | Yes on TEST now. Production only with your separate approval. |
| D3 | Should new accounts be treated differently (for example, their first N reports go to review)? Today they aren't. | Keep as is unless abuse appears. It would be a new rule, so it's your call. |
| D4 | Add a per-person posting limit and duplicate grouping? No limit exists today. | Yes, but you choose the numbers; I won't invent them. |
| D5 | "Any face removes the photo" is strict: a street scene with a bystander is dropped. Keep it, or blur faces instead? | Keep until a blur step exists. |
| D6 | Should pending reports expire, and should a late approval be dated from submission? | Yes, both: same length as an automatic approval, counted from submission. |
| D7 | Should an admin approval, or an edit that makes a report visible, send the usual push? | Yes, once, with the same rules as creation. Skip it if the report would already have expired. |
| D8 | After an admin rejection, or 3 flags, can the author's edit republish automatically? | No. Edits after an admin rejection or flags go to pending. |
| D9 | Profane or discriminatory reports that describe a real hazard are published with a neutral title. Keep that? | Keep, but stop returning and reading aloud the raw description to others. |

# Review prompt for the new ALRT prompt document

How to use: open a new Claude or GPT chat, attach (1) your new ALRT prompt document, (2) the "Everything to cross-check against" files listed below, then paste the prompt block. If the AI can read the repo, tell it the branch name. Nothing in this prompt changes production.

## Everything to cross-check against
- All 23 AI prompts from Admin > AI Prompts (export each prompt name, text, model, and where it is used).
- The source library: every row in Admin > Sources (name, ID, type, region, status, severity filter, push policy), plus the source list in backend/src/services/ingestion.service.ts.
- frontend/docs/ALRT_ALERT_CLASSIFICATION_AND_CONTENT_STANDARD.md (Standard v1.2).
- backend/src/utils/ai-prompt.util.ts and ai-prompt.service.ts (default prompts), backend/src/services/ask_alrt/system_prompt.ts and askalrt/functions/src/askalrt/systemPrompt.ts (the two Ask ALRT system prompts).
- docs/SOURCE_ONBOARDING_SKILL.md and docs/ADMIN_ALERT_PRESENTATION_SPEC.md.
- frontend/CLAUDE.md and backend/CLAUDE.md (locked rules).

## The prompt (copy everything below this line)

You are a senior QA reviewer for the ALRT emergency alert app. I have written a NEW ALRT prompt document (attached). Your job is to review it, cross-reference it against all my other AI prompts and my source library, and tell me plainly whether it collects everything correctly and will produce what is required. Do not rewrite the document unless I ask. Do not invent facts. If something is missing from the files I gave you, say "not provided" instead of guessing.

RULES THAT ARE SETTLED (do not question them, check the document obeys them):
1. Severity is assigned by code, never by the AI (Rule Zero). The AI may only extract, summarise and suggest actions.
2. Colour shows severity. Locked band colours: Info #8A93A0, Monitor #F5C518, Action #F07E1B, Critical #DA1F2D. Shape shows the source system: AWS triangle, official diamond, humanitarian square, community circle, ALRT Intel shield.
3. An agency's own warning level (Advice, Watch and Act, Emergency Warning) must never be lost or downgraded. Drills, tests and resolved incidents are Info.
4. Official AWS and verified official emergency warnings are always on.
5. No specific emergency number in any user-facing or AI text; use "your local emergency number" unless an emergency service states a number.
6. No reporter name or photo is ever shown on the map; plain English; no en-dashes in output text.

STEP 1: INVENTORY
List every field, instruction, rule, example and output format in the new document. Number them (N1, N2...). Then list every prompt I attached (P1...P23) and every source (S1...) with one line each.

STEP 2: COVERAGE MATRIX (table)
For each source S and each alert type it produces, show: what the source supplies, what the new document extracts, what the app shows (title, summary, category, sub-category, severity band, shape, colour, icon, location, time, expiry, calls to action, attribution), and any gap. Columns: Source | Field supplied | Extracted by new document? | Shown in app? | Gap or risk | Evidence (quote the line from the document).

STEP 3: PROMPT CROSS-REFERENCE (table)
For every prompt P and the new document, compare: purpose, input, output schema, severity handling, category list, word limits, tone, forbidden content, fallback. Columns: Topic | Existing prompts say | New document says | Conflict, duplicate or gap | Which should win and why. Flag any prompt that becomes redundant, any rule that exists in only one place, and any rule that two prompts state differently (for example call-to-action count or summary length).

STEP 4: FIT TEST
Take at least 12 realistic sample alerts (use real wording from my feeds if provided; otherwise write clearly labelled synthetic ones) covering: bushfire Advice, Watch and Act, Emergency Warning (AWS); planned burn with a warning; structure fire; vehicle crash; flood; severe weather; power outage; a drill or test; a resolved incident; a "Not Applicable" level; a long multi-paragraph agency warning; a non-English or messy feed item; a community report; a global humanitarian event. For each, run the new document's instructions and show the expected output exactly as the app would receive it (title, summary, category, calls to action, confidence) and the severity band the CODE would assign. Mark each PASS or FAIL against the rules above and say why. Point out anywhere the document would let the AI choose severity, invent a place, number or warning, or drop the official level.

STEP 5: SAFETY, PRIVACY AND WORDING CHECK
Check for: any emergency number, any claim that ALRT contacts emergency services, any reporter identity, medical or legal advice, fear language, instructions that conflict with official agency advice, and any wording that is hard for a stressed or hard-of-hearing person to read quickly (target: short sentences, plain words, no jargon).

STEP 6: VERDICT
Give three lists: (a) Verified correct (with evidence), (b) Wrong or missing (ranked by risk: safety first, then correctness, then clarity), (c) Cannot be verified from what I provided (say exactly which file or sample you need). Then give a one-paragraph plain-English answer: "Is it ready to use? Yes, no, or yes with these fixes."

STEP 7: FIXES
For each item in (b), give the exact replacement wording or the exact line to add, and name which existing prompts must be edited so everything stays consistent. Finish with a short regression checklist I can re-run after any change.

Output format: short headings, tables for Steps 2 and 3, plain English, no en-dashes. Do not claim anything is verified unless you can quote the evidence.

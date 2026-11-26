# Development progress — 5 November 2026

Plan: docs/alert-wording-display-plan-20261105.md

Task 1: implemented — grounded fallback and advice supplementation; regression tests observed failing before correction. Retained original source paragraphs in fallback presentation after review identified heuristic omissions.
Task 2: implemented — exact published guide category only, no broad parent inheritance. Added library exact-category rule after confirming utilities advice incorrectly matched structure fire.
Task 3: implemented — two displayed facts without repeated generated intro; agency-first advice and labelled ALRT supplement; selected needs only; published empty profile rows no longer fall back to bundled stale rows. Targeted Flutter 21 checks pass.
Task 4: draft prepared — local prompt contract/activation notes and existing admin content preview notice. Major combined-preview redesign intentionally deferred because owner is unsure; production untouched.

Ruling: Preserve all essential agency instructions even above the normal 2–4 target — shortening must never remove conditions.
Ruling: Allow fewer facts/advice points when supported/reviewed material is sparse — no filler.
Ruling: Full original fallback description stays visible — a heuristic cannot prove it found every instruction. Raw record remains intact; display applies existing number policy.
Ruling: Keep changes in the existing isolated development branch; no merge, publish or deployment.

Verification: backend 186/186 (24 files), admin 85/85 (20 files), targeted Flutter 21/21, admin production build succeeds. Initial high-concurrency runs timed out; both full suites passed with maxWorkers=2 and unchanged test timeouts. git diff --check passes. No device visual QA or TEST deployment completed.

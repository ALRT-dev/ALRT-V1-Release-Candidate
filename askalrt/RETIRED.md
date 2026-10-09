# Retired: Ask ALRT now runs in the backend

As of 6 Oct 2026 Ask ALRT no longer uses this Firebase function, Firestore,
Firebase Auth or App Check. It lives in `backend/` (`src/services/ask_alrt.service.ts`
and `src/services/ask_alrt/`), reads its answers, emergency numbers and daily
counters from Postgres, and calls Claude Haiku through AWS Bedrock.

- App: `POST /api/ask-alrt` with the normal ALRT login.
- Admin Portal: answers and emergency numbers are edited at `/api/admin/ask-alrt/*`.
- Nothing here needs deploying. The folder is kept only as a reference for the
  original rules and tests, and can be deleted once the backend version has been
  through test.

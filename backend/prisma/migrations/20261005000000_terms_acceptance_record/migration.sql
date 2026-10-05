-- Record which version of the legal text each user accepted, and when.
ALTER TABLE "User"
  ADD COLUMN "termsAcceptedAt" TIMESTAMP(3),
  ADD COLUMN "termsVersion" TEXT,
  ADD COLUMN "privacyVersion" TEXT,
  ADD COLUMN "guidelinesVersion" TEXT;

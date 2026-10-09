# R-08: Database Migration Rehearsal Report

**Date:** 2026-10-09
**Environment:** Ephemeral PostgreSQL 16.15 + PostGIS 3.4 (Ubuntu 24.04)
**Branch:** release-candidate (commit 05a32d8, all R-01 through R-07 merged)

## Summary

All 115 Prisma migrations applied cleanly from scratch with zero failures.
The resulting schema matches `prisma/schema.prisma` (53 models, 33 enums).

## Rehearsal Method

1. Fresh PostgreSQL 16 database created (`alrt_migration_rehearsal`)
2. PostGIS extension installed
3. All 115 migration SQL files applied sequentially in timestamp order
4. Prisma `_prisma_migrations` table populated to mirror `prisma migrate deploy` behaviour
5. Schema integrity validated post-migration

## Results

| Metric | Value |
|--------|-------|
| Total migrations | 115 |
| Passed | 115 |
| Failed | 0 |
| Application tables | 53 |
| Enums | 33 |
| Foreign keys | 67 |
| Indexes | 186 |
| PostGIS geometry columns | 4 |
| Unfinished migrations | 0 |
| Rolled-back migrations | 0 |

## Schema Verification

### Tables (53 application tables)

AIPrompt, AIPromptGroup, Admin, AdminAuditLog, AskAlrtConfig, AskAlrtEntry,
AskAlrtUsage, AskAlrtZone, Configuration, FamilyCheckIn, FamilyCheckInRequest,
FamilyCircle, FamilyInvite, FamilyJourney, FamilyJourneyRecipient,
FamilyLocationPing, FamilyLocationRequest, FamilyMember,
FamilyMemberHazardAlert, FamilyPlaceEvent, FamilyPlaceNotificationPref,
FamilySavedPlace, FamilyScheduledCheckIn, FamilySosEvent, FamilySosList,
FamilySosResponse, Hazard, HazardCategory, HazardCategoryImage,
HazardCorroboration, HazardFlag, HazardMedia, HazardSource,
HazardSourceLicense, HazardView, HazardVote, LocationSubscription,
PasswordResetToken, RevenueCatWebhookEvent, SafetyGuide, SafetyGuideTopic,
SponsorshipIntent, StoreSubscription, TrialRecord, User, UserBadge,
UserBlock, UserDevice, UserGuideProgress, UserPushNotificationSetting,
WebhookApiKey, WebhookLog, XpEvent

Plus `spatial_ref_sys` (PostGIS system table).

### PostGIS Geometry Columns

| Table | Column | SRID | Type |
|-------|--------|------|------|
| FamilyMember | geom | 4326 | POINT |
| Hazard | geom | 4326 | POINT |
| Hazard | geomBox | 4326 | POLYGON |
| LocationSubscription | geomBox | 4326 | POLYGON |

### Enums (33)

AIConfidence, AdminRole, CategoryImageType, CircleFundingMode,
ConfigurationKey, FamilyCheckInStatus, FamilyJourneyStatus,
FamilyLocationRequestStatus, FamilyPlaceEventType, FamilyPlaceIcon,
FamilyPlan, FamilyRole, FamilyScheduledCheckInMode, FamilySharingLevel,
FamilySnapshotSource, FamilySosResponseType, FamilySosStatus, FireStatus,
HazardFlagReason, HazardReviewStatus, HazardSeverity, HazardSeverityBand,
HazardSeveritySystem, HazardSourceHealthStatus,
HazardSourceLifecycleStatus, HazardSourceShape, HazardVoteType, MediaType,
PlanTier, SeverityLevelHandling, SourcePushPolicy,
StoreSubscriptionStatus, XpEventType

## Observations

### Duplicate Timestamp (low risk)

Two migrations share the timestamp `20260930000000`:
- `20260930000000_source_registry_review_fields` (alters `HazardSource`)
- `20260930000000_v1_review_followup` (alters `FamilySosEvent`, `FamilyLocationPing`, `StoreSubscription`)

**Risk assessment:** LOW. They touch completely different tables with no
dependencies between them. Prisma sorts alphabetically within the same
timestamp, so `source_registry_review_fields` always runs before
`v1_review_followup`. Both applied cleanly in this order.

### Migration Count vs Audit Note

The feature audit noted "34+ new since prod". The exact count of new
migrations depends on which migrations production has already applied.
All 115 apply cleanly from a blank database, confirming no SQL conflicts
exist in the full chain.

## Production Deployment Notes

1. **Run `prisma migrate deploy`** (not `prisma migrate dev`) against the
   production database. This applies only unapplied migrations.
2. **Back up the production database** before running migrations.
3. **Blue/green deployment:** Apply migrations to the new (green)
   container's database connection before switching traffic.
4. **PostGIS version:** Ensure the production PostgreSQL has PostGIS 3.x
   installed (required by spatial indexes and geometry columns).
5. **Estimated duration:** All 115 migrations completed in under 10
   seconds on an empty database. On production with data, additive
   migrations (ADD COLUMN, CREATE TABLE, CREATE INDEX) will be fast.
   The only potentially slow operation would be index creation on large
   tables, but all indexes use CONCURRENTLY-safe patterns.

## Conclusion

The migration chain is clean and ready for production deployment. No
schema conflicts, no failed migrations, no ordering issues. The
duplicate timestamp is a cosmetic issue with no functional impact.

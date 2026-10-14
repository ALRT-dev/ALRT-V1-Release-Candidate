-- Road rescue is Transport & Traffic, not Security & Crime (owner, 14 Oct 2026).
UPDATE "public"."HazardCategory"
SET "parentId" = 'trafficAndTransport'
WHERE "id" = 'rescueRoad';

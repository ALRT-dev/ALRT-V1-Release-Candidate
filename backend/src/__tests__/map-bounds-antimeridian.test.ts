import { describe, expect, it } from "vitest";
import {
  buildHazardsWhereClause,
  buildHazardsWhereClauseRaw,
} from "../utils/hazard.util.js";

/**
 * Zooming out from Australia pushes the viewport's east edge past 180, so it
 * comes back as a negative longitude and southwestLng > northeastLng. An
 * ST_MakeEnvelope with xmin > xmax is an empty box, and a plain
 * gte/lte longitude range matches nothing, so the map and the Alerts list
 * both went blank at that zoom. A wrapped viewport must be read as its two
 * real halves instead.
 */

// Perth is near 115.86E; zoom out and the east edge wraps to about -144.
const WRAPPED = {
  southwestLat: -60,
  southwestLng: 15,
  northeastLat: 20,
  northeastLng: -144,
};

const NORMAL = {
  southwestLat: -33,
  southwestLng: 115,
  northeastLat: -31,
  northeastLng: 117,
};

describe("map bounds across the antimeridian", () => {
  it("splits a wrapped viewport into two longitude ranges (raw/PostGIS)", () => {
    const { whereClause, queryParams } = buildHazardsWhereClauseRaw({
      ...WRAPPED,
      ignoreHazardLatLngBounds: true,
    } as any);

    // Two envelopes, OR'd, not one inverted one.
    const envelopes = whereClause.match(/ST_MakeEnvelope/g) ?? [];
    expect(envelopes).toHaveLength(2);
    // East half runs to 180, west half starts at -180.
    expect(queryParams).toContain(180);
    expect(queryParams).toContain(-180);
    // Every envelope has xmin < xmax.
    expect(queryParams.slice(0, 4)).toEqual([15, -60, 180, 20]);
    expect(queryParams.slice(4, 8)).toEqual([-180, -60, -144, 20]);
  });

  it("leaves an ordinary viewport as a single box (raw/PostGIS)", () => {
    const { whereClause, queryParams } = buildHazardsWhereClauseRaw({
      ...NORMAL,
      ignoreHazardLatLngBounds: true,
    } as any);

    expect(whereClause.match(/ST_MakeEnvelope/g) ?? []).toHaveLength(1);
    expect(queryParams.slice(0, 4)).toEqual([115, -33, 117, -31]);
  });

  it("splits a wrapped viewport into two longitude ranges (prisma)", () => {
    const where = buildHazardsWhereClause({
      ...WRAPPED,
      ignoreHazardLatLngBounds: true,
    } as any);

    const geo = (where.AND as any[]).find((c) => Array.isArray(c?.OR));
    const ranges = geo.OR.map(
      (c: any) =>
        c.AND.find((p: any) => p.longitude?.gte !== undefined)?.longitude,
    ).filter(Boolean);

    expect(ranges).toEqual([
      { gte: 15, lte: 180 },
      { gte: -180, lte: -144 },
    ]);
  });

  it("keeps bounds that sit on the equator or the prime meridian", () => {
    // 0 is a real coordinate; a truthiness check silently dropped the filter.
    const where = buildHazardsWhereClause({
      southwestLat: 0,
      southwestLng: 0,
      northeastLat: 10,
      northeastLng: 10,
      ignoreHazardLatLngBounds: true,
    } as any);

    const geo = (where.AND as any[]).find((c) => Array.isArray(c?.OR));
    expect(geo).toBeDefined();
    const lng = geo.OR[0].AND.find(
      (p: any) => p.longitude?.gte !== undefined,
    )?.longitude;
    expect(lng).toEqual({ gte: 0, lte: 10 });
  });
});

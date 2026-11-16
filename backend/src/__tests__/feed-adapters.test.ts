import { describe, expect, it } from "vitest";
import { arcgisToHazards, capAuToHazards, geojsonToHazards, runAdapter } from "../utils/feed_adapters.util.js";

const cap = (body: string) => `<?xml version="1.0"?><feed xmlns="http://www.w3.org/2005/Atom">${body}</feed>`;
const capAlert = (id: string, extra = "", msgType = "Alert", sender = "sa-ses@sa.gov.au") => `<entry><content type="text/xml"><alert xmlns="urn:oasis:names:tc:emergency:cap:1.2">
  <identifier>${id}</identifier><sender>${sender}</sender><sent>2026-11-16T08:00:00+10:30</sent><status>Actual</status><msgType>${msgType}</msgType><scope>Public</scope>
  ${msgType === "Cancel" ? "<references>sa-ses@sa.gov.au,OLD-1,2026-11-16T07:00:00+10:30</references>" : ""}
  <info><language>en-AU</language><category>Met</category><event>Flood</event><headline>Flood Watch and Act - Gawler River</headline>
  <description>Moderate flooding is expected along the Gawler River.</description><instruction>Avoid driving through floodwater.</instruction>
  <expires>2026-11-17T08:00:00+10:30</expires><web>https://www.ses.sa.gov.au/warnings</web>
  <parameter><valueName>AustralianWarningSystem:WarningLevel</valueName><value>Watch and Act</value></parameter>${extra}
  <area><areaDesc>Gawler</areaDesc><polygon>-34.5,138.7 -34.6,138.8 -34.7,138.7 -34.5,138.7</polygon></area></info></alert></content></entry>`;

describe("generic feed adapters", () => {
  it("reads a CAP-AU Atom feed: level, instruction, area, box and expiry, copied not rewritten", () => {
    const r = capAuToHazards(cap(capAlert("A-1")), "saSes", { categoryId: "flood", jurisdictionCountry: "AU" });
    expect(r.hazards).toHaveLength(1);
    const h = r.hazards[0]!;
    expect(h).toMatchObject({
      id: "A-1", sourceId: "saSes", title: "Flood Watch and Act - Gawler River", nativeWarningLevel: "Watch and Act",
      sourceInstructions: ["Avoid driving through floodwater."], locationName: "Gawler", categoryId: "flood",
      link: "https://www.ses.sa.gov.au/warnings", expiresAt: "2026-11-16T21:30:00.000Z", jurisdictionCountry: "AU",
    });
    expect(h.description).toContain("Warning level: Watch and Act"); // the webhook needs the level quoted
    expect(h.northeastLat).toBeCloseTo(-34.5);
    expect(h.southwestLng).toBeCloseTo(138.7);
  });

  it("filters a shared multi-agency feed by sender and reads cancellations", () => {
    const r = capAuToHazards(cap(capAlert("A-1") + capAlert("B-1", "", "Alert", "cfs@sa.gov.au") + capAlert("C-1", "", "Cancel")), "saSes", { senders: ["sa-ses@sa.gov.au"] });
    expect(r.hazards.map((h) => h.id)).toEqual(["A-1"]);
    expect(r.skipped).toEqual([{ id: "B-1", reason: "Sender cfs@sa.gov.au is not this source." }]);
    expect(r.cancelledIds).toContain("OLD-1");
  });

  it("refuses unsafe or non-CAP XML", () => {
    expect(() => capAuToHazards('<!DOCTYPE x [<!ENTITY a "b">]><feed/>', "s")).toThrow(/not valid XML/);
    expect(() => capAuToHazards("<rss><channel/></rss>", "s")).toThrow(/not a CAP alert/);
  });

  const quake = {
    type: "FeatureCollection",
    features: [
      { type: "Feature", id: "ga2026wxyz", geometry: { type: "Point", coordinates: [117.1, -31.2] },
        properties: { event_id: "ga2026wxyz", description: "Magnitude 4.6 earthquake, 20 km NE of Cadoux, WA", magnitude: 4.6, origin_time: "2026-11-16T01:02:03Z", url: "https://earthquakes.ga.gov.au/event/ga2026wxyz" } },
      { type: "Feature", id: "small", geometry: { type: "Point", coordinates: [117, -31] }, properties: { event_id: "small", description: "Magnitude 1.9", magnitude: 1.9 } },
    ],
  };
  const quakeConfig = { idField: "event_id", descriptionFields: ["description"], timeField: "origin_time", linkField: "url", categoryId: "earthquake", defaultHours: 24, minMagnitude: 3, magnitudeField: "magnitude", jurisdictionCountry: "AU" };

  it("maps a GeoJSON feed with the source's field mapping", () => {
    const r = geojsonToHazards(quake, "gaEarthquakes", quakeConfig, new Date("2026-11-16T02:00:00Z"));
    expect(r.hazards).toEqual([{
      id: "ga2026wxyz", sourceId: "gaEarthquakes", title: "Magnitude 4.6 earthquake, 20 km NE of Cadoux, WA",
      description: "Magnitude 4.6 earthquake, 20 km NE of Cadoux, WA", latitude: -31.2, longitude: 117.1,
      link: "https://earthquakes.ga.gov.au/event/ga2026wxyz", occurredAt: "2026-11-16T01:02:03.000Z",
      expiresAt: "2026-11-17T01:02:03.000Z", categoryId: "earthquake", jurisdictionCountry: "AU",
    }]);
    expect(r.skipped).toEqual([{ id: "small", reason: "Below magnitude 3." }]);
  });

  it("maps ArcGIS results, coded levels and exclusions", () => {
    const r = arcgisToHazards({ features: [
      { attributes: { OBJECTID: 7, Title: "Shark sighting", Details: "Large shark seen 200 m offshore.", Status: "Active", Beach: "Cottesloe", Sev: "2" }, geometry: { x: 115.75, y: -31.99 } },
      { attributes: { OBJECTID: 8, Title: "Old", Details: "Resolved sighting", Status: "Closed" }, geometry: { x: 115.7, y: -31.9 } },
    ] }, "sharkSmartWa", {
      idField: "OBJECTID", titleField: "Title", descriptionFields: ["Details"], locationField: "Beach", categoryId: "sharkSighting",
      levelField: "Sev", levelMap: { "2": "Warning" }, exclude: { field: "Status", values: ["closed"] }, defaultHours: 6,
    }, new Date("2026-11-16T02:00:00Z"));
    expect(r.hazards[0]).toMatchObject({ id: "7", title: "Shark sighting", locationName: "Cottesloe", nativeWarningLevel: "Warning", latitude: -31.99 });
    expect(r.hazards[0]!.description).toContain("Warning level: Warning");
    expect(r.skipped).toEqual([{ id: "8", reason: "Excluded (Status)." }]);
  });

  it("rejects a bad mapping or an unknown adapter before anything is posted", () => {
    expect(() => runAdapter("geojson", "{}", "s", { idField: "x" })).toThrow();
    expect(() => runAdapter("rss", "{}", "s", {})).toThrow(/Unknown adapter/);
    expect(() => runAdapter("geojson", "not json", "s", quakeConfig)).toThrow(/not valid JSON/);
  });
});

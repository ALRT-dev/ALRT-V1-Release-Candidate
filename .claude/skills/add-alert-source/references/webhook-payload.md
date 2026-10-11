# Webhook payload for n8n (POST /api/webhook/hazards)

Source of truth: `src/validators/webhook.validator.ts` and
`src/controllers/webhook.controller.ts` in backendV2. Re-check them if this looks stale.

Headers: `Content-Type: application/json`, `X-Webhook-Api-Key: <from n8n credential>`

```json
{
  "syncOption": "ignoreExisting",
  "allowedSeverityBands": ["monitor", "action", "critical"],
  "hazards": [
    {
      "id": "tasSes-ABC123",
      "sourceId": "tasSes",
      "title": "Flood Watch - Derwent River",
      "description": "Alert Level: Watch and Act\nMinor flooding is expected …",
      "latitude": -42.88,
      "longitude": 147.33,
      "locationName": "New Norfolk, TAS",
      "northeastLat": -42.7, "northeastLng": 147.5,
      "southwestLat": -42.9, "southwestLng": 147.0,
      "categoryId": "flood",
      "severity": "watchAndAct",
      "severityBand": "action",
      "isAwsCompliant": true,
      "callsToAction": ["Move to higher ground if advised by SES"],
      "link": "https://…/warning/ABC123",
      "occurredAt": "2026-10-08T03:00:00Z",
      "expiresAt": "2026-10-09T03:00:00Z"
    }
  ]
}
```

| Field | Required | Rules / notes |
|---|---|---|
| `sourceId` | yes | ≤50 chars, must exist as a `HazardSource` row |
| `description` | yes | 1–5000 chars. Category/severity/fireStatus are keyword-derived from it when not sent |
| `id` | strongly recommended | ≤100 chars, `<sourceId>-<nativeId>`. If omitted, a content hash is used, so wording changes create duplicates |
| `latitude`+`longitude` or `locationName` | one of them | otherwise 400. Items that can't be geocoded are dropped |
| `title` | no | ≤200. AI summary may rewrite it |
| `categoryId` | no | must exist, else 400 for that item |
| `severity` | no | `unknown` `info` `advice` `watchAndAct` `emergency` |
| `severityBand` | no | `info` `monitor` `action` `critical` (default `info` if not derivable) |
| `fireStatus` | no | `active` `beingControlled` `underControl` `closed`, fire categories only |
| `callsToAction` | no | only source-stated instructions, each ≤500 |
| `aiSummary` | no | ≤1000. If sent, it overrides the AI summary |
| `link` | no | valid URL |
| `occurredAt`, `expiresAt` | no | ISO-8601 datetime |
| `syncOption` | no | default `ignoreExisting`. Don't schedule `replaceExisting`/`deleteExisting` |
| `allowedSeverityBands` | no | applies to new hazards. Existing ones dropping below get expired |

Responses: `201` all processed · `207` partial (`errors[]` with `index`) · `400`
nothing valid · `401/403` key missing/invalid/disabled/expired · `429` rate limit
(back off; limits are per key, default 10/min, 100/h, 1000/day).

## n8n Code node sketch (map feed items → payload)

```js
const SOURCE_ID = 'tasSes';
const hazards = $input.all().flatMap(({ json: item }) => {
  const nativeId = item.identifier ?? item.guid;
  const hasGeo = item.lat != null && item.lng != null;
  if (!nativeId || (!hasGeo && !item.area)) return [];   // skip, don't guess
  return [{
    id: `${SOURCE_ID}-${nativeId}`,
    sourceId: SOURCE_ID,
    title: item.title?.slice(0, 200),
    description: `Alert Level: ${item.level}\n${item.summary}`.slice(0, 5000),
    ...(hasGeo ? { latitude: Number(item.lat), longitude: Number(item.lng) } : {}),
    ...(item.area ? { locationName: item.area.slice(0, 200) } : {}),
    ...(item.url ? { link: item.url } : {}),
    ...(item.issued ? { occurredAt: new Date(item.issued).toISOString() } : {}),
    ...(item.expires ? { expiresAt: new Date(item.expires).toISOString() } : {}),
  }];
});
return hazards.length ? [{ json: { syncOption: 'ignoreExisting', hazards } }] : [];
```

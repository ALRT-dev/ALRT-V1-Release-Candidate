# Admin "Alert presentation" editor: specification

Status: proposal for owner review, written 13 Oct 2026. Docs only. No code, migration or deployment is made by this file. Items marked "proposed" do not exist yet.

Audience: Sarah Nixon (owner) and the developer who will build it.

Goal: let an authorised admin choose how each category and each source looks in the app (icon, and where allowed, colour and shape), preview it, save it with a history, and roll it back, without ever being able to change what an official warning colour or severity band means.

Contents:
1. What exists now (from the code)
2. What is locked and cannot be edited
3. What the editor may change
4. Data model and minimal migration
5. Endpoints
6. Validation and conflict warnings
7. Audit history and rollback
8. Safe defaults
9. How the Flutter app receives it
10. Admin screen outline
11. Build order and effort
12. Findings from reading the code

---

## 1. What exists now

**Database** (`backend/prisma/schema.prisma`)
- `HazardCategory`: `id`, `name`, `description`, `color` (a hex string, optional), `keywords`, `isFireRelated`, `parentId`. **There is no icon field.** Related table `HazardCategoryImage` holds uploaded images per slot (`CategoryImageType`: info, monitor, action, critical, advice, watchAndAct, emergency, user, and four fire-status slots), each with an S3 key.
- `HazardSource`: `shape` (`HazardSourceShape`: triangle, diamond, circle, square, shield), `severitySystem`, `levelHandling`, `stickiness`, `maxInternalBand`, `pushPolicy`, plus registry, licence and health fields. There is no icon or colour field on a source.
- `AdminAuditLog`: who, action, target type and id, reason, before and after snapshots (JSON). Used by category and source updates today.

**Backend admin**
- Categories: `GET/POST/PUT/DELETE /api/admin/categories` (`backend/src/routes/admin/hazard_category.route.ts`). Read for any admin; write for admin or above. `POST` and `PUT` accept multipart image uploads in the twelve image slots. Updates write an audit entry (`hazardCategory.update`) with name, description, colour, parent, keywords and the list of image slots replaced.
- Sources: `GET/POST/PUT/DELETE /api/admin/hazard-sources` plus `/licenses`. The validators already accept `shape`, `severitySystem`, `levelHandling`, `maxInternalBand`, `pushPolicy`. Updates are audited.

**Admin portal** (`admin/src/pages`)
- `CategoriesPage.tsx`: lists categories with a colour swatch and any uploaded image; the edit form has name, description and colour (hex). The page says icon image upload is not supported in this version, even though the backend route accepts image files. So: **the Categories page has no icon upload**, and there is no icon picker.
- `SourcesPage.tsx`: lists sources and edits registry fields, lifecycle status, licensing notes and advisory text. Shape and severity-system are not shown on the form even though the API accepts them.
- `AuditLogPage.tsx`: read-only list of audit entries.

**Public read endpoints used by the app**
- `GET /api/hazard-categories` (also `/parent`, `/sub`): categories with images.
- `GET /api/hazards` (and the subscription variant): each alert embeds its `category` (with images and parent) and its `source` (with licence, shape and the rest of the registry row). See `buildHazardInclude` in `backend/src/utils/hazard.util.ts`.

**Flutter app** (`frontend/lib/features/shared`)
- Map markers (`services/hazard_service.dart`, bitmap building around lines 580 to 710): the marker is drawn by **shape x band**, 5 shapes x 4 bands = 20 bitmaps, keyed `shape_{shape}_{band}`, using `MapPinShape` and the locked band hex (`AlertCardStyle.bandShapeColor`). Category images are only a fallback, and the fire-status pins still use uploaded category images.
- The shape comes from `Hazard.effectiveMapShape` (`models/hazard_model.dart` around lines 160 to 200): the source's `shape` if the server sends one; otherwise shield for ALRT Intel, square for global humanitarian, circle for community reports, triangle for AWS-compliant alerts, diamond for everything else.
- Category colour and glyph (`models/hazard_category_model.dart`, `views/widgets/category_glyph.dart`): the seven locked categories get their colour from a fixed table inside the app (`lockedCategoryColorFor`), and the server colour is used only for a category the app does not recognise. The glyph is a Lucide icon chosen **by matching the category name** inside the app (`CategoryGlyph.iconFor`); anything else shows an exclamation mark.

**Net effect today:** changing a locked category's colour in the admin portal changes nothing in the app, and there is no way to give a new category an icon from the admin side.

## 2. What is locked and cannot be edited (by anyone, including super admin)

From `frontend/CLAUDE.md` and the Alert Classification and Content Standard:
- Band colours and meaning: Info grey `#8A93A0`, Monitor yellow `#F5C518`, Action orange `#F07E1B`, Critical red `#DA1F2D`. The four band names and what they mean.
- Official warning colours and the Australian Warning System levels and wording. The AWS triangle writes the publisher's level word; no editor can change it.
- Severity is assigned by code from the source's own text (Rule Zero). The editor never sets, shows or changes an alert's band.
- Shape meaning: AWS triangle, official diamond, community circle, ALRT shield, humanitarian square. A shape may only be changed for a source where the new shape is legitimate for that source's severity system (section 6).
- The seven category colours: Weather `#2FA6FF`, Health `#FF7E29`, Security `#D9304F`, Traffic `#00CC96`, Utilities `#FFB300`, Community `#C233DB`, Other `#A67C52`.
- Family palette, plan colours, the red SOS strip, the footer, and the ALRT logo.
- "Red is reserved for the highest severity, never for category" (same rule that moved Security away from red).
The screen shows these as read-only rows with a padlock and the reason.

## 3. What the editor may change

1. **Category icon** (proposed): choose one icon key from an approved library for any category. The seven locked categories keep their current glyph unless the owner approves a change, in which case it is a versioned change like any other. New categories get a glyph here instead of the exclamation-mark fallback.
2. **Category colour for NEW (non-locked) categories only**, from a validated palette (section 6). The seven locked colours are shown but read-only.
3. **Source shape**, within the allowed set for that source's severity system, with a warning on any change.
4. **Source badge icon** (proposed, optional): a small glyph shown with the source name on cards. Not used for markers (the shape is the marker). Default none.
5. **Per-source marker label colour: not offered.** The marker colour is the band colour. The brief asked for "marker colour per category and source"; that would let an official diamond be tinted by category and break the "colour says how urgent" rule. This spec deliberately offers category colour for chips, cards and community pins only, and leaves the map marker colour tied to the band. If the owner wants category-tinted markers, it needs an explicit product decision and a change to the locked design rules.

**Approved icon library.** The app already ships Lucide icons (`lucide_icons_flutter`). The approved library is a reviewed allow-list of Lucide icon names (for example cloud, heart-pulse, shield-alert, car, zap, users, flame, waves, wind, thermometer, triangle-alert, house, plane, train, hospital, radio-tower, droplets, mountain, siren, circle-help). The admin picks from the list; the server stores only the key (a short text). No free image upload, no SVG upload, no emoji. The allow-list lives in one shared file used by the admin portal, the server validator and the app, and grows by reviewed commit. Keep the siren and any icon that could be mistaken for an emergency-services contact out of the list unless the owner approves them.

## 4. Data model and minimal migration (proposed)

Smallest change that works. Hand-authored SQL in a timestamped folder under `backend/prisma/migrations/`, as the backend rules require.

```
-- HazardCategory: icon key (nullable, null = the app's built-in glyph for that name)
ALTER TABLE "HazardCategory" ADD COLUMN "iconKey" TEXT;

-- HazardSource: optional small badge icon key
ALTER TABLE "HazardSource" ADD COLUMN "badgeIconKey" TEXT;

-- Versioned presentation history (one row per published change set)
CREATE TABLE "AlertPresentationVersion" (
  "id"          TEXT PRIMARY KEY,
  "version"     INTEGER NOT NULL UNIQUE,
  "status"      TEXT NOT NULL,        -- draft | published | superseded
  "snapshot"    JSONB NOT NULL,       -- full presentation of every category and source at that time
  "reason"      TEXT NOT NULL,
  "createdById" TEXT,
  "createdAt"   TIMESTAMP NOT NULL DEFAULT now(),
  "publishedById" TEXT,
  "publishedAt" TIMESTAMP,
  "rolledBackFrom" INTEGER
);
```
Notes:
- `HazardCategory.color` already exists and is reused.
- `HazardSource.shape` already exists and is reused.
- No data is rewritten. Existing rows keep null icon keys and behave exactly as today.
- The `snapshot` JSON holds, for every category: id, iconKey, color; for every source: id, shape, badgeIconKey. That is enough to compare, preview and roll back.
- Alternative with even less change: skip the version table and rely on `AdminAuditLog` before/after. That gives history but makes rollback fiddly and gives no draft stage. The version table is recommended because rollback is a safety control.
- Prisma enum for `HazardSourceShape` is unchanged.

## 5. Endpoints (proposed)

All under `/api/admin/alert-presentation`, admin auth required. Read: any admin. Draft and publish: admin or above. Rollback: super admin only (suggested).

| Method and path | Purpose |
|---|---|
| `GET /` | Current published presentation plus the locked list (so the screen can show padlocks). |
| `GET /library` | The approved icon allow-list (keys, display names, preview data). |
| `POST /drafts` | Create or replace the caller's draft from a list of changes. Body: `{ changes: [{ type: "category" or "source", id, iconKey?, color?, shape?, badgeIconKey? }], reason }`. Returns the validation result. |
| `POST /drafts/:id/validate` | Re-run validation and return errors and warnings (section 6). |
| `GET /drafts/:id/preview` | The data the preview needs: for each changed category or source, sample markers (shape x band), a card and a detail header using real or sample alerts. |
| `POST /drafts/:id/publish` | Publish. Needs `reason`. Refused if there are errors; warnings must be acknowledged with `acknowledgeWarnings: true`. Writes a new version and an audit entry. |
| `GET /versions` and `GET /versions/:version` | History list and a single snapshot, with a plain-English diff against the previous one. |
| `POST /versions/:version/rollback` | Creates a NEW version whose content equals the chosen old one (history is never edited). Needs `reason`. |

Publishing writes `HazardCategory.iconKey/color` and `HazardSource.shape/badgeIconKey` in one transaction, then clears the hazard and category list caches the same way other admin saves do (`invalidateHazardListCaches`).

Existing endpoints stay: the Categories and Sources pages can still edit name, description and registry fields. To avoid two ways of changing the same field, the new publish path becomes the only way to change `iconKey`, `color` and `shape`, and the old category `PUT` and source `PUT` must reject those three fields once the feature is live (or route them through the same validators and versioning).

## 6. Validation and conflict warnings

**Errors (block publishing)**
- `iconKey` not in the approved allow-list.
- Colour not a six-digit hex.
- Any attempt to change a locked category colour, a band colour, or a source's severity-system fields.
- Shape not allowed for the source: `triangle` only for a source whose severity system is `awsLevel`; `circle` only for community; `shield` only for ALRT Intel; `square` only for a humanitarian-style source with the verbatim scale (`gdacsColour`); `diamond` for official band-style sources.
- Colour contrast of a white glyph on the chosen colour below 3 to 1.
- A colour within a set distance (for example a small perceptual distance) of any band hex, which would make a category chip look like a severity colour.

**Warnings (publish allowed after the admin acknowledges)**
- New colour is close to another category's colour (chips would be hard to tell apart).
- Two categories share the same icon.
- A source's shape differs from its default for its type (for example an official source changed from diamond).
- A change affects a category used by more than a set number of live alerts (shows the count).
- The icon is on the "unfamiliar" list (needs the app to carry the glyph; see section 9) and the app version in the field may not have it.
- A change is made within 24 hours of a previous presentation change.

**Conflict warnings between category and source.** If a category glyph and a source badge icon are both set and use the same icon, warn that the card would show it twice. If a source's shape is changed to one used by a different source system, warn that the legend (map key) in the app would be wrong until the app is updated.

## 7. Audit history and rollback

- Every draft, publish and rollback writes to `AdminAuditLog` (actions such as `alertPresentation.publish`, `alertPresentation.rollback`) with admin id, reason, and before and after snapshots. No secrets are involved.
- Every publish creates an `AlertPresentationVersion` row. The history page lists version, date, who, reason, and a diff in words ("Weather: icon changed from cloud to cloud-rain").
- Rollback never deletes or edits history. It makes a new version equal to the chosen older one, re-validates it against today's rules, and publishes it. If the old version no longer passes validation (for example an icon was removed from the allow-list), the rollback is refused with the reason.
- Emergency control: a super admin button "Restore built-in defaults" that publishes a version with all icon keys null, locked colours, and each source's default shape from `SOURCE_REGISTRY_DEFAULTS` (`backend/src/utils/source_registry.util.ts`).

## 8. Safe defaults

- Null icon key means the app's built-in glyph by category name, exactly as today. Nothing changes for any category until someone publishes.
- Null badge icon means no badge.
- Null source shape means the app's documented fallback (shield, square, circle, triangle, diamond by source type).
- A new category with no icon shows the exclamation-mark glyph in the app's fallback colour.
- Unknown icon key sent to an older app: the app falls back to the name-based glyph and never shows a blank or a broken image.
- The editor starts in view-only mode; editing needs a click on "Start draft".
- Collection of nothing personal: the editor stores no user data.

## 9. How the Flutter app receives it

No new endpoint is required for the app.

1. `GET /api/hazard-categories` (and the embedded `category` inside each alert from `GET /api/hazards`) would return the new `iconKey` and the existing `color` and `images`. The Dart model `HazardCategory` (`models/hazard_category_model.dart`) gets one optional field, `iconKey`. Old apps ignore the unknown field.
2. `GET /api/hazards` already embeds the source with its `shape`. With the optional `badgeIconKey` added to the source model (`models/hazard_source_model.dart`), the app can show a small badge. `Hazard.effectiveMapShape` already prefers the server's shape, so a published shape change reaches the map on the next refresh with no app change.
3. `CategoryGlyph.iconFor` is changed to look up `iconKey` in a constant map of allow-listed key to `LucideIcons` entry first, then fall back to the current name matching. The allow-list is therefore also compiled into the app. **A new icon key needs an app release before it can be shown**; until then the fallback glyph shows. This keeps the app from ever rendering arbitrary downloaded images as an alert symbol, which is a safety and review benefit. (The alternative, downloadable SVG icons, was rejected for this version: it needs sanitising, caching and offline handling, and it widens what an admin mistake can break.)
4. Locked category colours stay compiled into the app (`lockedCategoryColorFor`), so a server-side colour change for a locked category cannot reach users. For a new category, `resolvedColor` falls back to the server colour as it does today.
5. Caching: the app builds marker bitmaps when it loads categories and sources. A published change appears after the next normal refresh or app start; no push is needed. The server list caches are cleared on publish.
6. Backwards compatibility: no existing field is renamed or removed. Older app builds keep working unchanged.

## 10. Admin screen outline

Tab "Alert presentation" in the admin portal, three panels.
- **Left: list.** Categories (the seven locked ones with padlocks, then others) and Sources (with their shape and system). Search box.
- **Centre: editor** for the selected item. For a category: icon picker (grid from the allow-list, with the app's current glyph marked), colour (read-only with a padlock for the locked seven; palette picker for new ones), live validation messages. For a source: shape selector limited to allowed values with a warning on change, optional badge icon.
- **Right: preview.** Shows the change in place: a 4-by-5 grid of markers (shape x band) for the chosen source, a sample card, and a sample detail header, on a light and a dark background, at phone size. It also shows a side-by-side "now" versus "after". The preview never edits live data.
- **Bottom bar:** Reason (required), Validate, Publish, and a link to History (version list, diff, rollback).
- A banner states in plain words what is locked: "Severity colours and what Info, Monitor, Action and Critical mean cannot be changed here."

## 11. Build order and effort (rough)

1. Shared allow-list file and the two small migrations (category `iconKey`, source `badgeIconKey`): small.
2. App change: read `iconKey`, map to Lucide, fall back to name matching: small, needs an app release.
3. Version table, draft, validate, publish, rollback endpoints with audit: medium.
4. Admin screen with preview: medium to large (the preview should reuse the same shape and band colours as the app; keep a copy of the locked hexes in one admin file and test that it matches `frontend/CLAUDE.md`).
5. Move `color`, `shape` and `iconKey` edits behind the new path and block them on the old pages: small.
6. Tests: validator unit tests (locked colours cannot change, shape rules, contrast), a verify script for rollback, a golden check that the preview colours equal the app's locked values.

## 12. Findings from reading the code

1. **Server colour is ignored for the seven locked categories.** The app uses its own table, so editing a locked category's colour in the admin portal is silently ineffective. The seeded colours in `populateInitialCategories` (for example Security `#FC9493`) also differ from the app's locked values (`#D9304F`). Not harmful, but it confuses an admin. Recommend showing the app's locked values in the portal and disabling the colour box for those seven.
2. **Category glyph is chosen by name matching inside the app.** Renaming a category in the portal can change its icon. A stored `iconKey` fixes that.
3. **A source's shape from the server beats the app's own rules.** `effectiveMapShape` returns the server's `source.shape` first. If an admin set a community or official source to the wrong shape (the API allows any value today), the map would show it. The schema comment says user reports always render as a circle, but the Dart code only does this when the server sends no shape. Recommend a server-side guard (the validation in section 6) and an app-side guard that forces circle for user-reported alerts.
4. **Backend image upload exists but is unused in the portal.** Uploaded category images only matter today for fire-status markers and as a fallback when a shaped pin cannot be built. The new icon approach does not remove them.
5. **Icons and the humanitarian square.** `globalHumanitarianSourceIds` in the app is empty (GDACS is folded into the official diamond, 5 Oct 2026). The square can still be produced by a server shape of `square`. The editor must not set a square unless the owner reverses that decision.
6. **Two ways to edit the same field.** Until section 5's last paragraph is done, the old Categories and Sources forms could overwrite a published presentation without a version. Treat that as a launch blocker for the feature.

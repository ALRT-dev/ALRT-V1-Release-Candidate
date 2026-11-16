-- New sources (16 November 2026), registered as DRAFT: the pipeline exists,
-- nothing is ingested until an admin confirms the licence, checks the feed
-- in Sources > Preview, and switches the source on. Separate migration so
-- the new 'draft' enum value is committed before it is used.
INSERT INTO "HazardSource" ("id","name","url","country","region","coverage","sourceType","authorityLevel","feedUrl","format","accessMethod","adapterKey","adapterConfig","scheduleMinutes","warningTypes","lifecycleStatus","licensingNotes","createdAt","updatedAt")
VALUES
('tasAlert','TasALERT (Tasmanian Government)','https://www.alert.tas.gov.au','AU','TAS','Tasmania','emergency management','official',
 'https://alert.tas.gov.au/data/cap-au.xml','CAP-AU','public','cap_au','{"jurisdictionCountry":"AU"}'::jsonb,5,
 ARRAY['bushfire','flood','storm','hazmat','smoke'],'draft',
 'Feed URL from TasALERT''s published feed list; licence and terms to confirm with TasALERT before switching on.',now(),now()),
('mainRoadsWaIncidents','Main Roads WA road incidents (WebEOC)','https://travelmap.mainroads.wa.gov.au','AU','WA','Western Australia','transport','official',
 NULL,'ArcGIS','public','arcgis',NULL,10,
 ARRAY['roadClosure','flood','bushfire','detour'],'draft',
 'Open data, Creative Commons Attribution 3.0 Australia (data.gov.au dataset mrwa-webeoc-road-incidents). Add the FeatureServer query URL and field mapping after previewing.',now(),now()),
('qldStormFloodCyclone','Queensland storm, flood and cyclone warnings','https://www.disaster.qld.gov.au','AU','QLD','Queensland','emergency management','official',
 'https://publiccontent-gis-psba-qld-gov-au.s3.ap-southeast-2.amazonaws.com/content/Feeds/StormFloodCycloneWarnings/StormWarnings.json','GeoJSON','public','geojson',NULL,10,
 ARRAY['storm','flood','cyclone'],'draft',
 'Published on data.gov.au (storm-flood-and-cyclone-warnings). Licence to confirm; set the field mapping after previewing.',now(),now()),
('gaEarthquakes','Geoscience Australia earthquakes','https://earthquakes.ga.gov.au','AU',NULL,'Australia and region','geoscience','official',
 NULL,'GeoJSON','public','geojson',
 '{"idField":"event_id","descriptionFields":["description"],"timeField":"origin_time","linkField":"url","categoryId":"earthquake","defaultHours":24,"minMagnitude":3,"magnitudeField":"magnitude","jurisdictionCountry":"AU"}'::jsonb,15,
 ARRAY['earthquake'],'draft',
 'Australian earthquakes, including small felt events USGS misses. Add the Earthquakes@GA feed URL and check field names in Preview. Licence to confirm.',now(),now()),
('sharkSmartWa','SharkSmart WA (DPIRD)','https://www.sharksmart.com.au','AU','WA','WA coast','marine','official',
 NULL,'ArcGIS','request','arcgis',NULL,10,
 ARRAY['sharkSighting'],'draft',
 'Official WA shark sightings and tagged-shark detections. No public feed found: ask DPIRD (sharksmart@dpird.wa.gov.au) for data access and terms.',now(),now()),
('nswAirQuality','NSW air quality (Department of Climate Change, Energy, the Environment and Water)','https://www.airquality.nsw.gov.au','AU','NSW','New South Wales','environment','official',
 NULL,'JSON','public','geojson',NULL,60,
 ARRAY['airQualityAlert','smoke'],'draft',
 'Official hourly NSW air quality API with Air Quality Category. Needs a small transform (n8n) to GeoJSON; licence to confirm.',now(),now())
ON CONFLICT ("id") DO NOTHING;

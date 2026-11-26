import { describe, expect, it } from 'vitest';
import { getDeterministicDfesContent } from '../utils/dfes_template.util.js';
import { withPublicCoords } from '../utils/hazard.util.js';

const title = 'Smoke Alert FOR KARRAGULLEN, ROLEYSTONE AND SURROUNDING AREAS IN THE CITY OF ARMADALE';
const description = `Region: METRO SOUTH EAST
The following alert has been issued by
the Parks and Wildlife Service at the Department of Biodiversity, Conservation and Attractions.
This is a new alert.
Time of issue:
08:34 AM
Date of issue:
08 Nov 2026
Smoke Alert
for KARRAGULLEN, ROLEYSTONE and surrounding areas in the CITY OF ARMADALE
• A Smoke Alert has been issued for people in KARRAGULLEN, ROLEYSTONE and surrounding areas in the CITY OF ARMADALE.
• The smoke is the result of prescribed burning being carried out in the area.
• Smoke may affect roads in the area and settle in low lying areas overnight before clearing Monday morning.
WHAT TO DO
• Shut doors and windows and turn off air-conditioners.
• If driving through the area, turn on headlights and drive slowly. If you cannot
see clearly, pull over to the left, keep your headlights and hazard lights on, and wait until the smoke clears.
• People with asthma and pre-existing respiratory or cardiovascular illnesses should follow their pre-prepared treatment plan.
• Watch for emergency services personnel and follow their directions.
ROAD CLOSURES AND CONDITIONS
Motorists are asked to avoid the area, reduce speed and drive carefully.
Road information may also be available from Main Roads WA by visiting the Main Roads Travel Map.
KEEP UP TO DATE
• Visit Emergency WA.
END
Media Contact: DBCA Media on 9219 9999.`;

describe('DFES distributed smoke bulletin', () => {
  it('declines ambiguous audience headings rather than removing instruction scope', () => {
    expect(getDeterministicDfesContent({title:'Smoke Alert for Example', description:
      'Region: Metro\n• Smoke is present.\nWHAT TO DO\n• Shut windows.\nPeople with asthma:\n• Follow your treatment plan.'})).toBeNull();
  });
  it('retains leading and interspersed conditional headings on their following actions', () => {
    const source = 'Region: Metro\n• Smoke is present.\nWHAT TO DO\nIf driving through the area:\n• Turn on headlights.\n• Drive slowly.\nWhen at home:\n• Shut windows.\nKEEP UP TO DATE\n• Visit Emergency WA.';
    const result = getDeterministicDfesContent({title:'Smoke Alert for Example',description:source});
    expect(result?.contentDetails?.officialActions).toEqual([
      'If driving through the area: Turn on headlights.',
      'If driving through the area: Drive slowly.',
      'When at home: Shut windows.',
    ]);
  });
  it('selects incident facts rather than metadata and keeps complete instruction conditions', () => {
    const value = getDeterministicDfesContent({title, description});
    expect(value).not.toBeNull();
    expect(value!.contentDetails!.facts).toHaveLength(3);
    expect(value!.summary).toContain('prescribed burning');
    expect(value!.summary).not.toMatch(/Road information|following alert|Time of issue|This is a new/);
    expect(value!.contentDetails!.officialActions).toHaveLength(5);
    expect(value!.contentDetails!.officialActions[1]).toContain('If you cannot see clearly');
    expect(value!.contentDetails!.officialActions.join(' ')).not.toMatch(/Region:|Media Contact|KEEP UP TO DATE/);
    expect((value!.contentDetails as any).issuingAgency).toBe('Parks and Wildlife Service (DBCA)');
    expect((value!.contentDetails as any).originalSourceText).toBe(description);
  });
  it('repairs stored malformed content without changing lifecycle or category', () => {
    const source = {sourceId:'waDfes', title, description, categoryId:'airQualityAlert', reportedById: null,
      status:'expired', expiresAt:'2026-11-08', callsToAction:[description],
      contentDetails:{templateVersion:4, facts:['Road information may also be available.'],
        sourceUpdate:{summary:'Source changed',detectedAt:'2026-11-08T00:34:00Z'}}};
    const value = withPublicCoords(source);
    expect(value.callsToAction).not.toContain(description);
    expect(value.contentDetails.facts.join(' ')).toContain('prescribed burning');
    expect(value.contentDetails.sourceUpdate).toEqual(source.contentDetails.sourceUpdate);
    expect(value.categoryId).toBe('airQualityAlert');
    expect(value.status).toBe('expired');
    expect(source.callsToAction).toEqual([description]);
  });
  it('does not classify incident metadata or an unrelated bulletin as this format', () => {
    expect(getDeterministicDfesContent({title:'Fuel Leak - BEDFORDALE',description:'Region: X\nWHAT TO DO\n• Example.'})).toBeNull();
  });
});

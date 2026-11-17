/** Source-specific adapter for the distributed smoke bulletin format.
 * Not a generic keyword fallback: only source waDfes callers may use it. */
export function buildDfesSmokeBulletin(title: string, description: string, templateVersion = 0) {
  if (!/^smoke alert\b/i.test(title.trim()) ||
      !/^Region:\s*.+/im.test(description) ||
      !/^WHAT TO DO\s*:?\s*$/im.test(description)) return null;
  const lines = description.replace(/\r\n/g, '\n').split('\n').map(x => x.trim());
  const start = lines.findIndex(line => /^WHAT TO DO\s*:?$/i.test(line));
  const bullet = /^[•·*-]\s+/;
  const heading = /^(?:ROAD CLOSURES?(?: AND CONDITIONS)?|KEEP UP TO DATE|EXTRA INFORMATION|MORE INFORMATION|END)\s*:?$/i;
  function points(section: string[], instructions = false) {
    const result: string[] = [];
    let context = '';
    for (const line of section) {
      if (!line) continue;
      if (instructions && (/^(?:if|when|for)\b.+:\s*$/i.test(line) || /^if driving(?: through (?:the )?area)?\s*:?$/i.test(line))) {
        context = line;
        continue;
      }
      // A different audience/section heading could change the scope. Decline
      // rather than attach it to the previous instruction and weaken the next.
      if (instructions && !bullet.test(line) && /:\s*$/.test(line)) return null;
      if (bullet.test(line)) result.push([context, line.replace(bullet, '')].filter(Boolean).join(' '));
      else if (result.length) result[result.length - 1] += ` ${line}`;
      else return null;
    }
    return result;
  }
  // Start at the first incident bullet, avoiding all publisher/date/title preamble.
  const firstFact = lines.findIndex(line => bullet.test(line));
  if (firstFact < 0 || firstFact >= start) return null;
  const facts = points(lines.slice(firstFact, start))?.slice(0, 4);
  if (!facts) return null;
  if (!facts.some(fact => /\bsmoke\b/i.test(fact))) return null;
  const stop = lines.findIndex((line, i) => i > start && heading.test(line));
  const actions = points(lines.slice(start + 1, stop < 0 ? undefined : stop), true);
  if (!actions) return null;
  // This section contains an additional genuine driving instruction. Keep it,
  // while leaving contact/help/footer information in the original bulletin.
  const road = lines.findIndex(line => /^ROAD CLOSURES?(?: AND CONDITIONS)?\s*:?$/i.test(line));
  if (road >= 0) {
    const roadEnd = lines.findIndex((line, i) => i > road && heading.test(line));
    const roadText = lines.slice(road + 1, roadEnd < 0 ? undefined : roadEnd).join(' ');
    const instruction = roadText.match(/\bMotorists are asked to [^.]+\./i)?.[0];
    if (instruction) actions.push(instruction);
  }
  const issuingAgency = /Parks and Wildlife Service[\s\S]{0,100}Department of Biodiversity,\s*Conservation and Attractions/i.test(description)
    ? 'Parks and Wildlife Service (DBCA)' : 'DFES WA';
  return {
    title, summary: facts.map(fact => `• ${fact}`).join('\n'),
    callsToAction: actions.map(action => `${issuingAgency} advises: ${action}`),
    confidence: 'high' as const,
    contentDetails: {
      schemaVersion: 1, templateVersion, extractionMethod: 'dfes-smoke-bulletin',
      facts, officialActions: actions, alrtSuggestions: [], affectedAreas: [], nativeLevel: null,
      // Smoke-specific reviewed local library; the user's choices never leave the device.
      profileGuidance: [], profileGuidancePolicy: 'bundledFallback',
      evidence: facts, originalSourceText: description, issuingAgency,
      sourceIncidentType: 'Smoke alert',
    },
  };
}

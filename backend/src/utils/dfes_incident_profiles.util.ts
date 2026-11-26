import type { AgencyExtractionResult } from './agency_extraction.util.js';

// Neutral ALRT planning rows, reviewed 9 Nov 2026 against DFES preparation
// and smoke FAQs. Sent generically; profile selection remains on the phone.
// Publish rows explicitly so older clients do not select stale bundled advice.
const rows = {
  "bushfire": [
    [
      "older",
      "Checking who can help you carry out your bushfire plan, and keeping their contact details handy, may help."
    ],
    [
      "kids",
      "Checking your school or childcare emergency arrangements and agreeing who will contact them may help."
    ],
    [
      "mobility",
      "Checking that your bushfire plan includes accessible transport, equipment and someone who can assist may help."
    ],
    [
      "medical",
      "Checking that your emergency kit covers the supplies and equipment in your usual care plan may help."
    ],
    [
      "deaf",
      "Checking written official updates and agreeing how a trusted person will contact you may help."
    ],
    [
      "vision",
      "Reviewing your bushfire plan in an accessible format with someone who can assist may help."
    ],
    [
      "visitor",
      "Asking your accommodation provider about its bushfire plan and how it receives official warnings may help."
    ],
    [
      "worker",
      "Checking your workplace bushfire plan and how your employer will communicate changes may help."
    ],
    [
      "pets",
      "Including carriers, leads, supplies and a suitable place for your animals in your bushfire plan may help."
    ]
  ],
  "smoke": [
    [
      "older",
      "If you rely on someone for support, agreeing how you will check smoke updates together may help."
    ],
    [
      "kids",
      "If smoke affects school or childcare activities, checking their current arrangements may help you coordinate care."
    ],
    [
      "mobility",
      "Checking that your emergency plan includes the support and equipment you rely on may help if smoke affects you."
    ],
    [
      "medical",
      "Having your existing care plan and usual health-service contact details available may help if smoke affects you."
    ],
    [
      "deaf",
      "Checking written official smoke updates and agreeing how a trusted person will contact you may help."
    ],
    [
      "vision",
      "Using accessible official updates, or asking a trusted person to read them with you, may help."
    ],
    [
      "visitor",
      "Checking official smoke and road updates for the places you plan to visit may help."
    ],
    [
      "worker",
      "If your work is outdoors, checking your employer's arrangements for smoky conditions may help."
    ],
    [
      "pets",
      "Checking that your household emergency plan includes animal supplies and care arrangements may help."
    ]
  ]
} as const;

export function incidentPlanningProfiles(kind: 'bushfire' | 'smoke'): AgencyExtractionResult['contentDetails']['profileGuidance'] {
  return rows[kind].map(([tag,text]) => ({
    id: `dfes-incident-${kind}-${tag}-20261109`, text, profileTags: [tag],
    reference: kind === 'smoke' ? 'https://www.dfes.wa.gov.au/emergencywa/faq' : 'https://www.dfes.wa.gov.au/hazard-information/bushfire/prepare',
    reviewedAt: '2026-11-09',
  }));
}

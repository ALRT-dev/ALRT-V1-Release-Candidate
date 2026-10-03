/**
 * Starting list of emergency numbers shown in the Admin Portal.
 *
 * This mirrors the table in the mobile app
 * (frontend/lib/features/shared/services/emergency_number.dart) so an admin can
 * copy it into the editable list with one click. It is a SNAPSHOT: the Cloud
 * Function (askalrt/functions/src/lib/emergencyLogic.ts) ships only the first
 * eight countries, so the Ask ALRT assistant knows the rest only once they are
 * saved from the portal.
 *
 * Keep it conservative: list a country only where the number is unambiguous.
 */
export interface EmergencyNumberDefault {
  iso: string;
  name: string;
  number: string;
}

export const EMERGENCY_NUMBER_DEFAULTS: readonly EmergencyNumberDefault[] = [
  { iso: "AU", name: "Australia", number: "000" },
  { iso: "NZ", name: "New Zealand", number: "111" },
  { iso: "GB", name: "United Kingdom", number: "999" },
  { iso: "IE", name: "Ireland", number: "112" },
  { iso: "US", name: "United States", number: "911" },
  { iso: "CA", name: "Canada", number: "911" },
  { iso: "MX", name: "Mexico", number: "911" },
  { iso: "AT", name: "Austria", number: "112" },
  { iso: "BE", name: "Belgium", number: "112" },
  { iso: "BG", name: "Bulgaria", number: "112" },
  { iso: "HR", name: "Croatia", number: "112" },
  { iso: "CY", name: "Cyprus", number: "112" },
  { iso: "CZ", name: "Czechia", number: "112" },
  { iso: "DK", name: "Denmark", number: "112" },
  { iso: "EE", name: "Estonia", number: "112" },
  { iso: "FI", name: "Finland", number: "112" },
  { iso: "FR", name: "France", number: "112" },
  { iso: "DE", name: "Germany", number: "112" },
  { iso: "GR", name: "Greece", number: "112" },
  { iso: "HU", name: "Hungary", number: "112" },
  { iso: "IS", name: "Iceland", number: "112" },
  { iso: "IT", name: "Italy", number: "112" },
  { iso: "LV", name: "Latvia", number: "112" },
  { iso: "LI", name: "Liechtenstein", number: "112" },
  { iso: "LT", name: "Lithuania", number: "112" },
  { iso: "LU", name: "Luxembourg", number: "112" },
  { iso: "MT", name: "Malta", number: "112" },
  { iso: "NL", name: "Netherlands", number: "112" },
  { iso: "NO", name: "Norway", number: "112" },
  { iso: "PL", name: "Poland", number: "112" },
  { iso: "PT", name: "Portugal", number: "112" },
  { iso: "RO", name: "Romania", number: "112" },
  { iso: "RS", name: "Serbia", number: "112" },
  { iso: "SK", name: "Slovakia", number: "112" },
  { iso: "SI", name: "Slovenia", number: "112" },
  { iso: "ES", name: "Spain", number: "112" },
  { iso: "SE", name: "Sweden", number: "112" },
  { iso: "CH", name: "Switzerland", number: "112" },
  { iso: "TR", name: "Turkey", number: "112" },
  { iso: "UA", name: "Ukraine", number: "112" },
  { iso: "CN", name: "China", number: "110" },
  { iso: "HK", name: "Hong Kong", number: "999" },
  { iso: "IN", name: "India", number: "112" },
  { iso: "ID", name: "Indonesia", number: "112" },
  { iso: "JP", name: "Japan", number: "110" },
  { iso: "KR", name: "South Korea", number: "112" },
  { iso: "MY", name: "Malaysia", number: "999" },
  { iso: "PH", name: "Philippines", number: "911" },
  { iso: "SG", name: "Singapore", number: "999" },
  { iso: "TW", name: "Taiwan", number: "110" },
  { iso: "TH", name: "Thailand", number: "191" },
  { iso: "AE", name: "United Arab Emirates", number: "999" },
  { iso: "QA", name: "Qatar", number: "999" },
  { iso: "SA", name: "Saudi Arabia", number: "911" },
  { iso: "ZA", name: "South Africa", number: "112" },
  { iso: "KE", name: "Kenya", number: "999" },
];

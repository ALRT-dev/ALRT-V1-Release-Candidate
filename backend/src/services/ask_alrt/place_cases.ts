import type { PlaceContext } from "./place.js";

/**
 * The fixed Ask ALRT place test set (audit, 16 Nov 2026). Run by the unit
 * tests and by the daily assurance check. expected = the jurisdiction the
 * answer must use, or null when Ask ALRT must ask which place.
 */
const perth: PlaceContext = { deviceCountry: "AU", deviceState: "WA" };
const sydney: PlaceContext = { deviceCountry: "AU", deviceState: "NSW" };
const brisbane: PlaceContext = { deviceCountry: "AU", deviceState: "QLD" };
const adelaide: PlaceContext = { deviceCountry: "AU", deviceState: "SA" };

export const PLACE_CASES: { question: string; ctx: PlaceContext; expected: string | null }[] = [
  { question: "What are the road rules for kids in car seats?", ctx: perth, expected: "AU-WA" },
  { question: "What are the road rules in Bali?", ctx: perth, expected: "ID" },
  { question: "What number do I call in Japan?", ctx: perth, expected: "JP" },
  { question: "What do I do in a bushfire?", ctx: perth, expected: "AU-WA" },
  { question: "What does Watch and Act mean?", ctx: sydney, expected: "AU-NSW" },
  { question: "Can I drive through floodwater?", ctx: brisbane, expected: "AU-QLD" },
  { question: "Is it legal to carry pepper spray?", ctx: perth, expected: "AU-WA" },
  { question: "Is it legal to carry pepper spray in Queensland?", ctx: perth, expected: "AU-QLD" },
  { question: "Do I need a permit to light a fire this weekend in Margaret River?", ctx: perth, expected: "AU-WA" },
  { question: "What's the emergency number here?", ctx: { deviceCountry: "ID" }, expected: "ID" },
  { question: "What's the emergency number?", ctx: perth, expected: "AU-WA" },
  { question: "How do I prepare for a cyclone in Port Hedland?", ctx: sydney, expected: "AU-WA" },
  { question: "Is the air safe to go outside?", ctx: { ...perth, alertJurisdiction: "AU-WA" }, expected: "AU-WA" },
  { question: "What's the speed limit near schools?", ctx: perth, expected: "AU-WA" },
  { question: "What's the speed limit near schools in Victoria?", ctx: perth, expected: "AU-VIC" },
  { question: "Can I take my dog to an evacuation centre?", ctx: perth, expected: "AU-WA" },
  { question: "What should I do in an earthquake in Japan?", ctx: perth, expected: "JP" },
  { question: "Do I need travel insurance for Bali?", ctx: perth, expected: "ID" },
  { question: "How do I report a gas leak?", ctx: adelaide, expected: "AU-SA" },
  { question: "Who do I call for storm damage?", ctx: perth, expected: "AU-WA" },
  { question: "What's a boil water notice?", ctx: perth, expected: "AU-WA" },
  { question: "Is it safe to swim at Bondi after the storm?", ctx: perth, expected: "AU-NSW" },
  { question: "Are there sharks at Cottesloe today?", ctx: sydney, expected: "AU-WA" },
  { question: "What's the drink-drive limit in Bali?", ctx: perth, expected: "ID" },
  { question: "What should I pack in an emergency kit?", ctx: perth, expected: "AU-WA" },
  { question: "Are fireworks legal on New Year's?", ctx: perth, expected: "AU-WA" },
  { question: "What does an orange air quality rating mean?", ctx: perth, expected: "AU-WA" },
  { question: "What are the laws on child car seats?", ctx: {}, expected: null },
  { question: "What are the laws on child car seats?", ctx: { deviceCountry: "AU" }, expected: null },
  { question: "Road rules in Tokyo for cyclists?", ctx: perth, expected: "JP" },
  { question: "Is it a total fire ban in WA today?", ctx: sydney, expected: "AU-WA" },
  { question: "What do I do in a flood in New South Wales?", ctx: perth, expected: "AU-NSW" },
];

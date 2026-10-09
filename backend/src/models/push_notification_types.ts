export enum PushNotificationType {
  viewHazard = "viewHazard",

  // Scoring: opens the safety profile, where the badge grid lives.
  badgeEarned = "badgeEarned",

  // Family Mode — all deep-link into the family hub unless noted
  familyCheckIn = "familyCheckIn",
  familyCheckInRequest = "familyCheckInRequest",
  familyPlaceEvent = "familyPlaceEvent",
  familySos = "familySos", // deep-links into the SOS receiver screen
  familySosResponse = "familySosResponse",
  familySosResolved = "familySosResolved",
  // To the SOS sender only, about 10 minutes before liveUntil: opens their
  // SOS so they can extend it by an hour or end it.
  familySosEndingSoon = "familySosEndingSoon",
  familyHazardProximity = "familyHazardProximity", // deep-links into the hazard
  familyCircleUpdate = "familyCircleUpdate",
  familyLocationRequest = "familyLocationRequest", // opens the Share once / Not now screen
  familyLocationShared = "familyLocationShared",
  familyScheduledCheckInPrompt = "familyScheduledCheckInPrompt", // Daily reminder to check in
  familyJourneyShared = "familyJourneyShared", // sent only to the picked recipients

  // A test the signed-in user sent to their own phones from Manage
  // notifications. Never reaches anyone else.
  testNotification = "testNotification",
}

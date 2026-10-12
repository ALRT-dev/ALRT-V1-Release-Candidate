enum PushNotificationType {
  unknown,
  viewHazard,

  // Scoring: a badge was earned; tapping opens the safety profile, where
  // the badge shelf lives.
  badgeEarned,

  // Family Mode
  familyCheckIn,
  familyCheckInRequest,
  familyPlaceEvent,
  familySos,
  familySosResponse,
  familySosResolved,
  // To the SOS sender only, about 10 minutes before their SOS's end time
  // (data: sosEventId, circleId). Tapping opens their running SOS, where
  // "Extend 1 hour" lives.
  familySosEndingSoon,
  familyHazardProximity,
  familyCircleUpdate,
  familyLocationRequest,
  familyLocationShared,
  familyScheduledCheckInPrompt,
  familyJourneyShared,
  // A member sent a public alert to their group from the alert detail
  // screen ("Send to my group"). Payload carries hazardId (and circleId),
  // never a location; tapping opens that alert.
  familyHazardShare,

  // A test the signed-in user sent to their own phones.
  testNotification,
}

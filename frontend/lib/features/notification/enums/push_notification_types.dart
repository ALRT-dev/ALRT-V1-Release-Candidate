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
  familyHazardProximity,
  familyCircleUpdate,
  familyLocationRequest,
  familyLocationShared,
}

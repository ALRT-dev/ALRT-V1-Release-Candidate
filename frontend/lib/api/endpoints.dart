const kUrlBase = 'https://api.safetyalrt.com';
// const kUrlBase = 'http://192.168.1.67:9000';
const kUrlBaseDev = 'http://192.168.1.67:9000';

const kUrlApi = '/api';

// ---------------------------- AUTH ----------------------------

const kUrlAuth = '$kUrlApi/auth';

const kUrlOAuthGoogle = '$kUrlAuth/oauth/google';
const kUrlOAuthApple = '$kUrlAuth/oauth/apple';
const kUrlOAuthMicrosoft = '$kUrlAuth/oauth/microsoft';
const kUrlRefreshToken = '$kUrlAuth/refresh-token';
const kUrlEmailLogin = '$kUrlAuth/email-password/login';
const kUrlEmailRegister = '$kUrlAuth/email-password/register';

// ---------------------------- ONBOARDING ----------------------------

const kUrlOnboarding = '$kUrlApi/onboarding';

const kUrlOnboardingAcceptDisclaimer = '$kUrlOnboarding/accept-disclaimer';
const kUrlOnboardingAcceptTos = '$kUrlOnboarding/accept-tos';
const kUrlOnboardingLocation = '$kUrlOnboarding/location';
const kUrlOnboardingRadius = '$kUrlOnboarding/radius';
const kUrlOnboardingNotifications = '$kUrlOnboarding/notifications';

// ---------------------------- USER ----------------------------

const kUrlUser = '$kUrlApi/user';

const kUrlUserProfilePicture = '$kUrlUser/profile-picture';

/// A Firebase custom token for the signed-in user, so the app can sign in
/// to Firebase Auth and reach the Ask ALRT callable.
const kUrlFirebaseToken = '$kUrlUser/firebase-token';

const kUrlSubscribeLocation = '$kUrlUser/subscribe-location';
const kUrlUnsubscribeLocation = '$kUrlUser/unsubscribe-location';
const kUrlUserLocationSubscriptions = '$kUrlUser/location-subscriptions';
const kUrlOwnLocationSubscription = '$kUrlUser/own-location-subscription';
const kUrlOwnLocationSubscriptionRadius =
    '$kUrlUser/own-location-subscription-radius';

const kUrlPushNotificationSettings = '$kUrlUser/push-notification-settings';

const kUrlUserAccount = '$kUrlUser/account';
const kUrlUserAccountCancelDeletion = '$kUrlUserAccount/cancel-deletion';

// ---------------------------- HAZARD ----------------------------

const kUrlHazards = '$kUrlApi/hazards';
const kUrlHazardCategories = '$kUrlApi/hazard-categories';

// Community safety: flagging a report, and blocking an account.
const kUrlHazardFlag = '$kUrlHazards/{hazardId}/flag';
const kUrlUserBlocked = '$kUrlUser/blocked';
const kUrlUserUnblock = '$kUrlUserBlocked/{userId}';

const kUrlHazardsWithSubscriptionId =
    '$kUrlHazards/hazards-with-subscription-id';
const kUrlHazardCategoriesParent = '$kUrlHazardCategories/parent';
const kUrlHazardCategoriesSub = '$kUrlHazardCategories/sub';
const kUrlHazardVote = '$kUrlHazards/{hazardId}/vote';
const kUrlHazardView = '$kUrlHazards/{hazardId}/view';

// ---------------------------- NOTIFICATION ----------------------------

const kUrlNotifications = '$kUrlApi/notifications';

const kUrlNotificationsFeed = '$kUrlNotifications/feed';
const kUrlNotificationsPushNotificationToken =
    '$kUrlNotifications/push-notification-token';

// ---------------------------- SUPPORT ----------------------------

const kUrlSupport = '$kUrlApi/support';

// ---------------------------- FAMILY ----------------------------

const kUrlFamily = '$kUrlApi/family';

const kUrlFamilyCircle = '$kUrlFamily/circle';
const kUrlFamilyCircles = '$kUrlFamily/circles';
const kUrlFamilyCircleLeave = '$kUrlFamilyCircle/leave';
const kUrlFamilyCirclePhoto = '$kUrlFamilyCircle/photo';
const kUrlFamilyTransferCandidates = '$kUrlFamilyCircle/transfer-candidates';
const kUrlFamilyTransferOwnership = '$kUrlFamilyCircle/transfer-ownership';
const kUrlFamilyTakeOver = '$kUrlFamilyCircle/take-over';
const kUrlFamilyMembers = '$kUrlFamily/members';
const kUrlFamilyMemberMe = '$kUrlFamilyMembers/me';
const kUrlFamilyMemberMePhoto = '$kUrlFamilyMemberMe/photo';
const kUrlFamilyInvites = '$kUrlFamily/invites';
const kUrlFamilyInviteRevoke = '$kUrlFamilyInvites/{inviteId}/revoke';
const kUrlFamilyJoin = '$kUrlFamily/join';
const kUrlFamilyLocation = '$kUrlFamily/location';
const kUrlFamilyLocationRequest =
    '$kUrlFamilyMembers/{memberId}/location-request';
const kUrlFamilyLocationRequestsPending =
    '$kUrlFamily/location-requests/pending';
const kUrlFamilyLocationRequestRespond =
    '$kUrlFamily/location-requests/{requestId}/respond';
const kUrlFamilyCheckIn = '$kUrlFamily/check-in';
const kUrlFamilyCheckInRequest = '$kUrlFamilyCheckIn/request';
const kUrlFamilyCheckInRequestCancel = '$kUrlFamilyCheckInRequest/{requestId}';
const kUrlFamilyCheckIns = '$kUrlFamily/check-ins';
const kUrlFamilyScheduledCheckIns = '$kUrlFamily/scheduled-check-ins';
const kUrlFamilyScheduledCheckIn =
    '$kUrlFamilyScheduledCheckIns/{scheduledCheckInId}';
const kUrlFamilyPlaces = '$kUrlFamily/places';
const kUrlFamilyPlacePrefs = '$kUrlFamilyPlaces/{placeId}/prefs';
const kUrlFamilySosLists = '$kUrlFamily/sos-lists';
const kUrlFamilySosRecipients = '$kUrlFamily/sos-recipients';
const kUrlFamilySosList = '$kUrlFamilySosLists/{sosListId}';
const kUrlFamilyJourneys = '$kUrlFamily/journeys';
const kUrlFamilyJourneyMine = '$kUrlFamilyJourneys/me';
const kUrlFamilyJourneysShared = '$kUrlFamilyJourneys/shared';
const kUrlFamilyJourneyExtend = '$kUrlFamilyJourneys/{journeyId}/extend';
const kUrlFamilyJourneyStop = '$kUrlFamilyJourneys/{journeyId}/stop';
const kUrlFamilyJourneyPoint = '$kUrlFamilyJourneys/{journeyId}/point';
const kUrlFamilySos = '$kUrlFamily/sos';
const kUrlFamilySosActive = '$kUrlFamilySos/active';
const kUrlFamilySosRespond = '$kUrlFamilySos/{sosEventId}/respond';
const kUrlFamilySosResolve = '$kUrlFamilySos/{sosEventId}/resolve';
const kUrlFamilySosTrail = '$kUrlFamilySos/{sosEventId}/trail';

// ---------------------------- XP / SCORING ----------------------------

const kUrlXp = '$kUrlApi/xp';

const kUrlXpSummary = '$kUrlXp/summary';
const kUrlXpBreakdown = '$kUrlXp/breakdown';
const kUrlXpLeaderboard = '$kUrlXp/leaderboard';

// ---------------------------- LEARN / GUIDES ----------------------------

const kUrlGuides = '$kUrlApi/guides';

const kUrlGuideTopics = '$kUrlGuides/topics';
const kUrlGuideForCategory = '$kUrlGuides/for-category/{categoryId}';
const kUrlGuideDetail = '$kUrlGuides/{slugOrId}';
const kUrlGuideComplete = '$kUrlGuides/{slugOrId}/complete';

// ---------------------------- PUBLIC SHARE ----------------------------

/// Public share page for an alert — used when sharing an alert externally.
const kUrlShareAlert = '$kUrlBase/share/alert';

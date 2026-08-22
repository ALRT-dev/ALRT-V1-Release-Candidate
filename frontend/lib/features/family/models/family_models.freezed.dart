// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'family_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$FamilyCircle {

 String get id; String get name; String get plan; int get maxMembers;// Group rules (owner-set toggles, locked spec).
/// The beacon colour: marks the group on member dots, snapshot pins,
/// journey points and the widget.
 String? get themeColor;/// The group picture, set by the owner. Null means the circle is drawn
/// as its initial on [themeColor], which is the default look.
 String? get photoUrl;/// True when the host's ALRT+ lapsed: check-ins, snapshots and SOS are
/// paused for this circle, nothing deleted. Only ever true once
/// billing is switched on.
 bool get isPaused;/// Who lapsed, and how many of the 30 grace days remain. Only set
/// while [isPaused].
 String? get pausedHostName; int? get graceDaysLeft; bool get anyoneCanRequestSnapshot; bool get sosToWholeGroup; bool get journeysSnapPointsOnly; String get myMemberId; List<FamilyMember> get members; List<FamilySavedPlace> get places; List<FamilySosEvent> get activeSosEvents; FamilyCheckInRequest? get latestCheckInRequest; DateTime? get createdAt;
/// Create a copy of FamilyCircle
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FamilyCircleCopyWith<FamilyCircle> get copyWith => _$FamilyCircleCopyWithImpl<FamilyCircle>(this as FamilyCircle, _$identity);

  /// Serializes this FamilyCircle to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FamilyCircle&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.plan, plan) || other.plan == plan)&&(identical(other.maxMembers, maxMembers) || other.maxMembers == maxMembers)&&(identical(other.themeColor, themeColor) || other.themeColor == themeColor)&&(identical(other.photoUrl, photoUrl) || other.photoUrl == photoUrl)&&(identical(other.isPaused, isPaused) || other.isPaused == isPaused)&&(identical(other.pausedHostName, pausedHostName) || other.pausedHostName == pausedHostName)&&(identical(other.graceDaysLeft, graceDaysLeft) || other.graceDaysLeft == graceDaysLeft)&&(identical(other.anyoneCanRequestSnapshot, anyoneCanRequestSnapshot) || other.anyoneCanRequestSnapshot == anyoneCanRequestSnapshot)&&(identical(other.sosToWholeGroup, sosToWholeGroup) || other.sosToWholeGroup == sosToWholeGroup)&&(identical(other.journeysSnapPointsOnly, journeysSnapPointsOnly) || other.journeysSnapPointsOnly == journeysSnapPointsOnly)&&(identical(other.myMemberId, myMemberId) || other.myMemberId == myMemberId)&&const DeepCollectionEquality().equals(other.members, members)&&const DeepCollectionEquality().equals(other.places, places)&&const DeepCollectionEquality().equals(other.activeSosEvents, activeSosEvents)&&(identical(other.latestCheckInRequest, latestCheckInRequest) || other.latestCheckInRequest == latestCheckInRequest)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,plan,maxMembers,themeColor,photoUrl,isPaused,pausedHostName,graceDaysLeft,anyoneCanRequestSnapshot,sosToWholeGroup,journeysSnapPointsOnly,myMemberId,const DeepCollectionEquality().hash(members),const DeepCollectionEquality().hash(places),const DeepCollectionEquality().hash(activeSosEvents),latestCheckInRequest,createdAt);

@override
String toString() {
  return 'FamilyCircle(id: $id, name: $name, plan: $plan, maxMembers: $maxMembers, themeColor: $themeColor, photoUrl: $photoUrl, isPaused: $isPaused, pausedHostName: $pausedHostName, graceDaysLeft: $graceDaysLeft, anyoneCanRequestSnapshot: $anyoneCanRequestSnapshot, sosToWholeGroup: $sosToWholeGroup, journeysSnapPointsOnly: $journeysSnapPointsOnly, myMemberId: $myMemberId, members: $members, places: $places, activeSosEvents: $activeSosEvents, latestCheckInRequest: $latestCheckInRequest, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $FamilyCircleCopyWith<$Res>  {
  factory $FamilyCircleCopyWith(FamilyCircle value, $Res Function(FamilyCircle) _then) = _$FamilyCircleCopyWithImpl;
@useResult
$Res call({
 String id, String name, String plan, int maxMembers, String? themeColor, String? photoUrl, bool isPaused, String? pausedHostName, int? graceDaysLeft, bool anyoneCanRequestSnapshot, bool sosToWholeGroup, bool journeysSnapPointsOnly, String myMemberId, List<FamilyMember> members, List<FamilySavedPlace> places, List<FamilySosEvent> activeSosEvents, FamilyCheckInRequest? latestCheckInRequest, DateTime? createdAt
});


$FamilyCheckInRequestCopyWith<$Res>? get latestCheckInRequest;

}
/// @nodoc
class _$FamilyCircleCopyWithImpl<$Res>
    implements $FamilyCircleCopyWith<$Res> {
  _$FamilyCircleCopyWithImpl(this._self, this._then);

  final FamilyCircle _self;
  final $Res Function(FamilyCircle) _then;

/// Create a copy of FamilyCircle
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? plan = null,Object? maxMembers = null,Object? themeColor = freezed,Object? photoUrl = freezed,Object? isPaused = null,Object? pausedHostName = freezed,Object? graceDaysLeft = freezed,Object? anyoneCanRequestSnapshot = null,Object? sosToWholeGroup = null,Object? journeysSnapPointsOnly = null,Object? myMemberId = null,Object? members = null,Object? places = null,Object? activeSosEvents = null,Object? latestCheckInRequest = freezed,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,plan: null == plan ? _self.plan : plan // ignore: cast_nullable_to_non_nullable
as String,maxMembers: null == maxMembers ? _self.maxMembers : maxMembers // ignore: cast_nullable_to_non_nullable
as int,themeColor: freezed == themeColor ? _self.themeColor : themeColor // ignore: cast_nullable_to_non_nullable
as String?,photoUrl: freezed == photoUrl ? _self.photoUrl : photoUrl // ignore: cast_nullable_to_non_nullable
as String?,isPaused: null == isPaused ? _self.isPaused : isPaused // ignore: cast_nullable_to_non_nullable
as bool,pausedHostName: freezed == pausedHostName ? _self.pausedHostName : pausedHostName // ignore: cast_nullable_to_non_nullable
as String?,graceDaysLeft: freezed == graceDaysLeft ? _self.graceDaysLeft : graceDaysLeft // ignore: cast_nullable_to_non_nullable
as int?,anyoneCanRequestSnapshot: null == anyoneCanRequestSnapshot ? _self.anyoneCanRequestSnapshot : anyoneCanRequestSnapshot // ignore: cast_nullable_to_non_nullable
as bool,sosToWholeGroup: null == sosToWholeGroup ? _self.sosToWholeGroup : sosToWholeGroup // ignore: cast_nullable_to_non_nullable
as bool,journeysSnapPointsOnly: null == journeysSnapPointsOnly ? _self.journeysSnapPointsOnly : journeysSnapPointsOnly // ignore: cast_nullable_to_non_nullable
as bool,myMemberId: null == myMemberId ? _self.myMemberId : myMemberId // ignore: cast_nullable_to_non_nullable
as String,members: null == members ? _self.members : members // ignore: cast_nullable_to_non_nullable
as List<FamilyMember>,places: null == places ? _self.places : places // ignore: cast_nullable_to_non_nullable
as List<FamilySavedPlace>,activeSosEvents: null == activeSosEvents ? _self.activeSosEvents : activeSosEvents // ignore: cast_nullable_to_non_nullable
as List<FamilySosEvent>,latestCheckInRequest: freezed == latestCheckInRequest ? _self.latestCheckInRequest : latestCheckInRequest // ignore: cast_nullable_to_non_nullable
as FamilyCheckInRequest?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}
/// Create a copy of FamilyCircle
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FamilyCheckInRequestCopyWith<$Res>? get latestCheckInRequest {
    if (_self.latestCheckInRequest == null) {
    return null;
  }

  return $FamilyCheckInRequestCopyWith<$Res>(_self.latestCheckInRequest!, (value) {
    return _then(_self.copyWith(latestCheckInRequest: value));
  });
}
}


/// Adds pattern-matching-related methods to [FamilyCircle].
extension FamilyCirclePatterns on FamilyCircle {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FamilyCircle value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FamilyCircle() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FamilyCircle value)  $default,){
final _that = this;
switch (_that) {
case _FamilyCircle():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FamilyCircle value)?  $default,){
final _that = this;
switch (_that) {
case _FamilyCircle() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String plan,  int maxMembers,  String? themeColor,  String? photoUrl,  bool isPaused,  String? pausedHostName,  int? graceDaysLeft,  bool anyoneCanRequestSnapshot,  bool sosToWholeGroup,  bool journeysSnapPointsOnly,  String myMemberId,  List<FamilyMember> members,  List<FamilySavedPlace> places,  List<FamilySosEvent> activeSosEvents,  FamilyCheckInRequest? latestCheckInRequest,  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FamilyCircle() when $default != null:
return $default(_that.id,_that.name,_that.plan,_that.maxMembers,_that.themeColor,_that.photoUrl,_that.isPaused,_that.pausedHostName,_that.graceDaysLeft,_that.anyoneCanRequestSnapshot,_that.sosToWholeGroup,_that.journeysSnapPointsOnly,_that.myMemberId,_that.members,_that.places,_that.activeSosEvents,_that.latestCheckInRequest,_that.createdAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String plan,  int maxMembers,  String? themeColor,  String? photoUrl,  bool isPaused,  String? pausedHostName,  int? graceDaysLeft,  bool anyoneCanRequestSnapshot,  bool sosToWholeGroup,  bool journeysSnapPointsOnly,  String myMemberId,  List<FamilyMember> members,  List<FamilySavedPlace> places,  List<FamilySosEvent> activeSosEvents,  FamilyCheckInRequest? latestCheckInRequest,  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _FamilyCircle():
return $default(_that.id,_that.name,_that.plan,_that.maxMembers,_that.themeColor,_that.photoUrl,_that.isPaused,_that.pausedHostName,_that.graceDaysLeft,_that.anyoneCanRequestSnapshot,_that.sosToWholeGroup,_that.journeysSnapPointsOnly,_that.myMemberId,_that.members,_that.places,_that.activeSosEvents,_that.latestCheckInRequest,_that.createdAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String plan,  int maxMembers,  String? themeColor,  String? photoUrl,  bool isPaused,  String? pausedHostName,  int? graceDaysLeft,  bool anyoneCanRequestSnapshot,  bool sosToWholeGroup,  bool journeysSnapPointsOnly,  String myMemberId,  List<FamilyMember> members,  List<FamilySavedPlace> places,  List<FamilySosEvent> activeSosEvents,  FamilyCheckInRequest? latestCheckInRequest,  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _FamilyCircle() when $default != null:
return $default(_that.id,_that.name,_that.plan,_that.maxMembers,_that.themeColor,_that.photoUrl,_that.isPaused,_that.pausedHostName,_that.graceDaysLeft,_that.anyoneCanRequestSnapshot,_that.sosToWholeGroup,_that.journeysSnapPointsOnly,_that.myMemberId,_that.members,_that.places,_that.activeSosEvents,_that.latestCheckInRequest,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FamilyCircle extends FamilyCircle {
  const _FamilyCircle({required this.id, required this.name, this.plan = 'plus', this.maxMembers = 10, this.themeColor, this.photoUrl, this.isPaused = false, this.pausedHostName, this.graceDaysLeft, this.anyoneCanRequestSnapshot = true, this.sosToWholeGroup = true, this.journeysSnapPointsOnly = true, required this.myMemberId, final  List<FamilyMember> members = const <FamilyMember>[], final  List<FamilySavedPlace> places = const <FamilySavedPlace>[], final  List<FamilySosEvent> activeSosEvents = const <FamilySosEvent>[], this.latestCheckInRequest, this.createdAt}): _members = members,_places = places,_activeSosEvents = activeSosEvents,super._();
  factory _FamilyCircle.fromJson(Map<String, dynamic> json) => _$FamilyCircleFromJson(json);

@override final  String id;
@override final  String name;
@override@JsonKey() final  String plan;
@override@JsonKey() final  int maxMembers;
// Group rules (owner-set toggles, locked spec).
/// The beacon colour: marks the group on member dots, snapshot pins,
/// journey points and the widget.
@override final  String? themeColor;
/// The group picture, set by the owner. Null means the circle is drawn
/// as its initial on [themeColor], which is the default look.
@override final  String? photoUrl;
/// True when the host's ALRT+ lapsed: check-ins, snapshots and SOS are
/// paused for this circle, nothing deleted. Only ever true once
/// billing is switched on.
@override@JsonKey() final  bool isPaused;
/// Who lapsed, and how many of the 30 grace days remain. Only set
/// while [isPaused].
@override final  String? pausedHostName;
@override final  int? graceDaysLeft;
@override@JsonKey() final  bool anyoneCanRequestSnapshot;
@override@JsonKey() final  bool sosToWholeGroup;
@override@JsonKey() final  bool journeysSnapPointsOnly;
@override final  String myMemberId;
 final  List<FamilyMember> _members;
@override@JsonKey() List<FamilyMember> get members {
  if (_members is EqualUnmodifiableListView) return _members;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_members);
}

 final  List<FamilySavedPlace> _places;
@override@JsonKey() List<FamilySavedPlace> get places {
  if (_places is EqualUnmodifiableListView) return _places;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_places);
}

 final  List<FamilySosEvent> _activeSosEvents;
@override@JsonKey() List<FamilySosEvent> get activeSosEvents {
  if (_activeSosEvents is EqualUnmodifiableListView) return _activeSosEvents;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_activeSosEvents);
}

@override final  FamilyCheckInRequest? latestCheckInRequest;
@override final  DateTime? createdAt;

/// Create a copy of FamilyCircle
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FamilyCircleCopyWith<_FamilyCircle> get copyWith => __$FamilyCircleCopyWithImpl<_FamilyCircle>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FamilyCircleToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FamilyCircle&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.plan, plan) || other.plan == plan)&&(identical(other.maxMembers, maxMembers) || other.maxMembers == maxMembers)&&(identical(other.themeColor, themeColor) || other.themeColor == themeColor)&&(identical(other.photoUrl, photoUrl) || other.photoUrl == photoUrl)&&(identical(other.isPaused, isPaused) || other.isPaused == isPaused)&&(identical(other.pausedHostName, pausedHostName) || other.pausedHostName == pausedHostName)&&(identical(other.graceDaysLeft, graceDaysLeft) || other.graceDaysLeft == graceDaysLeft)&&(identical(other.anyoneCanRequestSnapshot, anyoneCanRequestSnapshot) || other.anyoneCanRequestSnapshot == anyoneCanRequestSnapshot)&&(identical(other.sosToWholeGroup, sosToWholeGroup) || other.sosToWholeGroup == sosToWholeGroup)&&(identical(other.journeysSnapPointsOnly, journeysSnapPointsOnly) || other.journeysSnapPointsOnly == journeysSnapPointsOnly)&&(identical(other.myMemberId, myMemberId) || other.myMemberId == myMemberId)&&const DeepCollectionEquality().equals(other._members, _members)&&const DeepCollectionEquality().equals(other._places, _places)&&const DeepCollectionEquality().equals(other._activeSosEvents, _activeSosEvents)&&(identical(other.latestCheckInRequest, latestCheckInRequest) || other.latestCheckInRequest == latestCheckInRequest)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,plan,maxMembers,themeColor,photoUrl,isPaused,pausedHostName,graceDaysLeft,anyoneCanRequestSnapshot,sosToWholeGroup,journeysSnapPointsOnly,myMemberId,const DeepCollectionEquality().hash(_members),const DeepCollectionEquality().hash(_places),const DeepCollectionEquality().hash(_activeSosEvents),latestCheckInRequest,createdAt);

@override
String toString() {
  return 'FamilyCircle(id: $id, name: $name, plan: $plan, maxMembers: $maxMembers, themeColor: $themeColor, photoUrl: $photoUrl, isPaused: $isPaused, pausedHostName: $pausedHostName, graceDaysLeft: $graceDaysLeft, anyoneCanRequestSnapshot: $anyoneCanRequestSnapshot, sosToWholeGroup: $sosToWholeGroup, journeysSnapPointsOnly: $journeysSnapPointsOnly, myMemberId: $myMemberId, members: $members, places: $places, activeSosEvents: $activeSosEvents, latestCheckInRequest: $latestCheckInRequest, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$FamilyCircleCopyWith<$Res> implements $FamilyCircleCopyWith<$Res> {
  factory _$FamilyCircleCopyWith(_FamilyCircle value, $Res Function(_FamilyCircle) _then) = __$FamilyCircleCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String plan, int maxMembers, String? themeColor, String? photoUrl, bool isPaused, String? pausedHostName, int? graceDaysLeft, bool anyoneCanRequestSnapshot, bool sosToWholeGroup, bool journeysSnapPointsOnly, String myMemberId, List<FamilyMember> members, List<FamilySavedPlace> places, List<FamilySosEvent> activeSosEvents, FamilyCheckInRequest? latestCheckInRequest, DateTime? createdAt
});


@override $FamilyCheckInRequestCopyWith<$Res>? get latestCheckInRequest;

}
/// @nodoc
class __$FamilyCircleCopyWithImpl<$Res>
    implements _$FamilyCircleCopyWith<$Res> {
  __$FamilyCircleCopyWithImpl(this._self, this._then);

  final _FamilyCircle _self;
  final $Res Function(_FamilyCircle) _then;

/// Create a copy of FamilyCircle
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? plan = null,Object? maxMembers = null,Object? themeColor = freezed,Object? photoUrl = freezed,Object? isPaused = null,Object? pausedHostName = freezed,Object? graceDaysLeft = freezed,Object? anyoneCanRequestSnapshot = null,Object? sosToWholeGroup = null,Object? journeysSnapPointsOnly = null,Object? myMemberId = null,Object? members = null,Object? places = null,Object? activeSosEvents = null,Object? latestCheckInRequest = freezed,Object? createdAt = freezed,}) {
  return _then(_FamilyCircle(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,plan: null == plan ? _self.plan : plan // ignore: cast_nullable_to_non_nullable
as String,maxMembers: null == maxMembers ? _self.maxMembers : maxMembers // ignore: cast_nullable_to_non_nullable
as int,themeColor: freezed == themeColor ? _self.themeColor : themeColor // ignore: cast_nullable_to_non_nullable
as String?,photoUrl: freezed == photoUrl ? _self.photoUrl : photoUrl // ignore: cast_nullable_to_non_nullable
as String?,isPaused: null == isPaused ? _self.isPaused : isPaused // ignore: cast_nullable_to_non_nullable
as bool,pausedHostName: freezed == pausedHostName ? _self.pausedHostName : pausedHostName // ignore: cast_nullable_to_non_nullable
as String?,graceDaysLeft: freezed == graceDaysLeft ? _self.graceDaysLeft : graceDaysLeft // ignore: cast_nullable_to_non_nullable
as int?,anyoneCanRequestSnapshot: null == anyoneCanRequestSnapshot ? _self.anyoneCanRequestSnapshot : anyoneCanRequestSnapshot // ignore: cast_nullable_to_non_nullable
as bool,sosToWholeGroup: null == sosToWholeGroup ? _self.sosToWholeGroup : sosToWholeGroup // ignore: cast_nullable_to_non_nullable
as bool,journeysSnapPointsOnly: null == journeysSnapPointsOnly ? _self.journeysSnapPointsOnly : journeysSnapPointsOnly // ignore: cast_nullable_to_non_nullable
as bool,myMemberId: null == myMemberId ? _self.myMemberId : myMemberId // ignore: cast_nullable_to_non_nullable
as String,members: null == members ? _self._members : members // ignore: cast_nullable_to_non_nullable
as List<FamilyMember>,places: null == places ? _self._places : places // ignore: cast_nullable_to_non_nullable
as List<FamilySavedPlace>,activeSosEvents: null == activeSosEvents ? _self._activeSosEvents : activeSosEvents // ignore: cast_nullable_to_non_nullable
as List<FamilySosEvent>,latestCheckInRequest: freezed == latestCheckInRequest ? _self.latestCheckInRequest : latestCheckInRequest // ignore: cast_nullable_to_non_nullable
as FamilyCheckInRequest?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of FamilyCircle
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FamilyCheckInRequestCopyWith<$Res>? get latestCheckInRequest {
    if (_self.latestCheckInRequest == null) {
    return null;
  }

  return $FamilyCheckInRequestCopyWith<$Res>(_self.latestCheckInRequest!, (value) {
    return _then(_self.copyWith(latestCheckInRequest: value));
  });
}
}


/// @nodoc
mixin _$FamilyMember {

 String get id; String get userId; String get name; String? get profilePictureUrl; String? get colorHex;@JsonKey(unknownEnumValue: FamilyRole.adult) FamilyRole get role;@JsonKey(unknownEnumValue: FamilySharingLevel.precise) FamilySharingLevel get sharingLevel; double? get latitude; double? get longitude; String? get locationLabel; DateTime? get locationUpdatedAt; DateTime? get locationExpiresAt;@JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue) FamilySnapshotSource? get locationSharedVia; int? get batteryLevel; bool get isMoving; String? get currentPlaceId; DateTime? get lastCheckInAt; DateTime? get createdAt;
/// Create a copy of FamilyMember
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FamilyMemberCopyWith<FamilyMember> get copyWith => _$FamilyMemberCopyWithImpl<FamilyMember>(this as FamilyMember, _$identity);

  /// Serializes this FamilyMember to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FamilyMember&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.name, name) || other.name == name)&&(identical(other.profilePictureUrl, profilePictureUrl) || other.profilePictureUrl == profilePictureUrl)&&(identical(other.colorHex, colorHex) || other.colorHex == colorHex)&&(identical(other.role, role) || other.role == role)&&(identical(other.sharingLevel, sharingLevel) || other.sharingLevel == sharingLevel)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.locationLabel, locationLabel) || other.locationLabel == locationLabel)&&(identical(other.locationUpdatedAt, locationUpdatedAt) || other.locationUpdatedAt == locationUpdatedAt)&&(identical(other.locationExpiresAt, locationExpiresAt) || other.locationExpiresAt == locationExpiresAt)&&(identical(other.locationSharedVia, locationSharedVia) || other.locationSharedVia == locationSharedVia)&&(identical(other.batteryLevel, batteryLevel) || other.batteryLevel == batteryLevel)&&(identical(other.isMoving, isMoving) || other.isMoving == isMoving)&&(identical(other.currentPlaceId, currentPlaceId) || other.currentPlaceId == currentPlaceId)&&(identical(other.lastCheckInAt, lastCheckInAt) || other.lastCheckInAt == lastCheckInAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,name,profilePictureUrl,colorHex,role,sharingLevel,latitude,longitude,locationLabel,locationUpdatedAt,locationExpiresAt,locationSharedVia,batteryLevel,isMoving,currentPlaceId,lastCheckInAt,createdAt);

@override
String toString() {
  return 'FamilyMember(id: $id, userId: $userId, name: $name, profilePictureUrl: $profilePictureUrl, colorHex: $colorHex, role: $role, sharingLevel: $sharingLevel, latitude: $latitude, longitude: $longitude, locationLabel: $locationLabel, locationUpdatedAt: $locationUpdatedAt, locationExpiresAt: $locationExpiresAt, locationSharedVia: $locationSharedVia, batteryLevel: $batteryLevel, isMoving: $isMoving, currentPlaceId: $currentPlaceId, lastCheckInAt: $lastCheckInAt, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $FamilyMemberCopyWith<$Res>  {
  factory $FamilyMemberCopyWith(FamilyMember value, $Res Function(FamilyMember) _then) = _$FamilyMemberCopyWithImpl;
@useResult
$Res call({
 String id, String userId, String name, String? profilePictureUrl, String? colorHex,@JsonKey(unknownEnumValue: FamilyRole.adult) FamilyRole role,@JsonKey(unknownEnumValue: FamilySharingLevel.precise) FamilySharingLevel sharingLevel, double? latitude, double? longitude, String? locationLabel, DateTime? locationUpdatedAt, DateTime? locationExpiresAt,@JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue) FamilySnapshotSource? locationSharedVia, int? batteryLevel, bool isMoving, String? currentPlaceId, DateTime? lastCheckInAt, DateTime? createdAt
});




}
/// @nodoc
class _$FamilyMemberCopyWithImpl<$Res>
    implements $FamilyMemberCopyWith<$Res> {
  _$FamilyMemberCopyWithImpl(this._self, this._then);

  final FamilyMember _self;
  final $Res Function(FamilyMember) _then;

/// Create a copy of FamilyMember
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? name = null,Object? profilePictureUrl = freezed,Object? colorHex = freezed,Object? role = null,Object? sharingLevel = null,Object? latitude = freezed,Object? longitude = freezed,Object? locationLabel = freezed,Object? locationUpdatedAt = freezed,Object? locationExpiresAt = freezed,Object? locationSharedVia = freezed,Object? batteryLevel = freezed,Object? isMoving = null,Object? currentPlaceId = freezed,Object? lastCheckInAt = freezed,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,profilePictureUrl: freezed == profilePictureUrl ? _self.profilePictureUrl : profilePictureUrl // ignore: cast_nullable_to_non_nullable
as String?,colorHex: freezed == colorHex ? _self.colorHex : colorHex // ignore: cast_nullable_to_non_nullable
as String?,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as FamilyRole,sharingLevel: null == sharingLevel ? _self.sharingLevel : sharingLevel // ignore: cast_nullable_to_non_nullable
as FamilySharingLevel,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double?,locationLabel: freezed == locationLabel ? _self.locationLabel : locationLabel // ignore: cast_nullable_to_non_nullable
as String?,locationUpdatedAt: freezed == locationUpdatedAt ? _self.locationUpdatedAt : locationUpdatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,locationExpiresAt: freezed == locationExpiresAt ? _self.locationExpiresAt : locationExpiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,locationSharedVia: freezed == locationSharedVia ? _self.locationSharedVia : locationSharedVia // ignore: cast_nullable_to_non_nullable
as FamilySnapshotSource?,batteryLevel: freezed == batteryLevel ? _self.batteryLevel : batteryLevel // ignore: cast_nullable_to_non_nullable
as int?,isMoving: null == isMoving ? _self.isMoving : isMoving // ignore: cast_nullable_to_non_nullable
as bool,currentPlaceId: freezed == currentPlaceId ? _self.currentPlaceId : currentPlaceId // ignore: cast_nullable_to_non_nullable
as String?,lastCheckInAt: freezed == lastCheckInAt ? _self.lastCheckInAt : lastCheckInAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [FamilyMember].
extension FamilyMemberPatterns on FamilyMember {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FamilyMember value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FamilyMember() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FamilyMember value)  $default,){
final _that = this;
switch (_that) {
case _FamilyMember():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FamilyMember value)?  $default,){
final _that = this;
switch (_that) {
case _FamilyMember() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String userId,  String name,  String? profilePictureUrl,  String? colorHex, @JsonKey(unknownEnumValue: FamilyRole.adult)  FamilyRole role, @JsonKey(unknownEnumValue: FamilySharingLevel.precise)  FamilySharingLevel sharingLevel,  double? latitude,  double? longitude,  String? locationLabel,  DateTime? locationUpdatedAt,  DateTime? locationExpiresAt, @JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue)  FamilySnapshotSource? locationSharedVia,  int? batteryLevel,  bool isMoving,  String? currentPlaceId,  DateTime? lastCheckInAt,  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FamilyMember() when $default != null:
return $default(_that.id,_that.userId,_that.name,_that.profilePictureUrl,_that.colorHex,_that.role,_that.sharingLevel,_that.latitude,_that.longitude,_that.locationLabel,_that.locationUpdatedAt,_that.locationExpiresAt,_that.locationSharedVia,_that.batteryLevel,_that.isMoving,_that.currentPlaceId,_that.lastCheckInAt,_that.createdAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String userId,  String name,  String? profilePictureUrl,  String? colorHex, @JsonKey(unknownEnumValue: FamilyRole.adult)  FamilyRole role, @JsonKey(unknownEnumValue: FamilySharingLevel.precise)  FamilySharingLevel sharingLevel,  double? latitude,  double? longitude,  String? locationLabel,  DateTime? locationUpdatedAt,  DateTime? locationExpiresAt, @JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue)  FamilySnapshotSource? locationSharedVia,  int? batteryLevel,  bool isMoving,  String? currentPlaceId,  DateTime? lastCheckInAt,  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _FamilyMember():
return $default(_that.id,_that.userId,_that.name,_that.profilePictureUrl,_that.colorHex,_that.role,_that.sharingLevel,_that.latitude,_that.longitude,_that.locationLabel,_that.locationUpdatedAt,_that.locationExpiresAt,_that.locationSharedVia,_that.batteryLevel,_that.isMoving,_that.currentPlaceId,_that.lastCheckInAt,_that.createdAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String userId,  String name,  String? profilePictureUrl,  String? colorHex, @JsonKey(unknownEnumValue: FamilyRole.adult)  FamilyRole role, @JsonKey(unknownEnumValue: FamilySharingLevel.precise)  FamilySharingLevel sharingLevel,  double? latitude,  double? longitude,  String? locationLabel,  DateTime? locationUpdatedAt,  DateTime? locationExpiresAt, @JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue)  FamilySnapshotSource? locationSharedVia,  int? batteryLevel,  bool isMoving,  String? currentPlaceId,  DateTime? lastCheckInAt,  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _FamilyMember() when $default != null:
return $default(_that.id,_that.userId,_that.name,_that.profilePictureUrl,_that.colorHex,_that.role,_that.sharingLevel,_that.latitude,_that.longitude,_that.locationLabel,_that.locationUpdatedAt,_that.locationExpiresAt,_that.locationSharedVia,_that.batteryLevel,_that.isMoving,_that.currentPlaceId,_that.lastCheckInAt,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FamilyMember extends FamilyMember {
  const _FamilyMember({required this.id, required this.userId, this.name = 'Family member', this.profilePictureUrl, this.colorHex, @JsonKey(unknownEnumValue: FamilyRole.adult) this.role = FamilyRole.adult, @JsonKey(unknownEnumValue: FamilySharingLevel.precise) this.sharingLevel = FamilySharingLevel.precise, this.latitude, this.longitude, this.locationLabel, this.locationUpdatedAt, this.locationExpiresAt, @JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue) this.locationSharedVia, this.batteryLevel, this.isMoving = false, this.currentPlaceId, this.lastCheckInAt, this.createdAt}): super._();
  factory _FamilyMember.fromJson(Map<String, dynamic> json) => _$FamilyMemberFromJson(json);

@override final  String id;
@override final  String userId;
@override@JsonKey() final  String name;
@override final  String? profilePictureUrl;
@override final  String? colorHex;
@override@JsonKey(unknownEnumValue: FamilyRole.adult) final  FamilyRole role;
@override@JsonKey(unknownEnumValue: FamilySharingLevel.precise) final  FamilySharingLevel sharingLevel;
@override final  double? latitude;
@override final  double? longitude;
@override final  String? locationLabel;
@override final  DateTime? locationUpdatedAt;
@override final  DateTime? locationExpiresAt;
@override@JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue) final  FamilySnapshotSource? locationSharedVia;
@override final  int? batteryLevel;
@override@JsonKey() final  bool isMoving;
@override final  String? currentPlaceId;
@override final  DateTime? lastCheckInAt;
@override final  DateTime? createdAt;

/// Create a copy of FamilyMember
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FamilyMemberCopyWith<_FamilyMember> get copyWith => __$FamilyMemberCopyWithImpl<_FamilyMember>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FamilyMemberToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FamilyMember&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.name, name) || other.name == name)&&(identical(other.profilePictureUrl, profilePictureUrl) || other.profilePictureUrl == profilePictureUrl)&&(identical(other.colorHex, colorHex) || other.colorHex == colorHex)&&(identical(other.role, role) || other.role == role)&&(identical(other.sharingLevel, sharingLevel) || other.sharingLevel == sharingLevel)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.locationLabel, locationLabel) || other.locationLabel == locationLabel)&&(identical(other.locationUpdatedAt, locationUpdatedAt) || other.locationUpdatedAt == locationUpdatedAt)&&(identical(other.locationExpiresAt, locationExpiresAt) || other.locationExpiresAt == locationExpiresAt)&&(identical(other.locationSharedVia, locationSharedVia) || other.locationSharedVia == locationSharedVia)&&(identical(other.batteryLevel, batteryLevel) || other.batteryLevel == batteryLevel)&&(identical(other.isMoving, isMoving) || other.isMoving == isMoving)&&(identical(other.currentPlaceId, currentPlaceId) || other.currentPlaceId == currentPlaceId)&&(identical(other.lastCheckInAt, lastCheckInAt) || other.lastCheckInAt == lastCheckInAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,name,profilePictureUrl,colorHex,role,sharingLevel,latitude,longitude,locationLabel,locationUpdatedAt,locationExpiresAt,locationSharedVia,batteryLevel,isMoving,currentPlaceId,lastCheckInAt,createdAt);

@override
String toString() {
  return 'FamilyMember(id: $id, userId: $userId, name: $name, profilePictureUrl: $profilePictureUrl, colorHex: $colorHex, role: $role, sharingLevel: $sharingLevel, latitude: $latitude, longitude: $longitude, locationLabel: $locationLabel, locationUpdatedAt: $locationUpdatedAt, locationExpiresAt: $locationExpiresAt, locationSharedVia: $locationSharedVia, batteryLevel: $batteryLevel, isMoving: $isMoving, currentPlaceId: $currentPlaceId, lastCheckInAt: $lastCheckInAt, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$FamilyMemberCopyWith<$Res> implements $FamilyMemberCopyWith<$Res> {
  factory _$FamilyMemberCopyWith(_FamilyMember value, $Res Function(_FamilyMember) _then) = __$FamilyMemberCopyWithImpl;
@override @useResult
$Res call({
 String id, String userId, String name, String? profilePictureUrl, String? colorHex,@JsonKey(unknownEnumValue: FamilyRole.adult) FamilyRole role,@JsonKey(unknownEnumValue: FamilySharingLevel.precise) FamilySharingLevel sharingLevel, double? latitude, double? longitude, String? locationLabel, DateTime? locationUpdatedAt, DateTime? locationExpiresAt,@JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue) FamilySnapshotSource? locationSharedVia, int? batteryLevel, bool isMoving, String? currentPlaceId, DateTime? lastCheckInAt, DateTime? createdAt
});




}
/// @nodoc
class __$FamilyMemberCopyWithImpl<$Res>
    implements _$FamilyMemberCopyWith<$Res> {
  __$FamilyMemberCopyWithImpl(this._self, this._then);

  final _FamilyMember _self;
  final $Res Function(_FamilyMember) _then;

/// Create a copy of FamilyMember
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? name = null,Object? profilePictureUrl = freezed,Object? colorHex = freezed,Object? role = null,Object? sharingLevel = null,Object? latitude = freezed,Object? longitude = freezed,Object? locationLabel = freezed,Object? locationUpdatedAt = freezed,Object? locationExpiresAt = freezed,Object? locationSharedVia = freezed,Object? batteryLevel = freezed,Object? isMoving = null,Object? currentPlaceId = freezed,Object? lastCheckInAt = freezed,Object? createdAt = freezed,}) {
  return _then(_FamilyMember(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,profilePictureUrl: freezed == profilePictureUrl ? _self.profilePictureUrl : profilePictureUrl // ignore: cast_nullable_to_non_nullable
as String?,colorHex: freezed == colorHex ? _self.colorHex : colorHex // ignore: cast_nullable_to_non_nullable
as String?,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as FamilyRole,sharingLevel: null == sharingLevel ? _self.sharingLevel : sharingLevel // ignore: cast_nullable_to_non_nullable
as FamilySharingLevel,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double?,locationLabel: freezed == locationLabel ? _self.locationLabel : locationLabel // ignore: cast_nullable_to_non_nullable
as String?,locationUpdatedAt: freezed == locationUpdatedAt ? _self.locationUpdatedAt : locationUpdatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,locationExpiresAt: freezed == locationExpiresAt ? _self.locationExpiresAt : locationExpiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,locationSharedVia: freezed == locationSharedVia ? _self.locationSharedVia : locationSharedVia // ignore: cast_nullable_to_non_nullable
as FamilySnapshotSource?,batteryLevel: freezed == batteryLevel ? _self.batteryLevel : batteryLevel // ignore: cast_nullable_to_non_nullable
as int?,isMoving: null == isMoving ? _self.isMoving : isMoving // ignore: cast_nullable_to_non_nullable
as bool,currentPlaceId: freezed == currentPlaceId ? _self.currentPlaceId : currentPlaceId // ignore: cast_nullable_to_non_nullable
as String?,lastCheckInAt: freezed == lastCheckInAt ? _self.lastCheckInAt : lastCheckInAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$FamilyInvite {

 String get id; String get code; int get useCount; int get maxUses;/// Whoever redeems this code joins as a guest.
 bool get isGuestInvite; DateTime? get expiresAt; DateTime? get createdAt;
/// Create a copy of FamilyInvite
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FamilyInviteCopyWith<FamilyInvite> get copyWith => _$FamilyInviteCopyWithImpl<FamilyInvite>(this as FamilyInvite, _$identity);

  /// Serializes this FamilyInvite to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FamilyInvite&&(identical(other.id, id) || other.id == id)&&(identical(other.code, code) || other.code == code)&&(identical(other.useCount, useCount) || other.useCount == useCount)&&(identical(other.maxUses, maxUses) || other.maxUses == maxUses)&&(identical(other.isGuestInvite, isGuestInvite) || other.isGuestInvite == isGuestInvite)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,code,useCount,maxUses,isGuestInvite,expiresAt,createdAt);

@override
String toString() {
  return 'FamilyInvite(id: $id, code: $code, useCount: $useCount, maxUses: $maxUses, isGuestInvite: $isGuestInvite, expiresAt: $expiresAt, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $FamilyInviteCopyWith<$Res>  {
  factory $FamilyInviteCopyWith(FamilyInvite value, $Res Function(FamilyInvite) _then) = _$FamilyInviteCopyWithImpl;
@useResult
$Res call({
 String id, String code, int useCount, int maxUses, bool isGuestInvite, DateTime? expiresAt, DateTime? createdAt
});




}
/// @nodoc
class _$FamilyInviteCopyWithImpl<$Res>
    implements $FamilyInviteCopyWith<$Res> {
  _$FamilyInviteCopyWithImpl(this._self, this._then);

  final FamilyInvite _self;
  final $Res Function(FamilyInvite) _then;

/// Create a copy of FamilyInvite
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? code = null,Object? useCount = null,Object? maxUses = null,Object? isGuestInvite = null,Object? expiresAt = freezed,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,useCount: null == useCount ? _self.useCount : useCount // ignore: cast_nullable_to_non_nullable
as int,maxUses: null == maxUses ? _self.maxUses : maxUses // ignore: cast_nullable_to_non_nullable
as int,isGuestInvite: null == isGuestInvite ? _self.isGuestInvite : isGuestInvite // ignore: cast_nullable_to_non_nullable
as bool,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [FamilyInvite].
extension FamilyInvitePatterns on FamilyInvite {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FamilyInvite value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FamilyInvite() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FamilyInvite value)  $default,){
final _that = this;
switch (_that) {
case _FamilyInvite():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FamilyInvite value)?  $default,){
final _that = this;
switch (_that) {
case _FamilyInvite() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String code,  int useCount,  int maxUses,  bool isGuestInvite,  DateTime? expiresAt,  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FamilyInvite() when $default != null:
return $default(_that.id,_that.code,_that.useCount,_that.maxUses,_that.isGuestInvite,_that.expiresAt,_that.createdAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String code,  int useCount,  int maxUses,  bool isGuestInvite,  DateTime? expiresAt,  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _FamilyInvite():
return $default(_that.id,_that.code,_that.useCount,_that.maxUses,_that.isGuestInvite,_that.expiresAt,_that.createdAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String code,  int useCount,  int maxUses,  bool isGuestInvite,  DateTime? expiresAt,  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _FamilyInvite() when $default != null:
return $default(_that.id,_that.code,_that.useCount,_that.maxUses,_that.isGuestInvite,_that.expiresAt,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FamilyInvite implements FamilyInvite {
  const _FamilyInvite({required this.id, required this.code, this.useCount = 0, this.maxUses = 10, this.isGuestInvite = false, this.expiresAt, this.createdAt});
  factory _FamilyInvite.fromJson(Map<String, dynamic> json) => _$FamilyInviteFromJson(json);

@override final  String id;
@override final  String code;
@override@JsonKey() final  int useCount;
@override@JsonKey() final  int maxUses;
/// Whoever redeems this code joins as a guest.
@override@JsonKey() final  bool isGuestInvite;
@override final  DateTime? expiresAt;
@override final  DateTime? createdAt;

/// Create a copy of FamilyInvite
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FamilyInviteCopyWith<_FamilyInvite> get copyWith => __$FamilyInviteCopyWithImpl<_FamilyInvite>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FamilyInviteToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FamilyInvite&&(identical(other.id, id) || other.id == id)&&(identical(other.code, code) || other.code == code)&&(identical(other.useCount, useCount) || other.useCount == useCount)&&(identical(other.maxUses, maxUses) || other.maxUses == maxUses)&&(identical(other.isGuestInvite, isGuestInvite) || other.isGuestInvite == isGuestInvite)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,code,useCount,maxUses,isGuestInvite,expiresAt,createdAt);

@override
String toString() {
  return 'FamilyInvite(id: $id, code: $code, useCount: $useCount, maxUses: $maxUses, isGuestInvite: $isGuestInvite, expiresAt: $expiresAt, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$FamilyInviteCopyWith<$Res> implements $FamilyInviteCopyWith<$Res> {
  factory _$FamilyInviteCopyWith(_FamilyInvite value, $Res Function(_FamilyInvite) _then) = __$FamilyInviteCopyWithImpl;
@override @useResult
$Res call({
 String id, String code, int useCount, int maxUses, bool isGuestInvite, DateTime? expiresAt, DateTime? createdAt
});




}
/// @nodoc
class __$FamilyInviteCopyWithImpl<$Res>
    implements _$FamilyInviteCopyWith<$Res> {
  __$FamilyInviteCopyWithImpl(this._self, this._then);

  final _FamilyInvite _self;
  final $Res Function(_FamilyInvite) _then;

/// Create a copy of FamilyInvite
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? code = null,Object? useCount = null,Object? maxUses = null,Object? isGuestInvite = null,Object? expiresAt = freezed,Object? createdAt = freezed,}) {
  return _then(_FamilyInvite(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,useCount: null == useCount ? _self.useCount : useCount // ignore: cast_nullable_to_non_nullable
as int,maxUses: null == maxUses ? _self.maxUses : maxUses // ignore: cast_nullable_to_non_nullable
as int,isGuestInvite: null == isGuestInvite ? _self.isGuestInvite : isGuestInvite // ignore: cast_nullable_to_non_nullable
as bool,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$FamilySavedPlace {

 String get id; String get name;@JsonKey(unknownEnumValue: FamilyPlaceIcon.other) FamilyPlaceIcon get icon; double get latitude; double get longitude; int get radiusMeters; String? get address; List<FamilyPlaceNotificationPref> get notificationPrefs;
/// Create a copy of FamilySavedPlace
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FamilySavedPlaceCopyWith<FamilySavedPlace> get copyWith => _$FamilySavedPlaceCopyWithImpl<FamilySavedPlace>(this as FamilySavedPlace, _$identity);

  /// Serializes this FamilySavedPlace to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FamilySavedPlace&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.radiusMeters, radiusMeters) || other.radiusMeters == radiusMeters)&&(identical(other.address, address) || other.address == address)&&const DeepCollectionEquality().equals(other.notificationPrefs, notificationPrefs));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,icon,latitude,longitude,radiusMeters,address,const DeepCollectionEquality().hash(notificationPrefs));

@override
String toString() {
  return 'FamilySavedPlace(id: $id, name: $name, icon: $icon, latitude: $latitude, longitude: $longitude, radiusMeters: $radiusMeters, address: $address, notificationPrefs: $notificationPrefs)';
}


}

/// @nodoc
abstract mixin class $FamilySavedPlaceCopyWith<$Res>  {
  factory $FamilySavedPlaceCopyWith(FamilySavedPlace value, $Res Function(FamilySavedPlace) _then) = _$FamilySavedPlaceCopyWithImpl;
@useResult
$Res call({
 String id, String name,@JsonKey(unknownEnumValue: FamilyPlaceIcon.other) FamilyPlaceIcon icon, double latitude, double longitude, int radiusMeters, String? address, List<FamilyPlaceNotificationPref> notificationPrefs
});




}
/// @nodoc
class _$FamilySavedPlaceCopyWithImpl<$Res>
    implements $FamilySavedPlaceCopyWith<$Res> {
  _$FamilySavedPlaceCopyWithImpl(this._self, this._then);

  final FamilySavedPlace _self;
  final $Res Function(FamilySavedPlace) _then;

/// Create a copy of FamilySavedPlace
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? icon = null,Object? latitude = null,Object? longitude = null,Object? radiusMeters = null,Object? address = freezed,Object? notificationPrefs = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as FamilyPlaceIcon,latitude: null == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double,longitude: null == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double,radiusMeters: null == radiusMeters ? _self.radiusMeters : radiusMeters // ignore: cast_nullable_to_non_nullable
as int,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,notificationPrefs: null == notificationPrefs ? _self.notificationPrefs : notificationPrefs // ignore: cast_nullable_to_non_nullable
as List<FamilyPlaceNotificationPref>,
  ));
}

}


/// Adds pattern-matching-related methods to [FamilySavedPlace].
extension FamilySavedPlacePatterns on FamilySavedPlace {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FamilySavedPlace value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FamilySavedPlace() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FamilySavedPlace value)  $default,){
final _that = this;
switch (_that) {
case _FamilySavedPlace():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FamilySavedPlace value)?  $default,){
final _that = this;
switch (_that) {
case _FamilySavedPlace() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name, @JsonKey(unknownEnumValue: FamilyPlaceIcon.other)  FamilyPlaceIcon icon,  double latitude,  double longitude,  int radiusMeters,  String? address,  List<FamilyPlaceNotificationPref> notificationPrefs)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FamilySavedPlace() when $default != null:
return $default(_that.id,_that.name,_that.icon,_that.latitude,_that.longitude,_that.radiusMeters,_that.address,_that.notificationPrefs);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name, @JsonKey(unknownEnumValue: FamilyPlaceIcon.other)  FamilyPlaceIcon icon,  double latitude,  double longitude,  int radiusMeters,  String? address,  List<FamilyPlaceNotificationPref> notificationPrefs)  $default,) {final _that = this;
switch (_that) {
case _FamilySavedPlace():
return $default(_that.id,_that.name,_that.icon,_that.latitude,_that.longitude,_that.radiusMeters,_that.address,_that.notificationPrefs);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name, @JsonKey(unknownEnumValue: FamilyPlaceIcon.other)  FamilyPlaceIcon icon,  double latitude,  double longitude,  int radiusMeters,  String? address,  List<FamilyPlaceNotificationPref> notificationPrefs)?  $default,) {final _that = this;
switch (_that) {
case _FamilySavedPlace() when $default != null:
return $default(_that.id,_that.name,_that.icon,_that.latitude,_that.longitude,_that.radiusMeters,_that.address,_that.notificationPrefs);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FamilySavedPlace implements FamilySavedPlace {
  const _FamilySavedPlace({required this.id, required this.name, @JsonKey(unknownEnumValue: FamilyPlaceIcon.other) this.icon = FamilyPlaceIcon.other, required this.latitude, required this.longitude, this.radiusMeters = 300, this.address, final  List<FamilyPlaceNotificationPref> notificationPrefs = const <FamilyPlaceNotificationPref>[]}): _notificationPrefs = notificationPrefs;
  factory _FamilySavedPlace.fromJson(Map<String, dynamic> json) => _$FamilySavedPlaceFromJson(json);

@override final  String id;
@override final  String name;
@override@JsonKey(unknownEnumValue: FamilyPlaceIcon.other) final  FamilyPlaceIcon icon;
@override final  double latitude;
@override final  double longitude;
@override@JsonKey() final  int radiusMeters;
@override final  String? address;
 final  List<FamilyPlaceNotificationPref> _notificationPrefs;
@override@JsonKey() List<FamilyPlaceNotificationPref> get notificationPrefs {
  if (_notificationPrefs is EqualUnmodifiableListView) return _notificationPrefs;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_notificationPrefs);
}


/// Create a copy of FamilySavedPlace
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FamilySavedPlaceCopyWith<_FamilySavedPlace> get copyWith => __$FamilySavedPlaceCopyWithImpl<_FamilySavedPlace>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FamilySavedPlaceToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FamilySavedPlace&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.radiusMeters, radiusMeters) || other.radiusMeters == radiusMeters)&&(identical(other.address, address) || other.address == address)&&const DeepCollectionEquality().equals(other._notificationPrefs, _notificationPrefs));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,icon,latitude,longitude,radiusMeters,address,const DeepCollectionEquality().hash(_notificationPrefs));

@override
String toString() {
  return 'FamilySavedPlace(id: $id, name: $name, icon: $icon, latitude: $latitude, longitude: $longitude, radiusMeters: $radiusMeters, address: $address, notificationPrefs: $notificationPrefs)';
}


}

/// @nodoc
abstract mixin class _$FamilySavedPlaceCopyWith<$Res> implements $FamilySavedPlaceCopyWith<$Res> {
  factory _$FamilySavedPlaceCopyWith(_FamilySavedPlace value, $Res Function(_FamilySavedPlace) _then) = __$FamilySavedPlaceCopyWithImpl;
@override @useResult
$Res call({
 String id, String name,@JsonKey(unknownEnumValue: FamilyPlaceIcon.other) FamilyPlaceIcon icon, double latitude, double longitude, int radiusMeters, String? address, List<FamilyPlaceNotificationPref> notificationPrefs
});




}
/// @nodoc
class __$FamilySavedPlaceCopyWithImpl<$Res>
    implements _$FamilySavedPlaceCopyWith<$Res> {
  __$FamilySavedPlaceCopyWithImpl(this._self, this._then);

  final _FamilySavedPlace _self;
  final $Res Function(_FamilySavedPlace) _then;

/// Create a copy of FamilySavedPlace
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? icon = null,Object? latitude = null,Object? longitude = null,Object? radiusMeters = null,Object? address = freezed,Object? notificationPrefs = null,}) {
  return _then(_FamilySavedPlace(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as FamilyPlaceIcon,latitude: null == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double,longitude: null == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double,radiusMeters: null == radiusMeters ? _self.radiusMeters : radiusMeters // ignore: cast_nullable_to_non_nullable
as int,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,notificationPrefs: null == notificationPrefs ? _self._notificationPrefs : notificationPrefs // ignore: cast_nullable_to_non_nullable
as List<FamilyPlaceNotificationPref>,
  ));
}


}


/// @nodoc
mixin _$FamilyPlaceNotificationPref {

 String get placeId; String get subjectMemberId; bool get notifyArrivals; bool get notifyDepartures;
/// Create a copy of FamilyPlaceNotificationPref
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FamilyPlaceNotificationPrefCopyWith<FamilyPlaceNotificationPref> get copyWith => _$FamilyPlaceNotificationPrefCopyWithImpl<FamilyPlaceNotificationPref>(this as FamilyPlaceNotificationPref, _$identity);

  /// Serializes this FamilyPlaceNotificationPref to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FamilyPlaceNotificationPref&&(identical(other.placeId, placeId) || other.placeId == placeId)&&(identical(other.subjectMemberId, subjectMemberId) || other.subjectMemberId == subjectMemberId)&&(identical(other.notifyArrivals, notifyArrivals) || other.notifyArrivals == notifyArrivals)&&(identical(other.notifyDepartures, notifyDepartures) || other.notifyDepartures == notifyDepartures));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,placeId,subjectMemberId,notifyArrivals,notifyDepartures);

@override
String toString() {
  return 'FamilyPlaceNotificationPref(placeId: $placeId, subjectMemberId: $subjectMemberId, notifyArrivals: $notifyArrivals, notifyDepartures: $notifyDepartures)';
}


}

/// @nodoc
abstract mixin class $FamilyPlaceNotificationPrefCopyWith<$Res>  {
  factory $FamilyPlaceNotificationPrefCopyWith(FamilyPlaceNotificationPref value, $Res Function(FamilyPlaceNotificationPref) _then) = _$FamilyPlaceNotificationPrefCopyWithImpl;
@useResult
$Res call({
 String placeId, String subjectMemberId, bool notifyArrivals, bool notifyDepartures
});




}
/// @nodoc
class _$FamilyPlaceNotificationPrefCopyWithImpl<$Res>
    implements $FamilyPlaceNotificationPrefCopyWith<$Res> {
  _$FamilyPlaceNotificationPrefCopyWithImpl(this._self, this._then);

  final FamilyPlaceNotificationPref _self;
  final $Res Function(FamilyPlaceNotificationPref) _then;

/// Create a copy of FamilyPlaceNotificationPref
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? placeId = null,Object? subjectMemberId = null,Object? notifyArrivals = null,Object? notifyDepartures = null,}) {
  return _then(_self.copyWith(
placeId: null == placeId ? _self.placeId : placeId // ignore: cast_nullable_to_non_nullable
as String,subjectMemberId: null == subjectMemberId ? _self.subjectMemberId : subjectMemberId // ignore: cast_nullable_to_non_nullable
as String,notifyArrivals: null == notifyArrivals ? _self.notifyArrivals : notifyArrivals // ignore: cast_nullable_to_non_nullable
as bool,notifyDepartures: null == notifyDepartures ? _self.notifyDepartures : notifyDepartures // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [FamilyPlaceNotificationPref].
extension FamilyPlaceNotificationPrefPatterns on FamilyPlaceNotificationPref {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FamilyPlaceNotificationPref value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FamilyPlaceNotificationPref() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FamilyPlaceNotificationPref value)  $default,){
final _that = this;
switch (_that) {
case _FamilyPlaceNotificationPref():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FamilyPlaceNotificationPref value)?  $default,){
final _that = this;
switch (_that) {
case _FamilyPlaceNotificationPref() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String placeId,  String subjectMemberId,  bool notifyArrivals,  bool notifyDepartures)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FamilyPlaceNotificationPref() when $default != null:
return $default(_that.placeId,_that.subjectMemberId,_that.notifyArrivals,_that.notifyDepartures);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String placeId,  String subjectMemberId,  bool notifyArrivals,  bool notifyDepartures)  $default,) {final _that = this;
switch (_that) {
case _FamilyPlaceNotificationPref():
return $default(_that.placeId,_that.subjectMemberId,_that.notifyArrivals,_that.notifyDepartures);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String placeId,  String subjectMemberId,  bool notifyArrivals,  bool notifyDepartures)?  $default,) {final _that = this;
switch (_that) {
case _FamilyPlaceNotificationPref() when $default != null:
return $default(_that.placeId,_that.subjectMemberId,_that.notifyArrivals,_that.notifyDepartures);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FamilyPlaceNotificationPref implements FamilyPlaceNotificationPref {
  const _FamilyPlaceNotificationPref({required this.placeId, required this.subjectMemberId, this.notifyArrivals = true, this.notifyDepartures = true});
  factory _FamilyPlaceNotificationPref.fromJson(Map<String, dynamic> json) => _$FamilyPlaceNotificationPrefFromJson(json);

@override final  String placeId;
@override final  String subjectMemberId;
@override@JsonKey() final  bool notifyArrivals;
@override@JsonKey() final  bool notifyDepartures;

/// Create a copy of FamilyPlaceNotificationPref
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FamilyPlaceNotificationPrefCopyWith<_FamilyPlaceNotificationPref> get copyWith => __$FamilyPlaceNotificationPrefCopyWithImpl<_FamilyPlaceNotificationPref>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FamilyPlaceNotificationPrefToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FamilyPlaceNotificationPref&&(identical(other.placeId, placeId) || other.placeId == placeId)&&(identical(other.subjectMemberId, subjectMemberId) || other.subjectMemberId == subjectMemberId)&&(identical(other.notifyArrivals, notifyArrivals) || other.notifyArrivals == notifyArrivals)&&(identical(other.notifyDepartures, notifyDepartures) || other.notifyDepartures == notifyDepartures));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,placeId,subjectMemberId,notifyArrivals,notifyDepartures);

@override
String toString() {
  return 'FamilyPlaceNotificationPref(placeId: $placeId, subjectMemberId: $subjectMemberId, notifyArrivals: $notifyArrivals, notifyDepartures: $notifyDepartures)';
}


}

/// @nodoc
abstract mixin class _$FamilyPlaceNotificationPrefCopyWith<$Res> implements $FamilyPlaceNotificationPrefCopyWith<$Res> {
  factory _$FamilyPlaceNotificationPrefCopyWith(_FamilyPlaceNotificationPref value, $Res Function(_FamilyPlaceNotificationPref) _then) = __$FamilyPlaceNotificationPrefCopyWithImpl;
@override @useResult
$Res call({
 String placeId, String subjectMemberId, bool notifyArrivals, bool notifyDepartures
});




}
/// @nodoc
class __$FamilyPlaceNotificationPrefCopyWithImpl<$Res>
    implements _$FamilyPlaceNotificationPrefCopyWith<$Res> {
  __$FamilyPlaceNotificationPrefCopyWithImpl(this._self, this._then);

  final _FamilyPlaceNotificationPref _self;
  final $Res Function(_FamilyPlaceNotificationPref) _then;

/// Create a copy of FamilyPlaceNotificationPref
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? placeId = null,Object? subjectMemberId = null,Object? notifyArrivals = null,Object? notifyDepartures = null,}) {
  return _then(_FamilyPlaceNotificationPref(
placeId: null == placeId ? _self.placeId : placeId // ignore: cast_nullable_to_non_nullable
as String,subjectMemberId: null == subjectMemberId ? _self.subjectMemberId : subjectMemberId // ignore: cast_nullable_to_non_nullable
as String,notifyArrivals: null == notifyArrivals ? _self.notifyArrivals : notifyArrivals // ignore: cast_nullable_to_non_nullable
as bool,notifyDepartures: null == notifyDepartures ? _self.notifyDepartures : notifyDepartures // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$FamilyMemberSnippet {

 String get id; String? get nickname; FamilyMemberUserSnippet? get user;
/// Create a copy of FamilyMemberSnippet
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FamilyMemberSnippetCopyWith<FamilyMemberSnippet> get copyWith => _$FamilyMemberSnippetCopyWithImpl<FamilyMemberSnippet>(this as FamilyMemberSnippet, _$identity);

  /// Serializes this FamilyMemberSnippet to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FamilyMemberSnippet&&(identical(other.id, id) || other.id == id)&&(identical(other.nickname, nickname) || other.nickname == nickname)&&(identical(other.user, user) || other.user == user));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,nickname,user);

@override
String toString() {
  return 'FamilyMemberSnippet(id: $id, nickname: $nickname, user: $user)';
}


}

/// @nodoc
abstract mixin class $FamilyMemberSnippetCopyWith<$Res>  {
  factory $FamilyMemberSnippetCopyWith(FamilyMemberSnippet value, $Res Function(FamilyMemberSnippet) _then) = _$FamilyMemberSnippetCopyWithImpl;
@useResult
$Res call({
 String id, String? nickname, FamilyMemberUserSnippet? user
});


$FamilyMemberUserSnippetCopyWith<$Res>? get user;

}
/// @nodoc
class _$FamilyMemberSnippetCopyWithImpl<$Res>
    implements $FamilyMemberSnippetCopyWith<$Res> {
  _$FamilyMemberSnippetCopyWithImpl(this._self, this._then);

  final FamilyMemberSnippet _self;
  final $Res Function(FamilyMemberSnippet) _then;

/// Create a copy of FamilyMemberSnippet
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? nickname = freezed,Object? user = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,nickname: freezed == nickname ? _self.nickname : nickname // ignore: cast_nullable_to_non_nullable
as String?,user: freezed == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as FamilyMemberUserSnippet?,
  ));
}
/// Create a copy of FamilyMemberSnippet
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FamilyMemberUserSnippetCopyWith<$Res>? get user {
    if (_self.user == null) {
    return null;
  }

  return $FamilyMemberUserSnippetCopyWith<$Res>(_self.user!, (value) {
    return _then(_self.copyWith(user: value));
  });
}
}


/// Adds pattern-matching-related methods to [FamilyMemberSnippet].
extension FamilyMemberSnippetPatterns on FamilyMemberSnippet {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FamilyMemberSnippet value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FamilyMemberSnippet() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FamilyMemberSnippet value)  $default,){
final _that = this;
switch (_that) {
case _FamilyMemberSnippet():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FamilyMemberSnippet value)?  $default,){
final _that = this;
switch (_that) {
case _FamilyMemberSnippet() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? nickname,  FamilyMemberUserSnippet? user)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FamilyMemberSnippet() when $default != null:
return $default(_that.id,_that.nickname,_that.user);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? nickname,  FamilyMemberUserSnippet? user)  $default,) {final _that = this;
switch (_that) {
case _FamilyMemberSnippet():
return $default(_that.id,_that.nickname,_that.user);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? nickname,  FamilyMemberUserSnippet? user)?  $default,) {final _that = this;
switch (_that) {
case _FamilyMemberSnippet() when $default != null:
return $default(_that.id,_that.nickname,_that.user);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FamilyMemberSnippet extends FamilyMemberSnippet {
  const _FamilyMemberSnippet({required this.id, this.nickname, this.user}): super._();
  factory _FamilyMemberSnippet.fromJson(Map<String, dynamic> json) => _$FamilyMemberSnippetFromJson(json);

@override final  String id;
@override final  String? nickname;
@override final  FamilyMemberUserSnippet? user;

/// Create a copy of FamilyMemberSnippet
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FamilyMemberSnippetCopyWith<_FamilyMemberSnippet> get copyWith => __$FamilyMemberSnippetCopyWithImpl<_FamilyMemberSnippet>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FamilyMemberSnippetToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FamilyMemberSnippet&&(identical(other.id, id) || other.id == id)&&(identical(other.nickname, nickname) || other.nickname == nickname)&&(identical(other.user, user) || other.user == user));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,nickname,user);

@override
String toString() {
  return 'FamilyMemberSnippet(id: $id, nickname: $nickname, user: $user)';
}


}

/// @nodoc
abstract mixin class _$FamilyMemberSnippetCopyWith<$Res> implements $FamilyMemberSnippetCopyWith<$Res> {
  factory _$FamilyMemberSnippetCopyWith(_FamilyMemberSnippet value, $Res Function(_FamilyMemberSnippet) _then) = __$FamilyMemberSnippetCopyWithImpl;
@override @useResult
$Res call({
 String id, String? nickname, FamilyMemberUserSnippet? user
});


@override $FamilyMemberUserSnippetCopyWith<$Res>? get user;

}
/// @nodoc
class __$FamilyMemberSnippetCopyWithImpl<$Res>
    implements _$FamilyMemberSnippetCopyWith<$Res> {
  __$FamilyMemberSnippetCopyWithImpl(this._self, this._then);

  final _FamilyMemberSnippet _self;
  final $Res Function(_FamilyMemberSnippet) _then;

/// Create a copy of FamilyMemberSnippet
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? nickname = freezed,Object? user = freezed,}) {
  return _then(_FamilyMemberSnippet(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,nickname: freezed == nickname ? _self.nickname : nickname // ignore: cast_nullable_to_non_nullable
as String?,user: freezed == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as FamilyMemberUserSnippet?,
  ));
}

/// Create a copy of FamilyMemberSnippet
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FamilyMemberUserSnippetCopyWith<$Res>? get user {
    if (_self.user == null) {
    return null;
  }

  return $FamilyMemberUserSnippetCopyWith<$Res>(_self.user!, (value) {
    return _then(_self.copyWith(user: value));
  });
}
}


/// @nodoc
mixin _$FamilyMemberUserSnippet {

 String get id; String? get name; String? get profilePictureUrl;
/// Create a copy of FamilyMemberUserSnippet
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FamilyMemberUserSnippetCopyWith<FamilyMemberUserSnippet> get copyWith => _$FamilyMemberUserSnippetCopyWithImpl<FamilyMemberUserSnippet>(this as FamilyMemberUserSnippet, _$identity);

  /// Serializes this FamilyMemberUserSnippet to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FamilyMemberUserSnippet&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.profilePictureUrl, profilePictureUrl) || other.profilePictureUrl == profilePictureUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,profilePictureUrl);

@override
String toString() {
  return 'FamilyMemberUserSnippet(id: $id, name: $name, profilePictureUrl: $profilePictureUrl)';
}


}

/// @nodoc
abstract mixin class $FamilyMemberUserSnippetCopyWith<$Res>  {
  factory $FamilyMemberUserSnippetCopyWith(FamilyMemberUserSnippet value, $Res Function(FamilyMemberUserSnippet) _then) = _$FamilyMemberUserSnippetCopyWithImpl;
@useResult
$Res call({
 String id, String? name, String? profilePictureUrl
});




}
/// @nodoc
class _$FamilyMemberUserSnippetCopyWithImpl<$Res>
    implements $FamilyMemberUserSnippetCopyWith<$Res> {
  _$FamilyMemberUserSnippetCopyWithImpl(this._self, this._then);

  final FamilyMemberUserSnippet _self;
  final $Res Function(FamilyMemberUserSnippet) _then;

/// Create a copy of FamilyMemberUserSnippet
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = freezed,Object? profilePictureUrl = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,profilePictureUrl: freezed == profilePictureUrl ? _self.profilePictureUrl : profilePictureUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [FamilyMemberUserSnippet].
extension FamilyMemberUserSnippetPatterns on FamilyMemberUserSnippet {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FamilyMemberUserSnippet value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FamilyMemberUserSnippet() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FamilyMemberUserSnippet value)  $default,){
final _that = this;
switch (_that) {
case _FamilyMemberUserSnippet():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FamilyMemberUserSnippet value)?  $default,){
final _that = this;
switch (_that) {
case _FamilyMemberUserSnippet() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? name,  String? profilePictureUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FamilyMemberUserSnippet() when $default != null:
return $default(_that.id,_that.name,_that.profilePictureUrl);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? name,  String? profilePictureUrl)  $default,) {final _that = this;
switch (_that) {
case _FamilyMemberUserSnippet():
return $default(_that.id,_that.name,_that.profilePictureUrl);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? name,  String? profilePictureUrl)?  $default,) {final _that = this;
switch (_that) {
case _FamilyMemberUserSnippet() when $default != null:
return $default(_that.id,_that.name,_that.profilePictureUrl);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FamilyMemberUserSnippet implements FamilyMemberUserSnippet {
  const _FamilyMemberUserSnippet({required this.id, this.name, this.profilePictureUrl});
  factory _FamilyMemberUserSnippet.fromJson(Map<String, dynamic> json) => _$FamilyMemberUserSnippetFromJson(json);

@override final  String id;
@override final  String? name;
@override final  String? profilePictureUrl;

/// Create a copy of FamilyMemberUserSnippet
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FamilyMemberUserSnippetCopyWith<_FamilyMemberUserSnippet> get copyWith => __$FamilyMemberUserSnippetCopyWithImpl<_FamilyMemberUserSnippet>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FamilyMemberUserSnippetToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FamilyMemberUserSnippet&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.profilePictureUrl, profilePictureUrl) || other.profilePictureUrl == profilePictureUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,profilePictureUrl);

@override
String toString() {
  return 'FamilyMemberUserSnippet(id: $id, name: $name, profilePictureUrl: $profilePictureUrl)';
}


}

/// @nodoc
abstract mixin class _$FamilyMemberUserSnippetCopyWith<$Res> implements $FamilyMemberUserSnippetCopyWith<$Res> {
  factory _$FamilyMemberUserSnippetCopyWith(_FamilyMemberUserSnippet value, $Res Function(_FamilyMemberUserSnippet) _then) = __$FamilyMemberUserSnippetCopyWithImpl;
@override @useResult
$Res call({
 String id, String? name, String? profilePictureUrl
});




}
/// @nodoc
class __$FamilyMemberUserSnippetCopyWithImpl<$Res>
    implements _$FamilyMemberUserSnippetCopyWith<$Res> {
  __$FamilyMemberUserSnippetCopyWithImpl(this._self, this._then);

  final _FamilyMemberUserSnippet _self;
  final $Res Function(_FamilyMemberUserSnippet) _then;

/// Create a copy of FamilyMemberUserSnippet
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = freezed,Object? profilePictureUrl = freezed,}) {
  return _then(_FamilyMemberUserSnippet(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,profilePictureUrl: freezed == profilePictureUrl ? _self.profilePictureUrl : profilePictureUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$FamilyCheckIn {

 String get id; String get circleId; String get memberId;@JsonKey(unknownEnumValue: FamilyCheckInStatus.safe) FamilyCheckInStatus get status; String? get message; double? get latitude; double? get longitude; String? get requestId; String? get hazardId; FamilyMemberSnippet? get member; DateTime? get createdAt;
/// Create a copy of FamilyCheckIn
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FamilyCheckInCopyWith<FamilyCheckIn> get copyWith => _$FamilyCheckInCopyWithImpl<FamilyCheckIn>(this as FamilyCheckIn, _$identity);

  /// Serializes this FamilyCheckIn to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FamilyCheckIn&&(identical(other.id, id) || other.id == id)&&(identical(other.circleId, circleId) || other.circleId == circleId)&&(identical(other.memberId, memberId) || other.memberId == memberId)&&(identical(other.status, status) || other.status == status)&&(identical(other.message, message) || other.message == message)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.requestId, requestId) || other.requestId == requestId)&&(identical(other.hazardId, hazardId) || other.hazardId == hazardId)&&(identical(other.member, member) || other.member == member)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,circleId,memberId,status,message,latitude,longitude,requestId,hazardId,member,createdAt);

@override
String toString() {
  return 'FamilyCheckIn(id: $id, circleId: $circleId, memberId: $memberId, status: $status, message: $message, latitude: $latitude, longitude: $longitude, requestId: $requestId, hazardId: $hazardId, member: $member, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $FamilyCheckInCopyWith<$Res>  {
  factory $FamilyCheckInCopyWith(FamilyCheckIn value, $Res Function(FamilyCheckIn) _then) = _$FamilyCheckInCopyWithImpl;
@useResult
$Res call({
 String id, String circleId, String memberId,@JsonKey(unknownEnumValue: FamilyCheckInStatus.safe) FamilyCheckInStatus status, String? message, double? latitude, double? longitude, String? requestId, String? hazardId, FamilyMemberSnippet? member, DateTime? createdAt
});


$FamilyMemberSnippetCopyWith<$Res>? get member;

}
/// @nodoc
class _$FamilyCheckInCopyWithImpl<$Res>
    implements $FamilyCheckInCopyWith<$Res> {
  _$FamilyCheckInCopyWithImpl(this._self, this._then);

  final FamilyCheckIn _self;
  final $Res Function(FamilyCheckIn) _then;

/// Create a copy of FamilyCheckIn
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? circleId = null,Object? memberId = null,Object? status = null,Object? message = freezed,Object? latitude = freezed,Object? longitude = freezed,Object? requestId = freezed,Object? hazardId = freezed,Object? member = freezed,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,circleId: null == circleId ? _self.circleId : circleId // ignore: cast_nullable_to_non_nullable
as String,memberId: null == memberId ? _self.memberId : memberId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as FamilyCheckInStatus,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double?,requestId: freezed == requestId ? _self.requestId : requestId // ignore: cast_nullable_to_non_nullable
as String?,hazardId: freezed == hazardId ? _self.hazardId : hazardId // ignore: cast_nullable_to_non_nullable
as String?,member: freezed == member ? _self.member : member // ignore: cast_nullable_to_non_nullable
as FamilyMemberSnippet?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}
/// Create a copy of FamilyCheckIn
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FamilyMemberSnippetCopyWith<$Res>? get member {
    if (_self.member == null) {
    return null;
  }

  return $FamilyMemberSnippetCopyWith<$Res>(_self.member!, (value) {
    return _then(_self.copyWith(member: value));
  });
}
}


/// Adds pattern-matching-related methods to [FamilyCheckIn].
extension FamilyCheckInPatterns on FamilyCheckIn {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FamilyCheckIn value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FamilyCheckIn() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FamilyCheckIn value)  $default,){
final _that = this;
switch (_that) {
case _FamilyCheckIn():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FamilyCheckIn value)?  $default,){
final _that = this;
switch (_that) {
case _FamilyCheckIn() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String circleId,  String memberId, @JsonKey(unknownEnumValue: FamilyCheckInStatus.safe)  FamilyCheckInStatus status,  String? message,  double? latitude,  double? longitude,  String? requestId,  String? hazardId,  FamilyMemberSnippet? member,  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FamilyCheckIn() when $default != null:
return $default(_that.id,_that.circleId,_that.memberId,_that.status,_that.message,_that.latitude,_that.longitude,_that.requestId,_that.hazardId,_that.member,_that.createdAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String circleId,  String memberId, @JsonKey(unknownEnumValue: FamilyCheckInStatus.safe)  FamilyCheckInStatus status,  String? message,  double? latitude,  double? longitude,  String? requestId,  String? hazardId,  FamilyMemberSnippet? member,  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _FamilyCheckIn():
return $default(_that.id,_that.circleId,_that.memberId,_that.status,_that.message,_that.latitude,_that.longitude,_that.requestId,_that.hazardId,_that.member,_that.createdAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String circleId,  String memberId, @JsonKey(unknownEnumValue: FamilyCheckInStatus.safe)  FamilyCheckInStatus status,  String? message,  double? latitude,  double? longitude,  String? requestId,  String? hazardId,  FamilyMemberSnippet? member,  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _FamilyCheckIn() when $default != null:
return $default(_that.id,_that.circleId,_that.memberId,_that.status,_that.message,_that.latitude,_that.longitude,_that.requestId,_that.hazardId,_that.member,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FamilyCheckIn implements FamilyCheckIn {
  const _FamilyCheckIn({required this.id, required this.circleId, required this.memberId, @JsonKey(unknownEnumValue: FamilyCheckInStatus.safe) this.status = FamilyCheckInStatus.safe, this.message, this.latitude, this.longitude, this.requestId, this.hazardId, this.member, this.createdAt});
  factory _FamilyCheckIn.fromJson(Map<String, dynamic> json) => _$FamilyCheckInFromJson(json);

@override final  String id;
@override final  String circleId;
@override final  String memberId;
@override@JsonKey(unknownEnumValue: FamilyCheckInStatus.safe) final  FamilyCheckInStatus status;
@override final  String? message;
@override final  double? latitude;
@override final  double? longitude;
@override final  String? requestId;
@override final  String? hazardId;
@override final  FamilyMemberSnippet? member;
@override final  DateTime? createdAt;

/// Create a copy of FamilyCheckIn
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FamilyCheckInCopyWith<_FamilyCheckIn> get copyWith => __$FamilyCheckInCopyWithImpl<_FamilyCheckIn>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FamilyCheckInToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FamilyCheckIn&&(identical(other.id, id) || other.id == id)&&(identical(other.circleId, circleId) || other.circleId == circleId)&&(identical(other.memberId, memberId) || other.memberId == memberId)&&(identical(other.status, status) || other.status == status)&&(identical(other.message, message) || other.message == message)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.requestId, requestId) || other.requestId == requestId)&&(identical(other.hazardId, hazardId) || other.hazardId == hazardId)&&(identical(other.member, member) || other.member == member)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,circleId,memberId,status,message,latitude,longitude,requestId,hazardId,member,createdAt);

@override
String toString() {
  return 'FamilyCheckIn(id: $id, circleId: $circleId, memberId: $memberId, status: $status, message: $message, latitude: $latitude, longitude: $longitude, requestId: $requestId, hazardId: $hazardId, member: $member, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$FamilyCheckInCopyWith<$Res> implements $FamilyCheckInCopyWith<$Res> {
  factory _$FamilyCheckInCopyWith(_FamilyCheckIn value, $Res Function(_FamilyCheckIn) _then) = __$FamilyCheckInCopyWithImpl;
@override @useResult
$Res call({
 String id, String circleId, String memberId,@JsonKey(unknownEnumValue: FamilyCheckInStatus.safe) FamilyCheckInStatus status, String? message, double? latitude, double? longitude, String? requestId, String? hazardId, FamilyMemberSnippet? member, DateTime? createdAt
});


@override $FamilyMemberSnippetCopyWith<$Res>? get member;

}
/// @nodoc
class __$FamilyCheckInCopyWithImpl<$Res>
    implements _$FamilyCheckInCopyWith<$Res> {
  __$FamilyCheckInCopyWithImpl(this._self, this._then);

  final _FamilyCheckIn _self;
  final $Res Function(_FamilyCheckIn) _then;

/// Create a copy of FamilyCheckIn
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? circleId = null,Object? memberId = null,Object? status = null,Object? message = freezed,Object? latitude = freezed,Object? longitude = freezed,Object? requestId = freezed,Object? hazardId = freezed,Object? member = freezed,Object? createdAt = freezed,}) {
  return _then(_FamilyCheckIn(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,circleId: null == circleId ? _self.circleId : circleId // ignore: cast_nullable_to_non_nullable
as String,memberId: null == memberId ? _self.memberId : memberId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as FamilyCheckInStatus,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double?,requestId: freezed == requestId ? _self.requestId : requestId // ignore: cast_nullable_to_non_nullable
as String?,hazardId: freezed == hazardId ? _self.hazardId : hazardId // ignore: cast_nullable_to_non_nullable
as String?,member: freezed == member ? _self.member : member // ignore: cast_nullable_to_non_nullable
as FamilyMemberSnippet?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of FamilyCheckIn
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FamilyMemberSnippetCopyWith<$Res>? get member {
    if (_self.member == null) {
    return null;
  }

  return $FamilyMemberSnippetCopyWith<$Res>(_self.member!, (value) {
    return _then(_self.copyWith(member: value));
  });
}
}


/// @nodoc
mixin _$FamilySosList {

 String get id; String get ownerUserId; String get name; bool get isDefault; List<String> get memberIds; DateTime? get createdAt;
/// Create a copy of FamilySosList
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FamilySosListCopyWith<FamilySosList> get copyWith => _$FamilySosListCopyWithImpl<FamilySosList>(this as FamilySosList, _$identity);

  /// Serializes this FamilySosList to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FamilySosList&&(identical(other.id, id) || other.id == id)&&(identical(other.ownerUserId, ownerUserId) || other.ownerUserId == ownerUserId)&&(identical(other.name, name) || other.name == name)&&(identical(other.isDefault, isDefault) || other.isDefault == isDefault)&&const DeepCollectionEquality().equals(other.memberIds, memberIds)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,ownerUserId,name,isDefault,const DeepCollectionEquality().hash(memberIds),createdAt);

@override
String toString() {
  return 'FamilySosList(id: $id, ownerUserId: $ownerUserId, name: $name, isDefault: $isDefault, memberIds: $memberIds, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $FamilySosListCopyWith<$Res>  {
  factory $FamilySosListCopyWith(FamilySosList value, $Res Function(FamilySosList) _then) = _$FamilySosListCopyWithImpl;
@useResult
$Res call({
 String id, String ownerUserId, String name, bool isDefault, List<String> memberIds, DateTime? createdAt
});




}
/// @nodoc
class _$FamilySosListCopyWithImpl<$Res>
    implements $FamilySosListCopyWith<$Res> {
  _$FamilySosListCopyWithImpl(this._self, this._then);

  final FamilySosList _self;
  final $Res Function(FamilySosList) _then;

/// Create a copy of FamilySosList
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? ownerUserId = null,Object? name = null,Object? isDefault = null,Object? memberIds = null,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,ownerUserId: null == ownerUserId ? _self.ownerUserId : ownerUserId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,isDefault: null == isDefault ? _self.isDefault : isDefault // ignore: cast_nullable_to_non_nullable
as bool,memberIds: null == memberIds ? _self.memberIds : memberIds // ignore: cast_nullable_to_non_nullable
as List<String>,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [FamilySosList].
extension FamilySosListPatterns on FamilySosList {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FamilySosList value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FamilySosList() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FamilySosList value)  $default,){
final _that = this;
switch (_that) {
case _FamilySosList():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FamilySosList value)?  $default,){
final _that = this;
switch (_that) {
case _FamilySosList() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String ownerUserId,  String name,  bool isDefault,  List<String> memberIds,  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FamilySosList() when $default != null:
return $default(_that.id,_that.ownerUserId,_that.name,_that.isDefault,_that.memberIds,_that.createdAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String ownerUserId,  String name,  bool isDefault,  List<String> memberIds,  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _FamilySosList():
return $default(_that.id,_that.ownerUserId,_that.name,_that.isDefault,_that.memberIds,_that.createdAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String ownerUserId,  String name,  bool isDefault,  List<String> memberIds,  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _FamilySosList() when $default != null:
return $default(_that.id,_that.ownerUserId,_that.name,_that.isDefault,_that.memberIds,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FamilySosList implements FamilySosList {
  const _FamilySosList({required this.id, required this.ownerUserId, required this.name, this.isDefault = false, final  List<String> memberIds = const <String>[], this.createdAt}): _memberIds = memberIds;
  factory _FamilySosList.fromJson(Map<String, dynamic> json) => _$FamilySosListFromJson(json);

@override final  String id;
@override final  String ownerUserId;
@override final  String name;
@override@JsonKey() final  bool isDefault;
 final  List<String> _memberIds;
@override@JsonKey() List<String> get memberIds {
  if (_memberIds is EqualUnmodifiableListView) return _memberIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_memberIds);
}

@override final  DateTime? createdAt;

/// Create a copy of FamilySosList
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FamilySosListCopyWith<_FamilySosList> get copyWith => __$FamilySosListCopyWithImpl<_FamilySosList>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FamilySosListToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FamilySosList&&(identical(other.id, id) || other.id == id)&&(identical(other.ownerUserId, ownerUserId) || other.ownerUserId == ownerUserId)&&(identical(other.name, name) || other.name == name)&&(identical(other.isDefault, isDefault) || other.isDefault == isDefault)&&const DeepCollectionEquality().equals(other._memberIds, _memberIds)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,ownerUserId,name,isDefault,const DeepCollectionEquality().hash(_memberIds),createdAt);

@override
String toString() {
  return 'FamilySosList(id: $id, ownerUserId: $ownerUserId, name: $name, isDefault: $isDefault, memberIds: $memberIds, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$FamilySosListCopyWith<$Res> implements $FamilySosListCopyWith<$Res> {
  factory _$FamilySosListCopyWith(_FamilySosList value, $Res Function(_FamilySosList) _then) = __$FamilySosListCopyWithImpl;
@override @useResult
$Res call({
 String id, String ownerUserId, String name, bool isDefault, List<String> memberIds, DateTime? createdAt
});




}
/// @nodoc
class __$FamilySosListCopyWithImpl<$Res>
    implements _$FamilySosListCopyWith<$Res> {
  __$FamilySosListCopyWithImpl(this._self, this._then);

  final _FamilySosList _self;
  final $Res Function(_FamilySosList) _then;

/// Create a copy of FamilySosList
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? ownerUserId = null,Object? name = null,Object? isDefault = null,Object? memberIds = null,Object? createdAt = freezed,}) {
  return _then(_FamilySosList(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,ownerUserId: null == ownerUserId ? _self.ownerUserId : ownerUserId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,isDefault: null == isDefault ? _self.isDefault : isDefault // ignore: cast_nullable_to_non_nullable
as bool,memberIds: null == memberIds ? _self._memberIds : memberIds // ignore: cast_nullable_to_non_nullable
as List<String>,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$FamilyTransferCandidate {

 String get memberId; String get name; String? get profilePictureUrl;@JsonKey(unknownEnumValue: FamilyRole.adult) FamilyRole get role; bool get eligible;/// Why the member cannot take over, when [eligible] is false.
 String? get reason;
/// Create a copy of FamilyTransferCandidate
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FamilyTransferCandidateCopyWith<FamilyTransferCandidate> get copyWith => _$FamilyTransferCandidateCopyWithImpl<FamilyTransferCandidate>(this as FamilyTransferCandidate, _$identity);

  /// Serializes this FamilyTransferCandidate to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FamilyTransferCandidate&&(identical(other.memberId, memberId) || other.memberId == memberId)&&(identical(other.name, name) || other.name == name)&&(identical(other.profilePictureUrl, profilePictureUrl) || other.profilePictureUrl == profilePictureUrl)&&(identical(other.role, role) || other.role == role)&&(identical(other.eligible, eligible) || other.eligible == eligible)&&(identical(other.reason, reason) || other.reason == reason));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,memberId,name,profilePictureUrl,role,eligible,reason);

@override
String toString() {
  return 'FamilyTransferCandidate(memberId: $memberId, name: $name, profilePictureUrl: $profilePictureUrl, role: $role, eligible: $eligible, reason: $reason)';
}


}

/// @nodoc
abstract mixin class $FamilyTransferCandidateCopyWith<$Res>  {
  factory $FamilyTransferCandidateCopyWith(FamilyTransferCandidate value, $Res Function(FamilyTransferCandidate) _then) = _$FamilyTransferCandidateCopyWithImpl;
@useResult
$Res call({
 String memberId, String name, String? profilePictureUrl,@JsonKey(unknownEnumValue: FamilyRole.adult) FamilyRole role, bool eligible, String? reason
});




}
/// @nodoc
class _$FamilyTransferCandidateCopyWithImpl<$Res>
    implements $FamilyTransferCandidateCopyWith<$Res> {
  _$FamilyTransferCandidateCopyWithImpl(this._self, this._then);

  final FamilyTransferCandidate _self;
  final $Res Function(FamilyTransferCandidate) _then;

/// Create a copy of FamilyTransferCandidate
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? memberId = null,Object? name = null,Object? profilePictureUrl = freezed,Object? role = null,Object? eligible = null,Object? reason = freezed,}) {
  return _then(_self.copyWith(
memberId: null == memberId ? _self.memberId : memberId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,profilePictureUrl: freezed == profilePictureUrl ? _self.profilePictureUrl : profilePictureUrl // ignore: cast_nullable_to_non_nullable
as String?,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as FamilyRole,eligible: null == eligible ? _self.eligible : eligible // ignore: cast_nullable_to_non_nullable
as bool,reason: freezed == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [FamilyTransferCandidate].
extension FamilyTransferCandidatePatterns on FamilyTransferCandidate {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FamilyTransferCandidate value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FamilyTransferCandidate() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FamilyTransferCandidate value)  $default,){
final _that = this;
switch (_that) {
case _FamilyTransferCandidate():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FamilyTransferCandidate value)?  $default,){
final _that = this;
switch (_that) {
case _FamilyTransferCandidate() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String memberId,  String name,  String? profilePictureUrl, @JsonKey(unknownEnumValue: FamilyRole.adult)  FamilyRole role,  bool eligible,  String? reason)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FamilyTransferCandidate() when $default != null:
return $default(_that.memberId,_that.name,_that.profilePictureUrl,_that.role,_that.eligible,_that.reason);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String memberId,  String name,  String? profilePictureUrl, @JsonKey(unknownEnumValue: FamilyRole.adult)  FamilyRole role,  bool eligible,  String? reason)  $default,) {final _that = this;
switch (_that) {
case _FamilyTransferCandidate():
return $default(_that.memberId,_that.name,_that.profilePictureUrl,_that.role,_that.eligible,_that.reason);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String memberId,  String name,  String? profilePictureUrl, @JsonKey(unknownEnumValue: FamilyRole.adult)  FamilyRole role,  bool eligible,  String? reason)?  $default,) {final _that = this;
switch (_that) {
case _FamilyTransferCandidate() when $default != null:
return $default(_that.memberId,_that.name,_that.profilePictureUrl,_that.role,_that.eligible,_that.reason);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FamilyTransferCandidate implements FamilyTransferCandidate {
  const _FamilyTransferCandidate({required this.memberId, required this.name, this.profilePictureUrl, @JsonKey(unknownEnumValue: FamilyRole.adult) this.role = FamilyRole.adult, this.eligible = false, this.reason});
  factory _FamilyTransferCandidate.fromJson(Map<String, dynamic> json) => _$FamilyTransferCandidateFromJson(json);

@override final  String memberId;
@override final  String name;
@override final  String? profilePictureUrl;
@override@JsonKey(unknownEnumValue: FamilyRole.adult) final  FamilyRole role;
@override@JsonKey() final  bool eligible;
/// Why the member cannot take over, when [eligible] is false.
@override final  String? reason;

/// Create a copy of FamilyTransferCandidate
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FamilyTransferCandidateCopyWith<_FamilyTransferCandidate> get copyWith => __$FamilyTransferCandidateCopyWithImpl<_FamilyTransferCandidate>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FamilyTransferCandidateToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FamilyTransferCandidate&&(identical(other.memberId, memberId) || other.memberId == memberId)&&(identical(other.name, name) || other.name == name)&&(identical(other.profilePictureUrl, profilePictureUrl) || other.profilePictureUrl == profilePictureUrl)&&(identical(other.role, role) || other.role == role)&&(identical(other.eligible, eligible) || other.eligible == eligible)&&(identical(other.reason, reason) || other.reason == reason));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,memberId,name,profilePictureUrl,role,eligible,reason);

@override
String toString() {
  return 'FamilyTransferCandidate(memberId: $memberId, name: $name, profilePictureUrl: $profilePictureUrl, role: $role, eligible: $eligible, reason: $reason)';
}


}

/// @nodoc
abstract mixin class _$FamilyTransferCandidateCopyWith<$Res> implements $FamilyTransferCandidateCopyWith<$Res> {
  factory _$FamilyTransferCandidateCopyWith(_FamilyTransferCandidate value, $Res Function(_FamilyTransferCandidate) _then) = __$FamilyTransferCandidateCopyWithImpl;
@override @useResult
$Res call({
 String memberId, String name, String? profilePictureUrl,@JsonKey(unknownEnumValue: FamilyRole.adult) FamilyRole role, bool eligible, String? reason
});




}
/// @nodoc
class __$FamilyTransferCandidateCopyWithImpl<$Res>
    implements _$FamilyTransferCandidateCopyWith<$Res> {
  __$FamilyTransferCandidateCopyWithImpl(this._self, this._then);

  final _FamilyTransferCandidate _self;
  final $Res Function(_FamilyTransferCandidate) _then;

/// Create a copy of FamilyTransferCandidate
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? memberId = null,Object? name = null,Object? profilePictureUrl = freezed,Object? role = null,Object? eligible = null,Object? reason = freezed,}) {
  return _then(_FamilyTransferCandidate(
memberId: null == memberId ? _self.memberId : memberId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,profilePictureUrl: freezed == profilePictureUrl ? _self.profilePictureUrl : profilePictureUrl // ignore: cast_nullable_to_non_nullable
as String?,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as FamilyRole,eligible: null == eligible ? _self.eligible : eligible // ignore: cast_nullable_to_non_nullable
as bool,reason: freezed == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$FamilySosRecipientGroup {

 String get circleId; String get name; String? get themeColor; List<FamilySosRecipient> get members;
/// Create a copy of FamilySosRecipientGroup
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FamilySosRecipientGroupCopyWith<FamilySosRecipientGroup> get copyWith => _$FamilySosRecipientGroupCopyWithImpl<FamilySosRecipientGroup>(this as FamilySosRecipientGroup, _$identity);

  /// Serializes this FamilySosRecipientGroup to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FamilySosRecipientGroup&&(identical(other.circleId, circleId) || other.circleId == circleId)&&(identical(other.name, name) || other.name == name)&&(identical(other.themeColor, themeColor) || other.themeColor == themeColor)&&const DeepCollectionEquality().equals(other.members, members));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,circleId,name,themeColor,const DeepCollectionEquality().hash(members));

@override
String toString() {
  return 'FamilySosRecipientGroup(circleId: $circleId, name: $name, themeColor: $themeColor, members: $members)';
}


}

/// @nodoc
abstract mixin class $FamilySosRecipientGroupCopyWith<$Res>  {
  factory $FamilySosRecipientGroupCopyWith(FamilySosRecipientGroup value, $Res Function(FamilySosRecipientGroup) _then) = _$FamilySosRecipientGroupCopyWithImpl;
@useResult
$Res call({
 String circleId, String name, String? themeColor, List<FamilySosRecipient> members
});




}
/// @nodoc
class _$FamilySosRecipientGroupCopyWithImpl<$Res>
    implements $FamilySosRecipientGroupCopyWith<$Res> {
  _$FamilySosRecipientGroupCopyWithImpl(this._self, this._then);

  final FamilySosRecipientGroup _self;
  final $Res Function(FamilySosRecipientGroup) _then;

/// Create a copy of FamilySosRecipientGroup
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? circleId = null,Object? name = null,Object? themeColor = freezed,Object? members = null,}) {
  return _then(_self.copyWith(
circleId: null == circleId ? _self.circleId : circleId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,themeColor: freezed == themeColor ? _self.themeColor : themeColor // ignore: cast_nullable_to_non_nullable
as String?,members: null == members ? _self.members : members // ignore: cast_nullable_to_non_nullable
as List<FamilySosRecipient>,
  ));
}

}


/// Adds pattern-matching-related methods to [FamilySosRecipientGroup].
extension FamilySosRecipientGroupPatterns on FamilySosRecipientGroup {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FamilySosRecipientGroup value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FamilySosRecipientGroup() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FamilySosRecipientGroup value)  $default,){
final _that = this;
switch (_that) {
case _FamilySosRecipientGroup():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FamilySosRecipientGroup value)?  $default,){
final _that = this;
switch (_that) {
case _FamilySosRecipientGroup() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String circleId,  String name,  String? themeColor,  List<FamilySosRecipient> members)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FamilySosRecipientGroup() when $default != null:
return $default(_that.circleId,_that.name,_that.themeColor,_that.members);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String circleId,  String name,  String? themeColor,  List<FamilySosRecipient> members)  $default,) {final _that = this;
switch (_that) {
case _FamilySosRecipientGroup():
return $default(_that.circleId,_that.name,_that.themeColor,_that.members);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String circleId,  String name,  String? themeColor,  List<FamilySosRecipient> members)?  $default,) {final _that = this;
switch (_that) {
case _FamilySosRecipientGroup() when $default != null:
return $default(_that.circleId,_that.name,_that.themeColor,_that.members);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FamilySosRecipientGroup implements FamilySosRecipientGroup {
  const _FamilySosRecipientGroup({required this.circleId, required this.name, this.themeColor, final  List<FamilySosRecipient> members = const <FamilySosRecipient>[]}): _members = members;
  factory _FamilySosRecipientGroup.fromJson(Map<String, dynamic> json) => _$FamilySosRecipientGroupFromJson(json);

@override final  String circleId;
@override final  String name;
@override final  String? themeColor;
 final  List<FamilySosRecipient> _members;
@override@JsonKey() List<FamilySosRecipient> get members {
  if (_members is EqualUnmodifiableListView) return _members;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_members);
}


/// Create a copy of FamilySosRecipientGroup
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FamilySosRecipientGroupCopyWith<_FamilySosRecipientGroup> get copyWith => __$FamilySosRecipientGroupCopyWithImpl<_FamilySosRecipientGroup>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FamilySosRecipientGroupToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FamilySosRecipientGroup&&(identical(other.circleId, circleId) || other.circleId == circleId)&&(identical(other.name, name) || other.name == name)&&(identical(other.themeColor, themeColor) || other.themeColor == themeColor)&&const DeepCollectionEquality().equals(other._members, _members));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,circleId,name,themeColor,const DeepCollectionEquality().hash(_members));

@override
String toString() {
  return 'FamilySosRecipientGroup(circleId: $circleId, name: $name, themeColor: $themeColor, members: $members)';
}


}

/// @nodoc
abstract mixin class _$FamilySosRecipientGroupCopyWith<$Res> implements $FamilySosRecipientGroupCopyWith<$Res> {
  factory _$FamilySosRecipientGroupCopyWith(_FamilySosRecipientGroup value, $Res Function(_FamilySosRecipientGroup) _then) = __$FamilySosRecipientGroupCopyWithImpl;
@override @useResult
$Res call({
 String circleId, String name, String? themeColor, List<FamilySosRecipient> members
});




}
/// @nodoc
class __$FamilySosRecipientGroupCopyWithImpl<$Res>
    implements _$FamilySosRecipientGroupCopyWith<$Res> {
  __$FamilySosRecipientGroupCopyWithImpl(this._self, this._then);

  final _FamilySosRecipientGroup _self;
  final $Res Function(_FamilySosRecipientGroup) _then;

/// Create a copy of FamilySosRecipientGroup
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? circleId = null,Object? name = null,Object? themeColor = freezed,Object? members = null,}) {
  return _then(_FamilySosRecipientGroup(
circleId: null == circleId ? _self.circleId : circleId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,themeColor: freezed == themeColor ? _self.themeColor : themeColor // ignore: cast_nullable_to_non_nullable
as String?,members: null == members ? _self._members : members // ignore: cast_nullable_to_non_nullable
as List<FamilySosRecipient>,
  ));
}


}


/// @nodoc
mixin _$FamilySosRecipient {

 String get memberId; String get name; String? get profilePictureUrl;@JsonKey(unknownEnumValue: FamilyRole.adult) FamilyRole get role;
/// Create a copy of FamilySosRecipient
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FamilySosRecipientCopyWith<FamilySosRecipient> get copyWith => _$FamilySosRecipientCopyWithImpl<FamilySosRecipient>(this as FamilySosRecipient, _$identity);

  /// Serializes this FamilySosRecipient to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FamilySosRecipient&&(identical(other.memberId, memberId) || other.memberId == memberId)&&(identical(other.name, name) || other.name == name)&&(identical(other.profilePictureUrl, profilePictureUrl) || other.profilePictureUrl == profilePictureUrl)&&(identical(other.role, role) || other.role == role));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,memberId,name,profilePictureUrl,role);

@override
String toString() {
  return 'FamilySosRecipient(memberId: $memberId, name: $name, profilePictureUrl: $profilePictureUrl, role: $role)';
}


}

/// @nodoc
abstract mixin class $FamilySosRecipientCopyWith<$Res>  {
  factory $FamilySosRecipientCopyWith(FamilySosRecipient value, $Res Function(FamilySosRecipient) _then) = _$FamilySosRecipientCopyWithImpl;
@useResult
$Res call({
 String memberId, String name, String? profilePictureUrl,@JsonKey(unknownEnumValue: FamilyRole.adult) FamilyRole role
});




}
/// @nodoc
class _$FamilySosRecipientCopyWithImpl<$Res>
    implements $FamilySosRecipientCopyWith<$Res> {
  _$FamilySosRecipientCopyWithImpl(this._self, this._then);

  final FamilySosRecipient _self;
  final $Res Function(FamilySosRecipient) _then;

/// Create a copy of FamilySosRecipient
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? memberId = null,Object? name = null,Object? profilePictureUrl = freezed,Object? role = null,}) {
  return _then(_self.copyWith(
memberId: null == memberId ? _self.memberId : memberId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,profilePictureUrl: freezed == profilePictureUrl ? _self.profilePictureUrl : profilePictureUrl // ignore: cast_nullable_to_non_nullable
as String?,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as FamilyRole,
  ));
}

}


/// Adds pattern-matching-related methods to [FamilySosRecipient].
extension FamilySosRecipientPatterns on FamilySosRecipient {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FamilySosRecipient value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FamilySosRecipient() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FamilySosRecipient value)  $default,){
final _that = this;
switch (_that) {
case _FamilySosRecipient():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FamilySosRecipient value)?  $default,){
final _that = this;
switch (_that) {
case _FamilySosRecipient() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String memberId,  String name,  String? profilePictureUrl, @JsonKey(unknownEnumValue: FamilyRole.adult)  FamilyRole role)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FamilySosRecipient() when $default != null:
return $default(_that.memberId,_that.name,_that.profilePictureUrl,_that.role);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String memberId,  String name,  String? profilePictureUrl, @JsonKey(unknownEnumValue: FamilyRole.adult)  FamilyRole role)  $default,) {final _that = this;
switch (_that) {
case _FamilySosRecipient():
return $default(_that.memberId,_that.name,_that.profilePictureUrl,_that.role);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String memberId,  String name,  String? profilePictureUrl, @JsonKey(unknownEnumValue: FamilyRole.adult)  FamilyRole role)?  $default,) {final _that = this;
switch (_that) {
case _FamilySosRecipient() when $default != null:
return $default(_that.memberId,_that.name,_that.profilePictureUrl,_that.role);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FamilySosRecipient implements FamilySosRecipient {
  const _FamilySosRecipient({required this.memberId, required this.name, this.profilePictureUrl, @JsonKey(unknownEnumValue: FamilyRole.adult) this.role = FamilyRole.adult});
  factory _FamilySosRecipient.fromJson(Map<String, dynamic> json) => _$FamilySosRecipientFromJson(json);

@override final  String memberId;
@override final  String name;
@override final  String? profilePictureUrl;
@override@JsonKey(unknownEnumValue: FamilyRole.adult) final  FamilyRole role;

/// Create a copy of FamilySosRecipient
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FamilySosRecipientCopyWith<_FamilySosRecipient> get copyWith => __$FamilySosRecipientCopyWithImpl<_FamilySosRecipient>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FamilySosRecipientToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FamilySosRecipient&&(identical(other.memberId, memberId) || other.memberId == memberId)&&(identical(other.name, name) || other.name == name)&&(identical(other.profilePictureUrl, profilePictureUrl) || other.profilePictureUrl == profilePictureUrl)&&(identical(other.role, role) || other.role == role));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,memberId,name,profilePictureUrl,role);

@override
String toString() {
  return 'FamilySosRecipient(memberId: $memberId, name: $name, profilePictureUrl: $profilePictureUrl, role: $role)';
}


}

/// @nodoc
abstract mixin class _$FamilySosRecipientCopyWith<$Res> implements $FamilySosRecipientCopyWith<$Res> {
  factory _$FamilySosRecipientCopyWith(_FamilySosRecipient value, $Res Function(_FamilySosRecipient) _then) = __$FamilySosRecipientCopyWithImpl;
@override @useResult
$Res call({
 String memberId, String name, String? profilePictureUrl,@JsonKey(unknownEnumValue: FamilyRole.adult) FamilyRole role
});




}
/// @nodoc
class __$FamilySosRecipientCopyWithImpl<$Res>
    implements _$FamilySosRecipientCopyWith<$Res> {
  __$FamilySosRecipientCopyWithImpl(this._self, this._then);

  final _FamilySosRecipient _self;
  final $Res Function(_FamilySosRecipient) _then;

/// Create a copy of FamilySosRecipient
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? memberId = null,Object? name = null,Object? profilePictureUrl = freezed,Object? role = null,}) {
  return _then(_FamilySosRecipient(
memberId: null == memberId ? _self.memberId : memberId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,profilePictureUrl: freezed == profilePictureUrl ? _self.profilePictureUrl : profilePictureUrl // ignore: cast_nullable_to_non_nullable
as String?,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as FamilyRole,
  ));
}


}


/// @nodoc
mixin _$FamilyTransferCandidates {

 String get circleId; int get memberCount; List<FamilyTransferCandidate> get candidates;
/// Create a copy of FamilyTransferCandidates
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FamilyTransferCandidatesCopyWith<FamilyTransferCandidates> get copyWith => _$FamilyTransferCandidatesCopyWithImpl<FamilyTransferCandidates>(this as FamilyTransferCandidates, _$identity);

  /// Serializes this FamilyTransferCandidates to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FamilyTransferCandidates&&(identical(other.circleId, circleId) || other.circleId == circleId)&&(identical(other.memberCount, memberCount) || other.memberCount == memberCount)&&const DeepCollectionEquality().equals(other.candidates, candidates));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,circleId,memberCount,const DeepCollectionEquality().hash(candidates));

@override
String toString() {
  return 'FamilyTransferCandidates(circleId: $circleId, memberCount: $memberCount, candidates: $candidates)';
}


}

/// @nodoc
abstract mixin class $FamilyTransferCandidatesCopyWith<$Res>  {
  factory $FamilyTransferCandidatesCopyWith(FamilyTransferCandidates value, $Res Function(FamilyTransferCandidates) _then) = _$FamilyTransferCandidatesCopyWithImpl;
@useResult
$Res call({
 String circleId, int memberCount, List<FamilyTransferCandidate> candidates
});




}
/// @nodoc
class _$FamilyTransferCandidatesCopyWithImpl<$Res>
    implements $FamilyTransferCandidatesCopyWith<$Res> {
  _$FamilyTransferCandidatesCopyWithImpl(this._self, this._then);

  final FamilyTransferCandidates _self;
  final $Res Function(FamilyTransferCandidates) _then;

/// Create a copy of FamilyTransferCandidates
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? circleId = null,Object? memberCount = null,Object? candidates = null,}) {
  return _then(_self.copyWith(
circleId: null == circleId ? _self.circleId : circleId // ignore: cast_nullable_to_non_nullable
as String,memberCount: null == memberCount ? _self.memberCount : memberCount // ignore: cast_nullable_to_non_nullable
as int,candidates: null == candidates ? _self.candidates : candidates // ignore: cast_nullable_to_non_nullable
as List<FamilyTransferCandidate>,
  ));
}

}


/// Adds pattern-matching-related methods to [FamilyTransferCandidates].
extension FamilyTransferCandidatesPatterns on FamilyTransferCandidates {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FamilyTransferCandidates value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FamilyTransferCandidates() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FamilyTransferCandidates value)  $default,){
final _that = this;
switch (_that) {
case _FamilyTransferCandidates():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FamilyTransferCandidates value)?  $default,){
final _that = this;
switch (_that) {
case _FamilyTransferCandidates() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String circleId,  int memberCount,  List<FamilyTransferCandidate> candidates)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FamilyTransferCandidates() when $default != null:
return $default(_that.circleId,_that.memberCount,_that.candidates);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String circleId,  int memberCount,  List<FamilyTransferCandidate> candidates)  $default,) {final _that = this;
switch (_that) {
case _FamilyTransferCandidates():
return $default(_that.circleId,_that.memberCount,_that.candidates);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String circleId,  int memberCount,  List<FamilyTransferCandidate> candidates)?  $default,) {final _that = this;
switch (_that) {
case _FamilyTransferCandidates() when $default != null:
return $default(_that.circleId,_that.memberCount,_that.candidates);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FamilyTransferCandidates implements FamilyTransferCandidates {
  const _FamilyTransferCandidates({required this.circleId, this.memberCount = 0, final  List<FamilyTransferCandidate> candidates = const <FamilyTransferCandidate>[]}): _candidates = candidates;
  factory _FamilyTransferCandidates.fromJson(Map<String, dynamic> json) => _$FamilyTransferCandidatesFromJson(json);

@override final  String circleId;
@override@JsonKey() final  int memberCount;
 final  List<FamilyTransferCandidate> _candidates;
@override@JsonKey() List<FamilyTransferCandidate> get candidates {
  if (_candidates is EqualUnmodifiableListView) return _candidates;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_candidates);
}


/// Create a copy of FamilyTransferCandidates
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FamilyTransferCandidatesCopyWith<_FamilyTransferCandidates> get copyWith => __$FamilyTransferCandidatesCopyWithImpl<_FamilyTransferCandidates>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FamilyTransferCandidatesToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FamilyTransferCandidates&&(identical(other.circleId, circleId) || other.circleId == circleId)&&(identical(other.memberCount, memberCount) || other.memberCount == memberCount)&&const DeepCollectionEquality().equals(other._candidates, _candidates));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,circleId,memberCount,const DeepCollectionEquality().hash(_candidates));

@override
String toString() {
  return 'FamilyTransferCandidates(circleId: $circleId, memberCount: $memberCount, candidates: $candidates)';
}


}

/// @nodoc
abstract mixin class _$FamilyTransferCandidatesCopyWith<$Res> implements $FamilyTransferCandidatesCopyWith<$Res> {
  factory _$FamilyTransferCandidatesCopyWith(_FamilyTransferCandidates value, $Res Function(_FamilyTransferCandidates) _then) = __$FamilyTransferCandidatesCopyWithImpl;
@override @useResult
$Res call({
 String circleId, int memberCount, List<FamilyTransferCandidate> candidates
});




}
/// @nodoc
class __$FamilyTransferCandidatesCopyWithImpl<$Res>
    implements _$FamilyTransferCandidatesCopyWith<$Res> {
  __$FamilyTransferCandidatesCopyWithImpl(this._self, this._then);

  final _FamilyTransferCandidates _self;
  final $Res Function(_FamilyTransferCandidates) _then;

/// Create a copy of FamilyTransferCandidates
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? circleId = null,Object? memberCount = null,Object? candidates = null,}) {
  return _then(_FamilyTransferCandidates(
circleId: null == circleId ? _self.circleId : circleId // ignore: cast_nullable_to_non_nullable
as String,memberCount: null == memberCount ? _self.memberCount : memberCount // ignore: cast_nullable_to_non_nullable
as int,candidates: null == candidates ? _self._candidates : candidates // ignore: cast_nullable_to_non_nullable
as List<FamilyTransferCandidate>,
  ));
}


}


/// @nodoc
mixin _$FamilyCircleSummary {

 String get circleId; String get name; String? get themeColor; String? get photoUrl;@JsonKey(unknownEnumValue: FamilyRole.adult) FamilyRole get role; String get myMemberId; int get memberCount;/// Members who hold a seat: everyone except guests, who join free.
 int get seatCount;/// True when the caller owns (pays for) this circle — its members
/// consume the caller's seats.
 bool get isOwned; DateTime? get joinedAt;
/// Create a copy of FamilyCircleSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FamilyCircleSummaryCopyWith<FamilyCircleSummary> get copyWith => _$FamilyCircleSummaryCopyWithImpl<FamilyCircleSummary>(this as FamilyCircleSummary, _$identity);

  /// Serializes this FamilyCircleSummary to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FamilyCircleSummary&&(identical(other.circleId, circleId) || other.circleId == circleId)&&(identical(other.name, name) || other.name == name)&&(identical(other.themeColor, themeColor) || other.themeColor == themeColor)&&(identical(other.photoUrl, photoUrl) || other.photoUrl == photoUrl)&&(identical(other.role, role) || other.role == role)&&(identical(other.myMemberId, myMemberId) || other.myMemberId == myMemberId)&&(identical(other.memberCount, memberCount) || other.memberCount == memberCount)&&(identical(other.seatCount, seatCount) || other.seatCount == seatCount)&&(identical(other.isOwned, isOwned) || other.isOwned == isOwned)&&(identical(other.joinedAt, joinedAt) || other.joinedAt == joinedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,circleId,name,themeColor,photoUrl,role,myMemberId,memberCount,seatCount,isOwned,joinedAt);

@override
String toString() {
  return 'FamilyCircleSummary(circleId: $circleId, name: $name, themeColor: $themeColor, photoUrl: $photoUrl, role: $role, myMemberId: $myMemberId, memberCount: $memberCount, seatCount: $seatCount, isOwned: $isOwned, joinedAt: $joinedAt)';
}


}

/// @nodoc
abstract mixin class $FamilyCircleSummaryCopyWith<$Res>  {
  factory $FamilyCircleSummaryCopyWith(FamilyCircleSummary value, $Res Function(FamilyCircleSummary) _then) = _$FamilyCircleSummaryCopyWithImpl;
@useResult
$Res call({
 String circleId, String name, String? themeColor, String? photoUrl,@JsonKey(unknownEnumValue: FamilyRole.adult) FamilyRole role, String myMemberId, int memberCount, int seatCount, bool isOwned, DateTime? joinedAt
});




}
/// @nodoc
class _$FamilyCircleSummaryCopyWithImpl<$Res>
    implements $FamilyCircleSummaryCopyWith<$Res> {
  _$FamilyCircleSummaryCopyWithImpl(this._self, this._then);

  final FamilyCircleSummary _self;
  final $Res Function(FamilyCircleSummary) _then;

/// Create a copy of FamilyCircleSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? circleId = null,Object? name = null,Object? themeColor = freezed,Object? photoUrl = freezed,Object? role = null,Object? myMemberId = null,Object? memberCount = null,Object? seatCount = null,Object? isOwned = null,Object? joinedAt = freezed,}) {
  return _then(_self.copyWith(
circleId: null == circleId ? _self.circleId : circleId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,themeColor: freezed == themeColor ? _self.themeColor : themeColor // ignore: cast_nullable_to_non_nullable
as String?,photoUrl: freezed == photoUrl ? _self.photoUrl : photoUrl // ignore: cast_nullable_to_non_nullable
as String?,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as FamilyRole,myMemberId: null == myMemberId ? _self.myMemberId : myMemberId // ignore: cast_nullable_to_non_nullable
as String,memberCount: null == memberCount ? _self.memberCount : memberCount // ignore: cast_nullable_to_non_nullable
as int,seatCount: null == seatCount ? _self.seatCount : seatCount // ignore: cast_nullable_to_non_nullable
as int,isOwned: null == isOwned ? _self.isOwned : isOwned // ignore: cast_nullable_to_non_nullable
as bool,joinedAt: freezed == joinedAt ? _self.joinedAt : joinedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [FamilyCircleSummary].
extension FamilyCircleSummaryPatterns on FamilyCircleSummary {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FamilyCircleSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FamilyCircleSummary() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FamilyCircleSummary value)  $default,){
final _that = this;
switch (_that) {
case _FamilyCircleSummary():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FamilyCircleSummary value)?  $default,){
final _that = this;
switch (_that) {
case _FamilyCircleSummary() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String circleId,  String name,  String? themeColor,  String? photoUrl, @JsonKey(unknownEnumValue: FamilyRole.adult)  FamilyRole role,  String myMemberId,  int memberCount,  int seatCount,  bool isOwned,  DateTime? joinedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FamilyCircleSummary() when $default != null:
return $default(_that.circleId,_that.name,_that.themeColor,_that.photoUrl,_that.role,_that.myMemberId,_that.memberCount,_that.seatCount,_that.isOwned,_that.joinedAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String circleId,  String name,  String? themeColor,  String? photoUrl, @JsonKey(unknownEnumValue: FamilyRole.adult)  FamilyRole role,  String myMemberId,  int memberCount,  int seatCount,  bool isOwned,  DateTime? joinedAt)  $default,) {final _that = this;
switch (_that) {
case _FamilyCircleSummary():
return $default(_that.circleId,_that.name,_that.themeColor,_that.photoUrl,_that.role,_that.myMemberId,_that.memberCount,_that.seatCount,_that.isOwned,_that.joinedAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String circleId,  String name,  String? themeColor,  String? photoUrl, @JsonKey(unknownEnumValue: FamilyRole.adult)  FamilyRole role,  String myMemberId,  int memberCount,  int seatCount,  bool isOwned,  DateTime? joinedAt)?  $default,) {final _that = this;
switch (_that) {
case _FamilyCircleSummary() when $default != null:
return $default(_that.circleId,_that.name,_that.themeColor,_that.photoUrl,_that.role,_that.myMemberId,_that.memberCount,_that.seatCount,_that.isOwned,_that.joinedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FamilyCircleSummary implements FamilyCircleSummary {
  const _FamilyCircleSummary({required this.circleId, required this.name, this.themeColor, this.photoUrl, @JsonKey(unknownEnumValue: FamilyRole.adult) this.role = FamilyRole.adult, required this.myMemberId, this.memberCount = 0, this.seatCount = 0, this.isOwned = false, this.joinedAt});
  factory _FamilyCircleSummary.fromJson(Map<String, dynamic> json) => _$FamilyCircleSummaryFromJson(json);

@override final  String circleId;
@override final  String name;
@override final  String? themeColor;
@override final  String? photoUrl;
@override@JsonKey(unknownEnumValue: FamilyRole.adult) final  FamilyRole role;
@override final  String myMemberId;
@override@JsonKey() final  int memberCount;
/// Members who hold a seat: everyone except guests, who join free.
@override@JsonKey() final  int seatCount;
/// True when the caller owns (pays for) this circle — its members
/// consume the caller's seats.
@override@JsonKey() final  bool isOwned;
@override final  DateTime? joinedAt;

/// Create a copy of FamilyCircleSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FamilyCircleSummaryCopyWith<_FamilyCircleSummary> get copyWith => __$FamilyCircleSummaryCopyWithImpl<_FamilyCircleSummary>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FamilyCircleSummaryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FamilyCircleSummary&&(identical(other.circleId, circleId) || other.circleId == circleId)&&(identical(other.name, name) || other.name == name)&&(identical(other.themeColor, themeColor) || other.themeColor == themeColor)&&(identical(other.photoUrl, photoUrl) || other.photoUrl == photoUrl)&&(identical(other.role, role) || other.role == role)&&(identical(other.myMemberId, myMemberId) || other.myMemberId == myMemberId)&&(identical(other.memberCount, memberCount) || other.memberCount == memberCount)&&(identical(other.seatCount, seatCount) || other.seatCount == seatCount)&&(identical(other.isOwned, isOwned) || other.isOwned == isOwned)&&(identical(other.joinedAt, joinedAt) || other.joinedAt == joinedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,circleId,name,themeColor,photoUrl,role,myMemberId,memberCount,seatCount,isOwned,joinedAt);

@override
String toString() {
  return 'FamilyCircleSummary(circleId: $circleId, name: $name, themeColor: $themeColor, photoUrl: $photoUrl, role: $role, myMemberId: $myMemberId, memberCount: $memberCount, seatCount: $seatCount, isOwned: $isOwned, joinedAt: $joinedAt)';
}


}

/// @nodoc
abstract mixin class _$FamilyCircleSummaryCopyWith<$Res> implements $FamilyCircleSummaryCopyWith<$Res> {
  factory _$FamilyCircleSummaryCopyWith(_FamilyCircleSummary value, $Res Function(_FamilyCircleSummary) _then) = __$FamilyCircleSummaryCopyWithImpl;
@override @useResult
$Res call({
 String circleId, String name, String? themeColor, String? photoUrl,@JsonKey(unknownEnumValue: FamilyRole.adult) FamilyRole role, String myMemberId, int memberCount, int seatCount, bool isOwned, DateTime? joinedAt
});




}
/// @nodoc
class __$FamilyCircleSummaryCopyWithImpl<$Res>
    implements _$FamilyCircleSummaryCopyWith<$Res> {
  __$FamilyCircleSummaryCopyWithImpl(this._self, this._then);

  final _FamilyCircleSummary _self;
  final $Res Function(_FamilyCircleSummary) _then;

/// Create a copy of FamilyCircleSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? circleId = null,Object? name = null,Object? themeColor = freezed,Object? photoUrl = freezed,Object? role = null,Object? myMemberId = null,Object? memberCount = null,Object? seatCount = null,Object? isOwned = null,Object? joinedAt = freezed,}) {
  return _then(_FamilyCircleSummary(
circleId: null == circleId ? _self.circleId : circleId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,themeColor: freezed == themeColor ? _self.themeColor : themeColor // ignore: cast_nullable_to_non_nullable
as String?,photoUrl: freezed == photoUrl ? _self.photoUrl : photoUrl // ignore: cast_nullable_to_non_nullable
as String?,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as FamilyRole,myMemberId: null == myMemberId ? _self.myMemberId : myMemberId // ignore: cast_nullable_to_non_nullable
as String,memberCount: null == memberCount ? _self.memberCount : memberCount // ignore: cast_nullable_to_non_nullable
as int,seatCount: null == seatCount ? _self.seatCount : seatCount // ignore: cast_nullable_to_non_nullable
as int,isOwned: null == isOwned ? _self.isOwned : isOwned // ignore: cast_nullable_to_non_nullable
as bool,joinedAt: freezed == joinedAt ? _self.joinedAt : joinedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$FamilyScheduledCheckIn {

 String get id; String get circleId; String get memberId;/// "HH:mm" 24h, Australia/Brisbane local time.
 String get timeOfDay;@JsonKey(unknownEnumValue: FamilyScheduledCheckInMode.prompted) FamilyScheduledCheckInMode get mode; DateTime? get lastFiredAt; FamilyMemberSnippet? get member; DateTime? get createdAt;
/// Create a copy of FamilyScheduledCheckIn
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FamilyScheduledCheckInCopyWith<FamilyScheduledCheckIn> get copyWith => _$FamilyScheduledCheckInCopyWithImpl<FamilyScheduledCheckIn>(this as FamilyScheduledCheckIn, _$identity);

  /// Serializes this FamilyScheduledCheckIn to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FamilyScheduledCheckIn&&(identical(other.id, id) || other.id == id)&&(identical(other.circleId, circleId) || other.circleId == circleId)&&(identical(other.memberId, memberId) || other.memberId == memberId)&&(identical(other.timeOfDay, timeOfDay) || other.timeOfDay == timeOfDay)&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.lastFiredAt, lastFiredAt) || other.lastFiredAt == lastFiredAt)&&(identical(other.member, member) || other.member == member)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,circleId,memberId,timeOfDay,mode,lastFiredAt,member,createdAt);

@override
String toString() {
  return 'FamilyScheduledCheckIn(id: $id, circleId: $circleId, memberId: $memberId, timeOfDay: $timeOfDay, mode: $mode, lastFiredAt: $lastFiredAt, member: $member, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $FamilyScheduledCheckInCopyWith<$Res>  {
  factory $FamilyScheduledCheckInCopyWith(FamilyScheduledCheckIn value, $Res Function(FamilyScheduledCheckIn) _then) = _$FamilyScheduledCheckInCopyWithImpl;
@useResult
$Res call({
 String id, String circleId, String memberId, String timeOfDay,@JsonKey(unknownEnumValue: FamilyScheduledCheckInMode.prompted) FamilyScheduledCheckInMode mode, DateTime? lastFiredAt, FamilyMemberSnippet? member, DateTime? createdAt
});


$FamilyMemberSnippetCopyWith<$Res>? get member;

}
/// @nodoc
class _$FamilyScheduledCheckInCopyWithImpl<$Res>
    implements $FamilyScheduledCheckInCopyWith<$Res> {
  _$FamilyScheduledCheckInCopyWithImpl(this._self, this._then);

  final FamilyScheduledCheckIn _self;
  final $Res Function(FamilyScheduledCheckIn) _then;

/// Create a copy of FamilyScheduledCheckIn
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? circleId = null,Object? memberId = null,Object? timeOfDay = null,Object? mode = null,Object? lastFiredAt = freezed,Object? member = freezed,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,circleId: null == circleId ? _self.circleId : circleId // ignore: cast_nullable_to_non_nullable
as String,memberId: null == memberId ? _self.memberId : memberId // ignore: cast_nullable_to_non_nullable
as String,timeOfDay: null == timeOfDay ? _self.timeOfDay : timeOfDay // ignore: cast_nullable_to_non_nullable
as String,mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as FamilyScheduledCheckInMode,lastFiredAt: freezed == lastFiredAt ? _self.lastFiredAt : lastFiredAt // ignore: cast_nullable_to_non_nullable
as DateTime?,member: freezed == member ? _self.member : member // ignore: cast_nullable_to_non_nullable
as FamilyMemberSnippet?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}
/// Create a copy of FamilyScheduledCheckIn
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FamilyMemberSnippetCopyWith<$Res>? get member {
    if (_self.member == null) {
    return null;
  }

  return $FamilyMemberSnippetCopyWith<$Res>(_self.member!, (value) {
    return _then(_self.copyWith(member: value));
  });
}
}


/// Adds pattern-matching-related methods to [FamilyScheduledCheckIn].
extension FamilyScheduledCheckInPatterns on FamilyScheduledCheckIn {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FamilyScheduledCheckIn value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FamilyScheduledCheckIn() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FamilyScheduledCheckIn value)  $default,){
final _that = this;
switch (_that) {
case _FamilyScheduledCheckIn():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FamilyScheduledCheckIn value)?  $default,){
final _that = this;
switch (_that) {
case _FamilyScheduledCheckIn() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String circleId,  String memberId,  String timeOfDay, @JsonKey(unknownEnumValue: FamilyScheduledCheckInMode.prompted)  FamilyScheduledCheckInMode mode,  DateTime? lastFiredAt,  FamilyMemberSnippet? member,  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FamilyScheduledCheckIn() when $default != null:
return $default(_that.id,_that.circleId,_that.memberId,_that.timeOfDay,_that.mode,_that.lastFiredAt,_that.member,_that.createdAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String circleId,  String memberId,  String timeOfDay, @JsonKey(unknownEnumValue: FamilyScheduledCheckInMode.prompted)  FamilyScheduledCheckInMode mode,  DateTime? lastFiredAt,  FamilyMemberSnippet? member,  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _FamilyScheduledCheckIn():
return $default(_that.id,_that.circleId,_that.memberId,_that.timeOfDay,_that.mode,_that.lastFiredAt,_that.member,_that.createdAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String circleId,  String memberId,  String timeOfDay, @JsonKey(unknownEnumValue: FamilyScheduledCheckInMode.prompted)  FamilyScheduledCheckInMode mode,  DateTime? lastFiredAt,  FamilyMemberSnippet? member,  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _FamilyScheduledCheckIn() when $default != null:
return $default(_that.id,_that.circleId,_that.memberId,_that.timeOfDay,_that.mode,_that.lastFiredAt,_that.member,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FamilyScheduledCheckIn implements FamilyScheduledCheckIn {
  const _FamilyScheduledCheckIn({required this.id, required this.circleId, required this.memberId, required this.timeOfDay, @JsonKey(unknownEnumValue: FamilyScheduledCheckInMode.prompted) this.mode = FamilyScheduledCheckInMode.prompted, this.lastFiredAt, this.member, this.createdAt});
  factory _FamilyScheduledCheckIn.fromJson(Map<String, dynamic> json) => _$FamilyScheduledCheckInFromJson(json);

@override final  String id;
@override final  String circleId;
@override final  String memberId;
/// "HH:mm" 24h, Australia/Brisbane local time.
@override final  String timeOfDay;
@override@JsonKey(unknownEnumValue: FamilyScheduledCheckInMode.prompted) final  FamilyScheduledCheckInMode mode;
@override final  DateTime? lastFiredAt;
@override final  FamilyMemberSnippet? member;
@override final  DateTime? createdAt;

/// Create a copy of FamilyScheduledCheckIn
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FamilyScheduledCheckInCopyWith<_FamilyScheduledCheckIn> get copyWith => __$FamilyScheduledCheckInCopyWithImpl<_FamilyScheduledCheckIn>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FamilyScheduledCheckInToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FamilyScheduledCheckIn&&(identical(other.id, id) || other.id == id)&&(identical(other.circleId, circleId) || other.circleId == circleId)&&(identical(other.memberId, memberId) || other.memberId == memberId)&&(identical(other.timeOfDay, timeOfDay) || other.timeOfDay == timeOfDay)&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.lastFiredAt, lastFiredAt) || other.lastFiredAt == lastFiredAt)&&(identical(other.member, member) || other.member == member)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,circleId,memberId,timeOfDay,mode,lastFiredAt,member,createdAt);

@override
String toString() {
  return 'FamilyScheduledCheckIn(id: $id, circleId: $circleId, memberId: $memberId, timeOfDay: $timeOfDay, mode: $mode, lastFiredAt: $lastFiredAt, member: $member, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$FamilyScheduledCheckInCopyWith<$Res> implements $FamilyScheduledCheckInCopyWith<$Res> {
  factory _$FamilyScheduledCheckInCopyWith(_FamilyScheduledCheckIn value, $Res Function(_FamilyScheduledCheckIn) _then) = __$FamilyScheduledCheckInCopyWithImpl;
@override @useResult
$Res call({
 String id, String circleId, String memberId, String timeOfDay,@JsonKey(unknownEnumValue: FamilyScheduledCheckInMode.prompted) FamilyScheduledCheckInMode mode, DateTime? lastFiredAt, FamilyMemberSnippet? member, DateTime? createdAt
});


@override $FamilyMemberSnippetCopyWith<$Res>? get member;

}
/// @nodoc
class __$FamilyScheduledCheckInCopyWithImpl<$Res>
    implements _$FamilyScheduledCheckInCopyWith<$Res> {
  __$FamilyScheduledCheckInCopyWithImpl(this._self, this._then);

  final _FamilyScheduledCheckIn _self;
  final $Res Function(_FamilyScheduledCheckIn) _then;

/// Create a copy of FamilyScheduledCheckIn
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? circleId = null,Object? memberId = null,Object? timeOfDay = null,Object? mode = null,Object? lastFiredAt = freezed,Object? member = freezed,Object? createdAt = freezed,}) {
  return _then(_FamilyScheduledCheckIn(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,circleId: null == circleId ? _self.circleId : circleId // ignore: cast_nullable_to_non_nullable
as String,memberId: null == memberId ? _self.memberId : memberId // ignore: cast_nullable_to_non_nullable
as String,timeOfDay: null == timeOfDay ? _self.timeOfDay : timeOfDay // ignore: cast_nullable_to_non_nullable
as String,mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as FamilyScheduledCheckInMode,lastFiredAt: freezed == lastFiredAt ? _self.lastFiredAt : lastFiredAt // ignore: cast_nullable_to_non_nullable
as DateTime?,member: freezed == member ? _self.member : member // ignore: cast_nullable_to_non_nullable
as FamilyMemberSnippet?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of FamilyScheduledCheckIn
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FamilyMemberSnippetCopyWith<$Res>? get member {
    if (_self.member == null) {
    return null;
  }

  return $FamilyMemberSnippetCopyWith<$Res>(_self.member!, (value) {
    return _then(_self.copyWith(member: value));
  });
}
}


/// @nodoc
mixin _$FamilyCheckInRequest {

 String get id; String get circleId; String get requestedById; String? get hazardId; String? get message; FamilyMemberSnippet? get requestedBy; List<FamilyCheckIn> get checkIns; DateTime? get createdAt;
/// Create a copy of FamilyCheckInRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FamilyCheckInRequestCopyWith<FamilyCheckInRequest> get copyWith => _$FamilyCheckInRequestCopyWithImpl<FamilyCheckInRequest>(this as FamilyCheckInRequest, _$identity);

  /// Serializes this FamilyCheckInRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FamilyCheckInRequest&&(identical(other.id, id) || other.id == id)&&(identical(other.circleId, circleId) || other.circleId == circleId)&&(identical(other.requestedById, requestedById) || other.requestedById == requestedById)&&(identical(other.hazardId, hazardId) || other.hazardId == hazardId)&&(identical(other.message, message) || other.message == message)&&(identical(other.requestedBy, requestedBy) || other.requestedBy == requestedBy)&&const DeepCollectionEquality().equals(other.checkIns, checkIns)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,circleId,requestedById,hazardId,message,requestedBy,const DeepCollectionEquality().hash(checkIns),createdAt);

@override
String toString() {
  return 'FamilyCheckInRequest(id: $id, circleId: $circleId, requestedById: $requestedById, hazardId: $hazardId, message: $message, requestedBy: $requestedBy, checkIns: $checkIns, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $FamilyCheckInRequestCopyWith<$Res>  {
  factory $FamilyCheckInRequestCopyWith(FamilyCheckInRequest value, $Res Function(FamilyCheckInRequest) _then) = _$FamilyCheckInRequestCopyWithImpl;
@useResult
$Res call({
 String id, String circleId, String requestedById, String? hazardId, String? message, FamilyMemberSnippet? requestedBy, List<FamilyCheckIn> checkIns, DateTime? createdAt
});


$FamilyMemberSnippetCopyWith<$Res>? get requestedBy;

}
/// @nodoc
class _$FamilyCheckInRequestCopyWithImpl<$Res>
    implements $FamilyCheckInRequestCopyWith<$Res> {
  _$FamilyCheckInRequestCopyWithImpl(this._self, this._then);

  final FamilyCheckInRequest _self;
  final $Res Function(FamilyCheckInRequest) _then;

/// Create a copy of FamilyCheckInRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? circleId = null,Object? requestedById = null,Object? hazardId = freezed,Object? message = freezed,Object? requestedBy = freezed,Object? checkIns = null,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,circleId: null == circleId ? _self.circleId : circleId // ignore: cast_nullable_to_non_nullable
as String,requestedById: null == requestedById ? _self.requestedById : requestedById // ignore: cast_nullable_to_non_nullable
as String,hazardId: freezed == hazardId ? _self.hazardId : hazardId // ignore: cast_nullable_to_non_nullable
as String?,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,requestedBy: freezed == requestedBy ? _self.requestedBy : requestedBy // ignore: cast_nullable_to_non_nullable
as FamilyMemberSnippet?,checkIns: null == checkIns ? _self.checkIns : checkIns // ignore: cast_nullable_to_non_nullable
as List<FamilyCheckIn>,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}
/// Create a copy of FamilyCheckInRequest
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FamilyMemberSnippetCopyWith<$Res>? get requestedBy {
    if (_self.requestedBy == null) {
    return null;
  }

  return $FamilyMemberSnippetCopyWith<$Res>(_self.requestedBy!, (value) {
    return _then(_self.copyWith(requestedBy: value));
  });
}
}


/// Adds pattern-matching-related methods to [FamilyCheckInRequest].
extension FamilyCheckInRequestPatterns on FamilyCheckInRequest {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FamilyCheckInRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FamilyCheckInRequest() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FamilyCheckInRequest value)  $default,){
final _that = this;
switch (_that) {
case _FamilyCheckInRequest():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FamilyCheckInRequest value)?  $default,){
final _that = this;
switch (_that) {
case _FamilyCheckInRequest() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String circleId,  String requestedById,  String? hazardId,  String? message,  FamilyMemberSnippet? requestedBy,  List<FamilyCheckIn> checkIns,  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FamilyCheckInRequest() when $default != null:
return $default(_that.id,_that.circleId,_that.requestedById,_that.hazardId,_that.message,_that.requestedBy,_that.checkIns,_that.createdAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String circleId,  String requestedById,  String? hazardId,  String? message,  FamilyMemberSnippet? requestedBy,  List<FamilyCheckIn> checkIns,  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _FamilyCheckInRequest():
return $default(_that.id,_that.circleId,_that.requestedById,_that.hazardId,_that.message,_that.requestedBy,_that.checkIns,_that.createdAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String circleId,  String requestedById,  String? hazardId,  String? message,  FamilyMemberSnippet? requestedBy,  List<FamilyCheckIn> checkIns,  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _FamilyCheckInRequest() when $default != null:
return $default(_that.id,_that.circleId,_that.requestedById,_that.hazardId,_that.message,_that.requestedBy,_that.checkIns,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FamilyCheckInRequest implements FamilyCheckInRequest {
  const _FamilyCheckInRequest({required this.id, required this.circleId, required this.requestedById, this.hazardId, this.message, this.requestedBy, final  List<FamilyCheckIn> checkIns = const <FamilyCheckIn>[], this.createdAt}): _checkIns = checkIns;
  factory _FamilyCheckInRequest.fromJson(Map<String, dynamic> json) => _$FamilyCheckInRequestFromJson(json);

@override final  String id;
@override final  String circleId;
@override final  String requestedById;
@override final  String? hazardId;
@override final  String? message;
@override final  FamilyMemberSnippet? requestedBy;
 final  List<FamilyCheckIn> _checkIns;
@override@JsonKey() List<FamilyCheckIn> get checkIns {
  if (_checkIns is EqualUnmodifiableListView) return _checkIns;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_checkIns);
}

@override final  DateTime? createdAt;

/// Create a copy of FamilyCheckInRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FamilyCheckInRequestCopyWith<_FamilyCheckInRequest> get copyWith => __$FamilyCheckInRequestCopyWithImpl<_FamilyCheckInRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FamilyCheckInRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FamilyCheckInRequest&&(identical(other.id, id) || other.id == id)&&(identical(other.circleId, circleId) || other.circleId == circleId)&&(identical(other.requestedById, requestedById) || other.requestedById == requestedById)&&(identical(other.hazardId, hazardId) || other.hazardId == hazardId)&&(identical(other.message, message) || other.message == message)&&(identical(other.requestedBy, requestedBy) || other.requestedBy == requestedBy)&&const DeepCollectionEquality().equals(other._checkIns, _checkIns)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,circleId,requestedById,hazardId,message,requestedBy,const DeepCollectionEquality().hash(_checkIns),createdAt);

@override
String toString() {
  return 'FamilyCheckInRequest(id: $id, circleId: $circleId, requestedById: $requestedById, hazardId: $hazardId, message: $message, requestedBy: $requestedBy, checkIns: $checkIns, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$FamilyCheckInRequestCopyWith<$Res> implements $FamilyCheckInRequestCopyWith<$Res> {
  factory _$FamilyCheckInRequestCopyWith(_FamilyCheckInRequest value, $Res Function(_FamilyCheckInRequest) _then) = __$FamilyCheckInRequestCopyWithImpl;
@override @useResult
$Res call({
 String id, String circleId, String requestedById, String? hazardId, String? message, FamilyMemberSnippet? requestedBy, List<FamilyCheckIn> checkIns, DateTime? createdAt
});


@override $FamilyMemberSnippetCopyWith<$Res>? get requestedBy;

}
/// @nodoc
class __$FamilyCheckInRequestCopyWithImpl<$Res>
    implements _$FamilyCheckInRequestCopyWith<$Res> {
  __$FamilyCheckInRequestCopyWithImpl(this._self, this._then);

  final _FamilyCheckInRequest _self;
  final $Res Function(_FamilyCheckInRequest) _then;

/// Create a copy of FamilyCheckInRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? circleId = null,Object? requestedById = null,Object? hazardId = freezed,Object? message = freezed,Object? requestedBy = freezed,Object? checkIns = null,Object? createdAt = freezed,}) {
  return _then(_FamilyCheckInRequest(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,circleId: null == circleId ? _self.circleId : circleId // ignore: cast_nullable_to_non_nullable
as String,requestedById: null == requestedById ? _self.requestedById : requestedById // ignore: cast_nullable_to_non_nullable
as String,hazardId: freezed == hazardId ? _self.hazardId : hazardId // ignore: cast_nullable_to_non_nullable
as String?,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,requestedBy: freezed == requestedBy ? _self.requestedBy : requestedBy // ignore: cast_nullable_to_non_nullable
as FamilyMemberSnippet?,checkIns: null == checkIns ? _self._checkIns : checkIns // ignore: cast_nullable_to_non_nullable
as List<FamilyCheckIn>,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of FamilyCheckInRequest
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FamilyMemberSnippetCopyWith<$Res>? get requestedBy {
    if (_self.requestedBy == null) {
    return null;
  }

  return $FamilyMemberSnippetCopyWith<$Res>(_self.requestedBy!, (value) {
    return _then(_self.copyWith(requestedBy: value));
  });
}
}


/// @nodoc
mixin _$FamilySosEvent {

 String get id; String get circleId; String get memberId;@JsonKey(unknownEnumValue: FamilySosStatus.active) FamilySosStatus get status; bool get isLive; double? get latitude; double? get longitude; String? get locationLabel; FamilyMemberSnippet? get member; List<FamilySosResponse> get responses; DateTime? get resolvedAt; DateTime? get createdAt;
/// Create a copy of FamilySosEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FamilySosEventCopyWith<FamilySosEvent> get copyWith => _$FamilySosEventCopyWithImpl<FamilySosEvent>(this as FamilySosEvent, _$identity);

  /// Serializes this FamilySosEvent to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FamilySosEvent&&(identical(other.id, id) || other.id == id)&&(identical(other.circleId, circleId) || other.circleId == circleId)&&(identical(other.memberId, memberId) || other.memberId == memberId)&&(identical(other.status, status) || other.status == status)&&(identical(other.isLive, isLive) || other.isLive == isLive)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.locationLabel, locationLabel) || other.locationLabel == locationLabel)&&(identical(other.member, member) || other.member == member)&&const DeepCollectionEquality().equals(other.responses, responses)&&(identical(other.resolvedAt, resolvedAt) || other.resolvedAt == resolvedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,circleId,memberId,status,isLive,latitude,longitude,locationLabel,member,const DeepCollectionEquality().hash(responses),resolvedAt,createdAt);

@override
String toString() {
  return 'FamilySosEvent(id: $id, circleId: $circleId, memberId: $memberId, status: $status, isLive: $isLive, latitude: $latitude, longitude: $longitude, locationLabel: $locationLabel, member: $member, responses: $responses, resolvedAt: $resolvedAt, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $FamilySosEventCopyWith<$Res>  {
  factory $FamilySosEventCopyWith(FamilySosEvent value, $Res Function(FamilySosEvent) _then) = _$FamilySosEventCopyWithImpl;
@useResult
$Res call({
 String id, String circleId, String memberId,@JsonKey(unknownEnumValue: FamilySosStatus.active) FamilySosStatus status, bool isLive, double? latitude, double? longitude, String? locationLabel, FamilyMemberSnippet? member, List<FamilySosResponse> responses, DateTime? resolvedAt, DateTime? createdAt
});


$FamilyMemberSnippetCopyWith<$Res>? get member;

}
/// @nodoc
class _$FamilySosEventCopyWithImpl<$Res>
    implements $FamilySosEventCopyWith<$Res> {
  _$FamilySosEventCopyWithImpl(this._self, this._then);

  final FamilySosEvent _self;
  final $Res Function(FamilySosEvent) _then;

/// Create a copy of FamilySosEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? circleId = null,Object? memberId = null,Object? status = null,Object? isLive = null,Object? latitude = freezed,Object? longitude = freezed,Object? locationLabel = freezed,Object? member = freezed,Object? responses = null,Object? resolvedAt = freezed,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,circleId: null == circleId ? _self.circleId : circleId // ignore: cast_nullable_to_non_nullable
as String,memberId: null == memberId ? _self.memberId : memberId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as FamilySosStatus,isLive: null == isLive ? _self.isLive : isLive // ignore: cast_nullable_to_non_nullable
as bool,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double?,locationLabel: freezed == locationLabel ? _self.locationLabel : locationLabel // ignore: cast_nullable_to_non_nullable
as String?,member: freezed == member ? _self.member : member // ignore: cast_nullable_to_non_nullable
as FamilyMemberSnippet?,responses: null == responses ? _self.responses : responses // ignore: cast_nullable_to_non_nullable
as List<FamilySosResponse>,resolvedAt: freezed == resolvedAt ? _self.resolvedAt : resolvedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}
/// Create a copy of FamilySosEvent
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FamilyMemberSnippetCopyWith<$Res>? get member {
    if (_self.member == null) {
    return null;
  }

  return $FamilyMemberSnippetCopyWith<$Res>(_self.member!, (value) {
    return _then(_self.copyWith(member: value));
  });
}
}


/// Adds pattern-matching-related methods to [FamilySosEvent].
extension FamilySosEventPatterns on FamilySosEvent {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FamilySosEvent value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FamilySosEvent() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FamilySosEvent value)  $default,){
final _that = this;
switch (_that) {
case _FamilySosEvent():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FamilySosEvent value)?  $default,){
final _that = this;
switch (_that) {
case _FamilySosEvent() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String circleId,  String memberId, @JsonKey(unknownEnumValue: FamilySosStatus.active)  FamilySosStatus status,  double? latitude,  double? longitude,  String? locationLabel,  FamilyMemberSnippet? member,  List<FamilySosResponse> responses,  DateTime? resolvedAt,  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FamilySosEvent() when $default != null:
return $default(_that.id,_that.circleId,_that.memberId,_that.status,_that.latitude,_that.longitude,_that.locationLabel,_that.member,_that.responses,_that.resolvedAt,_that.createdAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String circleId,  String memberId, @JsonKey(unknownEnumValue: FamilySosStatus.active)  FamilySosStatus status,  double? latitude,  double? longitude,  String? locationLabel,  FamilyMemberSnippet? member,  List<FamilySosResponse> responses,  DateTime? resolvedAt,  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _FamilySosEvent():
return $default(_that.id,_that.circleId,_that.memberId,_that.status,_that.latitude,_that.longitude,_that.locationLabel,_that.member,_that.responses,_that.resolvedAt,_that.createdAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String circleId,  String memberId, @JsonKey(unknownEnumValue: FamilySosStatus.active)  FamilySosStatus status,  double? latitude,  double? longitude,  String? locationLabel,  FamilyMemberSnippet? member,  List<FamilySosResponse> responses,  DateTime? resolvedAt,  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _FamilySosEvent() when $default != null:
return $default(_that.id,_that.circleId,_that.memberId,_that.status,_that.latitude,_that.longitude,_that.locationLabel,_that.member,_that.responses,_that.resolvedAt,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FamilySosEvent implements FamilySosEvent {
  const _FamilySosEvent({required this.id, required this.circleId, required this.memberId, @JsonKey(unknownEnumValue: FamilySosStatus.active) this.status = FamilySosStatus.active, this.isLive = true, this.latitude, this.longitude, this.locationLabel, this.member, final  List<FamilySosResponse> responses = const <FamilySosResponse>[], this.resolvedAt, this.createdAt}): _responses = responses;
  factory _FamilySosEvent.fromJson(Map<String, dynamic> json) => _$FamilySosEventFromJson(json);

@override final  String id;
@override final  String circleId;
@override final  String memberId;
@override@JsonKey(unknownEnumValue: FamilySosStatus.active) final  FamilySosStatus status;
@override@JsonKey() final  bool isLive;
@override final  double? latitude;
@override final  double? longitude;
@override final  String? locationLabel;
@override final  FamilyMemberSnippet? member;
 final  List<FamilySosResponse> _responses;
@override@JsonKey() List<FamilySosResponse> get responses {
  if (_responses is EqualUnmodifiableListView) return _responses;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_responses);
}

@override final  DateTime? resolvedAt;
@override final  DateTime? createdAt;

/// Create a copy of FamilySosEvent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FamilySosEventCopyWith<_FamilySosEvent> get copyWith => __$FamilySosEventCopyWithImpl<_FamilySosEvent>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FamilySosEventToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FamilySosEvent&&(identical(other.id, id) || other.id == id)&&(identical(other.circleId, circleId) || other.circleId == circleId)&&(identical(other.memberId, memberId) || other.memberId == memberId)&&(identical(other.status, status) || other.status == status)&&(identical(other.isLive, isLive) || other.isLive == isLive)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.locationLabel, locationLabel) || other.locationLabel == locationLabel)&&(identical(other.member, member) || other.member == member)&&const DeepCollectionEquality().equals(other._responses, _responses)&&(identical(other.resolvedAt, resolvedAt) || other.resolvedAt == resolvedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,circleId,memberId,status,isLive,latitude,longitude,locationLabel,member,const DeepCollectionEquality().hash(_responses),resolvedAt,createdAt);

@override
String toString() {
  return 'FamilySosEvent(id: $id, circleId: $circleId, memberId: $memberId, status: $status, isLive: $isLive, latitude: $latitude, longitude: $longitude, locationLabel: $locationLabel, member: $member, responses: $responses, resolvedAt: $resolvedAt, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$FamilySosEventCopyWith<$Res> implements $FamilySosEventCopyWith<$Res> {
  factory _$FamilySosEventCopyWith(_FamilySosEvent value, $Res Function(_FamilySosEvent) _then) = __$FamilySosEventCopyWithImpl;
@override @useResult
$Res call({
 String id, String circleId, String memberId,@JsonKey(unknownEnumValue: FamilySosStatus.active) FamilySosStatus status, bool isLive, double? latitude, double? longitude, String? locationLabel, FamilyMemberSnippet? member, List<FamilySosResponse> responses, DateTime? resolvedAt, DateTime? createdAt
});


@override $FamilyMemberSnippetCopyWith<$Res>? get member;

}
/// @nodoc
class __$FamilySosEventCopyWithImpl<$Res>
    implements _$FamilySosEventCopyWith<$Res> {
  __$FamilySosEventCopyWithImpl(this._self, this._then);

  final _FamilySosEvent _self;
  final $Res Function(_FamilySosEvent) _then;

/// Create a copy of FamilySosEvent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? circleId = null,Object? memberId = null,Object? status = null,Object? isLive = null,Object? latitude = freezed,Object? longitude = freezed,Object? locationLabel = freezed,Object? member = freezed,Object? responses = null,Object? resolvedAt = freezed,Object? createdAt = freezed,}) {
  return _then(_FamilySosEvent(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,circleId: null == circleId ? _self.circleId : circleId // ignore: cast_nullable_to_non_nullable
as String,memberId: null == memberId ? _self.memberId : memberId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as FamilySosStatus,isLive: null == isLive ? _self.isLive : isLive // ignore: cast_nullable_to_non_nullable
as bool,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double?,locationLabel: freezed == locationLabel ? _self.locationLabel : locationLabel // ignore: cast_nullable_to_non_nullable
as String?,member: freezed == member ? _self.member : member // ignore: cast_nullable_to_non_nullable
as FamilyMemberSnippet?,responses: null == responses ? _self._responses : responses // ignore: cast_nullable_to_non_nullable
as List<FamilySosResponse>,resolvedAt: freezed == resolvedAt ? _self.resolvedAt : resolvedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of FamilySosEvent
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FamilyMemberSnippetCopyWith<$Res>? get member {
    if (_self.member == null) {
    return null;
  }

  return $FamilyMemberSnippetCopyWith<$Res>(_self.member!, (value) {
    return _then(_self.copyWith(member: value));
  });
}
}


/// @nodoc
mixin _$FamilySosTrailPoint {

 double get latitude; double get longitude; bool get isMoving; DateTime? get createdAt;
/// Create a copy of FamilySosTrailPoint
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FamilySosTrailPointCopyWith<FamilySosTrailPoint> get copyWith => _$FamilySosTrailPointCopyWithImpl<FamilySosTrailPoint>(this as FamilySosTrailPoint, _$identity);

  /// Serializes this FamilySosTrailPoint to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FamilySosTrailPoint&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.isMoving, isMoving) || other.isMoving == isMoving)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,latitude,longitude,isMoving,createdAt);

@override
String toString() {
  return 'FamilySosTrailPoint(latitude: $latitude, longitude: $longitude, isMoving: $isMoving, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $FamilySosTrailPointCopyWith<$Res>  {
  factory $FamilySosTrailPointCopyWith(FamilySosTrailPoint value, $Res Function(FamilySosTrailPoint) _then) = _$FamilySosTrailPointCopyWithImpl;
@useResult
$Res call({
 double latitude, double longitude, bool isMoving, DateTime? createdAt
});




}
/// @nodoc
class _$FamilySosTrailPointCopyWithImpl<$Res>
    implements $FamilySosTrailPointCopyWith<$Res> {
  _$FamilySosTrailPointCopyWithImpl(this._self, this._then);

  final FamilySosTrailPoint _self;
  final $Res Function(FamilySosTrailPoint) _then;

/// Create a copy of FamilySosTrailPoint
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? latitude = null,Object? longitude = null,Object? isMoving = null,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
latitude: null == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double,longitude: null == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double,isMoving: null == isMoving ? _self.isMoving : isMoving // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [FamilySosTrailPoint].
extension FamilySosTrailPointPatterns on FamilySosTrailPoint {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FamilySosTrailPoint value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FamilySosTrailPoint() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FamilySosTrailPoint value)  $default,){
final _that = this;
switch (_that) {
case _FamilySosTrailPoint():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FamilySosTrailPoint value)?  $default,){
final _that = this;
switch (_that) {
case _FamilySosTrailPoint() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double latitude,  double longitude,  bool isMoving,  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FamilySosTrailPoint() when $default != null:
return $default(_that.latitude,_that.longitude,_that.isMoving,_that.createdAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double latitude,  double longitude,  bool isMoving,  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _FamilySosTrailPoint():
return $default(_that.latitude,_that.longitude,_that.isMoving,_that.createdAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double latitude,  double longitude,  bool isMoving,  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _FamilySosTrailPoint() when $default != null:
return $default(_that.latitude,_that.longitude,_that.isMoving,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FamilySosTrailPoint implements FamilySosTrailPoint {
  const _FamilySosTrailPoint({required this.latitude, required this.longitude, this.isMoving = false, this.createdAt});
  factory _FamilySosTrailPoint.fromJson(Map<String, dynamic> json) => _$FamilySosTrailPointFromJson(json);

@override final  double latitude;
@override final  double longitude;
@override@JsonKey() final  bool isMoving;
@override final  DateTime? createdAt;

/// Create a copy of FamilySosTrailPoint
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FamilySosTrailPointCopyWith<_FamilySosTrailPoint> get copyWith => __$FamilySosTrailPointCopyWithImpl<_FamilySosTrailPoint>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FamilySosTrailPointToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FamilySosTrailPoint&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.isMoving, isMoving) || other.isMoving == isMoving)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,latitude,longitude,isMoving,createdAt);

@override
String toString() {
  return 'FamilySosTrailPoint(latitude: $latitude, longitude: $longitude, isMoving: $isMoving, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$FamilySosTrailPointCopyWith<$Res> implements $FamilySosTrailPointCopyWith<$Res> {
  factory _$FamilySosTrailPointCopyWith(_FamilySosTrailPoint value, $Res Function(_FamilySosTrailPoint) _then) = __$FamilySosTrailPointCopyWithImpl;
@override @useResult
$Res call({
 double latitude, double longitude, bool isMoving, DateTime? createdAt
});




}
/// @nodoc
class __$FamilySosTrailPointCopyWithImpl<$Res>
    implements _$FamilySosTrailPointCopyWith<$Res> {
  __$FamilySosTrailPointCopyWithImpl(this._self, this._then);

  final _FamilySosTrailPoint _self;
  final $Res Function(_FamilySosTrailPoint) _then;

/// Create a copy of FamilySosTrailPoint
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? latitude = null,Object? longitude = null,Object? isMoving = null,Object? createdAt = freezed,}) {
  return _then(_FamilySosTrailPoint(
latitude: null == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double,longitude: null == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double,isMoving: null == isMoving ? _self.isMoving : isMoving // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$FamilySosTrail {

 String get sosEventId; List<FamilySosTrailPoint> get points;
/// Create a copy of FamilySosTrail
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FamilySosTrailCopyWith<FamilySosTrail> get copyWith => _$FamilySosTrailCopyWithImpl<FamilySosTrail>(this as FamilySosTrail, _$identity);

  /// Serializes this FamilySosTrail to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FamilySosTrail&&(identical(other.sosEventId, sosEventId) || other.sosEventId == sosEventId)&&const DeepCollectionEquality().equals(other.points, points));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,sosEventId,const DeepCollectionEquality().hash(points));

@override
String toString() {
  return 'FamilySosTrail(sosEventId: $sosEventId, points: $points)';
}


}

/// @nodoc
abstract mixin class $FamilySosTrailCopyWith<$Res>  {
  factory $FamilySosTrailCopyWith(FamilySosTrail value, $Res Function(FamilySosTrail) _then) = _$FamilySosTrailCopyWithImpl;
@useResult
$Res call({
 String sosEventId, List<FamilySosTrailPoint> points
});




}
/// @nodoc
class _$FamilySosTrailCopyWithImpl<$Res>
    implements $FamilySosTrailCopyWith<$Res> {
  _$FamilySosTrailCopyWithImpl(this._self, this._then);

  final FamilySosTrail _self;
  final $Res Function(FamilySosTrail) _then;

/// Create a copy of FamilySosTrail
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? sosEventId = null,Object? points = null,}) {
  return _then(_self.copyWith(
sosEventId: null == sosEventId ? _self.sosEventId : sosEventId // ignore: cast_nullable_to_non_nullable
as String,points: null == points ? _self.points : points // ignore: cast_nullable_to_non_nullable
as List<FamilySosTrailPoint>,
  ));
}

}


/// Adds pattern-matching-related methods to [FamilySosTrail].
extension FamilySosTrailPatterns on FamilySosTrail {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FamilySosTrail value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FamilySosTrail() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FamilySosTrail value)  $default,){
final _that = this;
switch (_that) {
case _FamilySosTrail():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FamilySosTrail value)?  $default,){
final _that = this;
switch (_that) {
case _FamilySosTrail() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String sosEventId,  List<FamilySosTrailPoint> points)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FamilySosTrail() when $default != null:
return $default(_that.sosEventId,_that.points);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String sosEventId,  List<FamilySosTrailPoint> points)  $default,) {final _that = this;
switch (_that) {
case _FamilySosTrail():
return $default(_that.sosEventId,_that.points);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String sosEventId,  List<FamilySosTrailPoint> points)?  $default,) {final _that = this;
switch (_that) {
case _FamilySosTrail() when $default != null:
return $default(_that.sosEventId,_that.points);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FamilySosTrail implements FamilySosTrail {
  const _FamilySosTrail({required this.sosEventId, final  List<FamilySosTrailPoint> points = const <FamilySosTrailPoint>[]}): _points = points;
  factory _FamilySosTrail.fromJson(Map<String, dynamic> json) => _$FamilySosTrailFromJson(json);

@override final  String sosEventId;
 final  List<FamilySosTrailPoint> _points;
@override@JsonKey() List<FamilySosTrailPoint> get points {
  if (_points is EqualUnmodifiableListView) return _points;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_points);
}


/// Create a copy of FamilySosTrail
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FamilySosTrailCopyWith<_FamilySosTrail> get copyWith => __$FamilySosTrailCopyWithImpl<_FamilySosTrail>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FamilySosTrailToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FamilySosTrail&&(identical(other.sosEventId, sosEventId) || other.sosEventId == sosEventId)&&const DeepCollectionEquality().equals(other._points, _points));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,sosEventId,const DeepCollectionEquality().hash(_points));

@override
String toString() {
  return 'FamilySosTrail(sosEventId: $sosEventId, points: $points)';
}


}

/// @nodoc
abstract mixin class _$FamilySosTrailCopyWith<$Res> implements $FamilySosTrailCopyWith<$Res> {
  factory _$FamilySosTrailCopyWith(_FamilySosTrail value, $Res Function(_FamilySosTrail) _then) = __$FamilySosTrailCopyWithImpl;
@override @useResult
$Res call({
 String sosEventId, List<FamilySosTrailPoint> points
});




}
/// @nodoc
class __$FamilySosTrailCopyWithImpl<$Res>
    implements _$FamilySosTrailCopyWith<$Res> {
  __$FamilySosTrailCopyWithImpl(this._self, this._then);

  final _FamilySosTrail _self;
  final $Res Function(_FamilySosTrail) _then;

/// Create a copy of FamilySosTrail
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? sosEventId = null,Object? points = null,}) {
  return _then(_FamilySosTrail(
sosEventId: null == sosEventId ? _self.sosEventId : sosEventId // ignore: cast_nullable_to_non_nullable
as String,points: null == points ? _self._points : points // ignore: cast_nullable_to_non_nullable
as List<FamilySosTrailPoint>,
  ));
}


}


/// @nodoc
mixin _$FamilyLocationRequest {

 String get id; String get circleId; String get requesterId; String get targetMemberId;@JsonKey(unknownEnumValue: FamilyLocationRequestStatus.pending) FamilyLocationRequestStatus get status; String? get message; FamilyMemberSnippet? get requester; DateTime? get respondedAt; DateTime? get expiresAt; DateTime? get createdAt;
/// Create a copy of FamilyLocationRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FamilyLocationRequestCopyWith<FamilyLocationRequest> get copyWith => _$FamilyLocationRequestCopyWithImpl<FamilyLocationRequest>(this as FamilyLocationRequest, _$identity);

  /// Serializes this FamilyLocationRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FamilyLocationRequest&&(identical(other.id, id) || other.id == id)&&(identical(other.circleId, circleId) || other.circleId == circleId)&&(identical(other.requesterId, requesterId) || other.requesterId == requesterId)&&(identical(other.targetMemberId, targetMemberId) || other.targetMemberId == targetMemberId)&&(identical(other.status, status) || other.status == status)&&(identical(other.message, message) || other.message == message)&&(identical(other.requester, requester) || other.requester == requester)&&(identical(other.respondedAt, respondedAt) || other.respondedAt == respondedAt)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,circleId,requesterId,targetMemberId,status,message,requester,respondedAt,expiresAt,createdAt);

@override
String toString() {
  return 'FamilyLocationRequest(id: $id, circleId: $circleId, requesterId: $requesterId, targetMemberId: $targetMemberId, status: $status, message: $message, requester: $requester, respondedAt: $respondedAt, expiresAt: $expiresAt, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $FamilyLocationRequestCopyWith<$Res>  {
  factory $FamilyLocationRequestCopyWith(FamilyLocationRequest value, $Res Function(FamilyLocationRequest) _then) = _$FamilyLocationRequestCopyWithImpl;
@useResult
$Res call({
 String id, String circleId, String requesterId, String targetMemberId,@JsonKey(unknownEnumValue: FamilyLocationRequestStatus.pending) FamilyLocationRequestStatus status, String? message, FamilyMemberSnippet? requester, DateTime? respondedAt, DateTime? expiresAt, DateTime? createdAt
});


$FamilyMemberSnippetCopyWith<$Res>? get requester;

}
/// @nodoc
class _$FamilyLocationRequestCopyWithImpl<$Res>
    implements $FamilyLocationRequestCopyWith<$Res> {
  _$FamilyLocationRequestCopyWithImpl(this._self, this._then);

  final FamilyLocationRequest _self;
  final $Res Function(FamilyLocationRequest) _then;

/// Create a copy of FamilyLocationRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? circleId = null,Object? requesterId = null,Object? targetMemberId = null,Object? status = null,Object? message = freezed,Object? requester = freezed,Object? respondedAt = freezed,Object? expiresAt = freezed,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,circleId: null == circleId ? _self.circleId : circleId // ignore: cast_nullable_to_non_nullable
as String,requesterId: null == requesterId ? _self.requesterId : requesterId // ignore: cast_nullable_to_non_nullable
as String,targetMemberId: null == targetMemberId ? _self.targetMemberId : targetMemberId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as FamilyLocationRequestStatus,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,requester: freezed == requester ? _self.requester : requester // ignore: cast_nullable_to_non_nullable
as FamilyMemberSnippet?,respondedAt: freezed == respondedAt ? _self.respondedAt : respondedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}
/// Create a copy of FamilyLocationRequest
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FamilyMemberSnippetCopyWith<$Res>? get requester {
    if (_self.requester == null) {
    return null;
  }

  return $FamilyMemberSnippetCopyWith<$Res>(_self.requester!, (value) {
    return _then(_self.copyWith(requester: value));
  });
}
}


/// Adds pattern-matching-related methods to [FamilyLocationRequest].
extension FamilyLocationRequestPatterns on FamilyLocationRequest {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FamilyLocationRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FamilyLocationRequest() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FamilyLocationRequest value)  $default,){
final _that = this;
switch (_that) {
case _FamilyLocationRequest():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FamilyLocationRequest value)?  $default,){
final _that = this;
switch (_that) {
case _FamilyLocationRequest() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String circleId,  String requesterId,  String targetMemberId, @JsonKey(unknownEnumValue: FamilyLocationRequestStatus.pending)  FamilyLocationRequestStatus status,  String? message,  FamilyMemberSnippet? requester,  DateTime? respondedAt,  DateTime? expiresAt,  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FamilyLocationRequest() when $default != null:
return $default(_that.id,_that.circleId,_that.requesterId,_that.targetMemberId,_that.status,_that.message,_that.requester,_that.respondedAt,_that.expiresAt,_that.createdAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String circleId,  String requesterId,  String targetMemberId, @JsonKey(unknownEnumValue: FamilyLocationRequestStatus.pending)  FamilyLocationRequestStatus status,  String? message,  FamilyMemberSnippet? requester,  DateTime? respondedAt,  DateTime? expiresAt,  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _FamilyLocationRequest():
return $default(_that.id,_that.circleId,_that.requesterId,_that.targetMemberId,_that.status,_that.message,_that.requester,_that.respondedAt,_that.expiresAt,_that.createdAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String circleId,  String requesterId,  String targetMemberId, @JsonKey(unknownEnumValue: FamilyLocationRequestStatus.pending)  FamilyLocationRequestStatus status,  String? message,  FamilyMemberSnippet? requester,  DateTime? respondedAt,  DateTime? expiresAt,  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _FamilyLocationRequest() when $default != null:
return $default(_that.id,_that.circleId,_that.requesterId,_that.targetMemberId,_that.status,_that.message,_that.requester,_that.respondedAt,_that.expiresAt,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FamilyLocationRequest implements FamilyLocationRequest {
  const _FamilyLocationRequest({required this.id, required this.circleId, required this.requesterId, required this.targetMemberId, @JsonKey(unknownEnumValue: FamilyLocationRequestStatus.pending) this.status = FamilyLocationRequestStatus.pending, this.message, this.requester, this.respondedAt, this.expiresAt, this.createdAt});
  factory _FamilyLocationRequest.fromJson(Map<String, dynamic> json) => _$FamilyLocationRequestFromJson(json);

@override final  String id;
@override final  String circleId;
@override final  String requesterId;
@override final  String targetMemberId;
@override@JsonKey(unknownEnumValue: FamilyLocationRequestStatus.pending) final  FamilyLocationRequestStatus status;
@override final  String? message;
@override final  FamilyMemberSnippet? requester;
@override final  DateTime? respondedAt;
@override final  DateTime? expiresAt;
@override final  DateTime? createdAt;

/// Create a copy of FamilyLocationRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FamilyLocationRequestCopyWith<_FamilyLocationRequest> get copyWith => __$FamilyLocationRequestCopyWithImpl<_FamilyLocationRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FamilyLocationRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FamilyLocationRequest&&(identical(other.id, id) || other.id == id)&&(identical(other.circleId, circleId) || other.circleId == circleId)&&(identical(other.requesterId, requesterId) || other.requesterId == requesterId)&&(identical(other.targetMemberId, targetMemberId) || other.targetMemberId == targetMemberId)&&(identical(other.status, status) || other.status == status)&&(identical(other.message, message) || other.message == message)&&(identical(other.requester, requester) || other.requester == requester)&&(identical(other.respondedAt, respondedAt) || other.respondedAt == respondedAt)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,circleId,requesterId,targetMemberId,status,message,requester,respondedAt,expiresAt,createdAt);

@override
String toString() {
  return 'FamilyLocationRequest(id: $id, circleId: $circleId, requesterId: $requesterId, targetMemberId: $targetMemberId, status: $status, message: $message, requester: $requester, respondedAt: $respondedAt, expiresAt: $expiresAt, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$FamilyLocationRequestCopyWith<$Res> implements $FamilyLocationRequestCopyWith<$Res> {
  factory _$FamilyLocationRequestCopyWith(_FamilyLocationRequest value, $Res Function(_FamilyLocationRequest) _then) = __$FamilyLocationRequestCopyWithImpl;
@override @useResult
$Res call({
 String id, String circleId, String requesterId, String targetMemberId,@JsonKey(unknownEnumValue: FamilyLocationRequestStatus.pending) FamilyLocationRequestStatus status, String? message, FamilyMemberSnippet? requester, DateTime? respondedAt, DateTime? expiresAt, DateTime? createdAt
});


@override $FamilyMemberSnippetCopyWith<$Res>? get requester;

}
/// @nodoc
class __$FamilyLocationRequestCopyWithImpl<$Res>
    implements _$FamilyLocationRequestCopyWith<$Res> {
  __$FamilyLocationRequestCopyWithImpl(this._self, this._then);

  final _FamilyLocationRequest _self;
  final $Res Function(_FamilyLocationRequest) _then;

/// Create a copy of FamilyLocationRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? circleId = null,Object? requesterId = null,Object? targetMemberId = null,Object? status = null,Object? message = freezed,Object? requester = freezed,Object? respondedAt = freezed,Object? expiresAt = freezed,Object? createdAt = freezed,}) {
  return _then(_FamilyLocationRequest(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,circleId: null == circleId ? _self.circleId : circleId // ignore: cast_nullable_to_non_nullable
as String,requesterId: null == requesterId ? _self.requesterId : requesterId // ignore: cast_nullable_to_non_nullable
as String,targetMemberId: null == targetMemberId ? _self.targetMemberId : targetMemberId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as FamilyLocationRequestStatus,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,requester: freezed == requester ? _self.requester : requester // ignore: cast_nullable_to_non_nullable
as FamilyMemberSnippet?,respondedAt: freezed == respondedAt ? _self.respondedAt : respondedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of FamilyLocationRequest
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FamilyMemberSnippetCopyWith<$Res>? get requester {
    if (_self.requester == null) {
    return null;
  }

  return $FamilyMemberSnippetCopyWith<$Res>(_self.requester!, (value) {
    return _then(_self.copyWith(requester: value));
  });
}
}


/// @nodoc
mixin _$FamilySosResponse {

 String get id; String get sosEventId; String get memberId;@JsonKey(unknownEnumValue: FamilySosResponseType.seen) FamilySosResponseType get type; FamilyMemberSnippet? get member; DateTime? get createdAt;
/// Create a copy of FamilySosResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FamilySosResponseCopyWith<FamilySosResponse> get copyWith => _$FamilySosResponseCopyWithImpl<FamilySosResponse>(this as FamilySosResponse, _$identity);

  /// Serializes this FamilySosResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FamilySosResponse&&(identical(other.id, id) || other.id == id)&&(identical(other.sosEventId, sosEventId) || other.sosEventId == sosEventId)&&(identical(other.memberId, memberId) || other.memberId == memberId)&&(identical(other.type, type) || other.type == type)&&(identical(other.member, member) || other.member == member)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,sosEventId,memberId,type,member,createdAt);

@override
String toString() {
  return 'FamilySosResponse(id: $id, sosEventId: $sosEventId, memberId: $memberId, type: $type, member: $member, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $FamilySosResponseCopyWith<$Res>  {
  factory $FamilySosResponseCopyWith(FamilySosResponse value, $Res Function(FamilySosResponse) _then) = _$FamilySosResponseCopyWithImpl;
@useResult
$Res call({
 String id, String sosEventId, String memberId,@JsonKey(unknownEnumValue: FamilySosResponseType.seen) FamilySosResponseType type, FamilyMemberSnippet? member, DateTime? createdAt
});


$FamilyMemberSnippetCopyWith<$Res>? get member;

}
/// @nodoc
class _$FamilySosResponseCopyWithImpl<$Res>
    implements $FamilySosResponseCopyWith<$Res> {
  _$FamilySosResponseCopyWithImpl(this._self, this._then);

  final FamilySosResponse _self;
  final $Res Function(FamilySosResponse) _then;

/// Create a copy of FamilySosResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? sosEventId = null,Object? memberId = null,Object? type = null,Object? member = freezed,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,sosEventId: null == sosEventId ? _self.sosEventId : sosEventId // ignore: cast_nullable_to_non_nullable
as String,memberId: null == memberId ? _self.memberId : memberId // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as FamilySosResponseType,member: freezed == member ? _self.member : member // ignore: cast_nullable_to_non_nullable
as FamilyMemberSnippet?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}
/// Create a copy of FamilySosResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FamilyMemberSnippetCopyWith<$Res>? get member {
    if (_self.member == null) {
    return null;
  }

  return $FamilyMemberSnippetCopyWith<$Res>(_self.member!, (value) {
    return _then(_self.copyWith(member: value));
  });
}
}


/// Adds pattern-matching-related methods to [FamilySosResponse].
extension FamilySosResponsePatterns on FamilySosResponse {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FamilySosResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FamilySosResponse() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FamilySosResponse value)  $default,){
final _that = this;
switch (_that) {
case _FamilySosResponse():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FamilySosResponse value)?  $default,){
final _that = this;
switch (_that) {
case _FamilySosResponse() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String sosEventId,  String memberId, @JsonKey(unknownEnumValue: FamilySosResponseType.seen)  FamilySosResponseType type,  FamilyMemberSnippet? member,  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FamilySosResponse() when $default != null:
return $default(_that.id,_that.sosEventId,_that.memberId,_that.type,_that.member,_that.createdAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String sosEventId,  String memberId, @JsonKey(unknownEnumValue: FamilySosResponseType.seen)  FamilySosResponseType type,  FamilyMemberSnippet? member,  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _FamilySosResponse():
return $default(_that.id,_that.sosEventId,_that.memberId,_that.type,_that.member,_that.createdAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String sosEventId,  String memberId, @JsonKey(unknownEnumValue: FamilySosResponseType.seen)  FamilySosResponseType type,  FamilyMemberSnippet? member,  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _FamilySosResponse() when $default != null:
return $default(_that.id,_that.sosEventId,_that.memberId,_that.type,_that.member,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FamilySosResponse implements FamilySosResponse {
  const _FamilySosResponse({required this.id, required this.sosEventId, required this.memberId, @JsonKey(unknownEnumValue: FamilySosResponseType.seen) this.type = FamilySosResponseType.seen, this.member, this.createdAt});
  factory _FamilySosResponse.fromJson(Map<String, dynamic> json) => _$FamilySosResponseFromJson(json);

@override final  String id;
@override final  String sosEventId;
@override final  String memberId;
@override@JsonKey(unknownEnumValue: FamilySosResponseType.seen) final  FamilySosResponseType type;
@override final  FamilyMemberSnippet? member;
@override final  DateTime? createdAt;

/// Create a copy of FamilySosResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FamilySosResponseCopyWith<_FamilySosResponse> get copyWith => __$FamilySosResponseCopyWithImpl<_FamilySosResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FamilySosResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FamilySosResponse&&(identical(other.id, id) || other.id == id)&&(identical(other.sosEventId, sosEventId) || other.sosEventId == sosEventId)&&(identical(other.memberId, memberId) || other.memberId == memberId)&&(identical(other.type, type) || other.type == type)&&(identical(other.member, member) || other.member == member)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,sosEventId,memberId,type,member,createdAt);

@override
String toString() {
  return 'FamilySosResponse(id: $id, sosEventId: $sosEventId, memberId: $memberId, type: $type, member: $member, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$FamilySosResponseCopyWith<$Res> implements $FamilySosResponseCopyWith<$Res> {
  factory _$FamilySosResponseCopyWith(_FamilySosResponse value, $Res Function(_FamilySosResponse) _then) = __$FamilySosResponseCopyWithImpl;
@override @useResult
$Res call({
 String id, String sosEventId, String memberId,@JsonKey(unknownEnumValue: FamilySosResponseType.seen) FamilySosResponseType type, FamilyMemberSnippet? member, DateTime? createdAt
});


@override $FamilyMemberSnippetCopyWith<$Res>? get member;

}
/// @nodoc
class __$FamilySosResponseCopyWithImpl<$Res>
    implements _$FamilySosResponseCopyWith<$Res> {
  __$FamilySosResponseCopyWithImpl(this._self, this._then);

  final _FamilySosResponse _self;
  final $Res Function(_FamilySosResponse) _then;

/// Create a copy of FamilySosResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? sosEventId = null,Object? memberId = null,Object? type = null,Object? member = freezed,Object? createdAt = freezed,}) {
  return _then(_FamilySosResponse(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,sosEventId: null == sosEventId ? _self.sosEventId : sosEventId // ignore: cast_nullable_to_non_nullable
as String,memberId: null == memberId ? _self.memberId : memberId // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as FamilySosResponseType,member: freezed == member ? _self.member : member // ignore: cast_nullable_to_non_nullable
as FamilyMemberSnippet?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of FamilySosResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FamilyMemberSnippetCopyWith<$Res>? get member {
    if (_self.member == null) {
    return null;
  }

  return $FamilyMemberSnippetCopyWith<$Res>(_self.member!, (value) {
    return _then(_self.copyWith(member: value));
  });
}
}


/// @nodoc
mixin _$FamilyJourneyRecipient {

 String get memberId; String get name; String? get profilePictureUrl;
/// Create a copy of FamilyJourneyRecipient
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FamilyJourneyRecipientCopyWith<FamilyJourneyRecipient> get copyWith => _$FamilyJourneyRecipientCopyWithImpl<FamilyJourneyRecipient>(this as FamilyJourneyRecipient, _$identity);

  /// Serializes this FamilyJourneyRecipient to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FamilyJourneyRecipient&&(identical(other.memberId, memberId) || other.memberId == memberId)&&(identical(other.name, name) || other.name == name)&&(identical(other.profilePictureUrl, profilePictureUrl) || other.profilePictureUrl == profilePictureUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,memberId,name,profilePictureUrl);

@override
String toString() {
  return 'FamilyJourneyRecipient(memberId: $memberId, name: $name, profilePictureUrl: $profilePictureUrl)';
}


}

/// @nodoc
abstract mixin class $FamilyJourneyRecipientCopyWith<$Res>  {
  factory $FamilyJourneyRecipientCopyWith(FamilyJourneyRecipient value, $Res Function(FamilyJourneyRecipient) _then) = _$FamilyJourneyRecipientCopyWithImpl;
@useResult
$Res call({
 String memberId, String name, String? profilePictureUrl
});




}
/// @nodoc
class _$FamilyJourneyRecipientCopyWithImpl<$Res>
    implements $FamilyJourneyRecipientCopyWith<$Res> {
  _$FamilyJourneyRecipientCopyWithImpl(this._self, this._then);

  final FamilyJourneyRecipient _self;
  final $Res Function(FamilyJourneyRecipient) _then;

/// Create a copy of FamilyJourneyRecipient
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? memberId = null,Object? name = null,Object? profilePictureUrl = freezed,}) {
  return _then(_self.copyWith(
memberId: null == memberId ? _self.memberId : memberId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,profilePictureUrl: freezed == profilePictureUrl ? _self.profilePictureUrl : profilePictureUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [FamilyJourneyRecipient].
extension FamilyJourneyRecipientPatterns on FamilyJourneyRecipient {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FamilyJourneyRecipient value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FamilyJourneyRecipient() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FamilyJourneyRecipient value)  $default,){
final _that = this;
switch (_that) {
case _FamilyJourneyRecipient():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FamilyJourneyRecipient value)?  $default,){
final _that = this;
switch (_that) {
case _FamilyJourneyRecipient() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String memberId,  String name,  String? profilePictureUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FamilyJourneyRecipient() when $default != null:
return $default(_that.memberId,_that.name,_that.profilePictureUrl);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String memberId,  String name,  String? profilePictureUrl)  $default,) {final _that = this;
switch (_that) {
case _FamilyJourneyRecipient():
return $default(_that.memberId,_that.name,_that.profilePictureUrl);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String memberId,  String name,  String? profilePictureUrl)?  $default,) {final _that = this;
switch (_that) {
case _FamilyJourneyRecipient() when $default != null:
return $default(_that.memberId,_that.name,_that.profilePictureUrl);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FamilyJourneyRecipient implements FamilyJourneyRecipient {
  const _FamilyJourneyRecipient({required this.memberId, this.name = 'Family member', this.profilePictureUrl});
  factory _FamilyJourneyRecipient.fromJson(Map<String, dynamic> json) => _$FamilyJourneyRecipientFromJson(json);

@override final  String memberId;
@override@JsonKey() final  String name;
@override final  String? profilePictureUrl;

/// Create a copy of FamilyJourneyRecipient
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FamilyJourneyRecipientCopyWith<_FamilyJourneyRecipient> get copyWith => __$FamilyJourneyRecipientCopyWithImpl<_FamilyJourneyRecipient>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FamilyJourneyRecipientToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FamilyJourneyRecipient&&(identical(other.memberId, memberId) || other.memberId == memberId)&&(identical(other.name, name) || other.name == name)&&(identical(other.profilePictureUrl, profilePictureUrl) || other.profilePictureUrl == profilePictureUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,memberId,name,profilePictureUrl);

@override
String toString() {
  return 'FamilyJourneyRecipient(memberId: $memberId, name: $name, profilePictureUrl: $profilePictureUrl)';
}


}

/// @nodoc
abstract mixin class _$FamilyJourneyRecipientCopyWith<$Res> implements $FamilyJourneyRecipientCopyWith<$Res> {
  factory _$FamilyJourneyRecipientCopyWith(_FamilyJourneyRecipient value, $Res Function(_FamilyJourneyRecipient) _then) = __$FamilyJourneyRecipientCopyWithImpl;
@override @useResult
$Res call({
 String memberId, String name, String? profilePictureUrl
});




}
/// @nodoc
class __$FamilyJourneyRecipientCopyWithImpl<$Res>
    implements _$FamilyJourneyRecipientCopyWith<$Res> {
  __$FamilyJourneyRecipientCopyWithImpl(this._self, this._then);

  final _FamilyJourneyRecipient _self;
  final $Res Function(_FamilyJourneyRecipient) _then;

/// Create a copy of FamilyJourneyRecipient
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? memberId = null,Object? name = null,Object? profilePictureUrl = freezed,}) {
  return _then(_FamilyJourneyRecipient(
memberId: null == memberId ? _self.memberId : memberId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,profilePictureUrl: freezed == profilePictureUrl ? _self.profilePictureUrl : profilePictureUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$FamilyJourney {

 String get id; String get circleId; String get memberId; String get memberName; String get status; bool get isLive; DateTime get endsAt; DateTime? get endedAt; int get grantedMinutes; bool get canExtend; int get maxTotalMinutes; double? get latitude; double? get longitude; String? get locationLabel; List<FamilyJourneyRecipient> get recipients; DateTime? get createdAt;
/// Create a copy of FamilyJourney
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FamilyJourneyCopyWith<FamilyJourney> get copyWith => _$FamilyJourneyCopyWithImpl<FamilyJourney>(this as FamilyJourney, _$identity);

  /// Serializes this FamilyJourney to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FamilyJourney&&(identical(other.id, id) || other.id == id)&&(identical(other.circleId, circleId) || other.circleId == circleId)&&(identical(other.memberId, memberId) || other.memberId == memberId)&&(identical(other.memberName, memberName) || other.memberName == memberName)&&(identical(other.status, status) || other.status == status)&&(identical(other.isLive, isLive) || other.isLive == isLive)&&(identical(other.endsAt, endsAt) || other.endsAt == endsAt)&&(identical(other.endedAt, endedAt) || other.endedAt == endedAt)&&(identical(other.grantedMinutes, grantedMinutes) || other.grantedMinutes == grantedMinutes)&&(identical(other.canExtend, canExtend) || other.canExtend == canExtend)&&(identical(other.maxTotalMinutes, maxTotalMinutes) || other.maxTotalMinutes == maxTotalMinutes)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.locationLabel, locationLabel) || other.locationLabel == locationLabel)&&const DeepCollectionEquality().equals(other.recipients, recipients)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,circleId,memberId,memberName,status,isLive,endsAt,endedAt,grantedMinutes,canExtend,maxTotalMinutes,latitude,longitude,locationLabel,const DeepCollectionEquality().hash(recipients),createdAt);

@override
String toString() {
  return 'FamilyJourney(id: $id, circleId: $circleId, memberId: $memberId, memberName: $memberName, status: $status, isLive: $isLive, endsAt: $endsAt, endedAt: $endedAt, grantedMinutes: $grantedMinutes, canExtend: $canExtend, maxTotalMinutes: $maxTotalMinutes, latitude: $latitude, longitude: $longitude, locationLabel: $locationLabel, recipients: $recipients, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $FamilyJourneyCopyWith<$Res>  {
  factory $FamilyJourneyCopyWith(FamilyJourney value, $Res Function(FamilyJourney) _then) = _$FamilyJourneyCopyWithImpl;
@useResult
$Res call({
 String id, String circleId, String memberId, String memberName, String status, bool isLive, DateTime endsAt, DateTime? endedAt, int grantedMinutes, bool canExtend, int maxTotalMinutes, double? latitude, double? longitude, String? locationLabel, List<FamilyJourneyRecipient> recipients, DateTime? createdAt
});




}
/// @nodoc
class _$FamilyJourneyCopyWithImpl<$Res>
    implements $FamilyJourneyCopyWith<$Res> {
  _$FamilyJourneyCopyWithImpl(this._self, this._then);

  final FamilyJourney _self;
  final $Res Function(FamilyJourney) _then;

/// Create a copy of FamilyJourney
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? circleId = null,Object? memberId = null,Object? memberName = null,Object? status = null,Object? isLive = null,Object? endsAt = null,Object? endedAt = freezed,Object? grantedMinutes = null,Object? canExtend = null,Object? maxTotalMinutes = null,Object? latitude = freezed,Object? longitude = freezed,Object? locationLabel = freezed,Object? recipients = null,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,circleId: null == circleId ? _self.circleId : circleId // ignore: cast_nullable_to_non_nullable
as String,memberId: null == memberId ? _self.memberId : memberId // ignore: cast_nullable_to_non_nullable
as String,memberName: null == memberName ? _self.memberName : memberName // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,isLive: null == isLive ? _self.isLive : isLive // ignore: cast_nullable_to_non_nullable
as bool,endsAt: null == endsAt ? _self.endsAt : endsAt // ignore: cast_nullable_to_non_nullable
as DateTime,endedAt: freezed == endedAt ? _self.endedAt : endedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,grantedMinutes: null == grantedMinutes ? _self.grantedMinutes : grantedMinutes // ignore: cast_nullable_to_non_nullable
as int,canExtend: null == canExtend ? _self.canExtend : canExtend // ignore: cast_nullable_to_non_nullable
as bool,maxTotalMinutes: null == maxTotalMinutes ? _self.maxTotalMinutes : maxTotalMinutes // ignore: cast_nullable_to_non_nullable
as int,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double?,locationLabel: freezed == locationLabel ? _self.locationLabel : locationLabel // ignore: cast_nullable_to_non_nullable
as String?,recipients: null == recipients ? _self.recipients : recipients // ignore: cast_nullable_to_non_nullable
as List<FamilyJourneyRecipient>,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [FamilyJourney].
extension FamilyJourneyPatterns on FamilyJourney {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FamilyJourney value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FamilyJourney() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FamilyJourney value)  $default,){
final _that = this;
switch (_that) {
case _FamilyJourney():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FamilyJourney value)?  $default,){
final _that = this;
switch (_that) {
case _FamilyJourney() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String circleId,  String memberId,  String memberName,  String status,  bool isLive,  DateTime endsAt,  DateTime? endedAt,  int grantedMinutes,  bool canExtend,  int maxTotalMinutes,  double? latitude,  double? longitude,  String? locationLabel,  List<FamilyJourneyRecipient> recipients,  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FamilyJourney() when $default != null:
return $default(_that.id,_that.circleId,_that.memberId,_that.memberName,_that.status,_that.isLive,_that.endsAt,_that.endedAt,_that.grantedMinutes,_that.canExtend,_that.maxTotalMinutes,_that.latitude,_that.longitude,_that.locationLabel,_that.recipients,_that.createdAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String circleId,  String memberId,  String memberName,  String status,  bool isLive,  DateTime endsAt,  DateTime? endedAt,  int grantedMinutes,  bool canExtend,  int maxTotalMinutes,  double? latitude,  double? longitude,  String? locationLabel,  List<FamilyJourneyRecipient> recipients,  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _FamilyJourney():
return $default(_that.id,_that.circleId,_that.memberId,_that.memberName,_that.status,_that.isLive,_that.endsAt,_that.endedAt,_that.grantedMinutes,_that.canExtend,_that.maxTotalMinutes,_that.latitude,_that.longitude,_that.locationLabel,_that.recipients,_that.createdAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String circleId,  String memberId,  String memberName,  String status,  bool isLive,  DateTime endsAt,  DateTime? endedAt,  int grantedMinutes,  bool canExtend,  int maxTotalMinutes,  double? latitude,  double? longitude,  String? locationLabel,  List<FamilyJourneyRecipient> recipients,  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _FamilyJourney() when $default != null:
return $default(_that.id,_that.circleId,_that.memberId,_that.memberName,_that.status,_that.isLive,_that.endsAt,_that.endedAt,_that.grantedMinutes,_that.canExtend,_that.maxTotalMinutes,_that.latitude,_that.longitude,_that.locationLabel,_that.recipients,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FamilyJourney extends FamilyJourney {
  const _FamilyJourney({required this.id, required this.circleId, required this.memberId, this.memberName = 'Family member', this.status = 'active', this.isLive = false, required this.endsAt, this.endedAt, this.grantedMinutes = 0, this.canExtend = true, this.maxTotalMinutes = 240, this.latitude, this.longitude, this.locationLabel, final  List<FamilyJourneyRecipient> recipients = const <FamilyJourneyRecipient>[], this.createdAt}): _recipients = recipients,super._();
  factory _FamilyJourney.fromJson(Map<String, dynamic> json) => _$FamilyJourneyFromJson(json);

@override final  String id;
@override final  String circleId;
@override final  String memberId;
@override@JsonKey() final  String memberName;
@override@JsonKey() final  String status;
@override@JsonKey() final  bool isLive;
@override final  DateTime endsAt;
@override final  DateTime? endedAt;
@override@JsonKey() final  int grantedMinutes;
@override@JsonKey() final  bool canExtend;
@override@JsonKey() final  int maxTotalMinutes;
@override final  double? latitude;
@override final  double? longitude;
@override final  String? locationLabel;
 final  List<FamilyJourneyRecipient> _recipients;
@override@JsonKey() List<FamilyJourneyRecipient> get recipients {
  if (_recipients is EqualUnmodifiableListView) return _recipients;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_recipients);
}

@override final  DateTime? createdAt;

/// Create a copy of FamilyJourney
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FamilyJourneyCopyWith<_FamilyJourney> get copyWith => __$FamilyJourneyCopyWithImpl<_FamilyJourney>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FamilyJourneyToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FamilyJourney&&(identical(other.id, id) || other.id == id)&&(identical(other.circleId, circleId) || other.circleId == circleId)&&(identical(other.memberId, memberId) || other.memberId == memberId)&&(identical(other.memberName, memberName) || other.memberName == memberName)&&(identical(other.status, status) || other.status == status)&&(identical(other.isLive, isLive) || other.isLive == isLive)&&(identical(other.endsAt, endsAt) || other.endsAt == endsAt)&&(identical(other.endedAt, endedAt) || other.endedAt == endedAt)&&(identical(other.grantedMinutes, grantedMinutes) || other.grantedMinutes == grantedMinutes)&&(identical(other.canExtend, canExtend) || other.canExtend == canExtend)&&(identical(other.maxTotalMinutes, maxTotalMinutes) || other.maxTotalMinutes == maxTotalMinutes)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.locationLabel, locationLabel) || other.locationLabel == locationLabel)&&const DeepCollectionEquality().equals(other._recipients, _recipients)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,circleId,memberId,memberName,status,isLive,endsAt,endedAt,grantedMinutes,canExtend,maxTotalMinutes,latitude,longitude,locationLabel,const DeepCollectionEquality().hash(_recipients),createdAt);

@override
String toString() {
  return 'FamilyJourney(id: $id, circleId: $circleId, memberId: $memberId, memberName: $memberName, status: $status, isLive: $isLive, endsAt: $endsAt, endedAt: $endedAt, grantedMinutes: $grantedMinutes, canExtend: $canExtend, maxTotalMinutes: $maxTotalMinutes, latitude: $latitude, longitude: $longitude, locationLabel: $locationLabel, recipients: $recipients, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$FamilyJourneyCopyWith<$Res> implements $FamilyJourneyCopyWith<$Res> {
  factory _$FamilyJourneyCopyWith(_FamilyJourney value, $Res Function(_FamilyJourney) _then) = __$FamilyJourneyCopyWithImpl;
@override @useResult
$Res call({
 String id, String circleId, String memberId, String memberName, String status, bool isLive, DateTime endsAt, DateTime? endedAt, int grantedMinutes, bool canExtend, int maxTotalMinutes, double? latitude, double? longitude, String? locationLabel, List<FamilyJourneyRecipient> recipients, DateTime? createdAt
});




}
/// @nodoc
class __$FamilyJourneyCopyWithImpl<$Res>
    implements _$FamilyJourneyCopyWith<$Res> {
  __$FamilyJourneyCopyWithImpl(this._self, this._then);

  final _FamilyJourney _self;
  final $Res Function(_FamilyJourney) _then;

/// Create a copy of FamilyJourney
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? circleId = null,Object? memberId = null,Object? memberName = null,Object? status = null,Object? isLive = null,Object? endsAt = null,Object? endedAt = freezed,Object? grantedMinutes = null,Object? canExtend = null,Object? maxTotalMinutes = null,Object? latitude = freezed,Object? longitude = freezed,Object? locationLabel = freezed,Object? recipients = null,Object? createdAt = freezed,}) {
  return _then(_FamilyJourney(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,circleId: null == circleId ? _self.circleId : circleId // ignore: cast_nullable_to_non_nullable
as String,memberId: null == memberId ? _self.memberId : memberId // ignore: cast_nullable_to_non_nullable
as String,memberName: null == memberName ? _self.memberName : memberName // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,isLive: null == isLive ? _self.isLive : isLive // ignore: cast_nullable_to_non_nullable
as bool,endsAt: null == endsAt ? _self.endsAt : endsAt // ignore: cast_nullable_to_non_nullable
as DateTime,endedAt: freezed == endedAt ? _self.endedAt : endedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,grantedMinutes: null == grantedMinutes ? _self.grantedMinutes : grantedMinutes // ignore: cast_nullable_to_non_nullable
as int,canExtend: null == canExtend ? _self.canExtend : canExtend // ignore: cast_nullable_to_non_nullable
as bool,maxTotalMinutes: null == maxTotalMinutes ? _self.maxTotalMinutes : maxTotalMinutes // ignore: cast_nullable_to_non_nullable
as int,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double?,locationLabel: freezed == locationLabel ? _self.locationLabel : locationLabel // ignore: cast_nullable_to_non_nullable
as String?,recipients: null == recipients ? _self._recipients : recipients // ignore: cast_nullable_to_non_nullable
as List<FamilyJourneyRecipient>,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on

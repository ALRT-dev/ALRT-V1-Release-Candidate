// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'xp_summary_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$XpSummary {

 int get xpPoints; int get streakDays; bool get streakMultiplierActive; TrustTier? get trustTier; WeeklyQuest? get weeklyQuest; List<XpLedgerEvent> get recentEvents; List<SafetyBadge> get badges;
/// Create a copy of XpSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$XpSummaryCopyWith<XpSummary> get copyWith => _$XpSummaryCopyWithImpl<XpSummary>(this as XpSummary, _$identity);

  /// Serializes this XpSummary to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is XpSummary&&(identical(other.xpPoints, xpPoints) || other.xpPoints == xpPoints)&&(identical(other.streakDays, streakDays) || other.streakDays == streakDays)&&(identical(other.streakMultiplierActive, streakMultiplierActive) || other.streakMultiplierActive == streakMultiplierActive)&&(identical(other.trustTier, trustTier) || other.trustTier == trustTier)&&(identical(other.weeklyQuest, weeklyQuest) || other.weeklyQuest == weeklyQuest)&&const DeepCollectionEquality().equals(other.recentEvents, recentEvents)&&const DeepCollectionEquality().equals(other.badges, badges));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,xpPoints,streakDays,streakMultiplierActive,trustTier,weeklyQuest,const DeepCollectionEquality().hash(recentEvents),const DeepCollectionEquality().hash(badges));

@override
String toString() {
  return 'XpSummary(xpPoints: $xpPoints, streakDays: $streakDays, streakMultiplierActive: $streakMultiplierActive, trustTier: $trustTier, weeklyQuest: $weeklyQuest, recentEvents: $recentEvents, badges: $badges)';
}


}

/// @nodoc
abstract mixin class $XpSummaryCopyWith<$Res>  {
  factory $XpSummaryCopyWith(XpSummary value, $Res Function(XpSummary) _then) = _$XpSummaryCopyWithImpl;
@useResult
$Res call({
 int xpPoints, int streakDays, bool streakMultiplierActive, TrustTier? trustTier, WeeklyQuest? weeklyQuest, List<XpLedgerEvent> recentEvents, List<SafetyBadge> badges
});


$TrustTierCopyWith<$Res>? get trustTier;$WeeklyQuestCopyWith<$Res>? get weeklyQuest;

}
/// @nodoc
class _$XpSummaryCopyWithImpl<$Res>
    implements $XpSummaryCopyWith<$Res> {
  _$XpSummaryCopyWithImpl(this._self, this._then);

  final XpSummary _self;
  final $Res Function(XpSummary) _then;

/// Create a copy of XpSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? xpPoints = null,Object? streakDays = null,Object? streakMultiplierActive = null,Object? trustTier = freezed,Object? weeklyQuest = freezed,Object? recentEvents = null,Object? badges = null,}) {
  return _then(_self.copyWith(
xpPoints: null == xpPoints ? _self.xpPoints : xpPoints // ignore: cast_nullable_to_non_nullable
as int,streakDays: null == streakDays ? _self.streakDays : streakDays // ignore: cast_nullable_to_non_nullable
as int,streakMultiplierActive: null == streakMultiplierActive ? _self.streakMultiplierActive : streakMultiplierActive // ignore: cast_nullable_to_non_nullable
as bool,trustTier: freezed == trustTier ? _self.trustTier : trustTier // ignore: cast_nullable_to_non_nullable
as TrustTier?,weeklyQuest: freezed == weeklyQuest ? _self.weeklyQuest : weeklyQuest // ignore: cast_nullable_to_non_nullable
as WeeklyQuest?,recentEvents: null == recentEvents ? _self.recentEvents : recentEvents // ignore: cast_nullable_to_non_nullable
as List<XpLedgerEvent>,badges: null == badges ? _self.badges : badges // ignore: cast_nullable_to_non_nullable
as List<SafetyBadge>,
  ));
}
/// Create a copy of XpSummary
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TrustTierCopyWith<$Res>? get trustTier {
    if (_self.trustTier == null) {
    return null;
  }

  return $TrustTierCopyWith<$Res>(_self.trustTier!, (value) {
    return _then(_self.copyWith(trustTier: value));
  });
}/// Create a copy of XpSummary
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$WeeklyQuestCopyWith<$Res>? get weeklyQuest {
    if (_self.weeklyQuest == null) {
    return null;
  }

  return $WeeklyQuestCopyWith<$Res>(_self.weeklyQuest!, (value) {
    return _then(_self.copyWith(weeklyQuest: value));
  });
}
}


/// Adds pattern-matching-related methods to [XpSummary].
extension XpSummaryPatterns on XpSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _XpSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _XpSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _XpSummary value)  $default,){
final _that = this;
switch (_that) {
case _XpSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _XpSummary value)?  $default,){
final _that = this;
switch (_that) {
case _XpSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int xpPoints,  int streakDays,  bool streakMultiplierActive,  TrustTier? trustTier,  WeeklyQuest? weeklyQuest,  List<XpLedgerEvent> recentEvents,  List<SafetyBadge> badges)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _XpSummary() when $default != null:
return $default(_that.xpPoints,_that.streakDays,_that.streakMultiplierActive,_that.trustTier,_that.weeklyQuest,_that.recentEvents,_that.badges);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int xpPoints,  int streakDays,  bool streakMultiplierActive,  TrustTier? trustTier,  WeeklyQuest? weeklyQuest,  List<XpLedgerEvent> recentEvents,  List<SafetyBadge> badges)  $default,) {final _that = this;
switch (_that) {
case _XpSummary():
return $default(_that.xpPoints,_that.streakDays,_that.streakMultiplierActive,_that.trustTier,_that.weeklyQuest,_that.recentEvents,_that.badges);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int xpPoints,  int streakDays,  bool streakMultiplierActive,  TrustTier? trustTier,  WeeklyQuest? weeklyQuest,  List<XpLedgerEvent> recentEvents,  List<SafetyBadge> badges)?  $default,) {final _that = this;
switch (_that) {
case _XpSummary() when $default != null:
return $default(_that.xpPoints,_that.streakDays,_that.streakMultiplierActive,_that.trustTier,_that.weeklyQuest,_that.recentEvents,_that.badges);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _XpSummary implements XpSummary {
  const _XpSummary({this.xpPoints = 0, this.streakDays = 0, this.streakMultiplierActive = false, this.trustTier, this.weeklyQuest, final  List<XpLedgerEvent> recentEvents = const <XpLedgerEvent>[], final  List<SafetyBadge> badges = const <SafetyBadge>[]}): _recentEvents = recentEvents,_badges = badges;
  factory _XpSummary.fromJson(Map<String, dynamic> json) => _$XpSummaryFromJson(json);

@override@JsonKey() final  int xpPoints;
@override@JsonKey() final  int streakDays;
@override@JsonKey() final  bool streakMultiplierActive;
@override final  TrustTier? trustTier;
@override final  WeeklyQuest? weeklyQuest;
 final  List<XpLedgerEvent> _recentEvents;
@override@JsonKey() List<XpLedgerEvent> get recentEvents {
  if (_recentEvents is EqualUnmodifiableListView) return _recentEvents;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_recentEvents);
}

 final  List<SafetyBadge> _badges;
@override@JsonKey() List<SafetyBadge> get badges {
  if (_badges is EqualUnmodifiableListView) return _badges;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_badges);
}


/// Create a copy of XpSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$XpSummaryCopyWith<_XpSummary> get copyWith => __$XpSummaryCopyWithImpl<_XpSummary>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$XpSummaryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _XpSummary&&(identical(other.xpPoints, xpPoints) || other.xpPoints == xpPoints)&&(identical(other.streakDays, streakDays) || other.streakDays == streakDays)&&(identical(other.streakMultiplierActive, streakMultiplierActive) || other.streakMultiplierActive == streakMultiplierActive)&&(identical(other.trustTier, trustTier) || other.trustTier == trustTier)&&(identical(other.weeklyQuest, weeklyQuest) || other.weeklyQuest == weeklyQuest)&&const DeepCollectionEquality().equals(other._recentEvents, _recentEvents)&&const DeepCollectionEquality().equals(other._badges, _badges));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,xpPoints,streakDays,streakMultiplierActive,trustTier,weeklyQuest,const DeepCollectionEquality().hash(_recentEvents),const DeepCollectionEquality().hash(_badges));

@override
String toString() {
  return 'XpSummary(xpPoints: $xpPoints, streakDays: $streakDays, streakMultiplierActive: $streakMultiplierActive, trustTier: $trustTier, weeklyQuest: $weeklyQuest, recentEvents: $recentEvents, badges: $badges)';
}


}

/// @nodoc
abstract mixin class _$XpSummaryCopyWith<$Res> implements $XpSummaryCopyWith<$Res> {
  factory _$XpSummaryCopyWith(_XpSummary value, $Res Function(_XpSummary) _then) = __$XpSummaryCopyWithImpl;
@override @useResult
$Res call({
 int xpPoints, int streakDays, bool streakMultiplierActive, TrustTier? trustTier, WeeklyQuest? weeklyQuest, List<XpLedgerEvent> recentEvents, List<SafetyBadge> badges
});


@override $TrustTierCopyWith<$Res>? get trustTier;@override $WeeklyQuestCopyWith<$Res>? get weeklyQuest;

}
/// @nodoc
class __$XpSummaryCopyWithImpl<$Res>
    implements _$XpSummaryCopyWith<$Res> {
  __$XpSummaryCopyWithImpl(this._self, this._then);

  final _XpSummary _self;
  final $Res Function(_XpSummary) _then;

/// Create a copy of XpSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? xpPoints = null,Object? streakDays = null,Object? streakMultiplierActive = null,Object? trustTier = freezed,Object? weeklyQuest = freezed,Object? recentEvents = null,Object? badges = null,}) {
  return _then(_XpSummary(
xpPoints: null == xpPoints ? _self.xpPoints : xpPoints // ignore: cast_nullable_to_non_nullable
as int,streakDays: null == streakDays ? _self.streakDays : streakDays // ignore: cast_nullable_to_non_nullable
as int,streakMultiplierActive: null == streakMultiplierActive ? _self.streakMultiplierActive : streakMultiplierActive // ignore: cast_nullable_to_non_nullable
as bool,trustTier: freezed == trustTier ? _self.trustTier : trustTier // ignore: cast_nullable_to_non_nullable
as TrustTier?,weeklyQuest: freezed == weeklyQuest ? _self.weeklyQuest : weeklyQuest // ignore: cast_nullable_to_non_nullable
as WeeklyQuest?,recentEvents: null == recentEvents ? _self._recentEvents : recentEvents // ignore: cast_nullable_to_non_nullable
as List<XpLedgerEvent>,badges: null == badges ? _self._badges : badges // ignore: cast_nullable_to_non_nullable
as List<SafetyBadge>,
  ));
}

/// Create a copy of XpSummary
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TrustTierCopyWith<$Res>? get trustTier {
    if (_self.trustTier == null) {
    return null;
  }

  return $TrustTierCopyWith<$Res>(_self.trustTier!, (value) {
    return _then(_self.copyWith(trustTier: value));
  });
}/// Create a copy of XpSummary
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$WeeklyQuestCopyWith<$Res>? get weeklyQuest {
    if (_self.weeklyQuest == null) {
    return null;
  }

  return $WeeklyQuestCopyWith<$Res>(_self.weeklyQuest!, (value) {
    return _then(_self.copyWith(weeklyQuest: value));
  });
}
}


/// @nodoc
mixin _$TrustTier {

 int get tier; String get name; int get approvedCount; int get rejectedCount; double get verificationRate; NextTrustTier? get next;
/// Create a copy of TrustTier
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TrustTierCopyWith<TrustTier> get copyWith => _$TrustTierCopyWithImpl<TrustTier>(this as TrustTier, _$identity);

  /// Serializes this TrustTier to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TrustTier&&(identical(other.tier, tier) || other.tier == tier)&&(identical(other.name, name) || other.name == name)&&(identical(other.approvedCount, approvedCount) || other.approvedCount == approvedCount)&&(identical(other.rejectedCount, rejectedCount) || other.rejectedCount == rejectedCount)&&(identical(other.verificationRate, verificationRate) || other.verificationRate == verificationRate)&&(identical(other.next, next) || other.next == next));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,tier,name,approvedCount,rejectedCount,verificationRate,next);

@override
String toString() {
  return 'TrustTier(tier: $tier, name: $name, approvedCount: $approvedCount, rejectedCount: $rejectedCount, verificationRate: $verificationRate, next: $next)';
}


}

/// @nodoc
abstract mixin class $TrustTierCopyWith<$Res>  {
  factory $TrustTierCopyWith(TrustTier value, $Res Function(TrustTier) _then) = _$TrustTierCopyWithImpl;
@useResult
$Res call({
 int tier, String name, int approvedCount, int rejectedCount, double verificationRate, NextTrustTier? next
});


$NextTrustTierCopyWith<$Res>? get next;

}
/// @nodoc
class _$TrustTierCopyWithImpl<$Res>
    implements $TrustTierCopyWith<$Res> {
  _$TrustTierCopyWithImpl(this._self, this._then);

  final TrustTier _self;
  final $Res Function(TrustTier) _then;

/// Create a copy of TrustTier
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? tier = null,Object? name = null,Object? approvedCount = null,Object? rejectedCount = null,Object? verificationRate = null,Object? next = freezed,}) {
  return _then(_self.copyWith(
tier: null == tier ? _self.tier : tier // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,approvedCount: null == approvedCount ? _self.approvedCount : approvedCount // ignore: cast_nullable_to_non_nullable
as int,rejectedCount: null == rejectedCount ? _self.rejectedCount : rejectedCount // ignore: cast_nullable_to_non_nullable
as int,verificationRate: null == verificationRate ? _self.verificationRate : verificationRate // ignore: cast_nullable_to_non_nullable
as double,next: freezed == next ? _self.next : next // ignore: cast_nullable_to_non_nullable
as NextTrustTier?,
  ));
}
/// Create a copy of TrustTier
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$NextTrustTierCopyWith<$Res>? get next {
    if (_self.next == null) {
    return null;
  }

  return $NextTrustTierCopyWith<$Res>(_self.next!, (value) {
    return _then(_self.copyWith(next: value));
  });
}
}


/// Adds pattern-matching-related methods to [TrustTier].
extension TrustTierPatterns on TrustTier {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TrustTier value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TrustTier() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TrustTier value)  $default,){
final _that = this;
switch (_that) {
case _TrustTier():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TrustTier value)?  $default,){
final _that = this;
switch (_that) {
case _TrustTier() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int tier,  String name,  int approvedCount,  int rejectedCount,  double verificationRate,  NextTrustTier? next)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TrustTier() when $default != null:
return $default(_that.tier,_that.name,_that.approvedCount,_that.rejectedCount,_that.verificationRate,_that.next);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int tier,  String name,  int approvedCount,  int rejectedCount,  double verificationRate,  NextTrustTier? next)  $default,) {final _that = this;
switch (_that) {
case _TrustTier():
return $default(_that.tier,_that.name,_that.approvedCount,_that.rejectedCount,_that.verificationRate,_that.next);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int tier,  String name,  int approvedCount,  int rejectedCount,  double verificationRate,  NextTrustTier? next)?  $default,) {final _that = this;
switch (_that) {
case _TrustTier() when $default != null:
return $default(_that.tier,_that.name,_that.approvedCount,_that.rejectedCount,_that.verificationRate,_that.next);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TrustTier implements TrustTier {
  const _TrustTier({this.tier = 1, this.name = 'Newcomer', this.approvedCount = 0, this.rejectedCount = 0, this.verificationRate = 0.0, this.next});
  factory _TrustTier.fromJson(Map<String, dynamic> json) => _$TrustTierFromJson(json);

@override@JsonKey() final  int tier;
@override@JsonKey() final  String name;
@override@JsonKey() final  int approvedCount;
@override@JsonKey() final  int rejectedCount;
@override@JsonKey() final  double verificationRate;
@override final  NextTrustTier? next;

/// Create a copy of TrustTier
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TrustTierCopyWith<_TrustTier> get copyWith => __$TrustTierCopyWithImpl<_TrustTier>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TrustTierToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TrustTier&&(identical(other.tier, tier) || other.tier == tier)&&(identical(other.name, name) || other.name == name)&&(identical(other.approvedCount, approvedCount) || other.approvedCount == approvedCount)&&(identical(other.rejectedCount, rejectedCount) || other.rejectedCount == rejectedCount)&&(identical(other.verificationRate, verificationRate) || other.verificationRate == verificationRate)&&(identical(other.next, next) || other.next == next));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,tier,name,approvedCount,rejectedCount,verificationRate,next);

@override
String toString() {
  return 'TrustTier(tier: $tier, name: $name, approvedCount: $approvedCount, rejectedCount: $rejectedCount, verificationRate: $verificationRate, next: $next)';
}


}

/// @nodoc
abstract mixin class _$TrustTierCopyWith<$Res> implements $TrustTierCopyWith<$Res> {
  factory _$TrustTierCopyWith(_TrustTier value, $Res Function(_TrustTier) _then) = __$TrustTierCopyWithImpl;
@override @useResult
$Res call({
 int tier, String name, int approvedCount, int rejectedCount, double verificationRate, NextTrustTier? next
});


@override $NextTrustTierCopyWith<$Res>? get next;

}
/// @nodoc
class __$TrustTierCopyWithImpl<$Res>
    implements _$TrustTierCopyWith<$Res> {
  __$TrustTierCopyWithImpl(this._self, this._then);

  final _TrustTier _self;
  final $Res Function(_TrustTier) _then;

/// Create a copy of TrustTier
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? tier = null,Object? name = null,Object? approvedCount = null,Object? rejectedCount = null,Object? verificationRate = null,Object? next = freezed,}) {
  return _then(_TrustTier(
tier: null == tier ? _self.tier : tier // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,approvedCount: null == approvedCount ? _self.approvedCount : approvedCount // ignore: cast_nullable_to_non_nullable
as int,rejectedCount: null == rejectedCount ? _self.rejectedCount : rejectedCount // ignore: cast_nullable_to_non_nullable
as int,verificationRate: null == verificationRate ? _self.verificationRate : verificationRate // ignore: cast_nullable_to_non_nullable
as double,next: freezed == next ? _self.next : next // ignore: cast_nullable_to_non_nullable
as NextTrustTier?,
  ));
}

/// Create a copy of TrustTier
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$NextTrustTierCopyWith<$Res>? get next {
    if (_self.next == null) {
    return null;
  }

  return $NextTrustTierCopyWith<$Res>(_self.next!, (value) {
    return _then(_self.copyWith(next: value));
  });
}
}


/// @nodoc
mixin _$NextTrustTier {

 String get name; int get approvedNeeded; double get rateNeeded;
/// Create a copy of NextTrustTier
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NextTrustTierCopyWith<NextTrustTier> get copyWith => _$NextTrustTierCopyWithImpl<NextTrustTier>(this as NextTrustTier, _$identity);

  /// Serializes this NextTrustTier to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NextTrustTier&&(identical(other.name, name) || other.name == name)&&(identical(other.approvedNeeded, approvedNeeded) || other.approvedNeeded == approvedNeeded)&&(identical(other.rateNeeded, rateNeeded) || other.rateNeeded == rateNeeded));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,approvedNeeded,rateNeeded);

@override
String toString() {
  return 'NextTrustTier(name: $name, approvedNeeded: $approvedNeeded, rateNeeded: $rateNeeded)';
}


}

/// @nodoc
abstract mixin class $NextTrustTierCopyWith<$Res>  {
  factory $NextTrustTierCopyWith(NextTrustTier value, $Res Function(NextTrustTier) _then) = _$NextTrustTierCopyWithImpl;
@useResult
$Res call({
 String name, int approvedNeeded, double rateNeeded
});




}
/// @nodoc
class _$NextTrustTierCopyWithImpl<$Res>
    implements $NextTrustTierCopyWith<$Res> {
  _$NextTrustTierCopyWithImpl(this._self, this._then);

  final NextTrustTier _self;
  final $Res Function(NextTrustTier) _then;

/// Create a copy of NextTrustTier
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? approvedNeeded = null,Object? rateNeeded = null,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,approvedNeeded: null == approvedNeeded ? _self.approvedNeeded : approvedNeeded // ignore: cast_nullable_to_non_nullable
as int,rateNeeded: null == rateNeeded ? _self.rateNeeded : rateNeeded // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [NextTrustTier].
extension NextTrustTierPatterns on NextTrustTier {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NextTrustTier value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NextTrustTier() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NextTrustTier value)  $default,){
final _that = this;
switch (_that) {
case _NextTrustTier():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NextTrustTier value)?  $default,){
final _that = this;
switch (_that) {
case _NextTrustTier() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  int approvedNeeded,  double rateNeeded)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NextTrustTier() when $default != null:
return $default(_that.name,_that.approvedNeeded,_that.rateNeeded);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  int approvedNeeded,  double rateNeeded)  $default,) {final _that = this;
switch (_that) {
case _NextTrustTier():
return $default(_that.name,_that.approvedNeeded,_that.rateNeeded);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  int approvedNeeded,  double rateNeeded)?  $default,) {final _that = this;
switch (_that) {
case _NextTrustTier() when $default != null:
return $default(_that.name,_that.approvedNeeded,_that.rateNeeded);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _NextTrustTier implements NextTrustTier {
  const _NextTrustTier({required this.name, this.approvedNeeded = 0, this.rateNeeded = 0.0});
  factory _NextTrustTier.fromJson(Map<String, dynamic> json) => _$NextTrustTierFromJson(json);

@override final  String name;
@override@JsonKey() final  int approvedNeeded;
@override@JsonKey() final  double rateNeeded;

/// Create a copy of NextTrustTier
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NextTrustTierCopyWith<_NextTrustTier> get copyWith => __$NextTrustTierCopyWithImpl<_NextTrustTier>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$NextTrustTierToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NextTrustTier&&(identical(other.name, name) || other.name == name)&&(identical(other.approvedNeeded, approvedNeeded) || other.approvedNeeded == approvedNeeded)&&(identical(other.rateNeeded, rateNeeded) || other.rateNeeded == rateNeeded));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,approvedNeeded,rateNeeded);

@override
String toString() {
  return 'NextTrustTier(name: $name, approvedNeeded: $approvedNeeded, rateNeeded: $rateNeeded)';
}


}

/// @nodoc
abstract mixin class _$NextTrustTierCopyWith<$Res> implements $NextTrustTierCopyWith<$Res> {
  factory _$NextTrustTierCopyWith(_NextTrustTier value, $Res Function(_NextTrustTier) _then) = __$NextTrustTierCopyWithImpl;
@override @useResult
$Res call({
 String name, int approvedNeeded, double rateNeeded
});




}
/// @nodoc
class __$NextTrustTierCopyWithImpl<$Res>
    implements _$NextTrustTierCopyWith<$Res> {
  __$NextTrustTierCopyWithImpl(this._self, this._then);

  final _NextTrustTier _self;
  final $Res Function(_NextTrustTier) _then;

/// Create a copy of NextTrustTier
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? approvedNeeded = null,Object? rateNeeded = null,}) {
  return _then(_NextTrustTier(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,approvedNeeded: null == approvedNeeded ? _self.approvedNeeded : approvedNeeded // ignore: cast_nullable_to_non_nullable
as int,rateNeeded: null == rateNeeded ? _self.rateNeeded : rateNeeded // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}


/// @nodoc
mixin _$WeeklyQuest {

 String get id; String get title; String? get description; int get target; int get progress; int get xpReward; bool get completed;
/// Create a copy of WeeklyQuest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WeeklyQuestCopyWith<WeeklyQuest> get copyWith => _$WeeklyQuestCopyWithImpl<WeeklyQuest>(this as WeeklyQuest, _$identity);

  /// Serializes this WeeklyQuest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WeeklyQuest&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.target, target) || other.target == target)&&(identical(other.progress, progress) || other.progress == progress)&&(identical(other.xpReward, xpReward) || other.xpReward == xpReward)&&(identical(other.completed, completed) || other.completed == completed));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,description,target,progress,xpReward,completed);

@override
String toString() {
  return 'WeeklyQuest(id: $id, title: $title, description: $description, target: $target, progress: $progress, xpReward: $xpReward, completed: $completed)';
}


}

/// @nodoc
abstract mixin class $WeeklyQuestCopyWith<$Res>  {
  factory $WeeklyQuestCopyWith(WeeklyQuest value, $Res Function(WeeklyQuest) _then) = _$WeeklyQuestCopyWithImpl;
@useResult
$Res call({
 String id, String title, String? description, int target, int progress, int xpReward, bool completed
});




}
/// @nodoc
class _$WeeklyQuestCopyWithImpl<$Res>
    implements $WeeklyQuestCopyWith<$Res> {
  _$WeeklyQuestCopyWithImpl(this._self, this._then);

  final WeeklyQuest _self;
  final $Res Function(WeeklyQuest) _then;

/// Create a copy of WeeklyQuest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? description = freezed,Object? target = null,Object? progress = null,Object? xpReward = null,Object? completed = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,target: null == target ? _self.target : target // ignore: cast_nullable_to_non_nullable
as int,progress: null == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as int,xpReward: null == xpReward ? _self.xpReward : xpReward // ignore: cast_nullable_to_non_nullable
as int,completed: null == completed ? _self.completed : completed // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [WeeklyQuest].
extension WeeklyQuestPatterns on WeeklyQuest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WeeklyQuest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WeeklyQuest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WeeklyQuest value)  $default,){
final _that = this;
switch (_that) {
case _WeeklyQuest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WeeklyQuest value)?  $default,){
final _that = this;
switch (_that) {
case _WeeklyQuest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String? description,  int target,  int progress,  int xpReward,  bool completed)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WeeklyQuest() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.target,_that.progress,_that.xpReward,_that.completed);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String? description,  int target,  int progress,  int xpReward,  bool completed)  $default,) {final _that = this;
switch (_that) {
case _WeeklyQuest():
return $default(_that.id,_that.title,_that.description,_that.target,_that.progress,_that.xpReward,_that.completed);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String? description,  int target,  int progress,  int xpReward,  bool completed)?  $default,) {final _that = this;
switch (_that) {
case _WeeklyQuest() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.target,_that.progress,_that.xpReward,_that.completed);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WeeklyQuest implements WeeklyQuest {
  const _WeeklyQuest({required this.id, required this.title, this.description, this.target = 1, this.progress = 0, this.xpReward = 0, this.completed = false});
  factory _WeeklyQuest.fromJson(Map<String, dynamic> json) => _$WeeklyQuestFromJson(json);

@override final  String id;
@override final  String title;
@override final  String? description;
@override@JsonKey() final  int target;
@override@JsonKey() final  int progress;
@override@JsonKey() final  int xpReward;
@override@JsonKey() final  bool completed;

/// Create a copy of WeeklyQuest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WeeklyQuestCopyWith<_WeeklyQuest> get copyWith => __$WeeklyQuestCopyWithImpl<_WeeklyQuest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WeeklyQuestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WeeklyQuest&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.target, target) || other.target == target)&&(identical(other.progress, progress) || other.progress == progress)&&(identical(other.xpReward, xpReward) || other.xpReward == xpReward)&&(identical(other.completed, completed) || other.completed == completed));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,description,target,progress,xpReward,completed);

@override
String toString() {
  return 'WeeklyQuest(id: $id, title: $title, description: $description, target: $target, progress: $progress, xpReward: $xpReward, completed: $completed)';
}


}

/// @nodoc
abstract mixin class _$WeeklyQuestCopyWith<$Res> implements $WeeklyQuestCopyWith<$Res> {
  factory _$WeeklyQuestCopyWith(_WeeklyQuest value, $Res Function(_WeeklyQuest) _then) = __$WeeklyQuestCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String? description, int target, int progress, int xpReward, bool completed
});




}
/// @nodoc
class __$WeeklyQuestCopyWithImpl<$Res>
    implements _$WeeklyQuestCopyWith<$Res> {
  __$WeeklyQuestCopyWithImpl(this._self, this._then);

  final _WeeklyQuest _self;
  final $Res Function(_WeeklyQuest) _then;

/// Create a copy of WeeklyQuest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? description = freezed,Object? target = null,Object? progress = null,Object? xpReward = null,Object? completed = null,}) {
  return _then(_WeeklyQuest(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,target: null == target ? _self.target : target // ignore: cast_nullable_to_non_nullable
as int,progress: null == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as int,xpReward: null == xpReward ? _self.xpReward : xpReward // ignore: cast_nullable_to_non_nullable
as int,completed: null == completed ? _self.completed : completed // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$SafetyBadge {

 String get id; String get name; String get description; int get threshold; int get progress; bool get earned; DateTime? get earnedAt;
/// Create a copy of SafetyBadge
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SafetyBadgeCopyWith<SafetyBadge> get copyWith => _$SafetyBadgeCopyWithImpl<SafetyBadge>(this as SafetyBadge, _$identity);

  /// Serializes this SafetyBadge to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SafetyBadge&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.threshold, threshold) || other.threshold == threshold)&&(identical(other.progress, progress) || other.progress == progress)&&(identical(other.earned, earned) || other.earned == earned)&&(identical(other.earnedAt, earnedAt) || other.earnedAt == earnedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,description,threshold,progress,earned,earnedAt);

@override
String toString() {
  return 'SafetyBadge(id: $id, name: $name, description: $description, threshold: $threshold, progress: $progress, earned: $earned, earnedAt: $earnedAt)';
}


}

/// @nodoc
abstract mixin class $SafetyBadgeCopyWith<$Res>  {
  factory $SafetyBadgeCopyWith(SafetyBadge value, $Res Function(SafetyBadge) _then) = _$SafetyBadgeCopyWithImpl;
@useResult
$Res call({
 String id, String name, String description, int threshold, int progress, bool earned, DateTime? earnedAt
});




}
/// @nodoc
class _$SafetyBadgeCopyWithImpl<$Res>
    implements $SafetyBadgeCopyWith<$Res> {
  _$SafetyBadgeCopyWithImpl(this._self, this._then);

  final SafetyBadge _self;
  final $Res Function(SafetyBadge) _then;

/// Create a copy of SafetyBadge
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? description = null,Object? threshold = null,Object? progress = null,Object? earned = null,Object? earnedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,threshold: null == threshold ? _self.threshold : threshold // ignore: cast_nullable_to_non_nullable
as int,progress: null == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as int,earned: null == earned ? _self.earned : earned // ignore: cast_nullable_to_non_nullable
as bool,earnedAt: freezed == earnedAt ? _self.earnedAt : earnedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [SafetyBadge].
extension SafetyBadgePatterns on SafetyBadge {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SafetyBadge value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SafetyBadge() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SafetyBadge value)  $default,){
final _that = this;
switch (_that) {
case _SafetyBadge():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SafetyBadge value)?  $default,){
final _that = this;
switch (_that) {
case _SafetyBadge() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String description,  int threshold,  int progress,  bool earned,  DateTime? earnedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SafetyBadge() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.threshold,_that.progress,_that.earned,_that.earnedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String description,  int threshold,  int progress,  bool earned,  DateTime? earnedAt)  $default,) {final _that = this;
switch (_that) {
case _SafetyBadge():
return $default(_that.id,_that.name,_that.description,_that.threshold,_that.progress,_that.earned,_that.earnedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String description,  int threshold,  int progress,  bool earned,  DateTime? earnedAt)?  $default,) {final _that = this;
switch (_that) {
case _SafetyBadge() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.threshold,_that.progress,_that.earned,_that.earnedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SafetyBadge extends SafetyBadge {
  const _SafetyBadge({required this.id, required this.name, this.description = '', this.threshold = 1, this.progress = 0, this.earned = false, this.earnedAt}): super._();
  factory _SafetyBadge.fromJson(Map<String, dynamic> json) => _$SafetyBadgeFromJson(json);

@override final  String id;
@override final  String name;
@override@JsonKey() final  String description;
@override@JsonKey() final  int threshold;
@override@JsonKey() final  int progress;
@override@JsonKey() final  bool earned;
@override final  DateTime? earnedAt;

/// Create a copy of SafetyBadge
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SafetyBadgeCopyWith<_SafetyBadge> get copyWith => __$SafetyBadgeCopyWithImpl<_SafetyBadge>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SafetyBadgeToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SafetyBadge&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.threshold, threshold) || other.threshold == threshold)&&(identical(other.progress, progress) || other.progress == progress)&&(identical(other.earned, earned) || other.earned == earned)&&(identical(other.earnedAt, earnedAt) || other.earnedAt == earnedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,description,threshold,progress,earned,earnedAt);

@override
String toString() {
  return 'SafetyBadge(id: $id, name: $name, description: $description, threshold: $threshold, progress: $progress, earned: $earned, earnedAt: $earnedAt)';
}


}

/// @nodoc
abstract mixin class _$SafetyBadgeCopyWith<$Res> implements $SafetyBadgeCopyWith<$Res> {
  factory _$SafetyBadgeCopyWith(_SafetyBadge value, $Res Function(_SafetyBadge) _then) = __$SafetyBadgeCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String description, int threshold, int progress, bool earned, DateTime? earnedAt
});




}
/// @nodoc
class __$SafetyBadgeCopyWithImpl<$Res>
    implements _$SafetyBadgeCopyWith<$Res> {
  __$SafetyBadgeCopyWithImpl(this._self, this._then);

  final _SafetyBadge _self;
  final $Res Function(_SafetyBadge) _then;

/// Create a copy of SafetyBadge
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? description = null,Object? threshold = null,Object? progress = null,Object? earned = null,Object? earnedAt = freezed,}) {
  return _then(_SafetyBadge(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,threshold: null == threshold ? _self.threshold : threshold // ignore: cast_nullable_to_non_nullable
as int,progress: null == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as int,earned: null == earned ? _self.earned : earned // ignore: cast_nullable_to_non_nullable
as bool,earnedAt: freezed == earnedAt ? _self.earnedAt : earnedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$XpLedgerEvent {

 String get id;@JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue) XpEventType? get type; int get points; String? get hazardId; String? get guideId; DateTime? get createdAt;
/// Create a copy of XpLedgerEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$XpLedgerEventCopyWith<XpLedgerEvent> get copyWith => _$XpLedgerEventCopyWithImpl<XpLedgerEvent>(this as XpLedgerEvent, _$identity);

  /// Serializes this XpLedgerEvent to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is XpLedgerEvent&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.points, points) || other.points == points)&&(identical(other.hazardId, hazardId) || other.hazardId == hazardId)&&(identical(other.guideId, guideId) || other.guideId == guideId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,points,hazardId,guideId,createdAt);

@override
String toString() {
  return 'XpLedgerEvent(id: $id, type: $type, points: $points, hazardId: $hazardId, guideId: $guideId, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $XpLedgerEventCopyWith<$Res>  {
  factory $XpLedgerEventCopyWith(XpLedgerEvent value, $Res Function(XpLedgerEvent) _then) = _$XpLedgerEventCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue) XpEventType? type, int points, String? hazardId, String? guideId, DateTime? createdAt
});




}
/// @nodoc
class _$XpLedgerEventCopyWithImpl<$Res>
    implements $XpLedgerEventCopyWith<$Res> {
  _$XpLedgerEventCopyWithImpl(this._self, this._then);

  final XpLedgerEvent _self;
  final $Res Function(XpLedgerEvent) _then;

/// Create a copy of XpLedgerEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? type = freezed,Object? points = null,Object? hazardId = freezed,Object? guideId = freezed,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as XpEventType?,points: null == points ? _self.points : points // ignore: cast_nullable_to_non_nullable
as int,hazardId: freezed == hazardId ? _self.hazardId : hazardId // ignore: cast_nullable_to_non_nullable
as String?,guideId: freezed == guideId ? _self.guideId : guideId // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [XpLedgerEvent].
extension XpLedgerEventPatterns on XpLedgerEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _XpLedgerEvent value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _XpLedgerEvent() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _XpLedgerEvent value)  $default,){
final _that = this;
switch (_that) {
case _XpLedgerEvent():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _XpLedgerEvent value)?  $default,){
final _that = this;
switch (_that) {
case _XpLedgerEvent() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue)  XpEventType? type,  int points,  String? hazardId,  String? guideId,  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _XpLedgerEvent() when $default != null:
return $default(_that.id,_that.type,_that.points,_that.hazardId,_that.guideId,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue)  XpEventType? type,  int points,  String? hazardId,  String? guideId,  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _XpLedgerEvent():
return $default(_that.id,_that.type,_that.points,_that.hazardId,_that.guideId,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue)  XpEventType? type,  int points,  String? hazardId,  String? guideId,  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _XpLedgerEvent() when $default != null:
return $default(_that.id,_that.type,_that.points,_that.hazardId,_that.guideId,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _XpLedgerEvent implements XpLedgerEvent {
  const _XpLedgerEvent({required this.id, @JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue) this.type, this.points = 0, this.hazardId, this.guideId, this.createdAt});
  factory _XpLedgerEvent.fromJson(Map<String, dynamic> json) => _$XpLedgerEventFromJson(json);

@override final  String id;
@override@JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue) final  XpEventType? type;
@override@JsonKey() final  int points;
@override final  String? hazardId;
@override final  String? guideId;
@override final  DateTime? createdAt;

/// Create a copy of XpLedgerEvent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$XpLedgerEventCopyWith<_XpLedgerEvent> get copyWith => __$XpLedgerEventCopyWithImpl<_XpLedgerEvent>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$XpLedgerEventToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _XpLedgerEvent&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.points, points) || other.points == points)&&(identical(other.hazardId, hazardId) || other.hazardId == hazardId)&&(identical(other.guideId, guideId) || other.guideId == guideId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,points,hazardId,guideId,createdAt);

@override
String toString() {
  return 'XpLedgerEvent(id: $id, type: $type, points: $points, hazardId: $hazardId, guideId: $guideId, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$XpLedgerEventCopyWith<$Res> implements $XpLedgerEventCopyWith<$Res> {
  factory _$XpLedgerEventCopyWith(_XpLedgerEvent value, $Res Function(_XpLedgerEvent) _then) = __$XpLedgerEventCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue) XpEventType? type, int points, String? hazardId, String? guideId, DateTime? createdAt
});




}
/// @nodoc
class __$XpLedgerEventCopyWithImpl<$Res>
    implements _$XpLedgerEventCopyWith<$Res> {
  __$XpLedgerEventCopyWithImpl(this._self, this._then);

  final _XpLedgerEvent _self;
  final $Res Function(_XpLedgerEvent) _then;

/// Create a copy of XpLedgerEvent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? type = freezed,Object? points = null,Object? hazardId = freezed,Object? guideId = freezed,Object? createdAt = freezed,}) {
  return _then(_XpLedgerEvent(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as XpEventType?,points: null == points ? _self.points : points // ignore: cast_nullable_to_non_nullable
as int,hazardId: freezed == hazardId ? _self.hazardId : hazardId // ignore: cast_nullable_to_non_nullable
as String?,guideId: freezed == guideId ? _self.guideId : guideId // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on

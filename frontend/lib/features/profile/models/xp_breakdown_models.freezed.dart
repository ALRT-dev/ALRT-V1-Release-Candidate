// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'xp_breakdown_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$XpBreakdown {

 int get currentXpPoints; double get reliabilityScore;/// Everything the ledger has applied. Equal to [currentXpPoints] unless
/// a total was floored at zero along the way.
 int get ledgerTotal; int get rank; int get totalUsers; int get percentile; XpBreakdownStats? get stats;/// Points grouped by the kind of event that earned them.
 List<XpTypeTotal> get byType;/// The reports that earned or cost the most, biggest first.
 List<XpReportBreakdown> get reports;/// Learning, itemised like reports: guides by name, challenges by week.
 XpLearningBreakdown? get learning;
/// Create a copy of XpBreakdown
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$XpBreakdownCopyWith<XpBreakdown> get copyWith => _$XpBreakdownCopyWithImpl<XpBreakdown>(this as XpBreakdown, _$identity);

  /// Serializes this XpBreakdown to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is XpBreakdown&&(identical(other.currentXpPoints, currentXpPoints) || other.currentXpPoints == currentXpPoints)&&(identical(other.reliabilityScore, reliabilityScore) || other.reliabilityScore == reliabilityScore)&&(identical(other.ledgerTotal, ledgerTotal) || other.ledgerTotal == ledgerTotal)&&(identical(other.rank, rank) || other.rank == rank)&&(identical(other.totalUsers, totalUsers) || other.totalUsers == totalUsers)&&(identical(other.percentile, percentile) || other.percentile == percentile)&&(identical(other.stats, stats) || other.stats == stats)&&const DeepCollectionEquality().equals(other.byType, byType)&&const DeepCollectionEquality().equals(other.reports, reports)&&(identical(other.learning, learning) || other.learning == learning));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,currentXpPoints,reliabilityScore,ledgerTotal,rank,totalUsers,percentile,stats,const DeepCollectionEquality().hash(byType),const DeepCollectionEquality().hash(reports),learning);

@override
String toString() {
  return 'XpBreakdown(currentXpPoints: $currentXpPoints, reliabilityScore: $reliabilityScore, ledgerTotal: $ledgerTotal, rank: $rank, totalUsers: $totalUsers, percentile: $percentile, stats: $stats, byType: $byType, reports: $reports, learning: $learning)';
}


}

/// @nodoc
abstract mixin class $XpBreakdownCopyWith<$Res>  {
  factory $XpBreakdownCopyWith(XpBreakdown value, $Res Function(XpBreakdown) _then) = _$XpBreakdownCopyWithImpl;
@useResult
$Res call({
 int currentXpPoints, double reliabilityScore, int ledgerTotal, int rank, int totalUsers, int percentile, XpBreakdownStats? stats, List<XpTypeTotal> byType, List<XpReportBreakdown> reports, XpLearningBreakdown? learning
});


$XpBreakdownStatsCopyWith<$Res>? get stats;$XpLearningBreakdownCopyWith<$Res>? get learning;

}
/// @nodoc
class _$XpBreakdownCopyWithImpl<$Res>
    implements $XpBreakdownCopyWith<$Res> {
  _$XpBreakdownCopyWithImpl(this._self, this._then);

  final XpBreakdown _self;
  final $Res Function(XpBreakdown) _then;

/// Create a copy of XpBreakdown
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? currentXpPoints = null,Object? reliabilityScore = null,Object? ledgerTotal = null,Object? rank = null,Object? totalUsers = null,Object? percentile = null,Object? stats = freezed,Object? byType = null,Object? reports = null,Object? learning = freezed,}) {
  return _then(_self.copyWith(
currentXpPoints: null == currentXpPoints ? _self.currentXpPoints : currentXpPoints // ignore: cast_nullable_to_non_nullable
as int,reliabilityScore: null == reliabilityScore ? _self.reliabilityScore : reliabilityScore // ignore: cast_nullable_to_non_nullable
as double,ledgerTotal: null == ledgerTotal ? _self.ledgerTotal : ledgerTotal // ignore: cast_nullable_to_non_nullable
as int,rank: null == rank ? _self.rank : rank // ignore: cast_nullable_to_non_nullable
as int,totalUsers: null == totalUsers ? _self.totalUsers : totalUsers // ignore: cast_nullable_to_non_nullable
as int,percentile: null == percentile ? _self.percentile : percentile // ignore: cast_nullable_to_non_nullable
as int,stats: freezed == stats ? _self.stats : stats // ignore: cast_nullable_to_non_nullable
as XpBreakdownStats?,byType: null == byType ? _self.byType : byType // ignore: cast_nullable_to_non_nullable
as List<XpTypeTotal>,reports: null == reports ? _self.reports : reports // ignore: cast_nullable_to_non_nullable
as List<XpReportBreakdown>,learning: freezed == learning ? _self.learning : learning // ignore: cast_nullable_to_non_nullable
as XpLearningBreakdown?,
  ));
}
/// Create a copy of XpBreakdown
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$XpBreakdownStatsCopyWith<$Res>? get stats {
    if (_self.stats == null) {
    return null;
  }

  return $XpBreakdownStatsCopyWith<$Res>(_self.stats!, (value) {
    return _then(_self.copyWith(stats: value));
  });
}/// Create a copy of XpBreakdown
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$XpLearningBreakdownCopyWith<$Res>? get learning {
    if (_self.learning == null) {
    return null;
  }

  return $XpLearningBreakdownCopyWith<$Res>(_self.learning!, (value) {
    return _then(_self.copyWith(learning: value));
  });
}
}


/// Adds pattern-matching-related methods to [XpBreakdown].
extension XpBreakdownPatterns on XpBreakdown {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _XpBreakdown value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _XpBreakdown() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _XpBreakdown value)  $default,){
final _that = this;
switch (_that) {
case _XpBreakdown():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _XpBreakdown value)?  $default,){
final _that = this;
switch (_that) {
case _XpBreakdown() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int currentXpPoints,  double reliabilityScore,  int ledgerTotal,  int rank,  int totalUsers,  int percentile,  XpBreakdownStats? stats,  List<XpTypeTotal> byType,  List<XpReportBreakdown> reports,  XpLearningBreakdown? learning)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _XpBreakdown() when $default != null:
return $default(_that.currentXpPoints,_that.reliabilityScore,_that.ledgerTotal,_that.rank,_that.totalUsers,_that.percentile,_that.stats,_that.byType,_that.reports,_that.learning);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int currentXpPoints,  double reliabilityScore,  int ledgerTotal,  int rank,  int totalUsers,  int percentile,  XpBreakdownStats? stats,  List<XpTypeTotal> byType,  List<XpReportBreakdown> reports,  XpLearningBreakdown? learning)  $default,) {final _that = this;
switch (_that) {
case _XpBreakdown():
return $default(_that.currentXpPoints,_that.reliabilityScore,_that.ledgerTotal,_that.rank,_that.totalUsers,_that.percentile,_that.stats,_that.byType,_that.reports,_that.learning);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int currentXpPoints,  double reliabilityScore,  int ledgerTotal,  int rank,  int totalUsers,  int percentile,  XpBreakdownStats? stats,  List<XpTypeTotal> byType,  List<XpReportBreakdown> reports,  XpLearningBreakdown? learning)?  $default,) {final _that = this;
switch (_that) {
case _XpBreakdown() when $default != null:
return $default(_that.currentXpPoints,_that.reliabilityScore,_that.ledgerTotal,_that.rank,_that.totalUsers,_that.percentile,_that.stats,_that.byType,_that.reports,_that.learning);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _XpBreakdown extends XpBreakdown {
  const _XpBreakdown({this.currentXpPoints = 0, this.reliabilityScore = 0.0, this.ledgerTotal = 0, this.rank = 0, this.totalUsers = 0, this.percentile = 0, this.stats, final  List<XpTypeTotal> byType = const <XpTypeTotal>[], final  List<XpReportBreakdown> reports = const <XpReportBreakdown>[], this.learning}): _byType = byType,_reports = reports,super._();
  factory _XpBreakdown.fromJson(Map<String, dynamic> json) => _$XpBreakdownFromJson(json);

@override@JsonKey() final  int currentXpPoints;
@override@JsonKey() final  double reliabilityScore;
/// Everything the ledger has applied. Equal to [currentXpPoints] unless
/// a total was floored at zero along the way.
@override@JsonKey() final  int ledgerTotal;
@override@JsonKey() final  int rank;
@override@JsonKey() final  int totalUsers;
@override@JsonKey() final  int percentile;
@override final  XpBreakdownStats? stats;
/// Points grouped by the kind of event that earned them.
 final  List<XpTypeTotal> _byType;
/// Points grouped by the kind of event that earned them.
@override@JsonKey() List<XpTypeTotal> get byType {
  if (_byType is EqualUnmodifiableListView) return _byType;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_byType);
}

/// The reports that earned or cost the most, biggest first.
 final  List<XpReportBreakdown> _reports;
/// The reports that earned or cost the most, biggest first.
@override@JsonKey() List<XpReportBreakdown> get reports {
  if (_reports is EqualUnmodifiableListView) return _reports;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_reports);
}

/// Learning, itemised like reports: guides by name, challenges by week.
@override final  XpLearningBreakdown? learning;

/// Create a copy of XpBreakdown
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$XpBreakdownCopyWith<_XpBreakdown> get copyWith => __$XpBreakdownCopyWithImpl<_XpBreakdown>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$XpBreakdownToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _XpBreakdown&&(identical(other.currentXpPoints, currentXpPoints) || other.currentXpPoints == currentXpPoints)&&(identical(other.reliabilityScore, reliabilityScore) || other.reliabilityScore == reliabilityScore)&&(identical(other.ledgerTotal, ledgerTotal) || other.ledgerTotal == ledgerTotal)&&(identical(other.rank, rank) || other.rank == rank)&&(identical(other.totalUsers, totalUsers) || other.totalUsers == totalUsers)&&(identical(other.percentile, percentile) || other.percentile == percentile)&&(identical(other.stats, stats) || other.stats == stats)&&const DeepCollectionEquality().equals(other._byType, _byType)&&const DeepCollectionEquality().equals(other._reports, _reports)&&(identical(other.learning, learning) || other.learning == learning));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,currentXpPoints,reliabilityScore,ledgerTotal,rank,totalUsers,percentile,stats,const DeepCollectionEquality().hash(_byType),const DeepCollectionEquality().hash(_reports),learning);

@override
String toString() {
  return 'XpBreakdown(currentXpPoints: $currentXpPoints, reliabilityScore: $reliabilityScore, ledgerTotal: $ledgerTotal, rank: $rank, totalUsers: $totalUsers, percentile: $percentile, stats: $stats, byType: $byType, reports: $reports, learning: $learning)';
}


}

/// @nodoc
abstract mixin class _$XpBreakdownCopyWith<$Res> implements $XpBreakdownCopyWith<$Res> {
  factory _$XpBreakdownCopyWith(_XpBreakdown value, $Res Function(_XpBreakdown) _then) = __$XpBreakdownCopyWithImpl;
@override @useResult
$Res call({
 int currentXpPoints, double reliabilityScore, int ledgerTotal, int rank, int totalUsers, int percentile, XpBreakdownStats? stats, List<XpTypeTotal> byType, List<XpReportBreakdown> reports, XpLearningBreakdown? learning
});


@override $XpBreakdownStatsCopyWith<$Res>? get stats;@override $XpLearningBreakdownCopyWith<$Res>? get learning;

}
/// @nodoc
class __$XpBreakdownCopyWithImpl<$Res>
    implements _$XpBreakdownCopyWith<$Res> {
  __$XpBreakdownCopyWithImpl(this._self, this._then);

  final _XpBreakdown _self;
  final $Res Function(_XpBreakdown) _then;

/// Create a copy of XpBreakdown
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? currentXpPoints = null,Object? reliabilityScore = null,Object? ledgerTotal = null,Object? rank = null,Object? totalUsers = null,Object? percentile = null,Object? stats = freezed,Object? byType = null,Object? reports = null,Object? learning = freezed,}) {
  return _then(_XpBreakdown(
currentXpPoints: null == currentXpPoints ? _self.currentXpPoints : currentXpPoints // ignore: cast_nullable_to_non_nullable
as int,reliabilityScore: null == reliabilityScore ? _self.reliabilityScore : reliabilityScore // ignore: cast_nullable_to_non_nullable
as double,ledgerTotal: null == ledgerTotal ? _self.ledgerTotal : ledgerTotal // ignore: cast_nullable_to_non_nullable
as int,rank: null == rank ? _self.rank : rank // ignore: cast_nullable_to_non_nullable
as int,totalUsers: null == totalUsers ? _self.totalUsers : totalUsers // ignore: cast_nullable_to_non_nullable
as int,percentile: null == percentile ? _self.percentile : percentile // ignore: cast_nullable_to_non_nullable
as int,stats: freezed == stats ? _self.stats : stats // ignore: cast_nullable_to_non_nullable
as XpBreakdownStats?,byType: null == byType ? _self._byType : byType // ignore: cast_nullable_to_non_nullable
as List<XpTypeTotal>,reports: null == reports ? _self._reports : reports // ignore: cast_nullable_to_non_nullable
as List<XpReportBreakdown>,learning: freezed == learning ? _self.learning : learning // ignore: cast_nullable_to_non_nullable
as XpLearningBreakdown?,
  ));
}

/// Create a copy of XpBreakdown
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$XpBreakdownStatsCopyWith<$Res>? get stats {
    if (_self.stats == null) {
    return null;
  }

  return $XpBreakdownStatsCopyWith<$Res>(_self.stats!, (value) {
    return _then(_self.copyWith(stats: value));
  });
}/// Create a copy of XpBreakdown
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$XpLearningBreakdownCopyWith<$Res>? get learning {
    if (_self.learning == null) {
    return null;
  }

  return $XpLearningBreakdownCopyWith<$Res>(_self.learning!, (value) {
    return _then(_self.copyWith(learning: value));
  });
}
}


/// @nodoc
mixin _$XpBreakdownStats {

 int get totalHazardsReported; int get approvedReports;/// How many people confirmed the caller's reports. This is what the
/// badges are earned on.
 int get corroborationsReceived;
/// Create a copy of XpBreakdownStats
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$XpBreakdownStatsCopyWith<XpBreakdownStats> get copyWith => _$XpBreakdownStatsCopyWithImpl<XpBreakdownStats>(this as XpBreakdownStats, _$identity);

  /// Serializes this XpBreakdownStats to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is XpBreakdownStats&&(identical(other.totalHazardsReported, totalHazardsReported) || other.totalHazardsReported == totalHazardsReported)&&(identical(other.approvedReports, approvedReports) || other.approvedReports == approvedReports)&&(identical(other.corroborationsReceived, corroborationsReceived) || other.corroborationsReceived == corroborationsReceived));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalHazardsReported,approvedReports,corroborationsReceived);

@override
String toString() {
  return 'XpBreakdownStats(totalHazardsReported: $totalHazardsReported, approvedReports: $approvedReports, corroborationsReceived: $corroborationsReceived)';
}


}

/// @nodoc
abstract mixin class $XpBreakdownStatsCopyWith<$Res>  {
  factory $XpBreakdownStatsCopyWith(XpBreakdownStats value, $Res Function(XpBreakdownStats) _then) = _$XpBreakdownStatsCopyWithImpl;
@useResult
$Res call({
 int totalHazardsReported, int approvedReports, int corroborationsReceived
});




}
/// @nodoc
class _$XpBreakdownStatsCopyWithImpl<$Res>
    implements $XpBreakdownStatsCopyWith<$Res> {
  _$XpBreakdownStatsCopyWithImpl(this._self, this._then);

  final XpBreakdownStats _self;
  final $Res Function(XpBreakdownStats) _then;

/// Create a copy of XpBreakdownStats
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? totalHazardsReported = null,Object? approvedReports = null,Object? corroborationsReceived = null,}) {
  return _then(_self.copyWith(
totalHazardsReported: null == totalHazardsReported ? _self.totalHazardsReported : totalHazardsReported // ignore: cast_nullable_to_non_nullable
as int,approvedReports: null == approvedReports ? _self.approvedReports : approvedReports // ignore: cast_nullable_to_non_nullable
as int,corroborationsReceived: null == corroborationsReceived ? _self.corroborationsReceived : corroborationsReceived // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [XpBreakdownStats].
extension XpBreakdownStatsPatterns on XpBreakdownStats {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _XpBreakdownStats value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _XpBreakdownStats() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _XpBreakdownStats value)  $default,){
final _that = this;
switch (_that) {
case _XpBreakdownStats():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _XpBreakdownStats value)?  $default,){
final _that = this;
switch (_that) {
case _XpBreakdownStats() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int totalHazardsReported,  int approvedReports,  int corroborationsReceived)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _XpBreakdownStats() when $default != null:
return $default(_that.totalHazardsReported,_that.approvedReports,_that.corroborationsReceived);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int totalHazardsReported,  int approvedReports,  int corroborationsReceived)  $default,) {final _that = this;
switch (_that) {
case _XpBreakdownStats():
return $default(_that.totalHazardsReported,_that.approvedReports,_that.corroborationsReceived);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int totalHazardsReported,  int approvedReports,  int corroborationsReceived)?  $default,) {final _that = this;
switch (_that) {
case _XpBreakdownStats() when $default != null:
return $default(_that.totalHazardsReported,_that.approvedReports,_that.corroborationsReceived);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _XpBreakdownStats implements XpBreakdownStats {
  const _XpBreakdownStats({this.totalHazardsReported = 0, this.approvedReports = 0, this.corroborationsReceived = 0});
  factory _XpBreakdownStats.fromJson(Map<String, dynamic> json) => _$XpBreakdownStatsFromJson(json);

@override@JsonKey() final  int totalHazardsReported;
@override@JsonKey() final  int approvedReports;
/// How many people confirmed the caller's reports. This is what the
/// badges are earned on.
@override@JsonKey() final  int corroborationsReceived;

/// Create a copy of XpBreakdownStats
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$XpBreakdownStatsCopyWith<_XpBreakdownStats> get copyWith => __$XpBreakdownStatsCopyWithImpl<_XpBreakdownStats>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$XpBreakdownStatsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _XpBreakdownStats&&(identical(other.totalHazardsReported, totalHazardsReported) || other.totalHazardsReported == totalHazardsReported)&&(identical(other.approvedReports, approvedReports) || other.approvedReports == approvedReports)&&(identical(other.corroborationsReceived, corroborationsReceived) || other.corroborationsReceived == corroborationsReceived));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalHazardsReported,approvedReports,corroborationsReceived);

@override
String toString() {
  return 'XpBreakdownStats(totalHazardsReported: $totalHazardsReported, approvedReports: $approvedReports, corroborationsReceived: $corroborationsReceived)';
}


}

/// @nodoc
abstract mixin class _$XpBreakdownStatsCopyWith<$Res> implements $XpBreakdownStatsCopyWith<$Res> {
  factory _$XpBreakdownStatsCopyWith(_XpBreakdownStats value, $Res Function(_XpBreakdownStats) _then) = __$XpBreakdownStatsCopyWithImpl;
@override @useResult
$Res call({
 int totalHazardsReported, int approvedReports, int corroborationsReceived
});




}
/// @nodoc
class __$XpBreakdownStatsCopyWithImpl<$Res>
    implements _$XpBreakdownStatsCopyWith<$Res> {
  __$XpBreakdownStatsCopyWithImpl(this._self, this._then);

  final _XpBreakdownStats _self;
  final $Res Function(_XpBreakdownStats) _then;

/// Create a copy of XpBreakdownStats
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? totalHazardsReported = null,Object? approvedReports = null,Object? corroborationsReceived = null,}) {
  return _then(_XpBreakdownStats(
totalHazardsReported: null == totalHazardsReported ? _self.totalHazardsReported : totalHazardsReported // ignore: cast_nullable_to_non_nullable
as int,approvedReports: null == approvedReports ? _self.approvedReports : approvedReports // ignore: cast_nullable_to_non_nullable
as int,corroborationsReceived: null == corroborationsReceived ? _self.corroborationsReceived : corroborationsReceived // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$XpTypeTotal {

@JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue) XpEventType? get type; int get count; int get points;
/// Create a copy of XpTypeTotal
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$XpTypeTotalCopyWith<XpTypeTotal> get copyWith => _$XpTypeTotalCopyWithImpl<XpTypeTotal>(this as XpTypeTotal, _$identity);

  /// Serializes this XpTypeTotal to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is XpTypeTotal&&(identical(other.type, type) || other.type == type)&&(identical(other.count, count) || other.count == count)&&(identical(other.points, points) || other.points == points));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,count,points);

@override
String toString() {
  return 'XpTypeTotal(type: $type, count: $count, points: $points)';
}


}

/// @nodoc
abstract mixin class $XpTypeTotalCopyWith<$Res>  {
  factory $XpTypeTotalCopyWith(XpTypeTotal value, $Res Function(XpTypeTotal) _then) = _$XpTypeTotalCopyWithImpl;
@useResult
$Res call({
@JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue) XpEventType? type, int count, int points
});




}
/// @nodoc
class _$XpTypeTotalCopyWithImpl<$Res>
    implements $XpTypeTotalCopyWith<$Res> {
  _$XpTypeTotalCopyWithImpl(this._self, this._then);

  final XpTypeTotal _self;
  final $Res Function(XpTypeTotal) _then;

/// Create a copy of XpTypeTotal
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? type = freezed,Object? count = null,Object? points = null,}) {
  return _then(_self.copyWith(
type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as XpEventType?,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,points: null == points ? _self.points : points // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [XpTypeTotal].
extension XpTypeTotalPatterns on XpTypeTotal {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _XpTypeTotal value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _XpTypeTotal() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _XpTypeTotal value)  $default,){
final _that = this;
switch (_that) {
case _XpTypeTotal():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _XpTypeTotal value)?  $default,){
final _that = this;
switch (_that) {
case _XpTypeTotal() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue)  XpEventType? type,  int count,  int points)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _XpTypeTotal() when $default != null:
return $default(_that.type,_that.count,_that.points);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue)  XpEventType? type,  int count,  int points)  $default,) {final _that = this;
switch (_that) {
case _XpTypeTotal():
return $default(_that.type,_that.count,_that.points);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue)  XpEventType? type,  int count,  int points)?  $default,) {final _that = this;
switch (_that) {
case _XpTypeTotal() when $default != null:
return $default(_that.type,_that.count,_that.points);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _XpTypeTotal implements XpTypeTotal {
  const _XpTypeTotal({@JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue) this.type, this.count = 0, this.points = 0});
  factory _XpTypeTotal.fromJson(Map<String, dynamic> json) => _$XpTypeTotalFromJson(json);

@override@JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue) final  XpEventType? type;
@override@JsonKey() final  int count;
@override@JsonKey() final  int points;

/// Create a copy of XpTypeTotal
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$XpTypeTotalCopyWith<_XpTypeTotal> get copyWith => __$XpTypeTotalCopyWithImpl<_XpTypeTotal>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$XpTypeTotalToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _XpTypeTotal&&(identical(other.type, type) || other.type == type)&&(identical(other.count, count) || other.count == count)&&(identical(other.points, points) || other.points == points));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,count,points);

@override
String toString() {
  return 'XpTypeTotal(type: $type, count: $count, points: $points)';
}


}

/// @nodoc
abstract mixin class _$XpTypeTotalCopyWith<$Res> implements $XpTypeTotalCopyWith<$Res> {
  factory _$XpTypeTotalCopyWith(_XpTypeTotal value, $Res Function(_XpTypeTotal) _then) = __$XpTypeTotalCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue) XpEventType? type, int count, int points
});




}
/// @nodoc
class __$XpTypeTotalCopyWithImpl<$Res>
    implements _$XpTypeTotalCopyWith<$Res> {
  __$XpTypeTotalCopyWithImpl(this._self, this._then);

  final _XpTypeTotal _self;
  final $Res Function(_XpTypeTotal) _then;

/// Create a copy of XpTypeTotal
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? type = freezed,Object? count = null,Object? points = null,}) {
  return _then(_XpTypeTotal(
type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as XpEventType?,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,points: null == points ? _self.points : points // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$XpLearningBreakdown {

 List<XpGuideCompletion> get guides; List<XpChallengeCompletion> get challenges;
/// Create a copy of XpLearningBreakdown
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$XpLearningBreakdownCopyWith<XpLearningBreakdown> get copyWith => _$XpLearningBreakdownCopyWithImpl<XpLearningBreakdown>(this as XpLearningBreakdown, _$identity);

  /// Serializes this XpLearningBreakdown to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is XpLearningBreakdown&&const DeepCollectionEquality().equals(other.guides, guides)&&const DeepCollectionEquality().equals(other.challenges, challenges));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(guides),const DeepCollectionEquality().hash(challenges));

@override
String toString() {
  return 'XpLearningBreakdown(guides: $guides, challenges: $challenges)';
}


}

/// @nodoc
abstract mixin class $XpLearningBreakdownCopyWith<$Res>  {
  factory $XpLearningBreakdownCopyWith(XpLearningBreakdown value, $Res Function(XpLearningBreakdown) _then) = _$XpLearningBreakdownCopyWithImpl;
@useResult
$Res call({
 List<XpGuideCompletion> guides, List<XpChallengeCompletion> challenges
});




}
/// @nodoc
class _$XpLearningBreakdownCopyWithImpl<$Res>
    implements $XpLearningBreakdownCopyWith<$Res> {
  _$XpLearningBreakdownCopyWithImpl(this._self, this._then);

  final XpLearningBreakdown _self;
  final $Res Function(XpLearningBreakdown) _then;

/// Create a copy of XpLearningBreakdown
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? guides = null,Object? challenges = null,}) {
  return _then(_self.copyWith(
guides: null == guides ? _self.guides : guides // ignore: cast_nullable_to_non_nullable
as List<XpGuideCompletion>,challenges: null == challenges ? _self.challenges : challenges // ignore: cast_nullable_to_non_nullable
as List<XpChallengeCompletion>,
  ));
}

}


/// Adds pattern-matching-related methods to [XpLearningBreakdown].
extension XpLearningBreakdownPatterns on XpLearningBreakdown {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _XpLearningBreakdown value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _XpLearningBreakdown() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _XpLearningBreakdown value)  $default,){
final _that = this;
switch (_that) {
case _XpLearningBreakdown():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _XpLearningBreakdown value)?  $default,){
final _that = this;
switch (_that) {
case _XpLearningBreakdown() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<XpGuideCompletion> guides,  List<XpChallengeCompletion> challenges)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _XpLearningBreakdown() when $default != null:
return $default(_that.guides,_that.challenges);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<XpGuideCompletion> guides,  List<XpChallengeCompletion> challenges)  $default,) {final _that = this;
switch (_that) {
case _XpLearningBreakdown():
return $default(_that.guides,_that.challenges);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<XpGuideCompletion> guides,  List<XpChallengeCompletion> challenges)?  $default,) {final _that = this;
switch (_that) {
case _XpLearningBreakdown() when $default != null:
return $default(_that.guides,_that.challenges);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _XpLearningBreakdown implements XpLearningBreakdown {
  const _XpLearningBreakdown({final  List<XpGuideCompletion> guides = const <XpGuideCompletion>[], final  List<XpChallengeCompletion> challenges = const <XpChallengeCompletion>[]}): _guides = guides,_challenges = challenges;
  factory _XpLearningBreakdown.fromJson(Map<String, dynamic> json) => _$XpLearningBreakdownFromJson(json);

 final  List<XpGuideCompletion> _guides;
@override@JsonKey() List<XpGuideCompletion> get guides {
  if (_guides is EqualUnmodifiableListView) return _guides;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_guides);
}

 final  List<XpChallengeCompletion> _challenges;
@override@JsonKey() List<XpChallengeCompletion> get challenges {
  if (_challenges is EqualUnmodifiableListView) return _challenges;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_challenges);
}


/// Create a copy of XpLearningBreakdown
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$XpLearningBreakdownCopyWith<_XpLearningBreakdown> get copyWith => __$XpLearningBreakdownCopyWithImpl<_XpLearningBreakdown>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$XpLearningBreakdownToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _XpLearningBreakdown&&const DeepCollectionEquality().equals(other._guides, _guides)&&const DeepCollectionEquality().equals(other._challenges, _challenges));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_guides),const DeepCollectionEquality().hash(_challenges));

@override
String toString() {
  return 'XpLearningBreakdown(guides: $guides, challenges: $challenges)';
}


}

/// @nodoc
abstract mixin class _$XpLearningBreakdownCopyWith<$Res> implements $XpLearningBreakdownCopyWith<$Res> {
  factory _$XpLearningBreakdownCopyWith(_XpLearningBreakdown value, $Res Function(_XpLearningBreakdown) _then) = __$XpLearningBreakdownCopyWithImpl;
@override @useResult
$Res call({
 List<XpGuideCompletion> guides, List<XpChallengeCompletion> challenges
});




}
/// @nodoc
class __$XpLearningBreakdownCopyWithImpl<$Res>
    implements _$XpLearningBreakdownCopyWith<$Res> {
  __$XpLearningBreakdownCopyWithImpl(this._self, this._then);

  final _XpLearningBreakdown _self;
  final $Res Function(_XpLearningBreakdown) _then;

/// Create a copy of XpLearningBreakdown
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? guides = null,Object? challenges = null,}) {
  return _then(_XpLearningBreakdown(
guides: null == guides ? _self._guides : guides // ignore: cast_nullable_to_non_nullable
as List<XpGuideCompletion>,challenges: null == challenges ? _self._challenges : challenges // ignore: cast_nullable_to_non_nullable
as List<XpChallengeCompletion>,
  ));
}


}


/// @nodoc
mixin _$XpGuideCompletion {

 String? get guideId; String get title; int get points; DateTime? get createdAt;
/// Create a copy of XpGuideCompletion
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$XpGuideCompletionCopyWith<XpGuideCompletion> get copyWith => _$XpGuideCompletionCopyWithImpl<XpGuideCompletion>(this as XpGuideCompletion, _$identity);

  /// Serializes this XpGuideCompletion to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is XpGuideCompletion&&(identical(other.guideId, guideId) || other.guideId == guideId)&&(identical(other.title, title) || other.title == title)&&(identical(other.points, points) || other.points == points)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,guideId,title,points,createdAt);

@override
String toString() {
  return 'XpGuideCompletion(guideId: $guideId, title: $title, points: $points, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $XpGuideCompletionCopyWith<$Res>  {
  factory $XpGuideCompletionCopyWith(XpGuideCompletion value, $Res Function(XpGuideCompletion) _then) = _$XpGuideCompletionCopyWithImpl;
@useResult
$Res call({
 String? guideId, String title, int points, DateTime? createdAt
});




}
/// @nodoc
class _$XpGuideCompletionCopyWithImpl<$Res>
    implements $XpGuideCompletionCopyWith<$Res> {
  _$XpGuideCompletionCopyWithImpl(this._self, this._then);

  final XpGuideCompletion _self;
  final $Res Function(XpGuideCompletion) _then;

/// Create a copy of XpGuideCompletion
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? guideId = freezed,Object? title = null,Object? points = null,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
guideId: freezed == guideId ? _self.guideId : guideId // ignore: cast_nullable_to_non_nullable
as String?,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,points: null == points ? _self.points : points // ignore: cast_nullable_to_non_nullable
as int,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [XpGuideCompletion].
extension XpGuideCompletionPatterns on XpGuideCompletion {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _XpGuideCompletion value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _XpGuideCompletion() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _XpGuideCompletion value)  $default,){
final _that = this;
switch (_that) {
case _XpGuideCompletion():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _XpGuideCompletion value)?  $default,){
final _that = this;
switch (_that) {
case _XpGuideCompletion() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? guideId,  String title,  int points,  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _XpGuideCompletion() when $default != null:
return $default(_that.guideId,_that.title,_that.points,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? guideId,  String title,  int points,  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _XpGuideCompletion():
return $default(_that.guideId,_that.title,_that.points,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? guideId,  String title,  int points,  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _XpGuideCompletion() when $default != null:
return $default(_that.guideId,_that.title,_that.points,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _XpGuideCompletion implements XpGuideCompletion {
  const _XpGuideCompletion({this.guideId, this.title = 'Safety guide', this.points = 0, this.createdAt});
  factory _XpGuideCompletion.fromJson(Map<String, dynamic> json) => _$XpGuideCompletionFromJson(json);

@override final  String? guideId;
@override@JsonKey() final  String title;
@override@JsonKey() final  int points;
@override final  DateTime? createdAt;

/// Create a copy of XpGuideCompletion
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$XpGuideCompletionCopyWith<_XpGuideCompletion> get copyWith => __$XpGuideCompletionCopyWithImpl<_XpGuideCompletion>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$XpGuideCompletionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _XpGuideCompletion&&(identical(other.guideId, guideId) || other.guideId == guideId)&&(identical(other.title, title) || other.title == title)&&(identical(other.points, points) || other.points == points)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,guideId,title,points,createdAt);

@override
String toString() {
  return 'XpGuideCompletion(guideId: $guideId, title: $title, points: $points, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$XpGuideCompletionCopyWith<$Res> implements $XpGuideCompletionCopyWith<$Res> {
  factory _$XpGuideCompletionCopyWith(_XpGuideCompletion value, $Res Function(_XpGuideCompletion) _then) = __$XpGuideCompletionCopyWithImpl;
@override @useResult
$Res call({
 String? guideId, String title, int points, DateTime? createdAt
});




}
/// @nodoc
class __$XpGuideCompletionCopyWithImpl<$Res>
    implements _$XpGuideCompletionCopyWith<$Res> {
  __$XpGuideCompletionCopyWithImpl(this._self, this._then);

  final _XpGuideCompletion _self;
  final $Res Function(_XpGuideCompletion) _then;

/// Create a copy of XpGuideCompletion
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? guideId = freezed,Object? title = null,Object? points = null,Object? createdAt = freezed,}) {
  return _then(_XpGuideCompletion(
guideId: freezed == guideId ? _self.guideId : guideId // ignore: cast_nullable_to_non_nullable
as String?,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,points: null == points ? _self.points : points // ignore: cast_nullable_to_non_nullable
as int,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$XpChallengeCompletion {

 int get points; DateTime? get createdAt;
/// Create a copy of XpChallengeCompletion
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$XpChallengeCompletionCopyWith<XpChallengeCompletion> get copyWith => _$XpChallengeCompletionCopyWithImpl<XpChallengeCompletion>(this as XpChallengeCompletion, _$identity);

  /// Serializes this XpChallengeCompletion to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is XpChallengeCompletion&&(identical(other.points, points) || other.points == points)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,points,createdAt);

@override
String toString() {
  return 'XpChallengeCompletion(points: $points, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $XpChallengeCompletionCopyWith<$Res>  {
  factory $XpChallengeCompletionCopyWith(XpChallengeCompletion value, $Res Function(XpChallengeCompletion) _then) = _$XpChallengeCompletionCopyWithImpl;
@useResult
$Res call({
 int points, DateTime? createdAt
});




}
/// @nodoc
class _$XpChallengeCompletionCopyWithImpl<$Res>
    implements $XpChallengeCompletionCopyWith<$Res> {
  _$XpChallengeCompletionCopyWithImpl(this._self, this._then);

  final XpChallengeCompletion _self;
  final $Res Function(XpChallengeCompletion) _then;

/// Create a copy of XpChallengeCompletion
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? points = null,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
points: null == points ? _self.points : points // ignore: cast_nullable_to_non_nullable
as int,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [XpChallengeCompletion].
extension XpChallengeCompletionPatterns on XpChallengeCompletion {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _XpChallengeCompletion value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _XpChallengeCompletion() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _XpChallengeCompletion value)  $default,){
final _that = this;
switch (_that) {
case _XpChallengeCompletion():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _XpChallengeCompletion value)?  $default,){
final _that = this;
switch (_that) {
case _XpChallengeCompletion() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int points,  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _XpChallengeCompletion() when $default != null:
return $default(_that.points,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int points,  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _XpChallengeCompletion():
return $default(_that.points,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int points,  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _XpChallengeCompletion() when $default != null:
return $default(_that.points,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _XpChallengeCompletion implements XpChallengeCompletion {
  const _XpChallengeCompletion({this.points = 0, this.createdAt});
  factory _XpChallengeCompletion.fromJson(Map<String, dynamic> json) => _$XpChallengeCompletionFromJson(json);

@override@JsonKey() final  int points;
@override final  DateTime? createdAt;

/// Create a copy of XpChallengeCompletion
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$XpChallengeCompletionCopyWith<_XpChallengeCompletion> get copyWith => __$XpChallengeCompletionCopyWithImpl<_XpChallengeCompletion>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$XpChallengeCompletionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _XpChallengeCompletion&&(identical(other.points, points) || other.points == points)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,points,createdAt);

@override
String toString() {
  return 'XpChallengeCompletion(points: $points, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$XpChallengeCompletionCopyWith<$Res> implements $XpChallengeCompletionCopyWith<$Res> {
  factory _$XpChallengeCompletionCopyWith(_XpChallengeCompletion value, $Res Function(_XpChallengeCompletion) _then) = __$XpChallengeCompletionCopyWithImpl;
@override @useResult
$Res call({
 int points, DateTime? createdAt
});




}
/// @nodoc
class __$XpChallengeCompletionCopyWithImpl<$Res>
    implements _$XpChallengeCompletionCopyWith<$Res> {
  __$XpChallengeCompletionCopyWithImpl(this._self, this._then);

  final _XpChallengeCompletion _self;
  final $Res Function(_XpChallengeCompletion) _then;

/// Create a copy of XpChallengeCompletion
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? points = null,Object? createdAt = freezed,}) {
  return _then(_XpChallengeCompletion(
points: null == points ? _self.points : points // ignore: cast_nullable_to_non_nullable
as int,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$XpReportBreakdown {

 String get hazardId; String get title; String get reviewStatus; int get points; List<XpReportEvent> get events; DateTime? get createdAt;
/// Create a copy of XpReportBreakdown
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$XpReportBreakdownCopyWith<XpReportBreakdown> get copyWith => _$XpReportBreakdownCopyWithImpl<XpReportBreakdown>(this as XpReportBreakdown, _$identity);

  /// Serializes this XpReportBreakdown to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is XpReportBreakdown&&(identical(other.hazardId, hazardId) || other.hazardId == hazardId)&&(identical(other.title, title) || other.title == title)&&(identical(other.reviewStatus, reviewStatus) || other.reviewStatus == reviewStatus)&&(identical(other.points, points) || other.points == points)&&const DeepCollectionEquality().equals(other.events, events)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,hazardId,title,reviewStatus,points,const DeepCollectionEquality().hash(events),createdAt);

@override
String toString() {
  return 'XpReportBreakdown(hazardId: $hazardId, title: $title, reviewStatus: $reviewStatus, points: $points, events: $events, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $XpReportBreakdownCopyWith<$Res>  {
  factory $XpReportBreakdownCopyWith(XpReportBreakdown value, $Res Function(XpReportBreakdown) _then) = _$XpReportBreakdownCopyWithImpl;
@useResult
$Res call({
 String hazardId, String title, String reviewStatus, int points, List<XpReportEvent> events, DateTime? createdAt
});




}
/// @nodoc
class _$XpReportBreakdownCopyWithImpl<$Res>
    implements $XpReportBreakdownCopyWith<$Res> {
  _$XpReportBreakdownCopyWithImpl(this._self, this._then);

  final XpReportBreakdown _self;
  final $Res Function(XpReportBreakdown) _then;

/// Create a copy of XpReportBreakdown
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? hazardId = null,Object? title = null,Object? reviewStatus = null,Object? points = null,Object? events = null,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
hazardId: null == hazardId ? _self.hazardId : hazardId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,reviewStatus: null == reviewStatus ? _self.reviewStatus : reviewStatus // ignore: cast_nullable_to_non_nullable
as String,points: null == points ? _self.points : points // ignore: cast_nullable_to_non_nullable
as int,events: null == events ? _self.events : events // ignore: cast_nullable_to_non_nullable
as List<XpReportEvent>,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [XpReportBreakdown].
extension XpReportBreakdownPatterns on XpReportBreakdown {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _XpReportBreakdown value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _XpReportBreakdown() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _XpReportBreakdown value)  $default,){
final _that = this;
switch (_that) {
case _XpReportBreakdown():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _XpReportBreakdown value)?  $default,){
final _that = this;
switch (_that) {
case _XpReportBreakdown() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String hazardId,  String title,  String reviewStatus,  int points,  List<XpReportEvent> events,  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _XpReportBreakdown() when $default != null:
return $default(_that.hazardId,_that.title,_that.reviewStatus,_that.points,_that.events,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String hazardId,  String title,  String reviewStatus,  int points,  List<XpReportEvent> events,  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _XpReportBreakdown():
return $default(_that.hazardId,_that.title,_that.reviewStatus,_that.points,_that.events,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String hazardId,  String title,  String reviewStatus,  int points,  List<XpReportEvent> events,  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _XpReportBreakdown() when $default != null:
return $default(_that.hazardId,_that.title,_that.reviewStatus,_that.points,_that.events,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _XpReportBreakdown implements XpReportBreakdown {
  const _XpReportBreakdown({required this.hazardId, this.title = '', this.reviewStatus = 'pending', this.points = 0, final  List<XpReportEvent> events = const <XpReportEvent>[], this.createdAt}): _events = events;
  factory _XpReportBreakdown.fromJson(Map<String, dynamic> json) => _$XpReportBreakdownFromJson(json);

@override final  String hazardId;
@override@JsonKey() final  String title;
@override@JsonKey() final  String reviewStatus;
@override@JsonKey() final  int points;
 final  List<XpReportEvent> _events;
@override@JsonKey() List<XpReportEvent> get events {
  if (_events is EqualUnmodifiableListView) return _events;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_events);
}

@override final  DateTime? createdAt;

/// Create a copy of XpReportBreakdown
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$XpReportBreakdownCopyWith<_XpReportBreakdown> get copyWith => __$XpReportBreakdownCopyWithImpl<_XpReportBreakdown>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$XpReportBreakdownToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _XpReportBreakdown&&(identical(other.hazardId, hazardId) || other.hazardId == hazardId)&&(identical(other.title, title) || other.title == title)&&(identical(other.reviewStatus, reviewStatus) || other.reviewStatus == reviewStatus)&&(identical(other.points, points) || other.points == points)&&const DeepCollectionEquality().equals(other._events, _events)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,hazardId,title,reviewStatus,points,const DeepCollectionEquality().hash(_events),createdAt);

@override
String toString() {
  return 'XpReportBreakdown(hazardId: $hazardId, title: $title, reviewStatus: $reviewStatus, points: $points, events: $events, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$XpReportBreakdownCopyWith<$Res> implements $XpReportBreakdownCopyWith<$Res> {
  factory _$XpReportBreakdownCopyWith(_XpReportBreakdown value, $Res Function(_XpReportBreakdown) _then) = __$XpReportBreakdownCopyWithImpl;
@override @useResult
$Res call({
 String hazardId, String title, String reviewStatus, int points, List<XpReportEvent> events, DateTime? createdAt
});




}
/// @nodoc
class __$XpReportBreakdownCopyWithImpl<$Res>
    implements _$XpReportBreakdownCopyWith<$Res> {
  __$XpReportBreakdownCopyWithImpl(this._self, this._then);

  final _XpReportBreakdown _self;
  final $Res Function(_XpReportBreakdown) _then;

/// Create a copy of XpReportBreakdown
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? hazardId = null,Object? title = null,Object? reviewStatus = null,Object? points = null,Object? events = null,Object? createdAt = freezed,}) {
  return _then(_XpReportBreakdown(
hazardId: null == hazardId ? _self.hazardId : hazardId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,reviewStatus: null == reviewStatus ? _self.reviewStatus : reviewStatus // ignore: cast_nullable_to_non_nullable
as String,points: null == points ? _self.points : points // ignore: cast_nullable_to_non_nullable
as int,events: null == events ? _self._events : events // ignore: cast_nullable_to_non_nullable
as List<XpReportEvent>,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$XpReportEvent {

@JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue) XpEventType? get type; int get points; DateTime? get createdAt;
/// Create a copy of XpReportEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$XpReportEventCopyWith<XpReportEvent> get copyWith => _$XpReportEventCopyWithImpl<XpReportEvent>(this as XpReportEvent, _$identity);

  /// Serializes this XpReportEvent to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is XpReportEvent&&(identical(other.type, type) || other.type == type)&&(identical(other.points, points) || other.points == points)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,points,createdAt);

@override
String toString() {
  return 'XpReportEvent(type: $type, points: $points, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $XpReportEventCopyWith<$Res>  {
  factory $XpReportEventCopyWith(XpReportEvent value, $Res Function(XpReportEvent) _then) = _$XpReportEventCopyWithImpl;
@useResult
$Res call({
@JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue) XpEventType? type, int points, DateTime? createdAt
});




}
/// @nodoc
class _$XpReportEventCopyWithImpl<$Res>
    implements $XpReportEventCopyWith<$Res> {
  _$XpReportEventCopyWithImpl(this._self, this._then);

  final XpReportEvent _self;
  final $Res Function(XpReportEvent) _then;

/// Create a copy of XpReportEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? type = freezed,Object? points = null,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as XpEventType?,points: null == points ? _self.points : points // ignore: cast_nullable_to_non_nullable
as int,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [XpReportEvent].
extension XpReportEventPatterns on XpReportEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _XpReportEvent value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _XpReportEvent() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _XpReportEvent value)  $default,){
final _that = this;
switch (_that) {
case _XpReportEvent():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _XpReportEvent value)?  $default,){
final _that = this;
switch (_that) {
case _XpReportEvent() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue)  XpEventType? type,  int points,  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _XpReportEvent() when $default != null:
return $default(_that.type,_that.points,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue)  XpEventType? type,  int points,  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _XpReportEvent():
return $default(_that.type,_that.points,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue)  XpEventType? type,  int points,  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _XpReportEvent() when $default != null:
return $default(_that.type,_that.points,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _XpReportEvent implements XpReportEvent {
  const _XpReportEvent({@JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue) this.type, this.points = 0, this.createdAt});
  factory _XpReportEvent.fromJson(Map<String, dynamic> json) => _$XpReportEventFromJson(json);

@override@JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue) final  XpEventType? type;
@override@JsonKey() final  int points;
@override final  DateTime? createdAt;

/// Create a copy of XpReportEvent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$XpReportEventCopyWith<_XpReportEvent> get copyWith => __$XpReportEventCopyWithImpl<_XpReportEvent>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$XpReportEventToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _XpReportEvent&&(identical(other.type, type) || other.type == type)&&(identical(other.points, points) || other.points == points)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,points,createdAt);

@override
String toString() {
  return 'XpReportEvent(type: $type, points: $points, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$XpReportEventCopyWith<$Res> implements $XpReportEventCopyWith<$Res> {
  factory _$XpReportEventCopyWith(_XpReportEvent value, $Res Function(_XpReportEvent) _then) = __$XpReportEventCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue) XpEventType? type, int points, DateTime? createdAt
});




}
/// @nodoc
class __$XpReportEventCopyWithImpl<$Res>
    implements _$XpReportEventCopyWith<$Res> {
  __$XpReportEventCopyWithImpl(this._self, this._then);

  final _XpReportEvent _self;
  final $Res Function(_XpReportEvent) _then;

/// Create a copy of XpReportEvent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? type = freezed,Object? points = null,Object? createdAt = freezed,}) {
  return _then(_XpReportEvent(
type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as XpEventType?,points: null == points ? _self.points : points // ignore: cast_nullable_to_non_nullable
as int,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on

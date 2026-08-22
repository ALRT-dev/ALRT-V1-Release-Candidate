// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'xp_leaderboard_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$XpLeaderboard {

 List<XpLeaderboardEntry> get leaderboard; XpLeaderboardPagination? get pagination;
/// Create a copy of XpLeaderboard
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$XpLeaderboardCopyWith<XpLeaderboard> get copyWith => _$XpLeaderboardCopyWithImpl<XpLeaderboard>(this as XpLeaderboard, _$identity);

  /// Serializes this XpLeaderboard to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is XpLeaderboard&&const DeepCollectionEquality().equals(other.leaderboard, leaderboard)&&(identical(other.pagination, pagination) || other.pagination == pagination));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(leaderboard),pagination);

@override
String toString() {
  return 'XpLeaderboard(leaderboard: $leaderboard, pagination: $pagination)';
}


}

/// @nodoc
abstract mixin class $XpLeaderboardCopyWith<$Res>  {
  factory $XpLeaderboardCopyWith(XpLeaderboard value, $Res Function(XpLeaderboard) _then) = _$XpLeaderboardCopyWithImpl;
@useResult
$Res call({
 List<XpLeaderboardEntry> leaderboard, XpLeaderboardPagination? pagination
});


$XpLeaderboardPaginationCopyWith<$Res>? get pagination;

}
/// @nodoc
class _$XpLeaderboardCopyWithImpl<$Res>
    implements $XpLeaderboardCopyWith<$Res> {
  _$XpLeaderboardCopyWithImpl(this._self, this._then);

  final XpLeaderboard _self;
  final $Res Function(XpLeaderboard) _then;

/// Create a copy of XpLeaderboard
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? leaderboard = null,Object? pagination = freezed,}) {
  return _then(_self.copyWith(
leaderboard: null == leaderboard ? _self.leaderboard : leaderboard // ignore: cast_nullable_to_non_nullable
as List<XpLeaderboardEntry>,pagination: freezed == pagination ? _self.pagination : pagination // ignore: cast_nullable_to_non_nullable
as XpLeaderboardPagination?,
  ));
}
/// Create a copy of XpLeaderboard
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$XpLeaderboardPaginationCopyWith<$Res>? get pagination {
    if (_self.pagination == null) {
    return null;
  }

  return $XpLeaderboardPaginationCopyWith<$Res>(_self.pagination!, (value) {
    return _then(_self.copyWith(pagination: value));
  });
}
}


/// Adds pattern-matching-related methods to [XpLeaderboard].
extension XpLeaderboardPatterns on XpLeaderboard {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _XpLeaderboard value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _XpLeaderboard() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _XpLeaderboard value)  $default,){
final _that = this;
switch (_that) {
case _XpLeaderboard():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _XpLeaderboard value)?  $default,){
final _that = this;
switch (_that) {
case _XpLeaderboard() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<XpLeaderboardEntry> leaderboard,  XpLeaderboardPagination? pagination)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _XpLeaderboard() when $default != null:
return $default(_that.leaderboard,_that.pagination);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<XpLeaderboardEntry> leaderboard,  XpLeaderboardPagination? pagination)  $default,) {final _that = this;
switch (_that) {
case _XpLeaderboard():
return $default(_that.leaderboard,_that.pagination);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<XpLeaderboardEntry> leaderboard,  XpLeaderboardPagination? pagination)?  $default,) {final _that = this;
switch (_that) {
case _XpLeaderboard() when $default != null:
return $default(_that.leaderboard,_that.pagination);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _XpLeaderboard implements XpLeaderboard {
  const _XpLeaderboard({final  List<XpLeaderboardEntry> leaderboard = const <XpLeaderboardEntry>[], this.pagination}): _leaderboard = leaderboard;
  factory _XpLeaderboard.fromJson(Map<String, dynamic> json) => _$XpLeaderboardFromJson(json);

 final  List<XpLeaderboardEntry> _leaderboard;
@override@JsonKey() List<XpLeaderboardEntry> get leaderboard {
  if (_leaderboard is EqualUnmodifiableListView) return _leaderboard;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_leaderboard);
}

@override final  XpLeaderboardPagination? pagination;

/// Create a copy of XpLeaderboard
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$XpLeaderboardCopyWith<_XpLeaderboard> get copyWith => __$XpLeaderboardCopyWithImpl<_XpLeaderboard>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$XpLeaderboardToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _XpLeaderboard&&const DeepCollectionEquality().equals(other._leaderboard, _leaderboard)&&(identical(other.pagination, pagination) || other.pagination == pagination));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_leaderboard),pagination);

@override
String toString() {
  return 'XpLeaderboard(leaderboard: $leaderboard, pagination: $pagination)';
}


}

/// @nodoc
abstract mixin class _$XpLeaderboardCopyWith<$Res> implements $XpLeaderboardCopyWith<$Res> {
  factory _$XpLeaderboardCopyWith(_XpLeaderboard value, $Res Function(_XpLeaderboard) _then) = __$XpLeaderboardCopyWithImpl;
@override @useResult
$Res call({
 List<XpLeaderboardEntry> leaderboard, XpLeaderboardPagination? pagination
});


@override $XpLeaderboardPaginationCopyWith<$Res>? get pagination;

}
/// @nodoc
class __$XpLeaderboardCopyWithImpl<$Res>
    implements _$XpLeaderboardCopyWith<$Res> {
  __$XpLeaderboardCopyWithImpl(this._self, this._then);

  final _XpLeaderboard _self;
  final $Res Function(_XpLeaderboard) _then;

/// Create a copy of XpLeaderboard
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? leaderboard = null,Object? pagination = freezed,}) {
  return _then(_XpLeaderboard(
leaderboard: null == leaderboard ? _self._leaderboard : leaderboard // ignore: cast_nullable_to_non_nullable
as List<XpLeaderboardEntry>,pagination: freezed == pagination ? _self.pagination : pagination // ignore: cast_nullable_to_non_nullable
as XpLeaderboardPagination?,
  ));
}

/// Create a copy of XpLeaderboard
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$XpLeaderboardPaginationCopyWith<$Res>? get pagination {
    if (_self.pagination == null) {
    return null;
  }

  return $XpLeaderboardPaginationCopyWith<$Res>(_self.pagination!, (value) {
    return _then(_self.copyWith(pagination: value));
  });
}
}


/// @nodoc
mixin _$XpLeaderboardEntry {

 int get rank; String? get id; String get name; String? get email; int get xpPoints; double get reliabilityScore; int get hazardsReported;
/// Create a copy of XpLeaderboardEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$XpLeaderboardEntryCopyWith<XpLeaderboardEntry> get copyWith => _$XpLeaderboardEntryCopyWithImpl<XpLeaderboardEntry>(this as XpLeaderboardEntry, _$identity);

  /// Serializes this XpLeaderboardEntry to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is XpLeaderboardEntry&&(identical(other.rank, rank) || other.rank == rank)&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.email, email) || other.email == email)&&(identical(other.xpPoints, xpPoints) || other.xpPoints == xpPoints)&&(identical(other.reliabilityScore, reliabilityScore) || other.reliabilityScore == reliabilityScore)&&(identical(other.hazardsReported, hazardsReported) || other.hazardsReported == hazardsReported));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,rank,id,name,email,xpPoints,reliabilityScore,hazardsReported);

@override
String toString() {
  return 'XpLeaderboardEntry(rank: $rank, id: $id, name: $name, email: $email, xpPoints: $xpPoints, reliabilityScore: $reliabilityScore, hazardsReported: $hazardsReported)';
}


}

/// @nodoc
abstract mixin class $XpLeaderboardEntryCopyWith<$Res>  {
  factory $XpLeaderboardEntryCopyWith(XpLeaderboardEntry value, $Res Function(XpLeaderboardEntry) _then) = _$XpLeaderboardEntryCopyWithImpl;
@useResult
$Res call({
 int rank, String? id, String name, String? email, int xpPoints, double reliabilityScore, int hazardsReported
});




}
/// @nodoc
class _$XpLeaderboardEntryCopyWithImpl<$Res>
    implements $XpLeaderboardEntryCopyWith<$Res> {
  _$XpLeaderboardEntryCopyWithImpl(this._self, this._then);

  final XpLeaderboardEntry _self;
  final $Res Function(XpLeaderboardEntry) _then;

/// Create a copy of XpLeaderboardEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? rank = null,Object? id = freezed,Object? name = null,Object? email = freezed,Object? xpPoints = null,Object? reliabilityScore = null,Object? hazardsReported = null,}) {
  return _then(_self.copyWith(
rank: null == rank ? _self.rank : rank // ignore: cast_nullable_to_non_nullable
as int,id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,xpPoints: null == xpPoints ? _self.xpPoints : xpPoints // ignore: cast_nullable_to_non_nullable
as int,reliabilityScore: null == reliabilityScore ? _self.reliabilityScore : reliabilityScore // ignore: cast_nullable_to_non_nullable
as double,hazardsReported: null == hazardsReported ? _self.hazardsReported : hazardsReported // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [XpLeaderboardEntry].
extension XpLeaderboardEntryPatterns on XpLeaderboardEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _XpLeaderboardEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _XpLeaderboardEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _XpLeaderboardEntry value)  $default,){
final _that = this;
switch (_that) {
case _XpLeaderboardEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _XpLeaderboardEntry value)?  $default,){
final _that = this;
switch (_that) {
case _XpLeaderboardEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int rank,  String? id,  String name,  String? email,  int xpPoints,  double reliabilityScore,  int hazardsReported)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _XpLeaderboardEntry() when $default != null:
return $default(_that.rank,_that.id,_that.name,_that.email,_that.xpPoints,_that.reliabilityScore,_that.hazardsReported);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int rank,  String? id,  String name,  String? email,  int xpPoints,  double reliabilityScore,  int hazardsReported)  $default,) {final _that = this;
switch (_that) {
case _XpLeaderboardEntry():
return $default(_that.rank,_that.id,_that.name,_that.email,_that.xpPoints,_that.reliabilityScore,_that.hazardsReported);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int rank,  String? id,  String name,  String? email,  int xpPoints,  double reliabilityScore,  int hazardsReported)?  $default,) {final _that = this;
switch (_that) {
case _XpLeaderboardEntry() when $default != null:
return $default(_that.rank,_that.id,_that.name,_that.email,_that.xpPoints,_that.reliabilityScore,_that.hazardsReported);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _XpLeaderboardEntry implements XpLeaderboardEntry {
  const _XpLeaderboardEntry({this.rank = 0, this.id, this.name = 'Anonymous', this.email, this.xpPoints = 0, this.reliabilityScore = 0.0, this.hazardsReported = 0});
  factory _XpLeaderboardEntry.fromJson(Map<String, dynamic> json) => _$XpLeaderboardEntryFromJson(json);

@override@JsonKey() final  int rank;
@override final  String? id;
@override@JsonKey() final  String name;
@override final  String? email;
@override@JsonKey() final  int xpPoints;
@override@JsonKey() final  double reliabilityScore;
@override@JsonKey() final  int hazardsReported;

/// Create a copy of XpLeaderboardEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$XpLeaderboardEntryCopyWith<_XpLeaderboardEntry> get copyWith => __$XpLeaderboardEntryCopyWithImpl<_XpLeaderboardEntry>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$XpLeaderboardEntryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _XpLeaderboardEntry&&(identical(other.rank, rank) || other.rank == rank)&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.email, email) || other.email == email)&&(identical(other.xpPoints, xpPoints) || other.xpPoints == xpPoints)&&(identical(other.reliabilityScore, reliabilityScore) || other.reliabilityScore == reliabilityScore)&&(identical(other.hazardsReported, hazardsReported) || other.hazardsReported == hazardsReported));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,rank,id,name,email,xpPoints,reliabilityScore,hazardsReported);

@override
String toString() {
  return 'XpLeaderboardEntry(rank: $rank, id: $id, name: $name, email: $email, xpPoints: $xpPoints, reliabilityScore: $reliabilityScore, hazardsReported: $hazardsReported)';
}


}

/// @nodoc
abstract mixin class _$XpLeaderboardEntryCopyWith<$Res> implements $XpLeaderboardEntryCopyWith<$Res> {
  factory _$XpLeaderboardEntryCopyWith(_XpLeaderboardEntry value, $Res Function(_XpLeaderboardEntry) _then) = __$XpLeaderboardEntryCopyWithImpl;
@override @useResult
$Res call({
 int rank, String? id, String name, String? email, int xpPoints, double reliabilityScore, int hazardsReported
});




}
/// @nodoc
class __$XpLeaderboardEntryCopyWithImpl<$Res>
    implements _$XpLeaderboardEntryCopyWith<$Res> {
  __$XpLeaderboardEntryCopyWithImpl(this._self, this._then);

  final _XpLeaderboardEntry _self;
  final $Res Function(_XpLeaderboardEntry) _then;

/// Create a copy of XpLeaderboardEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? rank = null,Object? id = freezed,Object? name = null,Object? email = freezed,Object? xpPoints = null,Object? reliabilityScore = null,Object? hazardsReported = null,}) {
  return _then(_XpLeaderboardEntry(
rank: null == rank ? _self.rank : rank // ignore: cast_nullable_to_non_nullable
as int,id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,xpPoints: null == xpPoints ? _self.xpPoints : xpPoints // ignore: cast_nullable_to_non_nullable
as int,reliabilityScore: null == reliabilityScore ? _self.reliabilityScore : reliabilityScore // ignore: cast_nullable_to_non_nullable
as double,hazardsReported: null == hazardsReported ? _self.hazardsReported : hazardsReported // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$XpLeaderboardPagination {

 int get currentPage; int get totalPages; int get totalUsers; bool get hasNext; bool get hasPrev;
/// Create a copy of XpLeaderboardPagination
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$XpLeaderboardPaginationCopyWith<XpLeaderboardPagination> get copyWith => _$XpLeaderboardPaginationCopyWithImpl<XpLeaderboardPagination>(this as XpLeaderboardPagination, _$identity);

  /// Serializes this XpLeaderboardPagination to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is XpLeaderboardPagination&&(identical(other.currentPage, currentPage) || other.currentPage == currentPage)&&(identical(other.totalPages, totalPages) || other.totalPages == totalPages)&&(identical(other.totalUsers, totalUsers) || other.totalUsers == totalUsers)&&(identical(other.hasNext, hasNext) || other.hasNext == hasNext)&&(identical(other.hasPrev, hasPrev) || other.hasPrev == hasPrev));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,currentPage,totalPages,totalUsers,hasNext,hasPrev);

@override
String toString() {
  return 'XpLeaderboardPagination(currentPage: $currentPage, totalPages: $totalPages, totalUsers: $totalUsers, hasNext: $hasNext, hasPrev: $hasPrev)';
}


}

/// @nodoc
abstract mixin class $XpLeaderboardPaginationCopyWith<$Res>  {
  factory $XpLeaderboardPaginationCopyWith(XpLeaderboardPagination value, $Res Function(XpLeaderboardPagination) _then) = _$XpLeaderboardPaginationCopyWithImpl;
@useResult
$Res call({
 int currentPage, int totalPages, int totalUsers, bool hasNext, bool hasPrev
});




}
/// @nodoc
class _$XpLeaderboardPaginationCopyWithImpl<$Res>
    implements $XpLeaderboardPaginationCopyWith<$Res> {
  _$XpLeaderboardPaginationCopyWithImpl(this._self, this._then);

  final XpLeaderboardPagination _self;
  final $Res Function(XpLeaderboardPagination) _then;

/// Create a copy of XpLeaderboardPagination
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? currentPage = null,Object? totalPages = null,Object? totalUsers = null,Object? hasNext = null,Object? hasPrev = null,}) {
  return _then(_self.copyWith(
currentPage: null == currentPage ? _self.currentPage : currentPage // ignore: cast_nullable_to_non_nullable
as int,totalPages: null == totalPages ? _self.totalPages : totalPages // ignore: cast_nullable_to_non_nullable
as int,totalUsers: null == totalUsers ? _self.totalUsers : totalUsers // ignore: cast_nullable_to_non_nullable
as int,hasNext: null == hasNext ? _self.hasNext : hasNext // ignore: cast_nullable_to_non_nullable
as bool,hasPrev: null == hasPrev ? _self.hasPrev : hasPrev // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [XpLeaderboardPagination].
extension XpLeaderboardPaginationPatterns on XpLeaderboardPagination {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _XpLeaderboardPagination value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _XpLeaderboardPagination() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _XpLeaderboardPagination value)  $default,){
final _that = this;
switch (_that) {
case _XpLeaderboardPagination():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _XpLeaderboardPagination value)?  $default,){
final _that = this;
switch (_that) {
case _XpLeaderboardPagination() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int currentPage,  int totalPages,  int totalUsers,  bool hasNext,  bool hasPrev)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _XpLeaderboardPagination() when $default != null:
return $default(_that.currentPage,_that.totalPages,_that.totalUsers,_that.hasNext,_that.hasPrev);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int currentPage,  int totalPages,  int totalUsers,  bool hasNext,  bool hasPrev)  $default,) {final _that = this;
switch (_that) {
case _XpLeaderboardPagination():
return $default(_that.currentPage,_that.totalPages,_that.totalUsers,_that.hasNext,_that.hasPrev);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int currentPage,  int totalPages,  int totalUsers,  bool hasNext,  bool hasPrev)?  $default,) {final _that = this;
switch (_that) {
case _XpLeaderboardPagination() when $default != null:
return $default(_that.currentPage,_that.totalPages,_that.totalUsers,_that.hasNext,_that.hasPrev);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _XpLeaderboardPagination implements XpLeaderboardPagination {
  const _XpLeaderboardPagination({this.currentPage = 1, this.totalPages = 1, this.totalUsers = 0, this.hasNext = false, this.hasPrev = false});
  factory _XpLeaderboardPagination.fromJson(Map<String, dynamic> json) => _$XpLeaderboardPaginationFromJson(json);

@override@JsonKey() final  int currentPage;
@override@JsonKey() final  int totalPages;
@override@JsonKey() final  int totalUsers;
@override@JsonKey() final  bool hasNext;
@override@JsonKey() final  bool hasPrev;

/// Create a copy of XpLeaderboardPagination
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$XpLeaderboardPaginationCopyWith<_XpLeaderboardPagination> get copyWith => __$XpLeaderboardPaginationCopyWithImpl<_XpLeaderboardPagination>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$XpLeaderboardPaginationToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _XpLeaderboardPagination&&(identical(other.currentPage, currentPage) || other.currentPage == currentPage)&&(identical(other.totalPages, totalPages) || other.totalPages == totalPages)&&(identical(other.totalUsers, totalUsers) || other.totalUsers == totalUsers)&&(identical(other.hasNext, hasNext) || other.hasNext == hasNext)&&(identical(other.hasPrev, hasPrev) || other.hasPrev == hasPrev));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,currentPage,totalPages,totalUsers,hasNext,hasPrev);

@override
String toString() {
  return 'XpLeaderboardPagination(currentPage: $currentPage, totalPages: $totalPages, totalUsers: $totalUsers, hasNext: $hasNext, hasPrev: $hasPrev)';
}


}

/// @nodoc
abstract mixin class _$XpLeaderboardPaginationCopyWith<$Res> implements $XpLeaderboardPaginationCopyWith<$Res> {
  factory _$XpLeaderboardPaginationCopyWith(_XpLeaderboardPagination value, $Res Function(_XpLeaderboardPagination) _then) = __$XpLeaderboardPaginationCopyWithImpl;
@override @useResult
$Res call({
 int currentPage, int totalPages, int totalUsers, bool hasNext, bool hasPrev
});




}
/// @nodoc
class __$XpLeaderboardPaginationCopyWithImpl<$Res>
    implements _$XpLeaderboardPaginationCopyWith<$Res> {
  __$XpLeaderboardPaginationCopyWithImpl(this._self, this._then);

  final _XpLeaderboardPagination _self;
  final $Res Function(_XpLeaderboardPagination) _then;

/// Create a copy of XpLeaderboardPagination
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? currentPage = null,Object? totalPages = null,Object? totalUsers = null,Object? hasNext = null,Object? hasPrev = null,}) {
  return _then(_XpLeaderboardPagination(
currentPage: null == currentPage ? _self.currentPage : currentPage // ignore: cast_nullable_to_non_nullable
as int,totalPages: null == totalPages ? _self.totalPages : totalPages // ignore: cast_nullable_to_non_nullable
as int,totalUsers: null == totalUsers ? _self.totalUsers : totalUsers // ignore: cast_nullable_to_non_nullable
as int,hasNext: null == hasNext ? _self.hasNext : hasNext // ignore: cast_nullable_to_non_nullable
as bool,hasPrev: null == hasPrev ? _self.hasPrev : hasPrev // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on

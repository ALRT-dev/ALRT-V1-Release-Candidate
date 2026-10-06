import 'package:freezed_annotation/freezed_annotation.dart';

/// Base Either class
///
/// Receives two values [F] and [S]
/// as [F] is an failure and [S] is a success.
// @sealed
abstract class Either<S, F> {
  /// Default constructor.
  const Either();

  /// Returns the current Either.
  ///
  /// It may be a [Success] or an [Failure].
  /// Check with
  /// ```dart
  ///   Either.isSuccess();
  /// ```
  /// or
  /// ```dart
  ///   Either.isFailure();
  /// ```
  ///
  /// before casting the value;
  dynamic get();

  /// Returns the value of [S].
  S get success;

  /// Returns the value of [F].
  F get failure;

  /// Returns true if the current Either is an [Failure].
  bool get isFailure;

  /// Returns true if the current Either is a [Success].
  bool get isSuccess;

  /// Returns true if the current Either is an [Failure].
  bool get isRight;

  /// Returns true if the current Either is a [Success].
  bool get isLeft;

  /// Return the Either in one of these functions.
  ///
  /// if the Either is an failure, it will be returned in [whenFailure],
  /// if it is a success it will be returned in [whenSuccess].
  W when<W>(
    W Function(S success) whenSuccess,
    W Function(F failure) whenFailure,
  );

  /// Returns [whenSuccess] if the Either is a [Success].
  /// Otherwise, returns null.
  W? whenSuccess<W>(W? Function(S success) whenSuccess);

  /// Returns [whenFailure] if the Either is a [Failure].
  /// Otherwise, returns null.
  W? whenFailure<W>(W? Function(F failure) whenFailure);

  Either<S, F> copyWith<W>({S? Function(S)? success, F? Function(F)? failure}) {
    final succ = isFailure
        ? null
        : success != null
            ? success(this.success)
            : this.success;
    final fail = isSuccess
        ? null
        : failure != null
            ? failure(this.failure)
            : this.failure;

    if (succ != null) {
      return Success(succ);
    } else if (fail != null) {
      return Failure(fail);
    } else {
      throw Exception('You should pass either success or failure');
    }
  }
}

/// Success Either.
///
/// return it when the Either of a [Either] is
/// the expected value.
@immutable
class Success<S, F> implements Either<S, F> {
  /// Receives the [S] param as
  /// the successful Either.
  const Success(this._success);

  final S _success;

  @override
  S get() {
    return _success;
  }

  @override
  bool get isFailure => false;

  @override
  bool get isSuccess => true;

  @override
  bool get isRight => false;

  @override
  bool get isLeft => true;

  @override
  int get hashCode => _success.hashCode;

  @override
  bool operator ==(Object other) =>
      other is Success && other._success == _success;

  @override
  W when<W>(
    W Function(S success) whenSuccess,
    W Function(F failure) whenFailure,
  ) {
    return whenSuccess(_success);
  }

  @override
  F get failure =>
      throw Exception('Illegal use. You should check isFailure before calling');

  @override
  S get success => _success;

  @override
  W? whenSuccess<W>(W? Function(S success) whenSuccess) {
    return whenSuccess(_success);
  }

  @override
  W? whenFailure<W>(W? Function(F failure) whenFailure) {
    return null;
  }

  @override
  Either<S, F> copyWith<W>({S? Function(S)? success, F? Function(F)? failure}) {
    final succ = isFailure
        ? null
        : success != null
            ? success(this.success)
            : this.success;
    final fail = isSuccess
        ? null
        : failure != null
            ? failure(this.failure)
            : this.failure;

    if (succ != null) {
      return Success(succ);
    } else if (fail != null) {
      return Failure(fail);
    } else {
      throw Exception('You should pass either success or failure');
    }
  }
}

/// Failure Either.
///
/// return it when the Either of a [Either] is
/// not the expected value.
@immutable
class Failure<S, F> implements Either<S, F> {
  /// Receives the [F] param as
  /// the failure Either.
  const Failure(this._failure);

  final F _failure;

  @override
  F get() {
    return _failure;
  }

  @override
  bool get isFailure => true;

  @override
  bool get isSuccess => false;

  @override
  bool get isRight => true;

  @override
  bool get isLeft => false;

  @override
  int get hashCode => _failure.hashCode;

  @override
  bool operator ==(Object other) =>
      other is Failure && other._failure == _failure;

  @override
  W when<W>(
    W Function(S succcess) whenSuccess,
    W Function(F failure) whenFailure,
  ) {
    return whenFailure(_failure);
  }

  @override
  F get failure => _failure;

  @override
  S get success =>
      throw Exception('Illegal use. You should check isSuccess before calling');

  @override
  W? whenSuccess<W>(W? Function(S success) whenSuccess) {
    return null;
  }

  @override
  W? whenFailure<W>(W? Function(F failure) whenFailure) {
    return whenFailure(_failure);
  }

  @override
  Either<S, F> copyWith<W>({S? Function(S)? success, F? Function(F)? failure}) {
    final succ = isFailure
        ? null
        : success != null
            ? success(this.success)
            : this.success;
    final fail = isSuccess
        ? null
        : failure != null
            ? failure(this.failure)
            : this.failure;

    if (succ != null) {
      return Success(succ);
    } else if (fail != null) {
      return Failure(fail);
    } else {
      throw Exception('You should pass either success or failure');
    }
  }
}

/// Default success class.
///
/// Instead of returning void, as
/// ```dart
///   Either<Exception, void>
/// ```
/// return
/// ```dart
///   Either<Exception, SuccessEither>
/// ```
class SuccessEither {
  const SuccessEither._internal();
}

/// Default success case.
const success = SuccessEither._internal();

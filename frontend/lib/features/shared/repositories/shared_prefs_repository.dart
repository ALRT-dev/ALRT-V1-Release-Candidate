import 'package:hazard_app/features/shared/enums/shared_prefs_key_types.dart';
import 'package:hazard_app/features/shared/models/error_model.dart';
import 'package:hazard_app/features/shared/utils/async_call_helper.dart';
import 'package:hazard_app/features/shared/utils/either.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class SharedPreferencesRepository {
  Future<Either<void, AppError>> saveString({
    required SharedPrefsKey key,
    required String value,
  });

  Future<Either<String?, AppError>> getString({
    required SharedPrefsKey key,
  });

  Future<Either<void, AppError>> saveStringList({
    required SharedPrefsKey key,
    required List<String> value,
  });

  Future<Either<List<String>?, AppError>> getStringList({
    required SharedPrefsKey key,
  });

  Future<Either<void, AppError>> saveBool({
    required SharedPrefsKey key,
    required bool value,
  });

  Future<Either<bool?, AppError>> getBool({
    required SharedPrefsKey key,
  });

  Future<Either<void, AppError>> saveInt({
    required SharedPrefsKey key,
    required int value,
  });

  Future<Either<int?, AppError>> getInt({
    required SharedPrefsKey key,
  });

  Future<Either<void, AppError>> saveDouble({
    required SharedPrefsKey key,
    required double value,
  });

  Future<Either<double?, AppError>> getDouble({
    required SharedPrefsKey key,
  });

  Future<Either<void, AppError>> removeKey({
    required SharedPrefsKey key,
  });
}

class SharedPrefsRepositoryImpl implements SharedPreferencesRepository {
  SharedPrefsRepositoryImpl({
    required this.sharedPreferences,
  });

  final SharedPreferences sharedPreferences;

  @override
  Future<Either<void, AppError>> saveString({
    required SharedPrefsKey key,
    required String value,
  }) async {
    return runAsyncCall(
      name: 'saveString',
      future: () async {
        await sharedPreferences.setString(key.name, value);
        return Success(null);
      },
      onError: Failure.new,
    );
  }

  @override
  Future<Either<String?, AppError>> getString({
    required SharedPrefsKey key,
  }) async {
    return runAsyncCall(
      name: 'getString',
      future: () async {
        final value = sharedPreferences.getString(key.name);
        return Success(value);
      },
      onError: Failure.new,
    );
  }

  @override
  Future<Either<void, AppError>> saveStringList({
    required SharedPrefsKey key,
    required List<String> value,
  }) async {
    return runAsyncCall(
      name: 'saveStringList',
      future: () async {
        await sharedPreferences.setStringList(key.name, value);
        return Success(null);
      },
      onError: Failure.new,
    );
  }

  @override
  Future<Either<List<String>?, AppError>> getStringList({
    required SharedPrefsKey key,
  }) async {
    return runAsyncCall(
      name: 'getStringList',
      future: () async {
        final value = sharedPreferences.getStringList(key.name);
        return Success(value);
      },
      onError: Failure.new,
    );
  }

  @override
  Future<Either<void, AppError>> saveBool({
    required SharedPrefsKey key,
    required bool value,
  }) async {
    return runAsyncCall(
      name: 'saveBool',
      future: () async {
        await sharedPreferences.setBool(key.name, value);
        return Success(null);
      },
      onError: Failure.new,
    );
  }

  @override
  Future<Either<bool?, AppError>> getBool({
    required SharedPrefsKey key,
  }) async {
    return runAsyncCall(
      name: 'getBool',
      future: () async {
        final value = sharedPreferences.getBool(key.name);
        return Success(value);
      },
      onError: Failure.new,
    );
  }

  @override
  Future<Either<void, AppError>> saveInt({
    required SharedPrefsKey key,
    required int value,
  }) async {
    return runAsyncCall(
      name: 'saveInt',
      future: () async {
        await sharedPreferences.setInt(key.name, value);
        return Success(null);
      },
      onError: Failure.new,
    );
  }

  @override
  Future<Either<int?, AppError>> getInt({
    required SharedPrefsKey key,
  }) async {
    return runAsyncCall(
      name: 'getInt',
      future: () async {
        final value = sharedPreferences.getInt(key.name);
        return Success(value);
      },
      onError: Failure.new,
    );
  }

  @override
  Future<Either<void, AppError>> saveDouble({
    required SharedPrefsKey key,
    required double value,
  }) async {
    return runAsyncCall(
      name: 'saveDouble',
      future: () async {
        await sharedPreferences.setDouble(key.name, value);
        return Success(null);
      },
      onError: Failure.new,
    );
  }

  @override
  Future<Either<double?, AppError>> getDouble({
    required SharedPrefsKey key,
  }) async {
    return runAsyncCall(
      name: 'getDouble',
      future: () async {
        final value = sharedPreferences.getDouble(key.name);
        return Success(value);
      },
      onError: Failure.new,
    );
  }

  @override
  Future<Either<void, AppError>> removeKey({
    required SharedPrefsKey key,
  }) {
    return runAsyncCall(
      name: 'removeKey',
      future: () async {
        await sharedPreferences.remove(key.name);
        return Success(null);
      },
      onError: Failure.new,
    );
  }
}

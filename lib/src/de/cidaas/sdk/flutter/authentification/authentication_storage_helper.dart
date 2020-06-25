import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import './../entity/token_entity.dart';

/// The AuthStorageHelper
///
/// Encapsulates the required logic to store the [TokenEntity] inside the
/// flutter_secure_storage
class AuthStorageHelper {
  static const String ACCESS_TOKEN = 'access_token';
  static const String SUB = 'sub';
  static const String ID_TOKEN = 'id_token';
  static const String REFRESH_TOKEN = 'refresh_token';

  static AuthStorageHelper _instance;
  static FlutterSecureStorage _storage;

  /// Factory returns Singleton AuthStorageHelper
  ///
  /// if [storage] is given upon first creation, uses this FlutterSecureStorage
  /// if not, creates a new one
  factory AuthStorageHelper({FlutterSecureStorage storage}) {
    if (AuthStorageHelper._instance != null) {
      return AuthStorageHelper._instance;
    } else {
      return AuthStorageHelper._internal(storage: storage);
    }
  }

  /// Internal constr.
  AuthStorageHelper._internal({FlutterSecureStorage storage}) {
    if (storage == null) {
      _storage = const FlutterSecureStorage();
    } else {
      _storage = storage;
    }
    _instance = this;
  }

  Future<void> deleteToken() async {
    await _storage.delete(key: SUB);
    await _storage.delete(key: ACCESS_TOKEN);
    await _storage.delete(key: ID_TOKEN);
    await _storage.delete(key: REFRESH_TOKEN);
    return;
  }

  Future<void> persistTokenEntity(TokenEntity tokenEntity) async {
    if (tokenEntity.sub != null) {
      await _storage.write(key: SUB, value: tokenEntity.sub);
    }
    if (tokenEntity.accessToken != null) {
      await _storage.write(key: ACCESS_TOKEN, value: tokenEntity.accessToken);
    }
    if (tokenEntity.idToken != null) {
      await _storage.write(key: ID_TOKEN, value: tokenEntity.idToken);
    }
    if (tokenEntity.refreshToken != null) {
      await _storage.write(key: REFRESH_TOKEN, value: tokenEntity.refreshToken);
    }
  }

  Future<TokenEntity> getCurrentToken() async {
    final String sub = await _storage.read(key: SUB);
    final String accessToken = await _storage.read(key: ACCESS_TOKEN);
    final String idToken = await _storage.read(key: ID_TOKEN);
    final String refreshToken = await _storage.read(key: REFRESH_TOKEN);
    return TokenEntity(
        accessToken: accessToken,
        idToken: idToken,
        sub: sub,
        refreshToken: refreshToken);
  }

  void close() {
    _instance = null;
    _storage = null;
  }
}

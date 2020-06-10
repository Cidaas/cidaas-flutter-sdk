import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import './../entity/token_entity.dart';

class AuthStorageHelper {
  static const String ACCESS_TOKEN = "access_token";
  static const String SUB = "sub";
  static const String ID_TOKEN = "id_token";
  static const String REFRESH_TOKEN = "refresh_token";

  static final AuthStorageHelper _instance = AuthStorageHelper._internal();

  factory AuthStorageHelper() => _instance;
  final storage = new FlutterSecureStorage();

  AuthStorageHelper._internal();

  Future<void> deleteToken() async {
    await storage.delete(key: SUB);
    await storage.delete(key: ACCESS_TOKEN);
    await storage.delete(key: ID_TOKEN);
    await storage.delete(key: REFRESH_TOKEN);
    return;
  }

  Future<bool> hasToken() async {
    String token = await storage.read(key: ACCESS_TOKEN);
    return token?.isNotEmpty ?? false;
  }

  Future<void> persistTokenEntity(TokenEntity tokenEntity) async {
    if (tokenEntity.sub != null) {
      await storage.write(key: SUB, value: tokenEntity.sub);
    }
    if (tokenEntity.accessToken != null) {
      await storage.write(key: ACCESS_TOKEN, value: tokenEntity.accessToken);
    }
    if (tokenEntity.idToken != null) {
      await storage.write(key: ID_TOKEN, value: tokenEntity.idToken);
    }
    if (tokenEntity.refreshToken != null) {
      await storage.write(key: REFRESH_TOKEN, value: tokenEntity.refreshToken);
    }
  }

  Future<bool> hasUser(String sub) async {
    String sub = await storage.read(key: SUB);
    return sub?.isNotEmpty ?? false;
  }

  Future<TokenEntity> getCurrentToken() async {
    String sub = await storage.read(key: SUB);
    String accessToken = await storage.read(key: ACCESS_TOKEN);
    String idToken = await storage.read(key: ID_TOKEN);
    String refreshToken = await storage.read(key: REFRESH_TOKEN);
    return new TokenEntity(
        accessToken: accessToken,
        idToken: idToken,
        sub: sub,
        refreshToken: refreshToken);
  }
}

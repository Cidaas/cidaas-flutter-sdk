import 'package:cidaassdkflutter/src/de/cidaas/sdk/flutter/entity/token_entity.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import './../entity/token_entity.dart';


class AuthHandler {

  static const String ACCESS_TOKEN= "access_token";
  static const String SUB= "sub";
  static const String ID_TOKEN= "id_token";
  static const String REFRESH_TOKEN= "refresh_token";

  static final AuthHandler _instance = AuthHandler._internal();
  factory AuthHandler() => _instance;
  final storage = new FlutterSecureStorage();

  AuthHandler._internal();

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
    await storage.write(key: SUB, value: tokenEntity.sub);
    await storage.write(key: ACCESS_TOKEN, value: tokenEntity.accessToken);
    await storage.write(key: ID_TOKEN, value: tokenEntity.idToken);
    await storage.write(key: REFRESH_TOKEN, value: tokenEntity.refreshToken);
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
    return new TokenEntity(accessToken: accessToken, idToken: idToken, sub: sub, refreshToken: refreshToken);
  }
}
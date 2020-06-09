import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';


class AuthHandler {

  static const String ACCESS_TOKEN= "access-token";

  static final AuthHandler _instance = AuthHandler._internal();
  factory AuthHandler() => _instance;
  final storage = new FlutterSecureStorage();

  AuthHandler._internal();

  Future<String> authenticate({
    @required String username,
    @required String password,
  }) async {
    await Future.delayed(Duration(seconds: 1));
    return 'token';
  }

  Future<void> deleteToken() async {
    await storage.delete(key: ACCESS_TOKEN);
    return;
  }

  Future<void> persistToken(String token) async {
    await storage.write(key: ACCESS_TOKEN, value: token);
    return;
  }

  Future<bool> hasToken() async {
    String token = await storage.read(key: ACCESS_TOKEN);
    return token?.isNotEmpty ?? false;
  }
}
import 'dart:convert';

import 'package:flutter/material.dart';

import 'database/login_db_helper.dart';
import 'entity/token_entity.dart';
import 'entity/user_info_entity.dart';
import 'http/http_helper.dart';


class CidaasLoginProvider with ChangeNotifier {
  TokenEntity _tokenEntity;

  static String baseUrl =
      "https://protection-free.cidaas.de";
  static String clientId =
      "50e09c48-30be-4c98-bf22-32c8e7a4e545";
  static String clientSecret =
      "cba5e313-d6a3-4501-88ec-eb0d308bfc23";
  static String scopes = "openid profile email phone offline_access";
  static String redirectUri =
      "https://protection-free.cidaas.de/apps-srv/ping";

  //check current this.accesstoken is available and not expired
  bool get isAuth {
    var assertionIsAuth = (token != null);
    return assertionIsAuth;
  }

  TokenEntity get tokenEntity => this._tokenEntity;

  // token return null if token is expired, else it returns a the accessToken as String
  String get token {
    if (_tokenEntity != null && _tokenEntity.accessToken != null) {
      //call cidaasprovider method - check accessToken valid
      var tokenInfo =
      CidaasLoginProvider.isAccessTokenExpired(_tokenEntity.accessToken);
      return (tokenInfo != null) ? _tokenEntity.accessToken : null;
    }
    return null;
  }

  // 1. checks if the available AccessToken is expired (<60sec)
  // 1.1. no access token is availabe --> return false
  // 1.2. the access token in DB is ok, then it should return the accessToken
  // 1.3. the access token in DB is expired --> renew via refreshtoken
  Future<bool> tryAutoLogin() async {
    TokenEntity entity = await CidaasLoginProvider.getCurrentAccessToken();
    if (entity != null) this._tokenEntity = entity;
    return (entity != null);
  }

  //// static methods
  static getLoginURL() {
    final _scopes = Uri.encodeComponent(scopes);
    final _redirectUri = Uri.encodeComponent(redirectUri);
    return '${CidaasLoginProvider.baseUrl}/authz-srv/authz?client_id=${CidaasLoginProvider.clientId}&response_type=code&scope=${_scopes}&redirect_uri=${_redirectUri}';
  }

  // returns the accessToken By Code for Login purpose
  Future<TokenEntity> getAccessTokenByCode(String code) async {
    try {
      final tokenResponse = await HTTPHelper.postData(
          url: "${CidaasLoginProvider.baseUrl}/token-srv/token",
          data: {
            "grant_type": "authorization_code",
            "client_id": CidaasLoginProvider.clientId,
            "client_secret": CidaasLoginProvider.clientSecret,
            "code": code,
            "redirect_uri": CidaasLoginProvider.redirectUri,
          },
          headers: {});
      if (tokenResponse != null) {
        final tokenEntity = TokenEntity.fromJson(tokenResponse);
        await LoginDBHelper.insert(tokenEntity);
        final idToken = tokenResponse["id_token"];
        final parsedInfo = await CidaasLoginProvider.parseToken(idToken);
        if (tokenEntity != null) this._tokenEntity = tokenEntity;
        return tokenEntity;
      }
    } catch (e) {
      print("Catch Block");
      print(e);
    }
    return null;
  }

  static bool inRefreshTokenOperation = false;
  static Future<TokenEntity> renewAccessTokenByRefreshToken(
      String refreshToken) async {
    try {
      inRefreshTokenOperation = true;
      final tokenResponse = await HTTPHelper.postData(
          url: "${CidaasLoginProvider.baseUrl}/token-srv/token",
          data: {
            "grant_type": "refresh_token",
            "client_id": CidaasLoginProvider.clientId,
            "client_secret": CidaasLoginProvider.clientSecret,
            "refresh_token": refreshToken,
            "redirect_uri": CidaasLoginProvider.redirectUri,
          },
          headers: {});
      inRefreshTokenOperation = false;
      if (tokenResponse != null) {
        final tokenEntity = TokenEntity.fromJson(tokenResponse);
        await LoginDBHelper.insert(tokenEntity);
        final idToken = tokenResponse["id_token"];
        final parsedInfo = await CidaasLoginProvider.parseToken(idToken);
        return tokenEntity;
      }
    } catch (e) {}
    inRefreshTokenOperation = false;
    return null;
  }

  static Future<bool> doLogout() async {
    try {
      final tokenInfo = await LoginDBHelper.getCurrentToken();

      await HTTPHelper.postData(
          url:
          "${CidaasLoginProvider.baseUrl}/session/end_session?access_token_hint=${tokenInfo.accessToken}");

      // Clear all local dbs
      //await UserDBHelper.deleteAllUser();
      await LoginDBHelper.deleteAllUser();

      return true;
    } catch (e) {}
    return null;
  }

  static String _decodeBase64(String str) {
    String output = str.replaceAll('-', '+').replaceAll('_', '/');

    switch (output.length % 4) {
      case 0:
        break;
      case 2:
        output += '==';
        break;
      case 3:
        output += '=';
        break;
      default:
        throw Exception('Illegal base64url string!"');
    }

    return utf8.decode(base64Url.decode(output));
  }

  //check if the overhanded accessToken is still valid, and does not expire in less than 60 seconds
  static dynamic isAccessTokenExpired(String accessToken) {
    final decClaimSet =
    CidaasLoginProvider._decodeBase64(accessToken.split(".")[1]);
    print(decClaimSet);
    var tokenInfo = json.decode(decClaimSet);
    final expiresAt =
    DateTime.fromMillisecondsSinceEpoch(tokenInfo['exp'] * 1000);
    Duration difference = expiresAt.difference(DateTime.now());
    return (difference.inSeconds < 60) ? null : tokenInfo;
  }

//return DBTokenEntity if available and not expired and baseUrl fits
//return Renewed Entity if refreshtoken is available, and call returned a value
// else return null
  static Future<TokenEntity> getCurrentAccessToken() async {
    TokenEntity dbEntity = await LoginDBHelper.getCurrentToken();
    if (dbEntity == null) return null;
    var tokenInfo = isAccessTokenExpired(dbEntity.accessToken);
    if (tokenInfo != null && tokenInfo['iss'] != CidaasLoginProvider.baseUrl) {
      // Clear all local dbs
      await LoginDBHelper.deleteAllUser();
      return null;
    } else if (tokenInfo != null) {
      return dbEntity;
    } else {
      var newEntity = await CidaasLoginProvider.renewAccessTokenByRefreshToken(
          dbEntity.refreshToken);
      return newEntity;
    }
  }

  static Future<UserInfoEntity> parseToken(String token) async {
    final decClaimSet = _decodeBase64(token.split(".")[1]);
    print(decClaimSet);
    final tokenInfo = json.decode(decClaimSet);
    if (tokenInfo != null && tokenInfo['iss'] != CidaasLoginProvider.baseUrl) {
      // Clear all local dbs
      await LoginDBHelper.deleteAllUser();
      return null;
    } else {
      var tokInfo = UserInfoEntity.fromJson(tokenInfo);
      return tokInfo;
    }
  }
}

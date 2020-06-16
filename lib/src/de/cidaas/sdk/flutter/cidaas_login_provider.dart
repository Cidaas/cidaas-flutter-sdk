import 'dart:convert';
import 'dart:io';
import 'authentification/authentication_storage_helper.dart';
import 'entity/token_entity.dart';
import 'http/http_helper.dart';
import './authentification/authentication_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CidaasLoginProvider {
  static final AuthStorageHelper _authStorageHelper = AuthStorageHelper();

  static String baseUrl = "https://nightlybuild.cidaas.de";
  static String clientId = "07c4e2dd-cf5b-4c82-9fc9-67da2edacfa7";
  static String clientSecret = "faebad89-ee5e-4b03-8f50-69975f80bee6";
  static String scopes = "openid profile email";
  static String redirectUri = "https://nightlybuild.cidaas.de/apps-srv/ping";

  //check current this.accesstoken is available and not expired
  static Future<bool> get isAuth async {
    var assertionIsAuth = (await token != null);
    return assertionIsAuth;
  }

  // token return null if token is expired, else it returns a the accessToken as String
  static Future<String> get token async {
    TokenEntity _tokenEntity = await getStoredAccessToken();
    print("Token in get Token " + _tokenEntity.toString());
    if (_tokenEntity != null && (_tokenEntity.accessToken != null && _tokenEntity.accessToken.isNotEmpty || _tokenEntity.idToken != null && _tokenEntity.idToken.isNotEmpty)) {
      //call cidaasprovider method - check accessToken valid
      var tokenInfo =
          CidaasLoginProvider.isAccessTokenExpired(_tokenEntity.accessToken);
      return (tokenInfo != null) ? _tokenEntity.accessToken : null;
    }
    return null;
  }

  //// static methods
  static getLoginURL() {
    final _scopes = Uri.encodeComponent(scopes);
    final _redirectUri = Uri.encodeComponent(redirectUri);
    return '${CidaasLoginProvider.baseUrl}/authz-srv/authz?client_id=${CidaasLoginProvider.clientId}&response_type=code&scope=${_scopes}&redirect_uri=${_redirectUri}';
  }

  // returns the accessToken By Code for Login purpose
  static Future<TokenEntity> getAccessTokenByCode(String code) async {
    print("Start getAccessTokenByCode with code: " + code);
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
      print("TokenResponse in getAccessTokenByCode: " + tokenResponse.toString());
      if (tokenResponse != null) {
        final tokenEntity = TokenEntity.fromJson(tokenResponse);
        await _authStorageHelper.persistTokenEntity(tokenEntity);
        return tokenEntity;
      }
    } catch (e) {
      print("get Access Token By Code threw error");
      print(e);
    }
    return null;
  }

  static Future<TokenEntity> renewAccessTokenByRefreshToken(
      String refreshToken) async {
    try {
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
      if (tokenResponse != null) {
        final tokenEntity = TokenEntity.fromJson(tokenResponse);
        await _authStorageHelper.persistTokenEntity(tokenEntity);
        return tokenEntity;
      }
    } catch (e) {}
    return null;
  }

  static void doLogin(context) async {
    BlocProvider.of<AuthenticationBloc>(context)
        .add(AuthenticationStartedEvent());
  }

  static Future<bool> doLogout(context) async {
    try {
      final tokenInfo = await _authStorageHelper.getCurrentToken();

      await HTTPHelper.postData(
          url:
              "${CidaasLoginProvider.baseUrl}/session/end_session?access_token_hint=${tokenInfo.accessToken}");

      // Clear all local dbs
      await _authStorageHelper.deleteToken();
      BlocProvider.of<AuthenticationBloc>(context)
          .add(AuthenticationLoggedOutEvent());

      return true;
    } catch (e) {
      stderr.addError("Log out failed: ", e);
    }
    return false;
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

  //check if the given accessToken is still valid, and does not expire in less than 60 seconds
  static dynamic isAccessTokenExpired(String accessToken) {
    if (accessToken == null) {
      print("access token is null");
      return null;
    }
    final decClaimSet =
        CidaasLoginProvider._decodeBase64(accessToken.split(".")[1]);
    print("isAccessTokenExpired: " + decClaimSet);
    var tokenInfo = json.decode(decClaimSet);
    final expiresAt =
        DateTime.fromMillisecondsSinceEpoch(tokenInfo['exp'] * 1000);
    Duration difference = expiresAt.difference(DateTime.now());
    return (difference.inSeconds < 60) ? null : tokenInfo;
  }

  /// return DBTokenEntity if available and not expired and baseUrl fits
  /// return Renewed Entity if refreshtoken is available, and call returned a value
  /// else return null
  static Future<TokenEntity> getStoredAccessToken() async {
    TokenEntity dbEntity = await _authStorageHelper.getCurrentToken();
    print("DBEntity in getStored AccessToken " + dbEntity.toString());
    if (dbEntity == null || dbEntity.accessToken == null || dbEntity.accessToken.isEmpty) return null;
    var tokenInfo = isAccessTokenExpired(dbEntity.accessToken);
    if (tokenInfo != null && tokenInfo['iss'] != CidaasLoginProvider.baseUrl) {
      // Clear all local dbs
      await _authStorageHelper.deleteToken();
      return null;
    } else if (tokenInfo != null) {
      return dbEntity;
    } else {
      var newEntity =
          await renewAccessTokenByRefreshToken(dbEntity.refreshToken);
      return newEntity;
    }
  }

  static Map<String, dynamic> getTokenClaimSetForToken(String token) {
    final decClaimSet = _decodeBase64(token.split(".")[1]);
    return json.decode(decClaimSet);
  }
}

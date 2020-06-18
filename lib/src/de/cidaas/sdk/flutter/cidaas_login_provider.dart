import 'dart:convert';
import 'dart:io';
import 'authentification/authentication_storage_helper.dart';
import 'entity/token_entity.dart';
import 'entity/cidaas_config.dart';
import 'entity/openid_configuration.dart';
import 'http/http_helper.dart';
import './authentification/authentication_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart' show rootBundle;

class CidaasLoginProvider {
  static final AuthStorageHelper _authStorageHelper = AuthStorageHelper();

  static CidaasConfig _cidaasConf;
  static OpenIdConfiguration _openIdConfiguration;

  static Future<OpenIdConfiguration> checkAndLoadConfig(
      {configDir = "assets/cidaas_config.json"}) async {
    if (_cidaasConf == null || _cidaasConf.baseUrl.isEmpty ||
        _openIdConfiguration == null ||
        _openIdConfiguration.authorizationEndpoint.isEmpty) {
      Map configMap = jsonDecode(await rootBundle.loadString(configDir));
      CidaasConfig conf = CidaasConfig.fromJson(configMap);
      if (conf.baseUrl == null) {
        throw("Error reading the cidaas baseURL from file: " + configDir);
      }
      if (conf.baseUrl.startsWith("http") && !conf.baseUrl.startsWith("https")) {
        //Don't get a token via http!
        throw("ConfigurationError: Please use 'https' in the baseURL instead of 'http'");
      }
      if (conf.clientId == null) {
        throw("clientId is not set in cidaas config: " + configDir);
      }
      if (conf.clientSecret == null) {
        throw("clientSecret is not set in cidaas config: " + configDir);
      }
      if (conf.redirectURI == null) {
        throw("redirectUri is not set in cidaas config: " + configDir);
      }
      _cidaasConf = conf;
      try {
        final configResponse = await HTTPHelper.getData(
            url: conf.wellKnownURI,
            headers: {});
        if (configResponse != null) {
          _openIdConfiguration = OpenIdConfiguration.fromJson(
              new Map<String, dynamic>.from(configResponse));
          return _openIdConfiguration;
        } else {
          throw("Response from well-known endpoint ${conf
              .wellKnownURI} is null!");
        }
      } catch (e) {
        throw("Could not get well known configuration from ${conf
            .wellKnownURI}! Error: ${e.toString()}");
      }
    }
    return _openIdConfiguration;
  }

  static Future<CidaasConfig> getCidaasConf() async {
    if (CidaasLoginProvider._cidaasConf != null) {
      return CidaasLoginProvider._cidaasConf;
    } else {
      await checkAndLoadConfig();
      return CidaasLoginProvider._cidaasConf;
    }
  }

  static Future<OpenIdConfiguration> getOpenIdConfiguration() async {
    if (CidaasLoginProvider._openIdConfiguration != null) {
      return CidaasLoginProvider._openIdConfiguration;
    } else {
      return await checkAndLoadConfig();
    }
  }

  //check current this.accesstoken is available and not expired
  static Future<bool> isAuth() async {
    bool _isAuth = (await getStoredAccessToken()) != null;
    return _isAuth;
  }

  //// static methods
  static Future<String> getLoginURL() async {
    OpenIdConfiguration conf = await checkAndLoadConfig();
    String _scopes;
    if (_cidaasConf.scopes != null && _cidaasConf.scopes.isNotEmpty) {
      _scopes = Uri.encodeComponent(_cidaasConf.scopes);
    }
    String _redirectUri;
    if (_cidaasConf.redirectURI != null && _cidaasConf.redirectURI.isNotEmpty) {
      _redirectUri = Uri.encodeComponent(_cidaasConf.redirectURI);
    }
    return '${conf.authorizationEndpoint}?client_id=${_cidaasConf
        .clientId}&response_type=code&scope=${_scopes}&redirect_uri=${_redirectUri}';
  }

  // returns the accessToken By Code for Login purpose
  static Future<TokenEntity> getAccessTokenByCode(String code) async {
    OpenIdConfiguration conf = await checkAndLoadConfig();
    try {
      final tokenResponse = await HTTPHelper.postData(
          url: "${conf.tokenEndpoint}",
          data: {
            "grant_type": "authorization_code",
            "client_id": _cidaasConf.clientId,
            "client_secret": _cidaasConf.clientSecret,
            "code": code,
            "redirect_uri": _cidaasConf.redirectURI,
          },
          headers: {});
      if (tokenResponse != null) {
        final tokenEntity = TokenEntity.fromJson(tokenResponse);
        await _authStorageHelper.persistTokenEntity(tokenEntity);
        return tokenEntity;
      }
    } catch (e) {
      throw(e);
    }
    return null;
  }

  static Future<TokenEntity> renewAccessTokenByRefreshToken(
      String refreshToken) async {
    try {
      OpenIdConfiguration conf = await checkAndLoadConfig();
      final tokenResponse = await HTTPHelper.postData(
          url: "${conf.tokenEndpoint}",
          data: {
            "grant_type": "refresh_token",
            "client_id": _cidaasConf.clientId,
            "client_secret": _cidaasConf.clientSecret,
            "refresh_token": refreshToken,
            "redirect_uri": _cidaasConf.redirectURI,
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
      OpenIdConfiguration conf = await checkAndLoadConfig();
      final tokenInfo = await _authStorageHelper.getCurrentToken();

      await HTTPHelper.postData(
          url:
          "${conf.endSessionEndpoint}?access_token_hint=${tokenInfo
              .accessToken}");

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
      return null;
    }
    final decClaimSet =
    CidaasLoginProvider._decodeBase64(accessToken.split(".")[1]);
    var tokenInfo = json.decode(decClaimSet);
    final expiresAt =
    DateTime.fromMillisecondsSinceEpoch(tokenInfo['exp'] * 1000);
    Duration difference = expiresAt.difference(DateTime.now());
    return (difference.inSeconds < 60) ? null : tokenInfo;
  }

  /// Returns the stored access_token if it is valid.
  /// If the token is expired it will try to get a new access_token via the stored refresh_token.
  /// If no token is stored, returns null
  static Future<TokenEntity> getStoredAccessToken() async {
    TokenEntity dbEntity = await _authStorageHelper.getCurrentToken();
    if (dbEntity == null || (dbEntity.accessToken == null ||
        dbEntity.accessToken.isEmpty)) {
      return null;
    }
    var tokenInfo = isAccessTokenExpired(dbEntity.accessToken);
    await checkAndLoadConfig(); //_cidaasConf must be set
    if (tokenInfo == null) {
      //tokenInfo = null -> renew Access token
      var newEntity =
      await renewAccessTokenByRefreshToken(dbEntity.refreshToken);
      return newEntity;
    } else if (tokenInfo['iss'] != _cidaasConf.baseUrl) {
      // Clear all local dbs
      await _authStorageHelper.deleteToken();
      return null;
    } else {
      //token Info is set-> token is valid
      return dbEntity;
    }
  }

  /// Returns the claim set for the provided token
  /// To be used with the received id_token or access token
  static Map<String, dynamic> getTokenClaimSetForToken(String token) {
    final decClaimSet = _decodeBase64(token.split(".")[1]);
    return json.decode(decClaimSet);
  }
}

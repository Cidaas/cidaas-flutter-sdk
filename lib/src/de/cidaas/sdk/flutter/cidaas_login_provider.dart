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

  static Future<OpenIdConfiguration> checkAndLoadConfig({configDir = "assets/cidaas_config.json"}) async {
    print("Start load config");
    if (_cidaasConf == null || _cidaasConf.baseUrl.isEmpty || _openIdConfiguration == null || _openIdConfiguration.authorizationEndpoint.isEmpty) {
      Map configMap = jsonDecode(await rootBundle.loadString(configDir));
      CidaasConfig conf = CidaasConfig.fromJson(configMap);
      if (conf.baseUrl == null) {
        throw("Error reading the cidaas baseURL from file: " + configDir);
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
      print("Loaded cidaas config: " + conf.toString());
      try {
        final configResponse = await HTTPHelper.getData(
            url: conf.wellKnownURI,
            headers: {});
        print("Well-Known config response: " + configResponse.toString());
        if (configResponse != null) {
          _openIdConfiguration = OpenIdConfiguration.fromJson(new Map<String, dynamic>.from(configResponse));
          print(_openIdConfiguration.toString());
          return _openIdConfiguration;
        } else {
          throw("Response from well-known endpoint ${conf.wellKnownURI} is null!");
        }
      } catch (e) {
        throw("Could not get well known configuration from ${conf.wellKnownURI}! Error: ${e.toString()}");
      }
    }
    return _openIdConfiguration;
  }

  static Future<CidaasConfig> getCidaasConf() async{
    if (CidaasLoginProvider._cidaasConf != null) {
      return CidaasLoginProvider._cidaasConf;
    } else {
      await checkAndLoadConfig();
      return CidaasLoginProvider._cidaasConf;
    }
  }

  static Future<OpenIdConfiguration> getOpenIdConfiguration() async{
    if (CidaasLoginProvider._openIdConfiguration != null) {
      return CidaasLoginProvider._openIdConfiguration;
    } else {
      return await checkAndLoadConfig();
    }
  }

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
  static Future<String> getLoginURL() async {
    OpenIdConfiguration conf = await checkAndLoadConfig();
    print(conf.toString());
    String _scopes;
    if (_cidaasConf.scopes != null && _cidaasConf.scopes.isNotEmpty) {
      _scopes = Uri.encodeComponent(_cidaasConf.scopes);
    }
    String _redirectUri;
    if (_cidaasConf.redirectURI != null && _cidaasConf.redirectURI.isNotEmpty) {
      _redirectUri = Uri.encodeComponent(_cidaasConf.redirectURI);
    }
    return '${conf.authorizationEndpoint}?client_id=${_cidaasConf.clientId}&response_type=code&scope=${_scopes}&redirect_uri=${_redirectUri}';
  }

  // returns the accessToken By Code for Login purpose
  static Future<TokenEntity> getAccessTokenByCode(String code) async {
    print("Start getAccessTokenByCode with code: " + code);
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
              "${conf.endSessionEndpoint}?access_token_hint=${tokenInfo.accessToken}");

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
    await checkAndLoadConfig(); //_cidaasConf must be set
    if (tokenInfo != null && tokenInfo['iss'] != _cidaasConf.baseUrl) {
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

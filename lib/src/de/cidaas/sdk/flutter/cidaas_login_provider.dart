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

/// Provides static methods so a user can authenticate himself
class CidaasLoginProvider {
  static final AuthStorageHelper _authStorageHelper = AuthStorageHelper();

  static CidaasConfig _cidaasConf;
  static OpenIdConfiguration _openIdConfiguration;

  /// loads the config file from "assets/cidaas_config.json" or from the provided [configPath] config path
  ///
  /// If the config is already loaded does nothing.
  /// Checks the provided config file for the necessary fields
  /// Gets & sets the oauth2 well-known-openId configuration for your cidaas instance
  static Future<OpenIdConfiguration> checkAndLoadConfig(
      {configPath = "assets/cidaas_config.json"}) async {
    if (configPath == null) {
      // Dart's default values do not get set when passing null
      configPath = "assets/cidaas_config.json";
    }
    if (_cidaasConf == null || _cidaasConf.baseUrl.isEmpty ||
        _openIdConfiguration == null ||
        _openIdConfiguration.authorizationEndpoint.isEmpty) {
      Map configMap;
      try {
        configMap = jsonDecode(await rootBundle.loadString(configPath));
      } catch (e) {
        throw ConfigurationError("Could not load cidaas config from path: " + configPath.toString());
      }
      CidaasConfig conf = CidaasConfig.fromJson(configMap);
      if (conf.baseUrl == null) {
        throw ConfigurationError("Error reading the cidaas baseURL from file: " + configPath.toString());
      }
      if (conf.baseUrl.startsWith("http") && !conf.baseUrl.startsWith("https")) {
        //Don't get a token via http!
        throw ConfigurationError("Please use 'https' in the baseURL instead of 'http'. Config loaded: " + configPath.toString());
      }
      if (conf.clientId == null) {
        throw ConfigurationError("clientId is not set in cidaas config: " + configPath.toString());
      }
      if (conf.clientSecret == null) {
        throw ConfigurationError("clientSecret is not set in cidaas config: " + configPath.toString());
      }
      if (conf.redirectURI == null) {
        throw ConfigurationError("redirectUri is not set in cidaas config: " + configPath.toString());
      }
      _cidaasConf = conf;
      try {
        final configResponse = await HTTPHelper.getData(
            url: conf.wellKnownURI,
            headers: {});
        if (configResponse != null) {
          _openIdConfiguration = OpenIdConfiguration.fromJson(configResponse);
          return _openIdConfiguration;
        } else {
          throw WellKnownOpenIdConfigLoadError("Response from well-known endpoint ${conf
              .wellKnownURI} is null!");
        }
      } on WellKnownOpenIdConfigLoadError catch(e) {
        rethrow;
      } catch (e, s) {
        throw WellKnownOpenIdConfigLoadError("Could not get well known configuration from ${conf
            .wellKnownURI}! Error: ${e.toString()}" + s.toString());
      }
    }
    return _openIdConfiguration;
  }

  /// Returns the loaded cidaas configuration
  ///
  /// If no configuration has been loaded before, will load the configuration from the cidaas_config.json file
  /// In this case, if [configPath] is provided it will load it from this directory
  static Future<CidaasConfig> getCidaasConf({configPath}) async {
    if (CidaasLoginProvider._cidaasConf != null) {
      return CidaasLoginProvider._cidaasConf;
    } else {
      await checkAndLoadConfig(configPath: configPath);
      return CidaasLoginProvider._cidaasConf;
    }
  }

  /// Returns the loaded openId configuration
  ///
  /// If no configuration has been loaded before, will load the configuration from the cidaas_config.json file
  /// and fetch the well-known openId configuration from your cidaas instance.
  /// In this case, if [configPath] is provided it will load the cidaas_config.json from the provided [configPath]
  static Future<OpenIdConfiguration> getOpenIdConfiguration({configDir}) async {
    if (CidaasLoginProvider._openIdConfiguration != null) {
      return CidaasLoginProvider._openIdConfiguration;
    } else {
      return await checkAndLoadConfig(configPath: configDir);
    }
  }

  /// Check if the access_token is available & not expired
  static Future<bool> isAuth() async {
    bool _isAuth = (await getStoredAccessToken()) != null;
    return _isAuth;
  }

  /// Returns the login URL
  ///
  /// In detail, builds the loginUrl from the provided scopes, redirectUri & client_id
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

  /// returns the accessToken by the given [code]
  ///
  /// calls cidaas to obtain the access_token & persists it via flutter_secure_storage
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

  /// Refreshes the access_token by the given [refreshToken]
  ///
  /// Returns the updated [TokenEntity]
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
      } else {
        return null;
      }
    } catch (e) {}
    return null;
  }

  /// Starts the login process
  ///
  /// The [AuthenticationBloc] must be included in the given [context]
  static void doLogin(context) async {
    BlocProvider.of<AuthenticationBloc>(context)
        .add(AuthenticationStartedEvent());
  }

  /// Starts the logout process
  ///
  /// The [AuthenticationBloc] must be included in the given [context]
  /// Clears the flutter_secure_storage, returns true if successful
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

  /// Decodes the given base64 string [str]
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

  /// Check if the given [accessToken] does not expire in less than 60 seconds (or is already expired)
  static dynamic isAccessTokenExpired(String accessToken) {
    if (accessToken == null || accessToken.split(".").length != 3) {
      //Invalid access_token
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
  ///
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
  ///
  /// To be used with the received id_token or access token
  static Map<String, dynamic> getTokenClaimSetForToken(String token) {
    if (token.split(".").length != 3) {
      throw "Invalid Token: " + token;
    }
    final decClaimSet = _decodeBase64(token.split(".")[1]);
    return json.decode(decClaimSet);
  }

  /// Removes the loaded config
  static clearConfig() {
    _cidaasConf = null;
    _openIdConfiguration = null;
  }
}

class ConfigurationError implements Exception {
  String cause;
  ConfigurationError(this.cause);

  @override
  toString() {
    return "ConfigurationError: " + cause;
  }
}

class WellKnownOpenIdConfigLoadError implements Exception {
  String cause;
  WellKnownOpenIdConfigLoadError(this.cause);

  @override
  toString() {
    return "WellKnownOpenIdConfigLoadError: " + cause;
  }
}

import 'dart:async';
import 'package:cidaas_flutter_sdk/cidaas_flutter_sdk.dart';
import 'package:cidaas_flutter_sdk/src/de/cidaas/sdk/flutter/http/http_helper.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:cidaas_flutter_sdk/src/de/cidaas/sdk/flutter/authentification/authentication_storage_helper.dart';
import 'package:cidaas_flutter_sdk/src/de/cidaas/sdk/flutter/authentification/authentication_bloc.dart';
import 'package:http/http.dart' as http;

class MockStorageHelper extends Mock implements FlutterSecureStorage {}

class MockClient extends Mock implements http.Client {}

const String tokenNotIssuedByCidaas =
    'eyJhbGciOiJSUzI1NiIsImtpZCI6IjllYzFhNmIzLTNhMjUtNDEwMS1iY2RiLWFkN2U4MDVlMTFjZCJ9eyJ1YV9oYXNoIjoiM2I5N2RmNzMzMjc5ODA2OWVjNWI1YzgyNjkzNmQ1YzciLCJzaWQiOiJjNGI0ZGM2MC05NTgxLTRiMmYtYjljZC01ZGMxYmRlZWJjNDQiLCJzdWIiOiJBTk9OWU1PVVMiLCJhdWQiOiIwN2M0ZTJkZC1jZjViLTRjODItOWZjOS02N2RhMmVkYWNmYTciLCJpYXQiOjE1OTI5OTE5NDMsImF1dGhfdGltZSI6MTU5Mjk5MTk0MywiaXNzIjoibm90Q2lkYWFzIiwianRpIjoiMjg3ZmM3ZjctM2VkOS00NTc0LTg3MzMtMjRlMTlkZjU4YzY2Iiwic2NvcGVzIjpbIm9wZW5pZCIsInByb2ZpbGUiLCJlbWFpbCIsInBob25lIiwib2ZmbGluZV9hY2Nlc3MiXSwiZXhwIjoxNTkyOTkyMDEzfQh+14tUeA9eRWdGaCAXKkB7cgpPFE8+ZBtSeSsqN1xPOzNdPgZXUVlVdjMoKyEB3YR7CGUYCycJFT1maHwVVH8MPzY=';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CidaasLoginProvider tests, user is not logged in & correct config:', () {
    AuthenticationBloc authenticationBloc;

    setUp(() {
      final MockStorageHelper storage = MockStorageHelper();
      when(storage.write(key: AuthStorageHelper.ACCESS_TOKEN, value: AuthStorageHelper.ACCESS_TOKEN)).thenReturn(null);
      when(storage.write(key: AuthStorageHelper.SUB, value: AuthStorageHelper.SUB)).thenReturn(null);
      when(storage.write(key: AuthStorageHelper.ID_TOKEN, value: AuthStorageHelper.ID_TOKEN)).thenReturn(null);
      when(storage.write(key: AuthStorageHelper.REFRESH_TOKEN, value: AuthStorageHelper.REFRESH_TOKEN)).thenReturn(null);
      when(storage.read(key: AuthStorageHelper.ACCESS_TOKEN)).thenAnswer((_) => Future<String>(() => null));
      when(storage.read(key: AuthStorageHelper.SUB)).thenAnswer((_) => Future<String>(() => null));
      when(storage.read(key: AuthStorageHelper.ID_TOKEN)).thenAnswer((_) => Future<String>(() => null));
      when(storage.read(key: AuthStorageHelper.REFRESH_TOKEN)).thenAnswer((_) => Future<String>(() => null));
      authenticationBloc = AuthenticationBloc(secureStorage: storage);
      final MockClient httpMock = MockClient();
      const String jsonString =
          '{"issuer":"https://nightlybuild.cidaas.de","userinfo_endpoint":"https://nightlybuild.cidaas.de/users-srv/userinfo","authorization_endpoint":"https://nightlybuild.cidaas.de/authz-srv/authz","introspection_endpoint":"https://nightlybuild.cidaas.de/token-srv/introspect","introspection_async_update_endpoint":"https://nightlybuild.cidaas.de/token-srv/introspect/async/tokenusage","revocation_endpoint":"https://nightlybuild.cidaas.de/token-srv/revoke","token_endpoint":"https://nightlybuild.cidaas.de/token-srv/token","jwks_uri":"https://nightlybuild.cidaas.de/.well-known/jwks.json","check_session_iframe":"https://nightlybuild.cidaas.de/session/check_session","end_session_endpoint":"https://nightlybuild.cidaas.de/session/end_session","social_provider_token_resolver_endpoint":"https://nightlybuild.cidaas.de/login-srv/social/token","device_authorization_endpoint":"https://nightlybuild.cidaas.de/authz-srv/device/authz","subject_types_supported":["public"],"scopes_supported":["openid","profile","email","phone","address","offline_access","identities","roles","groups"],"response_types_supported":["code","token","id_token","code token","code id_token","token id_token","code token id_token"],"response_modes_supported":["query","fragment","form_post"],"grant_types_supported":["implicit","authorization_code","refresh_token","password","client_credentials"],"id_token_signing_alg_values_supported":["HS256","RS256"],"id_token_encryption_alg_values_supported":["RS256"],"id_token_encryption_enc_values_supported":["A128CBC-HS256"],"userinfo_signing_alg_values_supported":["HS256","RS256"],"userinfo_encryption_alg_values_supported":["RS256"],"userinfo_encryption_enc_values_supported":["A128CBC-HS256"],"request_object_signing_alg_values_supported":["HS256","RS256"],"request_object_encryption_alg_values_supported":["RS256"],"request_object_encryption_enc_values_supported":["A128CBC-HS256"],"token_endpoint_auth_methods_supported":["client_secret_basic","client_secret_post","client_secret_jwt","private_key_jwt"],"token_endpoint_auth_signing_alg_values_supported":["HS256","RS256"],"claims_supported":["aud","auth_time","created_at","email","email_verified","exp","family_name","given_name","iat","identities","iss","mobile_number","name","nickname","phone_number","picture","sub"],"claims_parameter_supported":false,"claim_types_supported":["normal"],"service_documentation":"https://docs.cidaas.de/","claims_locales_supported":["en-US"],"ui_locales_supported":["en-US","de-DE"],"display_values_supported":["page","popup"],"code_challenge_methods_supported":["plain","S256"],"request_parameter_supported":true,"request_uri_parameter_supported":true,"require_request_uri_registration":false,"op_policy_uri":"https://www.cidaas.com/privacy-policy/","op_tos_uri":"https://www.cidaas.com/terms-of-use/","scim_endpoint":"https://nightlybuild.cidaas.de/users-srv/scim/v2"}';
      when(httpMock.get('https://baseUrl.de/.well-known/openid-configuration', headers: anyNamed('headers')))
          .thenAnswer((_) => Future<http.Response>(() => http.Response(jsonString, 200)));
      when(httpMock.post('https://nightlybuild.cidaas.de/token-srv/token', headers: anyNamed('headers'), body: anyNamed('body')))
          .thenAnswer((_) => Future<http.Response>(() => http.Response(
              '{"access_token": "ReturnedAccessToken", "id_token": "ReturnedIdToken", "sub": "sub", "refresh_token": "refreshToken"}',
              200)));
      //Enable mock usage
      HTTPHelper(httpClient: httpMock);
    });

    tearDown(() {
      authenticationBloc?.close();
      CidaasLoginProvider.clearConfig();
    });

    test('load config & getConfig', () async {
      final OpenIdConfiguration idConfig = await CidaasLoginProvider.checkAndLoadConfig();
      expect(idConfig != null, true);
      expect(idConfig.issuer, 'https://nightlybuild.cidaas.de');
      final OpenIdConfiguration idConfigLater = await CidaasLoginProvider.getOpenIdConfiguration();
      expect(idConfigLater != null, true);
      expect(idConfigLater.issuer, 'https://nightlybuild.cidaas.de');
      final CidaasConfig cidaasConfig = await CidaasLoginProvider.getCidaasConf();
      expect(cidaasConfig != null, true);
      expect(cidaasConfig.baseUrl, 'https://baseUrl.de');
    });

    test('get CidaasConfig without preloading it', () async {
      final CidaasConfig cidaasConfig = await CidaasLoginProvider.getCidaasConf();
      expect(cidaasConfig != null, true);
      expect(cidaasConfig.baseUrl, 'https://baseUrl.de');
    });

    test('get OpenIdConfiguration without preloading it', () async {
      final OpenIdConfiguration idConfigLater = await CidaasLoginProvider.getOpenIdConfiguration();
      expect(idConfigLater != null, true);
      expect(idConfigLater.issuer, 'https://nightlybuild.cidaas.de');
    });

    test('get LoginUrl', () async {
      final String loginUrl = await CidaasLoginProvider.getLoginURL();
      expect(loginUrl != null, true);
      expect(
          loginUrl,
          'https://nightlybuild.cidaas.de/authz-srv/authz?client_id=clientId&response_type=code&scope=openid%20profile%20email%20offline_access&redirect_uri=https%3A%2F%2FredirectUri.de');
    });

    test('get access_token by code', () async {
      final TokenEntity tokenEntity = await CidaasLoginProvider.getAccessTokenByCode('code');
      expect(tokenEntity != null, true);
      expect(tokenEntity.accessToken, 'ReturnedAccessToken');
      expect(tokenEntity.idToken, 'ReturnedIdToken');
    });

    test('get renewAccessTokenByRefreshToken', () async {
      final TokenEntity tokenEntity = await CidaasLoginProvider.renewAccessTokenByRefreshToken('refreshToken');
      expect(tokenEntity != null, true);
      expect(tokenEntity.accessToken, 'ReturnedAccessToken');
      expect(tokenEntity.idToken, 'ReturnedIdToken');
    });
  }); //End mock group

  tearDown(() {
    CidaasLoginProvider.clearConfig();
  });

  test('get getTokenClaimSetForToken, invalid Token', () {
    runZoned(() {
      CidaasLoginProvider.getTokenClaimSetForToken('refreshToken');
    }, onError: expectAsync1((String e) {
      expect(e.toString(), 'Invalid Token: refreshToken');
    }));
  });

  test('get getTokenClaimSetForToken', () {
    final Map<String, dynamic> tokenClaims = CidaasLoginProvider.getTokenClaimSetForToken(
        'ey.eyJ1YV9oYXNoIjoiM2I5N2RmNzMzMjc5ODA2OWVjNWI1YzgyNjkzNmQ1YzciLCJzaWQiOiJjNGI0ZGM2MC05NTgxLTRiMmYtYjljZC01ZGMxYmRlZWJjNDQiLCJzdWIiOiJBTk9OWU1PVVMiLCJhdWQiOiIwN2M0ZTJkZC1jZjViLTRjODItOWZjOS02N2RhMmVkYWNmYTciLCJpYXQiOjE1OTI5OTE5NDMsImF1dGhfdGltZSI6MTU5Mjk5MTk0MywiaXNzIjoiaHR0cHM6Ly9uaWdodGx5YnVpbGQuY2lkYWFzLmRlIiwianRpIjoiMjg3ZmM3ZjctM2VkOS00NTc0LTg3MzMtMjRlMTlkZjU4YzY2Iiwic2NvcGVzIjpbIm9wZW5pZCIsInByb2ZpbGUiLCJlbWFpbCIsInBob25lIiwib2ZmbGluZV9hY2Nlc3MiXSwiZXhwIjoxNTkyOTkyMDEzfQ.h');
    expect(tokenClaims != null, true);
    expect(tokenClaims['scopes'][0], 'openid');
    expect(tokenClaims['iss'], 'https://nightlybuild.cidaas.de');
    expect(tokenClaims['sub'], 'ANONYMOUS');
  });

  test('load config with http instead https', () {
    runZoned(() {
      CidaasLoginProvider.checkAndLoadConfig(configPath: 'assets/cidaas_config_http.json');
    }, onError: expectAsync1((Exception e) {
      expect(e is ConfigurationError, true);
      expect(e.toString(),
          "ConfigurationError: Please use 'https' in the baseURL instead of 'http'. Config loaded: assets/cidaas_config_http.json");
    }));
  });

  test('load config without clientId', () {
    runZoned(() {
      CidaasLoginProvider.checkAndLoadConfig(configPath: 'assets/cidaas_config_without_clientId.json');
    }, onError: expectAsync1((Exception e) {
      expect(e is ConfigurationError, true);
      expect(
          e.toString(), 'ConfigurationError: clientId is not set in cidaas config: assets/cidaas_config_without_clientId.json');
    }));
  });

  test('load config without clientSecret', () {
    runZoned(() {
      CidaasLoginProvider.checkAndLoadConfig(configPath: 'assets/cidaas_config_without_clientSecret.json');
    }, onError: expectAsync1((Exception e) {
      expect(e is ConfigurationError, true);
      expect(e.toString(),
          'ConfigurationError: clientSecret is not set in cidaas config: assets/cidaas_config_without_clientSecret.json');
    }));
  });

  test('load config without redirectUri', () {
    runZoned(() {
      CidaasLoginProvider.checkAndLoadConfig(configPath: 'assets/cidaas_config_without_redirectUri.json');
    }, onError: expectAsync1((Exception e) {
      expect(e is ConfigurationError, true);
      expect(e.toString(),
          'ConfigurationError: redirectUri is not set in cidaas config: assets/cidaas_config_without_redirectUri.json');
    }));
  });

  test('load config without baseUrl', () {
    runZoned(() {
      CidaasLoginProvider.checkAndLoadConfig(configPath: 'assets/cidaas_config_without_baseUrl.json');
    }, onError: expectAsync1((Exception e) {
      expect(e is ConfigurationError, true);
      expect(e.toString(),
          'ConfigurationError: Error reading the cidaas baseURL from file: assets/cidaas_config_without_baseUrl.json');
    }));
  });

  test('config could not be loaded', () {
    runZoned(() {
      CidaasLoginProvider.checkAndLoadConfig(configPath: 'assets/cidaas_config_NotExisting_123456789.json');
    }, onError: expectAsync1((Exception e) {
      expect(e is ConfigurationError, true);
      expect(e.toString(),
          'ConfigurationError: Could not load cidaas config from path: assets/cidaas_config_NotExisting_123456789.json');
    }));
  });

  test('config is empty', () {
    runZoned(() {
      CidaasLoginProvider.checkAndLoadConfig(configPath: 'assets/cidaas_config_empty.json');
    }, onError: expectAsync1((Exception e) {
      expect(e is ConfigurationError, true);
      expect(e.toString(), 'ConfigurationError: Could not load cidaas config from path: assets/cidaas_config_empty.json');
    }));
  }); //End of mock group

  test('well-known openIdConfiguration response parse error', () {
    runZoned(() {
      final MockClient httpMock = MockClient();
      when(httpMock.get('https://baseUrl.de/.well-known/openid-configuration', headers: anyNamed('headers')))
          .thenAnswer((_) => Future<http.Response>(() => http.Response('.', 200)));
      //Enable mock usage
      HTTPHelper(httpClient: httpMock);
      CidaasLoginProvider.checkAndLoadConfig();
    }, onError: expectAsync1((Exception e) {
      expect(e is WellKnownOpenIdConfigLoadError, true);
      expect(
          e.toString().contains(
              'WellKnownOpenIdConfigLoadError: Could not get well known configuration from https://baseUrl.de/.well-known/openid-configuration! Error: FormatException: Unexpected character (at character 1)'),
          true);
    }));
  });

  test('well-known openIdConfiguration response is null', () {
    runZoned(() {
      final MockClient httpMock = MockClient();
      when(httpMock.get('https://baseUrl.de/.well-known/openid-configuration', headers: anyNamed('headers')))
          .thenAnswer((_) => Future<http.Response>(() => http.Response('', 500)));
      //Enable mock usage
      HTTPHelper(httpClient: httpMock);
      CidaasLoginProvider.checkAndLoadConfig();
    }, onError: expectAsync1((Exception e) {
      expect(e is WellKnownOpenIdConfigLoadError, true);
      expect(e.toString().contains('WellKnownOpenIdConfigLoadError: Response from well-known endpoint https://baseUrl.de/.well-known/openid-configuration is null!'),
          true);
    }));
  });
}

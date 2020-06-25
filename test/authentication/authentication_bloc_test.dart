import 'package:cidaas_flutter_sdk/cidaas_flutter_sdk.dart';
import 'package:cidaas_flutter_sdk/src/de/cidaas/sdk/flutter/http/http_helper.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'dart:async';
import 'package:mockito/mockito.dart';

import 'package:cidaas_flutter_sdk/src/de/cidaas/sdk/flutter/authentification/authentication_storage_helper.dart';
import 'package:cidaas_flutter_sdk/src/de/cidaas/sdk/flutter/authentification/authentication_bloc.dart';
import 'package:flutter/src/services/message_codec.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

class MockStorageHelper extends Mock implements FlutterSecureStorage {}
class MockClient extends Mock implements http.Client {}

const testToken = "ey.eyJ1YV9oYXNoIjoiM2I5N2RmNzMzMjc5ODA2OWVjNWI1YzgyNjkzNmQ1YzciLCJzaWQiOiJjNGI0ZGM2MC05NTgxLTRiMmYtYjljZC01ZGMxYmRlZWJjNDQiLCJzdWIiOiJBTk9OWU1PVVMiLCJhdWQiOiIwN2M0ZTJkZC1jZjViLTRjODItOWZjOS02N2RhMmVkYWNmYTciLCJpYXQiOjE1OTI5OTE5NDMsImF1dGhfdGltZSI6MTU5Mjk5MTk0MywiaXNzIjoiaHR0cHM6Ly9uaWdodGx5YnVpbGQuY2lkYWFzLmRlIiwianRpIjoiMjg3ZmM3ZjctM2VkOS00NTc0LTg3MzMtMjRlMTlkZjU4YzY2Iiwic2NvcGVzIjpbIm9wZW5pZCIsInByb2ZpbGUiLCJlbWFpbCIsInBob25lIiwib2ZmbGluZV9hY2Nlc3MiXSwiZXhwIjoxNTkyOTkyMDEzfQ.h";

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group("authenticationBloc tests with mocked secure storage, user not logged in:", () {
    AuthenticationBloc authenticationBloc;
    TokenEntity tokenEntity;

    setUp(() {
      var storage = new MockStorageHelper();
      when(storage.write(key: AuthStorageHelper.ACCESS_TOKEN, value: AuthStorageHelper.ACCESS_TOKEN)).thenReturn(null);
      when(storage.write(key: AuthStorageHelper.SUB, value: AuthStorageHelper.SUB)).thenReturn(null);
      when(storage.write(key: AuthStorageHelper.ID_TOKEN, value: AuthStorageHelper.ID_TOKEN)).thenReturn(null);
      when(storage.write(key: AuthStorageHelper.REFRESH_TOKEN, value: AuthStorageHelper.REFRESH_TOKEN)).thenReturn(null);
      when(storage.read(key: AuthStorageHelper.ACCESS_TOKEN)).thenAnswer((_) => Future<String>(() => null));
      when(storage.read(key: AuthStorageHelper.SUB)).thenAnswer((_) => Future<String>(() => null));
      when(storage.read(key: AuthStorageHelper.ID_TOKEN)).thenAnswer((_) => Future<String>(() => null));
      when(storage.read(key: AuthStorageHelper.REFRESH_TOKEN)).thenAnswer((_) => Future<String>(() => null));
      authenticationBloc = new AuthenticationBloc(secureStorage: storage);
      tokenEntity = new TokenEntity(accessToken: "accessToken", idToken: "idToken", sub: "sub", refreshToken: "refreshToken");
    });

    tearDown(() {
      authenticationBloc?.close();
    });

    test('initial state is correct', () {
      expect(authenticationBloc.initialState, AuthenticationHasLoggedOutState());
    });

    test('login event', () {
      final expectedResponse = [
        AuthenticationHasLoggedOutState(),
        AuthenticationInProgressState(),
        AuthenticationSuccessState(tokenEntity: tokenEntity)
      ];

      expectLater(
        authenticationBloc,
        emitsInOrder(expectedResponse),
      );

      AuthenticationLoggedInEvent loggedInEvent = AuthenticationLoggedInEvent(
        tokenEntity: tokenEntity,
      );

      authenticationBloc.add(loggedInEvent);
      expect(loggedInEvent.toString(), "AuthenticationLoggedInEvent { tokenEntity: TokenEntity {access_token: accessToken, id_token: idToken, sub: sub, refresh_token: refreshToken} }");
    });

    test('test AuthenticationStartedEvent', () {
        final expectedResponse = [
          AuthenticationHasLoggedOutState(),
          AuthenticationInProgressState(),
          AuthenticationShowLoginWithBrowserState()
        ];

        expectLater(
          authenticationBloc,
          emitsInOrder(expectedResponse),
        );

        authenticationBloc.add(AuthenticationStartedEvent());
    });

    test('close does not emit new states', () {
      expectLater(
        authenticationBloc,
        emitsInOrder([AuthenticationHasLoggedOutState(), emitsDone]),
      );
      authenticationBloc.close();
    });
  }); //End of mock group

  group("authenticationBloc tests with mocked secure storage, user is logged in:", () {
    AuthenticationBloc authenticationBloc;
    TokenEntity tokenEntity;
    MockStorageHelper storage = new MockStorageHelper();

    setUp(() {
      const String ACCESS_TOKEN = "access_token";
      const String SUB = "sub";
      const String ID_TOKEN = "id_token";
      const String REFRESH_TOKEN = "refresh_token";
      when(storage.write(key: ACCESS_TOKEN, value: ACCESS_TOKEN)).thenReturn(null);
      when(storage.write(key: SUB, value: SUB)).thenReturn(null);
      when(storage.write(key: ID_TOKEN, value: ID_TOKEN)).thenReturn(null);
      when(storage.write(key: REFRESH_TOKEN, value: REFRESH_TOKEN)).thenReturn(null);
      when(storage.read(key: AuthStorageHelper.ACCESS_TOKEN)).thenAnswer((_) => Future<String>(() => testToken));
      when(storage.read(key: AuthStorageHelper.SUB)).thenAnswer((_) => Future<String>(() => AuthStorageHelper.SUB));
      when(storage.read(key: AuthStorageHelper.ID_TOKEN)).thenAnswer((_) => Future<String>(() => AuthStorageHelper.ID_TOKEN));
      when(storage.read(key: AuthStorageHelper.REFRESH_TOKEN)).thenAnswer((_) => Future<String>(() => AuthStorageHelper.REFRESH_TOKEN));
      authenticationBloc = new AuthenticationBloc(secureStorage: storage);
      tokenEntity = new TokenEntity(accessToken: testToken, idToken: "idToken", sub: "sub", refreshToken: "refreshToken");
      var httpMock = new MockClient();
      String jsonString = '{"issuer":"https://nightlybuild.cidaas.de","userinfo_endpoint":"https://nightlybuild.cidaas.de/users-srv/userinfo","authorization_endpoint":"https://nightlybuild.cidaas.de/authz-srv/authz","introspection_endpoint":"https://nightlybuild.cidaas.de/token-srv/introspect","introspection_async_update_endpoint":"https://nightlybuild.cidaas.de/token-srv/introspect/async/tokenusage","revocation_endpoint":"https://nightlybuild.cidaas.de/token-srv/revoke","token_endpoint":"https://nightlybuild.cidaas.de/token-srv/token","jwks_uri":"https://nightlybuild.cidaas.de/.well-known/jwks.json","check_session_iframe":"https://nightlybuild.cidaas.de/session/check_session","end_session_endpoint":"https://nightlybuild.cidaas.de/session/end_session","social_provider_token_resolver_endpoint":"https://nightlybuild.cidaas.de/login-srv/social/token","device_authorization_endpoint":"https://nightlybuild.cidaas.de/authz-srv/device/authz","subject_types_supported":["public"],"scopes_supported":["openid","profile","email","phone","address","offline_access","identities","roles","groups"],"response_types_supported":["code","token","id_token","code token","code id_token","token id_token","code token id_token"],"response_modes_supported":["query","fragment","form_post"],"grant_types_supported":["implicit","authorization_code","refresh_token","password","client_credentials"],"id_token_signing_alg_values_supported":["HS256","RS256"],"id_token_encryption_alg_values_supported":["RS256"],"id_token_encryption_enc_values_supported":["A128CBC-HS256"],"userinfo_signing_alg_values_supported":["HS256","RS256"],"userinfo_encryption_alg_values_supported":["RS256"],"userinfo_encryption_enc_values_supported":["A128CBC-HS256"],"request_object_signing_alg_values_supported":["HS256","RS256"],"request_object_encryption_alg_values_supported":["RS256"],"request_object_encryption_enc_values_supported":["A128CBC-HS256"],"token_endpoint_auth_methods_supported":["client_secret_basic","client_secret_post","client_secret_jwt","private_key_jwt"],"token_endpoint_auth_signing_alg_values_supported":["HS256","RS256"],"claims_supported":["aud","auth_time","created_at","email","email_verified","exp","family_name","given_name","iat","identities","iss","mobile_number","name","nickname","phone_number","picture","sub"],"claims_parameter_supported":false,"claim_types_supported":["normal"],"service_documentation":"https://docs.cidaas.de/","claims_locales_supported":["en-US"],"ui_locales_supported":["en-US","de-DE"],"display_values_supported":["page","popup"],"code_challenge_methods_supported":["plain","S256"],"request_parameter_supported":true,"request_uri_parameter_supported":true,"require_request_uri_registration":false,"op_policy_uri":"https://www.cidaas.com/privacy-policy/","op_tos_uri":"https://www.cidaas.com/terms-of-use/","scim_endpoint":"https://nightlybuild.cidaas.de/users-srv/scim/v2"}';
      when(httpMock.get("https://baseUrl.de/.well-known/openid-configuration", headers: anyNamed("headers"))).thenAnswer((_) => Future<http.Response>(() => http.Response(jsonString, 200)));
      //Enable mock usage
      new HTTPHelper(http: httpMock);
    });

    tearDown(() {
      authenticationBloc?.close();
    });

    test('test Authentication from StartedEvent to successful', () {
      AuthenticationSuccessState authSuccess = AuthenticationSuccessState(tokenEntity: tokenEntity);
      final expectedResponse = [
        AuthenticationHasLoggedOutState(),
        AuthenticationInProgressState(),
        AuthenticationShowLoginWithBrowserState(),
        AuthenticationInProgressState(),
        authSuccess
      ];

      expectLater(
        authenticationBloc,
        emitsInOrder(expectedResponse),
      );

      authenticationBloc.add(AuthenticationStartedEvent());
      authenticationBloc.add(AuthenticationLoggedInEvent(tokenEntity: tokenEntity));
      expect(authSuccess.token, tokenEntity);
      Future.delayed(Duration(milliseconds: 50)).then((value) => {
        expectAsync0(() {
          expect(CidaasLoginProvider.isAuth(), true);
        })
      });
    });

    test('test AuthenticationStartedEvent, no access_token received', () {
      String error = "Test error";
      final expectedResponse = [
        AuthenticationHasLoggedOutState(),
        AuthenticationInProgressState(),
        AuthenticationShowLoginWithBrowserState(),
        AuthenticationInProgressState(),
        AuthenticationFailureState(error: error)
      ];

      expectLater(
        authenticationBloc,
        emitsInOrder(expectedResponse),
      );

      authenticationBloc.add(AuthenticationStartedEvent());
      authenticationBloc.add(AuthenticationLoggedInEvent(tokenEntity: null));
    });

    test('test AuthenticationLogOutEvent', () {
      final expectedResponse = [
        AuthenticationHasLoggedOutState(),
        AuthenticationInProgressState(),
        AuthenticationHasLoggedOutState()
      ];

      expectLater(
        authenticationBloc,
        emitsInOrder(expectedResponse),
      );

      authenticationBloc.add(AuthenticationLoggedOutEvent());

      Future.delayed(Duration(milliseconds: 50)).then((value) => verify(storage.delete(key: anyNamed("key"))).called(4));
    });
  }); //End of mock group user is logged in

  test('AuthenticationBloc is using a new instance of FlutterSecureStorage if no storage is provided', () {
    AuthenticationBloc authenticationBloc;
    runZoned(() {
      authenticationBloc = new AuthenticationBloc();
      //expect(AuthStorageHelper.storage is FlutterSecureStorage, true);
      TokenEntity tokenEntity = new TokenEntity(accessToken: "accessToken", idToken: "idToken", sub: "sub", refreshToken: "refreshToken");
      authenticationBloc.add(AuthenticationLoggedInEvent(
        tokenEntity: tokenEntity,
      ));
    }, onError: expectAsync1((e) {
      //FlutterSecureStorage is throwing the MissingPluginException,
      // because it has different dependencies, whether you are on android or ios
      expect(e, isInstanceOf<BlocUnhandledErrorException>());
      expect(e.error, isInstanceOf<MissingPluginException>());
      authenticationBloc.close();
    }));
  });
}

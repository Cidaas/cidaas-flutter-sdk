import 'package:cidaassdkflutter/cidaassdkflutter.dart';
import 'package:cidaassdkflutter/src/de/cidaas/sdk/flutter/http/http_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'dart:async';
import 'package:mockito/mockito.dart';

import 'package:cidaassdkflutter/src/de/cidaas/sdk/flutter/authentification/authentication_storage_helper.dart';
import 'package:cidaassdkflutter/src/de/cidaas/sdk/flutter/authentification/authentication_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

class MockStorageHelper extends Mock implements FlutterSecureStorage {}

class MockClient extends Mock implements http.Client {}

const tokenNotIssuedByCidaas =
    "eyJhbGciOiJSUzI1NiIsImtpZCI6IjllYzFhNmIzLTNhMjUtNDEwMS1iY2RiLWFkN2U4MDVlMTFjZCJ9eyJ1YV9oYXNoIjoiM2I5N2RmNzMzMjc5ODA2OWVjNWI1YzgyNjkzNmQ1YzciLCJzaWQiOiJjNGI0ZGM2MC05NTgxLTRiMmYtYjljZC01ZGMxYmRlZWJjNDQiLCJzdWIiOiJBTk9OWU1PVVMiLCJhdWQiOiIwN2M0ZTJkZC1jZjViLTRjODItOWZjOS02N2RhMmVkYWNmYTciLCJpYXQiOjE1OTI5OTE5NDMsImF1dGhfdGltZSI6MTU5Mjk5MTk0MywiaXNzIjoibm90Q2lkYWFzIiwianRpIjoiMjg3ZmM3ZjctM2VkOS00NTc0LTg3MzMtMjRlMTlkZjU4YzY2Iiwic2NvcGVzIjpbIm9wZW5pZCIsInByb2ZpbGUiLCJlbWFpbCIsInBob25lIiwib2ZmbGluZV9hY2Nlc3MiXSwiZXhwIjoxNTkyOTkyMDEzfQh+14tUeA9eRWdGaCAXKkB7cgpPFE8+ZBtSeSsqN1xPOzNdPgZXUVlVdjMoKyEB3YR7CGUYCycJFT1maHwVVH8MPzY=";

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group("Cidaas abstract class tests, user is logged in & correct config:", () {
    AuthenticationBloc authenticationBloc;

    setUp(() {
      var storage = new MockStorageHelper();
      when(storage.write(key: anyNamed("key"), value: anyNamed("value"))).thenReturn(null);
      when(storage.read(key: AuthStorageHelper.ACCESS_TOKEN)).thenAnswer((_) => Future<String>(() => AuthStorageHelper.ACCESS_TOKEN));
      when(storage.read(key: AuthStorageHelper.SUB)).thenAnswer((_) => Future<String>(() => AuthStorageHelper.SUB));
      when(storage.read(key: AuthStorageHelper.ID_TOKEN)).thenAnswer((_) => Future<String>(() => AuthStorageHelper.ID_TOKEN));
      when(storage.read(key: AuthStorageHelper.REFRESH_TOKEN)).thenAnswer((_) => Future<String>(() => AuthStorageHelper.REFRESH_TOKEN));
      authenticationBloc = new AuthenticationBloc(secureStorage: storage);
      var httpMock = new MockClient();
      String jsonString =
          '{"issuer":"https://nightlybuild.cidaas.de","userinfo_endpoint":"https://nightlybuild.cidaas.de/users-srv/userinfo","authorization_endpoint":"https://nightlybuild.cidaas.de/authz-srv/authz","introspection_endpoint":"https://nightlybuild.cidaas.de/token-srv/introspect","introspection_async_update_endpoint":"https://nightlybuild.cidaas.de/token-srv/introspect/async/tokenusage","revocation_endpoint":"https://nightlybuild.cidaas.de/token-srv/revoke","token_endpoint":"https://nightlybuild.cidaas.de/token-srv/token","jwks_uri":"https://nightlybuild.cidaas.de/.well-known/jwks.json","check_session_iframe":"https://nightlybuild.cidaas.de/session/check_session","end_session_endpoint":"https://nightlybuild.cidaas.de/session/end_session","social_provider_token_resolver_endpoint":"https://nightlybuild.cidaas.de/login-srv/social/token","device_authorization_endpoint":"https://nightlybuild.cidaas.de/authz-srv/device/authz","subject_types_supported":["public"],"scopes_supported":["openid","profile","email","phone","address","offline_access","identities","roles","groups"],"response_types_supported":["code","token","id_token","code token","code id_token","token id_token","code token id_token"],"response_modes_supported":["query","fragment","form_post"],"grant_types_supported":["implicit","authorization_code","refresh_token","password","client_credentials"],"id_token_signing_alg_values_supported":["HS256","RS256"],"id_token_encryption_alg_values_supported":["RS256"],"id_token_encryption_enc_values_supported":["A128CBC-HS256"],"userinfo_signing_alg_values_supported":["HS256","RS256"],"userinfo_encryption_alg_values_supported":["RS256"],"userinfo_encryption_enc_values_supported":["A128CBC-HS256"],"request_object_signing_alg_values_supported":["HS256","RS256"],"request_object_encryption_alg_values_supported":["RS256"],"request_object_encryption_enc_values_supported":["A128CBC-HS256"],"token_endpoint_auth_methods_supported":["client_secret_basic","client_secret_post","client_secret_jwt","private_key_jwt"],"token_endpoint_auth_signing_alg_values_supported":["HS256","RS256"],"claims_supported":["aud","auth_time","created_at","email","email_verified","exp","family_name","given_name","iat","identities","iss","mobile_number","name","nickname","phone_number","picture","sub"],"claims_parameter_supported":false,"claim_types_supported":["normal"],"service_documentation":"https://docs.cidaas.de/","claims_locales_supported":["en-US"],"ui_locales_supported":["en-US","de-DE"],"display_values_supported":["page","popup"],"code_challenge_methods_supported":["plain","S256"],"request_parameter_supported":true,"request_uri_parameter_supported":true,"require_request_uri_registration":false,"op_policy_uri":"https://www.cidaas.com/privacy-policy/","op_tos_uri":"https://www.cidaas.com/terms-of-use/","scim_endpoint":"https://nightlybuild.cidaas.de/users-srv/scim/v2"}';
      when(httpMock.get("https://baseUrl.de/.well-known/openid-configuration", headers: anyNamed("headers")))
          .thenAnswer((_) => Future<http.Response>(() => http.Response(jsonString, 200)));
      when(httpMock.post("https://nightlybuild.cidaas.de/token-srv/token", headers: anyNamed("headers"), body: anyNamed("body")))
          .thenAnswer((_) => Future<http.Response>(() => http.Response(
              '{"access_token": "ReturnedAccessToken", "id_token": "ReturnedIdToken", "sub": "sub", "refresh_token": "refreshToken"}',
              200)));
      //Enable mock usage
      new HTTPHelper(http: httpMock);
    });

    tearDown(() {
      authenticationBloc?.close();
      CidaasLoginProvider.clearConfig();
    });

    testWidgets('Cidaas starts with LoggedOut Screen', (WidgetTester tester) async {
      await tester.pumpWidget(BlocProvider<AuthenticationBloc>(
        create: (context) {
          return authenticationBloc;
        },
        child: MaterialApp(
          home: Scaffold(
              appBar: AppBar(
                title: Text('App'),
              ),
              body: MyCidaasImpl()),
        ),
      ));
      final loggedOutScreenFinder = find.text('Login');

      // Use the `findsOneWidget` matcher provided by flutter_test to verify
      // that the Text widgets appear exactly once in the widget tree.
      expect(loggedOutScreenFinder, findsOneWidget);
    });
  }); //End mock group
}

class MyCidaasImpl extends Cidaas {
  @override
  Widget getLoggedInScreen({tokenEntity}) {
    return Text("LoggedInScreen");
  }

  @override
  Widget getSplashScreen() {
    return Center(
      //child: CircularProgressIndicator(),
      child: Text('Please wait'),
    );
  }

  @override
  Widget getLoggedOutScreen({context}) {
    return Center(
        child: RaisedButton(
      child: Text('Login'),
      onPressed: () {
        CidaasLoginProvider.doLogin(context);
      },
    ));
  }

  @override
  Widget getAuthenticationFailureScreen({errorMessage}) {
    return Scaffold(
        body: Center(
      child: Text('$errorMessage', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
    ));
  }
}

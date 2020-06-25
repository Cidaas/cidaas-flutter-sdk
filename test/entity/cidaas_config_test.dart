import 'dart:convert';
import 'package:cidaas_flutter_sdk/cidaas_flutter_sdk.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('cidaas_config', () {
    test('create the cidaas_config from json', () {
      const String jsonString =
          '{"baseUrl": "BASEURL", "clientId": "CLIENTID", "clientSecret": "CLIENTSECRET", "scopes": "SCOPES", "redirectUri": "REDIRECTURI"}';

      final CidaasConfig config = CidaasConfig.fromJson(json.decode(jsonString));
      expect(config.baseUrl, 'BASEURL');
      expect(config.clientId, 'CLIENTID');
      expect(config.clientSecret, 'CLIENTSECRET');
      expect(config.scopes, 'SCOPES');
      expect(config.redirectURI, 'REDIRECTURI');
      expect(config.wellKnownURI, 'BASEURL/.well-known/openid-configuration');
    });

    test('create the json from cidaas_config', () {
      final CidaasConfig config = CidaasConfig(
          baseUrl: 'BASEURL',
          clientId: 'CLIENTID',
          clientSecret: 'CLIENTSECRET',
          scopes: 'SCOPES',
          redirectURI: 'REDIRECTURI');

      final Map<String, dynamic> jsonMap = config.toJson();
      expect(jsonMap['baseUrl'], 'BASEURL');
      expect(jsonMap['clientId'], 'CLIENTID');
      expect(jsonMap['clientSecret'], 'CLIENTSECRET');
      expect(jsonMap['scopes'], 'SCOPES');
      expect(jsonMap['redirectUri'], 'REDIRECTURI');
    });

    test('test toString', () {
      final CidaasConfig config = CidaasConfig(
          baseUrl: 'BASEURL',
          clientId: 'CLIENTID',
          clientSecret: 'CLIENTSECRET',
          scopes: 'SCOPES',
          redirectURI: 'REDIRECTURI');

      final String str = config.toString();
      expect(str.contains('BASEURL'), true);
    });
  });
}

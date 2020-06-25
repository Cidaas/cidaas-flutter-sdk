import 'dart:convert';
import 'package:cidaas_flutter_sdk/cidaas_flutter_sdk.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TokenEntity', () {
    test('create the TokenEntity from json', () {
      const String jsonString =
          '{"access_token": "ACCESSTOKEN", "id_token": "IDTOKEN", "sub": "SUB", "refresh_token": "REFRESH_TOKEN"}';

      final TokenEntity tokenEntity = TokenEntity.fromJson(json.decode(jsonString));
      expect(tokenEntity.accessToken, 'ACCESSTOKEN');
      expect(tokenEntity.idToken, 'IDTOKEN');
      expect(tokenEntity.sub, 'SUB');
      expect(tokenEntity.refreshToken, 'REFRESH_TOKEN');
    });

    test('create the json from TokenEntity', () {
      final TokenEntity tokenEntity = TokenEntity(accessToken: 'ACCESSTOKEN', idToken: 'IDTOKEN', sub: 'SUB', refreshToken: 'REFRESHTOKEN');

      final Map<String, dynamic> jsonMap = tokenEntity.toJson();
      expect(jsonMap['access_token'], 'ACCESSTOKEN');
      expect(jsonMap['id_token'], 'IDTOKEN');
      expect(jsonMap['sub'], 'SUB');
      expect(jsonMap['refresh_token'], 'REFRESHTOKEN');
    });

    test('test toString', () {
      final TokenEntity tokenEntity = TokenEntity(accessToken: 'ACCESSTOKEN', idToken: 'IDTOKEN', sub: 'SUB', refreshToken: 'REFRESHTOKEN');

      final String str = tokenEntity.toString();
      expect(str.contains('ACCESSTOKEN'), true);
    });
  });
}

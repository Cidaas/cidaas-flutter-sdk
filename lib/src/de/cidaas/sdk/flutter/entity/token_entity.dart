import 'package:flutter/widgets.dart';

/// The obtained TokenEntity after login
///
/// contains [accessToken], [idToken], [sub], [refreshToken]
class TokenEntity {
  String accessToken;
  String idToken;
  String sub;
  String refreshToken;
  TokenEntity({
    @required this.accessToken,
    @required this.idToken,
    @required this.sub,
    @required this.refreshToken,
  });
  TokenEntity.fromJson(Map<String, dynamic> json)
      : accessToken = json['access_token'],
        idToken = json['id_token'],
        sub = json['sub'],
        refreshToken = json['refresh_token'];

  Map<String, dynamic> toJson() => {
    'access_token': accessToken,
    'id_token': idToken,
    'sub': sub,
    'refresh_token': refreshToken,
  };

  @override
  String toString() => 'TokenEntity ${toJson().toString()}';
}

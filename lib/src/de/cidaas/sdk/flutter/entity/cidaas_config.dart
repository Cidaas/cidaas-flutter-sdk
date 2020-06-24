import 'package:flutter/widgets.dart';

/// The cidaas configuration
class CidaasConfig {

  String baseUrl = "";
  String clientId;
  String clientSecret;
  String scopes;
  String redirectURI;
  String wellKnownURI;

  CidaasConfig({
    @required this.baseUrl,
    @required this.clientId,
    @required this.clientSecret,
    @required this.scopes,
    @required this.redirectURI,
  }) {
    this.wellKnownURI = this.baseUrl + "/.well-known/openid-configuration";
  }

  CidaasConfig.fromJson(Map<String, dynamic> json)
      : baseUrl = json['baseUrl'],
        clientId = json['clientId'],
        clientSecret = json['clientSecret'],
        scopes = json['scopes'],
        redirectURI = json['redirectUri'],
        this.wellKnownURI = json['baseUrl'] != null ? json['baseUrl'] + "/.well-known/openid-configuration" : "";

  Map<String, dynamic> toJson() => {
        'baseUrl': baseUrl,
        'clientId': clientId,
        'clientSecret': clientSecret,
        'scopes': scopes,
        'redirectUri': redirectURI,
      };

  @override
  String toString() => 'CidaasConfig ${toJson().toString()}';
}

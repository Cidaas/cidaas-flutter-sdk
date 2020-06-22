/// The openId configuration
class OpenIdConfiguration {

  String issuer;
  String userinfoEndpoint;
  String authorizationEndpoint;
  String introspectionEndpoint;
  String introspectionAsyncUpdateEndpoint;
  String revocationEndpoint;
  String tokenEndpoint;
  String jwksUri;
  String checkSessionIframe;
  String endSessionEndpoint;
  String socialProviderTokenResolverEndpoint;
  String deviceAuthorizationEndpoint;
  List<String> subjectTypesSupported;
  List<String> scopesSupported;
  List<String> responseTypesSupported;
  List<String> responseModesSupported;
  List<String> grantTypesSupported;
  List<String> idTokenSigningAlgValuesSupported;
  List<String> idTokenEncryptionAlgValuesSupported;
  List<String> idTokenEncryptionEncValuesSupported;
  List<String> userinfoSigningAlgValuesSupported;
  List<String> userinfoEncryptionAlgValuesSupported;
  List<String> userinfoEncryptionEncValuesSupported;
  List<String> requestObjectSigningAlgValuesSupported;
  List<String> requestObjectEncryptionAlgValuesSupported;
  List<String> requestObjectEncryptionEncValuesSupported;
  List<String> tokenEndpointAuthMethodsSupported;
  List<String> tokenEndpointAuthSigningAlgValuesSupported;
  List<String> claimsSupported;
  bool claimsParameterSupported;
  List<String> claimsTypesSupported;
  String serviceDocumentation;
  List<String> uiLocalesSupported;
  List<String> displayValuesSupported;
  List<String> codeChallengeMethodsSupported;
  bool requestParameterSupported;
  bool requestUriParameterSupported;
  bool requireRequestUriRegistration;
  String opPolicyUri;
  String opTosUri;
  String scimEndpoint;

  OpenIdConfiguration.fromJson(Map<String, dynamic> json)
      : issuer = json['issuer'],
        userinfoEndpoint = json['userinfo_endpoint'],
        authorizationEndpoint = json['authorization_endpoint'],
        introspectionEndpoint = json['introspection_endpoint'],
        introspectionAsyncUpdateEndpoint = json['introspection_async_update_endpoint'],
        revocationEndpoint = json['revocation_endpoint'],
        tokenEndpoint = json['token_endpoint'],
        jwksUri = json['jwks_uri'],
        checkSessionIframe = json['check_session_iframe'],
        endSessionEndpoint = json['end_session_endpoint'],
        socialProviderTokenResolverEndpoint = json['social_provider_token_resolver_endpoint'],
        deviceAuthorizationEndpoint = json['device_authorization_endpoint'],
        subjectTypesSupported = (json['subject_types_supported'] as List<dynamic>).cast<String>(),
        scopesSupported = (json['scopes_supported'] as List<dynamic>).cast<String>(),
        responseTypesSupported = (json['response_types_supported'] as List<dynamic>).cast<String>(),
        responseModesSupported = (json['response_modes_supported'] as List<dynamic>).cast<String>(),
        grantTypesSupported = (json['grant_types_supported'] as List<dynamic>).cast<String>(),
        idTokenSigningAlgValuesSupported = (json['id_token_signing_alg_values_supported'] as List<dynamic>).cast<String>(),
        idTokenEncryptionAlgValuesSupported = (json['id_token_encryption_alg_values_supported'] as List<dynamic>).cast<String>(),
        idTokenEncryptionEncValuesSupported = (json['id_token_encryption_enc_values_supported'] as List<dynamic>).cast<String>(),
        tokenEndpointAuthMethodsSupported = (json['token_endpoint_auth_methods_supported'] as List<dynamic>).cast<String>(),
        tokenEndpointAuthSigningAlgValuesSupported = (json['token_endpoint_auth_signing_alg_values_supported'] as List<dynamic>).cast<String>(),
        claimsSupported = (json['claims_supported'] as List<dynamic>).cast<String>(),
        claimsParameterSupported = json['claims_parameter_supported'],
        claimsTypesSupported = (json['claim_types_supported'] as List<dynamic>).cast<String>(),
        serviceDocumentation = json['service_documentation'],
        uiLocalesSupported = (json['ui_locales_supported']as List<dynamic>).cast<String>(),
        displayValuesSupported = (json['display_values_supported'] as List<dynamic>).cast<String>(),
        codeChallengeMethodsSupported = (json['code_challenge_methods_supported'] as List<dynamic>).cast<String>(),
        requestParameterSupported = json['request_parameter_supported'],
        requestUriParameterSupported = json['request_uri_parameter_supported'],
        requireRequestUriRegistration = json['require_request_uri_registration'],
        opPolicyUri = json['op_policy_uri'],
        opTosUri = json['op_tos_uri'],
        scimEndpoint = json['scim_endpoint'];

  Map<String, dynamic> toJson() => {
    'issuer': issuer,
    'userinfo_endpoint': userinfoEndpoint,
    'authorization_endpoint': authorizationEndpoint,
    'introspection_endpoint': introspectionEndpoint,
    'introspection_async_update_endpoint': introspectionAsyncUpdateEndpoint,
    'revocation_endpoint': revocationEndpoint,
    'token_endpoint': tokenEndpoint,
    'jwks_uri': jwksUri,
    'check_session_iframe': checkSessionIframe,
    'end_session_endpoint': endSessionEndpoint,
    'social_provider_token_resolver_endpoint': socialProviderTokenResolverEndpoint,
    'device_authorization_endpoint': deviceAuthorizationEndpoint,
    'subject_types_supported': subjectTypesSupported,
    'scopes_supported': scopesSupported,
    'response_types_supported': responseTypesSupported,
    'response_modes_supported': responseModesSupported,
    'grant_types_supported': grantTypesSupported,
    'id_token_signing_alg_values_supported': idTokenSigningAlgValuesSupported,
    'id_token_encryption_alg_values_supported': idTokenEncryptionAlgValuesSupported,
    'id_token_encryption_enc_values_supported': idTokenEncryptionEncValuesSupported,
    'token_endpoint_auth_methods_supported': tokenEndpointAuthMethodsSupported,
    'token_endpoint_auth_signing_alg_values_supported': tokenEndpointAuthSigningAlgValuesSupported,
    'claims_supported': claimsSupported,
    'claims_parameter_supported': claimsParameterSupported,
    'claim_types_supported': claimsTypesSupported,
    'service_documentation': serviceDocumentation,
    'ui_locales_supported': uiLocalesSupported,
    'display_values_supported': displayValuesSupported,
    'code_challenge_methods_supported': codeChallengeMethodsSupported,
    'request_parameter_supported': requestParameterSupported,
    'request_uri_parameter_supported': requestUriParameterSupported,
    'require_request_uri_registration': requireRequestUriRegistration,
    'op_policy_uri': opPolicyUri,
    'op_tos_uri': opTosUri,
    'scim_endpoint': scimEndpoint,
  };

  @override
  String toString() => 'OpenIdConfiguration ${toJson().toString()}';
}

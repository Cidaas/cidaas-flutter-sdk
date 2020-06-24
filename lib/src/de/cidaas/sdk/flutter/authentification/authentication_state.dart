part of 'authentication_bloc.dart';

/// The AuthenticationState
abstract class AuthenticationState extends Equatable {
  @override
  List<Object> get props => [];
  const AuthenticationState();
}

/// States that the authentication was successful
///
/// Contains the [TokenEntity]
class AuthenticationSuccessState extends AuthenticationState {
  final TokenEntity tokenEntity;

  AuthenticationSuccessState({@required this.tokenEntity});

  TokenEntity get token{
    return tokenEntity;
  }

  @override
  String toString() => 'AuthenticationSuccessState { tokenEntity: $tokenEntity }';
}

/// States that the authentication was not successful
///
/// Contains the error as a [String]
class AuthenticationFailureState extends AuthenticationState {
  final String error;

  const AuthenticationFailureState({@required this.error});

  @override
  String toString() => 'AuthenticationFailureState { error: $error }';
}

/// States that the authentication is ongoing & currently the loginBrowser should be dispalyed
class AuthenticationShowLoginWithBrowserState extends AuthenticationState {}

/// States that the user has logged out
class AuthenticationHasLoggedOutState extends AuthenticationState {}

/// States that the authentication is in progress and some asynchronous operations are ongoing
class AuthenticationInProgressState extends AuthenticationState {}

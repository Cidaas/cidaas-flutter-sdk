import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import 'authentication.dart';
import 'authentication_handler.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  final AuthHandler authRepository;

  AuthenticationBloc({@required this.authRepository})
      : assert(authRepository != null);

  @override
  AuthenticationState get initialState => AuthenticationInitial();

  @override
  Stream<AuthenticationState> mapEventToState(
      AuthenticationEvent event,
      ) async* {
    if (event is AuthenticationStarted) {
      final bool hasToken = await authRepository.hasToken();

      if (hasToken) {
        yield AuthenticationSuccess();
      } else {
        yield AuthenticationFailure();
      }
    }

    if (event is AuthenticationLoggedIn) {
      yield AuthenticationSuccess();
    }

    if (event is AuthenticationLoggedOut) {
      yield AuthenticationInProgress();
      await authRepository.deleteToken();
      yield AuthenticationFailure();
    }
  }
}
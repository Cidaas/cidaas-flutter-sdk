import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cidaassdkflutter/cidaassdkflutter.dart';
import 'package:flutter/material.dart';
import 'authentication_storage_helper.dart';
import './../entity/token_entity.dart';

part 'authentication_event.dart';

part 'authentication_state.dart';

/// The authentication Bloc used to determine which screen should get displayed
class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {

  static final AuthenticationBloc _instance = AuthenticationBloc._internal();
  factory AuthenticationBloc() => _instance;

  AuthenticationBloc._internal();

  final AuthStorageHelper authStorageHelper = AuthStorageHelper();

  @override
  AuthenticationState get initialState => AuthenticationHasLoggedOutState();

  /// Maps the AuthenticationEvents to AuthenticationState
  @override
  Stream<AuthenticationState> mapEventToState(
    AuthenticationEvent event,
  ) async* {
    if (event is AuthenticationStartedEvent) {
      yield AuthenticationInProgressState();
      try {

        if (await CidaasLoginProvider.isAuth()) {
          yield AuthenticationSuccessState(
              tokenEntity: await authStorageHelper.getCurrentToken());
        } else {
          yield AuthenticationShowLoginWithBrowserState();
        }
      } catch (e) {
        yield AuthenticationFailureState(error: e);
      }
    }

    if (event is AuthenticationLoggedInEvent) {
      yield AuthenticationInProgressState();
      if (event.tokenEntity == null || event.tokenEntity.accessToken == null) {
        yield AuthenticationFailureState(error: "No access token received after login");
      }
      await authStorageHelper.persistTokenEntity(event.tokenEntity);
      yield AuthenticationSuccessState(tokenEntity: event.tokenEntity);
    }

    if (event is AuthenticationLoggedOutEvent) {
      yield AuthenticationInProgressState();
      await authStorageHelper.deleteToken();
      yield AuthenticationHasLoggedOutState();
    }
  }
}
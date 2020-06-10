import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'authentication_storage_helper.dart';
import './../entity/token_entity.dart';

part 'authentication_event.dart';

part 'authentication_state.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  final AuthStorageHelper authStorageHelper = AuthStorageHelper();

  @override
  AuthenticationState get initialState => AuthenticationLoggedOutState();

  @override
  Stream<AuthenticationState> mapEventToState(
    AuthenticationEvent event,
  ) async* {
    if (event is AuthenticationStartedEvent) {
      yield AuthenticationInProgressState();
      final bool hasToken = await authStorageHelper.hasToken();

      if (hasToken) {
        yield AuthenticationSuccessState(tokenEntity: await authStorageHelper.getCurrentToken());
      } else {
        yield AuthenticationLoggedOutState();
      }
    }

    if (event is AuthenticationLoggedInEvent) {
      yield AuthenticationInProgressState();
      print("TokenEntity in map AuthenticationLoggedIn to AuthenticationSuccess: ");
      if (event.tokenEntity != null) {
        print(event.tokenEntity);
      }
      await authStorageHelper.persistTokenEntity(event.tokenEntity);
      yield AuthenticationSuccessState(tokenEntity: event.tokenEntity);
    }

    if (event is AuthenticationLoggedOutEvent) {
      yield AuthenticationInProgressState();
      await authStorageHelper.deleteToken();
      yield AuthenticationLoggedOutState();
      this.close();
    }
  }
}
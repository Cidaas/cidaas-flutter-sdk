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
  AuthenticationState get initialState => AuthenticationInitial();

  @override
  Stream<AuthenticationState> mapEventToState(
    AuthenticationEvent event,
  ) async* {
    if (event is AuthenticationStarted) {
      final bool hasToken = await authStorageHelper.hasToken();

      if (hasToken) {
        yield AuthenticationSuccess(tokenEntity: await authStorageHelper.getCurrentToken());
      } else {
        yield AuthenticationFailure();
      }
    }

    if (event is AuthenticationLoggedIn) {
      yield AuthenticationInProgress();
      print("TokenEntity in map AuthenticationLoggedIn to AuthenticationSuccess: ");
      if (event.tokenEntity != null) {
        print(event.tokenEntity);
      }
      await authStorageHelper.persistTokenEntity(event.tokenEntity);
      yield AuthenticationSuccess(tokenEntity: event.tokenEntity);
    }

    if (event is AuthenticationLoggedOut) {
      yield AuthenticationInProgress();
      await authStorageHelper.deleteToken();
      yield AuthenticationFailure();
    }
  }
}
import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cidaassdkflutter/cidaassdkflutter.dart';
import 'package:flutter/material.dart';
import 'authentication_storage_helper.dart';
import './../entity/token_entity.dart';

part 'authentication_event.dart';

part 'authentication_state.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {

  static final AuthenticationBloc _instance = AuthenticationBloc._internal();
  factory AuthenticationBloc() => _instance;

  AuthenticationBloc._internal();

  final AuthStorageHelper authStorageHelper = AuthStorageHelper();

  @override
  AuthenticationState get initialState => AuthenticationShowLoginWithBrowserState();

  @override
  Stream<AuthenticationState> mapEventToState(
    AuthenticationEvent event,
  ) async* {
    if (event is AuthenticationStartedEvent) {
      yield AuthenticationInProgressState();
      final bool isAuthorized = await CidaasLoginProvider.isAuth;
      final token = await authStorageHelper.getCurrentToken();
      print("Token in Bloc from storage: " + token.toString());

      if (isAuthorized) {
        yield AuthenticationSuccessState(tokenEntity: await authStorageHelper.getCurrentToken());
      } else {
        yield AuthenticationShowLoginWithBrowserState();
      }
    }

    if (event is AuthenticationLoggedInEvent) {
      yield AuthenticationInProgressState();
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
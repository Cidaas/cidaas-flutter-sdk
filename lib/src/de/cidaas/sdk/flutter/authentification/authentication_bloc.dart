import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cidaassdkflutter/cidaassdkflutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'authentication_storage_helper.dart';
import './../entity/token_entity.dart';
import 'package:equatable/equatable.dart';

part 'authentication_event.dart';

part 'authentication_state.dart';

/// The authentication Bloc used to determine which screen should get displayed
class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {

  static AuthenticationBloc _instance;

  static AuthStorageHelper _authStorageHelper;

  /// Factory returns Singleton AuthenticationBloc
  ///
  /// if [storageHelper] is given upon first creation, uses this AuthStorageHelper
  /// if not, creates a new one
  factory AuthenticationBloc({FlutterSecureStorage secureStorage}) {
    if (AuthenticationBloc._instance != null) {
      return AuthenticationBloc._instance;
    } else {
      return AuthenticationBloc._internal(secureStorage: secureStorage);
    }
  }

  /// Internal constr.
  AuthenticationBloc._internal({FlutterSecureStorage secureStorage}) {
    if (secureStorage == null) {
      AuthenticationBloc._authStorageHelper = new AuthStorageHelper();
    } else {
      AuthenticationBloc._authStorageHelper = new AuthStorageHelper(storage: secureStorage);
    }
    AuthenticationBloc._instance = this;
  }

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
              tokenEntity: await _authStorageHelper.getCurrentToken());
        } else {
          yield AuthenticationShowLoginWithBrowserState();
        }
      } catch (e) {
        yield AuthenticationFailureState(error: e.toString());
      }
    }

    if (event is AuthenticationLoggedInEvent) {
      yield AuthenticationInProgressState();
      if (event.tokenEntity == null || event.tokenEntity.accessToken == null) {
        yield AuthenticationFailureState(error: "No access token received after login");
      } else {
        await _authStorageHelper.persistTokenEntity(event.tokenEntity);
        yield AuthenticationSuccessState(tokenEntity: event.tokenEntity);
      }
    }

    if (event is AuthenticationLoggedOutEvent) {
      yield AuthenticationInProgressState();
      await _authStorageHelper.deleteToken();
      yield AuthenticationHasLoggedOutState();
    }
  }

  @override
  close() async {
    _instance = null;
    _authStorageHelper?.close();
    _authStorageHelper = null;
    super.close();
  }
}
import 'dart:async';

import 'package:bloc/bloc.dart';
import './../authentification/authentication_storage_helper.dart';
import 'package:meta/meta.dart';
import './../entity/token_entity.dart';

import './../authentification/authentication.dart';

part 'login_event.dart';

part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthStorageHelper authStorageHelper;
  final AuthenticationBloc authenticationBloc;

  LoginBloc({
    @required this.authStorageHelper,
    @required this.authenticationBloc,
  })  : assert(authStorageHelper != null),
        assert(authenticationBloc != null);

  @override
  LoginState get initialState => LoginInitial();

  @override
  Stream<LoginState> mapEventToState(LoginEvent event) async* {
    if (event is LoggedIn) {
      yield LoginInitial();
      authenticationBloc.add(
          AuthenticationLoggedIn(tokenEntity: event.tokenEntity));
      yield LoginInitial();
    }
    if (event is LoginFailed) {
      yield LoginFailure();
    }
  }
}

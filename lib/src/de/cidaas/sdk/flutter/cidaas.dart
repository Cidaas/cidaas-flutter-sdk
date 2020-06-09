import 'package:cidaassdkflutter/src/de/cidaas/sdk/flutter/screens/LoginBrowser.dart';

import './authentification/authentication_handler.dart';
import 'package:flutter/material.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'authentification/authentication.dart';


class SimpleBlocDelegate extends BlocDelegate {
  @override
  void onEvent(Bloc bloc, Object event) {
    print(event);
    super.onEvent(bloc, event);
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    print(transition);
    super.onTransition(bloc, transition);
  }

  @override
  void onError(Bloc bloc, Object error, StackTrace stackTrace) {
    print(error);
    super.onError(bloc, error, stackTrace);
  }
}



abstract class Cidaas extends StatelessWidget {
  final AuthHandler authHandler;

  Cidaas({Key key, @required this.authHandler}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BlocBuilder<AuthenticationBloc, AuthenticationState>(
        builder: (context, state) {
          print("State cidaas.dart " + state.toString());
          if (state is AuthenticationSuccess) {
            return getHomePage();
          }
          if (state is AuthenticationFailure) {
            return LoginBrowser(authHandler: authHandler);
          }
          if (state is AuthenticationInProgress) {
            return getLoadingIndicatorScreen();
          }
          return getSplashScreen();
        },
      ),
    );
  }
  Widget getHomePage();
  Widget getSplashScreen();
  Widget getLoadingIndicatorScreen();
}
import 'package:cidaassdkflutter/src/de/cidaas/sdk/flutter/screens/login_browser.dart';

import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'authentification/authentication_bloc.dart';
import './screens/splash_screen.dart';

abstract class Cidaas extends StatelessWidget {
  static const defaultSplashScreen = SplashScreen();

  @override
  Widget build(BuildContext context) {
    Widget _splashScreen = getSplashScreen();
    if (_splashScreen == null) {
      _splashScreen = defaultSplashScreen;
    }
    return BlocBuilder<AuthenticationBloc, AuthenticationState>(
        builder: (context, state) {
          if (state is AuthenticationSuccessState) {
            return getHomePage(tokenEntity: state.tokenEntity);
          }
          if (state is AuthenticationShowLoginWithBrowserState) {
            return LoginBrowser(splashScreen: _splashScreen);
          }
          if (state is AuthenticationInProgressState) {
            return _splashScreen;
          }
          if (state is AuthenticationHasLoggedOutState) {
            return getLoggedOutScreen(context: context);
          }
          if (state is AuthenticationFailureState) {
            return Center(
              child: Text('${state.error}'),
            );
          }
          return _splashScreen;
        },
    );
  }

  Widget getHomePage({tokenEntity});

  Widget getSplashScreen();

  Widget getLoggedOutScreen({context});
}

import 'package:cidaassdkflutter/src/de/cidaas/sdk/flutter/screens/login_browser.dart';

import './authentification/authentication_storage_helper.dart';
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'authentification/authentication_bloc.dart';

abstract class Cidaas extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    print("Cidaas build called");
    return BlocBuilder<AuthenticationBloc, AuthenticationState>(
      builder: (context, state) {
        if (state is AuthenticationSuccessState) {
          return getHomePage(tokenEntity: state.tokenEntity);
        }
        if (state is AuthenticationShowLoginWithBrowserState) {
          return LoginBrowser(splashScreen: getSplashScreen());
        }
        if (state is AuthenticationInProgressState) {
          return getSplashScreen();
        }
        if (state is AuthenticationHasLoggedOutState) {
          return getLoggedOutScreen(context: context);
        }
        return getSplashScreen();
      },
    );
  }

  Widget getHomePage({tokenEntity});

  Widget getSplashScreen();

  Widget getLoggedOutScreen({context});
}

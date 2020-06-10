import 'package:cidaassdkflutter/src/de/cidaas/sdk/flutter/screens/LoginBrowser.dart';

import './authentification/authentication_storage_helper.dart';
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'authentification/authentication_bloc.dart';

abstract class Cidaas extends StatelessWidget {
  final AuthStorageHelper authStorageHelper;

  Cidaas({Key key, @required this.authStorageHelper}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print("Cidaas build called");
    return BlocBuilder<AuthenticationBloc, AuthenticationState>(
      builder: (context, state) {
        if (state is AuthenticationSuccessState) {
          return getHomePage(tokenEntity: state.tokenEntity);
        }
        if (state is AuthenticationLoggedOutState) {
          return LoginBrowser(authStorageHelper: authStorageHelper);
        }
        if (state is AuthenticationInProgressState) {
          return getSplashScreen();
        }
        return getSplashScreen();
      },
    );
  }

  Widget getHomePage({tokenEntity});

  Widget getSplashScreen();

  Widget getLoggedOutScreen();
}

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
    return MaterialApp(
      home: BlocBuilder<AuthenticationBloc, AuthenticationState>(
        builder: (context, state) {
          print("State cidaas.dart " + state.toString());
          if (state is AuthenticationSuccess) {
            return getHomePage();
          }
          if (state is AuthenticationFailure) {
            return LoginBrowser(authStorageHelper: authStorageHelper);
          }
          if (state is AuthenticationInProgress) {
            return getSplashScreen();
          }
          return getSplashScreen();
        },
      ),
    );
  }
  Widget getHomePage();
  Widget getSplashScreen();
}
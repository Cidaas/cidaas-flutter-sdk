import 'package:cidaassdkflutter/src/de/cidaas/sdk/flutter/authentification/authentication.dart';
import 'package:cidaassdkflutter/src/de/cidaas/sdk/flutter/authentification/authentication_handler.dart';
import 'package:cidaassdkflutter/src/de/cidaas/sdk/flutter/screens/LoginBrowser.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'login_bloc.dart';

class LoginPage extends StatelessWidget {
  final AuthHandler authHandler;

  LoginPage({Key key, @required this.authHandler})
      : assert(authHandler != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: BlocProvider(
        create: (context) {
          return LoginBloc(
            authenticationBloc: BlocProvider.of<AuthenticationBloc>(context),
            authHandler: authHandler,
          );
        },
        child: LoginBrowser(),
      ),
    );
  }
}
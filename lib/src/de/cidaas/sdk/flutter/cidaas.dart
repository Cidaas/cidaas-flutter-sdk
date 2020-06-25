import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';

import '../flutter/entity/token_entity.dart';
import 'authentification/authentication_bloc.dart';
import 'screens/login_browser.dart';
import 'screens/splash_screen.dart';

/// The [Cidaas] class encapsulates the Bloc logic
/// To use it, implement getLoggedInScreen() & getLoggedOutScreen().
/// You can optionally override the methods getSplashScreen() & getAuthenticationFailureScreen()
///
/// * The screen returned by getLoggedInScreen() will be displayed once the user has authenticated
/// * The screen returned by getLoggedOutScreen() will be displayed if the user is not logged in
/// * The screen returned by getSplashScreen() will be displayed during asynchronous loading operations
/// * The screen returned by getAuthenticationFailureScreen() will be displayed if the user could not be authenticated
///
/// The authentication process will start once 'CidaasLoginProvider.doLogin(context)' is called
abstract class Cidaas extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthenticationBloc, AuthenticationState>(
      builder: (BuildContext context, AuthenticationState state) {
        if (state is AuthenticationSuccessState) {
          return getLoggedInScreen(tokenEntity: state.tokenEntity);
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
        if (state is AuthenticationFailureState) {
          return getAuthenticationFailureScreen(errorMessage: state.error);
        }
        throw 'Unknown authentication state';
      },
    );
  }

  /// This screen will be displayed after successful login.
  ///
  /// The parameter [tokenEntity] will contain the received cidaas tokenEntity
  /// E.g.:
  /// @override
  ///  Widget getLoggedInScreen({tokenEntity}) {
  ///    return MyCustomLoggedInScreenOrAppHomePage(tokenEntity: tokenEntity);
  ///  }
  Widget getLoggedInScreen({TokenEntity tokenEntity});

  /// Override this method to display a custom loading screen
  Widget getSplashScreen() {
    return const SplashScreen();
  }

  /// This screen will be displayed if the user is logged out
  ///
  /// Provide the given [context] to the doLogin()-method of the CidaasLoginProvider
  /// This screen should contain a button to display the login button which calls the doLogin-Method, e.g.:
  /// RaisedButton(
  ///      child: Text('Login'),
  ///      onPressed: () {
  ///        CidaasLoginProvider.doLogin(context);
  ///      },
  Widget getLoggedOutScreen({BuildContext context});

  /// This screen will be displayed if no access_token is received after login
  ///
  /// [errorMessage] will contain the errorMessage
  Widget getAuthenticationFailureScreen({String errorMessage}) {
    return Center(
      child: Text(
        errorMessage,
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
      ),
    );
  }
}

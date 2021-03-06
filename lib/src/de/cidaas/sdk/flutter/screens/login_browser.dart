import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cidaas_login_provider.dart';
import '../entity/cidaas_config.dart';
import '../entity/token_entity.dart';
import './../authentification/authentication_bloc.dart';

class LoginBrowser extends StatefulWidget {
  final String reRouteToAfterLogin;
  final Widget splashScreen;

  LoginBrowser({Key key, this.reRouteToAfterLogin, @required this.splashScreen})
      : super(key: key);

  @override
  _LoginBrowserState createState() =>
      _LoginBrowserState(this.reRouteToAfterLogin, this.splashScreen);
}

class _LoginBrowserState extends State<LoginBrowser> {
  AuthenticationBloc _authenticationBloc;
  String _reRouteToAfterLogin;
  Widget _splashScreen;

  _LoginBrowserState(String reRouteToAfterLogin, Widget splashScreen) {
    this._reRouteToAfterLogin = reRouteToAfterLogin;
    this._splashScreen = splashScreen;
  }

  @override
  void initState() {
    super.initState();
    _authenticationBloc = BlocProvider.of<AuthenticationBloc>(context);
  }

  final Key comKey = const Key('login');

  void addListener(CidaasConfig config) {
    final FlutterWebviewPlugin flutterWebviewPlugin = FlutterWebviewPlugin();

    flutterWebviewPlugin.onUrlChanged.listen((String url) async {
      if (url.startsWith(config.redirectURI)) {
        final Uri parsedUrl = Uri.parse(url);
        final String code = parsedUrl.queryParameters['code'];
        final TokenEntity tokenEntity =
            await CidaasLoginProvider.getAccessTokenByCode(code.toString());
        if (tokenEntity != null) {
          _authenticationBloc
              .add(AuthenticationLoggedInEvent(tokenEntity: tokenEntity));
          flutterWebviewPlugin.close();
          if (this._reRouteToAfterLogin?.isNotEmpty ?? false) {
            Navigator.of(context).pushReplacementNamed(
                this._reRouteToAfterLogin,
                arguments: tokenEntity);
          }
        } else {
          flutterWebviewPlugin.show();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget getWebView() {
      final Future<String> _initURL = CidaasLoginProvider.getLoginURL();
      return FutureBuilder<String>(
          future: _initURL, // a previously-obtained Future<String> or null
          builder: (BuildContext context, AsyncSnapshot<String> urlSnapshot) {
            if (urlSnapshot.hasData) {
              final Future<CidaasConfig> _config =
                  CidaasLoginProvider.getCidaasConf();
              return FutureBuilder<CidaasConfig>(
                  future: _config,
                  // a previously-obtained Future<String> or null
                  builder: (BuildContext context,
                      AsyncSnapshot<CidaasConfig> configSnapshot) {
                    if (configSnapshot.hasData) {
                      addListener(configSnapshot.data);
                      return WebviewScaffold(
                          key: comKey,
                          url: urlSnapshot.data,
                          withJavascript: true,
                          displayZoomControls: false,
                          withZoom: false,
                          withLocalStorage: true,
                          hidden: true);
                    } else if (configSnapshot.hasError) {
                      // The config needs to be set by the developer
                      throw configSnapshot.error;
                    } else {
                      return this._splashScreen;
                    }
                  });
            } else if (urlSnapshot.hasError) {
              // The url needs to be set in the config by the developer
              throw urlSnapshot.error;
            } else {
              return this._splashScreen;
            }
          });
    }

    return getWebView();
  }
}

import 'package:cidaassdkflutter/src/de/cidaas/sdk/flutter/entity/cidaas_config.dart';

import './../authentification/authentication_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import './splash_screen.dart';
import '../cidaas_login_provider.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:flutter/material.dart';

class LoginBrowser extends StatefulWidget {
  final String routeTo;
  final Widget splashScreen;
  static const defaultSplashScreen = SplashScreen();

  LoginBrowser({Key key, this.routeTo, this.splashScreen = defaultSplashScreen}) : super(key: key);

  @override
  _LoginBrowserState createState() => _LoginBrowserState(this.routeTo, this.splashScreen);
}

class _LoginBrowserState extends State<LoginBrowser> {
  AuthenticationBloc _authenticationBloc;
  String _routeTo;
  Widget _splashScreen;

  _LoginBrowserState(String routeTo, Widget splashScreen) {
    this._routeTo = routeTo;
    this._splashScreen = splashScreen;
  }

  @override
  void initState() {
    super.initState();
    _authenticationBloc = BlocProvider.of<AuthenticationBloc>(context);
  }
  
  final comKey = Key('login');
  @override
  Widget build(BuildContext context) {
    final flutterWebviewPlugin = new FlutterWebviewPlugin();

    flutterWebviewPlugin.onUrlChanged.listen((String url) async {
      CidaasConfig _config = await CidaasLoginProvider.getCidaasConf();
      print("RedirectURI in Login Browser: " + _config.redirectURI.toString());
      if (url.startsWith(_config.redirectURI)) {
        final parsedUrl = Uri.parse(url);
        final code = parsedUrl.queryParameters["code"];
        print("Code in LoginBrowser " + code);
        print(code);
        final tokenEntity = await CidaasLoginProvider.getAccessTokenByCode(code.toString());
        print("TokenEntity in LoginBrowser" + tokenEntity.toString());
        if (tokenEntity != null) {
          _authenticationBloc.add(AuthenticationLoggedInEvent(tokenEntity: tokenEntity));
          flutterWebviewPlugin.close();
          if (this._routeTo?.isNotEmpty ?? false) {
            Navigator.of(context)
                .pushReplacementNamed(this._routeTo, arguments: tokenEntity);
          }
        } else {
          flutterWebviewPlugin.show();
        }
      }
    });

    Widget getWebView() {
      Future<String> _initURL = CidaasLoginProvider.getLoginURL();
      _initURL.then((val) => print("initURL: " + val.toString()));
      return FutureBuilder<String>(
        future: _initURL, // a previously-obtained Future<String> or null
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          if (snapshot.hasData) {
            return WebviewScaffold(
                key: comKey,
                url: snapshot.data,
                withJavascript: true,
                displayZoomControls: false,
                withZoom: false,
                withLocalStorage: true,
                hidden: true
            );
          } else {
            return this._splashScreen;
          }
        });
    }

    return BlocListener<AuthenticationBloc, AuthenticationState>(
      bloc: _authenticationBloc,
      listener: (context, state) {
        if (state is AuthenticationFailureState) {
          Scaffold.of(context).showSnackBar(
            SnackBar(
              content: Text('${state.error}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: BlocBuilder<AuthenticationBloc, AuthenticationState>(
        bloc: _authenticationBloc,
        builder: (context, state) {
          return getWebView();
        },
      ),
    );
  }
}

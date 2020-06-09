import 'package:cidaassdkflutter/src/de/cidaas/sdk/flutter/authentification/authentication.dart';
import 'package:cidaassdkflutter/src/de/cidaas/sdk/flutter/authentification/authentication_storage_helper.dart';
import 'package:cidaassdkflutter/src/de/cidaas/sdk/flutter/login/login_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cidaas_login_provider.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginBrowser extends StatefulWidget {

  final AuthStorageHelper authStorageHelper;

  LoginBrowser({Key key, @required this.authStorageHelper}) : super(key: key);

  @override
  _LoginBrowserState createState() => _LoginBrowserState();
}

class _LoginBrowserState extends State<LoginBrowser> {
  LoginBloc _loginBloc;
  AuthenticationBloc _authenticationBloc;

  AuthStorageHelper get authStorageHelper => AuthStorageHelper();

  @override
  void initState() {
    _authenticationBloc = BlocProvider.of<AuthenticationBloc>(context);
    _loginBloc = LoginBloc(
      authStorageHelper: authStorageHelper,
      authenticationBloc: _authenticationBloc,
    );
    super.initState();
  }

  var initUrl = CidaasLoginProvider.getLoginURL();
  final comKey = Key('login');
  @override
  Widget build(BuildContext context) {
    final flutterWebviewPlugin = new FlutterWebviewPlugin();

    flutterWebviewPlugin.onUrlChanged.listen((String url) async {
      if (url.startsWith(CidaasLoginProvider.redirectUri)) {
        final parsedUrl = Uri.parse(url);
        final code = parsedUrl.queryParameters["code"];
        print(code);
        final userinfo = CidaasLoginProvider().getAccessTokenByCode(code);
        if (userinfo != null) {
          _loginBloc.add(LoggedIn());
          flutterWebviewPlugin.close();
        } else {
          flutterWebviewPlugin.show();
        }
      }
    });

    Widget getWebView(){
      return WebviewScaffold(
        key: comKey,
        url: this.initUrl,
        withJavascript: true,
        displayZoomControls: false,
        withZoom: false,
        withLocalStorage: true,
        hidden: true
      );
    }

    return BlocListener<LoginBloc, LoginState>(
      bloc: _loginBloc,
      listener: (context, state) {
        if (state is LoginFailure) {
          Scaffold.of(context).showSnackBar(
            SnackBar(
              content: Text('${state.error}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: BlocBuilder<LoginBloc, LoginState>(
        bloc: _loginBloc,
        builder: (context, state) {
          return getWebView();
        },
      ),
    );
  }
}

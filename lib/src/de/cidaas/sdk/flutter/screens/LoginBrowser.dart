import './../authentification/authentication_bloc.dart';
import './../authentification/authentication_storage_helper.dart';
import './../login/login_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cidaas_login_provider.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:flutter/material.dart';

class LoginBrowser extends StatefulWidget {
  final AuthStorageHelper authStorageHelper;
  final String routeTo;

  LoginBrowser({Key key, @required this.authStorageHelper, this.routeTo}) : super(key: key);

  @override
  _LoginBrowserState createState() => _LoginBrowserState(this.routeTo);
}

class _LoginBrowserState extends State<LoginBrowser> {
  LoginBloc _loginBloc;
  AuthenticationBloc _authenticationBloc;
  String _routeTo;

  AuthStorageHelper get authStorageHelper => AuthStorageHelper();

  _LoginBrowserState(String routeTo) {
    this._routeTo = routeTo;
  }

  @override
  void initState() {
    super.initState();
    _authenticationBloc = BlocProvider.of<AuthenticationBloc>(context);
    _loginBloc = LoginBloc(
      authStorageHelper: authStorageHelper,
      authenticationBloc: _authenticationBloc,
    );

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
        final tokenEntity = await CidaasLoginProvider().getAccessTokenByCode(code);
        if (tokenEntity != null) {
          print("TokenEntity in LoginBrowser" + tokenEntity.toString());
          _loginBloc.add(LoggedIn(tokenEntity: tokenEntity));
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

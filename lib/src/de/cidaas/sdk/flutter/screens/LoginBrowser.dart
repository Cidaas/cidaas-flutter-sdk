import '../screens/splash_screen.dart';

import '../cidaas_login_provider.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginBrowser extends StatefulWidget {
  static const routeName = "/login";
  final String routeTo;

  LoginBrowser(String routeTo)
      : routeTo = routeTo;

  @override
  _LoginBrowserState createState() => _LoginBrowserState(routeTo);
}

class _LoginBrowserState extends State<LoginBrowser> {

  _LoginBrowserState(String routeTo) {
    this.routeTo = routeTo;
  }

  String routeTo;
  var initUrl = CidaasLoginProvider.getLoginURL();
  bool isLoading = false;
  bool isInitiated = false;

  final comKey = Key('login');
  @override
  Widget build(BuildContext context) {

    print(initUrl);
    print("Check if already logged in");
    Provider.of<CidaasLoginProvider>(context, listen: false).refreshLoginFromCache().then((loadedFromCache) => {
      print("Loaded from cache: " + loadedFromCache.toString()),
      if (loadedFromCache) {
        Navigator.of(context)
            .pushReplacementNamed(routeTo)
      }
    });

    bool clearCookie = true;
    final flutterWebviewPlugin = new FlutterWebviewPlugin();
    try {
      flutterWebviewPlugin.cleanCookies();
    } catch (e) {}

    flutterWebviewPlugin.onUrlChanged.listen((String url) async {
      print(url);
      if (url.startsWith(CidaasLoginProvider.redirectUri)) {
        setState(() {
          isLoading = true;
        });
        final parsedUrl = Uri.parse(url);
        final code = parsedUrl.queryParameters["code"];
        print(code);
        final userinfo =
            await Provider.of<CidaasLoginProvider>(context, listen: false).getAccessTokenByCode(code);
        if (userinfo != null) {
          flutterWebviewPlugin.close();
          print("Routing should occur, token: " + userinfo.accessToken);
          Navigator.of(context)
              .pushReplacementNamed(routeTo);
        } else {
          try {
            setState(() {
              isLoading = false;
            });
          } catch (e) {}

          flutterWebviewPlugin.show();
        }
      }
    });

    Widget _getInitWidget() {
      return Container(
          child: SplashScreen()
        );
    }

    return isLoading
        ? Scaffold(
            body: _getInitWidget(),
          )
        : WebviewScaffold(
            key: comKey,
            url: this.initUrl,
            withJavascript: true,
            displayZoomControls: false,
            withZoom: false,
            withLocalStorage: true,
            hidden: true,
            initialChild: _getInitWidget(),
            clearCache: clearCookie,
            clearCookies: clearCookie,
            userAgent: clearCookie
                ? DateTime.now().millisecondsSinceEpoch.toString()
                : "",
          );
  }
}

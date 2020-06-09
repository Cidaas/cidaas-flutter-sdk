import '../cidaas_login_provider.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginBrowser extends StatefulWidget {
  static const routeName = "/login";

  @override
  _LoginBrowserState createState() => _LoginBrowserState();
}

class _LoginBrowserState extends State<LoginBrowser> {
  var initUrl = CidaasLoginProvider.getLoginURL();
  bool isLoading = false;
  bool isInitiated = false;

  final comKey = Key('login');
  @override
  Widget build(BuildContext context) {
    // var clearCookie = ModalRoute.of(context).settings.arguments as bool;
    // if (clearCookie == null) {
    //   clearCookie = false;
    // }
    print(initUrl);
    bool clearCookie = true;
    final flutterWebviewPlugin = new FlutterWebviewPlugin();
    // if (clearCookie) {
    try {
      flutterWebviewPlugin.cleanCookies();
    //  flutterWebviewPlugin.clearCache();
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
          //Navigator.of(context)
          //    .pushReplacementNamed("/info");
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
          // color: Colors.redAccent,
          child: Center(
            child: Text(
              'please_wait',
              style: TextStyle(
                  color: Theme.of(context)
                      .textTheme
                      .headline5
                      .color) /* TextStyle(color: Colors.white) */,
            ),
          ),
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

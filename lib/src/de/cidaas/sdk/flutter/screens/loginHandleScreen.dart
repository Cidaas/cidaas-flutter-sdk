import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../screens/LoginBrowser.dart';
import '../cidaas_login_provider.dart';
import './splashScreen.dart';

class LoginHandleScreen extends StatefulWidget {
  final String routeTo;

  LoginHandleScreen(String routeTo)
      : routeTo = routeTo;

  // This widget is the root of your application.
  @override
  _LoginHandleScreen createState() =>
      _LoginHandleScreen(this.routeTo);
}

class _LoginHandleScreen extends State<LoginHandleScreen> {
  String routeTo;

  _LoginHandleScreen(String routeTo) {
    this.routeTo = routeTo;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(create: (_) => new CidaasLoginProvider())
      ],
      child: Consumer<CidaasLoginProvider>(
        builder: (context, _cidaasLoginProvider, _) => Scaffold(
          body: _cidaasLoginProvider.isAuth
              ? Navigator.pushNamed(context, routeTo)
              : FutureBuilder<bool>(
              future: _cidaasLoginProvider
                  .refreshLoginFromCache(), //Returns Future<bool>
              builder: (ctx, AsyncSnapshot<bool> dataLoadingSnapShot) =>
              dataLoadingSnapShot.connectionState ==
                  ConnectionState.waiting
                  ? SplashScreen()
                  : LoginBrowser(routeTo: routeTo)),
        ),
      ),
    );
  }
}

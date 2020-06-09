import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../screens/LoginBrowser.dart';
import '../cidaas_login_provider.dart';
import '../screens/splash_screen.dart';

class LoginHandleScreen extends StatefulWidget {
  final String routeTo;
  final StatefulWidget returnScreen;

  LoginHandleScreen(String routeTo, StatefulWidget returnScreen)
      : routeTo = routeTo,
        returnScreen = returnScreen;

  // This widget is the root of your application.
  @override
  _LoginHandleScreen createState() =>
      _LoginHandleScreen(this.routeTo, returnScreen);
}

class _LoginHandleScreen extends State<LoginHandleScreen> {
  String routeTo;
  StatefulWidget returnScreen;

  _LoginHandleScreen(String routeTo, StatefulWidget returnScreen) {
    this.routeTo = routeTo;
    this.returnScreen = returnScreen;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => new CidaasLoginProvider())
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
                          : dataLoadingSnapShot.data
                              ? //Future.delayed(Duration.zero, () {
                                  Navigator.of(ctx).push(MaterialPageRoute(
                                      settings: RouteSettings(name: routeTo),
                                      builder: (ctx) => returnScreen))//;
                                //})
                              : LoginBrowser()
                          ),
        ),
      ),
    );
  }
}

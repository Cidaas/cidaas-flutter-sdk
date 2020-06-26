# cidaas flutter SDK

This SDK makes it easy to secure your flutter app with [cidaas](https://www.cidaas.com/).

## Getting Started
With this SDK you can secure your flutter application with cidaas.  
You can have a look at the example project [here](https://github.com/Cidaas/cidaas-flutter-sdk-example).

### Requirements
Dart SDK version:
SDK: ">=2.7.0 <3.0.0"

### Configuration
To authenticate your users via the authorization code flow,  
please first configure your cidaas Application as described [here](https://docs.cidaas.de/manage-applications.html)

You have to create the cidaas_config.json file under the /assets/ - folder in your project's root folder, this should contain following values:
```
{
  "baseUrl": "https://yourCidaasBaseUrl.de",
  "clientId": "your_apps_clientId",
  "clientSecret": "your_apps_clientSecret",
  "scopes": "openid profile email offline_access",
  "redirectUri": "https://your_apps_redirectUri.de"
}
```
Don't forget to add the /assets/ folder as asset to your pubspec.yaml file:
```
flutter:
  assets:
    - assets/
```
Per default, the SDK will search for this configuration file under '<projectRootDirectory>/assets', but you can also define any other path where the SDK should search for this configuration.
Note, that you will have to provide the path to the configuration within your code to the SDK if you chose so.
You can do this by calling ```checkAndLoadConfig({configPath: "your/custom/path/to/your/cidaas_config.json"})``` from within your code before the first login event is triggered.

### Overview
The SDK is using the [Bloc pattern](https://pub.dev/packages/bloc).

There are two important classes to be used:
* The *Cidaas* class, which can be implemented and listens to your current Authentication State to decide which Widget should get displayed,
* the *CidaasLoginProvider*, which provides static methods to be used in the context of authorization.

#### Integration
To integrate the SDK into your application, you will need to implement the *Cidaas* class.
This class encapsulates the state logic used by the authentication Bloc.
All it needs, is the information what should be displayed when your user is:
* Not logged in
* Ís logged in
* The SDK is doing some asynchronous tasks
* The Authentication was not successful

This is done via the four methods
* getLoggedOutScreen()
* getLoggedInScreen()
* getSplashScreen()
* getAuthenticationFailureScreen()

All of them return the Widgets which should get displayed in the respective cases.
The Widget returned by getLoggedOutScreen() should provide a button to start the authentication.
This button should call CidaasLoginProvider.doLogin(context) to trigger the authentication.
In the same way, CidaasLoginProvider.doLogout(context) can be called to trigger the logout.

```
class MyCidaasImpl extends Cidaas {
  
  @override
  Widget getLoggedOutScreen({context}) {
    return Center(
        child: RaisedButton(
      child: Text('Login'),
      onPressed: () {
        CidaasLoginProvider.doLogin(context);
      },
    ));
  }
  
  @override
  Widget getLoggedInScreen({tokenEntity}) {
    return MyCustomLoggedInScreen(tokenEntity: tokenEntity);
  }

  @override
  Widget getSplashScreen() {
    return Center(
      //child: CircularProgressIndicator(),
      child: Text('Please wait'),
    );
  }

  @override
  Widget getAuthenticationFailureScreen({errorMessage}) {
    return Scaffold(
        body: Center(
      child: Text('$errorMessage', style:
        TextStyle(
        fontWeight: FontWeight.bold,
        color: Colors.red)),
    ));
  }
}

```
To integrate your CidaasImplementation, you will need to provide the AuthenticationBloc used by it to your build context.
This is done like this:

```
@override
  Widget build(BuildContext context) {
    return BlocProvider<AuthenticationBloc>(
      create: (context) {
        return AuthenticationBloc();
      },
      child: MaterialApp(
        home: Scaffold(
            appBar: AppBar(
              title: Text('App'),
            ),
            body: MyCidaasImpl()),
        routes: {
          App.route: (context) => App(),
          MyCustomLoggedInScreen.route: (context) => MyCustomLoggedInScreen()
        },
      ),
    );
  }
```
Note, using the Bloc pattern you don't need the routes defined here in the *MaterialApp*.

#### Obtaining the access_token
To obtain the access_token after the user has logged in, you can use
```
TokenEntity tokenEntity = await CidaasLoginProvider.getStoredAccessToken();
```
The returned TokenEntity will hold the accessToken, idToken, sub & refreshToken.
Note that if the accessToken is expired or will expire in less than 60 seconds, this method will automatically
trigger the refresh_token flow to obtain a new access_token, if the refreshToken is available.  
To make the refresh Token available to your application, you will need to provide the ```offline_access``` scope.
Read more about how cidaas handles scopes [here](https://docs.cidaas.de/manage-applications/scope-management.html#scope-management).

After the first login, the retrieved TokenEntity can be retrieved via the getLoggedInScreen()-method implementation as well:
```
  @override
  Widget getLoggedInScreen({tokenEntity}) {
    return MyCustomLoggedInScreen(tokenEntity: tokenEntity);
  }
 ```
 This way, you can pass the initial tokenEntity directly to your widget to be used.

#### Get the token claim set:
You can decode the token claim set via ```CidaasLoginProvider.getTokenClaimSetForToken(tokenEntity.idToken)```
You can either provide the accessToken or the idToken stored.
If the idToken is not set for your application, make sure the ```openid``` scope is set.

#### Check if the user is logged in in your code:
To check manually (from your code) if the user has logged in, call the
```CidaasLoginProvider.isAuth()``` method.
This returns Future<bool>, which will complete to *true*, if the user is logged in, & to *false* if the user is not.

#### Trigger login & logout
You can trigger the login & the logout anywhere from your code with these methods:
* ```CidaasLoginProvider.doLogin(context)```
* ```CidaasLoginProvider.doLogout(context)```
Note the context provided must contain the AuthenticationBloc.

If the user is already logged in, the login page will not get triggered and the user will get redirected
to the Screen defined by the getLoggedInScreen()-Method directly.

#### Get the configuration
You can get the cidaas configuration by calling CidaasLoginProvider.getCidaasConf() like this:  
```CidaasConfig cidaasConfig = await CidaasLoginProvider.getCidaasConf();```
You can get the retrieved OpenIdConfiguration for your cidaas instance like this:
```OpenIdConfiguration idConfigLater = await CidaasLoginProvider.getOpenIdConfiguration();```

#### How is the access_token/ the id_token stored?
The Tokens are stored using [flutter_secure_storage](https://pub.dev/packages/flutter_secure_storage), this translates to

* Keychain for iOS
* & AES encryption for Android. The AES secret key is encrypted with RSA and RSA key is stored in KeyStore

#### Further documentation
For further documentation, have a look at the [cidaas docs](https://docs.cidaas.de)
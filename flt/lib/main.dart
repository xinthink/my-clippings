import 'package:flutter/material.dart';
//import 'package:notever/local.dart' show FirebaseConfig;
import 'package:notever/screens.dart' show HomeScreen, AuthScreen;

void main() {
//  FirebaseConfig.initialize(); // local debugging only
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notever - sync your kindle clippings',
      theme: Theme.of(context).copyWith(
        brightness: Brightness.dark,
        primaryColor: Colors.green.shade900,
        accentColor: Colors.green.shade500,
        floatingActionButtonTheme: Theme.of(context).floatingActionButtonTheme.copyWith(
          backgroundColor: Colors.green.shade500,
        ),
      ),
      initialRoute: '/',
      routes: <String, WidgetBuilder>{
        '/': (_) => HomeScreen(),
      },
      onGenerateRoute: _generateRoute,
    );
  }

  Route _generateRoute(RouteSettings settings) {
    if (settings.name?.isNotEmpty != true) return null;

    final uri = Uri.parse(settings.name);
    final path = uri.path ?? '';
    final q = uri.queryParameters ?? <String, String>{};
    switch (path) {
      case '/auth':
        return _createRoute(settings, (_) => AuthScreen(uid: q['uid']));
        break;
      default:
        return null;
    }
  }

  Route _createRoute(RouteSettings settings, WidgetBuilder builder) =>
    MaterialPageRoute<void>(
      settings: settings,
      builder: builder,
    );
}

import 'package:flutter/material.dart';
import 'package:topup2p/widgets/login.dart';
import 'package:topup2p/widgets/register.dart';
import 'package:topup2p/widgets/mainpage.dart';
import 'package:topup2p/widgets/favorites_widget.dart';
import 'package:topup2p/widgets/games.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  //const GamesList().initImages();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Topup2p',
      theme: ThemeData(
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.black,
            elevation: 0,
            shadowColor: Colors.transparent,
          ),
        ),
        textTheme: const TextTheme(
          headline1: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
          headline6: TextStyle(fontSize: 26.0, fontStyle: FontStyle.italic),
          bodyText2: TextStyle(fontSize: 14.0, fontFamily: 'Hind'),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          toolbarHeight: 66,
        ),
        primarySwatch: Colors.blueGrey,
      ),
      home: const MainPage(),
    );
  }
}
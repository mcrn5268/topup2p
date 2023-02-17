import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:topup2p/seller/seller-main.dart';
import 'app_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:topup2p/user/widgets/login.dart';
import 'package:topup2p/user/widgets/register.dart';
import 'package:topup2p/user/widgets/seller/seller.dart';
import 'package:topup2p/user/widgets/mainpage-widgets/mainpage.dart';
import 'package:topup2p/user/widgets/mainpage-widgets/favorites-widgets/favorites.dart';
import 'package:topup2p/user/widgets/mainpage-widgets/games-widgets/games.dart';
import 'package:topup2p/global/globals.dart';
import 'package:topup2p/user/widgets/seller/seller.dart';
import 'package:topup2p/global/globals.dart' as GlobalValues;

import 'firebase_options.dart';
import 'user/widgets/forgotpassword.dart';

// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   // runApp(ChangeNotifierProvider(
//   //   create: (context) => ApplicationState(),
//   //   builder: ((context, child) => const Topup2p()),
//   // ));
//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );
//   runApp(ChangeNotifierProvider(
//     create: (context) => ApplicationState(),
//     builder: ((context, child) => const Topup2p()),
//   ));
// }

void main() {
  runApp(ChangeNotifierProvider(
    create: (context) => ApplicationState(),
    builder: ((context, child) => const Topup2p()),
  ));
  //runApp(const Topup2p());
}

class Topup2p extends StatelessWidget {
  const Topup2p({super.key});

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
          displayLarge: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
          titleLarge: TextStyle(fontSize: 26.0, fontStyle: FontStyle.italic),
          bodyMedium: TextStyle(fontSize: 14.0, fontFamily: 'Hind'),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          toolbarHeight: 66,
        ),
        primarySwatch: Colors.blueGrey,
      ),
      home: Consumer<ApplicationState>(builder: (context, appState, _) {
        print(GlobalValues.isLoggedIn);
        return GlobalValues.isLoggedIn
            //ApplicationState().loggedIn
            ? (userType == 'normal')
                ? const MainPage()
                : const SellerMain()
            : const LoginPage();
      }),

      //ApplicationState().loggedIn ? const MainPage() : const LoginPage(),

      //home: const GameSellerList('Mobile Legends'),
      //home: const MainPage(),
      //home: const LoginPage(),
    );
  }
}

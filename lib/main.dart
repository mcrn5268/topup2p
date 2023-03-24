import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:topup2p/providers/favorites_provider.dart';
import 'package:topup2p/providers/payment_provider.dart';
import 'package:topup2p/providers/sell_items_provider.dart';
import 'package:topup2p/screens/login.dart';
import 'package:topup2p/screens/seller/seller_main.dart';
import 'package:topup2p/screens/user/user_main.dart';
import 'package:topup2p/utilities/globals.dart';
import 'package:topup2p/utilities/models_utils.dart';
import 'package:flutter/material.dart';
import 'package:topup2p/providers/user_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: const Topup2p(),
    ),
  );
}

class Topup2p extends StatelessWidget {
  const Topup2p({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Topup2p',
        theme: ThemeData(
          textTheme: const TextTheme(
            displayLarge:
                TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
            titleLarge: TextStyle(fontSize: 26.0, fontStyle: FontStyle.italic),
            bodyMedium: TextStyle(fontSize: 14.0, fontFamily: 'Hind'),
            bodyLarge: TextStyle(
              fontSize: 16,
              color: Colors.black,
            ),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              side: const BorderSide(color: Colors.black),
              backgroundColor: Colors.transparent,
              foregroundColor: Colors.black,
              elevation: 0,
              shadowColor: Colors.transparent,
            ),
          ),
          appBarTheme: const AppBarTheme(
              backgroundColor: Colors.transparent,
              elevation: 0,
              toolbarHeight: 66,
              titleTextStyle: TextStyle(fontSize: 20, color: Colors.black)),
          primaryColor: Colors.white,
          brightness: Brightness.light,
          primaryColorDark: Colors.black,
          canvasColor: Colors.white,
          primarySwatch: Colors.blueGrey,
        ),
        darkTheme: ThemeData(
          // primaryColor: Colors.black12,
          brightness: Brightness.dark,
          //primaryColorDark: Colors.black12,
          //indicatorColor: Colors.white,
          canvasColor: Colors.grey[900],
          primarySwatch: Colors.teal,
          iconTheme: const IconThemeData(color: Colors.white),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              side: const BorderSide(color: Colors.white),
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
              elevation: 0,
              shadowColor: Colors.transparent,
            ),
          ),
          textTheme: const TextTheme(
            displayLarge:
                TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
            titleLarge: TextStyle(fontSize: 26.0, fontStyle: FontStyle.italic),
            bodyMedium: TextStyle(fontSize: 14.0, fontFamily: 'Hind'),
            bodyLarge: TextStyle(
              fontSize: 16,
              color: Colors.white,
            ),
          ),
          appBarTheme: const AppBarTheme(
              backgroundColor: Colors.transparent,
              elevation: 0,
              toolbarHeight: 66,
              titleTextStyle: TextStyle(fontSize: 20, color: Colors.white)),
        ), // standard dark theme
        themeMode: ThemeMode.system, // device controls theme
        home: Consumer<UserProvider>(
          builder: (context, userProvider, _) {
            if (userProvider.user == null) {
              // User is not logged in
              return const LoginScreen();
            } else {
              // User is logged in
              itemsObjectList = convertMapsToItems(productItemsMap);

              if (userProvider.user!.type == 'normal') {
                return ChangeNotifierProvider(
                  create: (_) => FavoritesProvider(),
                  child: const UserMainScreen(),
                );
              } else if (userProvider.user!.type == 'seller') {
                return MultiProvider(
                  providers: [
                    ChangeNotifierProvider(create: (_) => SellItemsProvider()),
                    ChangeNotifierProvider(create: (_) => PaymentProvider()),
                  ],
                  child: const SellerMain(),
                );
              } else {
                return const Center(child: Text('Something went wrong'));
              }
            }
          },
        ));
  }
}

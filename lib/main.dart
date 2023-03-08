import 'package:provider/provider.dart';
import 'package:topup2p/providers/favorites_provider.dart';
import 'package:topup2p/providers/payment_provider.dart';
import 'package:topup2p/providers/sell_items_provder.dart';
import 'package:topup2p/screens/login.dart';
import 'package:topup2p/screens/seller/seller_main.dart';
import 'package:topup2p/screens/user/user_main.dart';
import 'package:topup2p/utilities/globals.dart';
import 'package:topup2p/utilities/models_utils.dart';
import 'package:flutter/material.dart';
import 'package:topup2p/providers/user_provider.dart';

void main() {
  runApp(const Topup2p());
}

class Topup2p extends StatelessWidget {
  const Topup2p({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: MaterialApp(
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
            displayLarge:
                TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
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
        ),
      ),
    );
  }
}

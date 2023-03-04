import 'package:provider/provider.dart';
import 'package:topup2p/providers/favorites_provider.dart';
import 'package:topup2p/providers/payment_provider.dart';
import 'package:topup2p/providers/sell_items_provder.dart';
import 'package:topup2p/screens/login.dart';
import 'package:topup2p/screens/seller/seller_main.dart';
import 'package:topup2p/screens/user/user_main.dart';
import 'package:topup2p/utilities/globals.dart';
import 'package:topup2p/utilities/models_utils.dart';
import 'package:topup2p/widgets/loading_screen.dart';
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
          // pageTransitionsTheme: PageTransitionsTheme(
          //   builders: {
          //     TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          //     TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          //   },
          // ),
        ),
        home: Consumer<UserProvider>(
          builder: (context, UserProvider, _) {
            if (UserProvider.user == null) {
              // User is not logged in
              return LoginScreen();
            } else {
              // User is logged in
              itemsObjectList = convertMapsToItems(productItemsMap);

              if (UserProvider.user!.type == 'normal') {
                return ChangeNotifierProvider(
                  create: (_) => FavoritesProvider(),
                  child: UserMainScreen(),
                );
              } else if (UserProvider.user!.type == 'seller') {
                //toadd
                return MultiProvider(
                  providers: [
                    ChangeNotifierProvider(create: (_) => SellItemsProvider()),
                    ChangeNotifierProvider(create: (_) => PaymentProvider()),
                  ],
                  child: SellerMain(),
                );
              } else {
                return Center(child: const Text('Something went wrong'));
              }
            }
          },
        ),
      ),
    );
  }
}

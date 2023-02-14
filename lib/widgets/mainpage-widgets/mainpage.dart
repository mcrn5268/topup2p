import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:topup2p/cloud/readDB.dart';
import 'package:topup2p/sqflite/firestore-sqflite.dart';
import 'package:topup2p/sqflite/sqfliite.dart';
import 'package:topup2p/sqflite/sqflite-global.dart';
import 'package:topup2p/widgets/mainpage-widgets/favorites-widgets/favorites.dart';
import 'package:topup2p/widgets/mainpage-widgets/games-widgets/games.dart';
import 'package:topup2p/widgets/cons-widgets/appbar.dart';
import 'package:topup2p/widgets/register.dart';
import 'package:topup2p/widgets/textwidgets/headline6.dart';
import 'package:topup2p/widgets/cons-widgets/loadingscreen.dart';
import 'package:topup2p/global/globals.dart' as GlobalValues;
import 'package:provider/provider.dart';
import 'package:topup2p/provider/favoritesprovider.dart';

import '../../app_state.dart';
import '../../cloud/writeDB.dart';
import '../../global/globals.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  //var globals = GlobalValues;
  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    //FutureCall();
    return FutureBuilder(
        //future: Future.wait([DatabaseHelper().checkDatabase(), DatabaseHelper().checkUserData(), getSqfliteData()]),
        future: DatabaseHelper().checkDatabase().then((value) {
          return DatabaseHelper().checkUserData().then((value) {
            return checkAndUpdateData().then((value) {
              return getSqfliteData();
            });
          });
        }),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return ChangeNotifierProvider<FavoritesProvider>(
                create: (context) => FavoritesProvider(),
                child: Builder(
                  builder: ((context) {
                    return Scaffold(
                        appBar:
                            AppBarWidget(true, true, GlobalValues.isLoggedIn),
                        body: ListView(
                          addAutomaticKeepAlives: true,
                          shrinkWrap: false,
                          children: const <Widget>[
                            Divider(),
                            HeadLine6('FAVORITES'),
                            FavoritesList(),
                            Divider(),
                            HeadLine6('GAMES'),
                            GamesList(),
                          ],
                        ));
                  }),
                ));
          } else {
            return const LoadingScreen();
          }
        });
  }
}

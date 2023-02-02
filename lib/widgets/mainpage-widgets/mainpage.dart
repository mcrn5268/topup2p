import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:topup2p/widgets/mainpage-widgets/favorites-widgets/favorites.dart';
import 'package:topup2p/widgets/mainpage-widgets/games-widgets/games.dart';
import 'package:topup2p/widgets/cons-widgets/appbarwidgets/appbar.dart';
import 'package:topup2p/widgets/textwidgets/headline6.dart';
import 'package:topup2p/widgets/cons-widgets/loadingscreen.dart';
import 'package:topup2p/global/globals.dart' as GlobalValues;
import 'package:provider/provider.dart';
import 'package:topup2p/provider/favoritesprovider.dart';

import '../../global/globals.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  //var globals = GlobalValues;
  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late Future _flag;
  Future initImages() async {
    // >> To get paths you need these 2 lines
    final manifestContent = await rootBundle.loadString('AssetManifest.json');

    final Map<String, dynamic> manifestMap = json.decode(manifestContent);
    // >> To get paths you need these 2 lines

    final imagePaths = manifestMap.keys
        .where((String key) => key.contains('assets/gameslogos/'))
        .toList();
    //Map<String, String> nameMap = Map.fromIterables("name", productItems);
    for (int i = 0; i < GlobalValues.productItems.length; i++) {
      late final Map<String, dynamic> tempMap = {};
      tempMap['name'] = GlobalValues.productItems[i];
      tempMap['image'] = imagePaths[i];
      tempMap['isFav'] = false;
      if (tempMap['name'] == "Mobile Legends" ||
          tempMap['name'] == "Valorant" ||
          tempMap['name'] == "Steam Wallet Code" 
          // tempMap['name'] == "Garena Shells" ||
          // tempMap['name'] == "Free Fire MAX" ||
          // tempMap['name'] == "Grand Theft Auto V: Premium Online Edition"
          ) {
        tempMap['isFav'] = true;
      }
      GlobalValues.theMap.add(tempMap);
    }

    setState(() {});
    return true;
  }

  @override
  initState() {
    super.initState();
    _flag = initImages();
  }

  @override
  Widget build(BuildContext context) {
    //print height
    return FutureBuilder(
        future: _flag,
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return ChangeNotifierProvider<FavoritesProvider>(
                create: (context) => FavoritesProvider(),
                child: Builder(
                  builder: ((context) {
                    return Scaffold(
                        appBar: AppBarWidget(true, true, GlobalValues.isLoggedIn),
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

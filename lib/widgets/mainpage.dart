import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:topup2p/widgets/favorites.dart';
import 'package:topup2p/widgets/games.dart';
import 'package:topup2p/widgets/appbar.dart';
import 'package:topup2p/widgets/textwidgets/headline6.dart';
import 'package:topup2p/widgets/loadingscreen.dart';
import 'package:topup2p/global/globals.dart' as GlobalValues;
import 'package:provider/provider.dart';
import 'package:topup2p/provider/favoritesprovider.dart';

import '../global/globals.dart';

class MainPage extends StatefulWidget {
  MainPage({super.key});

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
      // if (tempMap['name'] == "Mobile Legends" ||
      //     tempMap['name'] == "Valorant" ||
      //     tempMap['name'] == "Steam Wallet Code" ||
      //     tempMap['name'] == "Garena Shells" ||
      //     tempMap['name'] == "Free Fire Max" ||
      //     tempMap['name'] == "Grand Theft Auto V: Premium Online Edition") {
      //   tempMap['isFav'] = true;
      // }
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
            return
              ChangeNotifierProvider<FavoritesProvider>(
                create: (context) => FavoritesProvider(),
                child: Scaffold(
                  appBar: const AppBarWidget(),
                  body: ListView(
                    shrinkWrap: true,
                    children: const <Widget>[
                      Divider(),
                      HeadLine6('FAVORITES'),
                      FavoritesList(),
                      //dynamically adjust # of shown items depending on the width
                      Divider(),
                      HeadLine6('GAMES'),
                      GamesList(),
                    ],
                  )
                ),

                
              );
            
          
          } else {
            return const LoadingScreen();
          }
        });
  }
}



// return Scaffold(
//                 appBar: const AppBarWidget(),
//                 body: ListView(
//                   shrinkWrap: true,
//                   children: const <Widget>[
//                     Divider(),
//                     HeadLine6('FAVORITES'),
//                     FavoritesList(),
//                     //dynamically adjust # of shown items depending on the width
//                     Divider(),
//                     HeadLine6('GAMES'),
//                     GamesList(),
//                   ],
//                 ));
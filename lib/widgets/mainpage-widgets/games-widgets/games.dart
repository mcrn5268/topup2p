import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:topup2p/global/globals.dart' as GlobalValues;
import 'package:topup2p/widgets/mainpage-widgets/mainpage.dart';
import 'package:topup2p/widgets/icons/favoriteicon.dart';
import 'package:provider/provider.dart';
import 'package:topup2p/provider/favoritesprovider.dart';
import 'package:topup2p/widgets/seller/seller.dart';

late var gamesContext;

class GamesList extends StatefulWidget {
  const GamesList({Key? key}) : super(key: key);
  @override
  State<GamesList> createState() => _GamesListState();
}

class _GamesListState extends State<GamesList> {
  bool _showMore = false;
  late String _viewML = 'View More';

  changeShowMore() {
    setState(() {
      _showMore = !_showMore;
      _viewML = _showMore ? 'View Less' : 'View More';
    });
  }

  @override
  Widget build(BuildContext context) {
    gamesContext = context;
    int countRow = GlobalValues.logicalWidth ~/ 150;
    return Column(
      children: [
        //change to slivergrid
        GridView.count(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          crossAxisCount: countRow,
          childAspectRatio: 0.76,
          mainAxisSpacing: 5,
          crossAxisSpacing: 5,
          padding: const EdgeInsets.all(10),
          children: <Widget>[
            ...GlobalValues.theMap.map(
              (mapKey) => Card(
                key: ValueKey(mapKey['name']),
                elevation: 0,
                color: Colors.transparent,
                child: Stack(children: [
                  Container(
                    clipBehavior: Clip.hardEdge,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: InkWell(
                      onTap: () {
                        MainPageNavigator(
                            mapKey['name'], mapKey['image-banner']);

                        // Navigator.of(context)
                        //     .push(
                        //   MaterialPageRoute(
                        //     builder: (_) =>
                        //         ChangeNotifierProvider<FavoritesProvider>.value(
                        //       value: FavoritesProvider(),
                        //       child: GameSellerList(
                        //           mapKey['name'], mapKey['image-banner']),
                        //     ),
                        //   ),
                        // )
                        //     .then((value) {
                        //   //setState(() {
                        //   Provider.of<FavoritesProvider>(context, listen: false)
                        //       .notifList();
                        //   //});
                        // });
                      },
                      child: Column(
                        children: [
                          Expanded(
                              flex: 3, child: Image.asset(mapKey['image']!)),
                          Expanded(
                            child: Container(
                              width: double.infinity,
                              color: Colors.grey,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    mapKey['name']!,
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  //Consumer<FavoritesProvider>(builder: (_, __, ___) {
                  FavoritesIcon(mapKey['name'], 35)
                  //}),
                ]),
              ),
            )
          ]
              .take(_showMore ? GlobalValues.productItems.length : countRow * 3)
              .toList(),
        ),
        InkWell(
          onTap: () {
            changeShowMore();
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Text(_viewML),
          ),
        ),
      ],
    );
  }
}

void MainPageNavigator(String name, String banner, {bool? flag}) {
  if (flag == null) {
    Navigator.of(gamesContext)
        .push(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider<FavoritesProvider>.value(
          value: FavoritesProvider(),
          child: GameSellerList(name, banner),
        ),
      ),
    )
        .then((value) {
      //setState(() {
      Provider.of<FavoritesProvider>(gamesContext, listen: false).notifList();
      //});
    });
  } else {
    Navigator.of(gamesContext)
        .pushReplacement(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider<FavoritesProvider>.value(
          value: FavoritesProvider(),
          child: GameSellerList(name, banner),
        ),
      ),
    )
        .then((value) {
      //setState(() {
      Provider.of<FavoritesProvider>(gamesContext, listen: false).notifList();
      //});
    });
  }
}

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:topup2p/global/globals.dart' as GlobalValues;
import 'package:topup2p/widgets/mainpage-widgets/mainpage.dart';
import 'package:topup2p/widgets/icons/favoriteicon.dart';
import 'package:provider/provider.dart';
import 'package:topup2p/provider/favoritesprovider.dart';

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
    int countRow = GlobalValues.logicalWidth ~/ 150;
    return Column(
      children: [
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
                      color: Colors.teal[100],
                    ),
                    child: Column(
                      children: [
                        Expanded(flex: 3, child: Image.asset(mapKey['image']!)),
                        Expanded(
                          child: Container(
                            width: double.infinity,
                            color: Colors.grey,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                mapKey['name']!,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Consumer<FavoritesProvider>(builder: (_, favorites, child) {
                    return FavoritesIcon(mapKey['name'], 35);
                  }),
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

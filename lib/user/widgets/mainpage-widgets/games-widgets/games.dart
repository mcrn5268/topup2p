import 'dart:convert';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:topup2p/global/globals.dart' as GlobalValues;
import 'package:topup2p/user/widgets/mainpage-widgets/mainpage.dart';
import 'package:topup2p/user/widgets/icons/favoriteicon.dart';
import 'package:provider/provider.dart';
import 'package:topup2p/user/provider/favoritesprovider.dart';
import 'package:topup2p/user/widgets/mainpage-widgets/sort-games.dart';
import 'package:topup2p/user/widgets/seller/seller.dart';

late var gamesContext;

class GamesList extends StatefulWidget {
  const GamesList({Key? key}) : super(key: key);
  @override
  State<GamesList> createState() => _GamesListState();
}

class _GamesListState extends State<GamesList> {
  bool _showMore = false;
  bool _isLoading = false;
  late String _viewML = 'View More';

  changeShowMore() {
    setState(() {
      _showMore = !_showMore;
      _viewML = _showMore ? 'View Less' : 'View More';
      _isLoading = !_isLoading;
    });
  }

  @override
  void initState() {
    super.initState();
    GamesSort().popuarity();
  }

  @override
  Widget build(BuildContext context) {
    gamesContext = context;
    int countRow = GlobalValues.logicalWidth ~/ 150;
    return Column(
      children: [
        //change to slivergrid
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 20),
              child: DropdownButton(
                icon: Icon(
                  Icons.sort,
                ),
                value: GlobalValues.selectedSort,
                items: [
                  DropdownMenuItem(
                    child: Text('A-Z'),
                    value: 1,
                  ),
                  DropdownMenuItem(
                    child: Text('Popularity'),
                    value: 2,
                  ),
                ],
                onChanged: (Object? value) {
                  setState(() {
                    GlobalValues.selectedSort = value as int;
                    if (value == 1) {
                      GamesSort().AtoZ();
                    } else if (value == 2) {
                      GamesSort().popuarity();
                    }
                  });
                },
              ),
            ),
          ],
        ),
        GridView.count(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          crossAxisCount: countRow,
          childAspectRatio: 0.76,
          mainAxisSpacing: 5,
          crossAxisSpacing: 5,
          padding: const EdgeInsets.all(10),
          children: <Widget>[
            ...GlobalValues.theMap
                .map((mapKey) => AnimationConfiguration.staggeredGrid(
                      position: index,
                      duration: const Duration(milliseconds: 375),
                      columnCount: 3,
                      child: ScaleAnimation(
                        child: FadeInAnimation(
                          child: Card(
                            key: ValueKey(mapKey['name']),
                            elevation: 0,
                            color: Colors.transparent,
                            child: Stack(children: [
                              InkWell(
                                onTap: () {
                                  MainPageNavigator(
                                      mapKey['name'], mapKey['image_banner']);
                                },
                                child: Column(
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(20.0),
                                          child: Image.asset(mapKey['image']!)),
                                    ),
                                    Expanded(
                                      child: Container(
                                        width: double.infinity,
                                        //color: Colors.grey,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
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
                              //Consumer<FavoritesProvider>(builder: (_, __, ___) {
                              FavoritesIcon(mapKey['name'], 35)
                              //}),
                            ]),
                          ),
                        ),
                      ),
                    ))
          ]
              .take(_showMore ? GlobalValues.productItems.length : countRow * 3)
              .toList(),
        ),
        InkWell(
          onTap: () {
            setState(() {
              _isLoading = !_isLoading;
            });
            changeShowMore();
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Visibility(
                  visible: !_isLoading,
                  child: Text(_viewML),
                ),
                Visibility(
                  visible: _isLoading,
                  child: CircularProgressIndicator(),
                ),
              ],
            ),
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
      PageRouteBuilder(
        pageBuilder: (_, __, ___) =>
            ChangeNotifierProvider<FavoritesProvider>.value(
          value: FavoritesProvider(),
          child: GameSellerList(name, banner),
        ),
        transitionsBuilder: (_, a, __, c) =>
            FadeTransition(opacity: a, child: c),
      ),
      // MaterialPageRoute(
      //   builder: (_) => ChangeNotifierProvider<FavoritesProvider>.value(
      //     value: FavoritesProvider(),
      //     child: GameSellerList(name, banner),
      //   ),
      // ),
    )
        .then((value) {
      //setState(() {
      Provider.of<FavoritesProvider>(gamesContext, listen: false).notifList();
      //});
    });
  } else {
    Navigator.of(gamesContext)
        .pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) =>
            ChangeNotifierProvider<FavoritesProvider>.value(
          value: FavoritesProvider(),
          child: GameSellerList(name, banner),
        ),
        transitionsBuilder: (_, a, __, c) =>
            FadeTransition(opacity: a, child: c),
      ),
    )
        .then((value) {
      Provider.of<FavoritesProvider>(gamesContext, listen: false).notifList();
    });
  }
}

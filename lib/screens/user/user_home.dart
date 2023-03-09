// ignore_for_file: non_constant_identifier_names

import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:topup2p/providers/favorites_provider.dart';
import 'package:topup2p/screens/user/shop.dart';
import 'package:topup2p/utilities/globals.dart';
import 'package:topup2p/widgets/favorite_icon.dart';

BuildContext? gameContext;

class GamesList extends StatefulWidget {
  const GamesList({Key? key}) : super(key: key);
  @override
  State<GamesList> createState() => _GamesListState();
}

class _GamesListState extends State<GamesList> {
  bool _showMore = false;
  bool _isLoading = false;
  String _viewML = 'View More';

  changeShowMore() {
    setState(() {
      _showMore = !_showMore;
      _viewML = _showMore ? 'View Less' : 'View More';
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    int countRow = logicalWidth ~/ 150;
    gameContext = context;
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
            ...itemsObjectList.map((item) =>
                AnimationConfiguration.staggeredGrid(
                  position: itemsObjectList.indexOf(item),
                  duration: const Duration(milliseconds: 375),
                  columnCount:
                      _showMore ? itemsObjectList.length : countRow * 3,
                  child: ScaleAnimation(
                    child: FadeInAnimation(
                      child: Card(
                        key: ValueKey('${item.name}-games'),
                        elevation: 0,
                        color: Colors.transparent,
                        child: Stack(children: [
                          GestureDetector(
                            onTap: () {
                              GameItemScreenNavigator(
                                  name: item.name, flag: true);
                            },
                            child: Column(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20.0),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.5),
                                          spreadRadius: 1,
                                          blurRadius: 3,
                                          offset: const Offset(0, 1),
                                        ),
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(20.0),
                                      child: Image.asset(item.image),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: SizedBox(
                                    width: double.infinity,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          item.name,
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          FavoritesIcon(itemName: item.name, size: 35)
                        ]),
                      ),
                    ),
                  ),
                ))
          ].take(_showMore ? itemsObjectList.length : countRow * 3).toList(),
        ),
        InkWell(
          onTap: () {
            setState(() {
              _isLoading = true;
            });
            changeShowMore();
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child:
                _isLoading ? const CircularProgressIndicator() : Text(_viewML),
          ),
        ),
      ],
    );
  }
}

//purpose ontap for main, favorites and search game item
//why? search item won't work well bec of pushreplacement

Future<void> GameItemScreenNavigator(
    {required String name, required bool flag}) async {
  FavoritesProvider favProvider =
      Provider.of<FavoritesProvider>(gameContext!, listen: false);
  if (flag == true) {
    final value = await Navigator.push(
      gameContext!,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) =>
            ChangeNotifierProvider<FavoritesProvider>.value(
          value: FavoritesProvider(),
          child:
              GameSellScreen(gameName: name, favorites: favProvider.favorites),
        ),
        transitionsBuilder: (_, a, __, c) =>
            FadeTransition(opacity: a, child: c),
      ),
    );
    //check if something changed if yes then update
    if (value.length != favProvider.favorites.length) {
      favProvider.clearFavorites();
      favProvider.addItems(value);
    }
  } else {
    final value = await Navigator.pushReplacement(
      gameContext!,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) =>
            ChangeNotifierProvider<FavoritesProvider>.value(
          value: FavoritesProvider(),
          child:
              GameSellScreen(gameName: name, favorites: favProvider.favorites),
        ),
        transitionsBuilder: (_, a, __, c) =>
            FadeTransition(opacity: a, child: c),
      ),
    );
    //check if something changed if yes then update
    if (value.length != favProvider.favorites.length) {
      favProvider.clearFavorites();
      favProvider.addItems(value);
    }
  }
}

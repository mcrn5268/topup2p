import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter/material.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:topup2p/global/globals.dart' as GlobalValues;
import 'package:topup2p/widgets/cons-widgets/appbar.dart';
import 'package:topup2p/widgets/textwidgets/headline6.dart';

class GameSellerList extends StatefulWidget {
  GameSellerList(this.gameName, {super.key});
  final String gameName;
  late Map<String, dynamic> gamesMap;
  List<Map<String, dynamic>> gameShopList = [];

  @override
  State<GameSellerList> createState() => _GameSellerListState();
}

class _GameSellerListState extends State<GameSellerList> {
  @override
  void initState() {
    super.initState();
    bool flag = false;
    for (int i = 0; i < GlobalValues.shopList.length && flag == false; i++) {
      widget.gamesMap = GlobalValues.shopList[i];
      if (widget.gamesMap['game'] == widget.gameName) {
        flag = true;
      }
    }
    for (int i = 1; i <= widget.gamesMap['shops'].length; i++) {
      late Map<String, dynamic> tempMap = {};
      late List<Map<String, List<String>>> tempMap2 = [];
      GlobalValues.gameShop
          .map((val) => {
                if (val['shop-name'] == widget.gamesMap['shops'][i - 1])
                  {
                    tempMap['shop-name'] = val['shop-name'],
                    tempMap['mop'] = val['mop'],
                    tempMap2.addAll(val['games-price-rate'])
                  }
              })
          .toList();
      tempMap2
          .map((valRate) => {
                for (var k in valRate.keys)
                  {
                    if (k == widget.gameName)
                      {tempMap['price-rate'] = valRate[k]}
                  }
              })
          .toList();
      widget.gameShopList.add(tempMap);
    }
    //print(gameShopList);
  }

  @override
  Widget build(BuildContext context) {
    //check for available seller for this game
    return Scaffold(
        appBar: AppBarWidget(false, false, GlobalValues.isLoggedIn),
        body: CustomScrollView(slivers: [
          SliverPinnedHeader(
              child: Container(
            //alignment: Alignment.topCenter,
            decoration:
                BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor),
            width: double.infinity,
            height: 210.1,
            child: Image.asset('assets/gameslogos-banner/1-b.jpeg'),
          )),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                return Column(
                  children: [
                    ...widget.gameShopList.map(
                      (val) => Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Container(
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.black)),
                            height: 150,
                            //alignment: Alignment.center,
                            child: Row(
                              children: [
                                SizedBox(
                                    width: 150,
                                    child: Image.asset(
                                        'assets/images/person-placeholder.png')),
                                Expanded(
                                    flex: 3,
                                    child: Column(children: [
                                      Padding(
                                        padding: const EdgeInsets.only(top: 5),
                                        child: Stack(
                                          children: [
                                            Container(
                                              alignment: Alignment.center,
                                              child: Text(
                                                val['shop-name'],
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleLarge,
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                            Container(
                                                alignment:
                                                    Alignment.centerRight,
                                                child: const Icon(Icons
                                                    .arrow_forward_ios_outlined)),
                                          ],
                                        ),
                                      ),
                                      const Divider(),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 5),
                                        child: Text(widget.gameName),
                                      ),
                                      Row(
                                        children: [
                                          for (var i = 1;
                                              i <=
                                                  ((val['price-rate'].length) /
                                                          3)
                                                      .ceil();
                                              i++) ...[
                                            Expanded(
                                                child: Column(
                                              children: [
                                                for (var j = (i == 1)
                                                        ? 0
                                                        : (i == 2)
                                                            ? 3
                                                            : 6;
                                                    j < i * 3 &&
                                                        j <
                                                            val['price-rate']
                                                                .length;
                                                    j++) ...[
                                                  Text(val['price-rate'][j])
                                                ]
                                              ],
                                            )),
                                          ],
                                        ],
                                      ),
                                      SizedBox(
                                        height: 28,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            for (var e in val['mop']) ...[
                                              Image.asset(e, width: 50)
                                            ]
                                          ],
                                        ),
                                      ),
                                    ]))
                              ],
                            )),
                      ),
                    )
                  ],
                );
              },
              childCount: 1,
            ),
          ),
        ]));
  }
}
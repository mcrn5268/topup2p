import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:topup2p/cloud/readDB.dart';
import 'package:topup2p/global/globals.dart' as GlobalValues;
import 'package:topup2p/global/globals.dart';
import 'package:topup2p/user/provider/favoritesprovider.dart';
import 'package:topup2p/cons-widgets/appbar.dart';
import 'package:topup2p/cons-widgets/loadingscreen.dart';
import 'package:topup2p/user/widgets/textwidgets/headline6.dart';
import 'package:topup2p/user/widgets/icons/favoriteicon.dart';

  bool sellerFlag = false;
class GameSellerList extends StatefulWidget {
  GameSellerList(this.gameName, this.gameBanner, {super.key});
  final String gameBanner;
  final String gameName;
  Map<String, dynamic> gamesMap = {};

  @override
  State<GameSellerList> createState() => _GameSellerListState();
}

class _GameSellerListState extends State<GameSellerList> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: Future.wait([readSellerData(widget.gameName)]),
        builder: ((context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Scaffold(
                appBar: AppBarWidget(false, false, GlobalValues.isLoggedIn),
                body: sellerBody());
          } else {
            return const LoadingScreen();
          }
        }));

    // return Scaffold(
    //     appBar: AppBarWidget(false, false, GlobalValues.isLoggedIn),
    //     body: sellerBody());
  }

  //seller list/body
  Widget sellerBody() {
    if (sellerFlag == true) {
      return CustomScrollView(slivers: [
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) {
              return Column(
                children: [
                  Stack(children: [
                    Container(
                      decoration: BoxDecoration(
                          color: Theme.of(context).scaffoldBackgroundColor),
                      width: double.infinity,
                      height: 210.1,
                      child: Image.asset(widget.gameBanner),
                    ),
                    FavoritesIcon(widget.gameName, 50)
                  ]),
                  ...gameShopList.map(
                    (val) => Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Container(
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.black)),
                          height: 150,
                          child: Row(
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(15, 0, 15, 0),
                                child: Container(
                                  width: 100,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: DecorationImage(
                                        image: AssetImage(
                                            'assets/images/estore.png')),
                                  ),
                                ),
                              ),
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
                                              alignment: Alignment.centerRight,
                                              child: const Icon(Icons
                                                  .arrow_forward_ios_outlined)),
                                        ],
                                      ),
                                    ),
                                    const Divider(),
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 5),
                                      child: Text(widget.gameName),
                                    ),
                                    Row(
                                      children: [
                                        for (var i = 1;
                                            i <=
                                                ((val['game-rates'].length) / 3)
                                                    .ceil();
                                            i++) ...[
                                          Expanded(
                                              child: Column(
                                            children: [
                                              for (var j = (i == 1)? 0 : (i == 2)? 3: 6;j < i * 3 && j <val['game-rates'].length;j++) ...[
                                                Text(
                                                    "₱${val['game-rates']['rate${j+1}']['php']} : ${val['game-rates']['rate${j+1}']['digGoods']}")
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
                                          for (var i = 1;
                                              i <= val['mop'].length;
                                              i++) ...[
                                            Image.asset(
                                                'assets/images/MoP/${val["mop"]["mop$i"]}.png',
                                                width: 50)
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
      ]);
    } else {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: SizedBox(
                width: 300,
                height: 300,
                child: Image.asset('assets/images/exclamation.png'),
              ),
            ),
            Text("Sorry there's no seller/shop for ${widget.gameName}")
          ],
        ),
      );
    }
  }
}

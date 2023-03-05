import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';
import 'package:topup2p/cloud/firestore.dart';
import 'package:topup2p/models/item_model.dart';
import 'package:topup2p/providers/favorites_provider.dart';
import 'package:topup2p/providers/user_provider.dart';
import 'package:topup2p/screens/chat.dart';
import 'package:topup2p/utilities/other_utils.dart';
import 'package:topup2p/utilities/image_file_utils.dart';
import 'package:topup2p/utilities/models_utils.dart';
import 'package:topup2p/widgets/appbar/appbar.dart';
import 'package:topup2p/widgets/favorite_icon.dart';
import 'package:topup2p/widgets/loading_screen.dart';

class GameSellScreen extends StatefulWidget {
  GameSellScreen({required this.gameName, required this.favorites, super.key});
  final String gameName;
  final List<Item> favorites;
  @override
  State<GameSellScreen> createState() => _GameSellScreenState();
}

class _GameSellScreenState extends State<GameSellScreen> {
  @override
  Widget build(BuildContext context) {
    UserProvider userProvider =
        Provider.of<UserProvider>(context, listen: false);
    FavoritesProvider favProvider =
        Provider.of<FavoritesProvider>(context, listen: false);
    return FutureBuilder(
        future: FirestoreService()
            .read(collection: 'seller_games_data', documentId: widget.gameName),
        builder: ((context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            favProvider.addItems(widget.favorites);
            return Scaffold(
                appBar: AppBarWidget(
                  home: false,
                  search: false,
                  isloggedin: userProvider.user != null,
                  fromGameSellScreen: favProvider.favorites,
                ),
                body: sellerBody(snapshot.data != null
                    ? snapshot.data as Map<String, dynamic>
                    : {}));
          } else {
            return const LoadingScreen();
          }
        }));
  }

  //seller list/body
  Widget sellerBody(Map<String, dynamic> data) {
    if (data.isNotEmpty) {
      var gameItem = getItemByName(widget.gameName);
      List<Map<dynamic, dynamic>> shopList = mapToList(data);
      return Column(
        children: [
          Stack(children: [
            Container(
              decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor),
              width: double.infinity,
              //height: 210.1,
              child: Image.asset(gameItem!.image_banner),
            ),
            FavoritesIcon(itemName: widget.gameName,size: 50)
          ]),
          Flexible(
            child: ListView.builder(
              itemCount: shopList.length,
              itemBuilder: (BuildContext context, int index) {
                return AnimationConfiguration.staggeredList(
                  position: index,
                  duration: const Duration(milliseconds: 375),
                  child: SlideAnimation(
                    verticalOffset: 50.0,
                    child: FadeInAnimation(
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: () async {
                              String? convId;
                              final Map<String, dynamic>? snapshot =
                                  await FirestoreService().read(
                                      collection: 'messages',
                                      documentId: 'users_conversations',
                                      subcollection: shopList[index]['info']
                                          ['uid'],
                                      subdocumentId: Provider.of<UserProvider>(
                                              context,
                                              listen: false)
                                          .user!
                                          .uid);
                              if (snapshot != null) {
                                convId = snapshot['conversationId'];
                              }
                              Navigator.push(
                                context,
                                PageRouteBuilder(
                                  pageBuilder: (_, __, ___) => ChatScreen(
                                    convId: convId,
                                    userId: shopList[index]['info']['uid'],
                                    userName: shopList[index]['info']['name'],
                                    userImage: shopList[index]['info']['image'],
                                  ),
                                  transitionsBuilder: (_, a, __, c) =>
                                      FadeTransition(opacity: a, child: c),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Container(
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .scaffoldBackgroundColor,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.5),
                                        blurRadius: 7,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  height: 150,
                                  child: Row(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            15, 0, 15, 0),
                                        child: shopList[index]['info']
                                                    ['image'] ==
                                                'placeholder'
                                            ? Container(
                                                width: 100,
                                                decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    image: DecorationImage(
                                                        fit: BoxFit.cover,
                                                        image: AssetImage(
                                                            'assets/images/store-placeholder.png'))),
                                              )
                                            : Container(
                                                width: 100,
                                                decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    image: DecorationImage(
                                                        fit: BoxFit.cover,
                                                        image: NetworkImage(
                                                            shopList[index]
                                                                    ['info']
                                                                ['image']))),
                                              ),
                                      ),
                                      Expanded(
                                          flex: 3,
                                          child: Column(children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.only(top: 5),
                                              child: Stack(
                                                children: [
                                                  Container(
                                                    alignment: Alignment.center,
                                                    child: Text(
                                                      shopList[index]
                                                          ['shop_name'],
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .titleLarge,
                                                      textAlign:
                                                          TextAlign.center,
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
                                              padding: const EdgeInsets.only(
                                                  bottom: 5),
                                              child: Text(widget.gameName),
                                            ),
                                            Expanded(
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  for (var i = 1;
                                                      i <=
                                                          ((shopList[index][
                                                                          'rates']
                                                                      .length) /
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
                                                                      shopList[index]
                                                                              [
                                                                              'rates']
                                                                          .length;
                                                              j++) ...[
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Text(
                                                                    "₱${shopList[index]['rates']['rate${j}']['php']} : ${shopList[index]['rates']['rate${j}']['digGoods']}"),
                                                                Image.asset(
                                                                  gameIcon(widget
                                                                      .gameName),
                                                                  width: 10,
                                                                  height: 10,
                                                                )
                                                              ],
                                                            )
                                                          ]
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ],
                                              ),
                                            ),
                                            Center(
                                              child: SizedBox(
                                                height: 28,
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    for (var key
                                                        in shopList[index]
                                                                ['mop']
                                                            .keys) ...[
                                                      Image.asset(
                                                          'assets/images/MoP/${shopList[index]['mop'][key]}.png',
                                                          width: 50)
                                                    ]
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ]))
                                    ],
                                  )),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      );
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
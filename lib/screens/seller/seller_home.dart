import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:topup2p/cloud/firestore.dart';
import 'package:topup2p/models/item_model.dart';
import 'package:topup2p/providers/payment_provider.dart';
import 'package:topup2p/providers/sell_items_provder.dart';
import 'package:topup2p/providers/user_provider.dart';
import 'package:topup2p/screens/seller/add-item.dart';
import 'package:topup2p/screens/seller/seller_main.dart';
import 'package:topup2p/utilities/globals.dart';
import 'package:topup2p/widgets/toast.dart';

class SellerMainScreen extends StatefulWidget {
  const SellerMainScreen({Key? key}) : super(key: key);

  @override
  State<SellerMainScreen> createState() => _SellerMainScreenState();
}

//tocheck keepalive
class _SellerMainScreenState extends State<SellerMainScreen> {
  final PageStorageBucket _bucket = PageStorageBucket();
  final ScrollController _scrollController = ScrollController();
  late PaymentProvider paymentProvider;
  late UserProvider userProvider;
  late SellItemsProvider siProvider;
  bool _showScrollToTopButton = false;
  Widget ratesLoop(Map<String, dynamic> data, String icon, int startIndex) {
    List<Widget> rows = [];

    int endIndex = startIndex + 3;
    if (endIndex > data['rates'].length) {
      endIndex = data['rates'].length;
    }

    for (int index = startIndex; index < endIndex; index++) {
      rows.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
                '₱ ${data["rates"]["rate$index"]["php"]}  :  ${data["rates"]["rate$index"]["digGoods"]} '),
            Image.asset(
              icon,
              width: 10,
            )
          ],
        ),
      );
    }
    return Column(children: rows);
  }

  Future<void> _showDialog(String game) async {
    String icon = game == 'Mobile Legends'
        ? 'assets/icons/diamond.png'
        : game == 'Valorant'
            ? 'assets/icons/valorant.png'
            : 'assets/icons/coin.png';
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
            //title: Text('Title'),
            children: [
              Image.asset(getImage(game, 'image_banner')),
              const SizedBox(height: 10),
              Center(
                child: FutureBuilder(
                  future: FirestoreService().read(
                      collection: 'sellers',
                      documentId:
                          Provider.of<UserProvider>(context, listen: false)
                              .user!
                              .uid,
                      subcollection: 'games',
                      subdocumentId: game),
                  builder: (BuildContext context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else {
                      Map<String, dynamic> data = snapshot.data;
                      return Row(
                        children: [
                          Expanded(child: ratesLoop(data, icon, 0)),
                          if (data.length > 3) ...[
                            Expanded(
                              child: ratesLoop(data, icon, 3),
                            ),
                          ]
                        ],
                      );
                    }
                  },
                ),
              ),
            ]);
      },
    );
  }

  @override
  void initState() {
    super.initState();
    paymentProvider = Provider.of<PaymentProvider>(context, listen: false);
    userProvider = Provider.of<UserProvider>(context, listen: false);
    siProvider = Provider.of<SellItemsProvider>(context, listen: false);
    _scrollController.addListener(() {
      setState(() {
        _showScrollToTopButton = _scrollController.offset >= 200;
      });
    });
  }

  String getImage(String imageName, String type) {
    Map<String, dynamic> result =
        productItemsMap.where((map) => map['name'] == imageName).first;
    return result[type];
  }

  @override
  Widget build(BuildContext context) {
    Widget sellerHomeBody =
        Consumer<SellItemsProvider>(builder: (context, siProvider2, _) {
      if (siProvider2.Sitems.isNotEmpty) {
        return ListView.builder(
          key: const ValueKey('seller-home-page-listview'),
          controller: _scrollController,
          //physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: siProvider2.Sitems.length,
          itemBuilder: (context, index) {
            //map
            Map<Item, String> map = siProvider2.Sitems[index];
            //key
            Item item = map.keys.first;
            //value
            String status = map.values.first;
            return AnimationConfiguration.staggeredList(
              position: index,
              duration: const Duration(milliseconds: 375),
              child: SlideAnimation(
                verticalOffset: 50.0,
                child: FadeInAnimation(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 3, 10, 3),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: MediaQuery.of(context).platformBrightness ==
                                Brightness.dark
                            ? Colors.black
                            : Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 0.5,
                            blurRadius: 1,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: InkWell(
                        child: ListTile(
                          title: Text('${item.name}  ⓘ'),
                          subtitle: Text(
                            status,
                            style: TextStyle(
                                color: status == 'disabled'
                                    ? Colors.red
                                    : Colors.grey),
                          ),
                          leading: ClipOval(
                            child: ColorFiltered(
                              colorFilter: (status == 'disabled')
                                  ? const ColorFilter.mode(
                                      Colors.grey, BlendMode.saturation)
                                  : const ColorFilter.mode(
                                      Colors.transparent, BlendMode.saturation),
                              child: CircleAvatar(
                                backgroundImage:
                                    AssetImage(getImage(item.name, 'image')),
                              ),
                            ),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.settings),
                            onPressed: () async {
                              final sellItems = await Navigator.push(
                                context,
                                PageRouteBuilder(
                                  pageBuilder: (_, __, ___) => MultiProvider(
                                    providers: [
                                      ChangeNotifierProvider<
                                          PaymentProvider>.value(
                                        value: PaymentProvider(),
                                      ),
                                      ChangeNotifierProvider<
                                          SellItemsProvider>.value(
                                        value: SellItemsProvider(),
                                      ),
                                    ],
                                    child: AddItemSell(
                                        Sitems: siProvider2.Sitems,
                                        payments: paymentProvider.payments,
                                        update: true,
                                        game: item.name),
                                  ),
                                  transitionsBuilder: (_, a, __, c) =>
                                      FadeTransition(opacity: a, child: c),
                                ),
                              );

                              if (sellItems != null) {
                                if (siProvider2.Sitems.length !=
                                    sellItems.length) {
                                  siProvider2.clearItems();
                                  siProvider2.addItems(sellItems);
                                }
                                setState(() {});
                              }
                            },
                          ),
                        ),
                        onTap: () {
                          _showDialog(item.name);
                        },
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      } else {
        return const Center(
            child: Text(
          "Click + To Post",
          style: TextStyle(fontSize: 24),
        ));
      }
    });
    Widget scrollBackup = Positioned(
        bottom: 100.0,
        right: 16.0,
        child: Visibility(
            visible: _showScrollToTopButton,
            child: FloatingActionButton(
              onPressed: () {
                _scrollController.animateTo(0,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut);
              },
              child: const Icon(Icons.arrow_upward),
            )));
    Widget addItem = Positioned(
      bottom: 15.0,
      right: 16.0,
      child: FloatingActionButton(
        onPressed: () async {
          if (Provider.of<PaymentProvider>(context, listen: false)
              .payments
              .isEmpty) {
            showToast('You must have a wallet');

            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (_, __, ___) => MultiProvider(
                  providers: [
                    ChangeNotifierProvider<PaymentProvider>.value(
                      value: PaymentProvider(),
                    ),
                    ChangeNotifierProvider<SellItemsProvider>.value(
                      value: SellItemsProvider(),
                    ),
                  ],
                  child: const SellerMain(index: 2),
                ),
                transitionsBuilder: (_, a, __, c) =>
                    FadeTransition(opacity: a, child: c),
              ),
            );
          } else if (Provider.of<PaymentProvider>(context, listen: false)
              .payments
              .any((payment) => payment.isEnabled == true)) {
            final sellItems = await Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (_, __, ___) => MultiProvider(
                  providers: [
                    ChangeNotifierProvider<PaymentProvider>.value(
                      value: PaymentProvider(),
                    ),
                    ChangeNotifierProvider<SellItemsProvider>.value(
                      value: SellItemsProvider(),
                    ),
                  ],
                  child: AddItemSell(
                      Sitems: siProvider.Sitems,
                      payments: paymentProvider.payments),
                ),
                transitionsBuilder: (_, a, __, c) =>
                    FadeTransition(opacity: a, child: c),
              ),
            );
            if (sellItems != null) {
              if (siProvider.Sitems.length != sellItems.length) {
                siProvider.clearItems();
                siProvider.addItems(sellItems);
              }
            }
            for (var index = 0; index < siProvider.Sitems.length; index++) {
              print(siProvider.Sitems[index]);
            }
          } else {
            showToast('You must have at least 1 enabled wallet');

            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (_, __, ___) => const SellerMain(index: 2),
                transitionsBuilder: (_, a, __, c) =>
                    FadeTransition(opacity: a, child: c),
              ),
            );
          }
        },
        //backgroundColor: Colors.blueGrey,
        child: const Icon(Icons.add),
      ),
    );
    bool oneEnabled =
        siProvider.Sitems.any((map) => map.values.first == 'enabled');
    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          title: const Text(
            'Games',
          ),
          shape:
              const Border(bottom: BorderSide(color: Colors.grey, width: 1))),
      body: PageStorage(
        key: const PageStorageKey('sellerHomePage'),
        bucket: _bucket,
        child: Stack(
          children: [
            Visibility(
              visible: siProvider.Sitems.isNotEmpty,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  InkWell(
                    onTap: () {
                      siProvider.toggleAllGamesProvider(!oneEnabled);
                      FirestoreService().toggleAllGames(
                          enable: !oneEnabled,
                          shopName: userProvider.user!.name,
                          uid: userProvider.user!.uid);
                      setState(() {});
                    },
                    child: Row(
                      children: [
                        Text(oneEnabled ? 'Disable ' : ' Enable '),
                        const Text('all items')
                      ],
                    ),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: sellerHomeBody,
            ),
            Container(
              height: MediaQuery.of(context).size.height,
            ),
            scrollBackup,
            addItem
          ],
        ),
      ),
    );
  }
}

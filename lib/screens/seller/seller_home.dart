import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';
import 'package:topup2p/cloud/firestore.dart';
import 'package:topup2p/models/item_model.dart';
import 'package:topup2p/providers/payment_provider.dart';
import 'package:topup2p/providers/sell_items_provder.dart';
import 'package:topup2p/providers/user_provider.dart';
import 'package:topup2p/screens/seller/add-item.dart';
import 'package:topup2p/screens/seller/seller_main.dart';
import 'package:topup2p/utilities/globals.dart';

class SellerMainScreen extends StatefulWidget {
  const SellerMainScreen({Key? key}) : super(key: key);

  @override
  _SellerMainScreenState createState() => _SellerMainScreenState();
}

//tocheck keepalive
class _SellerMainScreenState extends State<SellerMainScreen> {
  final PageStorageBucket _bucket = PageStorageBucket();
  ScrollController _scrollController = ScrollController();
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
              SizedBox(height: 10),
              Center(
                child: FutureBuilder(
                  future: FirestoreService().read(
                      collection: 'seller_games_data_2',
                      documentId:
                          Provider.of<UserProvider>(context, listen: false)
                              .user!
                              .name,
                      subcollection: game,
                      subdocumentId: game),
                  builder: (BuildContext context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
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
    _scrollController.addListener(() {
      print('_scrollController.offset ${_scrollController.offset}');
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
    SellItemsProvider siProvider =
        Provider.of<SellItemsProvider>(context, listen: false);
    PaymentProvider paymentProvider =
        Provider.of<PaymentProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          title: Text(
            'Games',
            style: TextStyle(
              color: Colors.black, // try a different color here
            ),
          ),
          shape: Border(bottom: BorderSide(color: Colors.grey, width: 1))),
      body: PageStorage(
        key: PageStorageKey('sellerHomePage'),
        bucket: _bucket,
        child: Stack(
          children: [
            Consumer<SellItemsProvider>(builder: (context, siProvider, _) {
              if (siProvider.Sitems.isNotEmpty) {
                return ListView.builder(
                  key: ValueKey('seller-home-page-listview'),
                  //todo check in release mode if still lagging
                  controller: _scrollController,
                  //physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: siProvider.Sitems.length,
                  itemBuilder: (context, index) {
                    //map
                    Map<Item, String> map = siProvider.Sitems[index];
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
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 2,
                                    blurRadius: 5,
                                    offset: Offset(
                                        0, 2), // changes position of shadow
                                  ),
                                ],
                              ),
                              child: InkWell(
                                child: ListTile(
                                  title: Text('${item.name}  ⓘ'),
                                  subtitle: Text(
                                    '$status',
                                    style: TextStyle(
                                        color: status == 'disabled'
                                            ? Colors.red
                                            : Colors.grey),
                                  ),
                                  leading: ClipOval(
                                    child: ColorFiltered(
                                      colorFilter: (status == 'disabled')
                                          ? ColorFilter.mode(
                                              Colors.grey, BlendMode.saturation)
                                          : ColorFilter.mode(Colors.transparent,
                                              BlendMode.saturation),
                                      child: CircleAvatar(
                                        backgroundImage: AssetImage(
                                            getImage('${item.name}', 'image')),
                                      ),
                                    ),
                                  ),
                                  trailing: IconButton(
                                    icon: Icon(Icons.settings),
                                    onPressed: () async {
                                      // your code here
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
                return Center(
                    child: const Text(
                  "Click + To Post",
                  style: TextStyle(fontSize: 24),
                ));
              }
            }),
            Container(
              height: MediaQuery.of(context).size.height,
            ),
            Positioned(
                bottom:
                    100.0, // Adjust this value to change the vertical position of the button
                right: 16.0,
                child: Visibility(
                    visible: _showScrollToTopButton,
                    child: FloatingActionButton(
                      onPressed: () {
                        _scrollController.animateTo(0,
                            duration: Duration(milliseconds: 500),
                            curve: Curves.easeInOut);
                      },
                      child: Icon(Icons.arrow_upward),
                    ))),
            Positioned(
              bottom:
                  15.0, // Adjust this value to change the vertical position of the button
              right: 16.0,
              child: FloatingActionButton(
                onPressed: () async {
                  if (Provider.of<PaymentProvider>(context, listen: false)
                      .payments
                      .isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: const Text('You must have a wallet')));

                    Navigator.pushReplacement(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (_, __, ___) => MultiProvider(
                          providers: [
                            ChangeNotifierProvider<SellItemsProvider>.value(
                              value: SellItemsProvider(),
                            ),
                            ChangeNotifierProvider<PaymentProvider>.value(
                              value: PaymentProvider(),
                            ),
                          ],
                          child: const SellerMain(index: 2),
                        ),
                        transitionsBuilder: (_, a, __, c) =>
                            FadeTransition(opacity: a, child: c),
                      ),
                    );
                  } else if (Provider.of<PaymentProvider>(context,
                          listen: false)
                      .payments
                      .any((payment) => payment.isEnabled == true)) {
                    final sellItems = await Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (_, __, ___) => MultiProvider(
                          providers: [
                            ChangeNotifierProvider<SellItemsProvider>.value(
                              value: SellItemsProvider(),
                            ),
                            ChangeNotifierProvider<PaymentProvider>.value(
                              value: PaymentProvider(),
                            ),
                          ],
                          child: AddItemSell(
                              siProvider.Sitems, paymentProvider.payments),
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
                      setState(() {});
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: const Text(
                            'You must have at least 1 enabled wallet')));

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
                backgroundColor: Colors.blueGrey,
                child: const Icon(Icons.add),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

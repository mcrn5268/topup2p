import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:topup2p/global/globals.dart';
import 'package:topup2p/seller/seller-items.dart';
import 'package:topup2p/seller/seller-main.dart';
import 'package:topup2p/seller/widgets/seller-home/add-item.dart';

class SellerMainPage extends StatefulWidget {
  const SellerMainPage({Key? key}) : super(key: key);

  @override
  _SellerMainPageState createState() => _SellerMainPageState();
}

class _SellerMainPageState extends State<SellerMainPage>
    with AutomaticKeepAliveClientMixin<SellerMainPage> {
  final PageStorageBucket _bucket = PageStorageBucket();
  ScrollController _scrollController = ScrollController();
  bool _showScrollToTopButton = false;
  Widget ratesLoop(Map<String, dynamic> data, String icon, int startIndex) {
    print('data $data');
    List<Widget> rows = [];

    int endIndex = startIndex + 3;
    if (endIndex > data.length) {
      endIndex = data.length;
    }

    for (int index = startIndex; index < endIndex; index++) {
      rows.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
                '₱ ${data["rate$index"]["php"]} : ${data["rate$index"]["digGoods"]}'),
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

  void _showDialog(String game) {
    Future<Map<String, dynamic>?> rates =
        sellerGamesItems().loadItemsRates(game);
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
                  future: rates,
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    } else {
                      Map<String, dynamic> data = snapshot.data;
                      data.remove('status');
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
        productItems2.where((map) => map['name'] == imageName).first;
    print(result);
    return result[type];
  }

  @override
  bool get wantKeepAlive => true;
  @override
  Widget build(BuildContext context) {
    super.build(context);
    print('list view builder');
    return Scaffold(
      body: PageStorage(
        key: PageStorageKey('sellerHomePage'),
        bucket: _bucket,
        child: Stack(
          children: [
            //-------if empty
            // Center(
            //     child: const Text(
            //   "Click + To Post",
            //   style: TextStyle(fontSize: 24),
            // )),
            // ListView.builder(
            //     key: ValueKey('seller-home-page-listview'),
            //     controller: _scrollController,
            //     itemCount: 15,
            //     itemBuilder: (context, index) {
            //       return ListTile(
            //         title: Text('Item$index'),
            //         subtitle: Text('item$index'),
            //       );
            //     }),
            StreamBuilder<DocumentSnapshot>(
              stream: dbInstance
                  .collection('sellers')
                  .doc('${sellerData["sname"]}')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
                if (snapshot.hasData) {
                  var data = snapshot.data!.data() as Map<String, dynamic>;
                  var field = data['games'];
                  if (field != null) {
                    var keys = field.keys.toList();
                    var values = field.values.toList();
                    try {
                      return ListView.builder(
                        key: ValueKey('seller-home-page-listview'),
                        //controller: _scrollController,
                        //physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: keys.length,
                        itemBuilder: (context, index) {
                          // return ListTile(
                          //   title: Text('Item$index'),
                          //   subtitle: Text('item$index'),
                          // );

                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ColorFiltered(
                              colorFilter: (values[index] == 'disabled')
                                  ? ColorFilter.mode(
                                      Colors.grey, BlendMode.saturation)
                                  : ColorFilter.mode(
                                      Colors.transparent, BlendMode.saturation),
                              child: Container(
                                decoration: BoxDecoration(
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
                                    title: Text('${keys[index]}  ⓘ'),
                                    subtitle: Text('${values[index]}'),
                                    leading: CircleAvatar(
                                      backgroundImage: AssetImage(
                                          getImage('${keys[index]}', 'image')),
                                    ),
                                    trailing: IconButton(
                                      icon: Icon(Icons.settings),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          PageRouteBuilder(
                                            pageBuilder: (_, __, ___) =>
                                                AddItemSell(
                                                    update: true,
                                                    game: keys[index]),
                                            transitionsBuilder: (_, a, __, c) =>
                                                FadeTransition(
                                                    opacity: a, child: c),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  onTap: () {
                                    //need to rename banner assets
                                    _showDialog(keys[index]);
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    } catch (e) {
                      print('error $e');
                      return Container();
                    }
                  } else {
                    return Center(
                        child: const Text(
                      "Click + To Post",
                      style: TextStyle(fontSize: 24),
                    ));
                  }
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                } else {
                  return Container();
                }
              },
            ),
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
                onPressed: () {
                  if ((sellerData['GCash'] == null ||
                          sellerData['GCash'] == 'disabled') &&
                      (sellerData['UnionBank'] == null ||
                          sellerData['UnionBank'] == 'disabled') &&
                      (sellerData['Metrobank'] == null ||
                          sellerData['Metrobank'] == 'disabled')) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: const Text('You must have a wallet')));

                    Navigator.pushReplacement(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (_, __, ___) => const SellerMain(index: 2),
                        transitionsBuilder: (_, a, __, c) =>
                            FadeTransition(opacity: a, child: c),
                      ),
                    );
                  } else {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (_, __, ___) => const AddItemSell(),
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

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class GamesList extends StatefulWidget {
  const GamesList({Key? key}) : super(key: key);
  @override
  State<GamesList> createState() => _GamesListState();
}

class _GamesListState extends State<GamesList> {
  static final List<String> productItems = [
    'Mobile Legends',
    'Valorant',
    'Call of Duty Mobile',
    'Leauge of Legends: Wild RIft',
    'Free Fire MAX',
    'Garena Shells',
    'Steam Wallet Code',
    'PUBG Mobile UC Vouchers',
    'Counter Strike: Global Offensive',
    'MU Origin 3',
    'Tinder Voucher Code',
    'Punishing: Gray Raven',
    'MU Origin 2',
    'LifeAfter',
    'Mirage: Perfect Skyline',
    'Basketrio',
    'Be The King: Judge Destiny',
    'ONE PUNCH MAN: The Strongest',
    'Identity V',
    'ZEPETO',
    'Apex Legends Mobile',
    '8 Ball Pool',
    'Legends of Runeterra',
    'Shining Nikki',
    'Super Sus',
    'Tamashi: Rise of Yokai',
    'World War Heroes',
    'Super Mecha Champions',
    'Grand Theft Auto V: Premium Online Edition',
    'MARVEL Super War',
    'WWE 2k22 - Steam',
    'Onmyoji Arena',
    'Dawn Era',
    'Sausage Man',
    'Hyper Front',
    'MARVEL Strike Force',
    'NBA 2k22 Steam',
    'Read Dead Redemption 2',
    "Tiny Tina's Assult on Dragon Keep",
    "Tiny Tina's Wonderlands",
    'Dragon City',
    'EOS Red',
    'The Lord of the Rings: Rise to War',
    'Harry Potter: Puzzle & Speels',
    'Cave Shooter',
    'Club Vegas',
    'Top Eleven',
    'Asphalt 9: Legends',
    'Modern Combat 5: Blackout',
    'Badlanders',
    'Heroes Evolved',
    'Tom and Jerry: Chase',
    'MARVEL Duel',
    'Turbo VPN',
    'Omlet Arcade',
    'Bleach Mobile 3D',
    'Disorder',
    'Captain Tsubasa: Dream Team',
    'Cooking Adventure',
    'Jade Dynasty: New Fantasy',
    'OlliOlli World',
    'Sprite Fantasia',
    'Dota 2',
    'Free Fire',
    'Viu',
    'Borderlands 3',
    'The Outer Worlds',
    "Sid Meier's Civilization VI",
    'Nintendo eShop (US)',
    'OK Cupid',
    'PlayStation Network Vouchers',
    'Xbox Gift Card (US)',
    'Minecraft'
  ];
  bool _isFavorited = false;
  late bool _showMore;
  late String _viewML = 'View More';
  late final List<Map<String, String>> theMap = [];

  Future initImages() async {
    // >> To get paths you need these 2 lines
    final manifestContent = await rootBundle.loadString('AssetManifest.json');

    final Map<String, dynamic> manifestMap = json.decode(manifestContent);
    // >> To get paths you need these 2 lines

    final imagePaths = manifestMap.keys
        .where((String key) => key.contains('assets/gameslogos/'))
        .toList();
    //Map<String, String> nameMap = Map.fromIterables("name", productItems);
    for (int i = 0; i < productItems.length; i++) {
      late final Map<String, String> tempMap = {};
      tempMap['name'] = productItems[i];
      tempMap['image'] = imagePaths[i];

      theMap.add(tempMap);
      //print(theMap);
    }
    setState(() {
      //theMap = Map.fromIterables(productItems, imagePaths);
    });
  }

  @override
  initState() {
    super.initState();
    _showMore = false;
    initImages();
  }

  changeShowMore() {
    setState(() {
      _showMore = !_showMore;
      _viewML = _showMore ? 'View Less' : 'View More';
    });
  }

  Widget favoriteIcon(IconData icon, bool flag) {
    return Padding(
      padding: const EdgeInsets.only(right: 5),
      //child: Align(
       // alignment: Alignment.topRight,
        child: IconButton(
          icon: Icon(icon),
          color: (flag
              ? _isFavorited
                  ? Colors.yellowAccent
                  : Colors.white
              : Colors.black),
          iconSize: 35,
          onPressed: () {
            setState(() {
              _isFavorited = !_isFavorited;
            });
          },
        ),
      //),
    );
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    int countRow = width ~/ 150;
    print('Width: $width | Row: $countRow');

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
            ...theMap.map(
              (key) => Card(
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
                        Expanded(flex: 3, child: Image.asset(key['image']!)),
                        Expanded(
                          child: Container(
                            width: double.infinity,
                            color: Colors.grey,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                key['name']!,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  favoriteIcon(Icons.bookmark, true),
                  favoriteIcon(Icons.bookmark_outline_outlined, false),
                ]),
              ),
            )
          ].take(_showMore ? productItems.length : countRow * 3).toList(),
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


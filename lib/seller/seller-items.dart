import 'package:topup2p/global/globals.dart';

class sellerGamesItems {
  Future<void> loadItems() async {
    print('sellerGamesItems loadItems');
    //seller
    final snapshot = await dbInstance
        .collection('sellers')
        .doc('${sellerData["sname"]}')
        .get();
    final data = snapshot.data() as Map<String, dynamic>;
    try {
      final gamesMap = data['games'] as Map<String, dynamic>;
      gamesMap.forEach((key, value) {
        final item = <String, String>{key: value};
        sellerItems.add(item);
      });
    } catch (e) {
      print('error $e');
    }
    int length = sellerItems.length;
    //images
    for (var index = 0; index < length; index++) {
      final snapshot2 = await dbInstance
          .collection('games_data')
          .doc('${sellerItems[index].keys.first}')
          .get();
      final data2 = snapshot2.data() as Map<String, dynamic>;
      final gameImage = data2['image'];
      final gameImageBanner = data2['image_banner'];
      sellerItems[index]['image'] = gameImage;
      sellerItems[index]['image_banner'] = gameImageBanner;
    }
  }

  Future<Map<String, dynamic>?> loadItemsRates(String game) async {
    try {
      final document =
          await dbInstance.collection('seller_games_data').doc('$game').get();
      final data = document.data();
      var myMap =
          data!['${sellerData["sname"]}']['rates'] as Map<String, dynamic>;
      myMap['status'] = data['${sellerData["sname"]}']['status'];
      print('myMap $myMap');
      return myMap;
    } catch (e) {
      return null;
    }
  }
}

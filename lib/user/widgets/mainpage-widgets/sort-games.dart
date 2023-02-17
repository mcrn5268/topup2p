import 'package:topup2p/global/globals.dart';

class GamesSort {
  void AtoZ() {
    theMap.sort((a, b) {
      var nameA = a['name'].toUpperCase();
      var nameB = b['name'].toUpperCase();
      return nameA.compareTo(nameB);
    });
  }

  void popuarity() {
    theMap.sort((a, b) => a["popularity"] - b["popularity"]);
  }
}

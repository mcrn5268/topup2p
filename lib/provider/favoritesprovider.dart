import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:topup2p/widgets/favorites.dart';
import 'package:topup2p/global/globals.dart' as GlobalValues;

final _innerList = <FavoriteItems>[];
List<SliverReorderableList> innerLists = [];
int index = 0;

class FavoritesProvider extends ChangeNotifier {
  String getImage(dynamic item) {
    return GlobalValues.forIcon[item]!;
  }

  void setImage(dynamic item) {
    //print(index);
    item['isFav'] = !item['isFav'];
    print(item['name']);
    if (item['isFav']) {
      _innerList.add(FavoriteItems(item['name'], item['image'], item['isFav']));

      innerLists.add(
        SliverReorderableList(
          itemCount: 1,
          onReorder: (int oldIndex, int newIndex) {
            if (newIndex > oldIndex) {
              newIndex -= 1;
            }
            final dynamic item = innerLists.removeAt(oldIndex);
            innerLists.insert(newIndex, item);
            final dynamic item2 = _innerList.removeAt(oldIndex);
            _innerList.insert(newIndex, item2);
          },
          itemBuilder: (BuildContext context, int index) {
            return ReorderableDragStartListener(
                key: ValueKey(item['name']),
                index: index,
                child: _innerList[innerLists.length-1],
                
                );

            
          },
          
        ),
      );

      /*
      innerLists.add(
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (BuildContext context, _) => _innerList[innerLists.length-1],
            childCount: 1,
          ),
        ),
      );

      */

      //index++;
      //print(index);
    } else {
      //print(_innerList.indexWhere((element) => element.name == item['name']));

      innerLists.removeAt(
          _innerList.indexWhere((element) => element.name == item['name']));

      _innerList.removeWhere((i) => i.name == item['name']);
      
    }
    notifyListeners();
  }
}

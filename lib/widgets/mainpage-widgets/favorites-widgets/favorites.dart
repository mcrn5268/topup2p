import 'package:flutter/material.dart';
import 'package:topup2p/global/globals.dart' as GlobalValues;
import 'package:topup2p/widgets/icons/favoriteicon.dart';
import 'package:provider/provider.dart';
import 'package:topup2p/provider/favoritesprovider.dart';
import 'package:topup2p/widgets/mainpage-widgets/favorites-widgets/favorites-items.dart';

//late double width = size.width;

class FavoritesList extends StatefulWidget {
  const FavoritesList({
    Key? key,
  }) : super(key: key);

  @override
  State<FavoritesList> createState() => _FavoritesListState();
}

class _FavoritesListState extends State<FavoritesList> with AutomaticKeepAliveClientMixin{
  //List<SliverList> innerLists = [];
  final controller = ScrollController();
  bool flag = true;

  //width = size.width
  void _arrowNav(String nav) {
    setState(() {
      if (nav == "Next") {
        GlobalValues.RVisible = !GlobalValues.RVisible;
      } else if (nav == "Prev") {
        GlobalValues.LVisible = !GlobalValues.LVisible;
      }
    });
  }

  @override
  void initState() {
    GlobalValues.favoritedList =
        GlobalValues.theMap.where((item) => item["isFav"] == true);

    super.initState();
    for (var e in GlobalValues.favoritedList) {
      GlobalValues.favoritedItems
          .add(FavoriteItems(e['name'], e['image'], e['isFav'], e['image-banner']));
    }
    if ((GlobalValues.favoritedItems.length) * 114.5 >
        GlobalValues.logicalWidth) {
      GlobalValues.RVisible = true;
    }
  }

  //arrow_forward_ios_outlined
  //arrow_back_ios_outlined
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: 
      Consumer<FavoritesProvider>(builder: (_, __, ___) {
        return Stack(
          children: [
            CustomScrollView(
              scrollDirection: Axis.horizontal,
              controller: controller,
              slivers: [
                SliverReorderableList(
                  itemCount: GlobalValues.favoritedItems.length,
                  onReorder: (int oldIndex, int newIndex) {
                    if (newIndex > oldIndex) {
                      newIndex -= 1;
                    }
                    final dynamic item =
                        GlobalValues.favoritedItems.removeAt(oldIndex);
                    GlobalValues.favoritedItems.insert(newIndex, item);
                  },
                  itemBuilder: (context, index) {
                    //cannot find correct provider
                    return ReorderableDelayedDragStartListener(
                      key: ValueKey("Favorited-Items-$index"),
                      index: index,
                      child: GlobalValues.favoritedItems[index],
                    );
                  },
                ),
              ],
            ),
            Row(
              children: [
                Visibility(
                  visible: GlobalValues.LVisible,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_outlined),
                        onPressed: () {
                          nextItem("Prev");
                        },
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Visibility(
                  visible: GlobalValues.RVisible,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_forward_ios_outlined),
                        onPressed: () {
                          nextItem("Next");
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        );
      }),
    );
  }

  double jumpValue = 0.0;
  bool navFlag = true;
  void nextItem(String move) {
    final deviceWidth = MediaQuery.of(context).size.width;
    double cardsWidth = ((GlobalValues.logicalWidth / 114.5).ceil() * 114.5);
    if (cardsWidth == deviceWidth) {
      flag = false;
    }
    if (cardsWidth > deviceWidth && flag) {
      jumpValue = cardsWidth - deviceWidth;
      flag = false;
      _arrowNav("Prev");
      //full card last item
    } else if (flag == false) {
      jumpValue = move == "Next" ? jumpValue += 114.5 : jumpValue -= 114.5;
      if (navFlag == false) {
        _arrowNav("Next");
        navFlag = true;
      }
    }
    //first item
    if (jumpValue < 0) {
      jumpValue = 0;
      _arrowNav(move);
      flag = true;
      if (navFlag == false) {
        _arrowNav("Next");
        navFlag = true;
      }
    }
    //last item
    if ((deviceWidth + jumpValue) / 114.5 ==
        GlobalValues.favoritedList.length) {
      navFlag = false;
      _arrowNav(move);
    }
    controller.jumpTo(jumpValue);
  }
  
  @override
  bool get wantKeepAlive => true;
}

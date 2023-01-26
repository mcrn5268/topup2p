import 'package:flutter/material.dart';
import 'package:topup2p/global/globals.dart' as GlobalValues;
import 'package:topup2p/widgets/icons/favoriteicon.dart';
import 'package:provider/provider.dart';
import 'package:topup2p/provider/favoritesprovider.dart';
import 'package:topup2p/provider/favoritesprovider.dart' as FavValues;

class FavoritesList extends StatefulWidget {
  const FavoritesList({
    Key? key,
  }) : super(key: key);

  @override
  _FavoritesListState createState() => _FavoritesListState();
}

class _FavoritesListState extends State<FavoritesList> {
  //List<SliverList> innerLists = [];
  final controller = ScrollController();
  bool _LVisible = false;
  bool _RVisible = false;
  Size size = WidgetsBinding.instance.window.physicalSize;
  late double width;
  bool flag = true;
  late var isFavorited;

  //width = size.width
  void _arrowNav(String nav) {
    setState(() {
      if (nav == "Next") {
        _RVisible = !_RVisible;
      } else if (nav == "Prev") {
        _LVisible = !_LVisible;
      }
    });
  }

  @override
  void initState() {
    isFavorited = GlobalValues.theMap.where((item) => item["isFav"] == true);

    width = size.width;
    super.initState();
    for (var e in isFavorited) {
      final _innerList = <FavoriteItems>[];

      _innerList.add(FavoriteItems(e['name'], e['image'], e['isFav']));




      // FavValues.innerLists.add(
      //   SliverList(
      //     delegate: SliverChildBuilderDelegate(
      //       (BuildContext context, int index) => _innerList[index],
      //       childCount: 1,
      //     ),
      //   ),
      //);



    }
    if (size.width / 128 < isFavorited.length) {
      _RVisible = true;
    }
    //double width = MediaQuery.of(context).size.width;
  }

  //arrow_forward_ios_outlined
  //arrow_back_ios_outlined
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: Consumer<FavoritesProvider>(builder: (_, favorites, child) {
        print("State build");
        return Stack(
          children: [
            CustomScrollView(
              scrollDirection: Axis.horizontal,
              controller: controller,
              slivers: FavValues.innerLists,
                
              
              
              
              


            ),


            // CustomScrollView(
            //   slivers: FavValues.innerLists,
            //   scrollDirection: Axis.horizontal,
            //   controller: controller,
            // ),



            Row(
              children: [
                Visibility(
                  visible: _LVisible,
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
                  visible: _RVisible,
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
    double cardsWidth = ((size.width / 114.5).ceil() * 114.5);
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
    if ((deviceWidth + jumpValue) / 114.5 == isFavorited.length) {
      navFlag = false;
      _arrowNav(move);
    }
    controller.jumpTo(jumpValue);
  }
}

class FavoriteItems extends StatefulWidget {
  final String name;
  final String image;
  final bool isFav;
  const FavoriteItems(this.name, this.image, this.isFav, {Key? key})
      : super(key: key);
  @override
  State createState() => FavoriteItemsState();
}

class FavoriteItemsState extends State<FavoriteItems> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print("FavoriteItems Build ${widget.name}");

    // return Material(
    //   child: Consumer<FavoritesProvider>(
    //     builder: (_, favorites, child) {


          return SizedBox(
            width: 114.5,
            
            child: Card(
              //key: ValueKey(widget.name),
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
                      Expanded(flex: 3, child: Image.asset(widget.image)),
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          color: Colors.grey,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              widget.name,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                FavoritesIcon(widget.name, 20),
              ]),
            ),


            
          );



    //     },
    //   ),
    // );



  }
}

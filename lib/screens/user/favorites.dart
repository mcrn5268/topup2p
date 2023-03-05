import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';
import 'package:topup2p/providers/favorites_provider.dart';
import 'package:topup2p/screens/user/user_home.dart';
import 'package:topup2p/utilities/globals.dart';
import 'package:topup2p/widgets/favorite_icon.dart';
import 'package:topup2p/widgets/favorite_placeholder.dart';

//todo
bool RVisible = false;
bool LVisible = false;

class FavoritesList extends StatefulWidget {
  const FavoritesList({
    Key? key,
  }) : super(key: key);

  @override
  State<FavoritesList> createState() => _FavoritesListState();
}

//change move AutomaticKeepAliveClientMixin to user_main.dart
class _FavoritesListState extends State<FavoritesList>
    with AutomaticKeepAliveClientMixin {
  final controller = ScrollController();
  bool flag = true;
  int favoritedLength = 0;

  //width = size.width
  void _arrowNav(String nav) {
    setState(() {
      if (nav == "Next") {
        RVisible = !RVisible;
      } else if (nav == "Prev") {
        LVisible = !LVisible;
      }
    });
  }

  @override
  bool get wantKeepAlive => true;

//calculate R/LVisible
  @override
  void initState() {
    super.initState();

    if ((Provider.of<FavoritesProvider>(context, listen: false)
                .favorites
                .length) *
            114.5 >
        logicalWidth) {
      RVisible = true;
    }
  }

  //arrow_forward_ios_outlined
  //arrow_back_ios_outlined
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SizedBox(
      height: 150,
      child: Consumer<FavoritesProvider>(builder: (context, favProvider, _) {
        if (favProvider.favorites.isEmpty) {
          return FavoritesPlaceholder();
        } else {
          favoritedLength = favProvider.favorites.length;
          return Stack(
            children: [
              ListView.builder(
                  controller: controller,
                  scrollDirection: Axis.horizontal,
                  itemCount: favoritedLength,
                  itemBuilder: (context, index) {
                    return AnimationConfiguration.staggeredList(
                      position: index,
                      duration: const Duration(milliseconds: 375),
                      child: SlideAnimation(
                        horizontalOffset: 50.0,
                        child: FadeInAnimation(
                          child: SizedBox(
                            width: 114.5,
                            child: Card(
                              elevation: 0,
                              color: Colors.transparent,
                              child: Stack(children: [
                                GestureDetector(
                                  onTap: () {
                                    GameItemScreenNavigator(name:
                                        favProvider.favorites[index].name,
                                       flag: true);
                                  },
                                  child: Column(
                                    children: [
                                      Expanded(
                                        flex: 3,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(20.0),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.grey
                                                    .withOpacity(0.5),
                                                spreadRadius: 2,
                                                blurRadius: 5,
                                                offset: Offset(0,
                                                    2), 
                                              ),
                                            ],
                                          ),
                                          child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(20.0),
                                              child: Image.asset(favProvider
                                                  .favorites[index].image)),
                                        ),
                                      ),
                                      Expanded(
                                        child: Container(
                                          width: double.infinity,
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                favProvider
                                                    .favorites[index].name,
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(
                                                    fontSize: 10),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                FavoritesIcon(itemName:
                                    favProvider.favorites[index].name,size: 20)
                              ]),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
              Row(
                children: [
                  Visibility(
                    visible: LVisible,
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
                    visible: RVisible,
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
        }
      }),
    );
  }

  double jumpValue = 0.0;
  bool navFlag = true;
  void nextItem(String move) {
    final deviceWidth = MediaQuery.of(context).size.width;
    double cardsWidth = ((logicalWidth / 114.5).ceil() * 114.5);
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
    if ((deviceWidth + jumpValue) / 114.5 == favoritedLength) {
      navFlag = false;
      _arrowNav(move);
    }
    controller.jumpTo(jumpValue);
  }
}

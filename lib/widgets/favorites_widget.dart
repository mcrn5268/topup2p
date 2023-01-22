// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';

class FavoritesList extends StatefulWidget {
  const FavoritesList({
    Key? key,
  }) : super(key: key);

  @override
  _FavoritesListState createState() => _FavoritesListState();
}

class _FavoritesListState extends State<FavoritesList> {
  List<SliverList> innerLists = [];
  final controller = ScrollController();
  final _numLists = 2;
  final _numberOfItemsPerList = 1;
  bool _LVisible = false;
  bool _RVisible = false;
  Size size = WidgetsBinding.instance.window.physicalSize;
  late double width;
  bool flag = true;

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
    width = size.width;
    super.initState();
    for (int i = 0; i < _numLists; i++) {
      final _innerList = <FavoriteItems>[];
      for (int j = 0; j < _numberOfItemsPerList; j++) {
        _innerList.add(FavoriteItems(
          i: i,
        ));
      }
      innerLists.add(
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) => _innerList[index],
            childCount: _numberOfItemsPerList,
          ),
        ),
      );
    }
    if (size.width / 128 < _numLists) {
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
      child: Stack(
        children: <Widget>[
          CustomScrollView(
            slivers: innerLists,
            scrollDirection: Axis.horizontal,
            controller: controller,
          ),
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
      ),
    );
  }

  double jumpValue = 0.0;
  bool navFlag = true;
  void nextItem(String move) {
    final deviceWidth = MediaQuery.of(context).size.width;
    double cardsWidth = ((size.width / 128).ceil() * 128);
    if (cardsWidth == deviceWidth) {
      flag = false;
    }
    if (cardsWidth > deviceWidth && flag) {
      jumpValue = cardsWidth - deviceWidth;
      flag = false;
      _arrowNav("Prev");
      //full card last item
    } else if (flag == false) {
      jumpValue = move == "Next" ? jumpValue += 128 : jumpValue -= 128;
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
    if ((deviceWidth + jumpValue) / 128 == _numLists) {
      navFlag = false;
      _arrowNav(move);
    }
    print("jumpValue: $jumpValue");
    controller.jumpTo(jumpValue);
  }
}

@immutable
class FavoriteItems extends StatefulWidget {
  const FavoriteItems({Key? key, required this.i}) : super(key: key);
  final int i;
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
    return Card(
      shape: RoundedRectangleBorder(
        side: const BorderSide(
          color: Colors.black,
        ),
        borderRadius: BorderRadius.circular(20),
        //set border radius more than 50% of height and width to make circle
      ),
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(10),
            child: Image.asset(
              'assets/images/logo.png',
              width: 100,
              height: 100,
            ),
          ),
          Text('Test${widget.i}'),
        ],
      ),
    );
  }
}

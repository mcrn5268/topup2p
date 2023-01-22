import 'package:flutter/material.dart';
import 'package:topup2p/widgets/favorites_widget.dart';
import 'package:topup2p/widgets/games.dart';
import 'package:topup2p/widgets/appbar.dart';
import 'package:topup2p/widgets/textwidgets/headline6.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    //print height
    return Scaffold(
        appBar: const AppBarWidget(),
        body: ListView(
          shrinkWrap: true,
          children: const <Widget>[
            Divider(),
            HeadLine6('FAVORITES'),
            FavoritesList(),
            //dynamically adjust # of shown items depending on the width
            Divider(),
            HeadLine6('GAMES'),
            GamesList(),
          ],
        ));
  }
}

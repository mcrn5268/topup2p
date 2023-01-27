import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:topup2p/global/globals.dart' as GlobalValues;
import 'package:provider/provider.dart';
import 'package:topup2p/provider/favoritesprovider.dart';

class FavoritesIcon extends StatefulWidget {
  final String name;
  final double size;
  const FavoritesIcon(this.name, this.size, {super.key});

  @override
  State<FavoritesIcon> createState() => _FavoritesIconState();
}

class _FavoritesIconState extends State<FavoritesIcon> {
  @override
  Widget build(BuildContext context) {
    var isFavList =
        GlobalValues.theMap.firstWhere((item) => item["name"] == widget.name);
    dynamic isFavorited = isFavList['isFav'];
    String icon = GlobalValues.forIcon[isFavorited]!;
    return Align(
        alignment: Alignment.topRight,
        child:
            // Consumer<FavoritesProvider>(
            //builder: (context, favorites, child) {
            // print("CONSUMER ${isFavList['name']} $icon ");
            //return
            IconButton(
          key: ValueKey('${widget.name}favButton'),
          icon: Image.asset(
              //context.read<FavoritesProvider>().getImage(isFavorited)),
              //Provider.of<FavoritesProvider>(context, listen: false).getImage(isFavorited)),
              //'assets/images/logo.png'),
              FavoritesProvider().getImage(isFavorited)),

          //WHHYYYYYYYYYYYY
          color: null,
          padding: const EdgeInsets.only(right: 10),
          constraints: const BoxConstraints(),
          iconSize: widget.size,
          onPressed: () {
            
            //Provider.of<FavoritesProvider>(context, listen: false).checkNav();
            context.read<FavoritesProvider>().setImage(isFavList);
            //Provider.of<FavoritesProvider>(context, listen: false).setImage(isFavList);
            if ((GlobalValues.favoritedItems.length) * 114.5 >
                GlobalValues.logicalWidth) {
              GlobalValues.RVisible = true;
            } else {
              GlobalValues.RVisible = false;
            }
            //setState(() {});
          },
        )
        //})
        );
  }
}

import 'package:flutter/material.dart';
import 'package:topup2p/widgets/icons/favoriteicon.dart';
import 'package:provider/provider.dart';
import 'package:topup2p/provider/favoritesprovider.dart';
import 'package:topup2p/widgets/seller/seller.dart';

class FavoriteItems extends StatefulWidget {
  final String name;
  final String image;
  final bool isFav;
  final String banner;
  const FavoriteItems(this.name, this.image, this.isFav, this.banner,
      {Key? key})
      : super(key: key);
  @override
  State<FavoriteItems> createState() => FavoriteItemsState();
}

class FavoriteItemsState extends State<FavoriteItems> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
            ),
            child: InkWell(
              onTap: () {
                Navigator.of(context)
                    .push(
                  MaterialPageRoute(
                    builder: (_) =>
                        ChangeNotifierProvider<FavoritesProvider>.value(
                      value: FavoritesProvider(),
                      child: GameSellerList(widget.name, widget.banner),
                    ),
                  ),
                )
                    .then((value) {
                  setState(() {
                    Provider.of<FavoritesProvider>(context, listen: false)
                        .notifList();
                  });
                });
              },
              child: Column(
                children: [
                  Expanded(flex: 3, child: Image.asset(widget.image)),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      color: Colors.grey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            widget.name,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),  
          ),
         // Consumer<FavoritesProvider>(builder: (_, __, ___) {
            //return 
            FavoritesIcon(widget.name, 20)
          //}),
        ]),
      ),
    );

    //     },
    //   ),
    // );
  }
}

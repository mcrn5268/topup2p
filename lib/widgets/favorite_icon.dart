import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:topup2p/cloud/firestore.dart';
import 'package:topup2p/models/item_model.dart';
import 'package:topup2p/providers/favorites_provider.dart';
import 'package:topup2p/providers/user_provider.dart';
import 'package:topup2p/screens/user/favorites.dart';
import 'package:topup2p/utilities/globals.dart';
import 'package:topup2p/utilities/models_utils.dart';

class FavoritesIcon extends StatefulWidget {
  final String itemName;
  final double size;
  const FavoritesIcon({required this.itemName, required this.size, super.key});

  @override
  State<FavoritesIcon> createState() => _FavoritesIconState();
}

class _FavoritesIconState extends State<FavoritesIcon> {
  @override
  Widget build(BuildContext context) {
    Item? itemObject = getItemByName(widget.itemName);
    FavoritesProvider favProvider =
        Provider.of<FavoritesProvider>(context, listen: false);
    UserProvider userProvider =
        Provider.of<UserProvider>(context, listen: false);
    if (itemObject != null) {
      return Align(
          alignment: Alignment.topRight,
          child: IconButton(
            key: ValueKey('${widget.itemName}favButton'),
            icon: Image.asset(
                Provider.of<FavoritesProvider>(context).isFavorite(itemObject)
                    ? icon[true]!
                    : icon[false]!),
            color: null,
            padding: const EdgeInsets.only(right: 10),
            constraints: const BoxConstraints(),
            iconSize: widget.size,
            onPressed: () {
              if (favProvider.isFavorite(itemObject)) {
                FirestoreService().deleteField(
                    collection: 'user_games_data',
                    documentId: userProvider.user!.uid,
                    field: widget.itemName);
              } else {
                FirestoreService().create(
                    collection: 'user_games_data',
                    documentId: userProvider.user!.uid,
                    data: {widget.itemName: FieldValue.serverTimestamp()});
              }
              favProvider.toggleFavorite(itemObject);

              if ((favProvider.favorites.length) * 114.5 > logicalWidth) {
                RVisible = true;
              } else {
                RVisible = false;
              }

              setState(() {});
            },
          ));
    } else {
      return const Align(alignment: Alignment.topRight, child: Icon(Icons.error));
    }
  }
}

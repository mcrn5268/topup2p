import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:topup2p/providers/favorites_provider.dart';
import 'package:topup2p/screens/profile.dart';

class ProfileButton extends StatelessWidget {
  const ProfileButton({super.key});

  @override
  Widget build(BuildContext context) {
    FavoritesProvider favProvider =
        Provider.of<FavoritesProvider>(context, listen: false);
    return ElevatedButton(
      onPressed: () async {
        final favs = await Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) =>
                ChangeNotifierProvider<FavoritesProvider>.value(
              value: FavoritesProvider(),
              child: ProfileScreen(
                  favorites:
                      Provider.of<FavoritesProvider>(context, listen: false)
                          .favorites),
            ),
            transitionsBuilder: (_, a, __, c) =>
                FadeTransition(opacity: a, child: c),
          ),
        );
        if (favs.length != favProvider.favorites.length) {
          favProvider.clearFavorites();
          favProvider.addItems(favs);
        }
      },
      child: Row(
        children: const <Widget>[Icon(Icons.person_outline_sharp)],
      ),
    );
  }
}

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
        print(
            'profile button ${Provider.of<FavoritesProvider>(context, listen: false).favorites.length}');
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

        print('check length11 ${favProvider.favorites.length}');
        print('check length22 ${favs.length}');
        if (favs.length != favProvider.favorites.length) {
          favProvider.clearFavorites();
          favProvider.addItems(favs);
        }
        print('check length33 ${favProvider.favorites.length}');
        print('check length44 ${favs.length}');
      },
      child: Row(
        children: const <Widget>[Icon(Icons.person_outline_sharp)],
      ),
    );
  }
}

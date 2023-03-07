import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:topup2p/cloud/firestore.dart';
import 'package:topup2p/providers/favorites_provider.dart';
import 'package:topup2p/providers/user_provider.dart';
import 'package:topup2p/screens/user/favorites.dart';
import 'package:topup2p/screens/user/user_home.dart';
import 'package:topup2p/utilities/models_utils.dart';
import 'package:topup2p/widgets/appbar/appbar.dart';
import 'package:topup2p/widgets/headline6.dart';
import 'package:topup2p/widgets/loading_screen.dart';

class UserMainScreen extends StatefulWidget {
  const UserMainScreen({super.key});
  @override
  State<UserMainScreen> createState() => _UserMainScreenState();
}

class _UserMainScreenState extends State<UserMainScreen> {
  @override
  Widget build(BuildContext context) {
    UserProvider userProvider =
        Provider.of<UserProvider>(context, listen: false);
    return FutureBuilder(
        //check for favorited items in firestore for UI
        future: FirestoreService().read(
            collection: 'user_games_data', documentId: userProvider.user!.uid),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              // Read Firestore data into a List of MapEntry objects
              List<MapEntry<String, dynamic>> data =
                  snapshot.data!.entries.toList();
              // Sort the List based on the order of fields in the Firestore document - inverted
              if (data.length > 1) {
                data.sort((a, b) => a.value.compareTo(b.value));
              }

              // Iterate over the sorted List to add items to the FavoritesProvider
              for (var entry in data) {
                var favoritedItem = getItemByName(entry.key);
                // Add Item to favorited items list
                Provider.of<FavoritesProvider>(context, listen: false)
                    .toggleFavorite(favoritedItem!,notify: false);
              }
            } else {
              print("snapshot is empty users_game_data - favorited");
            }
            return Scaffold(
                appBar: AppBarWidget(
                    home: true,
                    search: true,
                    isloggedin: userProvider.user != null),
                body: ListView(
                  addAutomaticKeepAlives: true,
                  shrinkWrap: false,
                  children: const <Widget>[
                    HeadLine6('FAVORITES'),
                    FavoritesList(),
                    Divider(),
                    HeadLine6('GAMES'),
                    GamesList(),
                  ],
                ));
          } else {
            return Container(
              width: 50,
              height: 50,
              child: const LoadingScreen(),
            );
          }
        });
  }
}

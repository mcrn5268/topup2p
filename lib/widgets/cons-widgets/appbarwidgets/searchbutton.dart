import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:topup2p/global/globals.dart' as GlobalValues;
import 'package:topup2p/provider/favoritesprovider.dart';
import 'package:topup2p/widgets/mainpage-widgets/games-widgets/games.dart';
import 'package:topup2p/widgets/seller/seller.dart';

class SearchButton extends StatelessWidget {
  const SearchButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          children: [
            ElevatedButton(
              onPressed: () {
                showSearch(
                  context: context,
                  delegate: SearchD(),
                );
              },
              child: Row(
                children: const <Widget>[Icon(Icons.search_outlined)],
              ),
            )
          ],
        ),
      ],
    );
  }
}

class SearchD extends SearchDelegate {
  @override
  List<Widget>? buildActions(BuildContext context) => [
        IconButton(
            onPressed: () {
              if (query.isEmpty) {
                close(context, null);
              } else {
                query = '';
              }
            },
            icon: const Icon(Icons.clear))
      ];

  @override
  Widget? buildLeading(BuildContext context) => IconButton(
      onPressed: () {
        close(context, null);
      },
      icon: const Icon(Icons.arrow_back_ios_outlined,
          color: Colors.black)); //close searchbar

  @override
  Widget buildResults(BuildContext context) {
    // TODO: implement buildResults
    throw UnimplementedError();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    List<String> suggestions = GlobalValues.productItems.where((search) {
      final result = search.toLowerCase();
      final input = query.toLowerCase();

      return result.contains(input);
    }).toList();

    return ListView.builder(
        itemCount: suggestions.length,
        itemBuilder: (context, index) {
          final suggestion = suggestions[index];

          return ListTile(
            title: Text(suggestion),
            onTap: () {
              MainPageNavigator(suggestion, getBanner(suggestion), flag: true);
            },
          );
        });
  }
}

String getBanner(String name) {
  var temp =
      GlobalValues.theMap.where((element) => element['name'] == name).toList();

  return temp[0]['image-banner'];
}

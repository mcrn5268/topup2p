import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:topup2p/screens/user/user_home.dart';
import 'package:topup2p/utilities/globals.dart';

class SearchButton extends StatelessWidget {
  const SearchButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        showSearch(
          context: context,
          delegate: MySearchDelegate(),
        );
      },
      child: Row(
        children: const <Widget>[Icon(Icons.search_outlined)],
      ),
    );
  }
}

class MySearchDelegate extends SearchDelegate {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
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
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
        icon: AnimatedIcon(
            icon: AnimatedIcons.menu_arrow,
            progress: transitionAnimation,
            color: Colors.black),
        onPressed: () => close(context, null));
  }

  @override
  Widget buildResults(BuildContext context) {
    FocusScope.of(context).unfocus();
    return buildSuggestions(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final List<Map<String, dynamic>> matchingSuggestions =
        productItemsMap.where((suggestion) {
      final String suggestionTitle =
          suggestion['name'].toString().toLowerCase();
      return suggestionTitle.contains(query.toLowerCase());
    }).toList();

    return ListView.builder(
      itemCount: matchingSuggestions.length,
      itemBuilder: (BuildContext context, int index) {
        final String title = matchingSuggestions[index]['name'];
        return AnimationConfiguration.staggeredList(
          position: index,
          duration: const Duration(milliseconds: 375),
          child: SlideAnimation(
            verticalOffset: 50.0,
            child: FadeInAnimation(
              child: ListTile(
                  title: Text(title),
                  onTap: () {
                    GameItemScreenNavigator(title, false);
                  }),
            ),
          ),
        );
      },
    );
  }
}

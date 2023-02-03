import 'package:flutter/material.dart';

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
<<<<<<< HEAD
                //skip
=======
                showSearch(
                  context: context,
                  delegate: SearchD(),
                );
>>>>>>> main-page-fix
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
<<<<<<< HEAD
}
=======
}

class SearchD extends SearchDelegate {
  List<String> searchResults = ['hatdong', 'tanga', 'bobo', 'pakyu', 'payong'];

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
  Widget buildResults(BuildContext context) => Center(
        child: Text(query),
      );

  @override
  Widget buildSuggestions(BuildContext context) {
    List<String> suggestions = searchResults.where((search) {
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
              query = suggestion;

              showResults(context);
            },
          );
        });
  }
}
>>>>>>> main-page-fix

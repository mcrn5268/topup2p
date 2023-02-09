import 'package:flutter/material.dart';

import '../../profile.dart';

class ProfileButton extends StatelessWidget {
  const ProfileButton({super.key});

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
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (_, __, ___) => const ProfilePage(),
                    transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
                  ),
                );
              },
              child: Row(
                children: const <Widget>[Icon(Icons.person_outline_sharp)],
              ),
            )
          ],
        ),
      ],
    );
  }
}
import 'package:flutter/material.dart';

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
                //skip
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
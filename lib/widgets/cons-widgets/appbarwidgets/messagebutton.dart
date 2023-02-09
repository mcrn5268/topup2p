import 'package:flutter/material.dart';

class MessageButton extends StatelessWidget {
  const MessageButton({super.key});

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
                // Navigator.push(
                //   context,
                //   PageRouteBuilder(
                //     pageBuilder: (_, __, ___) => const RegisterPage(),
                //     transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
                //   ),
                // );
              },
              child: Row(
                children: const <Widget>[
                  Icon(Icons.chat_bubble_outline_outlined)
                ],
              ),
            )
          ],
        ),
      ],
    );
  }
}
import 'package:flutter/material.dart';

//HEADLINE text theme

class HeadLine6 extends StatelessWidget {
  const HeadLine6(this.text, {super.key});

  final String text;
  @override
  Widget build(BuildContext context) {
    //double padding = (text == 'GAMES') ? 0 : 20;
    double padding = (text == 'GAMES') ? 20 : 20;
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 10, 0, padding),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleLarge,
        textAlign: TextAlign.center,
      ),
    );
  }
}

import 'package:flutter/material.dart';

class LogoButton extends StatelessWidget {
  const LogoButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Image.asset('assets/images/logo.png');
    // return IconButton(
    //           icon: Image.asset('assets/images/logo.png'),
    //           iconSize: 40,
    //           onPressed: () {
    //             //toMainPage
    //           },
    //         );
  }
}

import 'package:flutter/material.dart';

class ForgotPage extends StatelessWidget {
  const ForgotPage({super.key});

  @override
  Widget build(BuildContext context) {
    
    Widget backButton = Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Row(
                children: const <Widget>[
                  Icon(Icons.arrow_back_ios_outlined),
                  Text(
                    'Back',
                  ),
                ],
              ),
            )
          ],
        ),
      ],
    );
    double imageWidth =
        MediaQuery.of(context).orientation == Orientation.landscape ? 300 : 700;
    return Scaffold(
      body: ListView(
        children: [
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                backButton,
                Image.asset(
                  'assets/images/logo.png',
                  width: imageWidth,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
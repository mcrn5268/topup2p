import 'package:flutter/material.dart';

class CustomDivider extends StatelessWidget {
  const CustomDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      Row(children: <Widget>[
        Expanded(
          child: Container(
              margin: const EdgeInsets.only(left: 50.0, right: 20.0),
              child: const Divider(
                color: Colors.grey,
                height: 36,
              )),
        ),
        const Text("OR"),
        Expanded(
          child: Container(
              margin: const EdgeInsets.only(left: 20.0, right: 50.0),
              child: const Divider(
                color: Colors.grey,
                height: 36,
              )),
        ),
      ]),
    ]);
  }
}
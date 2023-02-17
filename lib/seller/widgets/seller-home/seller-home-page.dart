import 'package:flutter/material.dart';
import 'package:topup2p/global/globals.dart';
import 'package:topup2p/seller/seller-main.dart';

class SellerMainPage extends StatefulWidget {
  const SellerMainPage({Key? key}) : super(key: key);

  @override
  _SellerMainPageState createState() => _SellerMainPageState();
}

class _SellerMainPageState extends State<SellerMainPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: const Text(
        "Click + To Post",
        style: TextStyle(fontSize: 24),
      )),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if ((sellerData['GCash'] == null ||
                  sellerData['GCash'] == 'disabled') &&
              (sellerData['UnionBank'] == null ||
                  sellerData['UnionBank'] == 'disabled') &&
              (sellerData['Metrobank'] == null ||
                  sellerData['Metrobank'] == 'disabled')) {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: const Text('You must have a wallet')));

            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (_, __, ___) => const SellerMain(index: 2),
                transitionsBuilder: (_, a, __, c) =>
                    FadeTransition(opacity: a, child: c),
              ),
            );
          } else {
            
          }
        },
        backgroundColor: Colors.blueGrey,
        child: const Icon(Icons.add),
      ),
    );
  }
}

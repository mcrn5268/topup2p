import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:topup2p/cons-widgets/loadingscreen.dart';
import 'package:topup2p/global/globals.dart';
import 'package:topup2p/seller/widgets/messages.dart';
import 'package:topup2p/seller/widgets/seller-home/seller-home-page.dart';
import 'package:topup2p/seller/widgets/seller-profile/seller-profile.dart';
import 'package:topup2p/sqflite/firestore-sqflite.dart';
import 'package:topup2p/sqflite/sqflite-global.dart';

class SellerMain extends StatefulWidget {
  final int? index;
  const SellerMain({this.index, super.key});

  @override
  State<SellerMain> createState() => _SellerMain();
}

class _SellerMain extends State<SellerMain> {
  late int _currentIndex;
  final List<Widget> _children = [
    SellerMainPage(),
    ChatScreen(),
    SellerProfile(),
  ];
  @override
  void initState() {
    super.initState();
    _currentIndex = widget.index ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
          future: getSellerSqfliteData()
              .then((value) => checkAndUpdateDataSeller()),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return _children[_currentIndex];
            } else {
              return const LoadingScreen();
            }
          }),

      //_children[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        onTap: onTabTapped,
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            label: 'Messages',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  void onTabTapped(int index) {
    if (_currentIndex != index) {
      setState(() {
        _currentIndex = index;
      });
    }
  }
}

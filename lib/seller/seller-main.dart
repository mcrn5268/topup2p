import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:topup2p/cons-widgets/loadingscreen.dart';
import 'package:topup2p/global/globals.dart';
import 'package:topup2p/seller/seller-items.dart';
import 'package:topup2p/seller/widgets/messages.dart';
import 'package:topup2p/seller/widgets/seller-home/seller-home-page.dart';
import 'package:topup2p/seller/widgets/seller-profile/seller-profile.dart';
import 'package:topup2p/sqflite/firestore-sqflite.dart';
import 'package:topup2p/sqflite/sqflite-global.dart';

class SellerMain extends StatefulWidget {
  final int? index;
  const SellerMain({this.index, super.key});

  @override
  State<SellerMain> createState() => _SellerMainState();
}

class _SellerMainState extends State<SellerMain> {
  bool _isLoading = false;
  late int _currentIndex;
  final List<Widget> _children = [
    SellerMainPage(),
    ChatScreen(),
    SellerProfile(),
  ];
  final PageStorageBucket bucket = PageStorageBucket();

  @override
  void initState() {
    super.initState();
    _isLoading = true;
    executeSellerFuture();
    _currentIndex = widget.index ?? 0;
  }

  Future<void> executeSellerFuture() async {
    await getSellerSqfliteData();
    await checkAndUpdateDataSeller();
    await sellerGamesItems().loadItems();
    print('sellerItems length ${sellerItems.length}');
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const LoadingScreen()
        : Scaffold(
            body: PageStorage(
              bucket: bucket,
              child: IndexedStack(
                index: _currentIndex,
                children: _children,
              ),
            ),
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

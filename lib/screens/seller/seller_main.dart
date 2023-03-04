import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:topup2p/cloud/firestore.dart';
import 'package:topup2p/models/item_model.dart';
import 'package:topup2p/models/payment_model.dart';
import 'package:topup2p/providers/payment_provider.dart';
import 'package:topup2p/providers/sell_items_provder.dart';
import 'package:topup2p/providers/user_provider.dart';
import 'package:topup2p/screens/messages.dart';
import 'package:topup2p/screens/profile.dart';
import 'package:topup2p/screens/seller/seller_home.dart';
import 'package:topup2p/utilities/models_utils.dart';
import 'package:topup2p/widgets/loading_screen.dart';

class SellerMain extends StatefulWidget {
  final int? index;
  const SellerMain({this.index, super.key});

  @override
  State<SellerMain> createState() => _SellerMainState();
}

class _SellerMainState extends State<SellerMain> {
  bool _isLoading = false;
  late int _currentIndex;
  final PageStorageBucket bucket = PageStorageBucket();
  final List<Widget> _children = [
    SellerMainScreen(),
    MessagesScreen(),
    ChangeNotifierProvider<SellItemsProvider>.value(
      value: SellItemsProvider(),
      child: ProfileScreen(),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _isLoading = true;
    readSellerFirestore();
    _currentIndex = widget.index ?? 0;
  }

  Future<void> readSellerFirestore() async {
    Map<String, dynamic>? sellerData = await FirestoreService().read(
        collection: 'sellers',
        documentId:
            Provider.of<UserProvider>(context, listen: false).user!.uid);
    if (sellerData != null) {
      //MoPs
      try {
        Map<String, dynamic>? mopMap = sellerData['MoP'];
        //If seller has MoP from firestore
        if (mopMap!.isNotEmpty) {
          for (String paymentName in mopMap.keys) {
            Map<String, dynamic> paymentData = mopMap[paymentName];

            Payment payment = Payment(
              paymentname: paymentName,
              accountname: paymentData['account_name'],
              accountnumber: paymentData['account_number'],
              isEnabled: paymentData['status'] == 'enabled',
              paymentimage: 'assets/images/MoP/${paymentName}Card.png',
            );
            Provider.of<PaymentProvider>(context, listen: false)
                .addPayment(payment);
          }
        }
      } catch (e) {
        print(
            'Something went wrong with reading seller MoP data from Firestore: $e');
      }
      //MoPs
      try {
        Map<String, dynamic>? gamesMap = sellerData['games'];
        //If seller has games posted from firestore
        if (gamesMap!.isNotEmpty) {
          gamesMap.forEach((key, value) {
            Item? item = getItemByName(key);
            if (item != null) {
              Provider.of<SellItemsProvider>(context, listen: false)
                  .addItem(item, value, notify: false);
            }
          });
        }
      } catch (e) {
        print(
            'Something went wrong with reading seller games data from Firestore: $e');
      }
    }
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
            bottomNavigationBar: Stack(
              children: [
                BottomNavigationBar(
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
                Positioned(
                    right: MediaQuery.of(context).size.width / 2 - 15,
                    bottom: 35,
                    child: StreamBuilder(
                        stream: FirestoreService().getSeenStream(
                            Provider.of<UserProvider>(context, listen: false)
                                .user!
                                .uid),
                        builder: (context, snapshot) {
                          return Visibility(
                            visible: snapshot.hasData,
                            child: Align(
                              alignment: Alignment.topRight,
                              child: Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle, color: Colors.red),
                              ),
                            ),
                          );
                        }))
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

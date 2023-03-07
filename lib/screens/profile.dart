import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:topup2p/cloud/firestore.dart';
import 'package:topup2p/models/item_model.dart';
import 'package:topup2p/providers/favorites_provider.dart';
import 'package:topup2p/providers/payment_provider.dart';
import 'package:topup2p/providers/sell_items_provder.dart';
import 'package:topup2p/providers/user_provider.dart';
import 'package:topup2p/screens/edit_profile.dart';
import 'package:topup2p/screens/seller/wallets.dart';
import 'package:topup2p/screens/user/seller_register.dart';
import 'package:topup2p/utilities/profile_image.dart';
import 'package:topup2p/widgets/appbar/messagebutton.dart';
import 'package:topup2p/widgets/appbar/signoutbutton.dart';

//this is shared screen for both user type normal and seller
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({this.favorites, super.key});
  final List<Item>? favorites;
  @override
  Widget build(BuildContext context) {
    PaymentProvider? paymentProvider;
    FavoritesProvider? favProvider;
    UserProvider userProvider = Provider.of<UserProvider>(context);
    //if user type seller add PaymentProvider
    if (Provider.of<UserProvider>(context, listen: false).user!.type ==
        'seller') {
      try {
        paymentProvider = Provider.of<PaymentProvider>(context, listen: false);
      } catch (e) {
        print('Probably just transitioned from user to seller | $e');
      }
    }

    if (favorites != null) {
      favProvider = Provider.of<FavoritesProvider>(context);
      favProvider.clearFavorites(notify: false);
      favProvider.addItems(favorites!, notify: false);
    }
    Widget profileHead = Stack(
      alignment: Alignment.center,
      children: [
        CustomPaint(
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: 350,
          ),
          painter: HeaderCurvedContainer(),
        ),
        Positioned(
          top: 0,
          child: Padding(
            padding: const EdgeInsets.only(right: 8.0, top: 10),
            child: Container(
              width: MediaQuery.of(context).size.width,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  //if user type is normal show back button
                  if (userProvider.user!.type == 'normal') ...[
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          IconButton(
                              onPressed: () {
                                Navigator.pop(context, favProvider!.favorites);
                              },
                              icon: Icon(Icons.arrow_back_ios_outlined,
                                  color: Colors.white)),
                        ],
                      ),
                    ),
                    const MessageButton(fromProfile: true),
                  ],
                  const SignoutButton(),
                ],
              ),
            ),
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                userProvider.user!.name,
                style: TextStyle(
                  fontSize: 35.0,
                  letterSpacing: 1.5,
                  color: Colors.white,
                ),
              ),
            ),
            CircleAvatar(
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                radius: 80,
                child: getImage(context)),
          ],
        ),
      ],
    );
    Widget profileBody = Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: Column(
        children: [
          InkWell(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(Icons.edit, color: Colors.grey),
                Text('Edit Profile')
              ],
            ),
            onTap: () async {
              if (userProvider.user!.type == 'seller') {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (_, __, ___) => MultiProvider(
                      providers: [
                        ChangeNotifierProvider<SellItemsProvider>.value(
                          value: SellItemsProvider(),
                        ),
                        ChangeNotifierProvider<PaymentProvider>.value(
                          value: PaymentProvider(),
                        ),
                      ],
                      child: const EditProfileScreen(),
                    ),
                    transitionsBuilder: (_, a, __, c) =>
                        FadeTransition(opacity: a, child: c),
                  ),
                );
              } else if (userProvider.user!.type == 'normal') {
                print(
                    'edit profile button ${Provider.of<FavoritesProvider>(context, listen: false).favorites.length}');
                final favs = await Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (_, __, ___) => MultiProvider(
                      providers: [
                        ChangeNotifierProvider<FavoritesProvider>.value(
                          value: FavoritesProvider(),
                        ),
                      ],
                      child:
                          EditProfileScreen(favorites: favProvider!.favorites),
                    ),
                    transitionsBuilder: (_, a, __, c) =>
                        FadeTransition(opacity: a, child: c),
                  ),
                );
                if (favs.length != favProvider!.favorites.length) {
                  favProvider.clearFavorites();
                  favProvider.addItems(favs);
                }
              }
            },
          ),
          //different icon for different user type
          ListTile(
            leading: Icon(userProvider.user!.type == 'normal'
                ? Icons.person
                : Icons.storefront),
            title: Text(userProvider.user!.name),
          ),
          const Divider(),
          //todo
          ListTile(
            leading: Icon(Icons.phone_android),
            title: Text('+639 999 9999'),
          ),
          const Divider(),
          ListTile(
            leading: Icon(Icons.email),
            title: Text(userProvider.user!.email),
          ),
          const Divider(),
          //if user type seller show Wallets list tile
          if (userProvider.user!.type == 'seller') ...[
            InkWell(
                child: ListTile(
                  leading: Icon(Icons.wallet),
                  title: const Text("Wallets"),
                  trailing: Icon(Icons.arrow_forward_ios_outlined),
                ),
                onTap: () async {
                  final paymentsList = await Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (_, __, ___) =>
                          ChangeNotifierProvider<PaymentProvider>.value(
                        value: PaymentProvider(),
                        child: SellerWalletsScreen(
                            payments: paymentProvider!.payments),
                      ),
                      transitionsBuilder: (_, a, __, c) =>
                          FadeTransition(opacity: a, child: c),
                    ),
                  );
                  //after navigator.pop check if payment has been added
                  //if yes then update both provider and firestore
                  if (paymentsList != null) {
                    //add to provider
                    paymentProvider!.clearPayments();
                    paymentProvider.addAllPayments(paymentsList);
                    //add to firestore
                    Map<String, dynamic> forSellersMap = {};

                    for (int index = 0;
                        index < paymentProvider.payments.length;
                        index++) {
                      Map<String, dynamic> paymentMap = {
                        'account_name':
                            paymentProvider.payments[index].accountname,
                        'account_number':
                            paymentProvider.payments[index].accountnumber,
                        'status': paymentProvider.payments[index].isEnabled
                            ? 'enabled'
                            : 'disabled'
                      };

                      String paymentName =
                          paymentProvider.payments[index].paymentname;
                      forSellersMap['MoP'] ??=
                          {}; // Initialize 'MoP' map if it doesn't exist
                      forSellersMap['MoP'][paymentName] ??=
                          {}; // Initialize payment map if it doesn't exist
                      forSellersMap['MoP'][paymentName]
                          .addAll(paymentMap); // Add payment map to 'MoP'
                    }
                    //todo fix when wallet is updated, update all firestore documents
                    FirestoreService().create(
                        collection: 'sellers',
                        documentId: userProvider.user!.uid,
                        data: forSellersMap);
                  }
                }),
            const Divider(),
          ],
        ],
      ),
    );
    Widget wantToSell = Padding(
      padding: const EdgeInsets.fromLTRB(0, 50, 0, 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          InkWell(
            child: RichText(
              textScaleFactor: MediaQuery.of(context).textScaleFactor,
              textAlign: TextAlign.center,
              text: TextSpan(
                style: const TextStyle(fontSize: 15, color: Colors.black),
                children: const [
                  TextSpan(
                    text: 'Want to sell?',
                    style: TextStyle(decoration: TextDecoration.underline),
                  ),
                ],
              ),
            ),
            onTap: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) =>
                      ChangeNotifierProvider<FavoritesProvider>.value(
                    value: FavoritesProvider(),
                    child: const SellerRegisterScreen(),
                  ),
                  transitionsBuilder: (_, a, __, c) =>
                      FadeTransition(opacity: a, child: c),
                ),
              );
            },
          ),
        ],
      ),
    );
    return SafeArea(
      child: Scaffold(
        body: ListView(children: [
          profileHead,
          profileBody,
          //if user type normal show an option where they can be a seller
          if (userProvider.user!.type == 'normal') ...[wantToSell]
        ]),
      ),
    );
  }
}

// CustomPainter class to for the header curved-container
class HeaderCurvedContainer extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..shader = LinearGradient(
        colors: [Colors.blueGrey, Colors.black],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    Path path = Path()
      ..relativeLineTo(0, 150)
      ..quadraticBezierTo(size.width / 2, 300.0, size.width, 150)
      ..relativeLineTo(0, -150)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

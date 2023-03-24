import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:topup2p/cloud/firestore.dart';
import 'package:topup2p/models/item_model.dart';
import 'package:topup2p/models/payment_model.dart';
import 'package:topup2p/providers/favorites_provider.dart';
import 'package:topup2p/providers/payment_provider.dart';
import 'package:topup2p/providers/sell_items_provider.dart';
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
    SellItemsProvider? siProvider;
    FavoritesProvider? favProvider;
    UserProvider userProvider =
        Provider.of<UserProvider>(context, listen: false);
    //if user type seller add PaymentProvider
    if (userProvider.user != null) {
      if (userProvider.user!.type == 'seller') {
        try {
          paymentProvider =
              Provider.of<PaymentProvider>(context, listen: false);
          siProvider = Provider.of<SellItemsProvider>(context, listen: false);
        } catch (e) {
          if (kDebugMode) {
            print('Probably just transitioned from user to seller | $e');
          }
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
            painter: HeaderCurvedContainer(context),
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              height: 350,
            ),
          ),
          Positioned(
            top: 0,
            child: Padding(
              padding: const EdgeInsets.only(right: 8.0, top: 10),
              child: SizedBox(
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
                                  Navigator.pop(
                                      context, favProvider!.favorites);
                                },
                                icon: const Icon(Icons.arrow_back_ios_outlined,
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
                  style: const TextStyle(
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
                children: const [
                  Icon(Icons.edit, color: Colors.grey),
                  Text('Edit Profile')
                ],
              ),
              onTap: () async {
                if (userProvider.user!.type == 'seller') {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (_, __, ___) => const EditProfileScreen(),
                      transitionsBuilder: (_, a, __, c) =>
                          FadeTransition(opacity: a, child: c),
                    ),
                  );
                } else if (userProvider.user!.type == 'normal') {
                  await Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (_, __, ___) => const EditProfileScreen(),
                      transitionsBuilder: (_, a, __, c) =>
                          FadeTransition(opacity: a, child: c),
                    ),
                  );
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
            const ListTile(
              leading: Icon(Icons.phone_android),
              title: Text('+639 999 9999'),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.email),
              title: Text(userProvider.user!.email),
            ),
            const Divider(),
            //if user type seller show Wallets list tile
            if (userProvider.user!.type == 'seller') ...[
              InkWell(
                  child: const ListTile(
                    leading: Icon(Icons.wallet),
                    title: Text("Wallets"),
                    trailing: Icon(Icons.arrow_forward_ios_outlined),
                  ),
                  onTap: () async {
                    final returnList = await Navigator.push(
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
                          child: SellerWalletsScreen(
                            payments: paymentProvider!.payments,
                            //must include SellItemsProvider
                            //because if there is no enabled wallets
                            //all games will be disabled
                            siItems: siProvider!.Sitems,
                          ),
                        ),
                        transitionsBuilder: (_, a, __, c) =>
                            FadeTransition(opacity: a, child: c),
                      ),
                    );
                    //after navigator.pop check if payment has been added
                    //if yes then update both provider and firestore
                    if (returnList[0] != null) {
                      //add to provider
                      paymentProvider!.clearPayments();
                      paymentProvider.addAllPayments(returnList[0]);
                      //add to firestore
                      Map<String, dynamic> forSellersMap = {};
                      Map<String, dynamic> forGamesMap = {};
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

                        forGamesMap['mop$index'] = {
                          'name': paymentName,
                          ...paymentMap
                        };
                      }
                      FirestoreService().create(
                          collection: 'sellers',
                          documentId: userProvider.user!.uid,
                          data: forSellersMap);
                      for (var item in siProvider!.Sitems) {
                        Item itemObject = item.keys.first;
                        FirestoreService().create(
                            collection: 'sellers',
                            documentId: userProvider.user!.uid,
                            data: {'mop': forGamesMap},
                            subcollection: 'games',
                            subdocumentId: itemObject.name);

                        FirestoreService().create(
                            collection: 'seller_games_data',
                            documentId: itemObject.name,
                            data: {
                              userProvider.user!.name: {'mop': forGamesMap}
                            });
                      }
                    }
                    if (returnList[2] == true) {
                      siProvider!.rebuild();
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
                text: const TextSpan(
                  style: TextStyle(fontSize: 15),
                  children: [
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
                    pageBuilder: (_, __, ___) => const SellerRegisterScreen(),
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
    } else {
      return Container();
    }
  }
}

// CustomPainter class to for the header curved-container
class HeaderCurvedContainer extends CustomPainter {
  const HeaderCurvedContainer(this.context);
  final BuildContext context;
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..shader = LinearGradient(
        colors: MediaQuery.of(context).platformBrightness == Brightness.dark
            ? [Colors.teal, Colors.black]
            : [Colors.blueGrey, Colors.black],
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

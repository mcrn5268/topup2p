import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';
import 'package:topup2p/models/payment_model.dart';
import 'package:topup2p/providers/payment_provider.dart';
import 'package:topup2p/screens/seller/add-update_wallet.dart';

class SellerWalletsScreen extends StatefulWidget {
  const SellerWalletsScreen({required this.payments, super.key});
  final List<Payment> payments;
  @override
  State<SellerWalletsScreen> createState() => _SellerWalletsScreenState();
}

class _SellerWalletsScreenState extends State<SellerWalletsScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.payments.isNotEmpty) {
      Provider.of<PaymentProvider>(context, listen: false)
          .clearPayments(notify: false);
      Provider.of<PaymentProvider>(context, listen: false)
          .addAllPayments(widget.payments, notify: false);
    }
  }

  int limit = 3;

  @override
  Widget build(BuildContext context) {
    PaymentProvider paymentProvider =
        Provider.of<PaymentProvider>(context, listen: false);

    Future<void> toCardWallet({Payment? card}) async {
      final walletPayments = await Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) =>
              ChangeNotifierProvider<PaymentProvider>.value(
            value: PaymentProvider(),
            child: AddUpdateWalletScreen(
                cardWallet: card, paymentList: paymentProvider.payments),
          ),
          transitionsBuilder: (_, a, __, c) =>
              FadeTransition(opacity: a, child: c),
        ),
      );
      //add to provider
      if (walletPayments != null) {
        paymentProvider.updatePaymentList(walletPayments);
        setState(() {});
      }
    }

    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
              onPressed: () {
                Navigator.pop(context, paymentProvider.payments);
              },
              icon: const Icon(
                Icons.arrow_back_ios_outlined,
              )),
          centerTitle: true,
          title: const Text(
            'Wallets',
            style: TextStyle(),
          ),
          shape: const Border(bottom: BorderSide(color: Colors.grey, width: 1)),
        ),
        body: Consumer<PaymentProvider>(builder: (context, paymentProvider, _) {
          return Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 25, right: 25, bottom: 10),
                child: ListView(children: [
                  ColorFiltered(
                    colorFilter: ColorFilter.mode(
                        MediaQuery.of(context).platformBrightness ==
                                Brightness.dark
                            ? Colors.white
                            : Colors.black,
                        BlendMode.srcIn),
                    child: Image.asset(
                      'assets/images/wallet-placeholder.png',
                      height: MediaQuery.of(context).orientation ==
                              Orientation.portrait
                          ? MediaQuery.of(context).size.width - 200
                          : MediaQuery.of(context).size.width / 5,
                    ),
                  ),
                  const Divider(),
                  if (paymentProvider.payments.isNotEmpty) ...[
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: paymentProvider.payments.length,
                      itemBuilder: (BuildContext context, int index) {
                        var paymentItem = paymentProvider.payments[index];
                        return AnimationConfiguration.staggeredList(
                          position: index,
                          duration: const Duration(milliseconds: 375),
                          child: SlideAnimation(
                            verticalOffset: 50.0,
                            child: FadeInAnimation(
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: InkWell(
                                  onTap: () => toCardWallet(card: paymentItem),
                                  child: Stack(
                                    alignment: AlignmentDirectional.center,
                                    children: [
                                      AspectRatio(
                                        aspectRatio: 1.5873,
                                        child: Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width -
                                              100,
                                          decoration: BoxDecoration(
                                            image: DecorationImage(
                                              image: AssetImage(
                                                paymentItem.paymentimage,
                                              ),fit: BoxFit.cover
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.grey
                                                    .withOpacity(0.5),
                                                spreadRadius: 1,
                                                blurRadius: 3,
                                                offset: const Offset(0, 1),
                                              ),
                                            ],
                                          ),
                                          foregroundDecoration: BoxDecoration(
                                            color: paymentItem.isEnabled
                                                ? Colors.transparent
                                                : Colors.grey,
                                            backgroundBlendMode:
                                                BlendMode.saturation,
                                          ),
                                          // child: Image.asset(
                                          //   paymentItem.paymentimage,
                                          //   width: MediaQuery.of(context)
                                          //           .size
                                          //           .width -
                                          //       100,
                                          // ),
                                        ),
                                      ),
                                      const Align(
                                          alignment:
                                              AlignmentDirectional.centerEnd,
                                          child: SizedBox(
                                              width: 30.0,
                                              height: 30.0,
                                              child: Icon(Icons
                                                  .arrow_forward_ios_outlined))),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ] else ...[
                    SizedBox(
                      height: MediaQuery.of(context).size.height / 2,
                      child: const Center(
                        child: Text('Click + To Add',
                            style: TextStyle(fontSize: 24)),
                      ),
                    )
                  ]
                ]),
              ),
              Positioned(
                bottom: 15.0,
                right: 16.0,
                child: FloatingActionButton(
                  onPressed: () {
                    toCardWallet();
                  },
                  child: const Icon(Icons.add),
                ),
              ),
            ],
          );
        }));
  }
}

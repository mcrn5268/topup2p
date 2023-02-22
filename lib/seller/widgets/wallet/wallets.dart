import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:topup2p/DigitInputFormatter.dart';
import 'package:topup2p/global/globals.dart';
import 'package:topup2p/seller/widgets/wallet/wallet-info.dart';

class SellerWallets extends StatefulWidget {
  const SellerWallets({super.key});

  @override
  State<SellerWallets> createState() => _SellerWalletsState();
}

class _SellerWalletsState extends State<SellerWallets> {
  List<bool> _checkboxValues = [false, false, false];
  List<bool> _showInputFields = [false, false, false];
  TextEditingController _GCashcont = TextEditingController();
  TextEditingController _UBcont = TextEditingController();
  TextEditingController _MBcont = TextEditingController();
  TextEditingController _GCashcont2 = TextEditingController();
  TextEditingController _UBcont2 = TextEditingController();
  TextEditingController _MBcont2 = TextEditingController();

  @override
  void initState() {
    super.initState();
    //sellerData['GCash']!['status'] = false;
  }

  int limit = 3;
  //dispose all controllers
  void _handleCheckboxValueChange(int index, bool? value) {
    setState(() {
      _checkboxValues[index] = value!;
      _showInputFields[index] =
          _showInputFields[index] ? false : !_showInputFields[index] == value;
    });
  }

  @override
  void dispose() {
    super.dispose();
    _GCashcont.dispose();
    _UBcont.dispose();
    _MBcont.dispose();
    _GCashcont2.dispose();
    _UBcont2.dispose();
    _MBcont2.dispose();
  }

  void cardButtonPress(BuildContext context, String card) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => WalletInfo(card),
        transitionsBuilder: (_, a, __, c) =>
            FadeTransition(opacity: a, child: c),
      ),
    ).then((_) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(
                Icons.arrow_back_ios_outlined,
                color: Colors.black,
              )),
        ),
        body: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 25, right: 25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.wallet,
                    size: 100,
                  ),
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: InkWell(
                      onTap: () => cardButtonPress(context, 'GCash'),
                      child: Stack(
                        alignment: AlignmentDirectional.center,
                        children: [
                          Container(
                            foregroundDecoration: BoxDecoration(
                              color: sellerData['GCash'] == 'enabled'
                                  ? Colors.transparent
                                  : Colors.grey,
                              backgroundBlendMode: BlendMode.saturation,
                            ),
                            child: Image.asset(
                              'assets/images/MoP/GCashCard.png',
                              width: MediaQuery.of(context).size.width - 100,
                            ),
                          ),
                          Align(
                              alignment: AlignmentDirectional.centerEnd,
                              child: Container(
                                  width: 50.0,
                                  height: 50.0,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.black,
                                      width: 2.0,
                                    ),
                                  ),
                                  child:
                                      Icon(Icons.arrow_forward_ios_outlined))),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: InkWell(
                      onTap: () => cardButtonPress(context, 'UnionBank'),
                      child: Stack(
                        alignment: AlignmentDirectional.center,
                        children: [
                          Container(
                            foregroundDecoration: BoxDecoration(
                              color: sellerData['UnionBank'] == 'enabled'
                                  ? Colors.transparent
                                  : Colors.grey,
                              backgroundBlendMode: BlendMode.saturation,
                            ),
                            child: Image.asset(
                              'assets/images/MoP/UnionBankCard.png',
                              width: MediaQuery.of(context).size.width - 100,
                            ),
                          ),
                          Align(
                              alignment: AlignmentDirectional.centerEnd,
                              child: Container(
                                  width: 50.0,
                                  height: 50.0,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.black,
                                      width: 2.0,
                                    ),
                                  ),
                                  child:
                                      Icon(Icons.arrow_forward_ios_outlined))),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: InkWell(
                      onTap: () => cardButtonPress(context, 'Metrobank'),
                      child: Stack(
                        alignment: AlignmentDirectional.center,
                        children: [
                          Container(
                            foregroundDecoration: BoxDecoration(
                              color: sellerData['Metrobank'] == 'enabled'
                                  ? Colors.transparent
                                  : Colors.grey,
                              backgroundBlendMode: BlendMode.saturation,
                            ),
                            child: Image.asset(
                              'assets/images/MoP/MetrobankCard.png',
                              width: MediaQuery.of(context).size.width - 100,
                            ),
                          ),
                          Align(
                              alignment: AlignmentDirectional.centerEnd,
                              child: Container(
                                  width: 50.0,
                                  height: 50.0,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.black,
                                      width: 2.0,
                                    ),
                                  ),
                                  child:
                                      Icon(Icons.arrow_forward_ios_outlined))),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ));
  }
}

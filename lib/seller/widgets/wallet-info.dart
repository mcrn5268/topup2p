import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:topup2p/DigitInputFormatter.dart';
import 'package:topup2p/global/globals.dart';
import 'package:topup2p/seller/widgets/seller-profile/update-card-db.dart';

class WalletInfo extends StatefulWidget {
  const WalletInfo(this.cardWallet, {super.key});
  final String cardWallet;
  @override
  State<WalletInfo> createState() => _WalletInfoState();
}

class _WalletInfoState extends State<WalletInfo> {
  TextEditingController _controllername = TextEditingController();
  bool _isEditablename = false;
  TextEditingController _controllernum = TextEditingController();
  bool _isEditablenum = false;
  int limit = 3;
  bool isToggled = false;
  @override
  void initState() {
    super.initState();
    _controllername.text = sellerData['${widget.cardWallet}name'] ?? '';
    _controllernum.text = sellerData['${widget.cardWallet}num'] ?? '';
  }

  @override
  void dispose() {
    _controllername.dispose();
    _controllernum.dispose();
    super.dispose();
  }

  void updateSellerWallet(String type) {
    if (type == 'name') {
      sellerData['${widget.cardWallet}$type'] = _controllername.text;
    } else if (type == 'num') {
      sellerData['${widget.cardWallet}$type'] = _controllernum.text.toString();
    }
    if (_controllername.text == '' && _controllernum.text.toString() == '') {
      setState(() {
        sellerData[widget.cardWallet] = 'disabled';
      });
    } else {
      setState(() {
        sellerData[widget.cardWallet] = 'enabled';
      });
    }
    updateOrInsertRow(widget.cardWallet);
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
          flexibleSpace: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  FlutterSwitch(
                    height: 20.0,
                    width: 50.0,
                    padding: 4.0,
                    toggleSize: 15.0,
                    borderRadius: 10.0,
                    activeColor: Colors.green,
                    inactiveColor: Colors.red,
                    value: sellerData['${widget.cardWallet}'] == 'enabled',
                    onToggle: (value) {
                      if (_controllername.text == '' &&
                          _controllernum.text.toString() == '') {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: const Text(
                                'Account Name and/or Number is required')));
                      } else {
                        setState(() {
                          sellerData['${widget.cardWallet}'] =
                              value ? 'enabled' : 'disabled';
                          updateOrInsertRow(widget.cardWallet);
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.only(left: 25, right: 25),
          child: ListView(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/MoP/${widget.cardWallet}Card.png',
                    width: logicalWidth - 100,
                  ),
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.only(left: 50),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _controllername,
                                enabled: _isEditablename,
                              ),
                            ),
                            Container(
                              width: 50,
                              height: 48.0,
                              child: IconButton(
                                icon: _isEditablename
                                    ? Icon(Icons.check)
                                    : Icon(Icons.edit),
                                onPressed: () {
                                  if (_isEditablename) {
                                    updateSellerWallet('name');
                                  }

                                  setState(() {
                                    _isEditablename = !_isEditablename;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 50),
                          child: Text('Account Name'),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                keyboardType: TextInputType.number,
                                inputFormatters: [DigitInputFormatter(limit)],
                                controller: _controllernum,
                                enabled: _isEditablenum,
                                onChanged: (value) {
                                  if (widget.cardWallet == 'GCash') {
                                    if (value.length >= 2 &&
                                        value.substring(0, 2) == '09') {
                                      limit = 11;
                                    } else if (value.length >= 3 &&
                                        value.substring(0, 3) == '639') {
                                      limit = 12;
                                    }
                                  } else if (widget.cardWallet == 'UnionBank') {
                                    limit = 12;
                                  } else if (widget.cardWallet == 'Metrobank') {
                                    limit = 13;
                                  }
                                  setState(() {});
                                },
                              ),
                            ),
                            Container(
                              width: 50,
                              height: 48.0,
                              child: IconButton(
                                icon: _isEditablenum
                                    ? Icon(Icons.check)
                                    : Icon(Icons.edit),
                                onPressed: () {
                                  if (_isEditablenum) {
                                    updateSellerWallet('num');
                                  }
                                  setState(() {
                                    _isEditablenum = !_isEditablenum;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 50),
                          child: Text('Account Number'),
                        ),
                      ],
                    ),
                  )
                ],
              )
            ],
          ),
        ));
  }
}

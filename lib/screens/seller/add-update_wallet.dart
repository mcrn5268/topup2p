// ignore_for_file: file_names

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:provider/provider.dart';
import 'package:topup2p/cloud/firestore.dart';
import 'package:topup2p/models/item_model.dart';
import 'package:topup2p/models/payment_model.dart';
import 'package:topup2p/providers/payment_provider.dart';
import 'package:topup2p/providers/sell_items_provder.dart';
import 'package:topup2p/providers/user_provider.dart';
import 'package:topup2p/utilities/digit_input_formatter.dart';
import 'package:topup2p/utilities/models_utils.dart';
import 'package:topup2p/widgets/show_dialog.dart';
import 'package:topup2p/widgets/toast.dart';

//todo if there is no wallet left, disable all of the items
//also show warning
class AddUpdateWalletScreen extends StatefulWidget {
  const AddUpdateWalletScreen(
      {required this.cardWallet,
      required this.paymentList,
      required this.gamesItemsList,
      super.key});
  final Payment? cardWallet;
  final List<Payment> paymentList;
  final List<Map<Item, String>> gamesItemsList;
  @override
  State<AddUpdateWalletScreen> createState() => _AddUpdateWalletScreenState();
}

class _AddUpdateWalletScreenState extends State<AddUpdateWalletScreen> {
  final TextEditingController _controllername = TextEditingController();
  final TextEditingController _controllernum = TextEditingController();
  bool _isEditable = false;
  final TextEditingController _typeAheadController = TextEditingController();
  late int limit;
  bool isToggled = false;
  List<String> threeMOPs = ['GCash', 'UnionBank', 'Metrobank'];
  bool flag = false;
  Payment? payment;
  String _hintTextName = '';
  String _hintTextNum = '';
  late PaymentProvider paymentProvider;
  late SellItemsProvider siProvider;

  bool switchFlag = true;
  @override
  void initState() {
    super.initState();
    paymentProvider = Provider.of<PaymentProvider>(context, listen: false);
    siProvider = Provider.of<SellItemsProvider>(context, listen: false);
    if (widget.cardWallet != null) {
      payment = widget.cardWallet;
      _typeAheadController.text = payment!.paymentname;
      _controllername.text = payment!.accountname;
      _controllernum.text = payment!.accountnumber;
      flag = true;
    }
    if (widget.paymentList.isNotEmpty) {
      paymentProvider.clearPayments(notify: false);
      paymentProvider.addAllPayments(widget.paymentList, notify: false);
    }
    if (widget.gamesItemsList.isNotEmpty) {
      siProvider.clearItems(notify: false);
      siProvider.addItems(widget.gamesItemsList, notify: false);
    }
    limit = max(_controllernum.text.toString().length, 3);
  }

  @override
  void dispose() {
    _controllername.dispose();
    _controllernum.dispose();
    _typeAheadController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget walletsList = TypeAheadFormField(
      textFieldConfiguration: TextFieldConfiguration(
        controller: _typeAheadController,
        decoration: const InputDecoration(
          labelText: 'Select a wallet',
          border: OutlineInputBorder(),
        ),
        //on keyboard submit/enter/send/confirm
        onSubmitted: (value) {
          if (value.isEmpty) {
            // If the field is empty, do nothing
            flag = false;
            return;
          }
          final suggestions = threeMOPs.where(
              (option) => option.toLowerCase().contains(value.toLowerCase()));
          if (suggestions.isNotEmpty) {
            // If there are suggestions, select the first one
            setState(() {
              _typeAheadController.text = suggestions.first;
              _hintTextName = 'John Smith';
              _hintTextNum = _typeAheadController.text == 'GCash'
                  ? '63 (9XX) XXX XXXX or 0 (9XX) XXX XXXX'
                  : _typeAheadController.text == 'Unionbank'
                      ? 'XXXX XXXX XXXX'
                      : _typeAheadController.text == 'MetroBank'
                          ? 'XXXX XXXX XXXXX'
                          : 'XXXXXXXXXXX';
              payment =
                  getPaymentByName(suggestions.first, paymentProvider.payments);
              if (payment != null) {
                _controllername.text = payment!.accountname;
                _controllernum.text = payment!.accountnumber;
                flag = true;
              }
            });
          } else {
            // If there are no suggestions, clear the text field
            setState(() {
              _typeAheadController.clear();
              _controllername.text = '';
              _controllernum.text = '';
              _hintTextName = '';
              _hintTextNum = '';

              flag = false;
            });
          }
        },
      ),
      suggestionsCallback: (pattern) {
        return threeMOPs.where(
            (option) => option.toLowerCase().contains(pattern.toLowerCase()));
      },
      itemBuilder: (context, suggestion) {
        return ListTile(
          title: Text(suggestion),
        );
      },
      //suggestion selected
      onSuggestionSelected: (suggestion) {
        setState(() {
          _typeAheadController.text = suggestion;
          _hintTextName = 'John Smith';
          _hintTextNum = _typeAheadController.text == 'GCash'
              ? '63 (9XX) XXX XXXX or 0 (9XX) XXX XXXX'
              : _typeAheadController.text == 'UnionBank'
                  ? 'XXXX XXXX XXXX'
                  : _typeAheadController.text == 'Metrobank'
                      ? 'XXXX XXXX XXXXX'
                      : 'XXXXXXXXXXX';
          payment = getPaymentByName(suggestion, paymentProvider.payments);
          if (payment != null) {
            _controllername.text = payment!.accountname;
            _controllernum.text = payment!.accountnumber;
            flag = true;
          }
        });
      },
    );
    Widget inputFields = Padding(
      padding: const EdgeInsets.only(left: 20, right: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            children: [
              Expanded(
                child: Stack(
                  children: [
                    TextField(
                      decoration: InputDecoration(hintText: _hintTextName),
                      controller: _controllername,
                      enabled: _isEditable,
                      onChanged: (_) => setState(() {}),
                    ),
                    Visibility(
                      visible:
                          _controllername.text != '' && _isEditable == true,
                      child: Positioned(
                          right: 0,
                          child: SizedBox(
                            height: 58,
                            child: IconButton(
                              icon: const Icon(Icons.close,
                                  color: Colors.grey, size: 20),
                              onPressed: () {
                                setState(() {
                                  _controllername.text = '';
                                });
                              },
                            ),
                          )),
                    )
                  ],
                ),
              ),
            ],
          ),
          const Text('Account Name'),
          Row(
            children: [
              Expanded(
                child: Stack(
                  children: [
                    TextField(
                      decoration: InputDecoration(hintText: _hintTextNum),
                      keyboardType: TextInputType.number,
                      inputFormatters: [DigitInputFormatter(limit)],
                      controller: _controllernum,
                      enabled: _isEditable,
                      onChanged: (value) {
                        if (_typeAheadController.text == 'GCash') {
                          if (value.length >= 2 &&
                              value.substring(0, 2) == '09') {
                            limit = 11;
                          } else if (value.length >= 3 &&
                              value.substring(0, 3) == '639') {
                            limit = 12;
                          }
                        } else if (_typeAheadController.text == 'UnionBank') {
                          limit = 12;
                        } else if (_typeAheadController.text == 'Metrobank') {
                          limit = 13;
                        }
                        setState(() {});
                      },
                    ),
                    Visibility(
                      visible: _controllernum.text != '' && _isEditable == true,
                      child: Positioned(
                          right: 0,
                          child: SizedBox(
                            height: 58,
                            child: IconButton(
                              icon: const Icon(Icons.close,
                                  color: Colors.grey, size: 20),
                              onPressed: () {
                                setState(() {
                                  _controllernum.text = '';
                                });
                              },
                            ),
                          )),
                    )
                  ],
                ),
              ),
            ],
          ),
          const Text('Account Number'),
          SizedBox(
            height: 63,
            child: Row(
              children: [
                Visibility(
                    visible: _typeAheadController.text != '',
                    child: Flexible(
                        child: Padding(
                      padding: const EdgeInsets.only(top: 15),
                      child: GestureDetector(
                        onTap: () {
                          if (_isEditable == true) {
                            if ((_controllername.text == '' &&
                                    _controllernum.text == '') ||
                                ((payment != null)
                                    ? (payment!.accountname ==
                                            _controllername.text &&
                                        payment!.accountnumber ==
                                            _controllernum.text)
                                    : false)) {
                              showToast('No changes has been made');

                              setState(() {
                                _isEditable = !_isEditable;
                              });
                            } else if (_controllername.text == '') {
                              showToast('Account name must not be empty');
                            } else if (_controllernum.text == '') {
                              showToast('Account number must not be empty');
                            } else if (_controllernum.text.length != limit) {
                              if (_controllernum.text.length == 1) {
                                showToast(
                                    'Account number start with either 09 or 639');
                              } else {
                                showToast(
                                    'Account number must have $limit digits');
                              }
                            } else {
                              payment = Payment(
                                  paymentname: _typeAheadController.text,
                                  paymentimage:
                                      'assets/images/MoP/${_typeAheadController.text}Card.png',
                                  accountname: _controllername.text,
                                  accountnumber: _controllernum.text,
                                  isEnabled: true);
                              final paymentObject = getPaymentByName(
                                  _typeAheadController.text,
                                  paymentProvider.payments);
                              if (paymentObject == null) {
                                paymentProvider.addPayment(payment!,
                                    notify: false);
                              } else {
                                paymentProvider.updatePayment(paymentObject,
                                    accountname: _controllername.text,
                                    accountnumber: _controllernum.text);
                              }
                              showToast('Wallet updated');
                              setState(() {
                                _isEditable = !_isEditable;
                              });
                            }
                          } else {
                            setState(() {
                              _isEditable = !_isEditable;
                            });
                          }
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            _isEditable
                                ? const Icon(Icons.check)
                                : const Icon(Icons.edit),
                            Text(_isEditable ? 'Save' : 'Edit')
                          ],
                        ),
                      ),
                    ))),
              ],
            ),
          ),
        ],
      ),
    );
    return WillPopScope(
      onWillPop: () async {
        List<dynamic> toReturn = [paymentProvider.payments, siProvider.Sitems];
        Navigator.pop(context, toReturn);
        return false;
      },
      child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
                onPressed: () {
                  List<dynamic> toReturn = [
                    paymentProvider.payments,
                    siProvider.Sitems
                  ];
                  Navigator.pop(context, toReturn);
                },
                icon: const Icon(
                  Icons.arrow_back_ios_outlined,
                )),
            flexibleSpace: SafeArea(
              child: Visibility(
                visible: flag,
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
                        value: payment != null ? payment!.isEnabled : false,
                        onToggle: (value) async {
                          UserProvider userProvider =
                              Provider.of<UserProvider>(context, listen: false);
                          var enabledPayments = paymentProvider.payments
                              .where((payment) => payment.isEnabled);
                          bool onlyOne = enabledPayments.length == 1;

                          if (onlyOne) {
                            switchFlag = (await dialogBuilder(
                                context,
                                'Confirm',
                                'If you disable all of your wallet, all of your games listen will be disabled as well. \n\nDo you want to proceed?'))!;
                          }
                          if (switchFlag) {
                            if (onlyOne) {
                              FirestoreService().toggleAllGames(
                                  uid: userProvider.user!.uid,
                                  enable: false,
                                  shopName: userProvider.user!.name);
                              siProvider.toggleAllGamesProvider(false);
                            }
                            paymentProvider.updatePayment(payment!,
                                isEnabled: !payment!.isEnabled, notify: false);
                            setState(() {
                              !payment!.isEnabled;
                            });
                          }
                        },
                      ),
                    ],
                  ),
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
                      'assets/images/MoP/placeholder.png',
                      height: MediaQuery.of(context).orientation ==
                              Orientation.portrait
                          ? MediaQuery.of(context).size.width - 200
                          : MediaQuery.of(context).size.width / 5,
                    ),
                    Stack(
                      children: [
                        walletsList,
                        Visibility(
                          visible: _typeAheadController.text != '' &&
                              _isEditable == false,
                          child: Positioned(
                              right: 0,
                              child: SizedBox(
                                height: 58,
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.close,
                                    color: Colors.grey,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _typeAheadController.text = '';
                                      _controllername.text = '';
                                      _controllernum.text = '';
                                      _hintTextName = '';
                                      _hintTextNum = '';
                                      flag = false;
                                    });
                                  },
                                ),
                              )),
                        )
                      ],
                    ),
                    const Divider(),
                    inputFields
                  ],
                )
              ],
            ),
          )),
    );
  }
}

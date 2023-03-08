// ignore_for_file: file_names, non_constant_identifier_names

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
import 'package:topup2p/utilities/globals.dart';
import 'package:topup2p/utilities/image_file_utils.dart';
import 'package:topup2p/utilities/models_utils.dart';
import 'package:topup2p/utilities/profile_image.dart';
import 'package:topup2p/widgets/loading_screen.dart';

class AddItemSell extends StatefulWidget {
  const AddItemSell(
      {required this.Sitems,
      required this.payments,
      this.update,
      this.game,
      super.key});
  final bool? update;
  final String? game;
  final List<Map<Item, String>>? Sitems;
  final List<Payment> payments;

  @override
  State<AddItemSell> createState() => _AddItemSellState();
}

class _AddItemSellState extends State<AddItemSell> {
  final List<TextEditingController> _cRate = List.generate(
    12,
    (index) => TextEditingController(),
  );
  final List<String?> _errorText = List.generate(12, (index) => null);
  final TextEditingController _typeAheadController = TextEditingController();
  String gameIconPath = 'assets/icons/coin.png';
  bool _isLoading = false;
  int mapIndex = 0;
  bool? isEnabled = true;
  bool _isLoadingData = false;
  Future<Map<String, dynamic>>? rates;
  bool _ratesFlag = true;
  bool _switchVisible = false;
  String forButton = 'ADD';

  Map<String, dynamic> itemDataMap = {};

  void _cRateValidation() {
    for (int i = 0; i < _cRate.length / 2; i++) {
      TextEditingController controller = _cRate[i];
      TextEditingController controller2 = _cRate[i + 6];
      if (controller.text != '') {
        if (controller2.text == '') {
          _errorText[i + 6] = 'Must have a value';
          _ratesFlag = false;
        }
      } else if (controller2.text != '') {
        if (controller.text == '') {
          _errorText[i] = 'Must have a value';
          _ratesFlag = false;
        }
      } else if (controller.text != '' && controller2.text != '') {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content:
                Text('Rates must not be empty if you wish to add an item!')));
        _ratesFlag = false;
      }
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.update == true) {
      _typeAheadController.text = widget.game!;
      gameIconPath = gameIcon(_typeAheadController.text);
      _isLoadingData = true;
      forButton = 'UPDATE';
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        checkGame(widget.game!);
      });
    }
    if (widget.Sitems != null || widget.Sitems!.isNotEmpty) {
      Provider.of<SellItemsProvider>(context, listen: false)
          .addItems(widget.Sitems!);

      Provider.of<PaymentProvider>(context, listen: false)
          .clearPayments(notify: false);
      Provider.of<PaymentProvider>(context, listen: false)
          .addAllPayments(widget.payments, notify: false);
    }
  }

  Future<void> checkGame(String gameName) async {
    //check game if it exists if yes then populate the input fields
    final item = getItemByName(gameName);
    if (item != null) {
      bool isAlreadyPosted =
          Provider.of<SellItemsProvider>(context, listen: false)
              .itemExist(item);
      if (isAlreadyPosted) {
        itemDataMap = await FirestoreService().read(
            collection: 'sellers',
            documentId:
                Provider.of<UserProvider>(context, listen: false).user!.uid,
            subcollection: 'games',
            subdocumentId: gameName);
        if (itemDataMap.isNotEmpty) {
          setState(() {
            isEnabled = itemDataMap['info']['status'] == 'enabled';
            _switchVisible = true;

            for (int index = 0; index < itemDataMap['rates'].length; index++) {
              _cRate[index].text = itemDataMap['rates']['rate$index']['php'];
              _cRate[index + 6].text =
                  itemDataMap['rates']['rate$index']['digGoods'];
            }
          });
          forButton = 'UPDATE';
        } else {
          forButton = 'ADD';
        }
      }
    }

    setState(() {
      _isLoadingData = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    PaymentProvider paymentProvider =
        Provider.of<PaymentProvider>(context, listen: false);
    //input field list 12pcs
    List<Widget> rowsList = List.generate(
      (_cRate.length / 2).ceil(),
      (index) => Row(
        children: [
          const Padding(
            padding: EdgeInsets.only(right: 8.0),
            child: Text(
              '₱',
              style: TextStyle(fontSize: 25),
            ),
          ),
          Expanded(
            child: TextField(
              onChanged: (_) {
                setState(() {
                  _errorText[index] = null;
                });
              },
              keyboardType: TextInputType.number,
              controller: _cRate[index],
              enabled: _typeAheadController.text != '',
              decoration: InputDecoration(
                hintText: '(${(index + 1) * 100})',
                errorText: _errorText[index],
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(left: 10, right: 10),
            child: Text(
              ':',
              style: TextStyle(fontSize: 25),
            ),
          ),
          Expanded(
            child: TextField(
              onChanged: (_) {
                setState(() {
                  _errorText[index + 6] = null;
                });
              },
              keyboardType: TextInputType.number,
              controller: _cRate[index + 6],
              enabled: _typeAheadController.text != '',
              decoration: InputDecoration(
                hintText: '(${(index + 1) * 500})',
                errorText: _errorText[index + 6],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Image.asset(
              gameIconPath,
              width: 20,
              height: 20,
            ),
          ),
        ],
      ),
    );
    Widget rateFields = Padding(
      padding: const EdgeInsets.only(top: 30, bottom: 20),
      child: Column(
        children: [
          Stack(
            children: [
              TypeAheadFormField(
                textFieldConfiguration: TextFieldConfiguration(
                  controller: _typeAheadController,
                  decoration: const InputDecoration(
                    labelText: 'Select a game',
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: (value) {
                    if (value.isEmpty) {
                      // If the field is empty, do nothing
                      return;
                    }
                    final suggestions = itemsObjectList.where((option) => option
                        .name
                        .toLowerCase()
                        .contains(value.toLowerCase()));
                    if (suggestions.isNotEmpty) {
                      // If there are suggestions, select the first one
                      setState(() {
                        _typeAheadController.text = suggestions.first.name;
                        _isLoadingData = true;
                        checkGame(suggestions.first.name);
                        gameIconPath = gameIcon(_typeAheadController.text);
                      });
                    } else {
                      // If there are no suggestions, clear the text field
                      _typeAheadController.clear();
                    }
                    setState(() {
                      gameIconPath = gameIcon(_typeAheadController.text);
                    });
                  },
                ),
                suggestionsCallback: (pattern) {
                  return itemsObjectList.where((option) => option.name
                      .toLowerCase()
                      .contains(pattern.toLowerCase()));
                },
                itemBuilder: (context, suggestion) {
                  return ListTile(
                    title: Text(suggestion.name),
                  );
                },
                onSuggestionSelected: (suggestion) {
                  setState(() {
                    _typeAheadController.text = suggestion.name;
                    _isLoadingData = true;
                    checkGame(suggestion.name);
                    gameIconPath = gameIcon(_typeAheadController.text);
                  });
                },
              ),
              Visibility(
                visible: _typeAheadController.text != '',
                child: Positioned(
                    right: 0,
                    child: SizedBox(
                      height: 58,
                      child: IconButton(
                        onPressed: () => setState(() {
                          _switchVisible = false;
                          _typeAheadController.text = '';
                          for (var controller in _cRate) {
                            controller.text = '';
                          }
                        }),
                        icon: const Icon(Icons.close),
                        color: Colors.grey,
                      ),
                    )),
              )
            ],
          ),
          GestureDetector(
            onTap: () {
              if (_typeAheadController.text == '') {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Select a game first!')));
              }
            },
            child: Stack(
              children: [
                Visibility(
                  visible: true,
                  child: Column(
                    children: rowsList,
                  ),
                ),
                if (_isLoadingData) ...[
                  const Padding(
                    padding: EdgeInsets.only(top: 15),
                    child: Center(child: CircularProgressIndicator()),
                  )
                ]
              ],
            ),
          ),
          const SizedBox(
            height: 30,
          ),
          Stack(
            children: [
              Visibility(
                visible: _typeAheadController.text != '',
                child: ElevatedButton(
                  onPressed: () async {
                    final scaffoldMsgr = ScaffoldMessenger.of(context);
                    _cRateValidation();
                    //add item to provider and firestore
                    //SellItemsProvider
                    SellItemsProvider siProvider =
                        Provider.of<SellItemsProvider>(context, listen: false);
                    Item? item = getItemByName(_typeAheadController.text);
                    if (siProvider.itemExist(item!)) {
                      siProvider.updateItem(
                          item, itemDataMap['info']['status']);
                    } else {
                      siProvider.addItem(item, 'enabled');
                    }

                    //Firestore
                    if (_ratesFlag == true) {
                      setState(() {
                        _isLoading = true;
                      });
                      //rates
                      Map<String, dynamic> ratesMap = {};
                      int indexUsed = 0;
                      for (var i = 0; i < _cRate.length / 2; i++) {
                        if (_cRate[i].text.toString() != '') {
                          if (_cRate[i + 6].text.toString() != '') {
                            ratesMap['rate$indexUsed'] = {
                              'php': _cRate[i].text.toString(),
                              'digGoods': _cRate[i + 6].text.toString(),
                            };
                            indexUsed++;
                          }
                        }
                      }
                      UserProvider userProvider =
                          Provider.of<UserProvider>(context, listen: false);
                      //add the game to sellers collection with status as enabled
                      await FirestoreService().create(
                          collection: 'sellers',
                          documentId: userProvider.user!.uid,
                          data: {
                            'games': {
                              _typeAheadController.text:
                                  isEnabled! ? 'enabled' : 'disabled'
                            }
                          });
                      //add the seller to game document as a collection
                      //mop
                      Map<String, dynamic> mopMap = {};
                      for (int index = 0;
                          index < paymentProvider.payments.length;
                          index++) {
                        var item = paymentProvider.payments[index];
                        if (item.isEnabled) {
                          mopMap['mop$index'] = {
                            'name': item.paymentname,
                            'account_name': item.accountname,
                            'account_number': item.accountnumber,
                            'status': item.isEnabled ? 'enabled' : 'disbaled'
                          };
                        }
                      }
                      final Map<String, dynamic> mapData = {
                        'mop': mopMap,
                        'rates': ratesMap,
                        'info': {
                          'status': forButton == 'ADD'
                              ? 'enabled'
                              : isEnabled!
                                  ? 'enabled'
                                  : 'disabled',
                          'uid': userProvider.user!.uid,
                          'name': userProvider.user!.name,
                          'image': userProvider.user!.image_url
                        }
                      };
                      await FirestoreService().create(
                        collection: 'seller_games_data',
                        documentId: _typeAheadController.text,
                        data: {userProvider.user!.name: mapData},
                        merge: false,
                      );

                      await FirestoreService().create(
                        collection: 'sellers',
                        documentId: userProvider.user!.uid,
                        data: mapData,
                        subcollection: 'games',
                        subdocumentId: _typeAheadController.text,
                        merge: false,
                      );
                      scaffoldMsgr.showSnackBar(
                          const SnackBar(content: Text('Success')));
                      setState(() {
                        _isLoading = false;
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    maximumSize:
                        Size((MediaQuery.of(context).size.width / 2) - 75, 40),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                        side: const BorderSide(color: Colors.black)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                    child: Center(
                      child: Text(
                        forButton,
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
              onPressed: () {
                Navigator.pop(
                    context,
                    Provider.of<SellItemsProvider>(context, listen: false)
                        .Sitems);
              },
              icon: const Icon(
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
                  Visibility(
                    visible: _switchVisible,
                    child: FlutterSwitch(
                      height: 20.0,
                      width: 50.0,
                      padding: 4.0,
                      toggleSize: 15.0,
                      borderRadius: 10.0,
                      activeColor: Colors.green,
                      inactiveColor: Colors.red,
                      value: isEnabled ?? false,
                      onToggle: (value) {
                        setState(() {
                          isEnabled = !isEnabled!;
                        });

                        Provider.of<SellItemsProvider>(context, listen: false)
                            .updateItem(
                                getItemByName(_typeAheadController.text)!,
                                isEnabled! ? 'enabled' : 'disabled');
                        FirestoreService().create(
                            collection: 'seller_games_data',
                            documentId: _typeAheadController.text,
                            data: {
                              Provider.of<UserProvider>(context, listen: false)
                                  .user!
                                  .name: {
                                'info': {
                                  'status': isEnabled! ? 'enabled' : 'disabled'
                                }
                              }
                            });
                        //sellers fields
                        FirestoreService().create(
                            collection: 'sellers',
                            documentId: Provider.of<UserProvider>(context,
                                    listen: false)
                                .user!
                                .uid,
                            data: {
                              'games': {
                                _typeAheadController.text:
                                    isEnabled! ? 'enabled' : 'disabled'
                              }
                            });
                        //sellers subcollection
                        FirestoreService().create(
                            collection: 'sellers',
                            documentId: Provider.of<UserProvider>(context,
                                    listen: false)
                                .user!
                                .uid,
                            data: {
                              'info': {
                                'status': isEnabled! ? 'enabled' : 'disabled'
                              }
                            },
                            subcollection: 'games',
                            subdocumentId: _typeAheadController.text);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content:
                                Text(isEnabled! ? 'Enabled' : 'Disbaled')));
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        body: _isLoading
            ? const LoadingScreen()
            : Padding(
                padding: const EdgeInsets.only(left: 25, right: 25),
                child: ListView(
                  children: [
                    Center(
                      child: getImage(context),
                    ),
                    const Divider(),
                    rateFields,
                  ],
                ),
              ));
  }
}

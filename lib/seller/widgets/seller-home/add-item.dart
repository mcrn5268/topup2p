import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:topup2p/cloud/writeDB.dart';
import 'package:topup2p/cons-widgets/loadingscreen.dart';
import 'package:topup2p/seller/seller-items.dart';
import 'package:topup2p/seller/seller-main.dart';
import 'package:topup2p/seller/widgets/seller-home/seller-home-page.dart';
import 'package:topup2p/seller/widgets/seller-profile/seller-profile.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:topup2p/global/globals.dart';

class AddItemSell extends StatefulWidget {
  const AddItemSell({this.update, this.game, super.key});
  final bool? update;
  final String? game;
  @override
  State<AddItemSell> createState() => _AddItemSellState();
}

class _AddItemSellState extends State<AddItemSell> {
  List<TextEditingController> _cRate = List.generate(
    12,
    (index) => TextEditingController(),
  );
  List<String?> _errorText = List.generate(12, (index) => null);
  final TextEditingController _typeAheadController = TextEditingController();
  String gameIconPath = 'assets/icons/coin.png';
  bool _isLoading = false;
  int mapIndex = 0;
  bool? isEnabled;
  bool _isLoadingData = false;
  Future<Map<String, dynamic>>? rates;
  bool _updateButton = false;
  bool _ratesFlag = true;
  bool _switchVisible = false;
  String forButton = 'ADD';
  void gameIcon() {
    if (_typeAheadController.text == 'Mobile Legends') {
      gameIconPath = 'assets/icons/diamond.png';
    } else if (_typeAheadController.text == 'Valorant') {
      gameIconPath = 'assets/icons/valorant.png';
    } else {
      gameIconPath = 'assets/icons/coin.png';
    }
  }

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
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: const Text(
                'Rates must not be empty if you wish to add an item!')));
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
      _isLoadingData = true;
      forButton = 'UPDATE';
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        checkGame(widget.game!);
      });
    }
  }

  Future<void> checkGame(String gameName) async {
    print('check game');
    Map<String, dynamic>? result =
        await sellerGamesItems().loadItemsRates(gameName);
    print('result $result');
    if (result != null) {
      setState(() {
        isEnabled = result['status'] == 'enabled';
        _switchVisible = true;
        for (var index = 0; index < result!.length - 1; index++) {
          print('index $index');
          _cRate[index].text = result['rate$index']['php'];
          _cRate[index + 6].text = result['rate$index']['digGoods'];
        }
      });
      forButton = 'UPDATE';
    } else {
      forButton = 'ADD';
    }
    setState(() {
      _isLoadingData = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> rowsList = List.generate(
      (_cRate.length / 2).ceil(),
      (index) => Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: const Text(
              '₱',
              style: TextStyle(fontSize: 25),
            ),
          ),
          Expanded(
            child: TextField(
              onChanged: (_) {
                if (widget.update == true) {
                  setState(() {
                    _updateButton = true;
                  });
                } else {
                  setState(() {
                    _errorText[index] = null;
                  });
                }
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
          Padding(
            padding: const EdgeInsets.only(left: 10, right: 10),
            child: const Text(
              ':',
              style: TextStyle(fontSize: 25),
            ),
          ),
          Expanded(
            child: TextField(
              onChanged: (_) {
                if (widget.update == true) {
                  setState(() {
                    _updateButton = true;
                  });
                } else {
                  setState(() {
                    _errorText[index + 6] = null;
                  });
                }
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
                          _updateButton = true;
                        });
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
                      child: const SellerProfile().getImage(),
                    ),
                    const Divider(),
                    Padding(
                      padding: const EdgeInsets.only(top: 30, bottom: 20),
                      child: Column(
                        children: [
                          Stack(
                            children: [
                              TypeAheadFormField(
                                textFieldConfiguration: TextFieldConfiguration(
                                  controller: _typeAheadController,
                                  decoration: InputDecoration(
                                    labelText: 'Select a game',
                                    border: OutlineInputBorder(),
                                  ),
                                  onSubmitted: (value) {
                                    //_lostFocus = true;
                                    if (value.isEmpty) {
                                      // If the field is empty, do nothing
                                      return;
                                    }
                                    final suggestions = productItems.where(
                                        (option) => option
                                            .toLowerCase()
                                            .contains(value.toLowerCase()));
                                    if (suggestions.isNotEmpty) {
                                      // If there are suggestions, select the first one
                                      setState(() {
                                        _typeAheadController.text =
                                            suggestions.first;
                                        _isLoadingData = true;
                                        checkGame(suggestions.first);
                                        gameIcon();
                                      });
                                    } else {
                                      // If there are no suggestions, clear the text field
                                      _typeAheadController.clear();
                                    }
                                    setState(() {
                                      gameIcon();
                                    });
                                  },
                                ),
                                suggestionsCallback: (pattern) {
                                  return productItems.where((option) => option
                                      .toLowerCase()
                                      .contains(pattern.toLowerCase()));
                                },
                                itemBuilder: (context, suggestion) {
                                  return ListTile(
                                    title: Text(suggestion),
                                  );
                                },
                                onSuggestionSelected: (suggestion) {
                                  setState(() {
                                    _typeAheadController.text = suggestion;
                                    _isLoadingData = true;
                                    checkGame(suggestion);
                                    gameIcon();
                                  });
                                },
                              ),
                              Visibility(
                                visible: _typeAheadController.text != '',
                                child: Positioned(
                                    // alignment: Alignment.centerRight,
                                    right: 0,
                                    child: Container(
                                      height: 58,
                                      child: IconButton(
                                        onPressed: () => setState(() {
                                          _switchVisible = false;
                                          _typeAheadController.text = '';
                                          _cRate.forEach((controller) =>
                                              controller.text = '');
                                        }),
                                        icon: Icon(Icons.close),
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
                                    SnackBar(
                                        content: const Text(
                                            'Select a game first!')));
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
                                  Padding(
                                    padding: const EdgeInsets.only(top: 15),
                                    child: Center(
                                        child: CircularProgressIndicator()),
                                  )
                                ]
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 30,
                          ),
                          Stack(
                            children: [
                              Visibility(
                                visible: _typeAheadController.text != '',
                                child: ElevatedButton(
                                  onPressed: () async {
                                    _cRateValidation();
                                    if (_ratesFlag == true) {
                                      List<Map<String, dynamic>> ratesMap = [];
                                      for (var i = 0;
                                          i < _cRate.length / 2;
                                          i++) {
                                        if (_cRate[i].text.toString() != '') {
                                          if (_cRate[i + 6].text.toString() !=
                                              '') {
                                            ratesMap.add({
                                              'php':
                                                  '${_cRate[i].text.toString()}',
                                              'digGoods':
                                                  '${_cRate[i + 6].text.toString()}',
                                            });
                                          }
                                        }
                                      }
                                      setState(() {
                                        _isLoading = true;
                                      });
                                      if (forButton == 'ADD') {
                                        await sellerGamesData(
                                            _typeAheadController.text,
                                            ratesMap);
                                      } else if (forButton == 'UPDATE') {
                                        await sellerGamesData(
                                            _typeAheadController.text, ratesMap,
                                            update: true,
                                            status: isEnabled!
                                                ? 'enabled'
                                                : 'disabled');
                                      }
                                      Navigator.pushReplacement(
                                        context,
                                        PageRouteBuilder(
                                          pageBuilder: (_, __, ___) =>
                                              const SellerMain(),
                                          transitionsBuilder: (_, a, __, c) =>
                                              FadeTransition(
                                                  opacity: a, child: c),
                                        ),
                                      );
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
                                        side: const BorderSide(
                                            color: Colors.black)),
                                  ),
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(0, 10, 0, 10),
                                    child: Center(
                                      child: Text(
                                        forButton,
                                        style: TextStyle(fontSize: 20),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ));
  }
}

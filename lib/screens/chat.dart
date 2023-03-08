import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:provider/provider.dart';
import 'package:topup2p/cloud/firestore.dart';
import 'package:topup2p/models/item_model.dart';
import 'package:topup2p/models/user_model.dart';
import 'package:topup2p/providers/user_provider.dart';
import 'package:topup2p/utilities/image_file_utils.dart';
import 'package:chat_bubbles/chat_bubbles.dart';
import 'package:intl/intl.dart';
import 'package:topup2p/utilities/models_utils.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen(
      {required this.userId,
      required this.userName,
      required this.userImage,
      this.convId,
      this.gameFromShop,
      this.gameName,
      super.key});
  final String? convId;
  final String userId;
  final String userName;
  final String userImage;
  final Map<dynamic, dynamic>? gameFromShop;
  final String? gameName;
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final TextEditingController _typeAheadController = TextEditingController();
  late Future<String> forconvId;
  String? conversationId;
  bool _flag = false;
  bool _isLoadingData = false;
  Map<String, dynamic> shopInfo = {};
  List<dynamic> enabledGames = [];
  List<Map<String, dynamic>> payments = [];
  Item? selectedItem;

  @override
  void initState() {
    super.initState();
    if (Provider.of<UserProvider>(context, listen: false).user!.type ==
        'normal') {
      FirestoreService()
          .read(collection: 'sellers', documentId: widget.userId)
          .then((value) => {
                setState(() {
                  enabledGames = value['games']
                      .entries
                      .where((entry) => entry.value == 'enabled')
                      .map((entry) => entry.key)
                      .toList();
                })
              });
    } else {
      //todo
      //use sell_items_provider
    }
    if (widget.gameFromShop != null) {
      for (var key in widget.gameFromShop!.keys) {
        shopInfo[key.toString()] = widget.gameFromShop![key];
      }
      _typeAheadController.text = widget.gameName!;
      selectedItem = getItemByName(_typeAheadController.text);
    }
    FirestoreService()
        .read(collection: 'sellers', documentId: widget.userId)
        .then((value) => {
              setState(() {
                for (var key in value['MoP'].keys) {
                  var account = value['MoP'][key];
                  if (account['status'] == 'enabled') {
                    var enabledAccount = {'name': key};
                    enabledAccount.addAll(account);
                    payments.add(enabledAccount);
                  }
                }
              })
            });

    forconvId = FirestoreService().conversationId(widget.convId);
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {}
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _typeAheadController.dispose();
    super.dispose();
  }

  Future<dynamic> readGameData(String name) async {
    Map<String, dynamic> gameData = await FirestoreService()
        .read(collection: 'seller_games_data', documentId: name);
    return gameData[widget.userName];
  }

  @override
  Widget build(BuildContext context) {
    PlatformFile? pickedFile;
    ValueNotifier<bool> isVisiblegame = ValueNotifier<bool>(false);
    ValueNotifier<bool> isVisiblepayment = ValueNotifier<bool>(false);

    Widget gamesInfo = ValueListenableBuilder<bool>(
      valueListenable: isVisiblegame,
      builder: (BuildContext context, bool value, Widget? child) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: value ? 1.0 : 0.0,
            child: Container(
              height: isVisiblegame.value ? 145 : 0,
              width: isVisiblegame.value
                  ? MediaQuery.of(context).size.width - 50
                  : 0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.blueGrey,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Row(
                  children: [
                    Expanded(
                        flex: 3,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              height: 145,
                              decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(20.0),
                                    bottomLeft: Radius.circular(20.0),
                                  ),
                                  image: DecorationImage(
                                      fit: BoxFit.cover,
                                      image: _typeAheadController.text == ''
                                          ? const AssetImage(
                                              'assets/images/logo-old.png')
                                          : AssetImage(selectedItem!.image))),
                            )
                          ],
                        )),
                    Expanded(
                        flex: 4,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.only(top: 10, bottom: 10),
                              child: Container(
                                height: 35,
                                width:
                                    MediaQuery.of(context).size.width / 2 - 25,
                                decoration: BoxDecoration(
                                  color:
                                      Theme.of(context).scaffoldBackgroundColor,
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: TypeAheadFormField(
                                  textFieldConfiguration:
                                      TextFieldConfiguration(
                                    textAlign: TextAlign.center,
                                    controller: _typeAheadController,
                                    decoration: const InputDecoration(
                                      hintText: 'Select a game',
                                      labelStyle: TextStyle(
                                        color: Colors.black,
                                      ),
                                      border: InputBorder.none,
                                    ),
                                    onSubmitted: (value) async {
                                      if (value.isEmpty) {
                                        // If the field is empty, do nothing
                                        return;
                                      }
                                      final suggestions = enabledGames.where(
                                          (option) => option
                                              .toLowerCase()
                                              .contains(value.toLowerCase()));
                                      if (suggestions.isNotEmpty) {
                                        // If there are suggestions, select the first one
                                        setState(() {
                                          selectedItem =
                                              getItemByName(suggestions.first);
                                          _typeAheadController.text =
                                              suggestions.first;
                                          _isLoadingData = true;
                                        });
                                        shopInfo = await readGameData(
                                            suggestions.first);
                                        setState(() {
                                          _isLoadingData = false;
                                        });
                                      } else {
                                        // If there are no suggestions, clear the text field
                                        _typeAheadController.clear();
                                      }
                                    },
                                  ),
                                  suggestionsCallback: (pattern) {
                                    return enabledGames;
                                  },
                                  itemBuilder: (context, suggestion) {
                                    return ListTile(
                                      title: Text(suggestion),
                                    );
                                  },
                                  onSuggestionSelected: (suggestion) async {
                                    setState(() {
                                      selectedItem = getItemByName(suggestion);
                                      _typeAheadController.text = suggestion;
                                      _isLoadingData = true;
                                    });
                                    shopInfo = await readGameData(suggestion);
                                    setState(() {
                                      _isLoadingData = false;
                                    });
                                  },
                                ),
                              ),
                            ),
                            if (_typeAheadController.text != '') ...[
                              Expanded(
                                child: _isLoadingData
                                    ? const CircularProgressIndicator()
                                    : Row(
                                        children: [
                                          for (var i = 1;
                                              i <=
                                                  ((shopInfo['rates'].length) /
                                                          3)
                                                      .ceil();
                                              i++) ...[
                                            Expanded(
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  for (var j = (i == 1)
                                                          ? 0
                                                          : (i == 2)
                                                              ? 3
                                                              : 6;
                                                      j < i * 3 &&
                                                          j <
                                                              shopInfo['rates']
                                                                  .length;
                                                      j++) ...[
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Text(
                                                          "₱ ${shopInfo['rates']['rate$j']['php']} : ${shopInfo['rates']['rate$j']['digGoods']} ",
                                                          style: const TextStyle(
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                        Image.asset(
                                                          gameIcon(
                                                              _typeAheadController
                                                                  .text),
                                                          width: 10,
                                                          height: 10,
                                                        )
                                                      ],
                                                    )
                                                  ]
                                                ],
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        bottom: 10, top: 10),
                                    child: InkWell(
                                      child:
                                          const Icon(Icons.copy, color: Colors.white),
                                      onTap: () {
                                        String text = List.generate(
                                            shopInfo['rates'].length, (i) {
                                          var rate =
                                              shopInfo['rates']['rate$i'];
                                          return '₱ ${rate['php']} : ${rate['digGoods']} | ';
                                        }).join('\n');
                                        Clipboard.setData(
                                            ClipboardData(text: text));
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(const SnackBar(
                                          content: Text('Copiied'),
                                          duration: Duration(milliseconds: 500),
                                        ));
                                      },
                                    ),
                                  ),
                                ],
                              )
                            ]
                          ],
                        ))
                  ],
                ),
              ),
            ),
          );
        });
      },
    );

    Widget paymentsInfo = ValueListenableBuilder<bool>(
      valueListenable: isVisiblepayment,
      builder: (BuildContext context, bool value, Widget? child) {
        return AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: value ? 1.0 : 0.0,
          child: Container(
            height: isVisiblepayment.value ? 145 : 0,
            width: isVisiblepayment.value
                ? MediaQuery.of(context).size.width - 50
                : 0,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.blueGrey,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (payments.isNotEmpty) ...[
                  for (var index = 0; index < payments.length; index++) ...[
                    Expanded(
                        child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(10, 10, 10, 5),
                          child: Container(
                            height: 50,
                            width: 50,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                image: DecorationImage(
                                    fit: BoxFit.fitHeight,
                                    image: AssetImage(
                                        'assets/images/MoP/${payments[index]['name']}-large.png'))),
                          ),
                        ),
                        Text(
                          payments[index]['name'],
                          style: const TextStyle(color: Colors.white),
                        ),
                        const Divider(
                          color: Colors.white,
                          height: 1,
                          indent: 20,
                          endIndent: 20,
                        ),
                        Text('${payments[index]['account_name']}',
                            style: const TextStyle(color: Colors.white)),
                        Text('${payments[index]['account_number']}',
                            style: const TextStyle(color: Colors.white)),
                        Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: InkWell(
                            child: const Icon(Icons.copy, color: Colors.white),
                            onTap: () {
                              String text =
                                  '${payments[index]['name']} : Account Name: ${payments[index]['account_name']} | Account Number: ${payments[index]['account_number']}';
                              Clipboard.setData(ClipboardData(text: text));
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(const SnackBar(
                                content: Text('Copiied'),
                                duration: Duration(milliseconds: 500),
                              ));
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(const SnackBar(
                                content: Text('Copiied'),
                                duration: Duration(milliseconds: 500),
                              ));
                            },
                          ),
                        ),
                      ],
                    ))
                  ]
                ] else ...[
                  const Text('No Payments Information Available',
                      style: TextStyle(color: Colors.white))
                ]
              ],
            ),
          ),
        );
      },
    );

    Widget toggleButton = Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              isVisiblegame.value = !isVisiblegame.value;
              if (isVisiblepayment.value == true) {
                isVisiblepayment.value = !isVisiblepayment.value;
              }
            },
            icon: ValueListenableBuilder<bool>(
              valueListenable: isVisiblegame,
              builder: (BuildContext context, bool value, Widget? child) {
                return RotationTransition(
                  turns: AlwaysStoppedAnimation(value ? 0 : 0.5),
                  child: const Icon(
                    Icons.arrow_drop_up,
                    color: Colors.black,
                  ),
                );
              },
            ),
            label: const Text('Game'),
          ),
        ),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              isVisiblepayment.value = !isVisiblepayment.value;
              if (isVisiblegame.value == true) {
                isVisiblegame.value = !isVisiblegame.value;
              }
            },
            icon: ValueListenableBuilder<bool>(
              valueListenable: isVisiblepayment,
              builder: (BuildContext context, bool value, Widget? child) {
                return RotationTransition(
                  turns: AlwaysStoppedAnimation(value ? 0 : 0.5),
                  child: const Icon(
                    Icons.arrow_drop_up,
                    color: Colors.black,
                  ),
                );
              },
            ),
            label: const Text('Payment'),
          ),
        ),
      ],
    );

    Widget chatBody = Flexible(
        //getting the conversationID
        //if there is no existing, it will create a new one
        child: FutureBuilder<String>(
            future: forconvId,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else {
                conversationId = snapshot.data!;
                DateTime? prevDate;
                bool todayDisplayed = false;
                //return Container();
                return StreamBuilder<QuerySnapshot>(
                  stream: FirestoreService().getStream(
                      docId: 'conversations',
                      subcollectionName: conversationId!),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    } else {
                      if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                        //there are messages
                        SchedulerBinding.instance.addPostFrameCallback((_) {
                          //scroll to bottom
                          _scrollController.jumpTo(
                            _scrollController.position.maxScrollExtent,
                          );
                        });
                        return Stack(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 42.5),
                              child: ListView.builder(
                                controller: _scrollController,
                                itemCount: snapshot.data!.docs.length,
                                itemBuilder: (BuildContext context, int index) {
                                  final doc = snapshot.data!.docs[index];
                                  final msg = doc.get('msg');
                                  final sender = doc.get('sender');
                                  final timestamp =
                                      doc.get('timestamp') as Timestamp?;
                                  bool isSender = sender ==
                                          Provider.of<UserProvider>(context,
                                                  listen: false)
                                              .user!
                                              .uid
                                      ? true
                                      : false;
                                  bool showDate = false;
                                  bool today = false;

                                  if (timestamp != null) {
                                    final now = DateTime.now();
                                    final msgDate = timestamp.toDate();

                                    if (prevDate == null ||
                                        prevDate!.difference(msgDate).inDays !=
                                            0) {
                                      // Message is from a different day
                                      showDate = true;
                                      prevDate = msgDate;
                                      todayDisplayed =
                                          false; // reset today display flag
                                    }
                                    if (now.year == msgDate.year &&
                                        now.month == msgDate.month &&
                                        now.day == msgDate.day &&
                                        !todayDisplayed) {
                                      // Message is from today and "Today" has not been displayed yet
                                      showDate = true;
                                      today = true;
                                      todayDisplayed =
                                          true; // set today display flag
                                    }
                                    final formattedDate = today
                                        ? 'Today'
                                        : showDate
                                            ? now.year == msgDate.year
                                                ? DateFormat('MMM d')
                                                    .format(msgDate)
                                                : DateFormat('MMM d, y')
                                                    .format(msgDate)
                                            : '';

                                    final formattedTime =
                                        DateFormat('h:mm a').format(msgDate);

                                    return AnimationConfiguration.staggeredList(
                                      position: index,
                                      duration:
                                          const Duration(milliseconds: 375),
                                      child: SlideAnimation(
                                        verticalOffset: 50.0,
                                        child: FadeInAnimation(
                                          child: Column(
                                            children: [
                                              if (showDate) // Show the date if it's the first document or the previous document is over 24 hours ago
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 5),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Text(formattedDate),
                                                    ],
                                                  ),
                                                ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 5, bottom: 5),
                                                child: msg['type'] == 'text'
                                                    ?
                                                    //message type is text
                                                    BubbleNormal(
                                                        text: msg['content'],
                                                        isSender: isSender,
                                                        color: Colors.blueGrey,
                                                        textStyle: const TextStyle(
                                                          fontSize: 16,
                                                          color: Colors.white,
                                                        ),
                                                      )
                                                    :
                                                    //message type is image
                                                    BubbleNormalImage(
                                                        isSender: isSender,
                                                        image: Image.network(
                                                          msg['content'],
                                                          loadingBuilder: (context,
                                                              child,
                                                              loadingProgress) {
                                                            if (loadingProgress !=
                                                                null) {
                                                              _scrollController
                                                                  .animateTo(
                                                                _scrollController
                                                                    .position
                                                                    .maxScrollExtent,
                                                                duration: const Duration(
                                                                    milliseconds:
                                                                        200),
                                                                curve: Curves
                                                                    .easeOut,
                                                              );
                                                            }
                                                            return child;
                                                          },
                                                        ),
                                                        color: Colors.blueGrey,
                                                        tail: true,
                                                        id: 'image $index',
                                                      ),
                                              ),
                                              //add time message is sent
                                              if (formattedTime.isNotEmpty)
                                                Padding(
                                                  padding: isSender
                                                      ? const EdgeInsets.only(
                                                          top: 2, right: 20)
                                                      : const EdgeInsets.only(
                                                          top: 2, left: 20),
                                                  child: Align(
                                                    alignment: isSender
                                                        ? Alignment.centerRight
                                                        : Alignment.centerLeft,
                                                    child: Text(
                                                      formattedTime,
                                                      style: TextStyle(
                                                          fontSize: 12,
                                                          color:
                                                              Colors.grey[600]),
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  }
                                  return null;
                                },
                              ),
                            ),
                            Column(
                              children: [
                                toggleButton,
                                Stack(
                                  children: [gamesInfo, paymentsInfo],
                                )
                              ],
                            ),
                          ],
                        );
                      } else {
                        //no messages
                        return const Center(
                            child: CircleAvatar(
                                radius: 200,
                                backgroundImage: AssetImage(
                                    'assets/images/empty-chat.png')));
                      }
                    }
                  },
                );
              }
            }));
    Widget footer =
        //StatefulBuilder for the listview not to rebuild when using setstate here
        //this is for uploading image and showing a preview on top of textfield
        //user has a choice to either send the image or remove it
        StatefulBuilder(
      builder: (context, setState) => Column(
        children: [
          //image preview is inside Visibility()
          Visibility(
            visible: _flag,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Container(
                    height: 100,
                    decoration: BoxDecoration(
                        image: pickedFile != null
                            ? DecorationImage(
                                image: FileImage(File(pickedFile!.path!)))
                            : null),
                  ),
                ),
                IconButton(
                    onPressed: () {
                      setState(() {
                        _flag = false;
                        pickedFile = null;
                      });
                    },
                    icon: const Icon(
                      Icons.close,
                      color: Colors.grey,
                    ))
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                //select image - camera icon
                GestureDetector(
                    onTap: () async {
                      pickedFile = await selectImageFile();
                      setState(() {
                        _flag = true;
                      });
                    },
                    child: const Icon(Icons.camera_alt)),
                //text field
                Expanded(
                    child: Padding(
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  child: Container(
                      decoration: BoxDecoration(
                          color: Colors.blueGrey[50],
                          borderRadius: const BorderRadius.all(Radius.circular(20))),
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 15, right: 15, bottom: 5),
                        child: TextField(
                          controller: _controller,
                        ),
                      )),
                )),
                //send message - send icon
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () async {
                      UserModel userModel = Provider.of<UserProvider>(context, listen: false).user!;
                    if (pickedFile != null) {
                      String url =
                          await uploadImageFile(pickedFile!, conversationId!);
                      FirestoreService().sendMessage(
                          conversationId: conversationId!,
                          message: url,
                          otherUserId: widget.userId,
                          otherUserImage: widget.userImage,
                          otherUserName: widget.userName,
                          type: 'image',
                          userModel: userModel);

                      setState(() {
                        pickedFile = null;
                        _flag = false;
                      });
                    }
                    if (_controller.text.isNotEmpty) {
                      FirestoreService().sendMessage(
                          conversationId: conversationId!,
                          message: _controller.text,
                          otherUserId: widget.userId,
                          otherUserImage: widget.userImage,
                          otherUserName: widget.userName,
                          type: 'text',
                          userModel: userModel);
                    }

                    _controller.clear();
                    try {
                      _scrollController.animateTo(
                        _scrollController.position.maxScrollExtent,
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeOut,
                      );
                    } catch (e) {
                      if (kDebugMode) {
                        print('scroll error $e');
                      }
                    }
                  },
                )
              ],
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
              icon: const Icon(
                Icons.arrow_back_ios_outlined,
                color: Colors.black,
              )),
          centerTitle: true,
          title: Text(
            widget.userName,
            style: const TextStyle(
              color: Colors.black,
            ),
          ),
          shape: const Border(bottom: BorderSide(color: Colors.grey, width: 1)),
        ),
        body: Column(
          children: [chatBody, footer],
        ));
  }
}

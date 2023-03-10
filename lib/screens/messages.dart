// ignore_for_file: non_constant_identifier_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';
import 'package:topup2p/cloud/firestore.dart';
import 'package:topup2p/models/item_model.dart';
import 'package:topup2p/models/payment_model.dart';
import 'package:topup2p/providers/payment_provider.dart';
import 'package:topup2p/providers/sell_items_provder.dart';
import 'package:topup2p/providers/user_provider.dart';
import 'package:topup2p/screens/chat.dart';
import 'package:intl/intl.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({this.siItems, this.payments, super.key});
  final List<Map<Item, String>>? siItems;
  final List<Payment>? payments;
  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  late SellItemsProvider siProvider;
  late PaymentProvider paymentProvider;
  @override
  void initState() {
    super.initState();
    siProvider = Provider.of<SellItemsProvider>(context, listen: false);
    paymentProvider = Provider.of<PaymentProvider>(context, listen: false);
    if (widget.siItems != null) {
      siProvider.addItems(widget.siItems!);
    }
    if (widget.payments != null) {
      paymentProvider.clearPayments(notify: false);
      paymentProvider.addAllPayments(widget.payments!, notify: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    UserProvider userProvider =
        Provider.of<UserProvider>(context, listen: false);

    Widget messagesBody = StreamBuilder<QuerySnapshot>(
      stream: FirestoreService().getStream(
          docId: 'users',
          subcollectionName: userProvider.user!.uid,
          flag: false),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (BuildContext context, int index) {
              final doc = snapshot.data!.docs[index];
              final last_msg = doc.get('last_msg');
              final other_user = doc.get('other_user');
              //for placeholder display photo
              final bool = other_user['image'] ==
                          'assets/images/store-placeholder.png' ||
                      other_user['image'] ==
                          'assets/images/person-placeholder.png'
                  ? true
                  : false;

              ///data/user/0/com.example.topup2p/app_flutter/assets/images/JSSdS4pZgPPSGxi3xOvbcA4hu1w1/FB_IMG_1672753761418.jpg
//https://firebasestorage.googleapis.com/v0/b/topup2p.appspot.com/o/assets%2Fimages%2FJSSdS4pZgPPSGxi3xOvbcA4hu1w1%2FFB_IMG_1672753761418.jpg?alt=media&token=92bdaea9-9909-430b-8ba0-b90f3dfd47ba

              //for formatting for who sent the last message
              //if it's the current user, then add 'You: ' before the message
              final msg = last_msg['sender'] == userProvider.user!.uid
                  ? last_msg['msg']['type'] == 'text'
                      ? 'You: ${last_msg['msg']['content']}'
                      : 'You: 🖼️'
                  : last_msg['msg']['type'] == 'text'
                      ? '${last_msg['msg']['content']}'
                      : '🖼️';

              if (last_msg['timestamp'] != null) {
                final lastMsgTime =
                    (last_msg['timestamp'] as Timestamp).toDate();
                final now = DateTime.now();

                String displayTime;
                if (now.day == lastMsgTime.day &&
                    now.month == lastMsgTime.month &&
                    now.year == lastMsgTime.year) {
                  // Today
                  final format = DateFormat.jm();
                  displayTime = format.format(lastMsgTime);
                } else if (now.year == lastMsgTime.year) {
                  // This year
                  final format = DateFormat.MMMd();
                  displayTime = format.format(lastMsgTime);
                } else {
                  // Past year/s
                  final format = DateFormat.yMMMd();
                  displayTime = format.format(lastMsgTime);
                }
                return AnimationConfiguration.staggeredList(
                    position: index,
                    duration: const Duration(milliseconds: 375),
                    child: SlideAnimation(
                      verticalOffset: 50.0,
                      child: FadeInAnimation(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(10, 3, 10, 3),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              //to show a different container color if message isSeen = false
                              color: last_msg['isSeen'] == false
                                  ? Colors.blueGrey[50]
                                  : MediaQuery.of(context).platformBrightness ==
                                          Brightness.dark
                                      ? Colors.black
                                      : Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  spreadRadius: 0.5,
                                  blurRadius: 1,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                            child: InkWell(
                              child: Stack(
                                children: [
                                  ListTile(
                                    //check bool if image is placeholder or not
                                    //because of AssetImage and NetworkImage being different
                                    leading: bool
                                        ? CircleAvatar(
                                            backgroundImage:
                                                AssetImage(other_user['image']))
                                        : CircleAvatar(
                                            backgroundImage: NetworkImage(
                                                other_user['image'])),
                                    title: Text(other_user['name'],
                                        style: TextStyle(
                                            color: last_msg['isSeen'] == false
                                                ? Colors.black
                                                : Colors.grey)),
                                    //limit the number of characters being shown in listtiles of messages
                                    //excess characters are chanegd to ...
                                    subtitle: Text(
                                      msg.length > 30
                                          ? '${msg.substring(0, 30)}...'
                                          : msg,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: last_msg['isSeen'] == false
                                            ? Colors.black
                                            : Colors.grey,
                                      ),
                                    ),
                                    //different color depending on isSeen
                                    trailing: Text(displayTime,
                                        style: TextStyle(
                                            color: last_msg['isSeen'] == false
                                                ? Colors.black
                                                : Colors.grey)),
                                    onTap: () async {
                                      //when the message is tapped, pass the conversation ID
                                      String? convId;
                                      await FirestoreService()
                                          .read(
                                              collection: 'messages',
                                              documentId: 'users_conversations',
                                              subcollection:
                                                  userProvider.user!.uid,
                                              subdocumentId: other_user['uid'])
                                          .then((value) {
                                        if (value != null) {
                                          //if there are messages already
                                          convId = value['conversationId'];
                                          if (last_msg['isSeen'] == false) {
                                            //since user already tapped on the message tile
                                            //update isSeen from false to true
                                            FirestoreService().create(
                                                collection: 'messages',
                                                documentId: 'users',
                                                data: {
                                                  'last_msg': {'isSeen': true}
                                                },
                                                subcollection:
                                                    userProvider.user!.uid,
                                                subdocumentId: convId);
                                            FirestoreService().update(
                                                collection: 'messages',
                                                documentId:
                                                    'users_conversations',
                                                data: {
                                                  'conversationId': convId,
                                                  'isSeen': true
                                                },
                                                subcollection:
                                                    userProvider.user!.uid,
                                                subdocumentId:
                                                    other_user['uid']);
                                          }
                                        }
                                        if (widget.siItems != null ||
                                            widget.payments != null) {
                                          Navigator.push(
                                            context,
                                            PageRouteBuilder(
                                              pageBuilder: (_, __, ___) =>
                                                  MultiProvider(
                                                providers: [
                                                  ChangeNotifierProvider<
                                                      SellItemsProvider>.value(
                                                    value: SellItemsProvider(),
                                                  ),
                                                  ChangeNotifierProvider<
                                                      PaymentProvider>.value(
                                                    value: PaymentProvider(),
                                                  ),
                                                ],
                                                child: ChatScreen(
                                                    convId: convId,
                                                    userId: other_user['uid'],
                                                    userImage:
                                                        other_user['image'],
                                                    userName:
                                                        other_user['name'],
                                                    sItems: siProvider.Sitems,
                                                    payments: paymentProvider
                                                        .payments),
                                              ),
                                              transitionsBuilder:
                                                  (_, a, __, c) =>
                                                      FadeTransition(
                                                          opacity: a, child: c),
                                            ),
                                          );
                                        } else {
                                          Navigator.push(
                                            context,
                                            PageRouteBuilder(
                                              pageBuilder: (_, __, ___) =>
                                                  ChatScreen(
                                                convId: convId,
                                                userId: other_user['uid'],
                                                userImage: other_user['image'],
                                                userName: other_user['name'],
                                              ),
                                              transitionsBuilder:
                                                  (_, a, __, c) =>
                                                      FadeTransition(
                                                          opacity: a, child: c),
                                            ),
                                          );
                                        }
                                      });
                                    },
                                  ),
                                  //indicator that a message tile is isSeen = false
                                  //red circle Container()
                                  Visibility(
                                    visible: last_msg['isSeen'] == false,
                                    child: Align(
                                        alignment: Alignment.topRight,
                                        child: Container(
                                          width: 10,
                                          height: 10,
                                          decoration: const BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.red),
                                        )),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ));
              }
              return null;
            },
          );
        } else {
          //if messages is empty
          return const Center(
              child: CircleAvatar(
                  radius: 200,
                  backgroundImage: AssetImage('assets/images/empty-chat.png')));
        }
      },
    );
    return Scaffold(
        //if user type normal show back button
        //if seller don't show back button only title
        appBar: userProvider.user!.type == 'normal'
            ? AppBar(
                leading: IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(
                      Icons.arrow_back_ios_outlined,
                    )),
                centerTitle: true,
                title: const Text(
                  'Messages',
                ),
                shape: const Border(
                    bottom: BorderSide(color: Colors.grey, width: 1)),
              )
            : AppBar(
                centerTitle: true,
                title: const Text(
                  'Messages',
                ),
                shape: const Border(
                    bottom: BorderSide(color: Colors.grey, width: 1))),
        body: messagesBody);
  }
}

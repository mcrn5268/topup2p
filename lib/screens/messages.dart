import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';
import 'package:topup2p/cloud/firestore.dart';
import 'package:topup2p/providers/user_provider.dart';
import 'package:topup2p/screens/chat.dart';
import 'package:intl/intl.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});
  @override
  _MessagesScreenState createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  @override
  Widget build(BuildContext context) {
    UserProvider userProvider =
        Provider.of<UserProvider>(context, listen: false);
    return Scaffold(
        appBar: userProvider.user!.type == 'normal'
            ? AppBar(
                leading: IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(
                      Icons.arrow_back_ios_outlined,
                      color: Colors.black,
                    )),
                centerTitle: true,
                title: Text(
                  'Messages',
                  style: TextStyle(
                    color: Colors.black, // try a different color here
                  ),
                ),
                shape: Border(bottom: BorderSide(color: Colors.grey, width: 1)),
              )
            : AppBar(
                centerTitle: true,
                title: Text(
                  'Messages',
                  style: TextStyle(
                    color: Colors.black, // try a different color here
                  ),
                ),
                shape:
                    Border(bottom: BorderSide(color: Colors.grey, width: 1))),
        body: StreamBuilder<QuerySnapshot>(
          stream: FirestoreService().getStream(
              docId: 'users',
              subcollectionName: userProvider.user!.uid,
              flag: false),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            if (snapshot.hasData && snapshot.data!.docs.length > 0) {
              return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (BuildContext context, int index) {
                  final doc = snapshot.data!.docs[index];
                  final last_msg = doc.get('last_msg');
                  final other_user = doc.get('other_user');
                  final bool = other_user['image'] ==
                              'assets/images/store-placeholder.png' ||
                          other_user['image'] ==
                              'assets/images/person-placeholder.png'
                      ? true
                      : false;

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
                                  color: last_msg['isSeen'] == false
                                      ? Colors.blueGrey[50]
                                      : Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.5),
                                      spreadRadius: 2,
                                      blurRadius: 5,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: InkWell(
                                  child: Stack(
                                    children: [
                                      ListTile(
                                        leading: bool
                                            ? CircleAvatar(
                                                backgroundImage: AssetImage(
                                                    other_user['image']))
                                            : CircleAvatar(
                                                backgroundImage: NetworkImage(
                                                    other_user['image'])),
                                        title: Text(other_user['name'],
                                            style: TextStyle(
                                                color:
                                                    last_msg['isSeen'] == false
                                                        ? Colors.black
                                                        : Colors.grey)),
                                        subtitle: Text(
                                          msg.length > 30
                                              ? msg.substring(0, 30) + '...'
                                              : msg,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: last_msg['isSeen'] == false
                                                ? Colors.black
                                                : Colors.grey,
                                          ),
                                        ),
                                        trailing: Text(displayTime,
                                            style: TextStyle(
                                                color:
                                                    last_msg['isSeen'] == false
                                                        ? Colors.black
                                                        : Colors.grey)),
                                        onTap: () async {
                                          String? convId;
                                          final Map<String, dynamic>? snapshot =
                                              await FirestoreService().read(
                                                  collection: 'messages',
                                                  documentId:
                                                      'users_conversations',
                                                  subcollection:
                                                      userProvider.user!.uid,
                                                  subdocumentId:
                                                      other_user['uid']);
                                          if (snapshot != null) {
                                            print('snapshot not null');
                                            convId = snapshot['conversationId'];
                                            if (last_msg['isSeen'] == false) {
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
                                                  'messages',
                                                  'users_conversations',
                                                  {
                                                    'conversationId': convId,
                                                    'isSeen': true
                                                  },
                                                  subcollection:
                                                      userProvider.user!.uid,
                                                  subdocumentId:
                                                      other_user['uid']);
                                            }
                                          }

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
                                        },
                                      ),
                                      Visibility(
                                        visible: last_msg['isSeen'] == false,
                                        child: Align(
                                            alignment: Alignment.topRight,
                                            child: Container(
                                              width: 10,
                                              height: 10,
                                              decoration: BoxDecoration(
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
                },
              );
            } else {
              return Center(
                  child: CircleAvatar(
                      radius: 200,
                      backgroundImage:
                          AssetImage('assets/images/empty-chat.png')));
            }
          },
        ));
  }
}

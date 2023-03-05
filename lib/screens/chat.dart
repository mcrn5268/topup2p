import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';
import 'package:topup2p/cloud/firestore.dart';
import 'package:topup2p/providers/user_provider.dart';
import 'package:topup2p/utilities/image_file_utils.dart';
import 'package:chat_bubbles/chat_bubbles.dart';
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen(
      {required this.userId,
      required this.userName,
      required this.userImage,
      this.convId,
      super.key});
  final String? convId;
  final String userId;
  final String userName;
  final String userImage;
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  late Future<String> forconvId;
  String? conversationId;
  bool _flag = false;
  @override
  void initState() {
    super.initState();
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    PlatformFile? pickedFile;
    Widget chatBody = Flexible(
        //getting the conversationID
        //if there is no existing, it will create a new one
        child: FutureBuilder<String>(
            future: forconvId,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else {
                conversationId = snapshot.data!;
                DateTime? _prevDate;
                bool _todayDisplayed = false;
                //return Container();
                return StreamBuilder<QuerySnapshot>(
                  stream: FirestoreService().getStream(
                      docId: 'conversations',
                      subcollectionName: conversationId!),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    } else {
                      if (snapshot.hasData && snapshot.data!.docs.length > 0) {
                        //there are messages
                        SchedulerBinding.instance.addPostFrameCallback((_) {
                          //scroll to bottom
                          _scrollController.jumpTo(
                            _scrollController.position.maxScrollExtent,
                          );
                        });
                        return ListView.builder(
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

                              if (_prevDate == null ||
                                  _prevDate!.difference(msgDate).inDays != 0) {
                                // Message is from a different day
                                showDate = true;
                                _prevDate = msgDate;
                                _todayDisplayed =
                                    false; // reset today display flag
                              }
                              if (now.year == msgDate.year &&
                                  now.month == msgDate.month &&
                                  now.day == msgDate.day &&
                                  !_todayDisplayed) {
                                // Message is from today and "Today" has not been displayed yet
                                showDate = true;
                                today = true;
                                _todayDisplayed =
                                    true; // set today display flag
                              }
                              final formattedDate = today
                                  ? 'Today'
                                  : showDate
                                      ? now.year == msgDate.year
                                          ? DateFormat('MMM d').format(msgDate)
                                          : DateFormat('MMM d, y')
                                              .format(msgDate)
                                      : '';

                              final formattedTime =
                                  DateFormat('h:mm a').format(msgDate);

                              return AnimationConfiguration.staggeredList(
                                position: index,
                                duration: const Duration(milliseconds: 375),
                                child: SlideAnimation(
                                  verticalOffset: 50.0,
                                  child: FadeInAnimation(
                                    child: Column(
                                      children: [
                                        if (showDate) // Show the date if it's the first document or the previous document is over 24 hours ago
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 5),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
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
                                                  textStyle: TextStyle(
                                                    fontSize: 20,
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
                                                          duration: Duration(
                                                              milliseconds:
                                                                  200),
                                                          curve: Curves.easeOut,
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
                                                    color: Colors.grey[600]),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }
                          },
                        );
                      } else {
                        //no messages
                        return Center(
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
                    icon: Icon(
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
                    child: Icon(Icons.camera_alt)),
                //text field
                Expanded(
                    child: Padding(
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  child: Container(
                      decoration: BoxDecoration(
                          color: Colors.blueGrey[50],
                          borderRadius: BorderRadius.all(Radius.circular(20))),
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
                  icon: Icon(Icons.send),
                  onPressed: () async {
                    if (pickedFile != null) {
                      String url =
                          await uploadImageFile(pickedFile!, conversationId!);
                      FirestoreService().sendMessage(
                          conversationId: conversationId!,
                          message: url,
                          context: context,
                          otherUserId: widget.userId,
                          otherUserImage: widget.userImage,
                          otherUserName: widget.userName,
                          type: 'image');

                      setState(() {
                        pickedFile = null;
                        _flag = false;
                      });
                    }
                    if (_controller.text.length > 0) {
                      FirestoreService().sendMessage(
                          conversationId: conversationId!,
                          message: _controller.text,
                          context: context,
                          otherUserId: widget.userId,
                          otherUserImage: widget.userImage,
                          otherUserName: widget.userName,
                          type: 'text');
                    }

                    _controller.clear();
                    try {
                      _scrollController.animateTo(
                        _scrollController.position.maxScrollExtent,
                        duration: Duration(milliseconds: 200),
                        curve: Curves.easeOut,
                      );
                    } catch (e) {
                      print('scroll error $e');
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
              icon: Icon(
                Icons.arrow_back_ios_outlined,
                color: Colors.black,
              )),
          centerTitle: true,
          title: Text(
            widget.userName,
            style: TextStyle(
              color: Colors.black,
            ),
          ),
          shape: Border(bottom: BorderSide(color: Colors.grey, width: 1)),
        ),
        body: Column(
          children: [chatBody, footer],
        ));
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:topup2p/cloud/firestore.dart';
import 'package:topup2p/providers/user_provider.dart';
import 'package:topup2p/screens/chat.dart';
import 'package:topup2p/screens/messages.dart';

class MessageButton extends StatelessWidget {
  const MessageButton({this.fromProfile, super.key});
  final bool? fromProfile;
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirestoreService().getSeenStream(
            Provider.of<UserProvider>(context, listen: false).user!.uid),
        builder: (context, snapshot) {
          return ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) => MessagesScreen(),
                  transitionsBuilder: (_, a, __, c) =>
                      FadeTransition(opacity: a, child: c),
                ),
              );
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 25,
                  child: Stack(
                    children: [
                      Icon(
                        Icons.chat_bubble_outline_outlined,
                        color:
                            (fromProfile != null) ? Colors.white : Colors.black,
                      ),
                      Visibility(
                        visible: snapshot.hasData,
                        child: Align(
                            alignment: Alignment.topRight,
                            child: Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle, color: Colors.red),
                            )),
                      )
                    ],
                  ),
                ),
              ],
            ),
          );
        });
  }
}

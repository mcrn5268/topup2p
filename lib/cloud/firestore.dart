import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:topup2p/providers/user_provider.dart';
import 'package:topup2p/utilities/other_utils.dart';

class FirestoreService {
  FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> create(
      {required String collection,
      required String documentId,
      required Map<String, dynamic> data,
      String? subcollection,
      String? subdocumentId,
      bool merge = true}) async {
    if (subcollection == null && subdocumentId == null) {
      await _db
          .collection(collection)
          .doc(documentId)
          .set(data, SetOptions(merge: merge));
    } else {
      try {
        // subcollection subdocument
        //redundant data
        await FirebaseFirestore.instance
            .collection(collection)
            .doc(documentId)
            .collection(subcollection!)
            .doc(subdocumentId)
            .set(data, SetOptions(merge: merge));
      } catch (e) {
        print('Error creating document with subcollection: $e');
        rethrow;
      }
    }
  }

  Future<dynamic> read(
      {required String collection,
      required String documentId,
      String? subcollection,
      String? subdocumentId}) async {
    try {
      if (subcollection == null && subdocumentId == null) {
        DocumentSnapshot snapshot =
            await _db.collection(collection).doc(documentId).get();
        return snapshot.data() as Map<String, dynamic>;
      } else if (subcollection != null && subdocumentId != null) {
        DocumentSnapshot snapshot = await _db
            .collection(collection)
            .doc(documentId)
            .collection(subcollection)
            .doc(subdocumentId)
            .get();
        return snapshot.data() as Map<String, dynamic>;
      } else {
        QuerySnapshot querySnapshot = await _db
            .collection(collection)
            .doc(documentId)
            .collection(subcollection!)
            .get();
        return querySnapshot;
      }
    } catch (e) {
      print(
          'Something went wrong FirestoreService.read $collection $documentId $e');
      return null;
    }
  }

  Future<void> update(
     { required String collection, required String documentId, required Map<String, dynamic> data,
      String? subcollection, String? subdocumentId}) async {
    if (subcollection == null || subdocumentId == null) {
      await _db.collection(collection).doc(documentId).update(data);
    } else {
      await _db
          .collection(collection)
          .doc(documentId)
          .collection(subcollection)
          .doc(subdocumentId)
          .update(data);
    }
  }

  Future<void> delete({required String collection, required String documentId,
      String? subcollection, String? subdocumentId}) async {
    if (subcollection == null && subdocumentId == null) {
      await _db.collection(collection).doc(documentId).delete();
    } else {
      await _db
          .collection(collection)
          .doc(documentId)
          .collection(subcollection!)
          .doc(subdocumentId)
          .delete();
    }
  }

  Future<void> deleteField(
      {required String collection,
      required String documentId,
      required String field,
      String? subcollection,
      String? subdocumentId}) async {
    if (subcollection == null && subdocumentId == null) {
      await _db.collection(collection).doc(documentId).update({
        field: FieldValue.delete(),
      });
    } else {
      await _db
          .collection(collection)
          .doc(documentId)
          .collection(subcollection!)
          .doc(subdocumentId)
          .update({
        field: FieldValue.delete(),
      });
    }
  }

  Future<void> updateSubcollectionDocumentField({
    required String collectionName,
    required String subcollectionName,
    required String documentId,
    required String fieldName,
    dynamic fieldValue,}
  ) async {
    final collectionRef = _db.collection(collectionName);

    final documents = await collectionRef.get();
    for (final document in documents.docs) {
      try {
        final subcollectionRef =
            document.reference.collection(subcollectionName);
        final subcollectionSnapshot = await subcollectionRef.limit(1).get();

        if (subcollectionSnapshot.docs.isNotEmpty) {
          // Subcollection exists for this document
          final subcollectionDocRef = subcollectionRef.doc(documentId);
          await subcollectionDocRef.update({fieldName: fieldValue});
        }
      } catch (e) {
        print('Error: $e');
      }
    }
  }

  Stream<DocumentSnapshot?> getSeenStream({required String uid}) {
    return FirebaseFirestore.instance
        .collection('messages')
        .doc('users_conversations')
        .collection(uid)
        .where('isSeen', isEqualTo: false)
        .limit(1)
        .snapshots()
        .map((querySnapshot) {
      if (querySnapshot.docs.isEmpty) {
        return null;
      } else {
        return querySnapshot.docs[0];
      }
    });
  }

  Stream<QuerySnapshot> getStream(
      {required String docId,
      required String subcollectionName,
      bool flag = true}) {
    final CollectionReference mainCollectionRef = _db.collection('messages');
    final CollectionReference subCollectionRef =
        mainCollectionRef.doc(docId).collection(subcollectionName);

    // Add an orderBy clause to sort by the timestamp field in ascending order
    if (flag) {
      return subCollectionRef
          .orderBy('timestamp', descending: false)
          .snapshots();
    } else {
      //timestamp is inside a map field
      return subCollectionRef
          .orderBy(FieldPath(['last_msg', 'timestamp']), descending: true)
          .snapshots();
    }
  }

  Future<String> conversationId(String? id) async {
    print('id $id ddd');
    if (id == null) {
      late String returnId;
      bool flag = true;
      while (flag) {
        String generatedID = generateID();
        print('generatedID1 $generatedID ');
        final CollectionReference mainCollectionRef =
            _db.collection('messages');
        final snapshottt = await mainCollectionRef
            .doc('conversations')
            .collection(generatedID)
            .limit(1)
            .get();

        if (snapshottt.docs.isEmpty) {
          returnId = generatedID;
          flag = false;
        }
      }
      return returnId;
    } else {
      return id;
    }
  }

  Future<void> sendMessage(
      {required String conversationId,
      required BuildContext context,
      required String otherUserId,
      required String otherUserName,
      required String otherUserImage,
      required String type,
      required String message}) async {
    UserProvider userProvider =
        Provider.of<UserProvider>(context, listen: false);
    var timeStamp = FieldValue.serverTimestamp();
    Map<String, dynamic> forUsers = {
      'other_user': {
        'uid': userProvider.user!.uid,
        'name': userProvider.user!.name,
        'image': userProvider.user!.image_url
      },
      'last_msg': {
        'msg': {'type': type, 'content': message},
        'isSeen': false,
        'timestamp': timeStamp,
        'sender': userProvider.user!.uid
      }
    };
    Map<String, dynamic> forUsers2 = {
      'other_user': {
        'uid': otherUserId,
        'name': otherUserName,
        'image': otherUserImage
      },
      'last_msg': {
        'msg': {'type': type, 'content': message},
        'timestamp': timeStamp,
        'sender': userProvider.user!.uid
      }
    };
    Map<String, dynamic> forConv = {
      'timestamp': timeStamp,
      'msg': {'type': type, 'content': message},
      'sender': userProvider.user!.uid
    };
    create(
        collection: 'messages',
        documentId: 'users',
        data: forUsers,
        subcollection: otherUserId,
        subdocumentId: conversationId,
        merge: false);
    create(
        collection: 'messages',
        documentId: 'users',
        data: forUsers2,
        subcollection: userProvider.user!.uid,
        subdocumentId: conversationId,
        merge: false);
    create(
        collection: 'messages',
        documentId: 'conversations',
        data: forConv,
        subcollection: conversationId);
    //other user
    create(
        collection: 'messages',
        documentId: 'users_conversations',
        data: {'conversationId': conversationId, 'isSeen': false},
        subcollection: otherUserId,
        subdocumentId: userProvider.user!.uid,
        merge: false);
    //the user
    create(
        collection: 'messages',
        documentId: 'users_conversations',
        data: {'conversationId': conversationId, 'isSeen': true},
        subcollection: userProvider.user!.uid,
        subdocumentId: otherUserId,
        merge: false);
  }
}

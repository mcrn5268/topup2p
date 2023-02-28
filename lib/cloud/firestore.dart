import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirestoreService {
  FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> create(
      String collection, String documentId, Map<String, dynamic> data,
      {String? subcollection, String? subdocumentId, bool merge = true}) async {
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

  Future<dynamic> read(String collection, String documentId,
      {String? subcollection, String? subdocumentId}) async {
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
          'Something went wrong FirestoreService.read $collection $documentId');
      return null;
    }
  }

  Future<void> update(
      String collection, String documentId, Map<String, dynamic> data,
      {String? subcollection, String? subdocumentId}) async {
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

  Future<void> delete(String collection, String documentId,
      {String? subcollection, String? subdocumentId}) async {
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
      String collection, String documentId, String field) async {
    await _db.collection(collection).doc(documentId).update({
      field: FieldValue.delete(),
    });
  }

  Future<void> replaceDocumentnCollection(String old, String neww) async {
    final oldData = await read('sellers', old);
    delete('sellers', old);
    create('sellers', neww, oldData);
    renameSubcollection('seller_games_data', old, neww);
  }

  Future<void> renameSubcollection(
    String collectionName,
    String oldSubcollectionName,
    String newSubcollectionName,
  ) async {
    final collectionRef = _db.collection(collectionName);

    final documents = await collectionRef.get();
    for (final document in documents.docs) {
      try {
        final oldSubcollectionRef =
            document.reference.collection(oldSubcollectionName);
        final oldSubcollectionSnapshot =
            await oldSubcollectionRef.limit(1).get();

        if (oldSubcollectionSnapshot.docs.isNotEmpty) {
          // Copy documents to new subcollection
          final newSubcollectionRef =
              document.reference.collection(newSubcollectionName);
          final oldSubcollectionDocs = await oldSubcollectionRef.get();
          final batch = _db.batch();
          for (final oldDoc in oldSubcollectionDocs.docs) {
            batch.set(newSubcollectionRef.doc(oldDoc.id), oldDoc.data());
          }
          await batch.commit();

          // Delete old subcollection
          await oldSubcollectionRef.get().then((querySnapshot) {
            querySnapshot.docs.forEach((doc) async {
              await doc.reference.delete();
            });
          });

          // Create new subcollection
          await document.reference
              .collection(newSubcollectionName)
              .doc()
              .set({});
        }
      } catch (e) {
        print('Error: $e');
      }
    }
  }

  Future<void> updateSubcollectionDocumentField(
    String collectionName,
    String subcollectionName,
    String documentId,
    String fieldName,
    dynamic fieldValue,
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

  Future<String> getDownloadURL(String uid) async {
    Reference ref = FirebaseStorage.instance.ref().child('assets/images/$uid');
    ListResult result = await ref.listAll();
    if (result.items.isNotEmpty) {
      Reference fileRef = result.items.first;
      String downloadUrl = await fileRef.getDownloadURL();
      print('Download URL: $downloadUrl');
      return downloadUrl;
    } else {
      return 'assets/images/store-placeholder.png';
    }
  }
}

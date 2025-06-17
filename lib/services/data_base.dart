import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DatabaseMethods {

  final String uid = FirebaseAuth.instance.currentUser!.uid;

  /// Adds a new note with a given ID
  Future<void> addNotes(Map<String, dynamic> yourNotesInfoMap, String id) async {
    yourNotesInfoMap['uid'] = uid; // to Ensure UID is saved
    return await FirebaseFirestore.instance
        .collection("Heading")
        .doc(id)
        .set(yourNotesInfoMap);
  }

  /// Updates an existing note with a given ID
  Future<void> updateNotes(String id, Map<String, dynamic> updatedNote) async {
    return await FirebaseFirestore.instance
        .collection("Heading")
        .doc(id)
        .update(updatedNote);
  }

  /// Retrieves all notes as a stream
  Future<Stream<QuerySnapshot>> getYourNotes() async {
    return
      FirebaseFirestore.instance
          .collection("Heading")
          .where("uid", isEqualTo: uid)
          .orderBy("createdAt", descending: true)
          .orderBy("Pinned", descending: true)
          .snapshots();
  }

  /// Deletes a note by ID
  Future<void> deleteNotes(String id) async {
    return await FirebaseFirestore.instance
        .collection("Heading")
        .doc(id)
        .delete();
  }

  // Inside your database_methods.dart or wherever DatabaseMethods is defined
  Future<void> togglePin(String noteId, bool currentStatus) async {
    await FirebaseFirestore.instance
        .collection("Notes")
        .doc(noteId)
        .update({"Pinned": !currentStatus});
  }

}

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:my_notes_app/services/data_base.dart';
import 'package:random_string/random_string.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill ;

class NotesPage extends StatefulWidget {
  final bool isEditing;
  final String? noteId;
  final String? existingTitle;
  final String? existingType;
  final String? existingNotes;

  const NotesPage({
    super.key,
    this.isEditing = false,
    this.noteId,
    this.existingTitle,
    this.existingType,
    this.existingNotes,
  });

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  TextEditingController notesController = TextEditingController();
  TextEditingController noteHeadController = TextEditingController();
  TextEditingController noteTypeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.isEditing) {
      noteHeadController.text = widget.existingTitle ?? '';
      noteTypeController.text = widget.existingType ?? '';
      notesController.text = widget.existingNotes ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[900],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          widget.isEditing ? "Edit Note" : "New Note",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              const SizedBox(height: 12),
              TextField(
                controller: noteHeadController,
                decoration: const InputDecoration(
                  labelText: 'Write your Title',
                  border: OutlineInputBorder(),
                ),
                maxLines: 1,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: noteTypeController,
                decoration: const InputDecoration(
                  labelText: 'Type of your Note',
                  border: OutlineInputBorder(),
                ),
                maxLines: 1,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: notesController,
                decoration: const InputDecoration(
                  labelText: 'Write your note...',
                  border: OutlineInputBorder(),
                ),
                maxLines: null,
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          String id = widget.isEditing ? widget.noteId! : randomAlphaNumeric(10);
          String uid = FirebaseAuth.instance.currentUser!.uid;

          Map<String, dynamic> yourNotesInfoMap = {
            "Notes": notesController.text,
            "Title": noteHeadController.text,
            "Type": noteTypeController.text,
            "Id": id,
            "uid": uid,
            "createdAt": FieldValue.serverTimestamp(),
            "Pinned": widget.isEditing ? null : false, // preserve pin state on edit
          };

          if (widget.isEditing) {
            // Do not override `Pinned` if editing (leave it unchanged)
            yourNotesInfoMap.remove("Pinned");

            await DatabaseMethods().updateNotes(id, yourNotesInfoMap);
            Fluttertoast.showToast(
              msg: "Updated your Notes",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              backgroundColor: Colors.blue,
              textColor: Colors.white,
              fontSize: 16.0,
            );
          } else {
            await DatabaseMethods().addNotes(yourNotesInfoMap, id);
            Fluttertoast.showToast(
              msg: "Saved your Notes",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              backgroundColor: Colors.blue,
              textColor: Colors.white,
              fontSize: 16.0,
            );
          }

          Navigator.pop(context);
        },
        backgroundColor: Colors.blue[900],
        foregroundColor: Colors.amber[300],
        elevation: 2.0,
        child: const Icon(Icons.save),
      ),
    );
  }
}


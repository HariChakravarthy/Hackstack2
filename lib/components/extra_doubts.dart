/*class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final TextEditingController _controller = TextEditingController();
  Stream<QuerySnapshot>? notesStream;
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    getOnTheLoad();
  }

  getOnTheLoad() async {
    notesStream = await DatabaseMethods().getYourNotes();
    /*notesStream!.listen((snapshot) {
      allNotes = snapshot.docs;
      filteredNotes = allNotes;
      setState(() {});
    });*/
    setState(() {});
  }

  Widget allYourNotes() {
    return StreamBuilder<QuerySnapshot>(
      stream: notesStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }else if (snapshot.hasError) {
          return const Center(child: Text("Something went wrong"));
        } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No notes found"));
        }

        // Filter notes based on search query
        var notes = snapshot.data!.docs;
        var filteredNotes = notes.where((doc) {
          String title = (doc["Title"] ?? '').toLowerCase();
          String type = (doc["Type"] ?? '').toLowerCase();
          String note = (doc["Notes"] ?? '').toLowerCase();
          return title.contains(searchQuery) ||
              type.contains(searchQuery) ||
              note.contains(searchQuery);
        }).toList();

        return ListView.builder(
          // itemCount: snapshot.data!.docs.length,
          itemCount: filteredNotes.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            DocumentSnapshot ds = snapshot.data!.docs[index];

            DateTime? createdAt;
            try {
              Timestamp timestamp = ds["createdAt"];
              createdAt = timestamp.toDate();
            } catch (e) {
              createdAt = null;
            }

            String formattedDate = createdAt != null
                ? DateFormat('MMM d, yyyy • hh:mm a').format(createdAt)
                : 'Unknown Date';

            return Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ds["Type"] ?? ' ',
                    style: const TextStyle(
                      fontSize: 12,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      ds["Pinned"] == true ? Icons.push_pin : Icons.push_pin_outlined,
                      color: ds["Pinned"] == true ? Colors.orange : Colors.black45,
                    ),
                    onPressed: () async {
                      await DatabaseMethods().togglePin(ds["Id"], !(ds["Pinned"] ?? false));
                    },
                  ),
                  const SizedBox(height: 6),
                  Text(
                    ds["Title"] ?? '',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      /*GestureDetector(
                        onTap: () {
                          // editYourNotes(ds["id"]);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => NotesPage(
                                isEditing: true,
                                noteId: ds["Id"],
                                existingText: ds['Notes'],
                              ),
                            ),
                          );
                        },
                        child: Icon(
                            Icons.edit,
                          color: Colors.black,
                          size: 20,
                        ),
                      ),*/
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => NotesPage(
                                isEditing: true,
                                noteId: ds["Id"],
                                existingText: ds['Notes'],
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 8),
                      /*GestureDetector(
                        onTap: ()  async {
                          // deleteYourNotes(ds["id"]);
                          await DatabaseMethods().deleteNotes(ds["Id"]);
                        },
                        child: Icon(
                          Icons.delete,
                          color: Colors.black,
                          size: 20,
                        ),
                      )
                    ],
                  ),*/
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () async {
                          await DatabaseMethods().deleteNotes(ds["Id"]);
                        },
                      ),
                  const SizedBox(height: 6),
                  Text(
                    formattedDate,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 6),
                ],
              ),
              ],
            ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amber[50],
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Material(
                elevation: 2,
                shadowColor: Colors.white60,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Theme.of(context).cardColor,
                  ),
                  child: TextField(
                    controller: _controller,
                    /*onChanged: (value) {
                      setState(() {
                        searchQuery = value.toLowerCase();
                      });
                    },*/
                    decoration: InputDecoration(
                      labelText: 'Wanna find something?',
                      labelStyle: TextStyle(color: Colors.grey[700]),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: () {
                          setState(() {
                            searchQuery = _controller.text.toLowerCase();
                          });
                        },
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(color: Colors.blue, width: 2),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              allYourNotes(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const NotesPage()),
          );
        },
        backgroundColor: Colors.blue[900],
        foregroundColor: Colors.amber[300],
        elevation: 2.0,
        child: const Icon(Icons.add),
      ),
    );
  }
}*/


/*Future deleteYourNotes(String id) async {
    await FirebaseFirestore.instance.collection("Heading").doc(id).delete();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Note deleted successfully")),
    );
  }*/

/*Future editYourNotes(String id) => showDialog(context: context, builder: (context ) => AlertDialog(
    content: Container(
      child: Column(
        children: [
          GestureDetector(
              onTap: () {
                Navigator.pop((context));
              },
              child: Icon(
                Icons.cancel,
              )
          ),
        ],
      ),
    ),
  ));
  Future deleteYourNotes(String id) => showDialog(context: context, builder: (context ) => AlertDialog(
    content: Container(
      child: Column(
        children: [
          GestureDetector(
              onTap: () {
                Navigator.pop((context));
              },
              child: Icon(
                Icons.cancel,
              )
          ),
        ],
      ),
    ),
  ));*/

/*import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:my_notes_app/services/data_base.dart';
import 'package:random_string/random_string.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


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
          String id = widget.isEditing ? widget.noteId! : randomAlphaNumeric(
              10);
          String uid = FirebaseAuth.instance.currentUser!.uid;

          Map<String, dynamic> yourNotesInfoMap = {
            "Notes": notesController.text,
            "Title": noteHeadController.text,
            "Type": noteTypeController.text,
            "Id": id,
            "uid": uid, // for user specific data
            // "uid": FirebaseAuth.instance.currentUser!.uid
            "createdAt": FieldValue.serverTimestamp(),
            "Pinned": widget.isEditing ? null : false,
          };

          if (widget.isEditing) {
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
}*/

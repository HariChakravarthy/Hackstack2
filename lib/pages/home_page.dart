import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_notes_app/pages/new_notes_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_notes_app/services/data_base.dart';
import 'package:intl/intl.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
// import 'package:firebase_offline_cache/firebase_offline_cache.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  int myIndex = 0;

  final List<Widget> screens = [

    const HomeScreen(),
    const NotesScreen(),
    const TaskScreen(),
    const CalendarScreen(),
    const DocumentsScreen(),

  ];
  final List<Widget> menus = [
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE8E8DC),
      appBar: AppBar(
        backgroundColor: Colors.blue[900],
        leading: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProfileScreen()),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Icon(
                Icons.account_circle_outlined,
                color: Colors.white,
                size: 40,
            ),
            /*CircleAvatar(
              backgroundImage: AssetImage(
                  'lib/images/name.jpg',
              ),
            ),*/
          ),
        ),
        title: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Hey, What's up !",
              style: TextStyle(
                color: Color(0xFFE8E8DC),
                fontSize: 12,
              ),
            ),
            Row(
              children: [
                Text(
                  "One",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  ".",
                  style: TextStyle(
                    color: Colors.amber[300],
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  "Notes",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20 ,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.settings,
              color: Colors.white,
              size: 25,
            ),
            onPressed: () {} ,
          ),
          IconButton(
            icon: const Icon(
              Icons.notifications,
              color: Colors.white,
              size: 25,
            ),
            onPressed: () {} ,
          ),
        ],
    ),
      body: SafeArea(child: screens[myIndex]),
      bottomNavigationBar: BottomNavigationBar(
        showUnselectedLabels: false,
        backgroundColor: Colors.blue[900],
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white60,
        type: BottomNavigationBarType.fixed,
        currentIndex: myIndex,
        onTap: (index) {
          setState(() {
            myIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.speaker_notes_rounded),
            label: 'Notes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.task),
            label: 'To-dos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_outlined),
            label: 'Calendar',
          ),
        ],
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amber[50],
      body: SafeArea(
          child : SingleChildScrollView(
            padding: const EdgeInsets.all(12.0),
            child: const Center(
              child: Text(
                "Home Screen",
                style: TextStyle(fontSize: 20),
              ),
            ),
          ),
        ),
    );
  }
}



class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final TextEditingController _controller = TextEditingController();
  List<DocumentSnapshot> allNotes = [];
  List<DocumentSnapshot> filteredNotes = [];

  Stream<QuerySnapshot>? notesStream;

  @override
  void initState() {
    super.initState();
    // FirebaseOfflineCache.initialize();
    getOnTheLoad();
  }

  getOnTheLoad() async {
    notesStream = await DatabaseMethods().getYourNotes();
    notesStream!.listen((snapshot) {
      allNotes = snapshot.docs;
      filteredNotes = allNotes;
      setState(() {});
    });
  }

  Widget allYourNotes() {
    return filteredNotes.isEmpty
        ? const Center(child: Text("No notes found"))
        : ListView.builder(
      itemCount: filteredNotes.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        DocumentSnapshot ds = filteredNotes[index];

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

        return GestureDetector(
          child: Container(
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    ds["Type"] ?? '',
                    style: const TextStyle(fontSize: 12),
                  ),
                  IconButton(
                    icon: Icon(
                      (ds.data().toString().contains("Pinned") && ds["Pinned"] == true)
                          ? Icons.push_pin
                          : Icons.push_pin_outlined,
                      color: (ds.data().toString().contains("Pinned") && ds["Pinned"] == true)
                          ? Colors.orange
                          : Colors.black45,
                    ),
                    onPressed: () async {
                      bool currentPinned = ds.data().toString().contains("Pinned") && ds["Pinned"] == true;
                      await DatabaseMethods().togglePin(ds["Id"], !currentPinned);
                      setState(() {});
                    },
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                ds["Title"] ?? '',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              // const SizedBox(height: 6),
              // MarkdownBody(data: ds["Notes"] ?? ''),
              // const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NotesPage(
                            isEditing: true,
                            noteId: ds["Id"],
                            existingTitle: ds["Title"],
                            existingType: ds["Type"],
                            existingNotes: ds["Notes"],
                          ),
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () async {
                      await DatabaseMethods().deleteNotes(ds["Id"]);
                    },
                  ),
                ],
              ),
              Text(
                formattedDate,
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => NotesPage(
                  isEditing: true,
                  noteId: ds["Id"],
                  existingTitle: ds["Title"],
                  existingType: ds["Type"],
                  existingNotes: ds["Notes"],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void searchNotes(String query) {
    setState(() {
      filteredNotes = allNotes.where((doc) {
        String title = (doc["Title"] ?? '').toLowerCase();
        String type = (doc["Type"] ?? '').toLowerCase();
        String note = (doc["Notes"] ?? '').toLowerCase();
        return title.contains(query.toLowerCase()) ||
            type.contains(query.toLowerCase()) ||
            note.contains(query.toLowerCase());
      }).toList();
    });
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
                    onChanged: searchNotes,
                    decoration: InputDecoration(
                      labelText: 'Wanna find something?',
                      labelStyle: TextStyle(color: Colors.grey[700]),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: () {
                          searchNotes(_controller.text);
                        },
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
}


class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amber[50],
      body: SafeArea(
        child : SingleChildScrollView(
          padding: const EdgeInsets.all(12.0),
          child: const Center(
            child: Text(
              "Profile Screen",
              style: TextStyle(fontSize: 20),
            ),
          ),
        ),
      ),
    );
  }
}

class TaskScreen extends StatefulWidget {
  const TaskScreen({super.key});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amber[50],
      body: SafeArea(
        child : SingleChildScrollView(
          padding: const EdgeInsets.all(12.0),
          child: const Center(
            child: Text(
              "Tasks ",
              style: TextStyle(fontSize: 20),
            ),
          ),
        ),
      ),
    );
  }
}

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amber[50],
      body: SafeArea(
        child : SingleChildScrollView(
          padding: const EdgeInsets.all(12.0),
          child: const Center(
            child: Text(
              "Calendar",
              style: TextStyle(fontSize: 20),
            ),
          ),
        ),
      ),
    );
  }
}


class DocumentsScreen extends StatefulWidget {
  const DocumentsScreen({super.key});

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child : SingleChildScrollView(
          padding: const EdgeInsets.all(12.0),
          child: const Center(
            child: Text(
              "Documents",
              style: TextStyle(fontSize: 20),
            ),
          ),
        ),
      ),
    );
  }
}

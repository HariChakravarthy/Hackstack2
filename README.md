# my_notes_app

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

![Image](https://github.com/user-attachments/assets/f2833cf4-b48a-43f1-9c32-5dcd0a98e415)
![Image](https://github.com/user-attachments/assets/3d107bfb-e927-47e6-83c8-4e4061aff6d2)
![Image](https://github.com/user-attachments/assets/3518d2fa-ef92-422a-ba22-683907154d21)
![Image](https://github.com/user-attachments/assets/371da4a2-e8a4-42f1-876b-029bef221beb)
![Image](https://github.com/user-attachments/assets/e1086c13-5834-43dd-9848-4703ac04c886)

https://github.com/user-attachments/assets/5c3572ea-e13c-4a08-ba1c-d25f5f7d61f3

https://github.com/user-attachments/assets/832d9cc7-ac27-494f-bcc5-d1ba2a5fd9f2

I have built a flutter notes app with the following features 

- **Login/Signup UI** using Firebase Auth.
- A **home screen** showing all of the user’s notes.
- Ability to **add**, **edit**, and **delete** notes.
- USED and Enabled the CRUD Operations well 
- Real-time updates reflected instantly when a note is changed.
  
- User-specific data isolation: users should see **only their own notes**. I have tackled this feature with a uique id of user .


- Firebase Authentication (email/password or Google Sign-In)
- Firestore-based CRUD operations
- Timestamps for each note (created/last modified)
- USED the Indexes options in Firebase to display timestamps 
- Note ordering (e.g., most recent on top)
- Responsive UI (works on multiple screen sizes)
- Smooth UX with error handling and loading states

- build\app\outputs\flutter-apk\app-release.apk

  Issues & Resolutions Report
 Flutter Firebase Notes App
Technologies Used: Flutter, Firebase (Firestore, Auth).
1. Firestore Index Not Created
Issue:
While using .orderBy('createdAt', descending: true) in your query, Firestore threw an error like:

"FAILED_PRECONDITION: The query requires an index."

Root Cause:
Firestore requires compound indexes when performing filtered and ordered queries.

Resolution:
The Firestore error provided a direct link to create the required index.

Clicked the link → Confirmed the index creation.

After 1–2 minutes, the app started working fine.

2. Search Bar Not Filtering Data
Issue:
Search bar UI was present, but it didn’t actually filter the notes.

Root Cause:
The app was using StreamBuilder to directly show notesStream, but no search logic was applied on the stream data.

Resolution:
Implemented a TextEditingController to track search input.

Used snapshot.data!.docs.where(...) to filter notes manually on fields like Title, Type, and Notes.

Updated the ListView.builder to reflect filtered data.

4. Notes Not Visible to Specific Users (Security Issue)
Issue:
All notes were visible to all users.

Root Cause:
Firestore queries didn’t filter by uid, and rules weren’t set properly.

Resolution:
While adding notes, uid was stored using:

dart
Copy
Edit
yourNotesInfoMap['uid'] = FirebaseAuth.instance.currentUser!.uid;
Modified Firestore read query to:

dart
Copy
Edit
.where("uid", isEqualTo: FirebaseAuth.instance.currentUser!.uid)
Updated Firestore Rules:

js
Copy
Edit
match /Notes/{noteId} {
  allow read, write: if request.auth != null && request.auth.uid == resource.data.uid;
}
5. Edit Function Only Allowed Notes Field to be Updated
Issue:
During edit, only the note body (Notes) was updated — not Title or Type.
Cause:
existingTitle and existingType were not passed to the editing screen.
Resolution:
Passed existingTitle and existingType through Navigator:
dart
Copy
Edit
NotesPage(
  isEditing: true,
  noteId: ds["Id"],
  existingText: ds["Notes"],
  existingTitle: ds["Title"],
  existingType: ds["Type"],
)
dart
Copy
Edit
if (widget.isEditing && widget.existingTitle != null) {
  titleController.text = widget.existingTitle!;
  typeController.text = widget.existingType!;
  notesController.text = widget.existingText!;
}
6. Initial Notes Missing Required Fields
Issue:
Old notes were missing Pinned, uid, or createdAt.
Cause:
Those fields were introduced later during development.

Resolution:
Deleted old notes from Firebase Console.

Ensured new notes include all essential fields:

Id

Title

Type

Notes

Pinned

uid

createdAt


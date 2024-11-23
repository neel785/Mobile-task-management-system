import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: NotesScreen(),
    );
  }
}

class NoteItem {
  final String id;
  String title;
  String content;

  NoteItem({
    required this.id,
    required this.title,
    required this.content,
  });

  void updateContent(String newContent) {
    content = newContent;
  }
}

class NoteItemWidget extends StatelessWidget {
  final NoteItem note;
  final TextEditingController controller;

  NoteItemWidget({required this.note})
      : controller = TextEditingController(text: note.content);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              note.title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            TextField(
              controller: controller,
              onChanged: (newContent) {
                note.updateContent(newContent);
              },
              decoration: InputDecoration(
                labelText: 'Note Content',
                border: OutlineInputBorder(),
              ),
              maxLines: null,
              keyboardType: TextInputType.multiline,
            ),
          ],
        ),
      ),
    );
  }
}

class NotesScreen extends StatelessWidget {
  final List<NoteItem> notes = [
    NoteItem(
      id: '1',
      title: 'Note 1',
      content: 'This is the content for Note 1. It can include important details, ideas, or anything you want to remember.',
    ),
    NoteItem(
      id: '2',
      title: 'Note 2',
      content: 'Here is the content for Note 2. You can use these notes to jot down thoughts, tasks, or anything else on your mind.',
    ),
    NoteItem(
      id: '3',
      title: 'Note 3',
      content: 'The content for Note 3 goes here. Feel free to edit or add more notes as needed in your application.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notes'),
      ),
      body: ListView.builder(
        itemCount: notes.length,
        itemBuilder: (context, index) {
          return NoteItemWidget(note: notes[index]);
        },
      ),
    );
  }
}

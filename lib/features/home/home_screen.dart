import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Home Screen")),
      // ఎడమ వైపు మెనూ
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(child: Text("Side Menu", style: TextStyle(fontSize: 20))),
            ListTile(leading: const Icon(Icons.login), title: const Text("Login"), onTap: () {}),
            ListTile(leading: const Icon(Icons.contact_mail), title: const Text("Contact"), onTap: () {}),
            ListTile(leading: const Icon(Icons.book), title: const Text("Books"), onTap: () {}),
            ListTile(leading: const Icon(Icons.question_answer), title: const Text("Q&A"), onTap: () {}),
          ],
        ),
      ),
      body: Column(
        children: [
          const Expanded(child: Center(child: Text("Welcome to Church App"))),
          // కింద ఉండే Navigation Buttons
          Container(
            padding: const EdgeInsets.all(10),
            color: Colors.grey[200],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _navButton(context, Icons.menu_book, "Bible"),
                _navButton(context, Icons.music_note, "Music"),
                _navButton(context, Icons.library_books, "books"),
                _navButton(context, Icons.assignment, "Project H"),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _navButton(BuildContext context, IconData icon, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(icon: Icon(icon), onPressed: () {}),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
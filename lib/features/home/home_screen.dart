import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Church App")),
      drawer: Drawer(
        child: Column(
          children: [
            const UserAccountsDrawerHeader(
              accountName: Text("Telugu Bible"),
              accountEmail: Text("Version 1.0"),
              currentAccountPicture: CircleAvatar(child: Icon(Icons.person)),
            ),
            ListTile(leading: const Icon(Icons.login), title: const Text("Login"), onTap: () {}),
            ListTile(leading: const Icon(Icons.contact_mail), title: const Text("Contact"), onTap: () {}),
            ListTile(leading: const Icon(Icons.book), title: const Text("Books"), onTap: () {}),
            ListTile(leading: const Icon(Icons.help), title: const Text("Q&A"), onTap: () {}),
          ],
        ),
      ),
      body: const Center(child: Text("Welcome to the Home Screen")),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _bottomBtn(context, Icons.menu_book, "Bible", "/bible"),
            _bottomBtn(context, Icons.music_note, "Music", ""),
            _bottomBtn(context, Icons.library_books, "Books", ""),
            _bottomBtn(context, Icons.star, "Project H", ""),
          ],
        ),
      ),
    );
  }

  Widget _bottomBtn(BuildContext context, IconData icon, String label, String route) {
    return InkWell(
      onTap: () => route.isNotEmpty ? context.push(route) : null,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.brown),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
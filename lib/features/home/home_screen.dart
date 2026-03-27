import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117), // Deep Space Dark
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF00E5FF)), // Neon Cyan Menu Icon
        title: const Text("LUMINOUS WORD", style: TextStyle(letterSpacing: 3, fontWeight: FontWeight.w800, color: Color(0xFF00E5FF))),
        centerTitle: true,
      ),
      // ఎడమ వైపు సైడ్ మెనూ (Drawer)
      drawer: Drawer(
        backgroundColor: const Color(0xFF161B22),
        child: Column(
          children:[
            const UserAccountsDrawerHeader(
              decoration: BoxDecoration(color: Color(0xFF0D1117)),
              accountName: Text("Luminous Word", style: TextStyle(color: Color(0xFF00E5FF), fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: 2)),
              accountEmail: Text("Welcome to the Premium App", style: TextStyle(color: Colors.white54)),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Color(0xFF00E5FF),
                child: Icon(Icons.auto_stories, color: Colors.black, size: 30),
              ),
            ),
            _drawerItem(context, Icons.menu_book, "Bible", '/bible'),
            _drawerItem(context, Icons.library_music, "Music", '/home'), // మ్యూజిక్ తర్వాత యాడ్ చేద్దాం
            _drawerItem(context, Icons.book, "Books & PDFs", '/home'),
            _drawerItem(context, Icons.question_answer, "Q & A", '/home'),
            const Spacer(),
            const Divider(color: Colors.white10),
            // అడ్మిన్ ప్యానెల్ కి వెళ్ళే బటన్ (ఇది అందరికీ కనిపిస్తుంది)
            ListTile(
              leading: const Icon(Icons.admin_panel_settings, color: Colors.redAccent),
              title: const Text("Admin Portal", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
              onTap: () {
                Navigator.pop(context); // మెనూ క్లోజ్ చేసి
                context.push('/admin-login'); // లాగిన్ పేజీకి వెళ్తుంది
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      body: GridView.count(
        padding: const EdgeInsets.all(20),
        crossAxisCount: 2,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
        children:[
          _homeCard(context, "BIBLE", Icons.menu_book, '/bible'),
          _homeCard(context, "MUSIC", Icons.headphones, '/home'),
          _homeCard(context, "BOOKS", Icons.library_books, '/home'),
          _homeCard(context, "PROJECT H", Icons.star, '/home'),
        ],
      ),
    );
  }

  Widget _drawerItem(BuildContext context, IconData icon, String title, String route) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFFA78BFA)),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      onTap: () {
        Navigator.pop(context);
        if (route != '/home') context.push(route);
      },
    );
  }

  Widget _homeCard(BuildContext context, String title, IconData icon, String route) {
    return InkWell(
      onTap: () => route != '/home' ? context.push(route) : null,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF161B22),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
          boxShadow:[BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10)],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children:[
            Icon(icon, size: 50, color: const Color(0xFF00E5FF)),
            const SizedBox(height: 15),
            Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 2)),
          ],
        ),
      ),
    );
  }
}
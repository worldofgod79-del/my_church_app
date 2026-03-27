import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("LUMINOUS WORD", style: TextStyle(letterSpacing: 4, fontWeight: FontWeight.w900, color: Color(0xFF00E5FF))),
        centerTitle: true,
      ),
      drawer: _buildDrawer(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _largeCard(context, "THE HOLY BIBLE", "పరిశుద్ధ గ్రంథము", Icons.auto_stories, '/bible'),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: _squareCard(context, "MUSIC", Icons.headphones, '/music')),
                const SizedBox(width: 15),
                Expanded(child: _squareCard(context, "BOOKS", Icons.menu_book, '/home')),
              ],
            ),
            const SizedBox(height: 20),
            _largeCard(context, "AUDIO MESSAGES", "దైవ సందేశాలు", Icons.mic_external_on, '/home'),
            const SizedBox(height: 20),
            _largeCard(context, "PROJECT H", "Special Projects", Icons.star_rounded, '/home'),
          ],
        ),
      ),
    );
  }

  Widget _largeCard(BuildContext context, String title, String sub, IconData icon, String route) {
    return InkWell(
      onTap: () => route != '/home' ? context.push(route) : null,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          color: const Color(0xFF161616),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 40, color: const Color(0xFF00E5FF)),
            const SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1, color: Colors.white)),
                Text(sub, style: const TextStyle(fontSize: 14, color: Colors.white38)),
              ],
            ),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white12),
          ],
        ),
      ),
    );
  }

  Widget _squareCard(BuildContext context, String title, IconData icon, String route) {
    return InkWell(
      onTap: () => route != '/home' ? context.push(route) : null,
      child: Container(
        height: 140,
        decoration: BoxDecoration(
          color: const Color(0xFF161616),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: const Color(0xFFA78BFA)),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5, color: Colors.white)),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF0F0F0F),
      child: Column(
        children: [
          const DrawerHeader(child: Center(child: Icon(Icons.auto_stories, size: 60, color: Color(0xFF00E5FF)))),
          ListTile(
            leading: const Icon(Icons.admin_panel_settings, color: Colors.redAccent),
            title: const Text("Admin Portal", style: TextStyle(color: Colors.white)),
            onTap: () => context.push('/admin-login'),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../main.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("LUMINOUS WORD", style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.w900, color: Color(0xFF8B0000))),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode, color: const Color(0xFF8B0000)),
            onPressed: () => themeNotifier.value = isDark ? ThemeMode.light : ThemeMode.dark,
          )
        ],
      ),
      drawer: _buildDrawer(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _mainFeatureCard(context, "BIBLE", "పరిశుద్ధ గ్రంథము", Icons.auto_stories, '/bible'),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: _subFeatureCard(context, "MUSIC", Icons.headphones, '/music')),
                const SizedBox(width: 15),
                Expanded(child: _subFeatureCard(context, "BOOKS", Icons.menu_book, '/music')),
              ],
            ),
            const SizedBox(height: 15),
            _mainFeatureCard(context, "PROJECT H", "Special Projects", Icons.star_rounded, '/home'),
          ],
        ),
      ),
    );
  }

  Widget _mainFeatureCard(BuildContext context, String title, String sub, IconData icon, String route) {
    return InkWell(
      onTap: () => context.push(route),
      child: Container(
        height: 140,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF8B0000).withOpacity(0.3), width: 1.5),
        ),
        child: Stack(
          children: [
            Positioned(right: -20, bottom: -20, child: Icon(icon, size: 120, color: Colors.white.withOpacity(0.03))),
            Padding(
              padding: const EdgeInsets.all(25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF8B0000))),
                  Text(sub, style: const TextStyle(fontSize: 14, color: Colors.grey)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _subFeatureCard(BuildContext context, String title, IconData icon, String route) {
    return InkWell(
      onTap: () => context.push(route),
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: const Color(0xFF8B0000)),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5)),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF121212),
      child: Column(
        children: [
          const DrawerHeader(child: Center(child: Icon(Icons.auto_stories, size: 80, color: Color(0xFF8B0000)))),
          ListTile(leading: const Icon(Icons.admin_panel_settings, color: Colors.red), title: const Text("Admin Portal"), onTap: () => context.push('/admin-login')),
        ],
      ),
    );
  }
}
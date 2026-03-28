import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050505), // Deep Midnight
      body: CustomScrollView(
        slivers: [
          // Elegant Glassy Top Bar
          SliverAppBar(
            expandedHeight: 120,
            floating: true,
            backgroundColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 20, bottom: 15),
              title: const Text("LUMINOUS", style: TextStyle(letterSpacing: 8, fontWeight: FontWeight.w200, color: Colors.white)),
            ),
            actions: [
              IconButton(icon: const Icon(Icons.admin_panel_settings_outlined, color: Colors.white24), 
              onPressed: () => context.push('/admin-login')),
            ],
          ),
          
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeroCard(context), // Featured Section
                  const SizedBox(height: 30),
                  const Text("EXPLORE", style: TextStyle(letterSpacing: 2, color: Colors.white54, fontWeight: FontWeight.bold, fontSize: 12)),
                  const SizedBox(height: 15),
                  _buildModularGrid(context),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroCard(BuildContext context) {
    return InkWell(
      onTap: () => context.push('/bible'),
      child: Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: const LinearGradient(colors: [Color(0xFF00D2FF), Color(0xFF9D50BB)]), // Cyber Gradient
        ),
        child: Stack(
          children: [
            Positioned(right: -30, bottom: -30, child: Icon(Icons.auto_stories, size: 200, color: Colors.white.withOpacity(0.1))),
            const Padding(
              padding: EdgeInsets.all(30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("THE HOLY BIBLE", style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white)),
                  Text("Continue Reading...", style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w300)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModularGrid(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _categoryCard(context, "MUSIC", Icons.headphones, const Color(0xFF121212), '/music')),
            const SizedBox(width: 15),
            Expanded(child: _categoryCard(context, "BOOKS", Icons.menu_book, const Color(0xFF121212), '/music')),
          ],
        ),
        const SizedBox(height: 15),
        _categoryCard(context, "AUDIO MESSAGES", Icons.mic_none_rounded, const Color(0xFF121212), '/music', isWide: true),
      ],
    );
  }

  Widget _categoryCard(BuildContext context, String title, IconData icon, Color bg, String route, {bool isWide = false}) {
    return InkWell(
      onTap: () => context.push(route),
      child: Container(
        height: isWide ? 100 : 160,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: isWide 
          ? Row(children: [Icon(icon, color: const Color(0xFF00D2FF)), const SizedBox(width: 20), Text(title, style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2))])
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 40, color: const Color(0xFF00D2FF)),
                const SizedBox(height: 15),
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 1.5)),
              ],
            ),
      ),
    );
  }
}
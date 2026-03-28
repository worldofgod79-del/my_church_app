import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // Navigation కోసం ఇది ముఖ్యం
import '../../widgets/side_menu.dart';
import '../music/music_home.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 2; 

  final List<Widget> _pages = [
    const MusicHome(),      
    const Center(child: Text("Books Section Coming Soon", style: TextStyle(color: Colors.white))),
    const HomeContentView(), 
    const Center(child: Text("Audio Messages Coming Soon", style: TextStyle(color: Colors.white))),
    const Center(child: Text("Project H Coming Soon", style: TextStyle(color: Colors.white))),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      drawer: const SideMenu(),
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        height: 85,
        decoration: BoxDecoration(
          color: const Color(0xFF0A0A0A),
          border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          backgroundColor: Colors.transparent,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: const Color(0xFF00D2FF),
          unselectedItemColor: Colors.white24,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.headphones_outlined), label: "MUSIC"),
            BottomNavigationBarItem(icon: Icon(Icons.menu_book_outlined), label: "BOOKS"),
            BottomNavigationBarItem(icon: Icon(Icons.home_filled, size: 30), label: "HOME"),
            BottomNavigationBarItem(icon: Icon(Icons.mic_none_rounded), label: "AUDIO"),
            BottomNavigationBarItem(icon: Icon(Icons.star_outline_rounded), label: "PROJECT H"),
          ],
        ),
      ),
    );
  }
}

class HomeContentView extends StatelessWidget {
  const HomeContentView({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 80,
          backgroundColor: Colors.transparent,
          leading: Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu_rounded, color: Color(0xFF00D2FF)),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
          title: const Text("LUMINOUS", style: TextStyle(letterSpacing: 6, fontWeight: FontWeight.w200, color: Colors.white)),
          centerTitle: true,
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLiveStatus(),
                const SizedBox(height: 30),
                const Text("DAILY NOTIFICATIONS", style: TextStyle(letterSpacing: 2, color: Colors.white38, fontWeight: FontWeight.bold, fontSize: 11)),
                const SizedBox(height: 15),
                _buildNotificationsList(),
                const SizedBox(height: 35),
                _buildBibleHero(context), // ఇక్కడ నావిగేషన్ ఫిక్స్ చేశాను
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLiveStatus() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF121212),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.redAccent.withOpacity(0.2)),
      ),
      child: const Row(
        children: [
          CircleAvatar(radius: 5, backgroundColor: Colors.redAccent),
          SizedBox(width: 12),
          Text("LIVE NOW:", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 12)),
          SizedBox(width: 10),
          Expanded(child: Text("Sunday Service at 10 AM", style: TextStyle(color: Colors.white70), overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }

  Widget _buildNotificationsList() {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 5,
        itemBuilder: (context, i) => Container(
          width: 250,
          margin: const EdgeInsets.only(right: 15),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF121212),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: Colors.white.withOpacity(0.03)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Today's Verse", style: TextStyle(color: const Color(0xFF00D2FF).withOpacity(0.6), fontSize: 10, fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              const Text("ఆదియందు దేవుడు భూమ్యాకాశములను సృజించెను.", style: TextStyle(color: Colors.white, fontSize: 14), maxLines: 2, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBibleHero(BuildContext context) {
    return InkWell(
      // ఫిక్స్: Navigator.pushNamed బదులుగా context.push వాడాలి
      onTap: () => context.push('/bible'), 
      child: Container(
        height: 180,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: const LinearGradient(colors: [Color(0xFF00D2FF), Color(0xFF9D50BB)]),
        ),
        child: const Padding(
          padding: EdgeInsets.all(30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("HOLY BIBLE", style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Colors.white)),
              Text("Explore the Word...", style: TextStyle(color: Colors.white70)),
            ],
          ),
        ),
      ),
    );
  }
}
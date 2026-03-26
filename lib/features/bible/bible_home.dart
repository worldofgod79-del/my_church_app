import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'bible_service.dart';

class BibleHome extends StatelessWidget {
  const BibleHome({super.key});

  @override
  Widget build(BuildContext context) {
    final service = BibleService();
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFF0D1117), // Deep Space Blue
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text("LUMINOUS WORD", style: TextStyle(letterSpacing: 3, fontWeight: FontWeight.w800, color: Color(0xFF00E5FF))), // Neon Cyan
          centerTitle: true,
          actions:[
            IconButton(icon: const Icon(Icons.search, color: Colors.white70), onPressed: () => context.push('/search')),
          ],
          bottom: const TabBar(
            indicatorColor: Color(0xFF00E5FF),
            labelColor: Color(0xFF00E5FF),
            unselectedLabelColor: Colors.white30,
            indicatorSize: TabBarIndicatorSize.label,
            tabs: [Tab(text: "OLD TESTAMENT"), Tab(text: "NEW TESTAMENT")],
          ),
        ),
        body: TabBarView(
          children:[
            _buildGrid(context, service.getOTBooks(), 0),
            _buildGrid(context, service.getNTBooks(), 39),
          ],
        ),
      ),
    );
  }

  Widget _buildGrid(BuildContext context, List<String> books, int offset) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      itemCount: books.length,
      itemBuilder: (context, index) {
        return InkWell(
          onTap: () => context.push('/bible-reader/${books[index]}'),
          borderRadius: BorderRadius.circular(15),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            decoration: BoxDecoration(
              color: const Color(0xFF161B22), // Sleek Dark Card
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: Row(
              children:[
                Text("${offset + index + 1}", style: const TextStyle(color: Color(0xFFA78BFA), fontSize: 16, fontWeight: FontWeight.bold)), // Purple Accent
                const SizedBox(width: 20),
                Expanded(child: Text(books[index], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFFE6E8EA)))),
                const Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 14),
              ],
            ),
          ),
        );
      },
    );
  }
}
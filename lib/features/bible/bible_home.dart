import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'bible_service.dart';

class BibleHome extends StatefulWidget {
  const BibleHome({super.key});
  @override
  State<BibleHome> createState() => _BibleHomeState();
}

class _BibleHomeState extends State<BibleHome> {
  bool _isDark = false;

  @override
  Widget build(BuildContext context) {
    final service = BibleService();
    final bgColor = _isDark ? const Color(0xFF0F0F0F) : const Color(0xFFF4F1EE);
    final cardColor = _isDark ? const Color(0xFF1A1A1A) : Colors.white;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          elevation: 2,
          backgroundColor: _isDark ? Colors.black : const Color(0xFF1A237E), // Deep Midnight Blue
          title: const Text("BIBLE", style: TextStyle(letterSpacing: 3, fontWeight: FontWeight.bold, color: Colors.white)),
          centerTitle: true,
          actions: [
            IconButton(icon: Icon(_isDark ? Icons.light_mode : Icons.dark_mode, color: const Color(0xFFD4AF37)), 
              onPressed: () => setState(() => _isDark = !_isDark)),
            IconButton(icon: const Icon(Icons.search, color: Colors.white), onPressed: () => context.push('/search')),
          ],
          bottom: const TabBar(
            indicatorColor: Color(0xFFD4AF37), // Gold
            labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            tabs: [Tab(text: "పాత నిబంధన"), Tab(text: "క్రొత్త నిబంధన")],
          ),
        ),
        body: TabBarView(
          children: [
            _buildGrid(context, service.getOTBooks(), 0, cardColor),
            _buildGrid(context, service.getNTBooks(), 39, cardColor),
          ],
        ),
      ),
    );
  }

  Widget _buildGrid(BuildContext context, List<String> books, int offset, Color cardColor) {
    return GridView.builder(
      padding: const EdgeInsets.all(15),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 2.2,
      ),
      itemCount: books.length,
      itemBuilder: (context, index) {
        return InkWell(
          onTap: () => context.push('/bible-reader/${books[index]}'),
          child: Container(
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.2)),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
            ),
            child: Row(
              children: [
                Container(
                  width: 40, height: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color(0xFF1A237E),
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(11), bottomLeft: Radius.circular(11)),
                  ),
                  child: Center(child: Text("${offset + index + 1}", style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold))),
                ),
                const SizedBox(width: 10),
                Expanded(child: Text(books[index], style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: _isDark ? Colors.white : Colors.black))),
              ],
            ),
          ),
        );
      },
    );
  }
}
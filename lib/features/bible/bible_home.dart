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
    final bgColor = _isDark ? const Color(0xFF121212) : const Color(0xFFF9F7F5);
    final cardColor = _isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = _isDark ? Colors.white : const Color(0xFF1A1A1A);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: _isDark ? Colors.black : const Color(0xFF1A1A1A),
          title: const Text("BIBLE", style: TextStyle(letterSpacing: 4, fontWeight: FontWeight.w300, color: Colors.white)),
          centerTitle: true,
          actions: [
            IconButton(icon: Icon(_isDark ? Icons.light_mode : Icons.dark_mode, color: const Color(0xFFC5A059)), 
              onPressed: () => setState(() => _isDark = !_isDark)),
            IconButton(icon: const Icon(Icons.search_rounded, color: Color(0xFFC5A059)), 
              onPressed: () => context.push('/search')),
          ],
          bottom: const TabBar(
            indicatorColor: Color(0xFFC5A059),
            labelColor: Color(0xFFC5A059),
            unselectedLabelColor: Colors.white60,
            tabs: [Tab(text: "పాత నిబంధన"), Tab(text: "క్రొత్త నిబంధన")],
          ),
        ),
        body: TabBarView(
          children: [
            _buildGrid(context, service.getOTBooks(), 0, cardColor, textColor),
            _buildGrid(context, service.getNTBooks(), 39, cardColor, textColor),
          ],
        ),
      ),
    );
  }

  Widget _buildGrid(BuildContext context, List<String> books, int offset, Color cardColor, Color textColor) {
    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, crossAxisSpacing: 15, mainAxisSpacing: 15, childAspectRatio: 2.2,
      ),
      itemCount: books.length,
      itemBuilder: (context, index) {
        return InkWell(
          onTap: () => context.push('/bible-reader/${books[index]}'),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
            ),
            child: Row(
              children: [
                Text("${offset + index + 1}", style: TextStyle(color: Colors.grey.withOpacity(0.5), fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(width: 15),
                Expanded(child: Text(books[index], style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: textColor))),
              ],
            ),
          ),
        );
      },
    );
  }
}

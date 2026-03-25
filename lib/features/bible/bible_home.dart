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
        backgroundColor: const Color(0xFFF9F7F5), // Ivory Cream
        appBar: AppBar(
          elevation: 0,
          backgroundColor: const Color(0xFF1A1A1A), // Deep Charcoal
          title: const Text("BIBLE", style: TextStyle(letterSpacing: 4, fontWeight: FontWeight.w300, color: Colors.white)),
          centerTitle: true,
          actions: [
            IconButton(icon: const Icon(Icons.search_rounded, color: Color(0xFFC5A059)), onPressed: () => context.push('/search')),
          ],
          bottom: const TabBar(
            indicatorColor: Color(0xFFC5A059),
            labelColor: Color(0xFFC5A059),
            unselectedLabelColor: Colors.white60,
            indicatorSize: TabBarIndicatorSize.label,
            tabs: [
              Tab(child: Text("పాత నిబంధన", style: TextStyle(fontSize: 16))),
              Tab(child: Text("క్రొత్త నిబంధన", style: TextStyle(fontSize: 16))),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildGrid(context, service.getOTBooks(), 0),
            _buildGrid(context, service.getNTBooks(), 39),
          ],
        ),
      ),
    );
  }

  Widget _buildGrid(BuildContext context, List<String> books, int offset) {
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
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: Row(
              children: [
                Text("${offset + index + 1}", style: TextStyle(color: Colors.grey[300], fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(width: 15),
                Expanded(child: Text(books[index], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF2D2D2D)))),
              ],
            ),
          ),
        );
      },
    );
  }
}

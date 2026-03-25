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
    final themeBg = _isDark ? const Color(0xFF000000) : const Color(0xFFF2F2F7);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: themeBg,
        appBar: AppBar(
          backgroundColor: _isDark ? const Color(0xFF1C1C1E) : Colors.white,
          elevation: 0,
          centerTitle: false,
          title: Text("BIBLE", style: TextStyle(color: _isDark ? Colors.white : Colors.black, fontWeight: FontWeight.w900, letterSpacing: 2)),
          actions: [
            IconButton(icon: Icon(_isDark ? Icons.wb_sunny : Icons.nightlight_round, color: Colors.amber), 
              onPressed: () => setState(() => _isDark = !_isDark)),
            IconButton(icon: const Icon(Icons.search, color: Colors.blue), onPressed: () => context.push('/search')),
          ],
          bottom: TabBar(
            labelColor: Colors.blue,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.blue,
            indicatorSize: TabBarIndicatorSize.label,
            tabs: const [Tab(text: "OLD"), Tab(text: "NEW")],
          ),
        ),
        body: TabBarView(
          children: [
            _buildList(context, service.getOTBooks(), 0),
            _buildList(context, service.getNTBooks(), 39),
          ],
        ),
      ),
    );
  }

  Widget _buildList(BuildContext context, List<String> books, int offset) {
    return ListView.builder(
      padding: const EdgeInsets.all(15),
      itemCount: books.length,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: _isDark ? const Color(0xFF1C1C1E) : Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            leading: Text("${offset + index + 1}", style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 18)),
            title: Text(books[index], style: TextStyle(color: _isDark ? Colors.white : Colors.black, fontSize: 18, fontWeight: FontWeight.w600)),
            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
            onTap: () => context.push('/bible-reader/${books[index]}'),
          ),
        );
      },
    );
  }
}
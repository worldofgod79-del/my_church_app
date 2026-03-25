import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'bible_service.dart';

class BibleSearch extends StatefulWidget {
  final String? initialBook;
  const BibleSearch({super.key, this.initialBook});
  @override
  State<BibleSearch> createState() => _BibleSearchState();
}

class _BibleSearchState extends State<BibleSearch> {
  final BibleService _service = BibleService();
  final TextEditingController _controller = TextEditingController();
  List<SearchResult> _allFound = [], _display = [];
  String _scope = "Full Bible";
  bool _searching = false;

  void _search() async {
    if (_controller.text.trim().isEmpty) return;
    setState(() { _searching = true; _allFound = []; _display = []; });
    List<SearchResult> temp = [];
    for (var b in _service.bookNames) {
      try {
        var data = await _service.loadBook(b);
        (data['chapters'] as Map).forEach((cNum, verses) {
          (verses as Map).forEach((vNum, txt) {
            if (txt.toString().contains(_controller.text.trim())) temp.add(SearchResult(b, cNum, vNum, txt.toString()));
          });
        });
      } catch (_) {}
    }
    _allFound = temp; _filter();
  }

  void _filter() {
    setState(() {
      if (_scope == "Full Bible") _display = _allFound;
      else if (_scope == "Old Testament") _display = _allFound.where((r) => _service.getOTBooks().contains(r.book)).toList();
      else if (_scope == "New Testament") _display = _allFound.where((r) => _service.getNTBooks().contains(r.book)).toList();
      else if (_scope == "This Book") _display = _allFound.where((r) => r.book == widget.initialBook).toList();
      _searching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F1EE),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A237E),
        title: TextField(
          controller: _controller, autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(hintText: "వెతకండి...", hintStyle: TextStyle(color: Colors.white60), border: InputBorder.none),
          onSubmitted: (_) => _search(),
        ),
        actions: [IconButton(icon: const Icon(Icons.search, color: Colors.white), onPressed: _search)],
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: ["Full Bible", "Old Testament", "New Testament", "This Book"].map((s) {
                if (s == "This Book" && widget.initialBook == null) return const SizedBox();
                return Padding(padding: const EdgeInsets.symmetric(horizontal: 5), 
                  child: ChoiceChip(label: Text(s), selected: _scope == s, 
                    onSelected: (v) { setState(() => _scope = s); _filter(); }));
              }).toList(),
            ),
          ),
          if (_searching) const LinearProgressIndicator(color: Color(0xFFD4AF37)),
          Expanded(child: ListView.builder(
            itemCount: _display.length,
            itemBuilder: (context, i) {
              final r = _display[i];
              return Card(margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                child: ListTile(
                  title: Text("${r.book} ${r.chapter}:${r.verse}", style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1A237E))),
                  subtitle: Text(r.text, maxLines: 2),
                  onTap: () => context.push('/bible-reader/${r.book}?chapter=${r.chapter}&verse=${r.verse}'),
                ));
            })),
        ],
      ),
    );
  }
}
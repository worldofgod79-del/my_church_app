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
  List<SearchResult> _results = [];
  String _scope = "Full Bible";
  bool _isSearching = false;

  void _doSearch() async {
    if (_controller.text.isEmpty) return;
    setState(() { _isSearching = true; _results = []; });

    List<String> targetBooks = [];
    if (_scope == "Full Bible") targetBooks = _service.bookNames;
    else if (_scope == "Old Testament") targetBooks = _service.getOTBooks();
    else if (_scope == "New Testament") targetBooks = _service.getNTBooks();
    else if (_scope == "This Book") targetBooks = [widget.initialBook!];

    List<SearchResult> temp = [];
    for (var b in targetBooks) {
      try {
        var data = await _service.loadBook(b);
        Map chapters = data['chapters'];
        chapters.forEach((cNum, verses) {
          (verses as Map).forEach((vNum, txt) {
            if (txt.toString().contains(_controller.text)) {
              temp.add(SearchResult(b, cNum, vNum, txt.toString()));
            }
          });
        });
      } catch (_) {}
    }
    setState(() { _results = temp; _isSearching = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          decoration: const InputDecoration(hintText: "వెతకండి...", border: InputBorder.none),
          onSubmitted: (_) => _doSearch(),
        ),
        actions: [IconButton(icon: const Icon(Icons.search), onPressed: _doSearch)],
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ["Full Bible", "Old Testament", "New Testament", "This Book"].map((s) {
                if (s == "This Book" && widget.initialBook == null) return Container();
                return Padding(
                  padding: const EdgeInsets.all(5),
                  child: ChoiceChip(label: Text(s), selected: _scope == s, onSelected: (v) => setState(() => _scope = s)),
                );
              }).toList(),
            ),
          ),
          if (_isSearching) const LinearProgressIndicator(),
          Expanded(
            child: ListView.builder(
              itemCount: _results.length,
              itemBuilder: (context, i) {
                final r = _results[i];
                return ListTile(
                  title: Text("${r.book} ${r.chapter}:${r.verse}", style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(r.text, maxLines: 2),
                  onTap: () => context.push('/bible-reader/${r.book}?chapter=${r.chapter}&verse=${r.verse}'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
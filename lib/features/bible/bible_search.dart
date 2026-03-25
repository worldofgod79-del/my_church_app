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
  List<SearchResult> _allFound = []; // మొత్తం సెర్చ్ రిజల్ట్స్
  List<SearchResult> _displayResults = []; // స్క్రీన్ మీద కనిపించేవి (Filtered)
  String _scope = "Full Bible";
  bool _isSearching = false;

  void _runSearch() async {
    if (_controller.text.trim().isEmpty) return;
    setState(() { _isSearching = true; _allFound = []; _displayResults = []; });

    // ఎప్పుడూ మొత్తం బైబిల్ లోనే వెతుకుదాం, తర్వాత ఫిల్టర్ చేద్దాం (User experience కోసం)
    List<String> books = _service.bookNames;
    List<SearchResult> temp = [];

    for (var b in books) {
      try {
        var data = await _service.loadBook(b);
        Map chapters = data['chapters'];
        chapters.forEach((cNum, verses) {
          (verses as Map).forEach((vNum, txt) {
            if (txt.toString().contains(_controller.text.trim())) {
              temp.add(SearchResult(b, cNum, vNum, txt.toString()));
            }
          });
        });
      } catch (_) {}
    }
    _allFound = temp;
    _applyFilter();
  }

  void _applyFilter() {
    setState(() {
      _isSearching = true;
      if (_scope == "Full Bible") {
        _displayResults = _allFound;
      } else if (_scope == "Old Testament") {
        var ot = _service.getOTBooks();
        _displayResults = _allFound.where((r) => ot.contains(r.book)).toList();
      } else if (_scope == "New Testament") {
        var nt = _service.getNTBooks();
        _displayResults = _allFound.where((r) => nt.contains(r.book)).toList();
      } else if (_scope == "This Book" && widget.initialBook != null) {
        _displayResults = _allFound.where((r) => r.book == widget.initialBook).toList();
      }
      _isSearching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: TextField(
          controller: _controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: "వెతకండి (ఉదా: యేసు)...", border: InputBorder.none),
          onSubmitted: (_) => _runSearch(),
        ),
        actions: [IconButton(icon: const Icon(Icons.search, color: Colors.blue), onPressed: _runSearch)],
      ),
      body: Column(
        children: [
          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            child: Row(
              children: ["Full Bible", "Old Testament", "New Testament", "This Book"].map((s) {
                if (s == "This Book" && widget.initialBook == null) return const SizedBox();
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(s),
                    selected: _scope == s,
                    selectedColor: Colors.blue.withOpacity(0.2),
                    onSelected: (v) { setState(() => _scope = s); _applyFilter(); },
                  ),
                );
              }).toList(),
            ),
          ),
          if (_isSearching) const LinearProgressIndicator(),
          Expanded(
            child: _displayResults.isEmpty && !_isSearching
                ? const Center(child: Text("ఫలితాలు లేవు", style: TextStyle(color: Colors.grey)))
                : ListView.builder(
                    itemCount: _displayResults.length,
                    itemBuilder: (context, i) {
                      final r = _displayResults[i];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          title: Text("${r.book} ${r.chapter}:${r.verse}", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                          subtitle: Text(r.text, maxLines: 2, overflow: TextOverflow.ellipsis),
                          onTap: () => context.push('/bible-reader/${r.book}?chapter=${r.chapter}&verse=${r.verse}'),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
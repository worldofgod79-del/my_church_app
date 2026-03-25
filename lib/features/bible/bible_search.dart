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
  List<SearchResult> _allResults = [];
  List<SearchResult> _filteredResults = [];
  String _currentScope = "Full Bible";
  bool _isSearching = false;

  void _performSearch() async {
    if (_controller.text.isEmpty) return;
    setState(() { _isSearching = true; _allResults = []; });

    List<String> booksToSearch = [];
    if (_currentScope == "Full Bible") booksToSearch = _service.bookNames;
    else if (_currentScope == "Old Testament") booksToSearch = _service.getOTBooks();
    else if (_currentScope == "New Testament") booksToSearch = _service.getNTBooks();
    else if (_currentScope == "Specific Book") booksToSearch = [widget.initialBook!];

    List<SearchResult> tempResults = [];
    for (String bookName in booksToSearch) {
      try {
        var data = await _service.loadBook(bookName);
        Map<String, dynamic> chapters = data['chapters'];
        chapters.forEach((chapNum, verses) {
          (verses as Map).forEach((verseNum, text) {
            if (text.toString().contains(_controller.text)) {
              tempResults.add(SearchResult(bookName, chapNum, verseNum, text.toString()));
            }
          });
        });
      } catch (e) { debugPrint("Error search in $bookName"); }
    }

    setState(() {
      _allResults = tempResults;
      _filteredResults = tempResults;
      _isSearching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: "వెతకండి...", border: InputBorder.none),
          onSubmitted: (_) => _performSearch(),
        ),
        actions: [IconButton(icon: const Icon(Icons.search), onPressed: _performSearch)],
      ),
      body: Column(
        children: [
          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ["Full Bible", "Old Testament", "New Testament", "Specific Book"].map((scope) {
                if (scope == "Specific Book" && widget.initialBook == null) return Container();
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: ChoiceChip(
                    label: Text(scope == "Specific Book" ? widget.initialBook! : scope),
                    selected: _currentScope == scope,
                    onSelected: (val) { setState(() => _currentScope = scope); _performSearch(); },
                  ),
                );
              }).toList(),
            ),
          ),
          if (_isSearching) const LinearProgressIndicator(),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredResults.length,
              itemBuilder: (context, index) {
                final res = _filteredResults[index];
                return ListTile(
                  title: Text("${res.book} ${res.chapter}:${res.verse}", style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(res.text, maxLines: 2, overflow: TextOverflow.ellipsis),
                  onTap: () {
                    // ఆ వచనం దగ్గరికి వెళ్లడానికి
                    context.push('/bible-reader/${res.book}?chapter=${res.chapter}&verse=${res.verse}');
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

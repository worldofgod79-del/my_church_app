import 'package:flutter/material.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:go_router/go_router.dart';
import 'bible_service.dart';

class BibleReader extends StatefulWidget {
  final String bookName;
  final String? initialChapter, initialVerse;
  const BibleReader({super.key, required this.bookName, this.initialChapter, this.initialVerse});

  @override
  State<BibleReader> createState() => _BibleReaderState();
}

class _BibleReaderState extends State<BibleReader> {
  final BibleService _service = BibleService();
  final ItemScrollController _scrollController = ItemScrollController();
  Map<String, dynamic> _chapters = {};
  String _currentChapter = "1";
  String _currentVerse = "1";
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  _load() async {
    final data = await _service.loadBook(widget.bookName);
    setState(() {
      _chapters = data["chapters"];
      if (widget.initialChapter != null) _currentChapter = widget.initialChapter!;
      if (widget.initialVerse != null) _currentVerse = widget.initialVerse!;
      _loading = false;
    });

    // సెర్చ్ నుండి వచ్చినప్పుడు ఆ వచనం దగ్గరికి స్క్రోల్ అవ్వడం
    Future.delayed(const Duration(milliseconds: 600), () {
      if (widget.initialVerse != null && _scrollController.isAttached) {
        _scrollController.jumpTo(index: int.parse(widget.initialVerse!) - 1);
      }
    });
  }

  List<String> _sort(Iterable<String> k) => k.toList()..sort((a, b) => int.parse(a).compareTo(int.parse(b)));

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    var sortedChapters = _sort(_chapters.keys);
    var verses = _chapters[_currentChapter] ?? {};
    var sortedVerses = _sort(verses.keys);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.bookName, style: const TextStyle(fontSize: 15)),
        backgroundColor: Colors.brown[800],
        foregroundColor: Colors.white,
        actions: [
          // ఇక్కడ కూడా సెర్చ్ బటన్ యాడ్ చేశాను
          IconButton(
            icon: const Icon(Icons.search), 
            onPressed: () => context.push('/search?book=${widget.bookName}')
          ),
          DropdownButton<String>(
            value: _currentChapter,
            dropdownColor: Colors.brown[900],
            style: const TextStyle(color: Colors.white, fontSize: 13),
            underline: Container(),
            items: sortedChapters.map((c) => DropdownMenuItem(value: c, child: Text("అధ్యా. $c"))).toList(),
            onChanged: (v) => setState(() { _currentChapter = v!; _currentVerse = "1"; }),
          ),
          DropdownButton<String>(
            value: _currentVerse,
            dropdownColor: Colors.brown[900],
            style: const TextStyle(color: Colors.white, fontSize: 13),
            underline: Container(),
            items: sortedVerses.map((v) => DropdownMenuItem(value: v, child: Text("వచనం $v"))).toList(),
            onChanged: (v) {
              setState(() => _currentVerse = v!);
              _scrollController.scrollTo(index: int.parse(v!) - 1, duration: const Duration(milliseconds: 500));
            },
          ),
          const SizedBox(width: 5),
        ],
      ),
      body: Container(
        color: const Color(0xFFFFF9F0),
        child: ScrollablePositionedList.builder(
          itemCount: sortedVerses.length,
          itemScrollController: _scrollController,
          padding: const EdgeInsets.all(16),
          itemBuilder: (context, i) {
            String vNum = sortedVerses[i];
            bool isSel = vNum == _currentVerse;
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              color: isSel ? Colors.brown.withOpacity(0.1) : Colors.transparent,
              child: Text(
                "$vNum. ${verses[vNum]}", 
                style: TextStyle(fontSize: 20, height: 1.6, color: isSel ? Colors.red : Colors.black87)
              ),
            );
          },
        ),
      ),
    );
  }
}
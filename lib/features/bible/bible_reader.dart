import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:convert';
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

  List<String> _bookmarks = [];
  Map<String, int> _verseColors = {};
  Set<String> _selectedVerses = {};

  final Color primaryBrown = const Color(0xFF3E2723);
  final Color goldAccent = const Color(0xFFD4AF37);
  final Color paperColor = const Color(0xFFFDFBF7);

  @override
  void initState() {
    super.initState();
    _load();
  }

  _load() async {
    final data = await _service.loadBook(widget.bookName);
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _chapters = data["chapters"];
      if (widget.initialChapter != null) _currentChapter = widget.initialChapter!;
      if (widget.initialVerse != null) _currentVerse = widget.initialVerse!;
      _loading = false;
      _bookmarks = prefs.getStringList('bookmarks') ?? [];
      String colorData = prefs.getString('verse_colors') ?? "{}";
      _verseColors = Map<String, int>.from(json.decode(colorData));
    });
    Future.delayed(const Duration(milliseconds: 600), () {
      if (widget.initialVerse != null && _scrollController.isAttached) {
        _scrollController.jumpTo(index: int.parse(widget.initialVerse!) - 1);
      }
    });
  }

  _saveBookmarks() async => (await SharedPreferences.getInstance()).setStringList('bookmarks', _bookmarks);
  _saveColors() async => (await SharedPreferences.getInstance()).setString('verse_colors', json.encode(_verseColors));

  void _toggleSelection(String vNum) {
    setState(() {
      if (_selectedVerses.contains(vNum)) _selectedVerses.remove(vNum);
      else _selectedVerses.add(vNum);
    });
  }

  String _getSelectedText() {
    var sorted = _selectedVerses.toList()..sort((a, b) => int.parse(a).compareTo(int.parse(b)));
    String result = "${widget.bookName} $_currentChapter:${sorted.join(', ')}\n\n";
    for (var v in sorted) result += "$v. ${_chapters[_currentChapter][v]}\n";
    return result;
  }

  void _showVerseOptions(String vNum, String vText) {
    String key = "${widget.bookName}_${_currentChapter}_$vNum";
    bool isBookmarked = _bookmarks.contains(key);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 20),
            Text("${widget.bookName} $_currentChapter:$vNum", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: primaryBrown)),
            const Divider(height: 30),
            _actionTile(isBookmarked ? Icons.bookmark : Icons.bookmark_border, isBookmarked ? "Remove Bookmark" : "Add Bookmark", () {
              setState(() { isBookmarked ? _bookmarks.remove(key) : _bookmarks.add(key); });
              _saveBookmarks(); Navigator.pop(context);
            }),
            _actionTile(Icons.copy, "Copy Verse", () {
              Clipboard.setData(ClipboardData(text: "${widget.bookName} $_currentChapter:$vNum - $vText"));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Copied!")));
            }),
          ],
        ),
      ),
    );
  }

  Widget _actionTile(IconData icon, String title, VoidCallback onTap) {
    return ListTile(leading: Icon(icon, color: goldAccent), title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)), onTap: onTap);
  }

  List<String> _sort(Iterable<String> k) => k.toList()..sort((a, b) => int.parse(a).compareTo(int.parse(b)));

  @override
  Widget build(BuildContext context) {
    if (_loading) return Scaffold(body: Center(child: CircularProgressIndicator(color: goldAccent)));
    var sortedChapters = _sort(_chapters.keys);
    var verses = _chapters[_currentChapter] ?? {};
    var sortedVerses = _sort(verses.keys);

    return Scaffold(
      backgroundColor: paperColor,
      appBar: AppBar(
        elevation: 4,
        backgroundColor: primaryBrown,
        foregroundColor: Colors.white,
        title: Text(widget.bookName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () => context.push('/search?book=${widget.bookName}')),
          _customDropdown(_currentChapter, sortedChapters, (v) => setState(() { _currentChapter = v!; _currentVerse = "1"; _selectedVerses.clear(); })),
          _customDropdown(_currentVerse, sortedVerses, (v) {
            setState(() => _currentVerse = v!);
            _scrollController.scrollTo(index: int.parse(v!) - 1, duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
          }),
        ],
      ),
      body: ScrollablePositionedList.builder(
        itemCount: sortedVerses.length,
        itemScrollController: _scrollController,
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
        itemBuilder: (context, i) {
          String vNum = sortedVerses[i];
          String vText = verses[vNum].toString().trim();
          String key = "${widget.bookName}_${_currentChapter}_$vNum";
          bool isHighlighted = vNum == _currentVerse;
          bool isSelected = _selectedVerses.contains(vNum);
          bool isBookmarked = _bookmarks.contains(key);
          int? colorValue = _verseColors[key];

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => _toggleSelection(vNum),
            onLongPress: () => _showVerseOptions(vNum, vText),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
              margin: const EdgeInsets.only(bottom: 6),
              decoration: BoxDecoration(
                color: isSelected ? Colors.blue.withOpacity(0.15) : (colorValue != null ? Color(colorValue) : (isHighlighted ? Colors.brown.withOpacity(0.08) : Colors.transparent)),
                borderRadius: BorderRadius.circular(12),
                border: isSelected ? Border.all(color: Colors.blue.withOpacity(0.5)) : null,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("$vNum. ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: isHighlighted ? Colors.red[800] : const Color(0xFF8D6E63))),
                  Expanded(child: Text(vText, style: const TextStyle(fontSize: 22, height: 1.7, color: Color(0xFF2C1E1A)))),
                  if (isBookmarked) Icon(Icons.bookmark, size: 18, color: goldAccent),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _selectedVerses.isEmpty ? null : _buildSelectionBar(),
    );
  }

  Widget _customDropdown(String val, List<String> items, Function(String?) onChange) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
      child: DropdownButton<String>(
        value: val, dropdownColor: primaryBrown, iconEnabledColor: Colors.white,
        style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
        underline: Container(),
        items: items.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
        onChanged: onChange,
      ),
    );
  }

  Widget _buildSelectionBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: primaryBrown, borderRadius: BorderRadius.circular(40),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 20)],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(icon: const Icon(Icons.copy, color: Colors.white), onPressed: () {
            Clipboard.setData(ClipboardData(text: _getSelectedText()));
            setState(() => _selectedVerses.clear());
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Copied!")));
          }),
          IconButton(icon: const Icon(Icons.share, color: Colors.white), onPressed: () {
            Share.share(_getSelectedText());
            setState(() => _selectedVerses.clear());
          }),
          _colorDot(Colors.yellow[200]!), _colorDot(Colors.green[200]!), _colorDot(Colors.blue[200]!),
          const VerticalDivider(color: Colors.white24, width: 20),
          IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => setState(() => _selectedVerses.clear())),
        ],
      ),
    );
  }

  Widget _colorDot(Color color) {
    return GestureDetector(
      onTap: () {
        for (var v in _selectedVerses) _verseColors["${widget.bookName}_${_currentChapter}_$v"] = color.value;
        _saveColors(); setState(() => _selectedVerses.clear());
      },
      child: Padding(padding: const EdgeInsets.symmetric(horizontal: 6), child: CircleAvatar(backgroundColor: color, radius: 12)),
    );
  }
}
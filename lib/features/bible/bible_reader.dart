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
  bool _isDark = false;
  double _fontSize = 21.0; // Default Font Size

  List<String> _bookmarks = [];
  Map<String, int> _verseColors = {};
  Set<String> _selectedVerses = {};

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
      _isDark = prefs.getBool('isDark') ?? false;
      _fontSize = prefs.getDouble('fontSize') ?? 21.0;
    });
    if (widget.initialVerse != null) {
      Future.delayed(const Duration(milliseconds: 600), () {
        if (_scrollController.isAttached) _scrollController.jumpTo(index: int.parse(widget.initialVerse!) - 1);
      });
    }
  }

  _savePrefs() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDark', _isDark);
    prefs.setDouble('fontSize', _fontSize);
    prefs.setStringList('bookmarks', _bookmarks);
    prefs.setString('verse_colors', json.encode(_verseColors));
  }

  void _showSingleOptions(String vNum, String vText) {
    String key = "${widget.bookName}_${_currentChapter}_$vNum";
    bool isBookmarked = _bookmarks.contains(key);
    showModalBottomSheet(
      context: context,
      backgroundColor: _isDark ? const Color(0xFF1E1E1E) : Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("${widget.bookName} $_currentChapter:$vNum", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _isDark ? Colors.white : Colors.black)),
            const SizedBox(height: 20),
            ListTile(
              leading: Icon(isBookmarked ? Icons.bookmark : Icons.bookmark_border, color: const Color(0xFFC5A059)),
              title: Text(isBookmarked ? "Remove Bookmark" : "Save Bookmark", style: TextStyle(color: _isDark ? Colors.white : Colors.black)),
              onTap: () {
                setState(() { isBookmarked ? _bookmarks.remove(key) : _bookmarks.add(key); });
                _savePrefs(); Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  String _getShareText() {
    var sorted = _selectedVerses.toList()..sort((a, b) => int.parse(a).compareTo(int.parse(b)));
    String result = "${widget.bookName} $_currentChapter:${sorted.join(', ')}\n\n";
    for (var v in sorted) result += "$v. ${_chapters[_currentChapter][v]}\n";
    return result;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator(color: Color(0xFFC5A059))));
    var chapters = _chapters.keys.toList()..sort((a, b) => int.parse(a).compareTo(int.parse(b)));
    var verses = _chapters[_currentChapter] ?? {};
    var sortedVerses = verses.keys.toList()..sort((a, b) => int.parse(a).compareTo(int.parse(b)));

    final bgColor = _isDark ? const Color(0xFF121212) : const Color(0xFFFDFDFD);
    final txtColor = _isDark ? Colors.white70 : const Color(0xFF1A1A1A);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: _isDark ? Colors.black : Colors.white,
        elevation: 1,
        foregroundColor: _isDark ? Colors.white : Colors.black,
        title: Text(widget.bookName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        actions: [
          IconButton(icon: const Icon(Icons.zoom_in, size: 20), onPressed: () => setState(() { if(_fontSize < 40) _fontSize += 2; _savePrefs(); })),
          IconButton(icon: const Icon(Icons.zoom_out, size: 20), onPressed: () => setState(() { if(_fontSize > 14) _fontSize -= 2; _savePrefs(); })),
          IconButton(icon: const Icon(Icons.search, size: 20), onPressed: () => context.push('/search?book=${widget.bookName}')),
          _dropdown(_currentChapter, chapters),
        ],
      ),
      body: ScrollablePositionedList.builder(
        itemCount: sortedVerses.length,
        itemScrollController: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        itemBuilder: (context, i) {
          String vNum = sortedVerses[i];
          String vText = verses[vNum].toString().trim();
          String key = "${widget.bookName}_${_currentChapter}_$vNum";
          bool isSelected = _selectedVerses.contains(vNum);
          bool isBookmarked = _bookmarks.contains(key);
          int? colorVal = _verseColors[key];

          return GestureDetector(
            onTap: () => setState(() => isSelected ? _selectedVerses.remove(vNum) : _selectedVerses.add(vNum)),
            onLongPress: () => _showSingleOptions(vNum, vText),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFC5A059).withOpacity(0.2) : (colorVal != null ? Color(colorVal) : Colors.transparent),
                border: Border(bottom: BorderSide(color: _isDark ? Colors.white10 : Colors.grey[100]!, width: 0.5)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("$vNum ", style: TextStyle(fontSize: _fontSize * 0.7, fontWeight: FontWeight.bold, color: Colors.grey)),
                  Expanded(child: Text(vText, style: TextStyle(fontSize: _fontSize, height: 1.7, color: txtColor))),
                  if (isBookmarked) const Icon(Icons.bookmark, size: 16, color: Color(0xFFC5A059)),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: _selectedVerses.isEmpty ? null : _buildSelectionBar(),
    );
  }

  Widget _dropdown(String val, List<String> items) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(color: _isDark ? Colors.white12 : Colors.black.withOpacity(0.05), borderRadius: BorderRadius.circular(8)),
      child: DropdownButton<String>(
        value: val, underline: Container(), dropdownColor: _isDark ? Colors.black : Colors.white,
        style: TextStyle(color: _isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold),
        items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
        onChanged: (v) => setState(() { _currentChapter = v!; _selectedVerses.clear(); }),
      ),
    );
  }

  Widget _buildSelectionBar() {
    return Container(
      height: 70, margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(20), boxShadow: [const BoxShadow(color: Colors.black45, blurRadius: 15)]),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(icon: const Icon(Icons.copy, color: Colors.white), onPressed: () {
            Clipboard.setData(ClipboardData(text: _getShareText()));
            setState(() => _selectedVerses.clear());
          }),
          IconButton(icon: const Icon(Icons.share, color: Colors.white), onPressed: () {
            Share.share(_getShareText());
            setState(() => _selectedVerses.clear());
          }),
          _dot(Colors.yellow[200]!), _dot(Colors.green[200]!), _dot(Colors.blue[200]!),
          IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => setState(() => _selectedVerses.clear())),
        ],
      ),
    );
  }

  Widget _dot(Color c) => GestureDetector(onTap: () {
    for (var v in _selectedVerses) _verseColors["${widget.bookName}_${_currentChapter}_$v"] = c.value;
    _savePrefs(); setState(() => _selectedVerses.clear());
  }, child: CircleAvatar(radius: 12, backgroundColor: c));
}

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
    if (widget.initialVerse != null) {
      Future.delayed(const Duration(milliseconds: 600), () {
        if (_scrollController.isAttached) _scrollController.jumpTo(index: int.parse(widget.initialVerse!) - 1);
      });
    }
  }

  void _showOptions(String vNum, String vText) {
    String key = "${widget.bookName}_${_currentChapter}_$vNum";
    bool isBookmarked = _bookmarks.contains(key);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("${widget.bookName} $_currentChapter:$vNum", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _actionCircle(isBookmarked ? Icons.bookmark : Icons.bookmark_border, "Save", () {
                  setState(() { isBookmarked ? _bookmarks.remove(key) : _bookmarks.add(key); });
                  (SharedPreferences.getInstance()).then((p) => p.setStringList('bookmarks', _bookmarks));
                  Navigator.pop(context);
                }),
                _actionCircle(Icons.copy_rounded, "Copy", () {
                  Clipboard.setData(ClipboardData(text: vText));
                  Navigator.pop(context);
                }),
                _actionCircle(Icons.share_rounded, "Share", () {
                  Share.share("$vText\n\n${widget.bookName} $_currentChapter:$vNum");
                  Navigator.pop(context);
                }),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _actionCircle(IconData icon, String label, VoidCallback onTap) {
    return Column(
      children: [
        InkWell(onTap: onTap, child: CircleAvatar(radius: 30, backgroundColor: const Color(0xFFF0F0F0), child: Icon(icon, color: const Color(0xFF1A1A1A)))),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500))
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator(color: Color(0xFFC5A059))));
    var chapters = _chapters.keys.toList()..sort((a, b) => int.parse(a).compareTo(int.parse(b)));
    var verses = _chapters[_currentChapter] ?? {};
    var sortedVerses = verses.keys.toList()..sort((a, b) => int.parse(a).compareTo(int.parse(b)));

    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFD),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        foregroundColor: const Color(0xFF1A1A1A),
        title: Text(widget.bookName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        actions: [
          _dropdown(_currentChapter, chapters, (v) => setState(() { _currentChapter = v!; _currentVerse = "1"; _selectedVerses.clear(); })),
          _dropdown(_currentVerse, sortedVerses, (v) {
            setState(() => _currentVerse = v!);
            _scrollController.scrollTo(index: int.parse(v!) - 1, duration: const Duration(milliseconds: 500));
          }),
        ],
      ),
      body: ScrollablePositionedList.builder(
        itemCount: sortedVerses.length,
        itemScrollController: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
        itemBuilder: (context, i) {
          String vNum = sortedVerses[i];
          String vText = verses[vNum].toString().trim();
          String key = "${widget.bookName}_${_currentChapter}_$vNum";
          bool isSelected = _selectedVerses.contains(vNum);
          bool isBookmarked = _bookmarks.contains(key);
          int? colorVal = _verseColors[key];

          return GestureDetector(
            onTap: () => setState(() => isSelected ? _selectedVerses.remove(vNum) : _selectedVerses.add(vNum)),
            onLongPress: () => _showOptions(vNum, vText),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFC5A059).withOpacity(0.1) : (colorVal != null ? Color(colorVal) : Colors.transparent),
                border: Border(bottom: BorderSide(color: Colors.grey[100]!, width: 0.5)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("$vNum  ", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey[400])),
                  Expanded(child: Text(vText, style: const TextStyle(fontSize: 21, height: 1.8, color: Color(0xFF1A1A1A), letterSpacing: 0.2))),
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

  Widget _dropdown(String val, List<String> items, Function(String?) onChg) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 5),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(8)),
      child: DropdownButton<String>(
        value: val, underline: Container(), icon: const Icon(Icons.keyboard_arrow_down, size: 18),
        items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
        onChanged: onChg,
      ),
    );
  }

  Widget _buildSelectionBar() {
    return Container(
      height: 80,
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 20)]),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(icon: const Icon(Icons.copy, color: Colors.white), onPressed: () {
            String txt = "";
            for (var v in _selectedVerses) txt += "$v. ${_chapters[_currentChapter][v]}\n";
            Clipboard.setData(ClipboardData(text: txt));
            setState(() => _selectedVerses.clear());
          }),
          _dot(Colors.yellow[100]!), _dot(Colors.green[100]!), _dot(Colors.blue[100]!),
          IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => setState(() => _selectedVerses.clear())),
        ],
      ),
    );
  }

  Widget _dot(Color c) => GestureDetector(onTap: () {
    for (var v in _selectedVerses) _verseColors["${widget.bookName}_${_currentChapter}_$v"] = c.value;
    SharedPreferences.getInstance().then((p) => p.setString('verse_colors', json.encode(_verseColors)));
    setState(() => _selectedVerses.clear());
  }, child: CircleAvatar(radius: 12, backgroundColor: c));
}

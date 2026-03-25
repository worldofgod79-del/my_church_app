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
  bool _loading = true, _isDark = false;
  double _fontSize = 20.0;
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
      _isDark = prefs.getBool('isDark') ?? false;
      _fontSize = prefs.getDouble('fontSize') ?? 20.0;
      _bookmarks = prefs.getStringList('bookmarks') ?? [];
      String colorData = prefs.getString('verse_colors') ?? "{}";
      _verseColors = Map<String, int>.from(json.decode(colorData));
      if (widget.initialChapter != null) _currentChapter = widget.initialChapter!;
      if (widget.initialVerse != null) _currentVerse = widget.initialVerse!;
      _loading = false;
    });
    if (widget.initialVerse != null) {
      Future.delayed(const Duration(milliseconds: 600), () {
        if (_scrollController.isAttached) _scrollController.jumpTo(index: int.parse(widget.initialVerse!) - 1);
      });
    }
  }

  _save() async {
    final p = await SharedPreferences.getInstance();
    p.setBool('isDark', _isDark);
    p.setDouble('fontSize', _fontSize);
    p.setStringList('bookmarks', _bookmarks);
    p.setString('verse_colors', json.encode(_verseColors));
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator(color: Color(0xFFD4AF37))));
    var chapters = _chapters.keys.toList()..sort((a, b) => int.parse(a).compareTo(int.parse(b)));
    var versesMap = _chapters[_currentChapter] ?? {};
    var versesList = versesMap.keys.toList()..sort((a, b) => int.parse(a).compareTo(int.parse(b)));

    final bgColor = _isDark ? const Color(0xFF121212) : const Color(0xFFFCF9F5);
    final txtColor = _isDark ? Colors.white70 : Colors.black87;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        elevation: 2,
        backgroundColor: _isDark ? Colors.black : const Color(0xFF1A237E),
        foregroundColor: Colors.white,
        titleSpacing: 0,
        title: InkWell(
          onTap: () => context.pop(),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(widget.bookName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFD4AF37))),
          ),
        ),
        actions: [
          _drop(_currentChapter, chapters, (v) => setState(() { _currentChapter = v!; _currentVerse = "1"; _selectedVerses.clear(); })),
          _drop(_currentVerse, versesList, (v) { 
            setState(() => _currentVerse = v!); 
            _scrollController.scrollTo(index: int.parse(v!) - 1, duration: const Duration(milliseconds: 400)); 
          }),
          IconButton(icon: const Icon(Icons.search, size: 20), onPressed: () => context.push('/search?book=${widget.bookName}')),
          PopupMenuButton<String>(
            icon: const Icon(Icons.settings, size: 20, color: Color(0xFFD4AF37)),
            onSelected: (val) {
              if (val == 'dark') setState(() { _isDark = !_isDark; _save(); });
              if (val == 'in') setState(() { if(_fontSize < 45) _fontSize += 2; _save(); });
              if (val == 'out') setState(() { if(_fontSize > 12) _fontSize -= 2; _save(); });
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: 'dark', child: ListTile(leading: Icon(_isDark ? Icons.wb_sunny : Icons.nightlight_round), title: const Text("Theme"))),
              const PopupMenuItem(value: 'in', child: ListTile(leading: Icon(Icons.add_circle), title: const Text("Zoom In"))),
              const PopupMenuItem(value: 'out', child: ListTile(leading: Icon(Icons.remove_circle), title: const Text("Zoom Out"))),
            ],
          ),
        ],
      ),
      body: ScrollablePositionedList.builder(
        itemCount: versesList.length,
        itemScrollController: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        itemBuilder: (context, i) {
          String vNum = versesList[i];
          String vText = versesMap[vNum].toString().trim();
          String key = "${widget.bookName}_${_currentChapter}_$vNum";
          bool isSelected = _selectedVerses.contains(vNum);
          bool isBookmarked = _bookmarks.contains(key);
          int? colorVal = _verseColors[key];

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => setState(() => isSelected ? _selectedVerses.remove(vNum) : _selectedVerses.add(vNum)),
            onLongPress: () { setState(() { isBookmarked ? _bookmarks.remove(key) : _bookmarks.add(key); }); _save(); },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              decoration: BoxDecoration(
                color: isSelected ? Colors.blue.withOpacity(0.1) : (colorVal != null ? Color(colorVal) : Colors.transparent),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("$vNum. ", style: TextStyle(fontSize: _fontSize * 0.7, color: const Color(0xFFD4AF37), fontWeight: FontWeight.bold)),
                  Expanded(child: Text(vText, style: TextStyle(fontSize: _fontSize, height: 1.7, color: txtColor))),
                  if (isBookmarked) const Icon(Icons.bookmark, size: 16, color: Color(0xFFD4AF37)),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: _selectedVerses.isEmpty ? null : _buildSelectionBar(),
    );
  }

  Widget _drop(String val, List<String> items, Function(String?) onChg) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 3),
      padding: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(5)),
      child: DropdownButton<String>(
        value: val, underline: Container(), dropdownColor: const Color(0xFF1A237E),
        items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(color: Colors.white, fontSize: 13)))).toList(),
        onChanged: onChg,
      ),
    );
  }

  Widget _buildSelectionBar() {
    return Container(
      height: 70, margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: const Color(0xFF1A237E), borderRadius: BorderRadius.circular(20), boxShadow: [const BoxShadow(color: Colors.black45, blurRadius: 15)]),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(icon: const Icon(Icons.copy, color: Colors.white), onPressed: () {
            var sorted = _selectedVerses.toList()..sort((a,b) => int.parse(a).compareTo(int.parse(b)));
            String res = "${widget.bookName} $_currentChapter\n";
            for(var v in sorted) res += "$v. ${_chapters[_currentChapter][v]}\n";
            Clipboard.setData(ClipboardData(text: res)); setState(() => _selectedVerses.clear());
          }),
          IconButton(icon: const Icon(Icons.share, color: Colors.white), onPressed: () {
            var sorted = _selectedVerses.toList()..sort((a,b) => int.parse(a).compareTo(int.parse(b)));
            String res = "${widget.bookName} $_currentChapter\n";
            for(var v in sorted) res += "$v. ${_chapters[_currentChapter][v]}\n";
            Share.share(res); setState(() => _selectedVerses.clear());
          }),
          _dot(Colors.yellow[200]!), _dot(Colors.green[200]!),
          IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => setState(() => _selectedVerses.clear())),
        ],
      ),
    );
  }

  Widget _dot(Color c) => GestureDetector(onTap: () {
    for (var v in _selectedVerses) _verseColors["${widget.bookName}_${_currentChapter}_$v"] = c.value;
    _save(); setState(() => _selectedVerses.clear());
  }, child: CircleAvatar(radius: 12, backgroundColor: c));
}
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
  double _fontSize = 21.0;

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
      _fontSize = prefs.getDouble('fontSize') ?? 21.0;
      _bookmarks = prefs.getStringList('bookmarks') ?? [];
      String colorData = prefs.getString('verse_colors') ?? "{}";
      _verseColors = Map<String, int>.from(json.decode(colorData));
      
      if (widget.initialChapter != null) _currentChapter = widget.initialChapter!;
      if (widget.initialVerse != null) _currentVerse = widget.initialVerse!;
      _loading = false;
    });

    if (widget.initialVerse != null) {
      Future.delayed(const Duration(milliseconds: 600), () {
        if (_scrollController.isAttached) {
          _scrollController.jumpTo(index: int.parse(widget.initialVerse!) - 1);
        }
      });
    }
  }

  _savePrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDark', _isDark);
    await prefs.setDouble('fontSize', _fontSize);
    await prefs.setStringList('bookmarks', _bookmarks);
    await prefs.setString('verse_colors', json.encode(_verseColors));
  }

  String _getCombinedText() {
    var sorted = _selectedVerses.toList()..sort((a, b) => int.parse(a).compareTo(int.parse(b)));
    String result = "${widget.bookName} $_currentChapter:${sorted.join(', ')}\n\n";
    for (var v in sorted) result += "$v. ${_chapters[_currentChapter][v]}\n";
    return result;
  }

  void _showVerseMenu(String vNum, String vText) {
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
            const Divider(),
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

  List<String> _sort(Iterable<String> k) => k.toList()..sort((a, b) => int.parse(a).compareTo(int.parse(b)));

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator(color: Color(0xFFC5A059))));
    
    var chaptersList = _sort(_chapters.keys);
    var versesMap = _chapters[_currentChapter] ?? {};
    var versesList = _sort(versesMap.keys);

    final Color bgColor = _isDark ? const Color(0xFF121212) : const Color(0xFFFDFDFD);
    final Color textColor = _isDark ? Colors.white70 : const Color(0xFF1A1A1A);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        elevation: 1,
        backgroundColor: _isDark ? Colors.black : Colors.white,
        foregroundColor: _isDark ? Colors.white : Colors.black,
        titleSpacing: 0,
        title: Text(widget.bookName, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.remove_circle_outline, size: 20), onPressed: () => setState(() { if(_fontSize > 12) _fontSize -= 2; _savePrefs(); })),
          IconButton(icon: const Icon(Icons.add_circle_outline, size: 20), onPressed: () => setState(() { if(_fontSize < 45) _fontSize += 2; _savePrefs(); })),
          IconButton(icon: const Icon(Icons.search, size: 20), onPressed: () => context.push('/search?book=${widget.bookName}')),
          IconButton(icon: Icon(_isDark ? Icons.light_mode : Icons.dark_mode, size: 20), onPressed: () => setState(() { _isDark = !_isDark; _savePrefs(); })),
          
          // చాప్టర్ ఎంపిక
          _appBarDropdown(_currentChapter, chaptersList, (v) => setState(() { _currentChapter = v!; _currentVerse = "1"; _selectedVerses.clear(); })),
          
          // వచనం ఎంపిక (Back as requested)
          _appBarDropdown(_currentVerse, versesList, (v) {
            setState(() => _currentVerse = v!);
            _scrollController.scrollTo(index: int.parse(v!) - 1, duration: const Duration(milliseconds: 500));
          }),
        ],
      ),
      body: ScrollablePositionedList.builder(
        itemCount: versesList.length,
        itemScrollController: _scrollController,
        padding: const EdgeInsets.fromLTRB(15, 10, 15, 100),
        itemBuilder: (context, i) {
          String vNum = versesList[i];
          String vText = versesMap[vNum].toString().trim();
          String key = "${widget.bookName}_${_currentChapter}_$vNum";
          
          bool isHighlighted = vNum == _currentVerse;
          bool isSelected = _selectedVerses.contains(vNum);
          bool isBookmarked = _bookmarks.contains(key);
          int? colorVal = _verseColors[key];

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => setState(() => isSelected ? _selectedVerses.remove(vNum) : _selectedVerses.add(vNum)),
            onLongPress: () => _showVerseMenu(vNum, vText),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFC5A059).withOpacity(0.2) : (colorVal != null ? Color(colorVal) : (isHighlighted ? Colors.brown.withOpacity(0.1) : Colors.transparent)),
                border: Border(bottom: BorderSide(color: _isDark ? Colors.white10 : Colors.grey[100]!, width: 0.5)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("$vNum. ", style: TextStyle(fontSize: _fontSize * 0.7, fontWeight: FontWeight.bold, color: isHighlighted ? Colors.red : Colors.grey)),
                  Expanded(child: Text(vText, style: TextStyle(fontSize: _fontSize, height: 1.7, color: textColor))),
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

  Widget _appBarDropdown(String val, List<String> items, Function(String?) onChg) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(color: _isDark ? Colors.white12 : Colors.black.withOpacity(0.05), borderRadius: BorderRadius.circular(5)),
      child: DropdownButton<String>(
        value: val, underline: Container(), dropdownColor: _isDark ? Colors.black : Colors.white,
        style: TextStyle(color: _isDark ? Colors.white : Colors.black, fontSize: 12, fontWeight: FontWeight.bold),
        items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
        onChanged: onChg,
      ),
    );
  }

  Widget _buildSelectionBar() {
    return Container(
      height: 75, margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(25), boxShadow: [const BoxShadow(color: Colors.black54, blurRadius: 20)]),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(icon: const Icon(Icons.copy, color: Colors.white), onPressed: () {
            Clipboard.setData(ClipboardData(text: _getCombinedText()));
            setState(() => _selectedVerses.clear());
          }),
          IconButton(icon: const Icon(Icons.share, color: Colors.white), onPressed: () {
            Share.share(_getCombinedText());
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

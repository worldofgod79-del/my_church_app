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
  String _currentVerse = "1"; // ఇది డ్రాప్‌డౌన్ జంప్ కోసం
  bool _loading = true;

  List<String> _bookmarks = [];
  Map<String, int> _verseColors = {};
  
  // మల్టీ సెలెక్షన్ కోసం సెట్ (Keys: verse number)
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

    Future.delayed(const Duration(milliseconds: 600), () {
      if (widget.initialVerse != null && _scrollController.isAttached) {
        _scrollController.jumpTo(index: int.parse(widget.initialVerse!) - 1);
      }
    });
  }

  _saveBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('bookmarks', _bookmarks);
  }

  _saveColors() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('verse_colors', json.encode(_verseColors));
  }

  // సెలెక్షన్ టోగుల్ చేయడం
  void _toggleSelection(String vNum) {
    setState(() {
      if (_selectedVerses.contains(vNum)) {
        _selectedVerses.remove(vNum);
      } else {
        _selectedVerses.add(vNum);
      }
    });
  }

  // సెలెక్ట్ చేసిన వచనాల టెక్స్ట్ కలపడం
  String _getSelectedText() {
    var sortedSelected = _selectedVerses.toList()..sort((a, b) => int.parse(a).compareTo(int.parse(b)));
    String result = "${widget.bookName} $_currentChapter:${sortedSelected.join(', ')}\n\n";
    for (var v in sortedSelected) {
      result += "$v. ${_chapters[_currentChapter][v]}\n";
    }
    return result;
  }

  // మల్టీ కలర్ మార్కింగ్
  void _applyColorToSelected(Color color) {
    setState(() {
      for (var v in _selectedVerses) {
        String key = "${widget.bookName}_${_currentChapter}_$v";
        _verseColors[key] = color.value;
      }
      _selectedVerses.clear();
    });
    _saveColors();
  }

  // సింగిల్ వచనం ఆప్షన్స్ (Long Press)
  void _showVerseOptions(String vNum, String vText) {
    String key = "${widget.bookName}_${_currentChapter}_$vNum";
    bool isBookmarked = _bookmarks.contains(key);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("${widget.bookName} $_currentChapter:$vNum", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const Divider(),
            ListTile(
              leading: Icon(isBookmarked ? Icons.bookmark : Icons.bookmark_border, color: Colors.brown),
              title: Text(isBookmarked ? "Remove Bookmark" : "Add Bookmark"),
              onTap: () {
                setState(() { isBookmarked ? _bookmarks.remove(key) : _bookmarks.add(key); });
                _saveBookmarks();
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.copy, color: Colors.blue),
              title: const Text("Copy Single Verse"),
              onTap: () {
                Clipboard.setData(ClipboardData(text: "${widget.bookName} $_currentChapter:$vNum - $vText"));
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Copied!")));
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
          IconButton(icon: const Icon(Icons.search), onPressed: () => context.push('/search?book=${widget.bookName}')),
          DropdownButton<String>(
            value: _currentChapter,
            dropdownColor: Colors.brown[900],
            style: const TextStyle(color: Colors.white, fontSize: 13),
            underline: Container(),
            items: sortedChapters.map((c) => DropdownMenuItem(value: c, child: Text("అధ్యా. $c"))).toList(),
            onChanged: (v) => setState(() { _currentChapter = v!; _currentVerse = "1"; _selectedVerses.clear(); }),
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
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                margin: const EdgeInsets.only(bottom: 2),
                decoration: BoxDecoration(
                  // ప్రాధాన్యత: 1. సెలెక్షన్ (Blue), 2. కలర్ మార్కింగ్, 3. డ్రాప్‌డౌన్ జంప్ హైలైట్
                  color: isSelected 
                      ? Colors.blue.withOpacity(0.2) 
                      : (colorValue != null ? Color(colorValue) : (isHighlighted ? Colors.brown.withOpacity(0.1) : Colors.transparent)),
                  borderRadius: BorderRadius.circular(5),
                  border: isSelected ? Border.all(color: Colors.blue, width: 0.5) : null,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isBookmarked) const Icon(Icons.bookmark, size: 16, color: Colors.brown),
                    const SizedBox(width: 8),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(color: Colors.black87, fontSize: 21, height: 1.6),
                          children: [
                            TextSpan(text: "$vNum. ", style: TextStyle(fontWeight: FontWeight.bold, color: isHighlighted ? Colors.red : Colors.brown)),
                            TextSpan(text: vText),
                          ],
                        ),
                      ),
                    ),
                    if (isSelected) const Icon(Icons.check_circle, size: 18, color: Colors.blue),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      // మల్టీ సెలెక్షన్ చేసినప్పుడు కింద వచ్చే టూల్ బార్
      bottomNavigationBar: _selectedVerses.isEmpty 
          ? null 
          : BottomAppBar(
              height: 70,
              color: Colors.brown[50],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(icon: const Icon(Icons.copy), onPressed: () {
                    Clipboard.setData(ClipboardData(text: _getSelectedText()));
                    setState(() => _selectedVerses.clear());
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Selected verses copied!")));
                  }),
                  IconButton(icon: const Icon(Icons.share), onPressed: () {
                    Share.share(_getSelectedText());
                    setState(() => _selectedVerses.clear());
                  }),
                  // కలర్ పాలెట్
                  _colorOption(Colors.yellow[200]!),
                  _colorOption(Colors.green[200]!),
                  _colorOption(Colors.blue[200]!),
                  IconButton(icon: const Icon(Icons.clear), onPressed: () => setState(() => _selectedVerses.clear())),
                ],
              ),
            ),
    );
  }

  Widget _colorOption(Color color) {
    return GestureDetector(
      onTap: () => _applyColorToSelected(color),
      child: CircleAvatar(backgroundColor: color, radius: 12),
    );
  }
}
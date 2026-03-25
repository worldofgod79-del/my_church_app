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
              title: const Text("Copy Verse"),
              onTap: () {
                Clipboard.setData(ClipboardData(text: "${widget.bookName} $_currentChapter:$vNum - $vText"));
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Copied!")));
              },
            ),
            ListTile(
              leading: const Icon(Icons.share, color: Colors.green),
              title: const Text("Share Verse"),
              onTap: () {
                Share.share("${widget.bookName} $_currentChapter:$vNum\n$vText");
                Navigator.pop(context);
              },
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _colorIcon(key, Colors.yellow[200]!),
                _colorIcon(key, Colors.green[200]!),
                _colorIcon(key, Colors.blue[200]!),
                _colorIcon(key, Colors.pink[200]!),
                IconButton(icon: const Icon(Icons.format_color_reset), onPressed: () {
                  setState(() => _verseColors.remove(key));
                  _saveColors();
                  Navigator.pop(context);
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _colorIcon(String key, Color color) {
    return GestureDetector(
      onTap: () {
        setState(() => _verseColors[key] = color.value);
        _saveColors();
        Navigator.pop(context);
      },
      child: CircleAvatar(backgroundColor: color, radius: 15),
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
            String vText = verses[vNum].toString().trim();
            String key = "${widget.bookName}_${_currentChapter}_$vNum";
            
            bool isSel = vNum == _currentVerse;
            bool isBookmarked = _bookmarks.contains(key);
            int? colorValue = _verseColors[key];

            return GestureDetector(
              behavior: HitTestBehavior.opaque, // ఇది లాంగ్ ప్రెస్ కచ్చితంగా పనిచేసేలా చేస్తుంది
              onLongPress: () => _showVerseOptions(vNum, vText),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                decoration: BoxDecoration(
                  color: colorValue != null ? Color(colorValue) : (isSel ? Colors.brown.withOpacity(0.1) : Colors.transparent),
                  borderRadius: BorderRadius.circular(5),
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
                            TextSpan(text: "$vNum. ", style: TextStyle(fontWeight: FontWeight.bold, color: isSel ? Colors.red : Colors.brown)),
                            TextSpan(text: vText),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
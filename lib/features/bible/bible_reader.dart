import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:convert';
import 'bible_service.dart';
import 'cross_ref_service.dart';

class BibleReader extends StatefulWidget {
  final String bookName;
  final String? initialChapter, initialVerse;
  const BibleReader({super.key, required this.bookName, this.initialChapter, this.initialVerse});

  @override
  State<BibleReader> createState() => _BibleReaderState();
}

class _BibleReaderState extends State<BibleReader> {
  final BibleService _service = BibleService();
  final CrossRefService _crossService = CrossRefService();
  final ItemScrollController _scrollController = ItemScrollController();
  
  Map<String, dynamic> _chapters = {};
  String _currentChapter = "1";
  String _currentVerse = "1";
  String? _highlightedVerse; 
  
  bool _loading = true;
  bool _isDark = true;
  double _fontSize = 22.0;
  List<String> _bookmarks = [];
  Map<String, int> _verseColors = {};
  Set<String> _selectedVerses = {};

  final Color bgDark = const Color(0xFF0D1117);
  final Color accentCyan = const Color(0xFF00E5FF);
  final Color accentPurple = const Color(0xFFA78BFA);

  @override
  void initState() {
    super.initState();
    _load();
  }

  _load() async {
    try {
      final data = await _service.loadBook(widget.bookName);
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _chapters = data["chapters"];
        _isDark = prefs.getBool('isDark') ?? true;
        _fontSize = prefs.getDouble('fontSize') ?? 22.0;
        _bookmarks = prefs.getStringList('bookmarks') ?? [];
        String colorData = prefs.getString('verse_colors') ?? "{}";
        _verseColors = Map<String, int>.from(json.decode(colorData));
        
        if (widget.initialChapter != null) _currentChapter = widget.initialChapter!;
        if (widget.initialVerse != null) {
          _currentVerse = widget.initialVerse!;
          _highlightedVerse = widget.initialVerse!;
        }
        _loading = false;
      });
      
      if (widget.initialVerse != null) {
        Future.delayed(const Duration(milliseconds: 600), () {
          if (_scrollController.isAttached) {
            int vIndex = _getSortedKeys(_chapters[_currentChapter] ?? {}).indexOf(widget.initialVerse!);
            _scrollController.jumpTo(index: vIndex + 1); 
          }
        });
      }
    } catch (e) {
      setState(() { _loading = false; });
    }
  }

  _save() async {
    final p = await SharedPreferences.getInstance();
    p.setBool('isDark', _isDark);
    p.setDouble('fontSize', _fontSize);
    p.setStringList('bookmarks', _bookmarks);
    p.setString('verse_colors', json.encode(_verseColors));
  }

  List<String> _getSortedKeys(Iterable<String> k) => k.toList()..sort((a, b) => int.parse(a).compareTo(int.parse(b)));

  void _showOptions(String vNum, String vText) async {
    String key = "${widget.bookName}_${_currentChapter}_$vNum";
    bool isBookmarked = _bookmarks.contains(key);

    final crossData = await _crossService.getReferences(widget.bookName);
    List refs = [];
    if (crossData != null && crossData[_currentChapter] != null) {
      refs = crossData[_currentChapter][vNum] ?? [];
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: BoxDecoration(
          color: _isDark ? const Color(0xFF161B22) : Colors.white, 
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30))
        ),
        padding: const EdgeInsets.all(25),
        child: Column(
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 20),
            Text("${widget.bookName} $_currentChapter:$vNum", 
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: _isDark ? Colors.white : Colors.black)),
            const Divider(height: 30, color: Colors.white10),
            Expanded(
              child: ListView(
                children: [
                  ListTile(
                    leading: Icon(isBookmarked ? Icons.bookmark : Icons.bookmark_border, color: accentCyan),
                    title: Text(isBookmarked ? "Remove Bookmark" : "Save Bookmark", 
                      style: TextStyle(color: _isDark ? Colors.white : Colors.black)),
                    onTap: () { setState(() { isBookmarked ? _bookmarks.remove(key) : _bookmarks.add(key); }); _save(); Navigator.pop(context); },
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                    child: Text("CROSS REFERENCES", style: TextStyle(letterSpacing: 2, fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
                  ),
                  if (refs.isEmpty) 
                    const Padding(padding: EdgeInsets.all(15), child: Text("No references found.", style: TextStyle(color: Colors.white30)))
                  else
                    ...refs.map((r) {
                      return ListTile(
                        title: Text(r.toString(), style: TextStyle(color: accentPurple, fontWeight: FontWeight.bold)),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.white24),
                        onTap: () {
                          Navigator.pop(context);
                          _navigateToRef(r.toString());
                        },
                      );
                    }).toList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToRef(String ref) {
    try {
      List<String> parts = ref.split(' ');
      String bookCode = parts[0];
      List<String> loc = parts[1].split(':');
      String chap = loc[0];
      String verse = loc[1];
      String? telName = _service.engToTelMapping[bookCode];
      if (telName != null) {
        context.push('/bible-reader/$telName?chapter=$chap&verse=$verse');
      }
    } catch (e) {
      debugPrint("Nav Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return Scaffold(backgroundColor: bgDark, body: Center(child: CircularProgressIndicator(color: accentCyan)));
    var sortedChapters = _getSortedKeys(_chapters.keys);
    var versesMap = _chapters[_currentChapter] ?? {};
    var sortedVerses = _getSortedKeys(versesMap.keys);

    final Color bgColor = _isDark ? bgDark : const Color(0xFFF9FAFB);
    // ఇక్కడ whiteEms ని white70 గా ఫిక్స్ చేశాను
    final Color txtColor = _isDark ? Colors.white70 : Colors.black87;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: _isDark ? Colors.white : Colors.black,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, size: 20), onPressed: () => context.pop()),
        actions: [
          IconButton(icon: const Icon(Icons.search, size: 22), onPressed: () => context.push('/search?book=${widget.bookName}')),
          PopupMenuButton<String>(
            icon: const Icon(Icons.settings_outlined, size: 22),
            color: _isDark ? const Color(0xFF161B22) : Colors.white,
            onSelected: (val) {
              if (val == 'dark') setState(() { _isDark = !_isDark; _save(); });
              if (val == 'in') setState(() { if(_fontSize < 45) _fontSize += 2; _save(); });
              if (val == 'out') setState(() { if(_fontSize > 14) _fontSize -= 2; _save(); });
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: 'dark', child: ListTile(leading: Icon(_isDark ? Icons.wb_sunny : Icons.nightlight_round, color: accentCyan), title: const Text("Theme"))),
              const PopupMenuItem(value: 'in', child: ListTile(leading: Icon(Icons.zoom_in), title: Text("Zoom In"))),
              const PopupMenuItem(value: 'out', child: ListTile(leading: Icon(Icons.zoom_out), title: Text("Zoom Out"))),
            ],
          ),
        ],
      ),
      body: Stack(
        children: [
          ScrollablePositionedList.builder(
            itemCount: sortedVerses.length + 1, 
            itemScrollController: _scrollController,
            padding: const EdgeInsets.only(left: 25, right: 25, bottom: 120), 
            itemBuilder: (context, i) {
              if (i == 0) {
                return Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("WORLD OF GOD", style: TextStyle(fontSize: 12, letterSpacing: 4, fontWeight: FontWeight.bold, color: accentCyan)),
                      const SizedBox(height: 10),
                      Text("${widget.bookName} $_currentChapter", style: TextStyle(fontSize: 42, fontWeight: FontWeight.w900, color: _isDark ? Colors.white : Colors.black, letterSpacing: -1.5)),
                    ],
                  ),
                );
              }

              String vNum = sortedVerses[i - 1];
              String vText = versesMap[vNum].toString().trim();
              String key = "${widget.bookName}_${_currentChapter}_$vNum";
              bool isSelected = _selectedVerses.contains(vNum);
              bool isBookmarked = _bookmarks.contains(key);
              bool isHighlighted = vNum == _highlightedVerse; 
              int? colorVal = _verseColors[key];

              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => setState(() { if (isSelected) _selectedVerses.remove(vNum); else _selectedVerses.add(vNum); _highlightedVerse = null; }),
                onLongPress: () => _showOptions(vNum, vText),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: (isSelected || isHighlighted) ? const EdgeInsets.all(20) : EdgeInsets.zero,
                  decoration: BoxDecoration(
                    color: isSelected ? (_isDark ? const Color(0xFF161B22) : Colors.white) : (isHighlighted ? accentCyan.withOpacity(0.15) : (colorVal != null ? Color(colorVal).withOpacity(0.2) : Colors.transparent)),
                    borderRadius: BorderRadius.circular(24),
                    border: isSelected ? Border.all(color: _isDark ? const Color(0xFF30363D) : const Color(0xFFE5E7EB), width: 1.5) : (isHighlighted ? Border.all(color: accentCyan.withOpacity(0.5), width: 1.5) : null),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 4, right: 15),
                        child: Text(vNum, style: TextStyle(fontSize: _fontSize * 0.6, fontWeight: FontWeight.w900, color: accentPurple)),
                      ),
                      Expanded(child: Text(vText, style: TextStyle(fontSize: _fontSize, height: 1.6, color: txtColor))),
                      if (isBookmarked) Padding(padding: const EdgeInsets.only(left: 10), child: Icon(Icons.bookmark, size: 16, color: accentCyan)),
                    ],
                  ),
                ),
              );
            },
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 30, left: 20, right: 20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(40),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                  child: Container(
                    height: 65,
                    decoration: BoxDecoration(
                      color: _isDark ? Colors.black.withOpacity(0.6) : Colors.white.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(40),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: _selectedVerses.isEmpty 
                        ? _buildNavPill(sortedChapters, sortedVerses) 
                        : _buildActionPill(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavPill(List<String> chapters, List<String> verses) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children:[
        TextButton(onPressed: () => context.pop(), child: Text(widget.bookName, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF00E5FF)))),
        _glassDropdown("Ch $_currentChapter", chapters, (v) => setState(() { _currentChapter = v!; _currentVerse = "1"; _selectedVerses.clear(); _highlightedVerse = null; })),
        _glassDropdown("V $_currentVerse", verses, (v) {
          setState(() => _currentVerse = v!);
          _scrollController.scrollTo(index: verses.indexOf(v!) + 1, duration: const Duration(milliseconds: 500));
        }),
      ],
    );
  }

  Widget _glassDropdown(String title, List<String> items, Function(String?) onChg) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        hint: Text(title, style: TextStyle(color: _isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold, fontSize: 13)),
        dropdownColor: _isDark ? const Color(0xFF161B22) : Colors.white,
        items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: TextStyle(color: _isDark?Colors.white:Colors.black)))).toList(),
        onChanged: onChg,
      ),
    );
  }

  Widget _buildActionPill() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(icon: const Icon(Icons.copy, color: Colors.white), onPressed: () {
          var sorted = _selectedVerses.toList()..sort((a,b) => int.parse(a).compareTo(int.parse(b)));
          String res = "${widget.bookName} $_currentChapter\n\n";
          for(var v in sorted) res += "$v. ${_chapters[_currentChapter][v]}\n";
          Clipboard.setData(ClipboardData(text: res)); setState(() => _selectedVerses.clear());
        }),
        IconButton(icon: const Icon(Icons.share, color: Colors.white), onPressed: () {
          var sorted = _selectedVerses.toList()..sort((a,b) => int.parse(a).compareTo(int.parse(b)));
          String res = "${widget.bookName} $_currentChapter\n\n";
          for(var v in sorted) res += "$v. ${_chapters[_currentChapter][v]}\n";
          res += "\n- Shared via World Of God App"; 
          Share.share(res); setState(() => _selectedVerses.clear());
        }),
        _dot(const Color(0xFFFDE047)), _dot(const Color(0xFF6EE7B7)), _dot(const Color(0xFF93C5FD)), 
        IconButton(icon: Icon(Icons.close, color: accentCyan), onPressed: () => setState(() => _selectedVerses.clear())),
      ],
    );
  }

  Widget _dot(Color c) => GestureDetector(onTap: () {
    for (var v in _selectedVerses) _verseColors["${widget.bookName}_${_currentChapter}_$v"] = c.value;
    _save(); setState(() => _selectedVerses.clear());
  }, child: CircleAvatar(radius: 10, backgroundColor: c));
}
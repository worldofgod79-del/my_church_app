import 'dart:ui';
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
  String _errorMessage = ""; // ఎర్రర్ కోసం కొత్త వేరియబుల్
  
  bool _isDark = true;
  double _fontSize = 20.0;
  List<String> _bookmarks =[];
  Map<String, int> _verseColors = {};
  Set<String> _selectedVerses = {};

  final Color bgDark = const Color(0xFF0D1117);
  final Color bgLight = const Color(0xFFF9FAFB);
  final Color accentCyan = const Color(0xFF00E5FF);
  final Color accentPurple = const Color(0xFFA78BFA);

  @override
  void initState() {
    super.initState();
    _load();
  }

  // ఇక్కడే మనం ఎర్రర్స్ ని పట్టుకునే లాజిక్ రాశాం
  _load() async {
    try {
      final data = await _service.loadBook(widget.bookName);
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _chapters = data["chapters"];
        _isDark = prefs.getBool('isDark') ?? true;
        _fontSize = prefs.getDouble('fontSize') ?? 20.0;
        _bookmarks = prefs.getStringList('bookmarks') ??[];
        String colorData = prefs.getString('verse_colors') ?? "{}";
        _verseColors = Map<String, int>.from(json.decode(colorData));
        if (widget.initialChapter != null) _currentChapter = widget.initialChapter!;
        if (widget.initialVerse != null) _currentVerse = widget.initialVerse!;
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
      setState(() {
        _errorMessage = e.toString();
        _loading = false;
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

  List<String> _getSortedKeys(Iterable<String> k) => k.toList()..sort((a, b) => int.parse(a).compareTo(int.parse(b)));

  void _showOptions(String vNum, String vText) {
    String key = "${widget.bookName}_${_currentChapter}_$vNum";
    bool isBookmarked = _bookmarks.contains(key);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(color: _isDark ? const Color(0xFF161B22) : Colors.white, borderRadius: const BorderRadius.vertical(top: Radius.circular(30))),
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children:[
            Text("${widget.bookName} $_currentChapter:$vNum", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: _isDark ? Colors.white : Colors.black)),
            const Divider(height: 30, color: Colors.grey),
            ListTile(
              leading: Icon(isBookmarked ? Icons.bookmark : Icons.bookmark_border, color: accentCyan),
              title: Text(isBookmarked ? "Remove Bookmark" : "Save Bookmark", style: TextStyle(color: _isDark ? Colors.white : Colors.black)),
              onTap: () { setState(() { isBookmarked ? _bookmarks.remove(key) : _bookmarks.add(key); }); _save(); Navigator.pop(context); },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ఒకవేళ ఎర్రర్ వస్తే ఈ స్క్రీన్ కనిపిస్తుంది
    if (_errorMessage.isNotEmpty) {
      return Scaffold(
        backgroundColor: bgDark,
        appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white), onPressed: () => context.pop())),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text("సమస్య: \n$_errorMessage", style: const TextStyle(color: Colors.redAccent, fontSize: 16), textAlign: TextAlign.center),
          ),
        ),
      );
    }

    if (_loading) return Scaffold(backgroundColor: bgDark, body: Center(child: CircularProgressIndicator(color: accentCyan)));
    
    var chapters = _getSortedKeys(_chapters.keys);
    var versesMap = _chapters[_currentChapter] ?? {};
    var sortedVerses = _getSortedKeys(versesMap.keys);

    final bgColor = _isDark ? bgDark : bgLight;
    final txtColor = _isDark ? const Color(0xFFE6E8EA) : const Color(0xFF1F2328);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: _isDark ? Colors.white : Colors.black,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, size: 20), onPressed: () => context.pop()),
        actions:[
          IconButton(icon: const Icon(Icons.search, size: 22), onPressed: () => context.push('/search?book=${widget.bookName}')),
          PopupMenuButton<String>(
            icon: const Icon(Icons.settings_outlined, size: 22),
            color: _isDark ? const Color(0xFF161B22) : Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            onSelected: (val) {
              if (val == 'dark') setState(() { _isDark = !_isDark; _save(); });
              if (val == 'in') setState(() { if(_fontSize < 45) _fontSize += 2; _save(); });
              if (val == 'out') setState(() { if(_fontSize > 12) _fontSize -= 2; _save(); });
            },
            itemBuilder: (context) =>[
              PopupMenuItem(value: 'dark', child: ListTile(leading: Icon(_isDark ? Icons.wb_sunny : Icons.nightlight_round, color: accentCyan), title: Text("Theme", style: TextStyle(color: _isDark?Colors.white:Colors.black)))),
              PopupMenuItem(value: 'in', child: ListTile(leading: Icon(Icons.zoom_in, color: accentCyan), title: Text("Zoom In", style: TextStyle(color: _isDark?Colors.white:Colors.black)))),
              PopupMenuItem(value: 'out', child: ListTile(leading: Icon(Icons.zoom_out, color: accentCyan), title: Text("Zoom Out", style: TextStyle(color: _isDark?Colors.white:Colors.black)))),
            ],
          ),
        ],
      ),
      body: Stack(
        children:[
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
                    children:[
                      Text("BOOK OF ${widget.bookName.toUpperCase()}", style: TextStyle(fontSize: 12, letterSpacing: 3, fontWeight: FontWeight.bold, color: _isDark ? Colors.white54 : Colors.black54)),
                      const SizedBox(height: 10),
                      Text("Chapter $_currentChapter", style: TextStyle(fontSize: 48, fontWeight: FontWeight.w900, color: _isDark ? Colors.white : Colors.black, letterSpacing: -1.5)),
                    ],
                  ),
                );
              }

              String vNum = sortedVerses[i - 1];
              String vText = versesMap[vNum].toString().trim();
              String key = "${widget.bookName}_${_currentChapter}_$vNum";
              bool isSelected = _selectedVerses.contains(vNum);
              bool isBookmarked = _bookmarks.contains(key);
              int? colorVal = _verseColors[key];

              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => setState(() => isSelected ? _selectedVerses.remove(vNum) : _selectedVerses.add(vNum)),
                onLongPress: () => _showOptions(vNum, vText),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: isSelected ? const EdgeInsets.all(20) : EdgeInsets.zero,
                  decoration: BoxDecoration(
                    color: isSelected ? (_isDark ? const Color(0xFF161B22) : Colors.white) : (colorVal != null ? Color(colorVal).withOpacity(0.2) : Colors.transparent),
                    borderRadius: BorderRadius.circular(24),
                    border: isSelected ? Border.all(color: _isDark ? const Color(0xFF30363D) : const Color(0xFFE5E7EB), width: 1.5) : null,
                    boxShadow: isSelected ?[BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15)] :[],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children:[
                      Padding(
                        padding: const EdgeInsets.only(top: 4, right: 15),
                        child: Text(vNum, style: TextStyle(fontSize: _fontSize * 0.65, fontWeight: FontWeight.w900, color: accentPurple)),
                      ),
                      Expanded(
                        child: Text(vText, style: TextStyle(fontSize: _fontSize, height: 1.7, color: txtColor, fontWeight: FontWeight.w400)),
                      ),
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
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: _isDark ? Colors.black.withOpacity(0.6) : Colors.white.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(40),
                      border: Border.all(color: _isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05)),
                    ),
                    child: _selectedVerses.isEmpty 
                        ? _buildNavPill(chapters, sortedVerses) 
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
        TextButton(
          onPressed: () => context.pop(),
          style: TextButton.styleFrom(foregroundColor: accentCyan, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
          child: Text(widget.bookName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        ),
        Container(width: 1, height: 20, color: Colors.grey.withOpacity(0.3)),
        _glassDropdown("Ch $_currentChapter", chapters, (v) => setState(() { _currentChapter = v!; _currentVerse = "1"; _selectedVerses.clear(); })),
        Container(width: 1, height: 20, color: Colors.grey.withOpacity(0.3)),
        _glassDropdown("V $_currentVerse", verses, (v) {
          setState(() => _currentVerse = v!);
          int vIndex = verses.indexOf(v!);
          _scrollController.scrollTo(index: vIndex + 1, duration: const Duration(milliseconds: 500), curve: Curves.easeInOutQuart);
        }),
      ],
    );
  }

  Widget _glassDropdown(String title, List<String> items, Function(String?) onChg) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        hint: Text(title, style: TextStyle(color: _isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold, fontSize: 14)),
        icon: const SizedBox(),
        dropdownColor: _isDark ? const Color(0xFF161B22) : Colors.white,
        items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: TextStyle(color: _isDark?Colors.white:Colors.black)))).toList(),
        onChanged: onChg,
      ),
    );
  }

  Widget _buildActionPill() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children:[
        IconButton(icon: Icon(Icons.copy, color: _isDark ? Colors.white : Colors.black), onPressed: () {
          var sorted = _selectedVerses.toList()..sort((a,b) => int.parse(a).compareTo(int.parse(b)));
          String res = "${widget.bookName} $_currentChapter\n";
          for(var v in sorted) res += "$v. ${_chapters[_currentChapter][v]}\n";
          Clipboard.setData(ClipboardData(text: res)); setState(() => _selectedVerses.clear());
        }),
        IconButton(icon: Icon(Icons.share, color: _isDark ? Colors.white : Colors.black), onPressed: () {
          var sorted = _selectedVerses.toList()..sort((a,b) => int.parse(a).compareTo(int.parse(b)));
          String res = "${widget.bookName} $_currentChapter\n";
          for(var v in sorted) res += "$v. ${_chapters[_currentChapter][v]}\n";
          Share.share(res); setState(() => _selectedVerses.clear());
        }),
        _dot(const Color(0xFFFDE047)),
        _dot(const Color(0xFF6EE7B7)),
        _dot(const Color(0xFF93C5FD)),
        Container(width: 1, height: 20, color: Colors.grey.withOpacity(0.3)),
        IconButton(icon: Icon(Icons.close, color: accentCyan), onPressed: () => setState(() => _selectedVerses.clear())),
      ],
    );
  }

  Widget _dot(Color c) => GestureDetector(onTap: () {
    for (var v in _selectedVerses) _verseColors["${widget.bookName}_${_currentChapter}_$v"] = c.value;
    _save(); setState(() => _selectedVerses.clear());
  }, child: CircleAvatar(radius: 10, backgroundColor: c));
}

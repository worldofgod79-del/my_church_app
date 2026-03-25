import 'package:flutter/material.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'bible_service.dart';

class BibleReader extends StatefulWidget {
  final String bookName;
  const BibleReader({super.key, required this.bookName});

  @override
  State<BibleReader> createState() => _BibleReaderState();
}

class _BibleReaderState extends State<BibleReader> {
  final BibleService _service = BibleService();
  final ItemScrollController _itemScrollController = ItemScrollController();
  
  Map<String, dynamic> _chapters = {};
  String _currentChapter = "1";
  String _currentVerse = "1";
  bool _loading = true;
  String _errorMsg = "";

  @override
  void initState() {
    super.initState();
    _load();
  }

  _load() async {
    try {
      final data = await _service.loadBook(widget.bookName);
      setState(() {
        _chapters = data["chapters"];
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _errorMsg = e.toString();
        _loading = false;
      });
    }
  }

  // నంబర్లను 1, 2, 3... 10 క్రమంలో సర్దుబాటు చేసే ఫంక్షన్
  List<String> _getSortedKeys(Iterable<String> keys) {
    var list = keys.toList();
    list.sort((a, b) => int.parse(a).compareTo(int.parse(b)));
    return list;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_errorMsg.isNotEmpty) return Scaffold(appBar: AppBar(), body: Center(child: Text(_errorMsg)));

    List<String> sortedChapters = _getSortedKeys(_chapters.keys);
    Map<String, dynamic> versesMap = _chapters[_currentChapter] ?? {};
    List<String> sortedVerses = _getSortedKeys(versesMap.keys);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.brown[800],
        foregroundColor: Colors.white,
        titleSpacing: 0,
        title: Text(widget.bookName, style: const TextStyle(fontSize: 16)),
        actions: [
          // అధ్యాయం సెలెక్షన్
          DropdownButton<String>(
            value: _currentChapter,
            dropdownColor: Colors.brown[900],
            style: const TextStyle(color: Colors.white, fontSize: 13),
            underline: Container(),
            items: sortedChapters.map((c) => DropdownMenuItem(value: c, child: Text("అధ్యా. $c"))).toList(),
            onChanged: (v) {
              setState(() {
                _currentChapter = v!;
                _currentVerse = "1"; // అధ్యాయం మారితే వచనం 1 కి వెళ్లాలి
              });
            },
          ),
          // వచనం సెలెక్షన్
          DropdownButton<String>(
            value: _currentVerse,
            dropdownColor: Colors.brown[900],
            style: const TextStyle(color: Colors.white, fontSize: 13),
            underline: Container(),
            items: sortedVerses.map((v) => DropdownMenuItem(value: v, child: Text("వచనం $v"))).toList(),
            onChanged: (v) {
              setState(() => _currentVerse = v!);
              _itemScrollController.scrollTo(
                index: int.parse(v!) - 1,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOutCubic,
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Container(
        color: const Color(0xFFFFF9F0),
        child: ScrollablePositionedList.builder(
          itemCount: sortedVerses.length,
          itemScrollController: _itemScrollController,
          padding: const EdgeInsets.all(16),
          itemBuilder: (context, index) {
            String vNum = sortedVerses[index];
            bool isSelected = vNum == _currentVerse;

            return Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              color: isSelected ? Colors.brown.withOpacity(0.1) : Colors.transparent,
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(color: Colors.black87, fontSize: 20, height: 1.6),
                  children: [
                    TextSpan(
                      text: "$vNum. ",
                      style: TextStyle(
                        fontWeight: FontWeight.bold, 
                        color: isSelected ? Colors.red : Colors.brown
                      ),
                    ),
                    TextSpan(text: versesMap[vNum].toString().trim()),
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

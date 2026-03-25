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
      debugPrint("Error: $e");
    }
  }

  // నంబర్లను ఆర్డర్ లో పెట్టే ఫంక్షన్
  List<String> _getSortedKeys(Iterable<String> keys) {
    return keys.toList()..sort((a, b) => int.parse(a).compareTo(int.parse(b)));
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    // చాప్టర్లను నంబర్ల క్రమంలో సర్దుబాటు చేయడం
    List<String> sortedChapters = _getSortedKeys(_chapters.keys);
    
    // ప్రస్తుత చాప్టర్ లోని వచనాలను సర్దుబాటు చేయడం
    Map<String, dynamic> versesMap = _chapters[_currentChapter] ?? {};
    List<String> sortedVerses = _getSortedKeys(versesMap.keys);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.brown[800],
        foregroundColor: Colors.white,
        title: Text(widget.bookName, style: const TextStyle(fontSize: 18)),
        actions: [
          // చాప్టర్ సెలెక్షన్
          DropdownButton<String>(
            value: _currentChapter,
            dropdownColor: Colors.brown[900],
            style: const TextStyle(color: Colors.white),
            underline: Container(),
            items: sortedChapters.map((c) => DropdownMenuItem(value: c, child: Text("అధ్యాయం $c"))).toList(),
            onChanged: (v) {
              setState(() {
                _currentChapter = v!;
                _currentVerse = "1"; // చాప్టర్ మారితే వచనం 1 కి వెళ్లాలి
              });
            },
          ),
          const SizedBox(width: 10),
          // వచన సెలెక్షన్
          DropdownButton<String>(
            value: _currentVerse,
            dropdownColor: Colors.brown[900],
            style: const TextStyle(color: Colors.white),
            underline: Container(),
            items: sortedVerses.map((v) => DropdownMenuItem(value: v, child: Text("వచనం $v"))).toList(),
            onChanged: (v) {
              setState(() => _currentVerse = v!);
              // సెలెక్ట్ చేసిన వచనం దగ్గరికి స్క్రోల్ చేయడం
              _itemScrollController.scrollTo(
                index: int.parse(v!) - 1,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOutCubic,
              );
            },
          ),
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
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                // సెలెక్ట్ చేసిన వచనం హైలైట్ అవ్వడానికి
                color: isSelected ? Colors.brown.withOpacity(0.1) : Colors.transparent,
              ),
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(color: Colors.black87, fontSize: 20, height: 1.6),
                  children: [
                    TextSpan(
                      text: "$vNum. ",
                      style: TextStyle(
                        fontWeight: FontWeight.bold, 
                        color: isSelected ? Colors.red : Colors.brown,
                        fontSize: 18
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
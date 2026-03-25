import 'package:flutter/material.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
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

  // Cross References తెచ్చే లాజిక్
  void _showReferences(String vNum) async {
    showDialog(context: context, barrierDismissible: false, builder: (ctx) => const Center(child: CircularProgressIndicator()));

    try {
      String engBook = _service.getEngName(widget.bookName);
      // BibleSuperSearch API for Cross References
      final url = "https://api.biblesupersearch.com/v1/cross-references/$engBook/$_currentChapter/$vNum";
      final res = await http.get(Uri.parse(url));
      Navigator.pop(context); // Close loader

      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        List refs = data['results'] ?? [];

        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
          builder: (context) => Container(
            padding: const EdgeInsets.all(15),
            height: MediaQuery.of(context).size.height * 0.6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("${widget.bookName} $_currentChapter:$vNum - సంబంధిత వచనాలు", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.brown)),
                const Divider(),
                Expanded(
                  child: refs.isEmpty 
                  ? const Center(child: Text("రిఫరెన్సులు ఏమీ దొరకలేదు."))
                  : ListView.builder(
                      itemCount: refs.length,
                      itemBuilder: (context, i) {
                        String rBook = refs[i]['book'];
                        String rChap = refs[i]['chapter'].toString();
                        String rVerse = refs[i]['verse'].toString();
                        String rTelBook = _service.engToTel[rBook] ?? rBook;

                        return FutureBuilder<String>(
                          future: _service.getTeluguVerseText(rTelBook, rChap, rVerse),
                          builder: (context, snapshot) {
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text("$rTelBook $rChap:$rVerse", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                              subtitle: Text(snapshot.data ?? "లోడ్ అవుతోంది...", style: const TextStyle(fontSize: 16, color: Colors.black87)),
                            );
                          },
                        );
                      },
                    ),
                ),
              ],
            ),
          ),
        );
      }
    } catch (e) {
      Navigator.pop(context);
    }
  }

  List<String> _getSortedKeys(Iterable<String> keys) {
    return keys.toList()..sort((a, b) => int.parse(a).compareTo(int.parse(b)));
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

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
          // Chapter Dropdown
          DropdownButton<String>(
            value: _currentChapter,
            dropdownColor: Colors.brown[900],
            style: const TextStyle(color: Colors.white, fontSize: 13),
            underline: Container(),
            items: sortedChapters.map((c) => DropdownMenuItem(value: c, child: Text("అధ్యా. $c"))).toList(),
            onChanged: (v) => setState(() { _currentChapter = v!; _currentVerse = "1"; }),
          ),
          // Verse Dropdown
          DropdownButton<String>(
            value: _currentVerse,
            dropdownColor: Colors.brown[900],
            style: const TextStyle(color: Colors.white, fontSize: 13),
            underline: Container(),
            items: sortedVerses.map((v) => DropdownMenuItem(value: v, child: Text("వచనం $v"))).toList(),
            onChanged: (v) {
              setState(() => _currentVerse = v!);
              _itemScrollController.scrollTo(index: int.parse(v!) - 1, duration: const Duration(milliseconds: 500), curve: Curves.easeInOutCubic);
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
            return GestureDetector(
              onTap: () => _showReferences(vNum),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                color: isSelected ? Colors.brown.withOpacity(0.1) : Colors.transparent,
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(color: Colors.black87, fontSize: 20, height: 1.6),
                    children: [
                      TextSpan(text: "$vNum. ", style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? Colors.red : Colors.brown)),
                      TextSpan(text: versesMap[vNum].toString().trim()),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

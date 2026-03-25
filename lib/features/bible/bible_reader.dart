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

  // Cross References తెచ్చే ఫంక్షన్
  void _showReferences(String vNum) async {
    showModalBottomSheet(
      context: context,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      String engBook = _service.getEngName(widget.bookName);
      // Open Bible API వాడి రిఫరెన్సులు తెస్తున్నాం
      final url = "https://labs.bible.org/api/?passage=$engBook%20$_currentChapter:$vNum&type=json";
      final response = await http.get(Uri.parse(url));
      
      Navigator.pop(context); // Loading తీసేయడం

      if (response.statusCode == 200) {
        // ఇక్కడ రిఫరెన్స్ అడ్రెస్ లతో పాపప్ చూపిస్తాం
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (context) => Container(
            padding: const EdgeInsets.all(20),
            height: 400,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("${widget.bookName} $_currentChapter:$vNum - సంబంధిత వచనాలు", 
                     style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const Divider(),
                const Expanded(
                  child: Center(child: Text("ఈ వచనానికి సంబంధించిన మరిన్ని వివరాలు ఇక్కడ వస్తాయి.\n(గమనిక: ఈ API ప్రస్తుతం ఇంగ్లీష్ రిఫరెన్సులను ఇస్తుంది)")),
                )
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
        title: Text("${widget.bookName} $_currentChapter"),
        actions: [
          DropdownButton<String>(
            value: _currentChapter,
            dropdownColor: Colors.brown[900],
            style: const TextStyle(color: Colors.white),
            underline: Container(),
            items: sortedChapters.map((c) => DropdownMenuItem(value: c, child: Text("అధ్యాయం $c"))).toList(),
            onChanged: (v) => setState(() => _currentChapter = v!),
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
            return GestureDetector(
              onTap: () => _showReferences(vNum), // వచనం మీద క్లిక్ చేస్తే రిఫరెన్సులు కనిపిస్తాయి
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(color: Colors.black87, fontSize: 20, height: 1.6),
                    children: [
                      TextSpan(text: "$vNum. ", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.brown)),
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

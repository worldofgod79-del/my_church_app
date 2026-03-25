import 'package:flutter/material.dart';
import 'bible_service.dart';

class BibleReader extends StatefulWidget {
  final String bookName; // ఇప్పుడు ఇది String (పుస్తకం పేరు)
  const BibleReader({super.key, required this.bookName});

  @override
  State<BibleReader> createState() => _BibleReaderState();
}

class _BibleReaderState extends State<BibleReader> {
  final BibleService _service = BibleService();
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
      // ఫైల్ లోడ్ అవ్వకపోతే ఎర్రర్ చూపిస్తుంది
      debugPrint("Error loading bible: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    Map<String, dynamic> verses = _chapters[_currentChapter] ?? {};
    // వచనాలను నంబర్ల ప్రకారం ఆర్డర్ లో పెట్టడం
    var verseKeys = verses.keys.toList()..sort((a, b) => int.parse(a).compareTo(int.parse(b)));

    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.bookName} $_currentChapter"),
        backgroundColor: Colors.brown[800],
        foregroundColor: Colors.white,
        actions: [
          // అధ్యాయాలు మార్చుకోవడానికి Dropdown
          DropdownButton<String>(
            value: _currentChapter,
            dropdownColor: Colors.brown[700],
            style: const TextStyle(color: Colors.white),
            items: _chapters.keys.map((c) => DropdownMenuItem(value: c, child: Text("అధ్యాయం $c"))).toList(),
            onChanged: (v) => setState(() => _currentChapter = v!),
          )
        ],
      ),
      body: Container(
        color: const Color(0xFFFFF9F0),
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: verseKeys.length,
          itemBuilder: (context, index) {
            String vNum = verseKeys[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(color: Colors.black87, fontSize: 19, height: 1.5),
                  children: [
                    TextSpan(text: "$vNum. ", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.brown)),
                    TextSpan(text: verses[vNum].toString().trim()),
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
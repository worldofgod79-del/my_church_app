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
      debugPrint("Error loading bible: $e");
    }
  }

  // నంబర్ల క్రమంలో సర్దుబాటు చేసే ఫంక్షన్
  List<String> _getSortedKeys(Iterable<String> keys) {
    return keys.toList()..sort((a, b) => int.parse(a).compareTo(int.parse(b)));
  }

  // Cross References తెచ్చే ఫంక్షన్ (Internet API)
  void _showReferences(String vNum) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      String engBook = _service.getEngName(widget.bookName);
      // API నుండి రిఫరెన్సులను తెస్తున్నాం
      final url = "https://labs.bible.org/api/?passage=$engBook%20$_currentChapter:$vNum&type=json";
      final response = await http.get(Uri.parse(url));
      
      Navigator.pop(context); // Loading పాపప్ క్లోజ్ చేయడం

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
          builder: (context) => Container(
            padding: const EdgeInsets.all(20),
            height: MediaQuery.of(context).size.height * 0.5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("${widget.bookName} $_currentChapter:$vNum - సంబంధిత వచనాలు", 
                     style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.brown)),
                const Divider(),
                Expanded(
                  child: data.isEmpty 
                  ? const Center(child: Text("సమాచారం అందుబాటులో లేదు."))
                  : ListView.builder(
                      itemCount: data.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text("${data[index]['bookname']} ${data[index]['chapter']}:${data[index]['verse']}"),
                          subtitle: Text(data[index]['text']),
                        );
                      },
                    ),
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: Text("(గమనిక: ఈ రిఫరెన్సులు ప్రస్తుతం ఇంగ్లీష్ API నుండి వస్తున్నాయి)", 
                             style: TextStyle(fontSize: 10, fontStyle: FontStyle.italic)),
                )
              ],
            ),
          ),
        );
      }
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Internet Error!")));
    }
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
          // చాప్టర్ సెలెక్షన్ డ్రాప్‌డౌన్
          DropdownButton<String>(
            value: _currentChapter,
            dropdownColor: Colors.brown[900],
            style: const TextStyle(color: Colors.white, fontSize: 14),
            underline: Container(),
            items: sortedChapters.map((c) => DropdownMenuItem(value: c, child: Text("అధ్యాయం $c"))).toList(),
            onChanged: (v) {
              setState(() {
                _currentChapter = v!;
                _currentVerse = "1";
              });
            },
          ),
          const SizedBox(width: 5),
          // వచన సెలెక్షన్ డ్రాప్‌డౌన్ (ఇది నువ్వు అడిగింది)
          DropdownButton<String>(
            value: _currentVerse,
            dropdownColor: Colors.brown[900],
            style: const TextStyle(color: Colors.white, fontSize: 14),
            underline: Container(),
            items: sortedVerses.map((v) => DropdownMenuItem(value: v, child: Text("వచనం $v"))).toList(),
            onChanged: (v) {
              setState(() => _currentVerse = v!);
              // ఎంచుకున్న వచనం దగ్గరికి స్క్రోల్ చేయడం
              _itemScrollController.scrollTo(
                index: int.parse(v!) - 1,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOutCubic,
              );
            },
          ),
          const SizedBox(width: 10),
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
              onTap: () => _showReferences(vNum), // వచనం మీద క్లిక్ చేస్తే Cross References వస్తాయి
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                color: isSelected ? Colors.brown.withOpacity(0.1) : Colors.transparent,
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(color: Colors.black87, fontSize: 20, height: 1.6),
                    children: [
                      TextSpan(
                        text: "$vNum. ", 
                        style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? Colors.red : Colors.brown)
                      ),
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
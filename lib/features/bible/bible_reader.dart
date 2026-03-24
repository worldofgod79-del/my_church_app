import 'package:flutter/material.dart';
import 'bible_service.dart';

class BibleReader extends StatefulWidget {
  final int bookId; // 1 to 66
  const BibleReader({super.key, required this.bookId});

  @override
  State<BibleReader> createState() => _BibleReaderState();
}

class _BibleReaderState extends State<BibleReader> {
  final BibleService _service = BibleService();
  String _bookName = "";
  Map<String, dynamic> _chapters = {};
  String _selectedChapter = "1";
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  _loadData() async {
    final data = await _service.loadBookData(widget.bookId);
    setState(() {
      _bookName = data["name"];
      _chapters = data["chapters"];
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    // ప్రస్తుత అధ్యాయంలోని వచనాలు
    Map<String, dynamic> verses = _chapters[_selectedChapter] ?? {};
    List<String> verseKeys = verses.keys.toList()..sort((a, b) => int.parse(a).compareTo(int.parse(b)));

    return Scaffold(
      appBar: AppBar(
        title: Text("$_bookName $_selectedChapter"),
        backgroundColor: Colors.brown[800],
        foregroundColor: Colors.white,
        actions: [
          // అధ్యాయం మార్చుకోవడానికి Dropdown
          DropdownButton<String>(
            value: _selectedChapter,
            dropdownColor: Colors.brown[700],
            style: const TextStyle(color: Colors.white),
            items: _chapters.keys.map((String key) {
              return DropdownMenuItem<String>(value: key, child: Text("అధ్యాయం $key"));
            }).toList(),
            onChanged: (val) {
              if (val != null) setState(() => _selectedChapter = val);
            },
          ),
        ],
      ),
      body: Container(
        color: const Color(0xFFF5F5DC), // కంటికి హాయిగా ఉండే పేపర్ కలర్
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: verseKeys.length,
          itemBuilder: (context, index) {
            String vNum = verseKeys[index];
            String vText = verses[vNum].toString().trim(); // \n తీసేయడానికి trim()

            return Padding(
              padding: const EdgeInsets.only(bottom: 15.0),
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(color: Colors.black87, fontSize: 19, height: 1.5),
                  children: [
                    TextSpan(
                      text: "$vNum. ",
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.brown, fontSize: 16),
                    ),
                    TextSpan(text: vText),
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
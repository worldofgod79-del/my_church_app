import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'bible_service.dart';

class BibleSearch extends StatefulWidget {
  final String? initialBook;
  const BibleSearch({super.key, this.initialBook});

  @override
  State<BibleSearch> createState() => _BibleSearchState();
}

class _BibleSearchState extends State<BibleSearch> {
  final BibleService _service = BibleService();
  final TextEditingController _controller = TextEditingController();
  List<SearchResult> _allFound = [], _display =[];
  String _scope = "Full Bible";
  bool _searching = false;

  // Luminous Theme Colors (హోమ్ మరియు రీడర్ పేజీలకు మ్యాచ్ అయ్యేలా)
  final Color bgDark = const Color(0xFF0D1117);
  final Color cardDark = const Color(0xFF161B22);
  final Color accentCyan = const Color(0xFF00E5FF);
  final Color accentPurple = const Color(0xFFA78BFA);
  final Color txtPrimary = const Color(0xFFE6E8EA);

  void _search() async {
    if (_controller.text.trim().isEmpty) return;
    setState(() { _searching = true; _allFound = []; _display = []; });
    
    List<SearchResult> temp =[];
    for (var b in _service.bookNames) {
      try {
        var data = await _service.loadBook(b);
        (data['chapters'] as Map).forEach((cNum, verses) {
          (verses as Map).forEach((vNum, txt) {
            if (txt.toString().contains(_controller.text.trim())) {
              temp.add(SearchResult(b, cNum, vNum, txt.toString()));
            }
          });
        });
      } catch (_) {}
    }
    _allFound = temp; 
    _filter();
  }

  void _filter() {
    setState(() {
      if (_scope == "Full Bible") _display = _allFound;
      else if (_scope == "Old Testament") _display = _allFound.where((r) => _service.getOTBooks().contains(r.book)).toList();
      else if (_scope == "New Testament") _display = _allFound.where((r) => _service.getNTBooks().contains(r.book)).toList();
      else if (_scope == "This Book") _display = _allFound.where((r) => r.book == widget.initialBook).toList();
      _searching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgDark,
      appBar: AppBar(
        backgroundColor: bgDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white70, size: 20), 
          onPressed: () => context.pop()
        ),
        title: TextField(
          controller: _controller, 
          autofocus: true,
          style: TextStyle(color: txtPrimary, fontSize: 18),
          cursorColor: accentCyan,
          decoration: const InputDecoration(
            hintText: "వెతకండి (ఉదా: దేవుడు)...", 
            hintStyle: TextStyle(color: Colors.white30), 
            border: InputBorder.none
          ),
          onSubmitted: (_) => _search(),
        ),
        actions:[
          IconButton(icon: Icon(Icons.search, color: accentCyan), onPressed: _search)
        ],
      ),
      body: Column(
        children:[
          // Luminous Style Filter Pills
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
            child: Row(
              children:["Full Bible", "Old Testament", "New Testament", "This Book"].map((s) {
                if (s == "This Book" && widget.initialBook == null) return const SizedBox();
                bool isSelected = _scope == s;
                return GestureDetector(
                  onTap: () { setState(() => _scope = s); _filter(); },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? accentCyan.withOpacity(0.15) : cardDark,
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: isSelected ? accentCyan : Colors.white.withOpacity(0.05)),
                    ),
                    child: Text(s, style: TextStyle(
                      color: isSelected ? accentCyan : Colors.white60, 
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 14
                    )),
                  ),
                );
              }).toList(),
            ),
          ),
          
          if (_searching) LinearProgressIndicator(color: accentCyan, backgroundColor: cardDark),
          
          // Search Results
          Expanded(
            child: _display.isEmpty && !_searching
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children:[
                      Icon(Icons.manage_search_rounded, size: 80, color: Colors.white.withOpacity(0.05)),
                      const SizedBox(height: 15),
                      const Text("ఫలితాలు లేవు", style: TextStyle(color: Colors.white30, fontSize: 16)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  itemCount: _display.length,
                  itemBuilder: (context, i) {
                    final r = _display[i];
                    return InkWell(
                      onTap: () => context.push('/bible-reader/${r.book}?chapter=${r.chapter}&verse=${r.verse}'),
                      borderRadius: BorderRadius.circular(15),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                        decoration: BoxDecoration(
                          color: cardDark,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Colors.white.withOpacity(0.03)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children:[
                            // Book, Chapter, Verse in Neon Purple
                            Text("${r.book} ${r.chapter}:${r.verse}", 
                              style: TextStyle(color: accentPurple, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1)
                            ),
                            const SizedBox(height: 8),
                            // Verse text in Light Grey
                            Text(r.text, 
                              maxLines: 3, 
                              overflow: TextOverflow.ellipsis, 
                              style: TextStyle(color: txtPrimary, fontSize: 16, height: 1.5)
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                ),
          ),
        ],
      ),
    );
  }
}
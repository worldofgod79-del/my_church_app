// class BibleReader లో...
final String? initialChapter;
final String? initialVerse;
const BibleReader({super.key, required this.bookName, this.initialChapter, this.initialVerse});

// _load ఫంక్షన్ చివర్లో...
setState(() {
  if (widget.initialChapter != null) _currentChapter = widget.initialChapter!;
  if (widget.initialVerse != null) _currentVerse = widget.initialVerse!;
  _chapters = data["chapters"];
  _loading = false;
});

// పెయింటింగ్ అయ్యాక స్క్రోల్ చేయడానికి...
WidgetsBinding.instance.addPostFrameCallback((_) {
  if (widget.initialVerse != null) {
    _itemScrollController.jumpTo(index: int.parse(widget.initialVerse!) - 1);
  }
});

// AppBar లో సెర్చ్ ఐకాన్
actions: [
  IconButton(icon: const Icon(Icons.search), onPressed: () => context.push('/search?book=${widget.bookName}')),
  // మిగతా డ్రాప్‌డౌన్లు...
]

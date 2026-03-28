import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'github_service.dart';

class AdminBooksScreen extends StatefulWidget {
  const AdminBooksScreen({super.key});
  @override
  State<AdminBooksScreen> createState() => _AdminBooksScreenState();
}

class _AdminBooksScreenState extends State<AdminBooksScreen> {
  final GitHubService _github = GitHubService();
  bool _isLoading = true;
  List<dynamic> _books = [];
  String? _fileSha;
  final String filePath = "assets/data/books.json";

  @override
  void initState() { super.initState(); _loadBooks(); }

  _loadBooks() async {
    setState(() => _isLoading = true);
    try {
      final data = await _github.getFile(filePath);
      setState(() {
        _fileSha = data['sha'];
        _books = (data['content'] is List) ? List.from(data['content']) : [];
        _isLoading = false;
      });
    } catch (e) { setState(() => _isLoading = false); }
  }

  void _showBookForm({Map<String, dynamic>? existingBook, int? index}) {
    TextEditingController titleCtrl = TextEditingController(text: existingBook?['title'] ?? '');
    TextEditingController authorCtrl = TextEditingController(text: existingBook?['author'] ?? '');
    TextEditingController pdfCtrl = TextEditingController(text: existingBook?['pdfUrl'] ?? '');
    TextEditingController coverCtrl = TextEditingController(text: existingBook?['coverUrl'] ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF161B22),
        title: Text(existingBook == null ? "Add New Book" : "Edit Book", style: const TextStyle(color: Colors.white)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _input(titleCtrl, "Book Title"),
              const SizedBox(height: 10),
              _input(authorCtrl, "Author Name"),
              const SizedBox(height: 10),
              _input(pdfCtrl, "PDF Direct Link"),
              const SizedBox(height: 10),
              _input(coverCtrl, "Cover Image URL"),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              Map<String, dynamic> newBook = {
                "id": existingBook?['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
                "title": titleCtrl.text,
                "author": authorCtrl.text,
                "pdfUrl": pdfCtrl.text,
                "coverUrl": coverCtrl.text,
              };
              if (index != null) _books[index] = newBook; else _books.add(newBook);
              Navigator.pop(context);
              _github.updateFile(filePath, "Updated Books", _books, _fileSha).then((_) => _loadBooks());
            },
            child: const Text("Save"),
          )
        ],
      ),
    );
  }

  Widget _input(TextEditingController ctrl, String hint) {
    return TextField(controller: ctrl, style: const TextStyle(color: Colors.white), decoration: InputDecoration(hintText: hint, filled: true, fillColor: Colors.black26));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(backgroundColor: const Color(0xFF161B22), title: const Text("Manage Books"), actions: [IconButton(icon: const Icon(Icons.add), onPressed: () => _showBookForm())]),
      body: _isLoading ? const Center(child: CircularProgressIndicator()) : ListView.builder(
        itemCount: _books.length,
        itemBuilder: (context, i) => ListTile(
          leading: Image.network(_books[i]['coverUrl'], width: 50, errorBuilder: (_, __, ___) => const Icon(Icons.book)),
          title: Text(_books[i]['title'], style: const TextStyle(color: Colors.white)),
          subtitle: Text(_books[i]['author'], style: const TextStyle(color: Colors.white54)),
          trailing: IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () {
            setState(() => _books.removeAt(i));
            _github.updateFile(filePath, "Deleted Book", _books, _fileSha).then((_) => _loadBooks());
          }),
        ),
      ),
    );
  }
}
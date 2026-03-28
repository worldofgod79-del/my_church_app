import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:go_router/go_router.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class BooksHome extends StatefulWidget {
  const BooksHome({super.key});
  @override
  State<BooksHome> createState() => _BooksHomeState();
}

class _BooksHomeState extends State<BooksHome> {
  List<dynamic> _books = [];
  bool _isLoading = true;

  // GitHub నుండి లైవ్ బుక్స్ డేటాని తెచ్చే URL
  final String dataUrl = "https://api.github.com/repos/worldofgod79-del/my_church_app/contents/assets/data/books.json";

  @override
  void initState() {
    super.initState();
    _fetchBooks();
  }

  Future<void> _fetchBooks() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.get(Uri.parse(dataUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        String content = utf8.decode(base64.decode(data['content'].replaceAll('\n', '').trim()));
        setState(() {
          _books = json.decode(content);
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050505), // Pure Dark
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20), onPressed: () => context.go('/home')),
        title: const Text("BOOKS LIBRARY", style: TextStyle(letterSpacing: 3, fontWeight: FontWeight.w200, color: Colors.white)),
        centerTitle: true,
        actions: [IconButton(icon: const Icon(Icons.refresh, color: Color(0xFF00D2FF)), onPressed: _fetchBooks)],
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: Color(0xFF00D2FF)))
        : _books.isEmpty 
          ? const Center(child: Text("No Books Available Yet", style: TextStyle(color: Colors.white38)))
          : GridView.builder(
              padding: const EdgeInsets.all(20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, mainAxisSpacing: 25, crossAxisSpacing: 20, childAspectRatio: 0.65
              ),
              itemCount: _books.length,
              itemBuilder: (context, i) {
                var book = _books[i];
                return InkWell(
                  onTap: () => context.push('/pdf-reader', extra: {'url': book['pdfUrl'], 'title': book['title']}),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Book Cover with Glass effect
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: Colors.white.withOpacity(0.05)),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 15)],
                            image: DecorationImage(image: NetworkImage(book['coverUrl']), fit: BoxFit.cover),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(book['title'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15), maxLines: 1, overflow: TextOverflow.ellipsis),
                      Text(book['author'] ?? 'WOG Author', style: const TextStyle(color: Colors.white38, fontSize: 12)),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

// PDF Reader Screen (The Reader itself)
class PDFReaderScreen extends StatelessWidget {
  final String url;
  final String title;
  const PDFReaderScreen({super.key, required this.url, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(title, style: const TextStyle(fontSize: 16)),
        leading: IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
      ),
      body: SfPdfViewer.network(
        url,
        onDocumentLoadFailed: (details) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: ${details.description}")));
        },
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../music/music_service.dart'; // We use the same fetch logic

class BooksHome extends StatefulWidget {
  const BooksHome({super.key});
  @override
  State<BooksHome> createState() => _BooksHomeState();
}

class _BooksHomeState extends State<BooksHome> {
  List<dynamic> _books = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  _fetch() async {
    // మనం ఆల్బమ్స్ కోసం వాడినట్టే ఒక సర్వీస్ వాడతాం (కానీ ఫైల్ పాత్ books.json కి మారుస్తాం)
    // ప్రస్తుతానికి ఇక్కడ డైరెక్ట్ గా కోడ్ ఇస్తున్నాను
    // (MusicService లాగే ఇంకోటి క్రియేట్ చేయాలి లేదా MusicService ని Generalize చేయాలి)
  }

  @override
  Widget build(BuildContext context) {
    // UI code similar to Music Home (Grid of Book Cards)
    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      appBar: AppBar(backgroundColor: Colors.transparent, title: const Text("BOOKS LIBRARY")),
      body: const Center(child: Text("Books will appear here in Grid Style")),
    );
  }
}

// PDF చదివే స్క్రీన్
class PDFReaderScreen extends StatelessWidget {
  final String url;
  final String title;
  const PDFReaderScreen({super.key, required this.url, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title), backgroundColor: Colors.black),
      body: SfPdfViewer.network(url),
    );
  }
}
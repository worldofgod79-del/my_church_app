import 'package:flutter/services.dart';
import 'package:xml/xml.dart';

class BibleService {
  static Map<String, Map<String, dynamic>>? _bibleCache;

  final List<String> bookNames =[
    "ఆదికాండము", "నిర్గమకాండము", "లేవీయకాండము", "సంఖ్యాకాండము", "ద్వితీయోపదేశకాండము",
    "యెహోషువ", "న్యాయాధిపతులు", "రూతు", "1సమూయేలు", "2సమూయేలు",
    "1రాజులు", "2రాజులు", "1దినవృత్తాంతములు", "2దినవృత్తాంతములు", "ఎజ్రా",
    "నెహెమ్యా", "ఎస్తేరు", "యోబు", "కీర్తనలు", "సామెతలు",
    "ప్రసంగి", "పరమగీతము", "యెషయా", "యిర్మీయా", "విలాపవాక్యములు",
    "యెహెజ్కేలు", "దానియేలు", "హోషేయ", "యోవేలు", "ఆమోసు",
    "ఓబద్యా", "యోనా", "మీకా", "నహూము", "హబక్కూకు",
    "జెఫన్యా", "హగ్గయి", "జకర్యా", "మలాకీ", "మత్తయి",
    "మార్కు", "లూకా", "యోహాను", "అపో.కార్యములు", "రోమీయులకు",
    "1కొరింథీయులకు", "2కొరింథీయులకు", "గలతీయులకు", "ఎఫెసీయులకు", "ఫిలిప్పీయులకు",
    "కొలొస్సయులకు", "1థెస్సలొనీకయులకు", "2థెస్సలొనీకయులకు", "1తిమోతికి", "2తిమోతికి",
    "తీతుకు", "ఫిలేమోనుకు", "హెబ్రీయులకు", "యాకోబు", "1పేతురు",
    "2పేతురు", "1యోహాను", "2యోహాను", "3యోహాను", "యూదా", "ప్రకటన గ్రంథం"
  ];

  List<String> getOTBooks() => bookNames.sublist(0, 39);
  List<String> getNTBooks() => bookNames.sublist(39);

  Future<void> _loadXMLOnce() async {
    if (_bibleCache != null) return;
    
    try {
      final String rawXml = await rootBundle.loadString('assets/bible.xml');
      final document = XmlDocument.parse(rawXml);
      Map<String, Map<String, dynamic>> tempCache = {};
      
      for (var bookNode in document.findAllElements('BIBLEBOOK')) {
        String? bnumber = bookNode.getAttribute('bnumber');
        if (bnumber == null || bnumber.isEmpty) continue;
        
        int bIndex = int.parse(bnumber) - 1;
        if (bIndex < 0 || bIndex >= bookNames.length) continue;
        
        String teluguBookName = bookNames[bIndex];
        Map<String, dynamic> chaptersMap = {};
        
        for (var chapterNode in bookNode.findAllElements('CHAPTER')) {
          String? cnumber = chapterNode.getAttribute('cnumber');
          if (cnumber == null) continue;
          
          Map<String, String> versesMap = {};
          for (var versNode in chapterNode.findAllElements('VERS')) {
            String? vnumber = versNode.getAttribute('vnumber');
            if (vnumber != null) {
              versesMap[vnumber] = versNode.innerText.trim();
            }
          }
          chaptersMap[cnumber] = versesMap;
        }
        
        tempCache[teluguBookName] = {
          "name": teluguBookName,
          "chapters": chaptersMap
        };
      }
      _bibleCache = tempCache;
    } catch (e) {
      throw Exception("XML Error: దయచేసి 'assets/bible.xml' ఫైల్ ఉందో లేదో చెక్ చేయండి. \nవివరాలు: $e");
    }
  }

  Future<Map<String, dynamic>> loadBook(String bookName) async {
    await _loadXMLOnce();
    if (_bibleCache!.containsKey(bookName)) {
      return _bibleCache![bookName]!;
    } else {
      throw Exception("ఈ పుస్తకం దొరకలేదు: $bookName");
    }
  }
}

class SearchResult {
  final String book, chapter, verse, text;
  SearchResult(this.book, this.chapter, this.verse, this.text);
}

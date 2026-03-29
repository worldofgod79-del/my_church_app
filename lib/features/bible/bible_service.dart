import 'package:flutter/services.dart';
import 'package:xml/xml.dart';

class BibleService {
  static Map<String, Map<String, dynamic>>? _bibleCache;
  // వచనానికి ID ని స్టోర్ చేయడానికి Map (Key: "Book_Chap_Verse")
  static Map<String, int>? _verseIdMap;

  final List<String> bookNames = [
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

  final Map<String, String> engToTelMapping = {
    "GEN": "ఆదికాండము", "EXO": "నిర్గమకాండము", "LEV": "లేవీయకాండము", "NUM": "సంఖ్యాకాండము", "DEU": "ద్వితీయోపదేశకాండము",
    "JOS": "యెహోషువ", "JDG": "న్యాయాధిపతులు", "RUT": "రూతు", "1SA": "1సమూయేలు", "2SA": "2సమూయేలు",
    "1KI": "1రాజులు", "2KI": "2రాజులు", "1CH": "1దినవృత్తాంతములు", "2CH": "2దినవృత్తాంతములు", "EZR": "ఎజ్రా",
    "NEH": "నెహెమ్యా", "EST": "ఎస్తేరు", "JOB": "యోబు", "PSA": "కీర్తనలు", "PRO": "సామెతలు",
    "ECC": "ప్రసంగి", "SNG": "పరమగీతము", "ISA": "యెషయా", "JER": "యిర్మీయా", "LAM": "విలాపవాక్యములు",
    "EZK": "యెహెజ్కేలు", "DAN": "దానియేలు", "HOS": "హోషేయ", "JOL": "యోవేలు", "AMO": "ఆమోసు",
    "OBA": "ఓబద్యా", "JON": "యోనా", "MIC": "మీకా", "NAH": "నహూము", "HAB": "హబక్కూకు",
    "ZEP": "జెఫన్యా", "HAG": "హగ్గయి", "ZEC": "జకర్యా", "MAL": "మలాకీ", "MAT": "మత్తయి",
    "MRK": "మార్కు", "LUK": "లూకా", "JOH": "యోహాను", "ACT": "అపో.కార్యములు", "ROM": "రోమీయులకు",
    "1CO": "1కొరింథీయులకు", "2CO": "2కొరింథీయులకు", "GAL": "గలతీయులకు", "EPH": "ఎఫెసీయులకు", "PHP": "ఫిలిప్పీయులకు",
    "COL": "కొలొస్సయులకు", "1TH": "1థెస్సలొనీకయులకు", "2TH": "2థెస్సలొనీకయులకు", "1TI": "1తిమోతికి", "2TI": "2తిమోతికి",
    "TIT": "తీతుకు", "PHM": "ఫిలేమోనుకు", "HEB": "హెబ్రీయులకు", "JAS": "యాకోబు", "1PE": "1పేతురు",
    "2PE": "2పేతురు", "1JO": "1యోహాను", "2JO": "2యోహాను", "3JO": "3యోహాను", "JUD": "యూదా", "REV": "ప్రకటన గ్రంథం"
  };

  List<String> getOTBooks() => bookNames.sublist(0, 39);
  List<String> getNTBooks() => bookNames.sublist(39);

  Future<void> _loadXMLOnce() async {
    if (_bibleCache != null) return;
    _bibleCache = {};
    _verseIdMap = {};
    int globalIdCounter = 1; // 1 నుండి స్టార్ట్ అవుతుంది

    try {
      final String rawXml = await rootBundle.loadString('assets/bible.xml');
      final document = XmlDocument.parse(rawXml);
      
      for (var bookNode in document.findAllElements('BIBLEBOOK')) {
        int bNum = int.parse(bookNode.getAttribute('bnumber')!);
        String telBookName = bookNames[bNum - 1];
        Map<String, dynamic> chaptersMap = {};

        for (var chapterNode in bookNode.findAllElements('CHAPTER')) {
          String cNum = chapterNode.getAttribute('cnumber')!;
          Map<String, String> versesMap = {};

          for (var versNode in chapterNode.findAllElements('VERS')) {
            String vNum = versNode.getAttribute('vnumber')!;
            versesMap[vNum] = versNode.innerText.trim();
            
            // Map ID: "ఆదికాండము_1_1" -> 1
            _verseIdMap!["${telBookName}_${cNum}_$vNum"] = globalIdCounter;
            globalIdCounter++;
          }
          chaptersMap[cNum] = versesMap;
        }
        _bibleCache![telBookName] = {"name": telBookName, "chapters": chaptersMap};
      }
    } catch (e) {
      throw Exception("XML Error: $e");
    }
  }

  Future<Map<String, dynamic>> loadBook(String bookName) async {
    await _loadXMLOnce();
    return _bibleCache![bookName] ?? {};
  }

  // వచనం యొక్క Global ID తెచ్చే ఫంక్షన్
  int getGlobalId(String b, String c, String v) {
    return _verseIdMap?["${b}_${c}_$v"] ?? 0;
  }
}

class SearchResult {
  final String book, chapter, verse, text;
  SearchResult(this.book, this.chapter, this.verse, this.text);
}
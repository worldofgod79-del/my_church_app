import 'package:flutter/services.dart';
import 'package:xml/xml.dart';

class BibleService {
  static Map<String, Map<String, dynamic>>? _bibleCache;

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

  // క్రాస్ రిఫరెన్స్ నావిగేషన్ కోసం Mapping
  final Map<String, String> engToTelMapping = {
    "Gen": "ఆదికాండము", "Exo": "నిర్గమకాండము", "Lev": "లేవీయకాండము", "Num": "సంఖ్యాకాండము", "Deu": "ద్వితీయోపదేశకాండము",
    "Jos": "యెహోషువ", "Jud": "న్యాయాధిపతులు", "Rut": "రూతు", "1Sa": "1సమూయేలు", "2Sa": "2సమూయేలు",
    "1Ki": "1రాజులు", "2Ki": "2రాజులు", "1Ch": "1దినవృత్తాంతములు", "2Ch": "2దినవృత్తాంతములు", "Ezr": "ఎజ్రా",
    "Neh": "నెహెమ్యా", "Est": "ఎస్తేరు", "Job": "యోబు", "Psa": "కీర్తనలు", "Pro": "సామెతలు",
    "Ecc": "ప్రసంగి", "Son": "పరమగీతము", "Isa": "యెషయా", "Jer": "యిర్మీయా", "Lam": "విలాపవాక్యములు",
    "Eze": "యెహెజ్కేలు", "Dan": "దానియేలు", "Hos": "హోషేయ", "Joe": "యోవేలు", "Amo": "ఆమోసు",
    "Oba": "ఓబద్యా", "Jon": "యోనా", "Mic": "మీకా", "Nah": "నహూము", "Hab": "హబక్కూకు",
    "Zep": "జెఫన్యా", "Hag": "హగ్గయి", "Zec": "జకర్యా", "Mal": "మలాకీ", "Mat": "మత్తయి",
    "Mar": "మార్కు", "Luk": "లూకా", "Joh": "యోహాను", "Act": "అపో.కార్యములు", "Rom": "రోమీయులకు",
    "1Co": "1కొరింథీయులకు", "2Co": "2కొరింథీయులకు", "Gal": "గలతీయులకు", "Eph": "ఎఫెసీయులకు", "Phi": "ఫిలిప్పీయులకు",
    "Col": "కొలొస్సయులకు", "1Th": "1థెస్సలొనీకయులకు", "2Th": "2థెస్సలొనీకయులకు", "1Ti": "1తిమోతికి", "2Ti": "2తిమోతికి",
    "Tit": "తీతుకు", "Phm": "ఫిలేమోనుకు", "Heb": "హెబ్రీయులకు", "Jam": "యాకోబు", "1Pe": "1పేతురు",
    "2Pe": "2పేతురు", "1Jo": "1యోహాను", "2Jo": "2యోహాను", "3Jo": "3యోహాను", "Jud": "యూదా", "Rev": "ప్రకటన గ్రంథం"
  };

  List<String> getOTBooks() => bookNames.sublist(0, 39);
  List<String> getNTBooks() => bookNames.sublist(39);

  Future<void> _loadXMLOnce() async {
    if (_bibleCache != null) return;
    try {
      final String rawXml = await rootBundle.loadString('assets/bible.xml');
      final document = XmlDocument.parse(rawXml);
      Map<String, Map<String, dynamic>> tempCache = {};
      for (var bookNode in document.findAllElements('BIBLEBOOK')) {
        String bnumber = bookNode.getAttribute('bnumber') ?? "";
        int bIndex = int.parse(bnumber) - 1;
        String teluguBookName = bookNames[bIndex];
        Map<String, dynamic> chaptersMap = {};
        for (var chapterNode in bookNode.findAllElements('CHAPTER')) {
          String cnumber = chapterNode.getAttribute('cnumber')!;
          Map<String, String> versesMap = {};
          for (var versNode in chapterNode.findAllElements('VERS')) {
            versesMap[versNode.getAttribute('vnumber')!] = versNode.innerText.trim();
          }
          chaptersMap[cnumber] = versesMap;
        }
        tempCache[teluguBookName] = {"name": teluguBookName, "chapters": chaptersMap};
      }
      _bibleCache = tempCache;
    } catch (e) {
      throw Exception("XML Error: $e");
    }
  }

  Future<Map<String, dynamic>> loadBook(String bookName) async {
    await _loadXMLOnce();
    return _bibleCache![bookName] ?? {};
  }
}

class SearchResult {
  final String book, chapter, verse, text;
  SearchResult(this.book, this.chapter, this.verse, this.text);
}

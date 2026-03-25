import 'dart:convert';
import 'package:flutter/services.dart';

class BibleService {
  Future<Map<String, dynamic>> loadBook(String bookName) async {
    final String response = await rootBundle.loadString('assets/bible_json/$bookName.json');
    final Map<String, dynamic> data = json.decode(response);
    String keyInJson = data.keys.first;
    return {"name": keyInJson, "chapters": data[keyInJson]};
  }

  // రిఫరెన్స్ నుండి తెలుగు వచనాన్ని తీయడానికి చిన్న ఫంక్షన్
  Future<String> getTeluguVerseText(String telBook, String chap, String verse) async {
    try {
      final String response = await rootBundle.loadString('assets/bible_json/$telBook.json');
      final Map<String, dynamic> data = json.decode(response);
      String key = data.keys.first;
      return data[key][chap][verse].toString().trim();
    } catch (e) {
      return "";
    }
  }

  // English API Names to your Telugu JSON Filenames
  final Map<String, String> engToTel = {
    "Genesis": "ఆదికాండము", "Exodus": "నిర్గమకాండము", "Leviticus": "లేవీయకాండము",
    "Numbers": "సంఖ్యాకాండము", "Deuteronomy": "ద్వితీయోపదేశకాండము", "Joshua": "యెహోషువ",
    "Judges": "న్యాయాధిపతులు", "Ruth": "రూతు", "1 Samuel": "1సమూయేలు", "2 Samuel": "2సమూయేలు",
    "1 Kings": "1రాజులు", "2 Kings": "2రాజులు", "1 Chronicles": "1దినవృత్తాంతములు",
    "2 Chronicles": "2దినవృత్తాంతములు", "Ezra": "ఎజ్రా", "Nehemiah": "నెహెమ్యా",
    "Esther": "ఎస్తేరు", "Job": "యోబు", "Psalms": "కీర్తనలు", "Proverbs": "సామెతలు",
    "Ecclesiastes": "ప్రసంగి", "Song of Solomon": "పరమగీతము", "Isaiah": "యెషయా",
    "Jeremiah": "యిర్మీయా", "Lamentations": "విలాపవాక్యములు", "Ezekiel": "యెహెజ్కేలు",
    "Daniel": "దానియేలు", "Hosea": "హోషేయ", "Joel": "యోవేలు", "Amos": "ఆమోసు",
    "Obadiah": "ఓబద్యా", "Jonah": "యోనా", "Micah": "మీకా", "Nahum": "నహూము",
    "Habakkuk": "హబక్కూకు", "Zephaniah": "జెఫన్యా", "Haggai": "హగ్గయి", "Zechariah": "జకర్యా",
    "Malachi": "మలాకీ", "Matthew": "మత్తయి", "Mark": "మార్కు", "Luke": "లూకా",
    "John": "యోహాను", "Acts": "అపో.కార్యములు", "Romans": "రోమీయులకు",
    "1 Corinthians": "1కోరింథీయులకు", "2 Corinthians": "2కోరింథీయులకు", "Galatians": "గలతీయులకు",
    "Ephesians": "ఎఫెసీయులకు", "Philippians": "フィリピ", "Colossians": "కొలొస్సయులకు",
    "1 Thessalonians": "1థెస్సలొనీకయులకు", "2 Thessalonians": "2థెస్సలొనీకయులకు",
    "1 Timothy": "1తిమోతికి", "2 Timothy": "2తిమోతికి", "Titus": "తీతుకు",
    "Philemon": "ఫిలేమోనుకు", "Hebrews": "హెబ్రీయులకు", "James": "యాకోబు",
    "1 Peter": "1పేతురు", "2 Peter": "2పేతురు", "1 John": "1యోహాను", "2 John": "2యోహాను",
    "3 John": "3యోహాను", "Jude": "యూదా", "Revelation": "ప్రకటన గ్రంథం"
  };

  String getEngName(String telName) {
    return engToTel.entries.firstWhere((e) => e.value == telName, orElse: () => engToTel.entries.first).key;
  }

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
    "1కోరింథీయులకు", "2కోరింథీయులకు", "గలతీయులకు", "ఎఫెసీయులకు", "ఫిలిప్పీయులకు",
    "కొలొస్సయులకు", "1థెస్సలొనీకయులకు", "2థెస్సలొనీకయులకు", "1తిమోతికి", "2తిమోతికి",
    "తీతుకు", "ఫిలేమోనుకు", "హెబ్రీయులకు", "యాకోబు", "1పేతురు",
    "2పేతురు", "1యోహాను", "2యోహాను", "3యోహాను", "యూదా", "ప్రకటన గ్రంథం"
  ];
}

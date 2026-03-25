import 'dart:convert';
import 'package:flutter/services.dart';

class BibleService {
  Future<Map<String, dynamic>> loadBook(String bookName) async {
    final String response = await rootBundle.loadString('assets/bible_json/$bookName.json');
    final Map<String, dynamic> data = json.decode(response);
    String keyInJson = data.keys.first;
    return {"name": keyInJson, "chapters": data[keyInJson]};
  }

  // పాత నిబంధన (1-39 పుస్తకాలు)
  List<String> getOT() => bookNames.sublist(0, 39);

  // క్రొత్త నిబంధన (40-66 పుస్తకాలు)
  List<String> getNT() => bookNames.sublist(39);

  final List<String> bookNames = [
    "ఆదికాండము", "నిర్గమకాండము", "లేవీయకాండము", "సంఖ్యాకాండము", "ద్వితీయోపదేశకాండము",
    "యెహోషువ", "న్యాయాధిపతులు", "రూతు", "1సమూయేలు", "2సమూయేలు",
    "1రాజులు", "2రాజులు", "1దినవృత్తాంతములు", "2దినవృత్తాంతములు", "ఎజ్రా",
    "నెహెమ్యా", "ఎస్తేరు", "యోబు", "కీర్తనలు", "సామెతలు",
    "ప్రసంగి", "పరమగీతము", "యెషయా", "యిర్మీయా", "విలాపవాక్యములు",
    "యెహెజ్కేలు", "దానియేలు", "హోషేయ", "యోవేలు", "ఆమోసు",
    "ఓబద్యా", "యోనా", "మీకా", "నహూము", "హబక్కూకు",
    "జెఫンయా", "హగ్గయి", "జకర్యా", "మలాకీ", "మత్తయి",
    "మార్కు", "లూకా", "యోహాను", "అపో.కార్యములు", "రోమీయులకు",
    "1కొరింథీయులకు", "2కొరింథీయులకు", "గలతీయులకు", "ఎఫెసీయులకు", "ఫిలిప్పీయులకు",
    "కొలొస్సయులకు", "1థెస్సలొనీకయులకు", "2థెస్సలొనీకయులకు", "1తిమోతికి", "2తిమోతికి",
    "తీతుకు", "ఫిలేమోనుకు", "హెబ్రీయులకు", "యాకోబు", "1పేతురు",
    "2పేతురు", "1యోహాను", "2యోహాను", "3యోహాను", "యూదా", "ప్రకటన గ్రంథం"
  ];
}

class SearchResult {
  final String book, chapter, verse, text;
  SearchResult(this.book, this.chapter, this.verse, this.text);
}
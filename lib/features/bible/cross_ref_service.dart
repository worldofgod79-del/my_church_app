import 'dart:convert';
import 'package:flutter/services.dart';

class CrossRefService {
  // క్రాస్ రిఫరెన్స్ ఫైల్ ని లోడ్ చేస్తుంది
  Future<Map<String, dynamic>?> getReferences(String bookName) async {
    try {
      final String response = await rootBundle.loadString('assets/cross_refs/$bookName.json');
      return json.decode(response);
    } catch (e) {
      return null; // ఫైల్ లేకపోతే ఖాళీగా వదిలేస్తుంది
    }
  }
}

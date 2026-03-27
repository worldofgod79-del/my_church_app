import 'dart:convert';
import 'package:http/http.dart' as http;

class MusicService {
  // ఇది నీ గిట్‌హబ్ లోని albums.json ఫైల్ యొక్క "Raw" లింక్ (దీని వల్ల లైవ్ అప్‌డేట్స్ వస్తాయి)
  final String rawUrl = "https://raw.githubusercontent.com/worldofgod79-del/my_church_app/main/assets/data/albums.json";

  Future<List<dynamic>> getLiveAlbums() async {
    try {
      // ఇంటర్నెట్ నుండి నేరుగా ఫైల్ చదవడం
      final response = await http.get(Uri.parse(rawUrl));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return [];
    } catch (e) {
      return[]; // నెట్ లేకపోతే లేదా ఫైల్ లేకపోతే ఖాళీ లిస్ట్ ఇస్తుంది
    }
  }
}

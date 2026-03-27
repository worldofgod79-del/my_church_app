import 'dart:convert';
import 'package:http/http.dart' as http;

class MusicService {
  final String owner = "worldofgod79-del";
  final String repo = "my_church_app";
  final String filePath = "assets/data/albums.json";

  Future<List<dynamic>> getLiveAlbums() async {
    // CDN కి బదులుగా నేరుగా GitHub API ని వాడుతున్నాం (Real-time)
    final url = Uri.parse("https://api.github.com/repos/$owner/$repo/contents/$filePath");
    
    try {
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // గిట్‌హబ్ పంపే బేస్64 డేటాని నార్మల్ టెక్స్ట్ గా మార్చడం
        String base64Content = data['content'].replaceAll('\n', '').trim();
        String decodedString = utf8.decode(base64.decode(base64Content));
        return json.decode(decodedString);
      } else {
        print("GitHub API Error: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("Fetch Error: $e");
      return [];
    }
  }
}

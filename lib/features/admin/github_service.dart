import 'dart:convert';
import 'package:http/http.dart' as http;

class GitHubService {
  // నీ గిట్‌హబ్ వివరాలు ఇక్కడ ఇవ్వాలి
  final String owner = "worldofgod79-del"; // నీ గిట్‌హబ్ యూజర్ నేమ్
  final String repo = "my_church_app";     // నీ రిపోజిటరీ పేరు
  
  // ఇది చాలా ముఖ్యం! గిట్‌హబ్ లో టోకెన్ ఎలా క్రియేట్ చేయాలో కింద చెప్తాను. 
  // ఆ టోకెన్ ని ఇక్కడ పెట్టాలి.
  final String token = "నీ_GITHUB_PERSONAL_ACCESS_TOKEN_ఇక్కడ_పెట్టు";

  // గిట్‌హబ్ నుండి ఫైల్ (JSON) చదవడం
  Future<Map<String, dynamic>> getFile(String filePath) async {
    final url = "https://api.github.com/repos/$owner/$repo/contents/$filePath";
    final response = await http.get(
      Uri.parse(url),
      headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/vnd.github+json"
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      // గిట్‌హబ్ డేటాని Base64 ఫార్మాట్ లో ఇస్తుంది, దాన్ని నార్మల్ టెక్స్ట్ గా మార్చాలి
      String content = utf8.decode(base64.decode(data['content'].replaceAll('\n', '')));
      return {
        "sha": data['sha'], // ఫైల్ ని అప్‌డేట్ చేయడానికి ఈ 'sha' కోడ్ కావాలి
        "content": json.decode(content)
      };
    } else if (response.statusCode == 404) {
      // ఫైల్ లేకపోతే ఖాళీ డేటా ఇస్తాం
      return {"sha": null, "content":[]};
    } else {
      throw Exception("Failed to load file from GitHub");
    }
  }

  // గిట్‌హబ్ లో ఫైల్ ని అప్‌డేట్ చేయడం (కొత్త సాంగ్/ఆల్బమ్ యాడ్ చేసినప్పుడు)
  Future<bool> updateFile(String filePath, String message, dynamic newContent, String? sha) async {
    final url = "https://api.github.com/repos/$owner/$repo/contents/$filePath";
    
    // డేటాని మళ్ళీ Base64 లోకి మార్చాలి
    String jsonString = const JsonEncoder.withIndent('  ').convert(newContent);
    String encodedContent = base64.encode(utf8.encode(jsonString));

    Map<String, dynamic> body = {
      "message": message, // గిట్‌హబ్ లో కనిపించే కమిట్ మెసేజ్
      "content": encodedContent,
    };
    if (sha != null) {
      body["sha"] = sha; // పాత ఫైల్ ఉంటే దాన్ని రీప్లేస్ చేయడానికి
    }

    final response = await http.put(
      Uri.parse(url),
      headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/vnd.github+json",
        "Content-Type": "application/json"
      },
      body: json.encode(body),
    );

    return response.statusCode == 200 || response.statusCode == 201;
  }
}
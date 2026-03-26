import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class GitHubService {
  // నీ గిట్‌హబ్ వివరాలు ఇక్కడే ఉంటాయి
  final String owner = "worldofgod79-del"; 
  final String repo = "my_church_app";     

  // ఫోన్ మెమరీ నుండి టోకెన్ తెచ్చుకునే ఫంక్షన్
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('github_token');
  }

  Future<Map<String, dynamic>> getFile(String filePath) async {
    final token = await _getToken();
    if (token == null || token.isEmpty) throw Exception("Token not found. Please login again.");

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
      String content = utf8.decode(base64.decode(data['content'].replaceAll('\n', '')));
      return {"sha": data['sha'], "content": json.decode(content)};
    } else if (response.statusCode == 404) {
      return {"sha": null, "content":[]};
    } else {
      throw Exception("Failed to load file: ${response.statusCode}");
    }
  }

  Future<bool> updateFile(String filePath, String message, dynamic newContent, String? sha) async {
    final token = await _getToken();
    if (token == null || token.isEmpty) throw Exception("Token not found. Please login again.");

    final url = "https://api.github.com/repos/$owner/$repo/contents/$filePath";
    String jsonString = const JsonEncoder.withIndent('  ').convert(newContent);
    String encodedContent = base64.encode(utf8.encode(jsonString));

    Map<String, dynamic> body = {
      "message": message,
      "content": encodedContent,
    };
    if (sha != null) body["sha"] = sha; 

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
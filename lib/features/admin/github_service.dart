import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class GitHubService {
  final String owner = "worldofgod79-del"; 
  final String repo = "my_church_app";     

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('github_token');
  }

  Future<Map<String, dynamic>> getFile(String filePath) async {
    final token = await _getToken();
    if (token == null) throw Exception("Token missing");

    // ఇక్కడ URL ని సరిగ్గా ఫార్మాట్ చేసాం
    final url = Uri.parse("https://api.github.com/repos/$owner/$repo/contents/$filePath");
    
    final response = await http.get(
      url,
      headers: {
        "Authorization": "token $token", // 'Bearer' బదులు 'token' వాడి చూద్దాం
        "Accept": "application/vnd.github.v3+json",
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      // కొన్నిసార్లు బేస్64 లో కొత్త లైన్లు వస్తాయి, వాటిని క్లీన్ చేస్తున్నాం
      String content = utf8.decode(base64.decode(data['content'].replaceAll(RegExp(r'\s+'), '')));
      return {"sha": data['sha'], "content": json.decode(content)};
    } else if (response.statusCode == 404) {
      return {"sha": null, "content": []};
    } else {
      throw Exception("GitHub API Error: ${response.statusCode}");
    }
  }

  Future<bool> updateFile(String filePath, String message, dynamic newContent, String? sha) async {
    final token = await _getToken();
    if (token == null) return false;

    final url = Uri.parse("https://api.github.com/repos/$owner/$repo/contents/$filePath");
    String jsonString = const JsonEncoder.withIndent('  ').convert(newContent);
    String encodedContent = base64.encode(utf8.encode(jsonString));

    Map<String, dynamic> body = {
      "message": message,
      "content": encodedContent,
    };
    if (sha != null) body["sha"] = sha;

    final response = await http.put(
      url,
      headers: {
        "Authorization": "token $token",
        "Accept": "application/vnd.github.v3+json",
        "Content-Type": "application/json",
      },
      body: json.encode(body),
    );

    return response.statusCode == 200 || response.statusCode == 201;
  }
}

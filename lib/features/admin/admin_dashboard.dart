import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});
  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _token = TextEditingController(); 
  
  // కేవలం నీ మెయిల్ మాత్రమే యాక్సెప్ట్ చేస్తుంది
  final String adminEmail = "worldofgod79@gmail.com"; 

  void _login() async {
    // మెయిల్ మరియు పాస్వర్డ్ చెక్
    if (_email.text.trim() == adminEmail && _password.text == "admin123") {
      if (_token.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("GitHub Token is required!", style: TextStyle(color: Colors.white))));
        return;
      }
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('github_token', _token.text.trim());

      if (mounted) context.go('/admin-dashboard');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(backgroundColor: Colors.red, content: Text("Access Denied! You are not an Admin.", style: TextStyle(color: Colors.white))));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117), 
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, foregroundColor: Colors.white, leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new), onPressed: () => context.pop())),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children:[
              const Icon(Icons.admin_panel_settings, size: 80, color: Color(0xFF00E5FF)),
              const SizedBox(height: 20),
              const Text("ADMIN PORTAL", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 3)),
              const SizedBox(height: 40),
              _inputField(_email, "Admin Email (worldofgod79@...)", false),
              const SizedBox(height: 15),
              _inputField(_password, "Password", true),
              const SizedBox(height: 15),
              _inputField(_token, "GitHub Personal Access Token", true), 
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity, height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00E5FF), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                  onPressed: _login,
                  child: const Text("LOGIN", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1.5)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _inputField(TextEditingController ctrl, String hint, bool isObscure) {
    return TextField(
      controller: ctrl, obscureText: isObscure, style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        filled: true, fillColor: const Color(0xFF161B22), 
        hintText: hint, hintStyle: const TextStyle(color: Colors.white30), 
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none)
      ),
    );
  }
}

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  void _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('github_token'); 
    if (context.mounted) context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        backgroundColor: const Color(0xFF161B22),
        title: const Text("Admin Dashboard", style: TextStyle(color: Color(0xFF00E5FF), fontWeight: FontWeight.bold, letterSpacing: 1)),
        actions:[IconButton(icon: const Icon(Icons.logout, color: Colors.redAccent), onPressed: () => _logout(context))],
      ),
      body: GridView.count(
        crossAxisCount: 2, padding: const EdgeInsets.all(20), crossAxisSpacing: 15, mainAxisSpacing: 15,
        children:[
          _adminCard(context, "Albums & Songs", Icons.library_music, () => context.push('/admin-albums')), 
          _adminCard(context, "Books & PDFs", Icons.menu_book, () {}),
          _adminCard(context, "Audio Messages", Icons.mic, () {}),
          _adminCard(context, "Notifications", Icons.notifications_active, () {}),
        ],
      ),
    );
  }

  Widget _adminCard(BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap, borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(color: const Color(0xFF161B22), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withOpacity(0.05))),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children:[
            Icon(icon, size: 50, color: const Color(0xFFA78BFA)),
            const SizedBox(height: 15),
            Text(title, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
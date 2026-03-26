import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});
  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  
  final String adminEmail = "admin@luminousword.com"; 

  void _login() {
    if (_email.text.trim() == adminEmail && _password.text == "admin123") {
      context.go('/admin-dashboard');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Access Denied!", style: TextStyle(color: Colors.white))));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117), 
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, foregroundColor: Colors.white, leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new), onPressed: () => context.pop())),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children:[
            const Icon(Icons.admin_panel_settings, size: 80, color: Color(0xFF00E5FF)),
            const SizedBox(height: 20),
            const Text("ADMIN PORTAL", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 3)),
            const SizedBox(height: 40),
            TextField(
              controller: _email, style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(filled: true, fillColor: const Color(0xFF161B22), hintText: "Admin Email", hintStyle: const TextStyle(color: Colors.white30), border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none)),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _password, obscureText: true, style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(filled: true, fillColor: const Color(0xFF161B22), hintText: "Password", hintStyle: const TextStyle(color: Colors.white30), border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none)),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity, height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00E5FF), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                onPressed: _login,
                child: const Text("LOGIN", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        backgroundColor: const Color(0xFF161B22),
        title: const Text("Admin Dashboard", style: TextStyle(color: Color(0xFF00E5FF), fontWeight: FontWeight.bold)),
        actions:[IconButton(icon: const Icon(Icons.logout, color: Colors.redAccent), onPressed: () => context.go('/home'))],
      ),
      body: GridView.count(
        crossAxisCount: 2, padding: const EdgeInsets.all(20), crossAxisSpacing: 15, mainAxisSpacing: 15,
        children:[
          _adminCard(context, "Albums & Songs", Icons.library_music, () => context.push('/admin-albums')), // తర్వాత చేద్దాం
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
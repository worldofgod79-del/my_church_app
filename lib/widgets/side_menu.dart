import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SideMenu extends StatelessWidget {
  const SideMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF0A0A0A),
      child: Column(
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Color(0xFF121212)),
            child: Center(
              child: Text("LUMINOUS", style: TextStyle(letterSpacing: 5, color: Color(0xFF00D2FF), fontSize: 24, fontWeight: FontWeight.bold)),
            ),
          ),
          _menuItem(Icons.person_outline, "My Profile", () {}),
          _menuItem(Icons.settings_outlined, "Settings", () {}),
          const Divider(color: Colors.white10),
          _menuItem(Icons.admin_panel_settings_outlined, "Admin Portal", () => context.push('/admin-login')),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text("Version 1.0.0", style: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 12)),
          )
        ],
      ),
    );
  }

  Widget _menuItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.white70),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      onTap: onTap,
    );
  }
}
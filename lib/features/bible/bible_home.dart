import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'bible_service.dart';

class BibleHome extends StatelessWidget {
  const BibleHome({super.key});

  @override
  Widget build(BuildContext context) {
    final books = BibleService().bookNames;
    return Scaffold(
      appBar: AppBar(
        title: const Text("పరిశుద్ధ గ్రంథము"),
        backgroundColor: Colors.brown,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        itemCount: books.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.brown[100],
              child: Text("${index + 1}", style: const TextStyle(color: Colors.brown)),
            ),
            title: Text(books[index], style: const TextStyle(fontSize: 18)),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // పుస్తకం పేరును URL లో పంపిస్తున్నాం
              context.push('/bible-reader/${books[index]}');
            },
          );
        },
      ),
    );
  }
}
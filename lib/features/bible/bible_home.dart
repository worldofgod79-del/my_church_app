import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'bible_service.dart';

class BibleHome extends StatelessWidget {
  const BibleHome({super.key});

  @override
  Widget build(BuildContext context) {
    final books = BibleService().bookNames;

    return Scaffold(
      appBar: AppBar(title: const Text("పరిశుద్ధ గ్రంథము"), backgroundColor: Colors.brown),
      body: GridView.builder(
        padding: const EdgeInsets.all(10),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, childAspectRatio: 3, crossAxisSpacing: 10, mainAxisSpacing: 10,
        ),
        itemCount: books.length,
        itemBuilder: (context, index) {
          return ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.brown[50]),
            onPressed: () => context.push('/bible-reader/${index + 1}'),
            child: Text(books[index], textAlign: TextAlign.center, style: const TextStyle(color: Colors.brown, fontWeight: FontWeight.bold)),
          );
        },
      ),
    );
  }
}
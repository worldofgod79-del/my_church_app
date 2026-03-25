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
        actions: [
          // ఇది సెర్చ్ బటన్ - దీని మీద నొక్కితే సెర్చ్ స్క్రీన్ ఓపెన్ అవుతుంది
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => context.push('/search'),
          ),
        ],
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
            onTap: () => context.push('/bible-reader/${books[index]}'),
          );
        },
      ),
    );
  }
}
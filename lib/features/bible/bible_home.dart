import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'bible_service.dart';

class BibleHome extends StatelessWidget {
  const BibleHome({super.key});

  @override
  Widget build(BuildContext context) {
    final service = BibleService();
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F2EE),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: const Color(0xFF3E2723),
          foregroundColor: Colors.white,
          title: const Text("పరిశుద్ధ గ్రంథము", 
            style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
          actions: [
            IconButton(
              icon: const Icon(Icons.search, size: 28), 
              onPressed: () => context.push('/search')
            ),
          ],
          bottom: const TabBar(
            indicatorColor: Color(0xFFD4AF37), // Gold Color
            indicatorWeight: 4,
            labelStyle: TextStyle(fontWeight: FontWeight.bold),
            tabs: [
              Tab(text: "పాత నిబంధన"),
              Tab(text: "క్రొత్త నిబంధన"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // ఇక్కడ పేర్లు getOTBooks మరియు getNTBooks అని మార్చాను
            _buildBookGrid(context, service.getOTBooks(), 0),
            _buildBookGrid(context, service.getNTBooks(), 39),
          ],
        ),
      ),
    );
  }

  Widget _buildBookGrid(BuildContext context, List<String> books, int offset) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, 
        crossAxisSpacing: 12, 
        mainAxisSpacing: 12, 
        childAspectRatio: 0.8,
      ),
      itemCount: books.length,
      itemBuilder: (context, index) {
        return InkWell(
          onTap: () => context.push('/bible-reader/${books[index]}'),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05), 
                  blurRadius: 10, 
                  offset: const Offset(0, 5)
                )
              ],
              border: Border.all(
                color: const Color(0xFFD4AF37).withOpacity(0.3), 
                width: 1
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 18, 
                  backgroundColor: const Color(0xFF3E2723),
                  child: Text("${offset + index + 1}", 
                    style: const TextStyle(color: Colors.white, fontSize: 12)),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: Text(
                    books[index], 
                    textAlign: TextAlign.center, 
                    style: const TextStyle(
                      fontWeight: FontWeight.bold, 
                      fontSize: 13, 
                      color: Color(0xFF3E2723)
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

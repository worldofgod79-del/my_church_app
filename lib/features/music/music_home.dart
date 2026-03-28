import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'music_service.dart';

class MusicHome extends StatefulWidget {
  const MusicHome({super.key});
  @override
  State<MusicHome> createState() => _MusicHomeState();
}

class _MusicHomeState extends State<MusicHome> {
  final MusicService _service = MusicService();
  List<dynamic> _albums = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  _fetch() async {
    final data = await _service.getLiveAlbums();
    setState(() { _albums = data; _isLoading = false; });
  }

  void _openAlbum(dynamic album) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(color: Color(0xFF0A0A0A), borderRadius: BorderRadius.vertical(top: Radius.circular(40))),
        child: Column(
          children: [
            const SizedBox(height: 15),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 30),
            _albumHeader(album),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: (album['songs'] as List).length,
                itemBuilder: (context, i) {
                  var song = album['songs'][i];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                    leading: CircleAvatar(backgroundColor: Colors.white.withOpacity(0.05), child: const Icon(Icons.play_arrow, color: Color(0xFF00D2FF))),
                    title: Text(song['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    subtitle: Text(song['writer'] ?? 'Unknown', style: const TextStyle(color: Colors.white38, fontSize: 12)),
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/player', extra: {'songs': album['songs'], 'index': i, 'albumCover': album['coverUrl']});
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _albumHeader(dynamic album) {
    return Column(
      children: [
        Container(
          width: 180, height: 180,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 20)],
            image: DecorationImage(image: NetworkImage(album['coverUrl']), fit: BoxFit.cover),
          ),
        ),
        const SizedBox(height: 20),
        Text(album['title'], style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
        const Text("ALBUM", style: TextStyle(letterSpacing: 4, color: Colors.white24, fontSize: 10)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      appBar: AppBar(backgroundColor: Colors.transparent, title: const Text("LIBRARY", style: TextStyle(letterSpacing: 4, fontWeight: FontWeight.w300))),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: Color(0xFF00D2FF)))
        : GridView.builder(
            padding: const EdgeInsets.all(20),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 25, crossAxisSpacing: 20, childAspectRatio: 0.75),
            itemCount: _albums.length,
            itemBuilder: (context, index) {
              var album = _albums[index];
              return InkWell(
                onTap: () => _openAlbum(album),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          image: DecorationImage(image: NetworkImage(album['coverUrl']), fit: BoxFit.cover),
                          border: Border.all(color: Colors.white.withOpacity(0.05)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(album['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1),
                    Text("${(album['songs'] as List).length} Tracks", style: const TextStyle(color: Colors.white38, fontSize: 12)),
                  ],
                ),
              );
            },
          ),
    );
  }
}
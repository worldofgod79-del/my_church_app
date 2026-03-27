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
    _fetchAlbums();
  }

  _fetchAlbums() async {
    setState(() => _isLoading = true);
    final data = await _service.getLiveAlbums();
    setState(() { _albums = data; _isLoading = false; });
  }

  void _showSongs(dynamic album) {
    List songs = album['songs'] ?? [];
    String cover = album['coverUrl'] ?? '';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(color: Color(0xFF121212), borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
        child: Column(
          children: [
            const SizedBox(height: 15),
            Text(album['title'], style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF8B0000))),
            const Divider(color: Colors.white10),
            Expanded(
              child: ListView.builder(
                itemCount: songs.length,
                itemBuilder: (context, i) => ListTile(
                  leading: const Icon(Icons.play_arrow, color: Color(0xFF8B0000)),
                  title: Text(songs[i]['name']),
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/player', extra: {'songs': songs, 'index': i, 'albumCover': cover});
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("MUSIC", style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.bold))),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: Color(0xFF8B0000)))
        : GridView.builder(
            padding: const EdgeInsets.all(20),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 15, mainAxisSpacing: 20, childAspectRatio: 0.8),
            itemCount: _albums.length,
            itemBuilder: (context, index) {
              var album = _albums[index];
              String cover = album['coverUrl'] ?? '';
              return InkWell(
                onTap: () => _showSongs(album),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          image: cover.isNotEmpty ? DecorationImage(image: NetworkImage(cover), fit: BoxFit.cover) : null,
                          color: const Color(0xFF1A1A1A),
                          border: Border.all(color: const Color(0xFF8B0000).withOpacity(0.2)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(album['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text("${(album['songs'] as List).length} Songs", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              );
            },
          ),
    );
  }
}
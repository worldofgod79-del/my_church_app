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
    setState(() {
      _albums = data;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => context.pop(),
        ),
        title: const Text("MUSIC LIBRARY", 
          style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.w800, color: Color(0xFF00E5FF))),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.refresh, color: Colors.white70), onPressed: _fetchAlbums),
        ],
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: Color(0xFF00E5FF)))
        : _albums.isEmpty 
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.library_music, size: 80, color: Colors.white10),
                  const SizedBox(height: 10),
                  const Text("No Albums Found", style: TextStyle(color: Colors.white30)),
                  TextButton(onPressed: _fetchAlbums, child: const Text("Retry"))
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: _albums.length,
              itemBuilder: (context, index) {
                var album = _albums[index];
                List songs = album['songs'] ?? [];
                String cover = album['coverUrl'] ?? '';

                return Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF161B22),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.05)),
                  ),
                  child: Theme(
                    data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      tilePadding: const EdgeInsets.all(15),
                      leading: Container(
                        width: 60, height: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          image: cover.isNotEmpty ? DecorationImage(image: NetworkImage(cover), fit: BoxFit.cover) : null,
                          color: Colors.black38,
                        ),
                        child: cover.isEmpty ? const Icon(Icons.album, color: Colors.white24) : null,
                      ),
                      title: Text(album['title'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                      subtitle: Text("${songs.length} Songs", style: const TextStyle(color: Color(0xFFA78BFA))),
                      children: songs.asMap().entries.map((e) {
                        int sIndex = e.key;
                        var song = e.value;
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                          leading: const Icon(Icons.play_circle_fill, color: Color(0xFF00E5FF), size: 30),
                          title: Text(song['name'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                          subtitle: Text(song['writer'], style: const TextStyle(color: Colors.white30, fontSize: 12)),
                          onTap: () {
                            context.push('/player', extra: {'songs': songs, 'index': sIndex, 'albumCover': cover});
                          },
                        );
                      }).toList(),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

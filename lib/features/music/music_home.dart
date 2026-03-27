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
  List<dynamic> _albums =[];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAlbums();
  }

  _fetchAlbums() async {
    final data = await _service.getLiveAlbums();
    setState(() { _albums = data; _isLoading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117), // Deep Space Dark
      appBar: AppBar(
        backgroundColor: Colors.transparent, elevation: 0, foregroundColor: Colors.white,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new), onPressed: () => context.pop()),
        title: const Text("MUSIC LIBRARY", style: TextStyle(color: Color(0xFF00E5FF), fontWeight: FontWeight.bold, letterSpacing: 2)),
        centerTitle: true,
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: Color(0xFF00E5FF)))
        : _albums.isEmpty 
          ? const Center(child: Text("No Albums Found.\nAdd from Admin Panel.", textAlign: TextAlign.center, style: TextStyle(color: Colors.white54, fontSize: 16)))
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: _albums.length,
              itemBuilder: (context, index) {
                var album = _albums[index];
                List songs = album['songs'] ?? [];
                String cover = album['coverUrl'] ?? '';

                return Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(color: const Color(0xFF161B22), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withOpacity(0.05))),
                  child: ExpansionTile(
                    iconColor: const Color(0xFF00E5FF), collapsedIconColor: Colors.white54,
                    tilePadding: const EdgeInsets.all(10),
                    leading: Container(
                      width: 60, height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10), color: Colors.black45,
                        image: cover.isNotEmpty ? DecorationImage(image: NetworkImage(cover), fit: BoxFit.cover) : null,
                      ),
                      child: cover.isEmpty ? const Icon(Icons.album, color: Colors.white54) : null,
                    ),
                    title: Text(album['title'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                    subtitle: Text("${songs.length} Songs", style: const TextStyle(color: Color(0xFFA78BFA))),
                    children: songs.asMap().entries.map((e) {
                      int sIndex = e.key;
                      var song = e.value;
                      return ListTile(
                        leading: const Icon(Icons.play_circle_fill, color: Color(0xFF00E5FF)),
                        title: Text(song['name'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                        subtitle: Text(song['writer'], style: const TextStyle(color: Colors.white54)),
                        onTap: () {
                          // పాట మీద నొక్కితే ప్లేయర్ ఓపెన్ అవుతుంది. ఆల్బమ్ సాంగ్స్ అన్నీ పంపిస్తాం (Next/Prev కోసం).
                          context.push('/player', extra: {'songs': songs, 'index': sIndex, 'albumCover': cover});
                        },
                      );
                    }).toList(),
                  ),
                );
              },
            ),
    );
  }
}

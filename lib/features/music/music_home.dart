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

  // Luminous Theme Colors
  final Color bgDark = const Color(0xFF0D1117);
  final Color accentCyan = const Color(0xFF00E5FF);
  final Color accentPurple = const Color(0xFFA78BFA);

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

  // ఆల్బమ్ క్లిక్ చేసినప్పుడు పాటల లిస్ట్ చూపించే ఫంక్షన్
  void _showSongs(dynamic album) {
    List songs = album['songs'] ?? [];
    String cover = album['coverUrl'] ?? '';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: const Color(0xFF161B22),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 15),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 20),
            Text(album['title'], style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
            Text("${songs.length} Songs", style: TextStyle(color: accentPurple, fontSize: 14)),
            const Divider(color: Colors.white10, height: 30),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                itemCount: songs.length,
                itemBuilder: (context, i) {
                  return ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: accentCyan.withOpacity(0.1), shape: BoxShape.circle),
                      child: Icon(Icons.play_arrow_rounded, color: accentCyan),
                    ),
                    title: Text(songs[i]['name'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                    subtitle: Text(songs[i]['writer'] ?? 'Unknown', style: const TextStyle(color: Colors.white30, fontSize: 12)),
                    trailing: const Icon(Icons.more_vert, color: Colors.white24),
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/player', extra: {'songs': songs, 'index': i, 'albumCover': cover});
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => context.pop(),
        ),
        title: const Text("MUSIC LIBRARY", 
          style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.w900, color: Color(0xFF00E5FF))),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.refresh, color: Colors.white70), onPressed: _fetchAlbums),
        ],
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: Color(0xFF00E5FF)))
        : _albums.isEmpty 
          ? const Center(child: Text("No Albums Found", style: TextStyle(color: Colors.white24)))
          : GridView.builder(
              padding: const EdgeInsets.all(20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // 2 కాలమ్స్ గ్రిడ్
                crossAxisSpacing: 15,
                mainAxisSpacing: 20,
                childAspectRatio: 0.75, // కార్డు షేప్ కోసం
              ),
              itemCount: _albums.length,
              itemBuilder: (context, index) {
                var album = _albums[index];
                String cover = album['coverUrl'] ?? '';

                return InkWell(
                  onTap: () => _showSongs(album),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF161B22),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.05)),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 5))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Album Cover Image
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(19)),
                              image: cover.isNotEmpty 
                                ? DecorationImage(image: NetworkImage(cover), fit: BoxFit.cover) 
                                : null,
                              color: Colors.black38,
                            ),
                            child: cover.isEmpty 
                              ? Center(child: Icon(Icons.album, size: 50, color: accentCyan.withOpacity(0.3))) 
                              : null,
                          ),
                        ),
                        // Album Info
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                album['title'], 
                                maxLines: 1, 
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: accentPurple.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Text(
                                  "${(album['songs'] as List).length} Songs", 
                                  style: TextStyle(color: accentPurple, fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
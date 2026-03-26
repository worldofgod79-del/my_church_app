import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'github_service.dart';

class AdminAlbumsScreen extends StatefulWidget {
  const AdminAlbumsScreen({super.key});
  @override
  State<AdminAlbumsScreen> createState() => _AdminAlbumsScreenState();
}

class _AdminAlbumsScreenState extends State<AdminAlbumsScreen> {
  final GitHubService _github = GitHubService();
  bool _isLoading = true;
  List<dynamic> _albums =[];
  String? _fileSha;

  final String filePath = "assets/data/albums.json";

  @override
  void initState() {
    super.initState();
    _loadAlbums();
  }

  Future<void> _loadAlbums() async {
    setState(() => _isLoading = true);
    try {
      final data = await _github.getFile(filePath);
      setState(() {
        _fileSha = data['sha'];
        _albums = (data['content'] is List) ? List.from(data['content']) :[];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showMsg("Error loading albums. Please check Token.");
    }
  }

  Future<void> _saveData(String message) async {
    setState(() => _isLoading = true);
    try {
      bool success = await _github.updateFile(filePath, message, _albums, _fileSha);
      if (success) {
        _showMsg("Saved Successfully!");
        await _loadAlbums(); // రిఫ్రెష్ చేయడానికి
      } else {
        _showMsg("Failed to save.");
        setState(() => _isLoading = false);
      }
    } catch (e) {
      _showMsg("Error: $e");
      setState(() => _isLoading = false);
    }
  }

  void _showMsg(String msg) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  // ఆల్బమ్ యాడ్/ఎడిట్ చేసే ఫామ్
  void _showAlbumForm({Map<String, dynamic>? existingAlbum, int? index}) {
    TextEditingController titleCtrl = TextEditingController(text: existingAlbum?['title'] ?? '');
    TextEditingController coverCtrl = TextEditingController(text: existingAlbum?['coverUrl'] ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF161B22),
        title: Text(existingAlbum == null ? "Add New Album" : "Edit Album", style: const TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children:[
            _input(titleCtrl, "Album Title", maxLines: 1),
            const SizedBox(height: 10),
            _input(coverCtrl, "Cover Image URL", maxLines: 1),
          ],
        ),
        actions:[
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel", style: TextStyle(color: Colors.white54))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00E5FF)),
            onPressed: () {
              if (titleCtrl.text.isEmpty) return;
              Map<String, dynamic> newAlbum = {
                "id": existingAlbum?['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
                "title": titleCtrl.text.trim(),
                "coverUrl": coverCtrl.text.trim(),
                "songs": existingAlbum?['songs'] ??[], // పాత సాంగ్స్ ఉంటే వాటిని ఉంచుతాం
              };
              
              if (index != null) _albums[index] = newAlbum;
              else _albums.add(newAlbum);
              
              Navigator.pop(context);
              _saveData("Added/Updated Album: ${newAlbum['title']}");
            },
            child: const Text("Save", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  // సాంగ్ యాడ్/ఎడిట్ చేసే ఫామ్
  void _showSongForm(int albumIndex, {Map<String, dynamic>? existingSong, int? songIndex}) {
    TextEditingController nameCtrl = TextEditingController(text: existingSong?['name'] ?? '');
    TextEditingController writerCtrl = TextEditingController(text: existingSong?['writer'] ?? '');
    TextEditingController coverCtrl = TextEditingController(text: existingSong?['coverUrl'] ?? '');
    TextEditingController audioCtrl = TextEditingController(text: existingSong?['audioUrl'] ?? '');
    TextEditingController lyricsCtrl = TextEditingController(text: existingSong?['lyrics'] ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF161B22),
        title: Text(existingSong == null ? "Add Song" : "Edit Song", style: const TextStyle(color: Colors.white)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children:[
              _input(nameCtrl, "Song Name", maxLines: 1),
              const SizedBox(height: 10),
              _input(writerCtrl, "Writer Name", maxLines: 1),
              const SizedBox(height: 10),
              _input(coverCtrl, "Cover Image URL", maxLines: 1),
              const SizedBox(height: 10),
              _input(audioCtrl, "Audio Playable URL (MP3)", maxLines: 1),
              const SizedBox(height: 10),
              _input(lyricsCtrl, "Lyrics", maxLines: 4),
            ],
          ),
        ),
        actions:[
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel", style: TextStyle(color: Colors.white54))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00E5FF)),
            onPressed: () {
              if (nameCtrl.text.isEmpty || audioCtrl.text.isEmpty) {
                _showMsg("Name & Audio URL are required!");
                return;
              }
              Map<String, dynamic> newSong = {
                "id": existingSong?['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
                "name": nameCtrl.text.trim(),
                "writer": writerCtrl.text.trim(),
                "coverUrl": coverCtrl.text.trim(),
                "audioUrl": audioCtrl.text.trim(),
                "lyrics": lyricsCtrl.text.trim(),
              };
              
              if (songIndex != null) _albums[albumIndex]['songs'][songIndex] = newSong;
              else _albums[albumIndex]['songs'].add(newSong);
              
              Navigator.pop(context);
              _saveData("Updated Songs in Album");
            },
            child: const Text("Save Song", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  Widget _input(TextEditingController ctrl, String hint, {int maxLines = 1}) {
    return TextField(
      controller: ctrl, maxLines: maxLines, style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint, hintStyle: const TextStyle(color: Colors.white30),
        filled: true, fillColor: Colors.black26,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        backgroundColor: const Color(0xFF161B22),
        title: const Text("Manage Albums", style: TextStyle(color: Color(0xFF00E5FF), fontWeight: FontWeight.bold)),
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white), onPressed: () => context.pop()),
        actions:[
          IconButton(icon: const Icon(Icons.add_box, color: Color(0xFF00E5FF), size: 28), onPressed: () => _showAlbumForm()),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF00E5FF)))
          : _albums.isEmpty
              ? const Center(child: Text("No Albums Found.\nClick '+' to add.", textAlign: TextAlign.center, style: TextStyle(color: Colors.white54, fontSize: 16)))
              : ListView.builder(
                  padding: const EdgeInsets.all(15),
                  itemCount: _albums.length,
                  itemBuilder: (context, index) {
                    var album = _albums[index];
                    List songs = album['songs'] ??[];

                    return Card(
                      color: const Color(0xFF161B22),
                      margin: const EdgeInsets.only(bottom: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      child: ExpansionTile(
                        iconColor: const Color(0xFF00E5FF),
                        collapsedIconColor: Colors.white54,
                        leading: CircleAvatar(
                          backgroundImage: album['coverUrl'].toString().isNotEmpty ? NetworkImage(album['coverUrl']) : null,
                          backgroundColor: Colors.black45,
                          child: album['coverUrl'].toString().isEmpty ? const Icon(Icons.album, color: Colors.white) : null,
                        ),
                        title: Text(album['title'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                        subtitle: Text("${songs.length} Songs", style: const TextStyle(color: Colors.white54)),
                        children:[
                          const Divider(color: Colors.white10),
                          // ఆల్బమ్ ఎడిట్/డిలీట్ బటన్స్
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children:[
                              TextButton.icon(
                                icon: const Icon(Icons.edit, color: Colors.amber, size: 18), label: const Text("Edit Album", style: TextStyle(color: Colors.amber)),
                                onPressed: () => _showAlbumForm(existingAlbum: album, index: index),
                              ),
                              TextButton.icon(
                                icon: const Icon(Icons.delete, color: Colors.redAccent, size: 18), label: const Text("Delete", style: TextStyle(color: Colors.redAccent)),
                                onPressed: () {
                                  setState(() => _albums.removeAt(index));
                                  _saveData("Deleted Album: ${album['title']}");
                                },
                              ),
                            ],
                          ),
                          const Divider(color: Colors.white10),
                          // సాంగ్స్ లిస్ట్
                          ...songs.asMap().entries.map((entry) {
                            int sIndex = entry.key;
                            var song = entry.value;
                            return ListTile(
                              leading: const Icon(Icons.music_note, color: Color(0xFFA78BFA)),
                              title: Text(song['name'], style: const TextStyle(color: Colors.white)),
                              subtitle: Text(song['writer'], style: const TextStyle(color: Colors.white54)),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children:[
                                  IconButton(icon: const Icon(Icons.edit, color: Colors.amber, size: 20), onPressed: () => _showSongForm(index, existingSong: song, songIndex: sIndex)),
                                  IconButton(icon: const Icon(Icons.delete, color: Colors.redAccent, size: 20), onPressed: () {
                                    setState(() => _albums[index]['songs'].removeAt(sIndex));
                                    _saveData("Deleted Song");
                                  }),
                                ],
                              ),
                            );
                          }),
                          // యాడ్ సాంగ్ బటన్
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00E5FF).withOpacity(0.1), foregroundColor: const Color(0xFF00E5FF)),
                              icon: const Icon(Icons.add), label: const Text("Add Song"),
                              onPressed: () => _showSongForm(index),
                            ),
                          )
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
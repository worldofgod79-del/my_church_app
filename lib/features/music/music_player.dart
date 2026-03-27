import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class MusicPlayerScreen extends StatefulWidget {
  final List<dynamic> songs;
  final int initialIndex;
  final String albumCover;
  
  const MusicPlayerScreen({super.key, required this.songs, required this.initialIndex, required this.albumCover});

  @override
  State<MusicPlayerScreen> createState() => _MusicPlayerScreenState();
}

class _MusicPlayerScreenState extends State<MusicPlayerScreen> {
  final AudioPlayer _player = AudioPlayer();
  late int _currentIndex;
  bool _isPlaying = false, _showLyrics = false, _isShuffle = false, _isRepeat = false;
  Duration _duration = Duration.zero, _position = Duration.zero;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _initPlayer();
  }

  void _initPlayer() {
    _player.onDurationChanged.listen((d) => setState(() => _duration = d));
    _player.onPositionChanged.listen((p) => setState(() => _position = p));
    _player.onPlayerStateChanged.listen((s) => setState(() => _isPlaying = s == PlayerState.playing));
    _player.onPlayerComplete.listen((e) => _isRepeat ? _play(widget.songs[_currentIndex]) : _next());
    _play(widget.songs[_currentIndex]);
  }

  Future<void> _play(dynamic s) async => await _player.play(UrlSource(s['audioUrl']));
  void _next() {
    setState(() => _currentIndex = _isShuffle ? Random().nextInt(widget.songs.length) : (_currentIndex + 1) % widget.songs.length);
    _play(widget.songs[_currentIndex]);
  }

  String _time(Duration d) => "${d.inMinutes}:${(d.inSeconds % 60).toString().padLeft(2, '0')}";

  @override
  void dispose() { _player.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    var song = widget.songs[_currentIndex];
    String cover = (song['coverUrl'] != null && song['coverUrl'].toString().isNotEmpty) ? song['coverUrl'] : widget.albumCover;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(icon: const Icon(Icons.keyboard_arrow_down, size: 35), onPressed: () => context.pop()),
        actions: [IconButton(icon: Icon(_showLyrics ? Icons.lyrics : Icons.lyrics_outlined, color: const Color(0xFF00E5FF)), onPressed: () => setState(() => _showLyrics = !_showLyrics))],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          children: [
            Expanded(child: _showLyrics ? _lyricsView(song['lyrics']) : _coverView(cover)),
            const SizedBox(height: 30),
            Text(song['name'], style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
            Text(song['writer'], style: const TextStyle(fontSize: 16, color: Color(0xFF00E5FF))),
            const SizedBox(height: 30),
            Slider(
              activeColor: const Color(0xFF00E5FF),
              inactiveColor: Colors.white10,
              max: _duration.inSeconds.toDouble(),
              value: _position.inSeconds.toDouble().clamp(0, _duration.inSeconds.toDouble()),
              onChanged: (v) => _player.seek(Duration(seconds: v.toInt())),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [Text(_time(_position), style: const TextStyle(color: Colors.white38)), Text(_time(_duration), style: const TextStyle(color: Colors.white38))],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(icon: Icon(Icons.shuffle, color: _isShuffle ? const Color(0xFF00E5FF) : Colors.white38), onPressed: () => setState(() => _isShuffle = !_isShuffle)),
                IconButton(icon: const Icon(Icons.skip_previous_rounded, size: 40), onPressed: () => setState(() => _currentIndex = (_currentIndex - 1 < 0) ? widget.songs.length - 1 : _currentIndex - 1)),
                GestureDetector(
                  onTap: () => _isPlaying ? _player.pause() : _player.resume(),
                  child: CircleAvatar(radius: 35, backgroundColor: const Color(0xFF00E5FF), child: Icon(_isPlaying ? Icons.pause : Icons.play_arrow, size: 40, color: Colors.black)),
                ),
                IconButton(icon: const Icon(Icons.skip_next_rounded, size: 40), onPressed: _next),
                IconButton(icon: Icon(Icons.repeat, color: _isRepeat ? const Color(0xFF00E5FF) : Colors.white38), onPressed: () => setState(() => _isRepeat = !_isRepeat)),
              ],
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _coverView(String url) => Container(
    width: double.infinity,
    decoration: BoxDecoration(borderRadius: BorderRadius.circular(30), image: url.isNotEmpty ? DecorationImage(image: NetworkImage(url), fit: BoxFit.cover) : null, color: const Color(0xFF161616)),
    child: url.isEmpty ? const Icon(Icons.music_note, size: 100, color: Colors.white10) : null,
  );

  Widget _lyricsView(String? l) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(color: const Color(0xFF161616), borderRadius: BorderRadius.circular(30)),
    child: SingleChildScrollView(child: Text(l ?? "No Lyrics", style: const TextStyle(fontSize: 18, height: 1.8), textAlign: TextAlign.center)),
  );
}

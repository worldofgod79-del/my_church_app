import 'dart:math';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class MusicPlayerScreen extends StatefulWidget {
  final List<dynamic> songs;
  final int initialIndex;
  final String albumCover;
  
  const MusicPlayerScreen({
    super.key, 
    required this.songs, 
    required this.initialIndex, 
    required this.albumCover
  });

  @override
  State<MusicPlayerScreen> createState() => _MusicPlayerScreenState();
}

class _MusicPlayerScreenState extends State<MusicPlayerScreen> {
  final AudioPlayer _player = AudioPlayer();
  late int _currentIndex;
  
  bool _isPlaying = false;
  bool _showLyrics = false;
  bool _isShuffle = false;
  bool _isRepeat = false;

  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  // Luminous Theme Colors
  final Color accentCyan = const Color(0xFF00D2FF);
  final Color bgBlack = const Color(0xFF0A0A0A);

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _initPlayer();
  }

  void _initPlayer() {
    _player.onDurationChanged.listen((d) => setState(() => _duration = d));
    _player.onPositionChanged.listen((p) => setState(() => _position = p));
    _player.onPlayerStateChanged.listen((state) {
      setState(() => _isPlaying = state == PlayerState.playing);
    });
    _player.onPlayerComplete.listen((event) {
      if (_isRepeat) {
        _playCurrentSong();
      } else {
        _playNext();
      }
    });

    _playCurrentSong();
  }

  Future<void> _playCurrentSong() async {
    String url = widget.songs[_currentIndex]['audioUrl'];
    await _player.stop();
    await _player.play(UrlSource(url));
  }

  void _togglePlayPause() {
    if (_isPlaying) _player.pause();
    else _player.resume();
  }

  void _playNext() {
    setState(() {
      if (_isShuffle) {
        _currentIndex = Random().nextInt(widget.songs.length);
      } else {
        _currentIndex = (_currentIndex + 1) % widget.songs.length;
      }
      _position = Duration.zero;
    });
    _playCurrentSong();
  }

  void _playPrevious() {
    setState(() {
      _currentIndex = (_currentIndex - 1 < 0) ? widget.songs.length - 1 : _currentIndex - 1;
      _position = Duration.zero;
    });
    _playCurrentSong();
  }

  String _formatTime(Duration d) {
    String mins = d.inMinutes.toString().padLeft(2, '0');
    String secs = (d.inSeconds % 60).toString().padLeft(2, '0');
    return "$mins:$secs";
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var song = widget.songs[_currentIndex];
    String cover = (song['coverUrl'] != null && song['coverUrl'].toString().isNotEmpty) 
        ? song['coverUrl'] 
        : widget.albumCover;

    return Scaffold(
      backgroundColor: bgBlack,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_down, size: 35, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(_showLyrics ? Icons.subject : Icons.notes, 
            color: _showLyrics ? accentCyan : Colors.white70),
            onPressed: () => setState(() => _showLyrics = !_showLyrics),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          children: [
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                child: _showLyrics 
                  ? _buildLyricsView(song['lyrics']) 
                  : _buildCoverArt(cover),
              ),
            ),
            const SizedBox(height: 30),
            Text(song['name'], textAlign: TextAlign.center, 
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white)),
            Text(song['writer'] ?? 'Unknown', 
                style: TextStyle(fontSize: 16, color: accentCyan, letterSpacing: 1)),
            const SizedBox(height: 30),
            
            // Premium Seekbar
            SliderTheme(
              data: SliderThemeData(
                trackHeight: 3,
                activeTrackColor: accentCyan,
                inactiveTrackColor: Colors.white10,
                thumbColor: Colors.white,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              ),
              child: Slider(
                max: _duration.inSeconds.toDouble(),
                value: _position.inSeconds.toDouble().clamp(0, _duration.inSeconds.toDouble()),
                onChanged: (v) => _player.seek(Duration(seconds: v.toInt())),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_formatTime(_position), style: const TextStyle(color: Colors.white38, fontSize: 12)),
                Text(_formatTime(_duration), style: const TextStyle(color: Colors.white38, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 20),

            // Controls
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(icon: Icon(Icons.shuffle, color: _isShuffle ? accentCyan : Colors.white38), 
                    onPressed: () => setState(() => _isShuffle = !_isShuffle)),
                IconButton(icon: const Icon(Icons.skip_previous_rounded, size: 45, color: Colors.white), onPressed: _playPrevious),
                
                GestureDetector(
                  onTap: _togglePlayPause,
                  child: Container(
                    height: 80, width: 80,
                    decoration: BoxDecoration(
                      color: accentCyan,
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: accentCyan.withOpacity(0.4), blurRadius: 30, spreadRadius: 5)],
                    ),
                    child: Icon(_isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded, color: Colors.black, size: 45),
                  ),
                ),

                IconButton(icon: const Icon(Icons.skip_next_rounded, size: 45, color: Colors.white), onPressed: _playNext),
                IconButton(icon: Icon(Icons.repeat, color: _isRepeat ? accentCyan : Colors.white38), 
                    onPressed: () => setState(() => _isRepeat = !_isRepeat)),
              ],
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildCoverArt(String url) => Container(
    key: const ValueKey(1),
    width: double.infinity,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(30),
      image: url.isNotEmpty ? DecorationImage(image: NetworkImage(url), fit: BoxFit.cover) : null,
      color: const Color(0xFF161616),
      boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 30, offset: Offset(0, 15))],
    ),
    child: url.isEmpty ? const Icon(Icons.music_note, size: 100, color: Colors.white10) : null,
  );

  Widget _buildLyricsView(String? l) => Container(
    key: const ValueKey(2),
    padding: const EdgeInsets.all(25),
    decoration: BoxDecoration(color: const Color(0xFF161616), borderRadius: BorderRadius.circular(30)),
    child: SingleChildScrollView(
      child: Text(l ?? "Lyrics not available", 
        textAlign: TextAlign.center, 
        style: const TextStyle(fontSize: 18, color: Colors.white70, height: 1.8)),
    ),
  );
}
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
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
  
  bool _isPlaying = false;
  bool _showLyrics = false;
  bool _isShuffle = false;
  bool _isRepeat = false;

  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _initPlayer();
  }

  void _initPlayer() {
    // 1. Listen to duration changes
    _player.onDurationChanged.listen((d) => setState(() => _duration = d));
    // 2. Listen to position changes
    _player.onPositionChanged.listen((p) => setState(() => _position = p));
    // 3. Listen to state changes (Play/Pause)
    _player.onPlayerStateChanged.listen((state) {
      setState(() => _isPlaying = state == PlayerState.playing);
    });
    // 4. Auto-play next song when finished
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
    await _player.stop(); // Stop previous
    await _player.play(UrlSource(url)); // Play new
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
      if (_isShuffle) {
        _currentIndex = Random().nextInt(widget.songs.length);
      } else {
        _currentIndex = (_currentIndex - 1 < 0) ? widget.songs.length - 1 : _currentIndex - 1;
      }
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
    _player.dispose(); // యాప్ బ్యాక్ వెళ్తే ఆగిపోతుంది
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var song = widget.songs[_currentIndex];
    String cover = song['coverUrl'] != null && song['coverUrl'].toString().isNotEmpty ? song['coverUrl'] : widget.albumCover;
    String lyrics = song['lyrics'] ?? "Lyrics not available";

    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        backgroundColor: Colors.transparent, elevation: 0, foregroundColor: Colors.white,
        leading: IconButton(icon: const Icon(Icons.keyboard_arrow_down, size: 30), onPressed: () => context.pop()),
        title: const Text("NOW PLAYING", style: TextStyle(fontSize: 12, letterSpacing: 3, color: Color(0xFFA78BFA))),
        centerTitle: true,
        actions:[
          IconButton(
            icon: Icon(_showLyrics ? Icons.lyrics : Icons.lyrics_outlined, color: _showLyrics ? const Color(0xFF00E5FF) : Colors.white), 
            onPressed: () => setState(() => _showLyrics = !_showLyrics)
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children:[
            // Cover Art or Lyrics Section
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                child: _showLyrics 
                  ? _buildLyricsView(lyrics) 
                  : _buildCoverArt(cover),
              ),
            ),
            const SizedBox(height: 30),
            
            // Song Details
            Text(song['name'], textAlign: TextAlign.center, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 5),
            Text(song['writer'], style: const TextStyle(fontSize: 16, color: Color(0xFFA78BFA))),
            const SizedBox(height: 30),

            // Progress Bar (Seekbar)
            SliderTheme(
              data: SliderThemeData(
                trackHeight: 4,
                activeTrackColor: const Color(0xFF00E5FF),
                inactiveTrackColor: Colors.white24,
                thumbColor: Colors.white,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
              ),
              child: Slider(
                min: 0,
                max: _duration.inSeconds.toDouble(),
                value: _position.inSeconds.toDouble().clamp(0, _duration.inSeconds.toDouble()),
                onChanged: (val) {
                  _player.seek(Duration(seconds: val.toInt()));
                },
              ),
            ),
            
            // Time Indicators
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children:[
                  Text(_formatTime(_position), style: const TextStyle(color: Colors.white54, fontSize: 12)),
                  Text(_formatTime(_duration), style: const TextStyle(color: Colors.white54, fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Media Controls
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children:[
                IconButton(
                  icon: Icon(Icons.shuffle, color: _isShuffle ? const Color(0xFF00E5FF) : Colors.white54),
                  onPressed: () => setState(() => _isShuffle = !_isShuffle),
                ),
                IconButton(icon: const Icon(Icons.skip_previous, color: Colors.white, size: 40), onPressed: _playPrevious),
                
                // Play/Pause Button
                GestureDetector(
                  onTap: _togglePlayPause,
                  child: Container(
                    height: 70, width: 70,
                    decoration: const BoxDecoration(color: Color(0xFF00E5FF), shape: BoxShape.circle, boxShadow:[BoxShadow(color: Color(0x6600E5FF), blurRadius: 20)]),
                    child: Icon(_isPlaying ? Icons.pause : Icons.play_arrow, color: Colors.black, size: 40),
                  ),
                ),
                
                IconButton(icon: const Icon(Icons.skip_next, color: Colors.white, size: 40), onPressed: _playNext),
                IconButton(
                  icon: Icon(Icons.repeat, color: _isRepeat ? const Color(0xFF00E5FF) : Colors.white54),
                  onPressed: () => setState(() => _isRepeat = !_isRepeat),
                ),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildCoverArt(String coverUrl) {
    return Container(
      key: const ValueKey(1),
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: const Color(0xFF161B22),
        boxShadow: const[BoxShadow(color: Colors.black54, blurRadius: 30, offset: Offset(0, 15))],
        image: coverUrl.isNotEmpty ? DecorationImage(image: NetworkImage(coverUrl), fit: BoxFit.cover) : null,
      ),
      child: coverUrl.isEmpty ? const Icon(Icons.music_note, size: 100, color: Colors.white24) : null,
    );
  }

  Widget _buildLyricsView(String lyrics) {
    return Container(
      key: const ValueKey(2),
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: const Color(0xFF161B22), borderRadius: BorderRadius.circular(30), border: Border.all(color: Colors.white10)),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Text(lyrics, style: const TextStyle(fontSize: 18, color: Colors.white, height: 1.8), textAlign: TextAlign.center),
      ),
    );
  }
}

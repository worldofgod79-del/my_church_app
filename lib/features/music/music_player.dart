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
  
  bool _isPlaying = false;
  bool _showLyrics = false;
  bool _isShuffle = false;
  bool _isRepeat = false;

  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  // Crimson Theme Colors
  final Color crimsonRed = const Color(0xFF8B0000);
  final Color graphiteGray = const Color(0xFF1A1A1A);
  final Color pureBlack = const Color(0xFF000000);

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
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var song = widget.songs[_currentIndex];
    String currentCover = (song['coverUrl'] != null && song['coverUrl'].toString().isNotEmpty) 
        ? song['coverUrl'] 
        : widget.albumCover;
    String lyrics = song['lyrics'] ?? "Lyrics not provided for this song.";

    return Scaffold(
      backgroundColor: pureBlack,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.expand_more, size: 35, color: Colors.white70),
          onPressed: () => context.pop(),
        ),
        title: const Text("NOW PLAYING", style: TextStyle(fontSize: 12, letterSpacing: 3, fontWeight: FontWeight.bold, color: Colors.grey)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(_showLyrics ? Icons.subject : Icons.notes, color: _showLyrics ? crimsonRed : Colors.white70),
            onPressed: () => setState(() => _showLyrics = !_showLyrics),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Segmented Card View for Image or Lyrics
            Expanded(
              flex: 5,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 600),
                child: _showLyrics ? _buildLyricsCard(lyrics) : _buildAlbumArt(currentCover),
              ),
            ),
            const SizedBox(height: 40),
            
            // Song Info Section
            Column(
              children: [
                Text(song['name'], 
                  textAlign: TextAlign.center, 
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1)),
                const SizedBox(height: 8),
                Text(song['writer'] ?? 'Unknown Artist', 
                  style: TextStyle(fontSize: 16, color: crimsonRed, fontWeight: FontWeight.w600, letterSpacing: 1.2)),
              ],
            ),
            const SizedBox(height: 40),

            // Premium Red Seekbar
            SliderTheme(
              data: SliderThemeData(
                trackHeight: 3,
                activeTrackColor: crimsonRed,
                inactiveTrackColor: Colors.white10,
                thumbColor: crimsonRed,
                overlayColor: crimsonRed.withOpacity(0.2),
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
              ),
              child: Slider(
                min: 0,
                max: _duration.inSeconds.toDouble(),
                value: _position.inSeconds.toDouble().clamp(0, _duration.inSeconds.toDouble()),
                onChanged: (val) => _player.seek(Duration(seconds: val.toInt())),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_formatTime(_position), style: const TextStyle(color: Colors.white38, fontSize: 12)),
                  Text(_formatTime(_duration), style: const TextStyle(color: Colors.white38, fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Playback Controls
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: Icon(Icons.shuffle, color: _isShuffle ? crimsonRed : Colors.white38),
                  onPressed: () => setState(() => _isShuffle = !_isShuffle),
                ),
                IconButton(
                  icon: const Icon(Icons.skip_previous_rounded, color: Colors.white, size: 45),
                  onPressed: _playPrevious,
                ),
                
                // Main Crimson Play Button
                GestureDetector(
                  onTap: _togglePlayPause,
                  child: Container(
                    height: 80, width: 80,
                    decoration: BoxDecoration(
                      color: crimsonRed,
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: crimsonRed.withOpacity(0.4), blurRadius: 25, spreadRadius: 2)],
                    ),
                    child: Icon(_isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded, color: Colors.white, size: 50),
                  ),
                ),
                
                IconButton(
                  icon: const Icon(Icons.skip_next_rounded, color: Colors.white, size: 45),
                  onPressed: _playNext,
                ),
                IconButton(
                  icon: Icon(Icons.repeat_one_rounded, color: _isRepeat ? crimsonRed : Colors.white38),
                  onPressed: () => setState(() => _isRepeat = !_isRepeat),
                ),
              ],
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  // Cover Image Card
  Widget _buildAlbumArt(String url) {
    return Container(
      key: const ValueKey(1),
      width: double.infinity,
      decoration: BoxDecoration(
        color: graphiteGray,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: crimsonRed.withOpacity(0.3), width: 2),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 40, offset: const Offset(0, 20))],
        image: url.isNotEmpty ? DecorationImage(image: NetworkImage(url), fit: BoxFit.cover) : null,
      ),
      child: url.isEmpty ? Icon(Icons.music_note, size: 100, color: crimsonRed.withOpacity(0.2)) : null,
    );
  }

  // Lyrics Card
  Widget _buildLyricsCard(String lyrics) {
    return Container(
      key: const ValueKey(2),
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: graphiteGray,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Text(
          lyrics,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 19, color: Colors.white70, height: 1.8, letterSpacing: 0.5),
        ),
      ),
    );
  }
}
// (Music Player code remains similar in logic but uses the new Cyber Cyan theme)
// Update the play button to have a glow effect
GestureDetector(
  onTap: _togglePlayPause,
  child: Container(
    height: 80, width: 80,
    decoration: BoxDecoration(
      color: const Color(0xFF00D2FF),
      shape: BoxShape.circle,
      boxShadow: [BoxShadow(color: const Color(0xFF00D2FF).withOpacity(0.4), blurRadius: 30, spreadRadius: 5)],
    ),
    child: Icon(_isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded, color: Colors.black, size: 45),
  ),
),
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  runApp(const MusicPlayerApp());
}

// MUSIC PLAYER APP // 

class MusicPlayerApp extends StatelessWidget {
  const MusicPlayerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Music Player',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF080B12),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2196F3),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const MusicPlayerPage(),
    );
  }
}

// SONG MODEL //

class Song {
  final String title;
  final String artist;
  final String album;
  final String assetPath;
  final String imagePath;

  const Song({
    required this.title,
    required this.artist,
    required this.album,
    required this.assetPath,
    required this.imagePath,
  });
}

// MUSIC PLAYER PAGE //

class MusicPlayerPage extends StatefulWidget {
  const MusicPlayerPage({super.key});

  @override
  State<MusicPlayerPage> createState() => _MusicPlayerPageState();
}

class _MusicPlayerPageState extends State<MusicPlayerPage>
    with SingleTickerProviderStateMixin {
  final AudioPlayer _audioPlayer = AudioPlayer();

  // PLAYLIST //

  final List<Song> _playlist = const [
    Song(
      title: 'back to friends',
      artist: 'sombr',
      album: 'back to friends',
      assetPath: 'audio/back to friends.mp3',
      imagePath: 'images/back_to_friends.jpg',
    ),
    Song(
      title: 'Earrings',
      artist: 'Malcolm Todd',
      album: 'Sweet Boy',
      assetPath: 'audio/Earrings.mp3',
      imagePath: 'images/earrings.jpg',
    ),
    Song(
      title: 'Innocence',
      artist: 'Hildir Svensson',
      album: 'Innocence',
      assetPath: 'audio/Innocence.mp3',
      imagePath: 'images/innocence.jpg',
    ),
    Song(
      title: 'No. 1 Party Anthem',
      artist: 'Arctic Monkeys',
      album: 'AM',
      assetPath: 'audio/No. 1 Party Anthem.mp3',
      imagePath: 'images/no_1_party_anthem.jpg',
    ),
    Song(
      title: 'Sailor Song',
      artist: 'Gigi Perez',
      album: 'Sailor Song',
      assetPath: 'audio/Sailor Song.mp3',
      imagePath: 'images/sailor_song.jpg',
    ),
  ];

  // ANIMATION //

  late AnimationController _rotationController;

  // PLAYER VARIABLES //

  int _currentIndex = 0;
  bool _isPlaying = false;

  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  Song get _currentSong => _playlist[_currentIndex];

  // INITIALIZE //

  @override
  void initState() {
    super.initState();

    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );

    _audioPlayer.onPositionChanged.listen((newPosition) {
      if (!mounted) return;

      setState(() {
        _position = newPosition;
      });
    });

    _audioPlayer.onDurationChanged.listen((newDuration) {
      if (!mounted) return;

      setState(() {
        _duration = newDuration;
      });
    });

    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (!mounted) return;

      setState(() {
        _isPlaying = state == PlayerState.playing;
      });

      if (state == PlayerState.playing) {
        _rotationController.repeat();
      } else {
        _rotationController.stop();
      }
    });

    _audioPlayer.onPlayerComplete.listen((_) {
      if (!mounted) return;

      _nextSong();
    });
  }

  // PLAY SONG //

  Future<void> _playSong(int index) async {
    if (index < 0 || index >= _playlist.length) return;

    await _audioPlayer.stop();

    setState(() {
      _currentIndex = index;
      _position = Duration.zero;
      _duration = Duration.zero;
    });

    await _audioPlayer.play(AssetSource(_playlist[index].assetPath));
  }

  // PAUSE SONG //

  Future<void> _pauseSong() async {
    await _audioPlayer.pause();
  }

  // RESUME SONG //

  Future<void> _resumeSong() async {
    await _audioPlayer.resume();
  }

  // STOP SONG //

  Future<void> _stopSong() async {
    await _audioPlayer.stop();

    if (!mounted) return;

    setState(() {
      _position = Duration.zero;
    });
  }

  // NEXT SONG //

  void _nextSong() {
    _playSong((_currentIndex + 1) % _playlist.length);
  }

  // PREVIOUS SONG //

  void _previousSong() {
    _playSong((_currentIndex - 1 + _playlist.length) % _playlist.length);
  }

  // FORMAT DURATION //

  String _formatDuration(Duration duration) {
    return '${duration.inMinutes.remainder(60).toString().padLeft(2, '0')}:'
        '${duration.inSeconds.remainder(60).toString().padLeft(2, '0')}';
  }

  // ALBUM IMAGE //

  Widget _albumImage({
    required String imagePath,
    required double size,
    double borderRadius = 0,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Image.asset(
        'assets/$imagePath',
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: size,
            height: size,
            color: const Color(0xFF1565C0),
            child: const Center(
              child: Icon(
                Icons.music_note_rounded,
                color: Colors.white,
                size: 45,
              ),
            ),
          );
        },
      ),
    );
  }

  // ANIMATED AUDIO WAVE //

  Widget _animatedEqualizer() {
    return AnimatedBuilder(
      animation: _rotationController,
      builder: (context, child) {
        final animationValue = _rotationController.value * 2 * math.pi;

        final heights = [
          12 + math.sin(animationValue) * 6,
          22 + math.sin(animationValue + 1.5) * 10,
          16 + math.sin(animationValue + 3) * 7,
        ];

        return SizedBox(
          width: 32,
          height: 30,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: heights.map((height) {
              return Container(
                width: 4,
                height: height,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF2196F3),
                  borderRadius: BorderRadius.circular(5),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  // DISPOSE //

  @override
  void dispose() {
    _rotationController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  // BUILD UI //

  @override
  Widget build(BuildContext context) {
    final maxSeconds = _duration.inSeconds > 0
        ? _duration.inSeconds.toDouble()
        : 1.0;

    final currentSeconds = _position.inSeconds.toDouble().clamp(
      0.0,
      maxSeconds,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Music Player',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            children: [
              // SPINNING VINYL DISK //
              RotationTransition(
                turns: _rotationController,
                child: Container(
                  width: 245,
                  height: 245,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const SweepGradient(
                      colors: [
                        Color(0xFF080808),
                        Color(0xFF3D4652),
                        Color(0xFF101820),
                        Color(0xFF3D4652),
                        Color(0xFF080808),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.35),
                        blurRadius: 35,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 205,
                        height: 205,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white12, width: 1),
                        ),
                      ),

                      Container(
                        width: 155,
                        height: 155,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white24, width: 2),
                        ),
                        child: ClipOval(
                          child: _albumImage(
                            imagePath: _currentSong.imagePath,
                            size: 155,
                          ),
                        ),
                      ),

                      Container(
                        width: 20,
                        height: 20,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFFB9DFFF),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // SONG INFORMATION //
              Text(
                _currentSong.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                '${_currentSong.artist} • ${_currentSong.album}',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 15, color: Colors.white60),
              ),

              const SizedBox(height: 24),

              // PROGRESS BAR //
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: const Color(0xFF2196F3),
                  inactiveTrackColor: Colors.white12,
                  thumbColor: Colors.white,
                  overlayColor: Colors.blue.withOpacity(0.2),
                ),
                child: Slider(
                  min: 0,
                  max: maxSeconds,
                  value: currentSeconds,
                  onChanged: (value) {
                    _audioPlayer.seek(Duration(seconds: value.toInt()));
                  },
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatDuration(_position),
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      _formatDuration(_duration),
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // PLAYBACK CONTROLS PREVIOUS - PLAY/PAUSE - STOP - NEXT //
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: _previousSong,
                    icon: const Icon(Icons.skip_previous_rounded),
                    iconSize: 34,
                    color: Colors.white,
                    tooltip: 'Previous',
                  ),

                  const SizedBox(width: 14),

                  IconButton(
                    onPressed: () {
                      if (_isPlaying) {
                        _pauseSong();
                      } else {
                        if (_position > Duration.zero) {
                          _resumeSong();
                        } else {
                          _playSong(_currentIndex);
                        }
                      }
                    },
                    icon: Icon(
                      _isPlaying
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                    ),
                    iconSize: 42,
                    color: const Color(0xFF2196F3),
                    tooltip: 'Play or Pause',
                  ),

                  const SizedBox(width: 14),

                  IconButton(
                    onPressed: _stopSong,
                    icon: const Icon(Icons.stop_rounded),
                    iconSize: 30,
                    color: Colors.white,
                    tooltip: 'Stop',
                  ),

                  const SizedBox(width: 14),

                  IconButton(
                    onPressed: _nextSong,
                    icon: const Icon(Icons.skip_next_rounded),
                    iconSize: 34,
                    color: Colors.white,
                    tooltip: 'Next',
                  ),
                ],
              ),

              const SizedBox(height: 34),

              // PLAYLIST HEADER //
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Your Playlist',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${_playlist.length} Songs',
                    style: const TextStyle(color: Colors.white54),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // PLAYLIST //
              ListView.builder(
                itemCount: _playlist.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final song = _playlist[index];
                  final isSelected = index == _currentIndex;

                  return Card(
                    color: isSelected
                        ? Colors.blue.withOpacity(0.22)
                        : const Color(0xFF141A24),
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      onTap: () => _playSong(index),

                      // Album cover
                      leading: _albumImage(
                        imagePath: song.imagePath,
                        size: 48,
                        borderRadius: 10,
                      ),

                      // Song title
                      title: Text(
                        song.title,
                        style: TextStyle(
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),

                      // Artist and album
                      subtitle: Text('${song.artist} • ${song.album}'),

                      // Animated equalizer
                      trailing: isSelected && _isPlaying
                          ? _animatedEqualizer()
                          : const Icon(
                              Icons.play_circle_outline_rounded,
                              color: Colors.white54,
                            ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

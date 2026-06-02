import 'package:coctio/utils/sonixa_audio_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:just_audio/just_audio.dart';

class PlayerView extends StatefulWidget {
  const PlayerView({super.key});

  @override
  State<PlayerView> createState() => _PlayerViewState();
}

class _PlayerViewState extends State<PlayerView> {
  final SonixaAudioHandler _audioHandler = SonixaAudioHandler();
  bool _isShuffle = false;
  bool _isRepeat = false;

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1E164C), Color(0xFF0F5A55)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight:
                    MediaQuery.sizeOf(context).height -
                    MediaQuery.paddingOf(context).vertical,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 16.0,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // 1. App Bar Layer
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(0.08),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(
                            Icons.arrow_back_ios_new,
                            size: 18,
                            color: Colors.white,
                          ),
                        ),
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "PLAYING FROM PLAYLIST",
                                style: Theme.of(context).textTheme.labelSmall
                                    ?.copyWith(
                                      color: Colors.white54,
                                      letterSpacing: 1.5,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                "Favorites",
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(0.08),
                          ),
                          onPressed: () {},
                          icon: const Icon(
                            Icons.more_horiz_rounded,
                            size: 20,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),

                    // 2. Music Disc Asset Wrapper
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 24.0),
                      height: MediaQuery.sizeOf(context).height * 0.38,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.4),
                            blurRadius: 30,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(200),
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: SvgPicture.asset(
                            "assets/images/disk.svg",
                            fit: BoxFit.cover,
                            placeholderBuilder: (context) => Container(
                              color: Colors.black26,
                              child: const Icon(
                                Icons.album_rounded,
                                size: 160,
                                color: Colors.white24,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // 3. Reactive Track Descriptor Section
                    StreamBuilder<SequenceState?>(
                      stream: _audioHandler.player.sequenceStateStream,
                      builder: (context, _) {
                        final playlist = _audioHandler.playlist;
                        final currentIdx = _audioHandler.currentIndex;

                        // Safety layout fallback check
                        if (playlist.isEmpty || currentIdx >= playlist.length) {
                          return const SizedBox.shrink();
                        }

                        final currentSong = playlist[currentIdx];
                        final String songTitle =
                            currentSong['title'] ?? "Unknown Title";
                        final String songArtist =
                            currentSong['artist'] ?? "Unknown Artist";

                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              songTitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.headlineMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              songArtist,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(color: Colors.white60),
                            ),
                          ],
                        );
                      },
                    ),

                    // 4. Position Timeline Scrubbing Layout
                    StreamBuilder<Duration>(
                      stream: _audioHandler.player.positionStream,
                      builder: (context, snapshot) {
                        final position = snapshot.data ?? Duration.zero;
                        final duration =
                            _audioHandler.player.duration ?? Duration.zero;

                        return Column(
                          children: [
                            SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                trackHeight: 4,
                                activeTrackColor: const Color(0xff9333EA),
                                inactiveTrackColor: Colors.white24,
                                thumbColor: Colors.white,
                                thumbShape: const RoundSliderThumbShape(
                                  enabledThumbRadius: 6,
                                ),
                              ),
                              child: Slider(
                                min: 0.0,
                                max: duration.inMilliseconds.toDouble(),
                                value: position.inMilliseconds.toDouble().clamp(
                                  0.0,
                                  duration.inMilliseconds.toDouble(),
                                ),
                                onChanged: (value) {
                                  _audioHandler.player.seek(
                                    Duration(milliseconds: value.toInt()),
                                  );
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _formatDuration(position),
                                    style: const TextStyle(
                                      color: Colors.white54,
                                    ),
                                  ),
                                  Text(
                                    _formatDuration(duration),
                                    style: const TextStyle(
                                      color: Colors.white54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),

                    // 5. Media Control Actions Toolbar
                    Padding(
                      padding: const EdgeInsets.only(bottom: 24.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.shuffle_rounded,
                              size: 24,
                              color: _isShuffle
                                  ? const Color(0xff9333EA)
                                  : Colors.white60,
                            ),
                            onPressed: () {
                              setState(() => _isShuffle = !_isShuffle);
                              _audioHandler.player.setShuffleModeEnabled(
                                _isShuffle,
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.skip_previous_rounded,
                              color: Colors.white,
                              size: 42,
                            ),
                            onPressed: () => _audioHandler.prev(),
                          ),

                          StreamBuilder<bool>(
                            stream: _audioHandler.player.playingStream,
                            builder: (context, snapshot) {
                              // Safely default to false if the stream data hasn't arrived yet
                              final isPlaying = snapshot.data ?? false;

                              return GestureDetector(
                                onTap: () {
                                  // Toggle system media engines depending on the current active state
                                  if (isPlaying) {
                                    _audioHandler.pause();
                                  } else {
                                    _audioHandler.play();
                                  }
                                },
                                child: Container(
                                  height: 72,
                                  width: 72,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                  ),
                                  child: Icon(
                                    isPlaying
                                        ? Icons.pause_rounded
                                        : Icons.play_arrow_rounded,
                                    color: const Color(
                                      0xFF1E164C,
                                    ), // Deep premium background color match
                                    size: 40,
                                  ),
                                ),
                              );
                            },
                          ),

                          IconButton(
                            icon: const Icon(
                              Icons.skip_next_rounded,
                              color: Colors.white,
                              size: 42,
                            ),
                            onPressed: () => _audioHandler.next(),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.repeat_rounded,
                              size: 24,
                              color: _isRepeat
                                  ? const Color(0xff9333EA)
                                  : Colors.white60,
                            ),
                            onPressed: () {
                              setState(() => _isRepeat = !_isRepeat);
                              _audioHandler.player.setLoopMode(
                                _isRepeat ? LoopMode.one : LoopMode.off,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

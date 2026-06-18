import 'package:coctio/components/rotating_disc.dart';
import 'package:coctio/components/vertical_volume_slider.dart';
import 'package:coctio/utils/sonixa_audio_handler.dart';
import 'package:flutter/material.dart';
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
  bool _isInterfaceLocked = false;

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
                  vertical: 12.0,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // 1. Navigation Shell Top Header Bar Area
                    _buildAppBar(context),

                    // 2. Parallel Deck Layout: Volume Slider on LEFT, Disk scaled on RIGHT
                    SizedBox(
                      height: MediaQuery.sizeOf(context).height * 0.38,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Volume controls shifted left cleanly
                          Expanded(
                            flex: 1,
                            child: VerticalVolumeSlider(
                              isLocked: _isInterfaceLocked,
                            ),
                          ),
                          const SizedBox(
                            width: 16,
                          ), // Gives padding space between slider and disc
                          // Disc wrapper with defensive sizing to eliminate clipping
                          Expanded(
                            flex: 5,
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: AspectRatio(
                                  aspectRatio: 1.0,
                                  child: FittedBox(
                                    fit: BoxFit
                                        .contain, // Forces the child to scale down safely within bounds
                                    child: const RotatingDisc(),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // 3. Audio Metadata Information Header Card
                    _buildTrackDescriptorCard(),

                    // 4. Native Scrubbing Timeline Slider Stream
                    _buildScrubbingTimelineBar(context),

                    // 5. Media Framework Core Control Operation Controls Dashboard
                    _buildMediaControlControlsDashboard(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Row(
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
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Colors.white54,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                "Favorites",
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        IconButton(
          style: IconButton.styleFrom(
            backgroundColor: _isInterfaceLocked
                ? const Color(0xff9333EA).withOpacity(0.3)
                : Colors.white.withOpacity(0.08),
          ),
          onPressed: () {
            setState(() {
              _isInterfaceLocked = !_isInterfaceLocked;
            });
          },
          icon: Icon(
            _isInterfaceLocked ? Icons.lock_rounded : Icons.lock_open_rounded,
            size: 20,
            color: _isInterfaceLocked ? const Color(0xffA855F7) : Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildTrackDescriptorCard() {
    return StreamBuilder<SequenceState?>(
      stream: _audioHandler.player.sequenceStateStream,
      builder: (context, _) {
        final playlist = _audioHandler.playlist;
        final currentIdx = _audioHandler.currentIndex;

        if (playlist.isEmpty || currentIdx >= playlist.length) {
          return const SizedBox.shrink();
        }

        final currentSong = playlist[currentIdx];
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              currentSong['title'] ?? "Unknown Title",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              currentSong['artist'] ?? "Unknown Artist",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(color: Colors.white60),
            ),
          ],
        );
      },
    );
  }

  Widget _buildScrubbingTimelineBar(BuildContext context) {
    return StreamBuilder<Duration>(
      stream: _audioHandler.player.positionStream,
      builder: (context, snapshot) {
        final position = snapshot.data ?? Duration.zero;
        final duration = _audioHandler.player.duration ?? Duration.zero;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 4,
                activeTrackColor: _isInterfaceLocked
                    ? Colors.white12
                    : const Color(0xff9333EA),
                inactiveTrackColor: Colors.white24,
                thumbColor: _isInterfaceLocked
                    ? Colors.transparent
                    : Colors.white,
                thumbShape: _isInterfaceLocked
                    ? SliderComponentShape.noThumb
                    : const RoundSliderThumbShape(enabledThumbRadius: 6),
              ),
              child: Slider(
                min: 0.0,
                max: duration.inMilliseconds.toDouble(),
                value: position.inMilliseconds.toDouble().clamp(
                  0.0,
                  duration.inMilliseconds.toDouble(),
                ),
                onChanged: _isInterfaceLocked
                    ? null
                    : (value) {
                        _audioHandler.player.seek(
                          Duration(milliseconds: value.toInt()),
                        );
                      },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatDuration(position),
                    style: const TextStyle(color: Colors.white54),
                  ),
                  Text(
                    _formatDuration(duration),
                    style: const TextStyle(color: Colors.white54),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMediaControlControlsDashboard() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(
              Icons.shuffle_rounded,
              size: 24,
              color: _isShuffle ? const Color(0xff9333EA) : Colors.white60,
            ),
            onPressed: _isInterfaceLocked
                ? null
                : () {
                    setState(() => _isShuffle = !_isShuffle);
                    _audioHandler.player.setShuffleModeEnabled(_isShuffle);
                  },
          ),
          IconButton(
            icon: const Icon(
              Icons.skip_previous_rounded,
              color: Colors.white,
              size: 42,
            ),
            onPressed: _isInterfaceLocked ? null : () => _audioHandler.prev(),
          ),
          StreamBuilder<bool>(
            stream: _audioHandler.player.playingStream,
            builder: (context, snapshot) {
              final isPlaying = snapshot.data ?? false;
              return GestureDetector(
                onTap: _isInterfaceLocked
                    ? null
                    : () => isPlaying
                          ? _audioHandler.pause()
                          : _audioHandler.play(),
                child: Container(
                  height: 68,
                  width: 68,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isInterfaceLocked ? Colors.white30 : Colors.white,
                  ),
                  child: Icon(
                    isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    color: const Color(0xFF1E164C),
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
            onPressed: _isInterfaceLocked ? null : () => _audioHandler.next(),
          ),
          IconButton(
            icon: Icon(
              Icons.repeat_rounded,
              size: 24,
              color: _isRepeat ? const Color(0xff9333EA) : Colors.white60,
            ),
            onPressed: _isInterfaceLocked
                ? null
                : () {
                    setState(() => _isRepeat = !_isRepeat);
                    _audioHandler.player.setLoopMode(
                      _isRepeat ? LoopMode.one : LoopMode.off,
                    );
                  },
          ),
        ],
      ),
    );
  }
}

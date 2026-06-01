import 'package:coctio/utils/audio_handler.dart';
import 'package:coctio/utils/permissions_handler.dart';
import 'package:coctio/views/player_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:just_audio/just_audio.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  static const _channel = MethodChannel("flutter_channel");
  List<Map<String, dynamic>> _songs = [];
  bool _isLoading = false;
  String _selectedFilter = "All";

  @override
  void initState() {
    super.initState();
    // Scan device for local MP3 files immediately on app launch
    _loadAudioFiles();

    // Listen for index changes from the background player to keep HomeView fresh
    AudioHandler().player.currentIndexStream.listen((_) {
      if (mounted) setState(() {});
    });
  }

  Future<void> _loadAudioFiles() async {
    setState(() => _isLoading = true);

    bool hasPermission = await requestAudioPermission();

    if (hasPermission) {
      try {
        final List<dynamic> result = await _channel.invokeMethod(
          'getAudioFiles',
        );
        if (mounted) {
          setState(() {
            _songs = result.map((e) => Map<String, dynamic>.from(e)).toList();
          });
        }
      } on PlatformException catch (e) {
        debugPrint("Error reading media store via MethodChannel: ${e.message}");
      }
    } else {
      debugPrint("Storage/Audio permission denied by user.");
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  // Utility to convert track milliseconds into a digital MM:SS string
  String _formatDuration(dynamic milliseconds) {
    if (milliseconds == null) return "0:00";
    final int ms = milliseconds is int
        ? milliseconds
        : int.tryParse(milliseconds.toString()) ?? 0;
    final duration = Duration(milliseconds: ms);
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  // Iterates over all tracks dynamically to display total duration
  String _calculateTotalPlayingTime() {
    int totalMs = 0;
    for (var song in _songs) {
      final ms = song['duration'];
      if (ms is int) {
        totalMs += ms;
      } else if (ms != null) {
        totalMs += int.tryParse(ms.toString()) ?? 0;
      }
    }
    final duration = Duration(milliseconds: totalMs);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0) {
      return "${hours}h ${minutes}m";
    }
    return "${minutes}m";
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final bottomSheetHeight = mediaQuery.size.height * 0.13;

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
        child: Stack(
          children: [
            // Scrollable Content Layer
            SafeArea(
              bottom: false,
              child: CustomScrollView(
                slivers: [
                  // 1. Premium App Title Bar
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: Row(
                        children: [
                          Text(
                            "Sonixa",
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.8,
                                ),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(
                              Icons.search,
                              size: 26,
                              color: Colors.white,
                            ),
                            onPressed: () {},
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.more_vert_outlined,
                              size: 26,
                              color: Colors.white,
                            ),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 2. Real-time Music Analytics Metrics
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 12.0,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildMetricCard(
                              context,
                              "Total Songs",
                              _songs.length.toString(),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildMetricCard(
                              context,
                              "Playing Time",
                              _calculateTotalPlayingTime(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 3. Segment Filter Buttons
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 12.0,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: SegmentedButton<String>(
                        showSelectedIcon: false,
                        style: SegmentedButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.08),
                          foregroundColor: Colors.white70,
                          selectedBackgroundColor: const Color(0xff9333EA),
                          selectedForegroundColor: Colors.white,
                          side: BorderSide.none,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        segments: const [
                          ButtonSegment(value: "All", label: Text("All")),
                          ButtonSegment(value: "Recent", label: Text("Recent")),
                          ButtonSegment(
                            value: "Favourite",
                            label: Text("Favourite"),
                          ),
                        ],
                        selected: {_selectedFilter},
                        onSelectionChanged: (Set<String> newSelection) {
                          setState(() {
                            _selectedFilter = newSelection.first;
                          });
                        },
                      ),
                    ),
                  ),

                  // 4. Loading States & Dynamic List Implementation
                  if (_isLoading)
                    const SliverFillRemaining(
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Color(0xff9333EA),
                        ),
                      ),
                    )
                  else if (_songs.isEmpty)
                    SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.music_off_rounded,
                              size: 64,
                              color: Colors.white38,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "No MP3 files detected",
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(color: Colors.white60),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: EdgeInsets.only(
                        left: 8.0,
                        right: 8.0,
                        top: 8.0,
                        bottom:
                            bottomSheetHeight +
                            20.0, // Extra clearance padding so lists don't hide under the player
                      ),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final song = _songs[index];
                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 4.0),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.03),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12.0,
                                vertical: 4.0,
                              ),
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  height: 48,
                                  width: 48,
                                  color: Colors.white.withOpacity(0.07),
                                  padding: const EdgeInsets.all(8),
                                  child: SvgPicture.asset(
                                    "assets/images/music.svg",
                                    placeholderBuilder: (context) => const Icon(
                                      Icons.music_note_rounded,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ),
                              ),
                              title: Text(
                                song['title'] ?? "Unknown Track",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Text(
                                song['artist'] ?? "Unknown Artist",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              trailing: Text(_formatDuration(song['duration'])),
                              onTap: () async {
                                // Initialize global playback and update local track indexing instantly
                                await AudioHandler().playTrack(_songs, index);
                                setState(() {});

                                if (context.mounted) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const PlayerView(),
                                    ),
                                  );
                                }
                              },
                            ),
                          );
                        }, childCount: _songs.length),
                      ),
                    ),
                ],
              ),
            ),

            // 5. Fully Synchronized Bottom Floating Mini Player Overlay
            StreamBuilder<SequenceState?>(
              stream: AudioHandler().player.sequenceStateStream,
              builder: (context, snapshot) {
                final playlist = AudioHandler().playlist;

                // Keep mini player entirely hidden if no file handles have been actively loaded yet
                if (playlist.isEmpty) return const SizedBox.shrink();

                final currentIndex = AudioHandler().currentIndex;
                final currentSong = playlist[currentIndex];
                final String songTitle =
                    currentSong['title'] ?? "Unknown Title";
                final String songArtist =
                    currentSong['artist'] ?? "Unknown Artist";

                return Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PlayerView(),
                        ),
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      height: bottomSheetHeight,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 10.0,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF4A56E2), Color(0xFF5E2D93)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, -3),
                          ),
                        ],
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(24),
                          topRight: Radius.circular(24),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    width: 44,
                                    height: 44,
                                    color: Colors.white24,
                                    child: Image.network(
                                      "https://cdn3d.iconscout.com/3d/premium/thumb/headphone-3d-icon-download-in-png-blend-fbx-gltf-file-formats--headphones-headset-earphones-virtual-reality-pack-science-technology-icons-3342612.png",
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => const Icon(
                                        Icons.music_note,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        songTitle,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                            ),
                                      ),
                                      Text(
                                        songArtist,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(color: Colors.white70),
                                      ),
                                    ],
                                  ),
                                ),

                                // Interactive Media Buttons inside Mini Player Layout
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      padding: EdgeInsets.zero,
                                      icon: const Icon(
                                        Icons.skip_previous_rounded,
                                        color: Colors.white,
                                        size: 28,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          AudioHandler().prev();
                                        });
                                      },
                                    ),
                                    StreamBuilder<bool>(
                                      stream:
                                          AudioHandler().player.playingStream,
                                      builder: (context, playSnapshot) {
                                        final isPlaying =
                                            playSnapshot.data ?? false;
                                        return IconButton(
                                          padding: EdgeInsets.zero,
                                          icon: Icon(
                                            isPlaying
                                                ? Icons
                                                      .pause_circle_filled_rounded
                                                : Icons
                                                      .play_circle_filled_rounded,
                                            color: Colors.white,
                                            size: 36,
                                          ),
                                          onPressed: () {
                                            if (isPlaying) {
                                              AudioHandler().pause();
                                            } else {
                                              AudioHandler().play();
                                            }
                                          },
                                        );
                                      },
                                    ),
                                    IconButton(
                                      padding: EdgeInsets.zero,
                                      icon: const Icon(
                                        Icons.skip_next_rounded,
                                        color: Colors.white,
                                        size: 28,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          AudioHandler().next();
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 6),

                          // Linear Scrub Tracker Progress Indicator bar
                          StreamBuilder<Duration>(
                            stream: AudioHandler().player.positionStream,
                            builder: (context, posSnapshot) {
                              final position =
                                  posSnapshot.data ?? Duration.zero;
                              final duration =
                                  AudioHandler().player.duration ??
                                  Duration.zero;

                              double progressValue = 0.0;
                              if (duration.inMilliseconds > 0) {
                                progressValue =
                                    position.inMilliseconds /
                                    duration.inMilliseconds;
                              }

                              return ClipRRect(
                                borderRadius: BorderRadius.circular(2),
                                child: LinearProgressIndicator(
                                  value: progressValue.clamp(0.0, 1.0),
                                  backgroundColor: Colors.white12,
                                  valueColor:
                                      const AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                  minHeight: 2.5,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // Unified reusable metric statistics card design block
  Widget _buildMetricCard(BuildContext context, String title, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white60,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

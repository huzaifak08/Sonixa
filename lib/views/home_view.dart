import 'package:coctio/components/playing_wave_indicator.dart';
import 'package:coctio/providers/audio_provider/audio_provider.dart';
import 'package:coctio/utils/sonixa_audio_handler.dart';
import 'package:coctio/views/player_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:just_audio/just_audio.dart';

class HomeView extends ConsumerStatefulWidget {
  const HomeView({super.key});

  @override
  ConsumerState<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends ConsumerState<HomeView> {
  @override
  void initState() {
    super.initState();
    // Keep playback indexing synchronized dynamically across global instances
    SonixaAudioHandler().player.currentIndexStream.listen((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    // 1️⃣ Watch the generated async state payload directly
    final audioLibraryAsync = ref.watch(audioLibraryProvider);
    final bottomSheetHeight = MediaQuery.sizeOf(context).height * 0.13;

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
            SafeArea(
              bottom: false,
              child: CustomScrollView(
                slivers: [
                  // Title Layout Row
                  _buildHeaderBar(context),

                  // 2️⃣ Handle asynchronous framework lifecycle mapping smoothly via .when
                  audioLibraryAsync.when(
                    loading: () => const SliverFillRemaining(
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Color(0xff9333EA),
                        ),
                      ),
                    ),
                    error: (error, stack) => SliverFillRemaining(
                      child: Center(
                        child: Text(
                          error.toString(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white60),
                        ),
                      ),
                    ),
                    data: (songs) {
                      if (songs.isEmpty) {
                        return const SliverFillRemaining(
                          child: Center(
                            child: Text(
                              "No MP3 files detected",
                              style: TextStyle(color: Colors.white60),
                            ),
                          ),
                        );
                      }

                      return _buildSongList(songs, bottomSheetHeight);
                    },
                  ),
                ],
              ),
            ),

            // Persistent Floating Core State Controller Panel
            _buildMiniPlayer(bottomSheetHeight),
          ],
        ),
      ),
    );
  }

  // Pure list visual renderer with real-time active track wave tracking
  Widget _buildSongList(
    List<Map<String, dynamic>> songs,
    double bottomPadding,
  ) {
    return SliverPadding(
      padding: EdgeInsets.only(
        left: 8.0,
        right: 8.0,
        top: 8.0,
        bottom: bottomPadding + 20.0,
      ),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final song = songs[index];

          return Container(
            margin: const EdgeInsets.symmetric(vertical: 4.0),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.03),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
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
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  height: 48,
                  width: 48,
                  color: Colors.white.withOpacity(0.07),
                  padding: const EdgeInsets.all(8),
                  child: SvgPicture.asset("assets/images/music.svg"),
                ),
              ),

              // Real-time local stream evaluation for individual track items
              trailing: StreamBuilder<bool>(
                stream: SonixaAudioHandler().player.playingStream,
                builder: (context, playSnapshot) {
                  final isPlaying = playSnapshot.data ?? false;
                  final hasActivePlaylist =
                      SonixaAudioHandler().playlist.isNotEmpty;
                  final isCurrentTrack =
                      hasActivePlaylist &&
                      (SonixaAudioHandler().currentIndex == index);

                  if (isCurrentTrack) {
                    return PlayingWaveIndicator(isPlaying: isPlaying);
                  }

                  // Fall back to clean whitespace layout for standard inactive non-playing rows
                  return const SizedBox.shrink();
                },
              ),
              onTap: () async {
                await SonixaAudioHandler().playTrack(songs, index);
                if (mounted) setState(() {});

                if (context.mounted) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const PlayerView()),
                  );
                }
              },
            ),
          );
        }, childCount: songs.length),
      ),
    );
  }

  Widget _buildHeaderBar(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      sliver: SliverToBoxAdapter(
        child: Row(
          children: [
            SizedBox(
              height: 60,
              child: SvgPicture.asset("assets/images/sonixa.svg"),
            ),
            Text(
              "Sonixa",
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.search, color: Colors.white),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: () {
                ref.read(audioLibraryProvider.notifier).refreshLibrary();
              },
            ),
          ],
        ),
      ),
    );
  }

  // Fully Synchronized Stream-Driven Floating Mini Player Panel Layer
  Widget _buildMiniPlayer(double height) {
    return StreamBuilder<SequenceState?>(
      stream: SonixaAudioHandler().player.sequenceStateStream,
      builder: (context, snapshot) {
        final playlist = SonixaAudioHandler().playlist;

        // Keep mini player entirely hidden if no file handles have been actively loaded yet
        if (playlist.isEmpty) return const SizedBox.shrink();

        final currentIndex = SonixaAudioHandler().currentIndex;

        // Safety bounds check to avoid index errors on quick playlist transitions
        if (currentIndex >= playlist.length) return const SizedBox.shrink();

        final currentSong = playlist[currentIndex];
        final String songTitle = currentSong['title'] ?? "Unknown Title";
        final String songArtist = currentSong['artist'] ?? "Unknown Artist";

        return Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PlayerView()),
              );
            },
            child: Container(
              width: double.infinity,
              height: height,
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                songTitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                              ),
                              Text(
                                songArtist,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: Colors.white70),
                              ),
                            ],
                          ),
                        ),
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
                                  SonixaAudioHandler().prev();
                                });
                              },
                            ),
                            StreamBuilder<bool>(
                              stream: SonixaAudioHandler().player.playingStream,
                              builder: (context, playSnapshot) {
                                final isPlaying = playSnapshot.data ?? false;
                                return IconButton(
                                  padding: EdgeInsets.zero,
                                  icon: Icon(
                                    isPlaying
                                        ? Icons.pause_circle_filled_rounded
                                        : Icons.play_circle_filled_rounded,
                                    color: Colors.white,
                                    size: 36,
                                  ),
                                  onPressed: () {
                                    if (isPlaying) {
                                      SonixaAudioHandler().pause();
                                    } else {
                                      SonixaAudioHandler().play();
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
                                  SonixaAudioHandler().next();
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  StreamBuilder<Duration>(
                    stream: SonixaAudioHandler().player.positionStream,
                    builder: (context, posSnapshot) {
                      final position = posSnapshot.data ?? Duration.zero;
                      final duration =
                          SonixaAudioHandler().player.duration ?? Duration.zero;

                      double progressValue = 0.0;
                      if (duration.inMilliseconds > 0) {
                        progressValue =
                            position.inMilliseconds / duration.inMilliseconds;
                      }

                      return ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: LinearProgressIndicator(
                          value: progressValue.clamp(0.0, 1.0),
                          backgroundColor: Colors.white12,
                          valueColor: const AlwaysStoppedAnimation<Color>(
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
    );
  }
}

import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

// 1️⃣ Extending BaseAudioHandler links your class with the Android notification system
class SonixaAudioHandler extends BaseAudioHandler
    with QueueHandler, SeekHandler {
  static final SonixaAudioHandler _instance = SonixaAudioHandler._internal();
  factory SonixaAudioHandler() => _instance;

  final AudioPlayer player = AudioPlayer();
  List<Map<String, dynamic>> playlist = [];
  int currentIndex = 0;

  SonixaAudioHandler._internal() {
    // 2️⃣ Pipes audio execution state updates directly down to the native Android OS layer
    player.playbackEventStream.map(_transformEvent).pipe(playbackState);

    // Listen for track completion state to automatically trigger the next song
    player.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) {
        next();
      }
    });
  }

  Future<void> playTrack(
    List<Map<String, dynamic>> currentPlaylist,
    int index,
  ) async {
    if (currentPlaylist.isEmpty || index < 0 || index >= currentPlaylist.length)
      return;

    // Extract targeted path coordinates
    final String? targetPath = currentPlaylist[index]['path'];
    if (targetPath == null || targetPath.isEmpty) return;

    // Dynamic Check: Is this file already loaded in our media engine?
    final bool isSameTrack =
        playlist.isNotEmpty &&
        currentIndex < playlist.length &&
        playlist[currentIndex]['path'] == targetPath;

    playlist = currentPlaylist;
    currentIndex = index;

    // 3️⃣ Map track metadata properties over to the platform notification stream layout
    final currentSong = playlist[currentIndex];
    final mediaItemObj = MediaItem(
      id: currentSong['id']?.toString() ?? targetPath,
      album: "Local Storage",
      title: currentSong['title'] ?? "Unknown Track",
      artist: currentSong['artist'] ?? "Unknown Artist",
      duration: Duration(milliseconds: currentSong['duration'] ?? 0),
      extras: {'path': targetPath},
    );

    // Alert the system tray to refresh metadata card displays immediately
    mediaItem.add(mediaItemObj);

    // If it's the exact same song, bypass reloading the audio source entirely!
    if (isSameTrack) {
      if (!player.playing) play();
      return;
    }

    try {
      // Fresh song path detected -> Reset stream buffer and play from start
      await player.setAudioSource(
        AudioSource.uri(Uri.parse("file://$targetPath")),
      );
      play();
    } catch (e) {
      print("Error loading local audio source pipeline: $e");
    }
  }

  // 4️⃣ Override system media controls so lock screen buttons work out-of-the-box
  @override
  Future<void> play() => player.play();

  @override
  Future<void> pause() => player.pause();

  @override
  Future<void> seek(Duration position) => player.seek(position);

  @override
  Future<void> skipToNext() async => next();

  @override
  Future<void> skipToPrevious() async => prev();

  void next() {
    if (playlist.isEmpty) return;
    if (currentIndex < playlist.length - 1) {
      playTrack(playlist, currentIndex + 1);
    } else {
      playTrack(playlist, 0);
    }
  }

  void prev() {
    if (playlist.isEmpty) return;
    if (currentIndex > 0) {
      playTrack(playlist, currentIndex - 1);
    } else {
      playTrack(playlist, playlist.length - 1);
    }
  }

  /// Transforms internal just_audio events into standard native system PlaybackStates
  PlaybackState _transformEvent(PlaybackEvent event) {
    return PlaybackState(
      controls: [
        MediaControl.skipToPrevious,
        if (player.playing) MediaControl.pause else MediaControl.play,
        MediaControl.skipToNext,
      ],
      systemActions: const {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
      },
      androidCompactActionIndices: const [
        0,
        1,
        2,
      ], // Shows Prev, Play/Pause, Next buttons in collapsed mode
      processingState: const {
        ProcessingState.idle: AudioProcessingState.idle,
        ProcessingState.loading: AudioProcessingState.loading,
        ProcessingState.buffering: AudioProcessingState.buffering,
        ProcessingState.ready: AudioProcessingState.ready,
        ProcessingState.completed: AudioProcessingState.completed,
      }[player.processingState]!,
      playing: player.playing,
      updatePosition: player.position,
      bufferedPosition: player.bufferedPosition,
      speed: player.speed,
      queueIndex: event.currentIndex,
    );
  }
}

import 'package:just_audio/just_audio.dart';

class AudioHandler {
  static final AudioHandler _instance = AudioHandler._internal();
  factory AudioHandler() => _instance;
  AudioHandler._internal() {
    // Listen for track completion state to automatically trigger the next song
    player.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) {
        next();
      }
    });
  }

  final AudioPlayer player = AudioPlayer();
  List<Map<String, dynamic>> playlist = [];
  int currentIndex = 0;

  Future<void> playTrack(
    List<Map<String, dynamic>> currentPlaylist,
    int index,
  ) async {
    // 1️⃣ Extract targeted path coordinates
    final String? targetPath = currentPlaylist[index]['path'];
    if (targetPath == null || targetPath.isEmpty) return;

    // 2️⃣ Dynamic Check: Is this file already loaded in our media engine?
    final bool isSameTrack =
        playlist.isNotEmpty &&
        currentIndex < playlist.length &&
        playlist[currentIndex]['path'] == targetPath;

    // 3️⃣ Update our active memory indices
    playlist = currentPlaylist;
    currentIndex = index;

    // If it's the exact same song, bypass reloading the audio source entirely!
    if (isSameTrack) {
      // If the song was paused, resume it; otherwise, do nothing and let it play
      if (!player.playing) player.play();
      return;
    }

    try {
      // Fresh song path detected -> Reset stream buffer and play from start
      await player.setAudioSource(
        AudioSource.uri(Uri.parse("file://$targetPath")),
      );
      player.play();
    } catch (e) {
      print("Error loading local audio source pipeline: $e");
    }
  }

  void play() => player.play();
  void pause() => player.pause();

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
}

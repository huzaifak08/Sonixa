import 'package:just_audio/just_audio.dart';

class AudioHandler {
  // Singleton pattern to ensure only one instance handles playback across the app
  static final AudioHandler _instance = AudioHandler._internal();
  factory AudioHandler() => _instance;
  AudioHandler._internal();

  final AudioPlayer player = AudioPlayer();
  List<Map<String, dynamic>> playlist = [];
  int currentIndex = 0;

  // Initialize and begin track playback
  Future<void> playTrack(
    List<Map<String, dynamic>> currentPlaylist,
    int index,
  ) async {
    playlist = currentPlaylist;
    currentIndex = index;

    final String? filePath = playlist[currentIndex]['path'];
    if (filePath == null || filePath.isEmpty) return;

    try {
      // just_audio parses local Android files using the 'file://' URI prefix scheme
      await player.setAudioSource(
        AudioSource.uri(Uri.parse("file://$filePath")),
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
      playTrack(playlist, 0); // Loop back to the beginning of the list
    }
  }

  void prev() {
    if (playlist.isEmpty) return;
    if (currentIndex > 0) {
      playTrack(playlist, currentIndex - 1);
    } else {
      playTrack(playlist, playlist.length - 1); // Jump to the last track
    }
  }
}

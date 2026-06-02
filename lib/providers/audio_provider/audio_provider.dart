import 'package:coctio/services/audio_fetch_service.dart';
import 'package:coctio/utils/permissions_handler.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'audio_provider.g.dart';

@Riverpod(keepAlive: true)
class AudioLibraryNotifier extends _$AudioLibraryNotifier {
  final _fetchService = AudioFetchService();

  @override
  Future<List<Map<String, dynamic>>> build() async {
    // 1️⃣ Verify storage/media system permissions based on Android OS version
    final hasPermission = await requestAudioPermission();
    if (!hasPermission) {
      throw Exception("Storage/Audio permission denied by user.");
    }

    // 2️⃣ Query the local MediaStore via MethodChannel inside the native layer
    final localTracks = await _fetchService.fetchLocalMp3s();

    return localTracks;
  }

  /// Optional: Exposed public method to manually re-scan media storage directories
  Future<void> refreshLibrary() async {
    // Force the AsyncNotifier to transition into a loading state and re-execute build()
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      return await _fetchService.fetchLocalMp3s();
    });
  }
}

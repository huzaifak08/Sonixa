import 'package:flutter/services.dart';

class AudioFetchService {
  static const _channel = MethodChannel("flutter_channel");

  /// Directly invokes the Android native channel to query local audio files
  Future<List<Map<String, dynamic>>> fetchLocalMp3s() async {
    try {
      final List<dynamic>? result = await _channel.invokeMethod(
        'getAudioFiles',
      );
      if (result == null) return [];

      return result.map((e) => Map<String, dynamic>.from(e)).toList();
    } on PlatformException catch (e) {
      throw Exception("Native MediaStore query failed: ${e.message}");
    }
  }
}

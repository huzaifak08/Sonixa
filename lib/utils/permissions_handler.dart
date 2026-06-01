import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

Future<bool> requestAudioPermission() async {
  final deviceInfo = DeviceInfoPlugin();
  final androidInfo = await deviceInfo.androidInfo;

  // androidInfo.version.sdkInt 33 corresponds to Android 13
  if (androidInfo.version.sdkInt >= 33) {
    // Request modern granular audio permission
    final status = await Permission.audio.request();
    return status.isGranted;
  } else {
    // Request legacy global storage permission
    final status = await Permission.storage.request();
    return status.isGranted;
  }
}

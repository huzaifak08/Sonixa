import 'package:audio_service/audio_service.dart';
import 'package:coctio/constants/theme.dart';
import 'package:coctio/utils/sonixa_audio_handler.dart';
import 'package:coctio/views/welcome_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await AudioService.init(
    builder: () => SonixaAudioHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.farrukh.coctio.channel.audio',
      androidNotificationChannelName: 'Sonixa Playback Controls',
      androidNotificationOngoing: true,
      androidShowNotificationBadge: true,
      notificationColor: Color(0xFF1E164C),
    ),
  );

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sonixa',
      theme: themeData,
      home: const WelcomeView(),
    );
  }
}

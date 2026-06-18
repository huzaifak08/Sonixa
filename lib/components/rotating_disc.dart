import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:coctio/utils/sonixa_audio_handler.dart';

class RotatingDisc extends StatefulWidget {
  const RotatingDisc({super.key});

  @override
  State<RotatingDisc> createState() => _RotatingDiscState();
}

class _RotatingDiscState extends State<RotatingDisc>
    with SingleTickerProviderStateMixin {
  late final AnimationController _rotationController;
  final SonixaAudioHandler _audioHandler = SonixaAudioHandler();

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12), // Dynamic continuous RPM pace
    );

    // Sync rotation matrix on frame generation loops depending on active playback states
    _audioHandler.player.playingStream.listen((isPlaying) {
      if (!mounted) return;
      if (isPlaying) {
        _rotationController.repeat();
      } else {
        _rotationController.stop();
      }
    });
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20.0),
      height: MediaQuery.sizeOf(context).height * 0.34,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: RotationTransition(
        turns: _rotationController,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(200),
          child: AspectRatio(
            aspectRatio: 1,
            child: SvgPicture.asset(
              "assets/images/disk.svg",
              fit: BoxFit.cover,
              placeholderBuilder: (context) => Container(
                color: Colors.black26,
                child: const Icon(
                  Icons.album_rounded,
                  size: 160,
                  color: Colors.white24,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

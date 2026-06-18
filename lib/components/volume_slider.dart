import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class VerticalVolumeSlider extends StatefulWidget {
  final bool isLocked;

  const VerticalVolumeSlider({super.key, required this.isLocked});

  @override
  State<VerticalVolumeSlider> createState() => _VerticalVolumeSliderState();
}

class _VerticalVolumeSliderState extends State<VerticalVolumeSlider> {
  static const _platform = MethodChannel('flutter_channel');
  double _currentVolume = 0.5;

  @override
  void initState() {
    super.initState();
    _fetchCurrentSystemVolume();
  }

  Future<void> _fetchCurrentSystemVolume() async {
    try {
      final double vol = await _platform.invokeMethod('getSystemVolume');
      setState(() => _currentVolume = vol);
    } catch (e) {
      print("Failed to sync platform volume frames: $e");
    }
  }

  Future<void> _updateSystemVolume(double volume) async {
    if (widget.isLocked) return; // Guard clause when controls are locked

    setState(() => _currentVolume = volume);
    try {
      await _platform.invokeMethod('setSystemVolume', {"volume": volume});
    } catch (e) {
      print("Failed mutating system audio streams: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.volume_up_rounded,
          color: widget.isLocked ? Colors.white24 : Colors.white70,
          size: 18,
        ),
        const SizedBox(height: 8),
        Expanded(
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 4,
              activeTrackColor: widget.isLocked
                  ? Colors.white12
                  : const Color(0xff0F5A55),
              inactiveTrackColor: Colors.white12,
              thumbColor: widget.isLocked ? Colors.grey : Colors.white,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              // Removes the splash effect overlay when locked
              overlayColor: widget.isLocked
                  ? Colors.transparent
                  : Colors.white10,
            ),
            child: RotatedBox(
              quarterTurns:
                  3, // Rotates counter-clockwise to make it slide bottom-to-top
              child: Slider(
                min: 0.0,
                max: 1.0,
                value: _currentVolume,
                onChanged: widget.isLocked
                    ? null
                    : _updateSystemVolume, // Disables slider interactively
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Icon(
          Icons.volume_down_rounded,
          color: widget.isLocked ? Colors.white24 : Colors.white70,
          size: 18,
        ),
      ],
    );
  }
}

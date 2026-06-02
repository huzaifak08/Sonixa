import 'dart:math';

import 'package:flutter/material.dart';

class PlayingWaveIndicator extends StatefulWidget {
  final bool isPlaying;

  const PlayingWaveIndicator({super.key, required this.isPlaying});

  @override
  State<PlayingWaveIndicator> createState() => _PlayingWaveIndicatorState();
}

class _PlayingWaveIndicatorState extends State<PlayingWaveIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    if (widget.isPlaying) {
      _animationController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant PlayingWaveIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Dynamically halt or kick off animations depending on media engine play state
    if (widget.isPlaying) {
      _animationController.repeat(reverse: true);
    } else {
      _animationController.stop();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 24,
      alignment: Alignment.centerRight,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildBar(0.2, 0.8, 0.1), // Left equalizer bar
              _buildBar(0.4, 1.0, 0.4), // Center equalizer bar
              _buildBar(0.1, 0.7, 0.7), // Right equalizer bar
            ],
          );
        },
      ),
    );
  }

  Widget _buildBar(double minHeight, double maxHeight, double offset) {
    // Generate distinct waves by applying a phase shift based on the offset parameter
    double value = _animationController.value + offset;
    if (value > 1.0) value -= 1.0;

    // Apply a sine wave sequence to keep the motion smooth and fluid
    double sineValue = (sin(value * 2 * pi) + 1) / 2;
    double currentHeight = minHeight + (maxHeight - minHeight) * sineValue;

    return Container(
      width: 3.5,
      // If the song is paused globally, fall back to a subtle, static minimum height
      height: widget.isPlaying ? (24 * currentHeight) : 6.0,
      decoration: BoxDecoration(
        color: const Color(
          0xff9333EA,
        ), // Coordinates with your core accent theme
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

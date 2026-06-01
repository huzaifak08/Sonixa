import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CoctioHomeView extends StatefulWidget {
  const CoctioHomeView({super.key});

  @override
  State<CoctioHomeView> createState() => _CoctioHomeViewState();
}

class _CoctioHomeViewState extends State<CoctioHomeView> {
  Timer? _timer;
  int _secondsRemaining = 360;
  int _totalSeconds = 360;
  bool _isRunning = false;
  String _selectedType = 'Soft';

  final Map<String, int> _presets = {
    'Soft': 360, // 6 mins
    'Medium': 480, // 8 mins
    'Hard': 600, // 10 mins
  };

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _selectPreset(String type) {
    if (_selectedType == type && !_isRunning) return;
    HapticFeedback.selectionClick();
    setState(() {
      _selectedType = type;
      _secondsRemaining = _presets[type]!;
      _totalSeconds = _presets[type]!;
      _stopTimer();
    });
  }

  void _toggleTimer() {
    HapticFeedback.mediumImpact();
    if (_isRunning) {
      _stopTimer();
    } else {
      _startTimer();
    }
  }

  void _startTimer() {
    setState(() => _isRunning = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        _stopTimer();
        _showFinishedDialog();
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    setState(() => _isRunning = false);
  }

  void _resetTimer() {
    HapticFeedback.lightImpact();
    _stopTimer();
    setState(() => _secondsRemaining = _presets[_selectedType]!);
  }

  void _showFinishedDialog() {
    HapticFeedback.vibrate();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E164C),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Text(
            "Boiling Complete!",
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          content: Text(
            "Your $_selectedType boiled egg is ready to enjoy.",
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
            textAlign: TextAlign.center,
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: const Color(0xff9333EA),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                _resetTimer();
              },
              child: const Text("Perfect"),
            ),
          ],
        );
      },
    );
  }

  String _getFormattedTime() {
    int minutes = _secondsRemaining ~/ 60;
    int seconds = _secondsRemaining % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final widthSize = MediaQuery.sizeOf(context).width;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1E164C), Color(0xFF0F5A55)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 16.0,
            ),
            child: Column(
              children: [
                // 1. Unified App Branding Header Track
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.asset(
                        "assets/images/coctio-512.png",
                        height: 48,
                        width: 48,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          height: 48,
                          width: 48,
                          color: Colors.white.withOpacity(0.08),
                          child: const Icon(
                            Icons.blur_on_rounded,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Text(
                      "COCTIO",
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 6,
                      ),
                    ),
                  ],
                ),

                const Spacer(),

                // 2. High-Contrast Dial Circular Tracker Engine
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: widthSize * 0.72,
                      height: widthSize * 0.72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xff9333EA).withOpacity(0.15),
                            blurRadius: 40,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: CustomPaint(
                        painter: TimerPainter(
                          progress: _secondsRemaining / _totalSeconds,
                          trackColor: Colors.white.withOpacity(0.06),
                          // Matches your main segmented theme accent token directly
                          progressColor: const Color(0xff9333EA),
                        ),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _getFormattedTime(),
                          style: theme.textTheme.displayLarge?.copyWith(
                            fontSize: 62,
                            fontWeight: FontWeight.w200,
                            letterSpacing: -1,
                            fontFeatures: [const FontFeature.tabularFigures()],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "REMAINING",
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: Colors.white38,
                            letterSpacing: 2.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const Spacer(),

                // 3. Ergonomic Option Selection Matrix
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildEggCard('Soft', const Color(0xFFFFD166), theme),
                    _buildEggCard('Medium', const Color(0xFFF77F00), theme),
                    _buildEggCard('Hard', const Color(0xFFD62828), theme),
                  ],
                ),

                const SizedBox(height: 36),

                // 4. Central Execution Action Controller
                GestureDetector(
                  onTap: _toggleTimer,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 56,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: _isRunning ? Colors.transparent : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: _isRunning
                          ? Border.all(color: Colors.white24, width: 2)
                          : Border.all(color: Colors.transparent, width: 2),
                      boxShadow: _isRunning
                          ? []
                          : [
                              BoxShadow(
                                color: Colors.white.withOpacity(0.1),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                    ),
                    child: Center(
                      child: Text(
                        _isRunning ? "PAUSE PIPELINE" : "START BOILING",
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: _isRunning
                              ? Colors.white
                              : const Color(0xFF1E164C),
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                TextButton(
                  style: TextButton.styleFrom(
                    minimumSize: const Size(120, 44),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _resetTimer,
                  child: Text(
                    "RESET COUNTER",
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: Colors.white38,
                      letterSpacing: 1.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEggCard(String label, Color indicatorTone, ThemeData theme) {
    bool isSelected = _selectedType == label;
    return GestureDetector(
      onTap: () => _selectPreset(label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: MediaQuery.sizeOf(context).width * 0.26,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white.withOpacity(0.08)
              : Colors.white.withOpacity(0.02),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? const Color(0xff9333EA)
                : Colors.white.withOpacity(0.03),
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: indicatorTone.withOpacity(0.1),
              ),
              child: Icon(Icons.egg_rounded, color: indicatorTone, size: 28),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isSelected ? Colors.white : Colors.white60,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 5. High-Performance Anti-Aliased Progress Ring Painter
class TimerPainter extends CustomPainter {
  final double progress;
  final Color trackColor;
  final Color progressColor;

  TimerPainter({
    required this.progress,
    required this.trackColor,
    required this.progressColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double strokeThickness = size.width * 0.035;

    Paint backgroundTrackPaint = Paint()
      ..color = trackColor
      ..strokeWidth = strokeThickness
      ..style = PaintingStyle.stroke;

    Paint activeProgressPaint = Paint()
      ..color = progressColor
      ..strokeWidth = strokeThickness
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    Offset dialCenter = Offset(size.width / 2, size.height / 2);
    double boundRadius = (size.width - strokeThickness) / 2;

    // Draw non-active baseline foundation channel arc
    canvas.drawCircle(dialCenter, boundRadius, backgroundTrackPaint);

    // Compute angular velocity values (clamped trajectory starting directly at 12 o'clock positions)
    double calculatedSweepAngle = 2 * pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: dialCenter, radius: boundRadius),
      -pi / 2,
      calculatedSweepAngle,
      false,
      activeProgressPaint,
    );
  }

  @override
  bool shouldRepaint(TimerPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> with TickerProviderStateMixin {
  late final AnimationController _logoController;
  late final Animation<double> _logoAnimation;
  late final AnimationController _textController;
  late final Animation<double> _textAnimation;

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _logoAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeInOut),
    );

    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _textAnimation = CurvedAnimation(
      parent: _textController,
      curve: Curves.easeIn,
    );

    Future.delayed(const Duration(milliseconds: 1200), () {
      _textController.forward();
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2C1F6A), Color(0xFF11968D)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScaleTransition(
                scale: _logoAnimation,
                child: SvgPicture.asset(
                  'assets/images/sonixa_logo.svg',
                  width: 120,
                  height: 120,
                ),
              ),
              const SizedBox(height: 32),
              FadeTransition(
                opacity: _textAnimation,
                child: Text(
                  'Sonixa',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        blurRadius: 12,
                        color: Colors.black26,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

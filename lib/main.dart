import 'package:coctio/constants/theme.dart';
import 'package:coctio/views/welcome_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(ProviderScope(child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Coctio',
      theme: themeData,
      home: WelcomeView(),
    );
  }
}

// dart run build_runner build --delete-conflicting-outputs

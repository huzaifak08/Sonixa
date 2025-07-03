import 'package:flutter/material.dart';

final ThemeData themeData = ThemeData(
  colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
  iconTheme: const IconThemeData(color: Colors.white),
  listTileTheme: ListTileThemeData(
    titleTextStyle: TextStyle(
      color: Colors.white,
      fontSize: 16,
      fontWeight: FontWeight.w600,
    ),
    subtitleTextStyle: TextStyle(color: Colors.white60, fontSize: 12),
    leadingAndTrailingTextStyle: TextStyle(color: Colors.white60, fontSize: 12),
  ),
  textTheme: const TextTheme(
    displayLarge: TextStyle(
      color: Colors.white,
      fontSize: 57,
      fontWeight: FontWeight.bold,
    ),
    displayMedium: TextStyle(
      color: Colors.white,
      fontSize: 45,
      fontWeight: FontWeight.bold,
    ),
    displaySmall: TextStyle(
      color: Colors.white,
      fontSize: 36,
      fontWeight: FontWeight.w600,
    ),
    headlineLarge: TextStyle(
      color: Colors.white,
      fontSize: 32,
      fontWeight: FontWeight.bold,
    ),
    headlineMedium: TextStyle(
      color: Colors.white,
      fontSize: 28,
      fontWeight: FontWeight.w600,
    ),
    headlineSmall: TextStyle(
      color: Colors.white,
      fontSize: 24,
      fontWeight: FontWeight.w500,
    ),
    titleLarge: TextStyle(
      color: Colors.white,
      fontSize: 22,
      fontWeight: FontWeight.w600,
    ),
    titleMedium: TextStyle(
      color: Colors.white,
      fontSize: 16,
      fontWeight: FontWeight.w500,
    ),
    titleSmall: TextStyle(
      color: Colors.white,
      fontSize: 14,
      fontWeight: FontWeight.w500,
    ),
    bodyLarge: TextStyle(
      color: Colors.white,
      fontSize: 16,
      fontWeight: FontWeight.normal,
    ),
    bodyMedium: TextStyle(
      color: Colors.white,
      fontSize: 14,
      fontWeight: FontWeight.normal,
    ),
    bodySmall: TextStyle(
      color: Colors.white,
      fontSize: 12,
      fontWeight: FontWeight.normal,
    ),
    labelLarge: TextStyle(
      color: Colors.white,
      fontSize: 14,
      fontWeight: FontWeight.w500,
    ),
    labelMedium: TextStyle(
      color: Colors.white,
      fontSize: 12,
      fontWeight: FontWeight.w500,
    ),
    labelSmall: TextStyle(
      color: Colors.white,
      fontSize: 11,
      fontWeight: FontWeight.w400,
    ),
  ),
);

import 'package:flutter/material.dart';

// СТИЛИ ТЕМНОЙ ТЕМЫ

// Глобальный стиль для текста
TextStyle basicTextStyle = const TextStyle(color: Colors.black);

// Стиль для elevated кнопки
ButtonStyle elevatedButtonStyle = const ButtonStyle(
  foregroundColor: WidgetStatePropertyAll(Color.fromARGB(255, 255, 255, 255)),
  overlayColor: WidgetStatePropertyAll(Color.fromARGB(255, 28, 28, 28)),
);

// Цветовая схема
ColorScheme colorScheme = const ColorScheme(
  brightness: Brightness.light, 
  primary: Colors.black,
  onPrimary: Colors.white, 
  secondary: Colors.white, 
  onSecondary: Colors.black, 
  error: Color.fromARGB(255, 153, 10, 0), 
  onError: Colors.white, 
  surface: Colors.black, 
  onSurface: Colors.white,
  outline: Colors.black,
);

// Сама тема
final lightTheme = ThemeData(
  colorScheme: colorScheme,
  scaffoldBackgroundColor: Colors.white,
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.white,
    titleTextStyle: basicTextStyle.copyWith(fontSize: 24),
    iconTheme: const IconThemeData(
      color: Colors.black,
    )
  ),
  textTheme: TextTheme(
    bodyMedium: basicTextStyle.copyWith(fontSize: 15),
    bodyLarge: basicTextStyle.copyWith(fontSize: 20),
    labelMedium: basicTextStyle.copyWith(fontSize: 14),
  ),
  cardColor: const Color.fromARGB(255, 228, 228, 228),
  elevatedButtonTheme: ElevatedButtonThemeData(style: elevatedButtonStyle),
  snackBarTheme: const SnackBarThemeData(backgroundColor: Color.fromARGB(255, 228, 228, 228))
);
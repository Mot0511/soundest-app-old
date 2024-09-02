import 'package:flutter/material.dart';

TextStyle basicTextStyle = const TextStyle(color: Colors.black);

ButtonStyle elevatedButtonStyle = const ButtonStyle(
  foregroundColor: WidgetStatePropertyAll(Color.fromARGB(255, 255, 255, 255)),
  overlayColor: WidgetStatePropertyAll(Color.fromARGB(255, 28, 28, 28)),
);

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
    bodyMedium: basicTextStyle.copyWith(fontSize: 18),
    bodyLarge: basicTextStyle.copyWith(fontSize: 20),
    labelMedium: basicTextStyle.copyWith(fontSize: 14),
  ),
  cardColor: const Color.fromARGB(255, 228, 228, 228),
  elevatedButtonTheme: ElevatedButtonThemeData(style: elevatedButtonStyle)
);
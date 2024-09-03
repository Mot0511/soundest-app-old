import 'package:flutter/material.dart';

TextStyle basicTextStyle = const TextStyle(color: Colors.white);

ButtonStyle elevatedButtonStyle = const ButtonStyle(
  backgroundColor: WidgetStatePropertyAll(Color.fromARGB(255, 255, 255, 255)),
  foregroundColor: WidgetStatePropertyAll(Color.fromARGB(255, 0, 0, 0)),
  overlayColor: WidgetStatePropertyAll(Color.fromARGB(255, 215, 215, 215)),
);


ColorScheme colorScheme = const ColorScheme(
  brightness: Brightness.dark, 
  primary: Colors.white, 
  onPrimary: Colors.black, 
  secondary: Colors.black, 
  onSecondary: Colors.white, 
  error: Color.fromARGB(255, 153, 10, 0), 
  onError: Colors.white, 
  surface: Colors.white, 
  onSurface: Colors.black,
  outline: Colors.white,
);

final darkTheme = ThemeData(
  colorScheme: colorScheme,
  scaffoldBackgroundColor: Colors.black,
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.black,
    titleTextStyle: basicTextStyle.copyWith(fontSize: 24),
    iconTheme: const IconThemeData(
      color: Colors.white,
    )
  ),
  textTheme: TextTheme(
    bodyMedium: basicTextStyle.copyWith(fontSize: 15),
    bodyLarge: basicTextStyle.copyWith(fontSize: 20),
    labelMedium: basicTextStyle.copyWith(fontSize: 14),
  ),
  cardColor: const Color.fromARGB(255, 28, 28, 28),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: elevatedButtonStyle
  ),
  snackBarTheme: const SnackBarThemeData(backgroundColor: Color.fromARGB(255, 28, 28, 28))
);
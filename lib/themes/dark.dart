import 'package:flutter/material.dart';

final TextStyle globalTextStyle = TextStyle(color: Colors.white);

final darkTheme = ThemeData(
  primaryColor: Colors.white,
  scaffoldBackgroundColor: Colors.black,
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.black,
    titleTextStyle: globalTextStyle.copyWith(fontSize: 24),
  ),
  textTheme: TextTheme(
    bodyMedium: globalTextStyle,
  ),
  
);
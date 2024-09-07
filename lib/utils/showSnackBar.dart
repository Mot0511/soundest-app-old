import 'package:flutter/material.dart';

// Показ информационной плашки
void showSnackBar(String text, BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
}
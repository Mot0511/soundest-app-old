import 'package:flutter/material.dart';
import 'dart:io';

// Проверка подключения к интернету
Future<bool> internet() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
    } on SocketException catch (_) {
      return false;
    }
    return false;
  }
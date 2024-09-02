import 'package:flutter/material.dart';
import 'package:soundest/utils/prefs.dart';

class Settings extends StatefulWidget{
  const Settings({super.key});

  State<Settings> createState() => _Settings();
}

class _Settings extends State<Settings> {

  String musicPath = '';

  @override
  void initState() {
    getSettings();
  }

  void getSettings() async {
    final musicPathPrefs = await getPrefs('musicPath');

    setState(() async {
      musicPath = musicPathPrefs != null ? musicPathPrefs : '/storage/emulated/0/Music';
    });
  }

  void save() async {
    setPrefs('musicPath', musicPath);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Настройки')
      ),
      body: Column(
        children: [
          
          OutlinedButton(
            onPressed: save,
            child: const Text('Сохранить')
          )
        ]
      )
    );
  }
}
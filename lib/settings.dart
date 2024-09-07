import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:soundest/utils/prefs.dart';

// Страница с настройками
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

    setState(() {
      musicPath = musicPathPrefs != null ? musicPathPrefs : '/storage/emulated/0/Music';
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Настройки')
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: Column(
                          children: [
                            Align(alignment: Alignment.centerLeft, child: Text('Папка с музыкой', style: Theme.of(context).textTheme.labelMedium)),
                            Text(musicPath)
                          ],
                        ),
                      ),
                      OutlinedButton(
                        onPressed: () async {
                          final String? dir = await FilePicker.platform.getDirectoryPath();
                          if (dir != null) {
                            setState(() {
                              musicPath = dir;
                            });
                            setPrefs('musicPath', musicPath);
                          }
                        }, 
                        child: const Icon(Icons.folder_open)
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ]
      )
    );
  }
}
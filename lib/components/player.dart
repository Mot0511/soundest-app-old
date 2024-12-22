import 'dart:math';
import 'package:flutter/material.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:provider/provider.dart';
import 'package:soundest/services/fetchItems.dart';
import 'package:soundest/utils/prefs.dart';
import 'package:soundest/utils/showSnackBar.dart';

class PlayerManager extends ChangeNotifier{
  PlayerManager(context);
  late BuildContext context;
  final Future<String?> login = getPrefs('login');
  final AssetsAudioPlayer player = AssetsAudioPlayer();
  late Future<List<Map>> items;
  final Map? item = {};
  double duration = 0;
  bool isPlay = false;
  int step = 0;
  String url = '';

  void initItems() async {
    if (login != null) {
      items = getItems((await login as String), context);
    }
  }

  void leaf() async {
    Random random = Random();
    List<Map> data = await items;
    step = random.nextInt(data.length);
    setSong(data[step]);

    notifyListeners();
  }

  void setSong(Map item) async {
    final metas = Metas(
      title: item['title'],
      artist: item['author'],
      image: const MetasImage.asset("assets/images/icon.png")
    );

    final notificationSettings = NotificationSettings(
      prevEnabled: false,
      customNextAction: (player) {
        leaf();
      }
    );

    if (item.containsKey('path')){
      player.open(
        Audio.file(item['path'], metas: metas),
        showNotification: true,
        notificationSettings: notificationSettings
      );
      List<Map> data = await items;
      for (var i = 0; i < data.length; i++){
      if (data[i]['path'] == item['path']){
          step = i;
          isPlay = true;
          url = item['path'];
          break;
        }
      }
      
    } else {
      final id = item['id'];
      final newUrl = await getUrl('$login/$id.mp3');
      player.open(
        Audio.network(newUrl, metas: metas),
        showNotification: true,
        notificationSettings: notificationSettings
      );
      List<Map> data = await items;
      for (var i = 0; i < data.length; i++){
      if (data[i]['id'] == item['id']){
          step = i;
          isPlay = true;
          url = newUrl;
          break;
        }
      }
    }
    player.playlistAudioFinished.listen((_) => leaf());
    player.current.listen((currentSong) => duration = currentSong!.audio.duration.inSeconds.toDouble());
  }

  void play() {
     if (isPlay){
      isPlay = false;
      player.pause();
    } else {
      isPlay = true;
      player.play();
    }

    notifyListeners();
  }

  void uploadItem(Map item, BuildContext context) {
    if (login != null) {
      uploadSong(item, items, (login as String), context);
    }
  }

  void removeFromCloud_(int id, BuildContext context) {
    if (login != null) {
      removeFromCloud(items, id, (login as String));
      showSnackBar('Трек удален из облака', context);
    }
  }

  void removeItem(int id) async {
    items = removeItemFromList(items, id);

    notifyListeners();
  }

}

// Плеер, отображаемый внизу экрана
class Player extends StatelessWidget {
  const Player({super.key});

  @override
  Widget build(BuildContext context){
    final PlayerManager playerManager = Provider.of<PlayerManager>(context);

    final AssetsAudioPlayer player = playerManager.player;
    final double duration = playerManager.duration;
    final Map? item = playerManager.item;
    final isPlay = playerManager.isPlay;
    final leaf = playerManager.leaf;
    final play = playerManager.play;

    return Column(
      children: [
        player.builderCurrentPosition(
          builder: (context, current) {
            return Slider(
              max: duration + 1.0,
              value: current.inSeconds.toDouble(),
              onChanged: (double value) async {
                player.seek(Duration(seconds: value.toInt()));
              },
              thumbColor: Theme.of(context).colorScheme.primary,
              activeColor: Theme.of(context).colorScheme.primary,
              inactiveColor: Colors.grey,
            );
          }
        ),
        Padding(
          padding: const EdgeInsets.all(0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(5),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: play,
                      child: (isPlay
                          ? const Icon(Icons.pause_circle, size: 43)
                          : const Icon(Icons.play_circle, size: 43)),
                    ),
                    GestureDetector(
                      onTap: leaf,
                      child: const Icon(Icons.skip_next, size: 43),
                    )
                  ],
                )
              ),
              Padding(
                padding: EdgeInsets.only(top: 4),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item!['title'],
                          style: const TextStyle(fontSize: 15)),
                      Text(item!['author'],
                          style: const TextStyle(fontSize: 13)),
                    ]
                  )
                ),
            ],
          )
        )
      ],
    );
  }
}
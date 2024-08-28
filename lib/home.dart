import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import './services/fetchItems.dart';
import 'dart:math';
import 'package:assets_audio_player/assets_audio_player.dart';

import 'components/player.dart';
import 'components/item.dart';

class Home extends StatefulWidget{
  const Home({super.key, required this.login});
  final login;

  State<Home> createState() => _Home(login: login);
}

class _Home extends State<Home>{
  _Home({required this.login});
  final login;
  final player = AssetsAudioPlayer();
  late Future<List<Map>> items = getItems(login, context);

  int step = 0;
  String url = '';
  bool isPlay = false;
  double duration = 0.0;


  void leaf() async {
    Random random = Random();
    List<Map> data = await items;
    setState(() {
      step = random.nextInt(data.length);
    });
    setSong(data[step]);
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
          setState(() {
            step = i;
            isPlay = true;
            url = item['path'];
          });
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
            setState(() {
              step = i;
              isPlay = true;
              url = newUrl;
            });
            break;
        }
      }
    }
    player.playlistAudioFinished.listen((_) => leaf());
    player.current.listen((currentSong) => setState(() => duration = currentSong!.audio.duration.inSeconds.toDouble()));
  }

  void play() {
     if (isPlay){
      setState(() {
        isPlay = false;
      });
      player.pause();
    } else {
      setState(() {
        isPlay = true;
      });
      player.play();
    }
  }

  void uploadItem(Map item, BuildContext context) {
    uploadSong(item, items, login, context);
  }

  void removeFromCloud_(int id, BuildContext context) {
    removeFromCloud(items, id, login);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Трек удален из облака')));
  }

  void removeItem(int id) async {
    items = removeItemFromList(items, id);
    setState(() {});
  }

  @override
  Widget build(BuildContext context){
    return Column (
      children: [
        Expanded(
          child: LayoutBuilder(builder: (context, constraints){
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: FutureBuilder<List<Map>>(
                  future: items,
                  builder: (BuildContext context, AsyncSnapshot<List<Map>> snapshot){
                    List<Widget> children;
                    if (snapshot.hasData){
                      final data = snapshot.data;
                      if (data!.isNotEmpty){
                        children = List.generate(data!.length, (index) => Item(login: login, item: data[index], setSong: setSong, uploadItem: uploadItem, removeFromCloud_: removeFromCloud_, removeItem: removeItem));
                      } else {
                        children = [const Text('У вас пока нет музыки', style: TextStyle(fontSize: 20))];
                      }
                    } else if (snapshot.hasError){
                      final error = snapshot.error;
                      children = [
                        Center(child: Text('$error', style: const TextStyle(fontSize: 20)))
                      ];
                    } else {
                      children = [
                        const Align(
                          alignment: Alignment.center,
                          child: CircularProgressIndicator()
                        )
                      ];
                    }
                    return Column(
                      children: children,
                    );
                  }
                )
              )
            );
          }),
        ),
        FutureBuilder(
          future: items,
          builder: (BuildContext context, AsyncSnapshot<List<Map>> snapshot){
            Widget children = const SizedBox.shrink();
            if (snapshot.hasData){
              final data = snapshot.data;
              if (data!.isNotEmpty){
                children = SizedBox(
                  height: 101,
                  child: Player(player: player, duration: duration, item: data[step], leaf: leaf, play: play, isPlay: isPlay)
                );
              }
            }
            return children;
          }
        )
      ],
    );
  }
}





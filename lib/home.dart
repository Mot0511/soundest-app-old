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
  late Future<List<Map>> items = getItems(login);

  int step = 0;
  String url = '';
  bool isPlay = false;
  double duration = 0.0;

  void setItems (data) {
    setState(() {
      items = data;
    });
    uploadItems(login, items);
  }
  void remove(id){
    setItems(removeItem(items, id, login));
  }
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

  void uploadItem(Map item) {
    uploadSong(item, items, login);
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
                      children = List.generate(data!.length, (index) => Item(item: data[index], remove: remove, setSong: setSong, uploadItem: uploadItem));
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
            Widget children = const CircularProgressIndicator();
            if (snapshot.hasData){
              final data = snapshot.data;
              if (data != null){
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





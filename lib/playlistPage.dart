import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:soundest/components/item.dart';
import 'package:soundest/home.dart';
import 'package:soundest/services/fetchItems.dart';
import 'package:soundest/services/fetchPlaylists.dart';
import 'dart:math';
import 'package:soundest/components/player.dart';

// Страница самого плейлиста
class PlaylistPage extends StatefulWidget{
  const PlaylistPage({super.key, required this.name, required this.list, required this.login});
  final name;
  final list;
  final String login;

  State<PlaylistPage> createState() => _PlaylistPage(name: name, list: list, login: login);
}

class _PlaylistPage extends State<PlaylistPage>{
  _PlaylistPage({required this.name, required this.list, required this.login});
  final name;
  List list;
  final String login;

  late Future<List<Map>> items = getItemsByIds(login, list, context);

  final player = AssetsAudioPlayer();
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
    player.current.listen((currentSong) => setState(() {
      if (currentSong != null) {
        duration = currentSong.audio.duration.inSeconds.toDouble();
      }
    }));
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

  void removeFromPlaylist_(int id) async {
    final List<int> newList = await removeFromPlaylist(list, id, login, name);
    setState(() {
      list = newList;
      items = getItemsByIds(login, newList, context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(name)),
      body: Column (
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
                        children = List.generate(data!.length, (index) => Item(item: data[index], login: login, type: 'playlist', setSong: setSong, removeFromPlaylist_: removeFromPlaylist_));
                      } else if (snapshot.hasError){
                        final error = snapshot.error;
                        children = [
                          const Center(child: Text('Произошла ошибка', style: TextStyle(fontSize: 30)))
                        ];
                      } else {
                        children = [
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(15),
                              child: CircularProgressIndicator(),
                            ),
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
      ),
    );
  }
}
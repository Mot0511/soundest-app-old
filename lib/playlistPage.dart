import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:soundest/home.dart';
import 'package:soundest/services/fetchItems.dart';
import 'package:soundest/services/fetchPlaylists.dart';
import 'dart:math';

class PlaylistPage extends StatefulWidget{
  const PlaylistPage({super.key, required this.name, required this.list});
  final name;
  final list;

  State<PlaylistPage> createState() => _PlaylistPage(name: name, list: list);
}

class _PlaylistPage extends State<PlaylistPage>{
  _PlaylistPage({required this.name, required this.list});
  final name;
  final list;

  final login = 'suvorovmatvej9';
  final player = AudioPlayer();

  late Future<List<Map<String, dynamic>>> items = getItemsByIds(login, list);

  int step = 0;
  String url = '';
  bool isPlay = false;

  double duration = 0;
  double current = 0;

  void remove(id, String name) async {
    setState(() {
      items = inFuture(removeItem(items, id, login));
    });
    list.remove(id);
    setPlaylist(login, name, list);
  }
  Future<List<Map<String, dynamic>>> inFuture(el) async {
    return el;
  }

  void leaf() async {
    Random random = new Random();
    List<Map<String, dynamic>> data = await items;
    setState(() {
      step = random.nextInt(data.length);
    });
    setSong(data[step]['id']);
  }
  void setSong(id) async {
    player.stop();
    final newUrl = await getUrl('$login/$id.mp3');
    List<Map<String, dynamic>> data = await items;
    for (var i = 0; i < data.length; i++){
      if (data[i]['id'] == id){
          setState(() {
            step = i;
            isPlay = true;
            url = newUrl;
          });
          break;
      }
    }
    player.play(UrlSource(url));
    player.onDurationChanged.listen((Duration  d) {
      setState(() {
        duration = d.inSeconds * 1.0;
      });
    });
    player.onPositionChanged.listen((Duration  p) {
      setCurrent(p.inSeconds * 1.0);
    });
    player.onPlayerComplete.listen((_) {
      leaf();
    });
  }

  void play() {
    if (isPlay){
      player.pause();
      setState(() {
        isPlay = false;
      });
    } else {
      player.resume();
      setState(() {
        isPlay = true;
      }); 
    }
  }
  void setCurrent(double value) async {
    setState(() {
      current = value;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(name)),
      body: Padding(
        padding: EdgeInsets.all(8),
        child: Column (
          children: [
            Expanded(
              child: LayoutBuilder(builder: (context, constraints){
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    
                    child: FutureBuilder<List<Map<String, dynamic>>>(
                      future: items,
                      builder: (BuildContext context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot){
                        List<Widget> children;
                        if (snapshot.hasData){
                          final data = snapshot.data;
                          children = List.generate(data!.length, (index) => Item(item: data[index], remove: remove, setSong: setSong, playlist: name));
                        } else if (snapshot.hasError){
                          final error = snapshot.error;
                          children = [
                            const Center(child: Text('Произошла ошибка', style: TextStyle(fontSize: 30)))
                          ];
                        } else {
                          children = [
                            const Center(child: CircularProgressIndicator())
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
              builder: (BuildContext context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot){
                Widget children = const CircularProgressIndicator();
                if (snapshot.hasData){
                  final data = snapshot.data;
                  if (data != null){
                    children = SizedBox(
                      height: 101,
                      child: data.length > 0 ? Player(item: data[step], player: player, leaf: leaf, play: play, isPlay: isPlay, current: current, duration: duration, setCurrent: setCurrent) : Text('Плейлист пустой', style: TextStyle(fontSize: 24))
                      
                    );
                  }
                }
                return children;
              }
            )
          ],
        ),
      ),
    );
  }
}
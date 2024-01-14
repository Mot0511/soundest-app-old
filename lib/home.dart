import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import './services/fetchItems.dart';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart'; 

class Home extends StatefulWidget{
  const Home({super.key});

  State<Home> createState() => _Home();
}

class _Home extends State<Home>{
  final login = 'suvorovmatvej9';
  final player = AudioPlayer();

  late Future<List<Map<String, dynamic>>> items = getItems(login);
  int step = 0;
  String url = '';
  bool isPlay = false;
  late Duration duration;

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
    player.onDurationChanged.listen((Duration  p) {
        setState(() {
          duration = p;
        });
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
  // Future<List<Map<String, dynamic>>> itemsInFuture(el) async {
  //   return el;
  // }

  @override
  Widget build(BuildContext context){
    return Column (
      children: [
        Expanded(
          child: LayoutBuilder(builder: (context, constraints){
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight - 500),
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: items,
                  builder: (BuildContext context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot){
                    List<Widget> children;
                    if (snapshot.hasData){
                      final data = snapshot.data;
                      children = List.generate(data!.length, (index) => Item(item: data[index], remove: remove, setSong: setSong));
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
                  height: 50,
                  child: Player(item: data[step], leaf: leaf, play: play, isPlay: isPlay)
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

class Player extends StatelessWidget {
  const Player({super.key, required this.item, required this.leaf, required this.play, required this.isPlay});
  final Map<String, dynamic>? item;
  final leaf;
  final play;
  final isPlay;

  @override
  Widget build(BuildContext context){
    return Padding(
      padding: const EdgeInsets.all(3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(5),
            child: Row(
              children: [
                GestureDetector(
                  onTap: play,
                  child: (isPlay ? const Icon(Icons.pause_circle, size: 43) : const Icon(Icons.play_circle, size: 43)),
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
              Text(item!['title'], style: const TextStyle(fontSize: 15)),
              Text(item!['author'], style: const TextStyle(fontSize: 13)),
            ]
          )
          ),
        ],
      )
    );
  }
}


class Item extends StatelessWidget{
  const Item({super.key, required this.item, this.remove, this.setSong});
  final item;
  final remove;
  final setSong;

  @override
  Widget build(BuildContext context){
    return Container(
      width: 1000,
      height: 62,
      margin: EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        border: Border.all(
          width: 1,
          color: Theme.of(context).primaryColor
        ),
        borderRadius: BorderRadius.circular(5),
      ),
      child: InkWell (
        onTap: () => setSong(item['id']),
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item['title'], style: TextStyle(fontSize: 15)),
                    Text(item['author'], style: TextStyle(fontSize: 13)),
                  ]
                ),
              ),
              PopupMenuButton(
                color: Theme.of(context).scaffoldBackgroundColor,
                itemBuilder: (BuildContext context) => [
                    PopupMenuItem(
                      value: 1,
                      child: Text('Добавить в плейлист'),
                      onTap: () => remove(item['id']),
                    ),
                    PopupMenuItem(
                      value: 2,
                      child: Text('Изменить название или автора'),
                      onTap: () => remove(item['id']),
                    ),
                    PopupMenuItem(
                      value: 3,
                      child: const Text('Удалить'),
                      onTap: () => remove(item['id']),
                    ),
                ]),
            ]
          )
        ) 
      )
    );
  }
}
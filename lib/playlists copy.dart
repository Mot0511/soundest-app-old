import 'package:flutter/material.dart';
import 'package:soundest/editPlaylist.dart';
import 'package:soundest/playlistPage.dart';
import 'package:soundest/services/fetchPlaylists.dart';

class Playlists extends StatefulWidget{
  const Playlists({super.key});
  
  State<Playlists> createState() => _Playlists();
}

class _Playlists extends State<Playlists>{
  final login = 'suvorovmatvej9';
  late Future<Map<String, List<int>?>> playlists = getPlaylists(login);

  void updatePlaylists(action, name) async {
    final list = await playlists;
    switch (action){
      case 'creating':
        list[name] = [0];
        createPlaylist(login, name);
      case 'remove':
        list.remove(name);
        removePlaylist(login, name);
      case 'editing':
        list[name[1]] = list[name[0]];
        list.remove(name[0]);
        removePlaylist(login, name[0]);
        createPlaylist(login, name[1]);
    }
    setState(() {
      playlists = inFuture(list);
    });
  }
  void addItem(int id){
    
  }
  Future<Map<String, List<int>>> inFuture (data) async {
    return data;
  }

  @override
  Widget build(BuildContext context){
    return Column(
      children: [
        Expanded(
          child: LayoutBuilder(builder: (context, constraints){
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: FutureBuilder(
                  future: playlists,
                  builder: (BuildContext context, AsyncSnapshot snap){
                    Widget res = CircularProgressIndicator();
                    if (snap.hasData){
                      final data = snap.data;
                      final List<Widget> elements = [];
                      data.forEach((key, value){
                        elements.add(PlaylistItem(name: key, list: value, updatePlaylists: updatePlaylists));
                      });
                      res = Column(
                        children: elements,
                      );
                    }
                    return res;
                  }
                )
              )
            );
          })
        ),
        Center(
          child: OutlinedButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => EditPlaylist(data: '', action: 'creating', updatePlaylists: updatePlaylists))),
            child: const Text('Добавить плейлист'),
          )
        )
      ]
    );
  }
}

class PlaylistItem extends StatelessWidget{
  const PlaylistItem({super.key, required this.name, required this.list, this.updatePlaylists});
  final updatePlaylists;
  final name;
  final list;

  @override
  Widget build(BuildContext context){
    return Container(
      width: 1000,
      height: 80,
      padding: EdgeInsets.only(top: 3),
      margin: EdgeInsets.only(right: 5, bottom: 5),
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).primaryColor,
          width: 1
        ),
        borderRadius: BorderRadius.circular(5),
      ),
      child: InkWell(
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text(name, style: const TextStyle(fontSize: 25))
              )
            ),
            Align(
              alignment: Alignment.centerRight,
              child: PopupMenuButton(
                color: Theme.of(context).scaffoldBackgroundColor,
                itemBuilder: (BuildContext context) => [
                  PopupMenuItem(
                    value: 1,
                    child: Text('Изменить название'),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => EditPlaylist(data: name, action: 'editing', updatePlaylists: updatePlaylists))),
                  ),
                  PopupMenuItem(
                    value: 2,
                    child: Text('Удалить'),
                    onTap: () => updatePlaylists('remove', name),
                  )
                ]
              ),
            )
          ]
        ),
        onTap: (){
          Navigator.push(context, MaterialPageRoute(builder: (context) => PlaylistPage(name: name, list: list)));
        },
      )
    );
  }
}
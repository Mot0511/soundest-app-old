import 'package:flutter/material.dart';
import 'package:soundest/editPlaylist.dart';
import 'package:soundest/playlistPage.dart';
import 'package:soundest/services/fetchPlaylists.dart';
import 'package:soundest/components/playlistItem.dart';

// Страница с плейлистами
class Playlists extends StatefulWidget{
  const Playlists({super.key, required this.login});
  final String login;
  
  State<Playlists> createState() => _Playlists(login: login);
}

class _Playlists extends State<Playlists>{
  _Playlists({required this.login});
  final String login;
  late Future<Map<String, List?>> playlists = getPlaylists(login);

  void updatePlaylists(action, name) async {
    final list = await playlists;
    switch (action){
      case 'creating':
        list[name] = [0];
        createPlaylist(login, name);
        break;
      case 'remove':
        list.remove(name);
        removePlaylist(login, name);
        break;
      case 'editing':
        list[name[1]] = list[name[0]];
        list.remove(name[0]);
        removePlaylist(login, name[0]);
        createPlaylist(login, name[1]);
        break;
    }
    setState(() {
      playlists = inFuture(list);
    });
  }
  Future<Map<String, List>> inFuture (data) async {
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
                    Widget res = const Column(children: [CircularProgressIndicator()]);
                    if (snap.hasData){
                      final data = snap.data;
                      final List<Widget> elements = [];
                      data.forEach((key, value){
                        elements.add(PlaylistItem(name: key, list: value, updatePlaylists: updatePlaylists, login: login));
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
          child: ElevatedButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => EditPlaylist(data: '', action: 'creating', updatePlaylists: updatePlaylists))),
            child: const Text('Добавить плейлист'),
          )
        )
      ]
    );
  }
}

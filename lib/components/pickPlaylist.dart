import 'package:flutter/material.dart';
import 'package:soundest/services/fetchPlaylists.dart';

class PickPlaylist extends StatelessWidget{
  PickPlaylist({super.key, required this.songID, required this.login, required this.item});
  final int songID;
  final String login;
  final Map item;

  late Future<Map<String, List<int>>> playlists = getPlaylists(login);

  @override
  Widget build(BuildContext context){
    return (
      AlertDialog(
        title: const Text('Выберите плейлист'),
        content: Center(
          child: FutureBuilder(
            future: playlists,
            builder: (BuildContext context, AsyncSnapshot<Map<String, List<int>>> snap) {
              if (snap.hasData) {
                final data = snap.data;
                if (data!.isNotEmpty) {
                  List<Widget> widgets = [];
                  data!.forEach((key, value) {
                    widgets.add(
                      PlaylistItem(
                        name: key,
                        id: item['id'],
                        playlists: playlists,
                        login: login));
                  });
                  return Column(
                      children: widgets);
                } else {
                  return const Text('У вас нет плейлистов', style: TextStyle(fontSize: 20));
                }
              } else if (snap.hasError) {
                return const Text('Произошла ошибка', style: TextStyle(fontSize: 20));
              }
              return const CircularProgressIndicator();
              })
            ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, 'Cancel'),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {},
            child: const Text('Добавить'),
          )
        ]
      )
    );
  }
}
class PlaylistItem extends StatelessWidget {
  const PlaylistItem(
      {super.key,
      required this.name,
      required this.id,
      required this.playlists,
      required this.login});
  final name;
  final id;
  final playlists;
  final login;

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(5),
        child: Container(
            width: 1000,
            height: 50,
            decoration: BoxDecoration(
              border:
                  Border.all(width: 1, color: Theme.of(context).primaryColor),
              borderRadius: BorderRadius.circular(5),
            ),
            child: InkWell(
              child: Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: Text(name, style: TextStyle(fontSize: 18)),
                ),
              ),
              onTap: () async {
                addInPlaylist(id, login, name);
                Navigator.pop(context);
              },
            )));
  }
}

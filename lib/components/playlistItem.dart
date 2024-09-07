import 'package:flutter/material.dart';
import 'package:soundest/editPlaylist.dart';
import 'package:soundest/playlistPage.dart';
import 'package:soundest/services/fetchPlaylists.dart';

// Элемент одного плейлиста
class PlaylistItem extends StatelessWidget{
  const PlaylistItem({super.key, required this.name, required this.list, this.updatePlaylists, required this.login});
  final updatePlaylists;
  final name;
  final list;
  final login;

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
          Navigator.push(context, MaterialPageRoute(builder: (context) => PlaylistPage(name: name, list: list, login: login)));
        },
      )
    );
  }
}
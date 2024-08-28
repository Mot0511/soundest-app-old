import 'package:flutter/material.dart';
import 'package:soundest/services/fetchPlaylists.dart';

class EditPlaylist extends StatefulWidget{
  const EditPlaylist({super.key, required this.data, required this.action, required this.updatePlaylists});
  final updatePlaylists;
  final data;
  final action;

  State<EditPlaylist> createState() => _EditPlaylist(data: data, action: action, updatePlaylists: updatePlaylists);
}

class _EditPlaylist extends State<EditPlaylist>{
  final login = 'suvorovmatvej9';

  _EditPlaylist({required this.data, required this.action, required this.updatePlaylists});
  final updatePlaylists;
  final data;
  final action;

  late final name = TextEditingController(text: data);
 

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text((action == 'creating' ? 'Создание ' : 'Изменение ')+name.text)
      ),
      body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  TextFormField(
                    controller: name,
                    decoration: const InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: 'Название'
                    ),
                  ),
                ],
              )
            ),
            OutlinedButton(
              child: const Text('Сохранить'),
              onPressed: () {
                switch (action){
                  case 'creating':
                    updatePlaylists(action, name.text);
                  case 'editing':
                    updatePlaylists(action, [data, name.text]);
                
                }
                Navigator.pop(context);
              },
            )
          ],
        )
    );
  }
}
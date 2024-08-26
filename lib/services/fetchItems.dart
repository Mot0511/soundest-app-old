import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:math';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:glob/glob.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';

Future<void> downloadItem(Map item, String username, BuildContext context) async {
  final songID = item['id'];
  final title = item['title'];
  final author = item['author'];
  
  final fileRef = FirebaseStorage.instance.ref('$username/$songID.mp3');
  final file = File('/storage/emulated/0/Music/$title@$author.mp3');

  final task = fileRef.writeToFile(file);
  task.snapshotEvents.listen((snap) {
    switch (snap.state){
      case TaskState.running:
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Скачивание началось...')));
        break;
      case TaskState.success:
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Музыка скачана')));
        break;
      case TaskState.error:
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Произошла ошибка при скачивании')));
        break;
    }
  });
}

void uploadSong(Map item, Future<List<Map>> oldItems, String username) async {

    final file = File(item['path']);
    final songID = item['id'];

    final fileRef = FirebaseStorage.instance.ref('$username/$songID.mp3');
    await fileRef.putFile(file);

    final DatabaseReference ref = FirebaseDatabase.instance.ref('users/$username/songs/');
    final snap = await ref.get();
    final items = (snap.value as List).toList();
    final Map<String, dynamic> newItem = {
      'id': item['id'],
      'title': item['title'],
      'author': item['author'], 
    };
    items.add(newItem);
    await ref.set(items);

    final title = item['title'];
    final author = item['author'];
    final newpath = path.join(path.dirname(file.path), '$title@$author.mp3');
    file.renameSync(newpath);
}

Future<List<Map>> getItems(String login) async {
  DatabaseReference ref = FirebaseDatabase.instance.ref('/users/$login/songs/');
  final snap = await ref.get();
  final data = snap.value;

  List<Map<String, dynamic>> res = [];
  
  if (data != null){
    (data as List).forEach((value){
      Map<String, dynamic> item = {};
      (value as Map).forEach((key, value) {
        item[key] = value;
      });
      res.add(item);
    });
  }
  final status = await Permission.storage.request();
  if (status.isGranted) {
    final Directory dir = Directory('/storage/emulated/0/Music');
    final List<FileSystemEntity> entities = dir.listSync(recursive: true, followLinks: true);
    entities.forEach((entity) {
      final path = entity.path;
      if (path.endsWith('.mp3')){
        final songID = 1 + Random().nextInt(4294967296 - 1);
        final displayName = path.split('/').last;
        if (displayName.indexOf('@') != -1){
          final title = displayName.split('@')[0];
          final author = displayName.split('@')[1].split('.')[0];
          res.add({
            'id': songID,
            'title': title,
            'author': author,
            'path': path
          });
        } else {
          res.add({
            'id': songID,
            'title': displayName,
            'author': '',
            'path': path
          });
        }

        for (var i = 0; i < res.length; i++){
          for (var j = 0; j < res.length; j++){
            if (res[i]['title'] == res[j]['title'] && !res[i].containsKey('path') && res[i]['id'] != res[j]['id']){
              res[i]['path'] = res[j]['path'];
              res.removeAt(j);
            }
          }
        }

      }
    });
  } 

  Iterable isReverse = res.reversed;
  List<Map> items = (isReverse.toList() as List<Map>);

  return items;
}

void uploadItems(String login, Future<List<Map>> items) async {
  List<Map> data = await items;
  DatabaseReference ref = FirebaseDatabase.instance.ref('/users/$login/songs/');
  ref.set(data);
}

Future<List<Map>> removeItem(Future<List<Map>> items, int id, String login) async {
  List<Map> oldItems = await items;

  final ref = FirebaseStorage.instance.ref('$login/$id.mp3');
  await ref.delete();

  List<Map> newItems = [];
  oldItems.forEach((item) {
    if (item['id'] != id){
      newItems.add(item);
    }
  });
  return newItems;
}

Future<String> getUrl(String path) async {
  final ref = FirebaseStorage.instance.ref(path);
  final url = await ref.getDownloadURL();
  return url;
}

Future<bool> getIsUploaded(int id, String login) async {
  DatabaseReference ref = FirebaseDatabase.instance.ref('/users/$login/songs/');
  final snap = await ref.get();
  final data = (snap.value as List);
  for (var i = 0; i < data.length; i++){
    if (data[i]['id'] == id){
      return true;
    }
  }
  return false;
}
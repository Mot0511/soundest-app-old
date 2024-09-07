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
import 'package:soundest/services/firebase.dart';
import 'package:soundest/utils/prefs.dart';
import 'package:soundest/utils/showSnackBar.dart';
import '../utils/checkInternet.dart';
import 'package:soundest/services/fetchPlaylists.dart';

// Скачавание трека на устройство
Future<void> downloadItem(Map item, String username, BuildContext context) async {
  final songID = item['id'];
  final title = item['title'];
  final author = item['author'];
  
  final fileRef = FirebaseStorage.instance.ref('$username/$songID.mp3');
  final musicPath = await getPrefs('musicPath');
  final file = File('$musicPath/$title@$author#$songID.mp3');

  final task = fileRef.writeToFile(file);
  showSnackBar('Трек "$title" скачивается...', context);
  task.snapshotEvents.listen((snap) {
    switch (snap.state){
      case TaskState.success:
        showSnackBar('Трек "$title" скачан', context);
        break;
      case TaskState.error:
        showSnackBar('Произошла ошибка при скачивании трека "$title"', context);
        break;
    }
  });
}

// Загрузка трека в облако
void uploadSong(Map item, Future<List<Map>> oldItems, String username, BuildContext context) async {
    final file = File(item['path']);
    final songID = item['id'];
    final title = item['title'];
    final author = item['author'];

    final fileRef = FirebaseStorage.instance.ref('$username/$songID.mp3');
    showSnackBar('Трек "$title" загружается...', context);
    await fileRef.putFile(file).snapshotEvents.listen((snap) {
      switch (snap.state){
        case TaskState.success:
          showSnackBar('Трек "$title" загружен', context);
          break;
        case TaskState.error:
          showSnackBar('Произошла ошибка при загрузке трека "$title"', context);
          break;
      }
    });

    final Map<String, dynamic> newItem = {
      'id': item['id'],
      'title': item['title'],
      'author': item['author'], 
    };

    final refPath = 'users/$username/songs/';
    final data = await getDatabase(refPath);
    if (data != null){
      final items = (data as List).toList();
      items.add(newItem);
      await setDatabase(refPath, items);
    } else {
      await setDatabase(refPath, [newItem]);
    }

    final newpath = path.join(path.dirname(file.path), '$title@$author.mp3');
    file.renameSync(newpath);
}

// Получения списка треков
Future<List<Map>> getItems(String login, BuildContext context) async {
  List<Map<String, dynamic>> res = [];

  if (await internet()){
    // Получение треков из облака
    DatabaseReference ref = FirebaseDatabase.instance.ref('/users/$login/songs/');
    final snap = await ref.get();
    final data = snap.value;

    if (data != null){
      (data as List).forEach((value){
        Map<String, dynamic> item = {};
        (value as Map).forEach((key, value) {
          item[key] = value;
        });
        res.add(item);
      });
    }
  } else {
    showSnackBar('Отсутствует интернет соеднение', context);
  }
  
  // Получение треков из локального хранилища
  final storagePermission = await Permission.storage.request().isGranted;
  final audioPermission = await Permission.audio.request().isGranted;
  final manageStoragePermission = await Permission.manageExternalStorage.request().isGranted;
  if (storagePermission || audioPermission && manageStoragePermission) {
    final musicPath = await getPrefs('musicPath');
    final Directory dir = Directory('$musicPath');
    final List<FileSystemEntity> entities = dir.listSync(recursive: true, followLinks: true);
    entities.forEach((entity) async {
      final filepath = entity.path;
      if (filepath.endsWith('.mp3')){
        final displayName = filepath.split('/').last;
        final songID = displayName.indexOf('#') != -1 ? int.parse(displayName.split('#')[1].split('.')[0]) : 1 + Random().nextInt(4294967296 - 1);
        String newpath = '';
        if (displayName.indexOf('@') != -1){
          final title = displayName.split('@')[0];
          final author = displayName.split('@')[1].split('.')[0].split('#')[0];
          res.add({
            'id': songID,
            'title': title,
            'author': author,
            'path': filepath
          });
          newpath = path.join(path.dirname(filepath), '$title@$author#$songID.mp3');
        } else {
          final title = displayName.split('.')[0];
          res.add({
            'id': songID,
            'title': title,
            'author': '',
            'path': filepath
          });
          newpath = path.join(path.dirname(filepath), '$title#$songID.mp3');
        }
        final musicPath = await getPrefs('musicPath');
        final file = File('$musicPath/$displayName');
        file.renameSync(newpath);
        
        
      }
      
    });
  }
  // Если один и тот же трек есть и в облаке, и на устройстве, появятся повторяющиеся треки
  // Цикл ниже убирает повторяющися треки из списка
  for (var i = 0; i < res.length; i++){
    for (var j = 0; j < res.length; j++){
      if (res[i]['title'] == res[j]['title'] && i != j){
        res[i]['path'] = res[j]['path'];
        res.removeAt(j);
      }
    }
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

// Удаление трека из облака
Future<void> removeFromCloud(Future<List<Map>> items, int id, String login) async {
  final oldItems = (await getDatabase('users/$login/songs') as List);

  final storageRef = FirebaseStorage.instance.ref('$login/$id.mp3');
  await storageRef.delete();

  List<Map> newItems = [];
  oldItems.forEach((item) {
    if (item['id'] != id){
      newItems.add(item);
    }
  });

  final DatabaseReference ref = FirebaseDatabase.instance.ref('users/$login/songs/');
  await ref.set(newItems);

  await removeFromCloudPlaylist(id, login);

}

// Удаление трека с устройства
void removeFromDevice(String path) {
  final file = File(path);
  file.deleteSync();
}

// Удаление трека из передаваемого списка, возвращается измененный список треков
Future<List<Map>> removeItemFromList(Future<List<Map>> items, int id) async { 
  final oldItems = await items;
  List<Map> newItems = [];
  oldItems.forEach((item) {
    if (item['id'] != id){
      newItems.add(item);
    }
  });

  return newItems;
}

// Изменение трека в облаке и на устройстве
void editItem(int id, String login, String filename, String title, String author) async {
  final data = await getDatabase('/users/$login/songs/');

  if (data != null){
    final items = data as List;
    for (var i = 0; i < items.length; i++){
      if (items[i]['id'] == id){
        items[i]['title'] = title;
        items[i]['author'] = author;
      }
    }
    await setDatabase('/users/$login/songs/', items);
  }
  final musicPath = await getPrefs('musicPath');
  final file = File('$musicPath/$filename');
  if (file.existsSync()) {
    final newpath = path.join(path.dirname(file.path), '$title@$author.mp3');
    file.renameSync(newpath);
  }

}

// Поулчение url трека из облака
Future<String> getUrl(String path) async {
  final ref = FirebaseStorage.instance.ref(path);
  final url = await ref.getDownloadURL();
  return url;
}

// Проверка на присутствие трека в облаке
Future<bool> getIsUploaded(int id, String login) async {
  DatabaseReference ref = FirebaseDatabase.instance.ref('/users/$login/songs/');
  final snap = await ref.get();
  if (snap.exists) {
    final data = (snap.value as List);
    for (var i = 0; i < data.length; i++){
      if (data[i]['id'] == id){
        return true;
      }
    }
  }
  
  return false;
}
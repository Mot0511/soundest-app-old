import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:math';
import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

void uploadSong(Map item, Future<List<Map>> oldItems, String username) async {
    final items = await oldItems;
    final file = File(item['path']);
    final songID = 1 + Random().nextInt(4294967296 - 1);

    final storageRef = FirebaseStorage.instance.ref();
    final fileRef = storageRef.child('$username/$songID.mp3');
    await fileRef.putFile(file);

    final title = item['title'];
    final author = item['author'];
    final newpath = path.join(path.dirname(file.path), '$title@$author.mp3');
    file.renameSync(newpath);

    final DatabaseReference ref = FirebaseDatabase.instance.ref('users/$username/songs/');
    final Map<String, dynamic> newItem = {
      'id': item['id'],
      'title': item['title'],
      'author': item['author'],
    };
    items.add(newItem);
    await ref.set(items);
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

  // final path = await MediaStorage.getExternalStoragePublicDirectory(MediaStorage.DIRECTORY_MUSIC);
  // final bool isPermission = await MediaStorage.getRequestStoragePermission();
  // if (isPermission){
  //   final List media = await MediaStorage.getMediaStoreData(path);
  //   media.forEach((song) {
  //     if (song['media_type'] == 2){
  //       final songID = 1 + Random().nextInt(4294967296 - 1);
  //       final displayName = song['displayName'];
  //       if (displayName.indexOf('@') != -1){
  //         final title = displayName.split('@')[0];
  //         final author = displayName.split('@')[1].split('.')[0];
  //         res.add({
  //           'id': songID,
  //           'title': title,
  //           'author': author,
  //           'path': song['filepath']
  //         });
  //       } else {
  //         res.add({
  //           'id': songID,
  //           'title': displayName,
  //           'author': '',
  //           'path': song['filepath']
  //         });
  //       }
  //       for (var i = 0; i < res.length; i++){
  //         for (var j = 0; j < res.length; j++){
  //           if (res[i]['title'] == res[j]['title'] && !res[i].containsKey('path')){
  //             res[i]['path'] = res[j]['path'];
  //             res.removeAt(j);
  //           }
  //         }
  //       }
        
  //     }
  //   });

  // } else {
  //   await MediaStorage.getRequestStoragePermission();
  // }


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
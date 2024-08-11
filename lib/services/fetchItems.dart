import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';

Future<List<Audio>> getQueue(Map firstItem, List<Map> items, String login) async {
  final id = firstItem['id'];

  List<Audio> queue = [];
  items.forEach((item) async {
    queue.add(Audio(await getUrl('$login/$id.mp3')));
  });

  for (var i = 0; i < queue.length; i++){
    if (queue[i].path == firstItem['url']){
      queue.removeAt(i);
    }
  }
  
  queue.insert(0, Audio.network(await getUrl('$login/$id.mp3')));

  return queue;
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

  return res;
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
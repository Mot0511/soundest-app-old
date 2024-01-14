import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';

Future<List<Map<String, dynamic>>> getItems(String login) async {
  DatabaseReference ref = FirebaseDatabase.instance.ref('/users/$login/songs/');
  final snap = await ref.get();
  final data = snap.value;

  List<Map<String, dynamic>> res = [];
  
  if (data != null){
    (data as List).forEach((value){
      Map<String, dynamic> item = {};
      (value as Map).forEach((key, value) => {
        item[key] = value
      });
      res.add(item);
    });
  }
  
  return res;
}

void uploadItems(String login, Future<List<Map<String, dynamic>>> items) async {
  List<Map<String, dynamic>> data = await items;
  DatabaseReference ref = FirebaseDatabase.instance.ref('/users/$login/songs/');
  ref.set(data);
}

Future<List<Map<String, dynamic>>> removeItem(Future<List<Map<String, dynamic>>> items, int id, String login) async {
  List<Map<String, dynamic>> oldItems = await items;

  final ref = FirebaseStorage.instance.ref('$login/$id.mp3');
  await ref.delete();

  List<Map<String, dynamic>> newItems = [];
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
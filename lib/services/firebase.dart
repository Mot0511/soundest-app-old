import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';

Future<Object?> getDatabase(String path) async {
  final DatabaseReference ref = FirebaseDatabase.instance.ref(path);
  final snap = await ref.get();
  final data = snap.value;

  return data;
}
Future<void> setDatabase(String path, data) async {
  final DatabaseReference ref = FirebaseDatabase.instance.ref(path);
  await ref.set(data);
}
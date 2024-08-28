import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:soundest/services/fetchItems.dart';

Future<Map<String, List<int>>> getPlaylists(String login) async {
  DatabaseReference ref = FirebaseDatabase.instance.ref('/users/$login/playlists');
  final snap = await ref.get();
  final data = snap.value;
  Map<String, List<int>> res = {};

  if (data != null){
    (data as Map).forEach((key, value){
      List<int> list = List.from(value);
      res[key] = list;
    });
  }

  return res;
}

Future<List<int>> getPlaylist(String login, String name) async {
  DatabaseReference ref = FirebaseDatabase.instance.ref('/users/$login/playlists/$name');
  final snap = await ref.get();
  final data = (snap.value as List<int>);

  return data;
}

void addInPlaylist(int songID, String login, String name) async {
  final playlist = await getPlaylist(login, name);
  playlist.add(songID);

  DatabaseReference ref = FirebaseDatabase.instance.ref('/users/$login/playlists/$name');
  await ref.set(playlist);
}

List<int> addItem(List<int> list, int id) {
  list.add(id);
  return list;
}

List<int> removeItemFromPlaylist(List<int> list, int id) {
  List<int> newList = [];
  list.forEach((item) {
    if (item != id){
      newList.add(item);
    }
  });

  return newList;
}

void createPlaylist(String login, String name) async {
  DatabaseReference ref = FirebaseDatabase.instance.ref('/users/$login/playlists');
  Map<String, List<int>> playlists = await getPlaylists(login);
  playlists[name] = [0];
  ref.set(playlists);
}

void removePlaylist(String login, String name) {
  DatabaseReference ref = FirebaseDatabase.instance.ref('/users/$login/playlists/$name');
  ref.remove();
}

Future<List<Map>> getItemsByIds(String login, List<int> list, BuildContext context) async {
  final List<Map> items = await getItems(login, context);
  final List<Map> newItems = [];

  list.forEach((id){
    items.forEach((item){
      if (item['id'] == id){
        newItems.add(item);
      }
    });
  });

  return newItems;
}
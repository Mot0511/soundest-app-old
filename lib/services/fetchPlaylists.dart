import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:soundest/services/fetchItems.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:soundest/utils/checkInternet.dart';
import 'package:soundest/utils/prefs.dart';

Future<Map<String, List>> getPlaylists(String login) async {
  Map<String, List> playlists = {};
  if (await internet()){
    DatabaseReference ref = FirebaseDatabase.instance.ref('/users/$login/playlists');
    final snap = await ref.get();
    final data = snap.value;

    if (data != null){
      (data as Map).forEach((key, value){
        List<int> list = List.from(value);
        playlists[key] = list;
      });
    }
  }

  final String? localPlaylistsRaw = await getPrefs('playlists');
  var localPlaylists = {};
  if (localPlaylistsRaw != null){
    localPlaylists = jsonDecode(localPlaylistsRaw);
  } else {
    localPlaylists = {};
  }

  final Set<String> playlistsSet = (playlists.entries.map((playlist) => playlist.key)).toSet();
  final Set localPlaylistsSet = (localPlaylists.entries.map((playlist) => playlist.key)).toSet();

  final playlistsIntersection = playlistsSet.intersection(localPlaylistsSet);
  final Map<String, List> res = {};
  playlistsIntersection.forEach((playlist) {
    playlistsSet.remove(playlist);
    localPlaylistsSet.remove(playlist);
    final songs = playlists[playlist];
    final localSongs = localPlaylists[playlist];
    Set songsIntersection = {};
    if (songs != null && localSongs != null){
      final songsIntersection = songs.toSet().union(localSongs.toSet());
      res[playlist] = songsIntersection.toList();
    }
    
  });

  playlistsSet.forEach((playlist) {
    final songs = playlists[playlist];
    if (songs != null){
      res[playlist] = songs;
    }
  });

  localPlaylistsSet.forEach((playlist) {
    final songs = playlists[playlist];
    if (songs != null){
      res[playlist] = songs;
    }
  });

  return res;
}

Future<List> getPlaylist(String login, String name) async {
  DatabaseReference ref = FirebaseDatabase.instance.ref('/users/$login/playlists/$name');
  final snap = await ref.get();
  final data = (snap.value as List).toList();

  return data;
}

void addInPlaylist(int songID, String login, String name) async {
  final playlist = await getPlaylist(login, name);
  playlist.add(songID);

  DatabaseReference ref = FirebaseDatabase.instance.ref('/users/$login/playlists/$name');
  await ref.set(playlist);

  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final String? localPlaylistsRaw = prefs.getString('playlists');
  if (localPlaylistsRaw != null){
    final localPlaylists = jsonDecode(localPlaylistsRaw);
    localPlaylists[name].add(songID);
    prefs.setString('playlists', jsonEncode(localPlaylists));
  }
}

List<int> addItem(List<int> list, int id) {
  list.add(id);
  return list;
}

Future<void> removeFromCloudPlaylist(int id, String login) async {
  final DatabaseReference playlistsRef = FirebaseDatabase.instance.ref('users/$login/playlists/');
  final snap = await playlistsRef.get();
  final data = (snap.value as Map);

  for (final el in data.entries){
    final items = el.value.toList();
    if (items.contains(id)){
      items.remove(id);
    }
    final playlist = el.key;
    final DatabaseReference playlistRef = FirebaseDatabase.instance.ref('users/$login/playlists/$playlist');
    await playlistRef.set(items);
  }

}

Future<List<int>> removeFromPlaylist(List list, int id, String login, String name) async {
  List<int> newList = [];
  list.forEach((item) {
    if (item != id){
      newList.add(item);
    }
  });

  await removeFromCloudPlaylist(id, login);

  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final String? localPlaylistsRaw = prefs.getString('playlists');
  if (localPlaylistsRaw != null){
    final localPlaylists = jsonDecode(localPlaylistsRaw);
    localPlaylists[name].remove(id);
    prefs.setString('playlists', jsonEncode(localPlaylists));
  }
  return newList;
}



void createPlaylist(String login, String name) async {
  DatabaseReference ref = FirebaseDatabase.instance.ref('/users/$login/playlists');
  Map<String, List> playlists = await getPlaylists(login);
  playlists[name] = [0];
  ref.set(playlists);

  final String? localPlaylistsRaw = await getPrefs('playlists');
  if (localPlaylistsRaw != null){
    final localPlaylists = jsonDecode(localPlaylistsRaw);
    localPlaylists[name] = [0];
    await setPrefs('playlists', jsonEncode(localPlaylists));
  } else {
    await setPrefs('playlists', '{"$name": [0]}');
  }

}

void removePlaylist(String login, String name) async {
  DatabaseReference ref = FirebaseDatabase.instance.ref('/users/$login/playlists/$name');
  ref.remove();
  
  final String? localPlaylistsRaw = await getPrefs('playlists');
  if (localPlaylistsRaw != null){
    final localPlaylists = jsonDecode(localPlaylistsRaw);
    localPlaylists.remove(name);
    await setPrefs('playlists', jsonEncode(localPlaylists));
  }

  final tmp = await getPrefs('playlists');
}

Future<List<Map>> getItemsByIds(String login, List list, BuildContext context) async {
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
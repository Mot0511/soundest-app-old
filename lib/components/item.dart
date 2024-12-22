import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:soundest/components/pickPlaylist.dart';
import 'package:soundest/components/player.dart';
import 'package:soundest/editItem.dart';
import 'package:soundest/utils/prefs.dart';
import 'package:soundest/utils/showSnackBar.dart';
import '../services/fetchItems.dart';
import 'package:path/path.dart' as path;
import 'dart:io';
import 'package:soundest/themes/dark.dart';

// Элемент одного трека
class Item extends StatefulWidget{
  const Item({super.key, required this.login, required this.item, required this.type});
  final login;
  final item;
  final String type;

  @override
  State<Item> createState() => _Item(login: login, item: item, type: type);

}

class _Item extends State<Item>{
  _Item({required this.item, required this.login, required this.type});
  final login;
  final item;
  final String type;

  bool isLocal = false;
  bool isUploaded = false;

  @override
  void initState() {
    checkStates();
  }

  void checkStates() async {
    /// Инициализация состояний трека
    super.initState();
    // Проверка на присутствие трека на устройстве
    if (item.containsKey('path')){
      isLocal = true;
    }
    // Проверка на присутствие трека в облаке
    if (await getIsUploaded(item['id'], login)){
      isUploaded = true;
    }
    setState(() {});
  }

  void editItem_(String title, String author) async {
    /// Изменения данных трека в состоянии
    final id = item['id'];
    await editItem(item, login, title, author);
    setState(() {
      item['title'] = title;
      item['author'] = author;
      item['path'] = path.join(path.dirname(item['path']), '$title@$author№$id.mp3');
    });
  }

  @override
  Widget build(BuildContext context){
    final PlayerManager playerManager = Provider.of<PlayerManager>(context);
    final setSong = playerManager.setSong;
    final uploadItem = playerManager.uploadItem;
    final removeItem = playerManager.removeItem;
    final removeFromCloud_ = playerManager.removeFromCloud_;
    final removeFromPlaylist_ = playerManager.removeFromPlaylist_()

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
      ),
      child: InkWell (
        onTap: () => setSong(item), 
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item['title'], style: const TextStyle(fontSize: 17)),
                      Text(item['author'], style: const TextStyle(fontSize: 14)),
                    ]
                  ),
                )
              ),
              PopupMenuButton(
                iconColor: Theme.of(context).primaryColor,
                color: Theme.of(context).cardColor,
                itemBuilder: (BuildContext context) => [
                    if (!isLocal && isUploaded && type != 'playlist')
                      PopupMenuItem(
                        textStyle: Theme.of(context).textTheme.bodyMedium,
                        value: 1,
                        child: Text('Скачать на устройство', style: Theme.of(context).textTheme.labelMedium),
                        onTap: () async {
                          await downloadItem(item, login, context);
                          final id = item['id'];
                          final title = item['title'];
                          final author = item['author'];
                          final musicPath = await getPrefs('musicPath');
                          item['path'] = '$musicPath/$title@$author№$id.mp3';
                          isLocal = true;
                          setState(() => {});
                        },
                      ),
                    if (isLocal && !isUploaded && type != 'playlist')
                      PopupMenuItem(
                        value: 1,
                        child: Text('Загрузить в облако', style: Theme.of(context).textTheme.labelMedium),
                        onTap: () {
                          uploadItem(item, context);
                          setState(() => isUploaded = true);
                        },
                      ),
                    if (isLocal && type != 'playlist')
                      PopupMenuItem(
                        value: 1,
                        child: Text('Удалить с устройства', style: Theme.of(context).textTheme.labelMedium),
                        onTap: () {
                          removeFromDevice(item['path']);
                          if (!isUploaded){
                            removeItem(item['id']);
                          }
                          isLocal = false;
                          item.remove('path');
                          setState(() => {});
                          final String title = item['title'];
                          showSnackBar('Трек "$title" удален с устройства', context);
                        },
                      ),
                    if (isUploaded && type != 'playlist')
                      PopupMenuItem(
                        value: 1,
                        child: Text('Удалить из облака', style: Theme.of(context).textTheme.labelMedium),
                        onTap: () {
                          removeFromCloud_(item['id'], context);
                          if (!isLocal){
                            removeItem(item['id']);
                          }
                          setState(() => isUploaded = false);
                        },
                      ),
                    PopupMenuItem(
                      value: 1,
                      child: Text('Добавить в плейлист', style: Theme.of(context).textTheme.labelMedium),
                      onTap: () => showDialog(
                        context: context,
                        builder: (BuildContext context) => PickPlaylist(login: login, item: item)
                      ),
                    ),
                    if (type == 'playlist')
                      PopupMenuItem(
                        value: 1,
                        child: Text('Удалить из плейлиста', style: Theme.of(context).textTheme.labelMedium),
                        onTap: () => removeFromPlaylist_(item['id']),
                      ),
                    PopupMenuItem(
                      value: 2,
                      child: Text('Изменить название или автора', style: Theme.of(context).textTheme.labelMedium),
                        onTap: () => {
                          Navigator.push(
                            context, MaterialPageRoute(
                              builder: (context) => EditItem(data: item, editItem: editItem_)
                            )
                          ),
                        }
                    ),
                ]),
            ]
          )
        )
      )
    );
  }
}
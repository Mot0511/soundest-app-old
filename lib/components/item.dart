import 'package:flutter/material.dart';
import '../services/fetchItems.dart';

class Item extends StatefulWidget{
  const Item({super.key, required this.login, required this.item, required this.remove, required this.setSong, required this.uploadItem});
  final login;
  final item;
  final remove;
  final setSong;
  final uploadItem;

  @override
  State<Item> createState() => _Item(login: login, item: item, remove: remove, setSong: setSong, uploadItem: uploadItem);

}

class _Item extends State<Item>{
  _Item({required this.item, required this.login, required this.remove, required this.setSong, required this.uploadItem});
  final login;
  final item;
  final remove;
  final setSong;
  final uploadItem;

  bool isLocal = false;
  bool isUploaded = false;

  void checkStates() async {
    super.initState();
    if (item.containsKey('path')){
      isLocal = true;
    }
    if (await getIsUploaded(item['id'], login)){
      isUploaded = true;
    }
    setState(() {});
  }

  @override
  void initState() {
    checkStates();
  }

  @override
  Widget build(BuildContext context){
    return Container(
      width: 1000,
      height: 62,
      margin: EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        border: Border.all(
          width: 1,
          color: Theme.of(context).primaryColor
        ),
        borderRadius: BorderRadius.circular(5),
      ),
      child: InkWell (
        onTap: () => setSong(item),
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item['title'], style: TextStyle(fontSize: 15)),
                    Text(item['author'], style: TextStyle(fontSize: 13)),
                  ]
                ),
              ),
              PopupMenuButton(
                color: Theme.of(context).scaffoldBackgroundColor,
                itemBuilder: (BuildContext context) => [
                    if (!isLocal && isUploaded)
                      PopupMenuItem(
                        value: 1,
                        child: Text('Скачать на устройство'),
                        onTap: () async {
                          await downloadItem(item, login, context);
                          setState(() => isLocal == true);
                        },
                      ),
                    if (isLocal && !isUploaded)
                      PopupMenuItem(
                        value: 1,
                        child: Text('Загрузить в облако'),
                        onTap: () {
                          uploadItem(item);
                          setState(() => isUploaded == true);
                        },
                      ),
                    if (isLocal)
                      PopupMenuItem(
                        value: 1,
                        child: Text('Удалить с устройства'),
                        onTap: () {
                          setState(() => isLocal == false);
                        },
                      ),
                    if (isUploaded)
                      PopupMenuItem(
                        value: 1,
                        child: Text('Удалить из облака'),
                        onTap: () {
                          setState(() => isUploaded == false);
                        },
                      ),
                    PopupMenuItem(
                      value: 1,
                      child: Text('Добавить в плейлист'),
                      onTap: () => remove(item['id']),
                    ),
                    PopupMenuItem(
                      value: 2,
                      child: Text('Изменить название или автора'),
                      onTap: () => remove(item['id']),
                    ),
                ]),
            ]
          )
        ) 
      )
    );
  }
}
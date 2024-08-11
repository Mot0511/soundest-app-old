import 'package:flutter/material.dart';


class Item extends StatelessWidget{
  const Item({super.key, required this.item, this.remove, this.setSong});
  final item;
  final remove;
  final setSong;

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
                    PopupMenuItem(
                      value: 3,
                      child: const Text('Удалить'),
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
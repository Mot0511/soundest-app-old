import 'package:flutter/material.dart';
import 'package:soundest/UI/input.dart';

class EditItem extends StatefulWidget{
  const EditItem({super.key, required this.data, this.editItem});
  final data;
  final editItem;

  State<EditItem> createState() => _EditItem(data: data, editItem: editItem);
}

class _EditItem extends State<EditItem>{
  _EditItem({required this.data, this.editItem});
  final data;
  final editItem;

  late final title = TextEditingController(text: data['title']);
  late final author = TextEditingController(text: data['author']);
 
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text('Изменение '+title.text)
      ),
      body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  MyInput(text: 'Название', controller: title),
                  MyInput(text: 'Автор', controller: author),
                ],
              )
            ),
            ElevatedButton(
              child: const Text('Сохранить'),
              onPressed: () {
                final oldTitle = data['title'];
                final oldAuthor = data['author'];
                editItem(data['id'], '$oldTitle@$oldAuthor.mp3', title.text, author.text);
                Navigator.pop(context);
              },
            )
          ],
        )
    );
  }
}
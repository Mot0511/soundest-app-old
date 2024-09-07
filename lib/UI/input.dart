import 'package:flutter/material.dart';

// Кастомное поле ввода
class MyInput extends StatelessWidget{
  const MyInput({super.key, required this.text, required this.controller});
  final String text;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context){
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        border: const UnderlineInputBorder(),
        labelText: text,
        labelStyle: Theme.of(context).textTheme.bodyMedium
      ),
    );
  }
}
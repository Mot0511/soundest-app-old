import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:soundest/utils/showSnackBar.dart';
import './services/fetchItems.dart';
import 'dart:math';
import 'package:assets_audio_player/assets_audio_player.dart';

import 'components/player.dart';
import 'components/item.dart';

// Главная страница с треками
class Home extends StatefulWidget{
  const Home({super.key, required this.login});
  final login;

  State<Home> createState() => _Home(login: login);
}

class _Home extends State<Home>{
  _Home({required this.login});
  final login;

  @override
  Widget build(BuildContext context){
    final PlayerManager playerManager = Provider.of<PlayerManager>(context);
    playerManager.initItems();
    late final Future<List<Map>> items = playerManager.items;


    return Column (
      children: [
        Expanded(
          child: LayoutBuilder(builder: (context, constraints){
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: FutureBuilder<List<Map>>(
                  future: items,
                  builder: (BuildContext context, AsyncSnapshot<List<Map>> snapshot){
                    List<Widget> children;
                    if (snapshot.hasData){
                      final data = snapshot.data;
                      if (data!.isNotEmpty){
                        children = List.generate(data!.length, (index) => Item(login: login, item: data[index], type: 'common'));
                      } else {
                        children = [const Text('У вас пока нет музыки', style: TextStyle(fontSize: 20))];
                      }
                    } else if (snapshot.hasError){
                      final error = snapshot.error;
                      children = [
                        Center(child: Text('$error', style: const TextStyle(fontSize: 20)))
                      ];
                    } else {
                      children = [
                        const Align(
                          alignment: Alignment.center,
                          child: CircularProgressIndicator()
                        )
                      ];
                    }
                    return Column(
                      children: children,
                    );
                  }
                )
              )
            );
          }),
        ),
        
      ],
    );
  }
}





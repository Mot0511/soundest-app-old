import 'package:flutter/material.dart';
import './home.dart';
import './playlists.dart';

class NavBar extends StatefulWidget{
  const NavBar({super.key});

  @override
  State<NavBar> createState() => _NavBar();
}

class _NavBar extends State<NavBar>{
  int page = 0;

  void onTap(int index){
      setState((){
        page = index;
      });
  }

  static const List<Widget> Pages = <Widget>[
    Home(),
    Playlists(),
  ];

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: const Text('Soundest')),
      body: Container(child: Pages.elementAt(page), padding: const EdgeInsets.all(10)),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Моя музыка'
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.content_copy),
            label: 'Плейлисты'
          ),
        ],
        currentIndex: page,
        selectedItemColor: Theme.of(context).primaryColor,
        onTap: onTap
      ),
    );
  }
}
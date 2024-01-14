import 'package:flutter/material.dart';
import './home.dart';
import './playlists.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const Soundest());
}

class Soundest extends StatelessWidget {
  const Soundest({super.key});

  @override
  Widget build(BuildContext context){
    return MaterialApp(
      title: 'Soundest',
      theme: ThemeData(
        primaryColor: Color.fromARGB(255, 0, 0, 0),
        scaffoldBackgroundColor: Color.fromARGB(255, 255, 255, 255),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
        )
      ),
      home: NavBar()
    );
  }
}

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
      appBar: AppBar(title: Text('Soundest')),
      body: Container(child: Pages.elementAt(page), padding: EdgeInsets.all(10)),
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
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:soundest/components/player.dart';
import 'package:soundest/settings.dart';
import 'package:soundest/themes/dark.dart';
import 'package:soundest/themes/light.dart';
import 'package:soundest/utils/prefs.dart';
import './signin.dart';
import './home.dart';
import './playlists.dart';
import './services/fetchItems.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);


  runApp(const Soundest());
}

class Soundest extends StatelessWidget {
  const Soundest({super.key});

  @override
  Widget build(BuildContext context){
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => PlayerManager(context))
      ],
      child: MaterialApp(
        title: 'Soundest',
        theme: lightTheme,
        darkTheme: darkTheme,
        themeMode: ThemeMode.system,
        home: const NavBar()
      ),
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
  var isSigned;
  static String username = '';

  @override
  void initState() {
    super.initState();
    getLogin();
    initMusicPath();
  }

  Future<void> initMusicPath() async {
    final String? musicPath = await getPrefs('musicPath');
    if (musicPath == null) {
      await setPrefs('musicPath', '/storage/emulated/0/Music');
    }
  }

  Future<void> getLogin() async {
    final String? login = await getPrefs('login');
    if (login != null){
      isSigned = true;
      username = login;
    } else {
      isSigned = false;
    }
    setState(() {});
  }

  void logout() async {
    await removePrefs('login');
    setState(() { 
      isSigned = false;
      username = '';
    });
  }


  void setIsSigned(bool state, String login) {
    setState(() {
      isSigned = state;
      username = login;
    });
  }

  void onTap (int index){
    setState((){
      page = index;
    });
  }

  static List<Widget> Pages = <Widget>[
    Home(login: username),
    Playlists(login: username),
  ];

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: const Text('Soundest'),
        actions: [
          Builder(builder: (BuildContext context) {
            if (isSigned == true) {
              return PopupMenuButton(
                iconColor: Theme.of(context).primaryColor,
                color: Theme.of(context).cardColor,
                itemBuilder: (BuildContext context) => [
                if (Platform.isAndroid)
                PopupMenuItem(
                  onTap: () => Navigator.push(context, MaterialPageRoute(
                    builder: (context) => Settings())),
                  child: Text('Настройки', style: Theme.of(context).textTheme.labelMedium)
                ),
                PopupMenuItem(
                  onTap: logout,
                  child: Text('Выйти из аккаунта', style: Theme.of(context).textTheme.labelMedium)
                ),
              ]
              );
            } else {
              return const SizedBox.shrink();
            }
          })
        ]
      ),
      body: Container(
        padding: const EdgeInsets.all(0),
        child: (isSigned == true 
          ? Column(
            children: [
              Pages.elementAt(page),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 15),
                child: FutureBuilder(
                  future: Provider.of<PlayerManager>(context).items,
                  builder: (BuildContext context, AsyncSnapshot<List<Map>> snapshot){
                    Widget children = const SizedBox.shrink();
                    if (snapshot.hasData){
                      final data = snapshot.data;
                      if (data!.isNotEmpty){
                        children = SizedBox(
                          height: 101,
                          child: Player()
                        );
                      }
                    }
                    return children;
                  }
                )
              )
            ],
          )
          : isSigned == false 
            ? Signin(setIsSigned: setIsSigned) 
            : isSigned == null 
              ? const Align(
                  alignment: Alignment.center,
                  child: CircularProgressIndicator()
                ) 
              : const SizedBox.shrink()),
      ),
      bottomNavigationBar: Builder(builder: (context) {
        if (isSigned == true) {
          return BottomNavigationBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Моя музыка',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.content_copy),
                label: 'Плейлисты'
              ),
            ],
            currentIndex: page,
            backgroundColor: Theme.of(context).colorScheme.secondary,
            selectedItemColor: Theme.of(context).colorScheme.primary,
            onTap: onTap
          );
        } else {
          return const SizedBox.shrink();
        }
      })
    );
  }
}
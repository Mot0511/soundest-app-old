import 'dart:io';
import 'package:flutter/material.dart';
import './signin.dart';
import './home.dart';
import './playlists.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:math';

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
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
        )
      ),
      home: const NavBar()
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
  }

  Future<void> getLogin() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? login = prefs.getString('login');
    if (login != null){
      isSigned = true;
      username = login;
    } else {
      isSigned = false;
    }
    setState(() {});
  }

  void logout() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('login');
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

  void uploadFiles() async {
    final songID = 1 + Random().nextInt(9999999999999 - 1);

    FilePickerResult? result = await FilePicker.platform.pickFiles(allowMultiple: true, type: FileType.audio);
    if (result != null){
      List<File?> files = result.paths.map((path) => File(path!)).toList();

      final storageRef = FirebaseStorage.instance.ref();
      final DatabaseReference ref = FirebaseDatabase.instance.ref();
      files.forEach((file) async {
        if (file != null){
          final fileRef = storageRef.child('$username/$songID.mp3');
          await fileRef.putFile(file);
          await ref.set({

          });
        }
      });
    }

  }

  void onTap (int index){
    setState((){
      page = index;
    });
  }

  static List<Widget> Pages = <Widget>[
    Home(login: username),
    Playlists(),
  ];

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: const Text('Soundest'),
        actions: [
          Builder(builder: (BuildContext context) {
            if (isSigned == true) {
              return PopupMenuButton(itemBuilder: (BuildContext context) => [
                PopupMenuItem(
                  onTap: uploadFiles,
                  child: const Text('Загрузить музыку')
                ),
                PopupMenuItem(
                  onTap: logout,
                  child: const Text('Выйти из аккаунта')
                )
              ]
              );
            } else {
              return const SizedBox.shrink();
            }
          })
        ]
      ),
      body: Container(
        padding: const EdgeInsets.all(10),
        child: (isSigned == true 
          ? Pages.elementAt(page) 
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
          );
        } else {
          return const SizedBox.shrink();
        }
      })
    );
  }
}
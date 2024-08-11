import 'package:flutter/material.dart';
import 'package:soundest/navbar.dart';
import './home.dart';
import './playlists.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);


  runApp(const Soundest());
}

class Soundest extends StatelessWidget {
  const Soundest({super.key});

  signIn() async {
    
    // final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

    // final credential = GoogleAuthProvider.credential(
    //   accessToken: googleAuth?.accessToken,
    //   idToken: googleAuth?.idToken,
    // );

    // return await FirebaseAuth.instance.signInWithCredential(credential);
  }

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
      home: Scaffold(
        appBar: AppBar(title: const Text('Soundest')),
        body: Align(
          child: ElevatedButton(child: Text('Войти через Google'), onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const NavBar(),
              ),
            );
          }),
          alignment: Alignment.center,
        )
      )
    );
  }
}

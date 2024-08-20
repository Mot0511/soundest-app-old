import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Signin extends StatelessWidget {
  const Signin({super.key, required this.setIsSigned});
  final setIsSigned;

  void signin () async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    // Once signed in, return the UserCredential
    final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
    final email = userCredential.user?.email;
    final login = email?.split('@')[0];

    DatabaseReference ref = FirebaseDatabase.instance.ref('/users/$login');
    final snap = await ref.get();
    final data = snap.value;

    if (data == null){
      await ref.set({
        "email": email,
      });
    }

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    
    if (login != null){
      await prefs.setString('login', login);
    }
    
    setIsSigned(true, login);
  }

  @override
  Widget build(BuildContext context){
    return Align(
      alignment: Alignment.center,
      child: ElevatedButton(
        onPressed: signin,
        child: const Text('Войти через Google'),
      )
    );
  }
}
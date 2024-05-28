import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_snake_game/home.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyCjKlCezXSjlh2YYUPgMhmo1T4mTOj003o",
      appId: "1:288819926248:android:3535880d14f0d601a5a55d",
      messagingSenderId: "288819926248",
      projectId: "snakegame-d526c",
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter game',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
          brightness: Brightness.dark
      ),
      themeMode: ThemeMode.dark,
      home: Home(),
    );
  }
}

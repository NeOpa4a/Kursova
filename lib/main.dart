import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:nova_poshta/pages/MainPages.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:html';
import 'dart:js' as js;

void main() async {
    WidgetsFlutterBinding.ensureInitialized();
  // final firebaseConfig = js.context['firebaseConfig'];

  // final firebaseConfig = window.firebaseConfig;

  final firebaseConfig = js.context['firebaseConfig'];

  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: firebaseConfig['apiKey'],
      authDomain: firebaseConfig['authDomain'],
      projectId: firebaseConfig['projectId'],
      storageBucket: firebaseConfig['storageBucket'],
      messagingSenderId: firebaseConfig['messagingSenderId'],
      appId: firebaseConfig['appId'],
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
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const Mainpage(),
    );
  }
}


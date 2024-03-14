import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:furniture_placer/home_page.dart';


Future<void> main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
  } on Exception catch (e) {
    debugPrint(e.toString());
  }
    runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Furniture Placer',
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

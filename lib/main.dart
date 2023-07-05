import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:s2_0705/Screens/FlashScreen.dart';
import 'package:s2_0705/Screens/HomeScreen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home: FlashPage(),
      routes: {
        "/home":(context)=>HomeScreen()
      },
    );
  }
}

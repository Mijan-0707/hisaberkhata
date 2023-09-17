import 'package:flutter/material.dart';
import 'package:hisaberkhata/appdata/appdata.dart';
import 'package:hisaberkhata/screens/homescreen.dart';
import 'package:hisaberkhata/screens/inherited_widget.dart';
import 'package:hisaberkhata/screens/newhomescreen.dart';
// import 'package:hisaberkhata/screens/studentlist.dart';
// import 'package:hisaberkhata/screens/studentprofile.dart';

main() {
  runApp(AppDataProvider(
    appData: AppData(),
    child: MaterialApp(
      theme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    ),
  ));
}

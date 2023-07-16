import 'package:flutter/material.dart';
import 'package:hisaberkhata/screens/homescreen.dart';
import 'package:hisaberkhata/screens/studentlist.dart';
import 'package:hisaberkhata/screens/studentprofile.dart';

main() {
  runApp(MaterialApp(
    theme: ThemeData.dark(),
    debugShowCheckedModeBanner: false,
    home: HomeScreen(),
  ));
}

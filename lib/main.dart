import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisaberkhata/appdata/appdata.dart';
import 'package:hisaberkhata/screens/homescreen.dart';
import 'package:hisaberkhata/screens/inherited_widget.dart';
// import 'package:hisaberkhata/screens/studentlist.dart';
// import 'package:hisaberkhata/screens/studentprofile.dart';

main() {
  runApp(BlocProvider<AppDataCubit>(
    create: (context) => AppDataCubit(AppData()),
    child: MaterialApp(
      theme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    ),
  ));
}

class AppDataCubit extends Cubit<AppData> {
  AppDataCubit(this.data) : super(data);
  final AppData data;
}

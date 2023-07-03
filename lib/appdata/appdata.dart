import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppData {
  Future<File> get _localFile async {
    final directory = await getExternalStorageDirectory();
    return File('$directory/hisaberkhata_backup.txt');
  }

  Future<List<String>> getData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var studentBatchJsonE = prefs.getString('studentBatchJsonE');
    print(json);
    if (studentBatchJsonE == null || studentBatchJsonE.isEmpty) return [];
    List<dynamic> studentBatchJsonD = jsonDecode(studentBatchJsonE);
    final studentBatch = <String>[];
    for (int i = 0; i < studentBatchJsonD.length; i++) {
      studentBatch.add(studentBatchJsonD[i]);
    }
    return studentBatch;
  }

  void backup() async {
    final file = await _localFile;
    print(file.path);
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var studentBatchJsonD = prefs.getString('studentBatchJsonE');
    if (studentBatchJsonD == null) return;
    print(studentBatchJsonD);
    List<dynamic> studentBatchJsonE = jsonDecode(studentBatchJsonD);

    Map<String, dynamic> sajhj = {};
    for (int i = 0; i < studentBatchJsonE.length; i++) {
      final batch = studentBatchJsonE[i];
      final students = prefs.getString(batch);
      print([batch, students]);
      sajhj[batch] = students;
    }
    var backupString = jsonEncode(sajhj);
    print(backupString);
    // Write the file
    file.writeAsString(backupString);
  }

  Future<void> retore() async {
    try {
      final file = await _localFile;

      // Read the file
      final backupString = await file.readAsString();
      final backupStringD = jsonDecode(backupString) as Map?;
      if (backupStringD == null) return;
      print(backupString);
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final keys = backupStringD.keys.toList();

      for (int i = 0; i < keys.length; i++) {
        print(backupStringD[keys[i]]);

        await prefs.setString(keys[i], backupStringD[keys[i]]);
      }
      await prefs.setString('studentBatchJsonE', jsonEncode(keys));
    } catch (e) {
      print(e);
    }
  }
}

class StudenDetails {
  StudenDetails(
      {required this.name,
      required this.mobile,
      required this.address,
      required this.roll,
      required this.payment,
      required this.studentBatch});

  String name, mobile, address, roll, payment, studentBatch;

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'address': address,
      'mobile': mobile,
      'roll': roll,
      'payment': payment,
      'studentBatch': studentBatch
    };
  }

  @override
  String toString() {
    return '$name, $mobile, $address';
  }
}

final payedMonth = [];

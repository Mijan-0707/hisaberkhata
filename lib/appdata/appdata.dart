import 'dart:convert';
import 'dart:io';

import 'package:hisaberkhata/constants/constants.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppData {
  Future<File> get _localFile async {
    var status = await Permission.storage.status;
    if (!status.isGranted) await Permission.storage.request();

    final Directory dir;
    if (Platform.isAndroid) {
      dir = Directory('/storage/emulated/0/Download/HK_backup');
    } else {
      dir = await getApplicationDocumentsDirectory();
    }
    final f = File('${dir.path}/data.json');
    if (!(await f.exists())) await f.create(recursive: true);
    return f;
  }

  Future<List<String>> getData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final batchNamesStr = prefs.getString(PreferenceConstants.batchNameKey);

    if (batchNamesStr == null || batchNamesStr.isEmpty) return [];
    List<dynamic> batchNames = jsonDecode(batchNamesStr);
    final studentBatch = <String>[];
    for (int i = 0; i < batchNames.length; i++) {
      studentBatch.add(batchNames[i]);
    }
    return studentBatch;
  }

  void createBackup() async {
    final file = await _localFile;
    print(file.path);
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var batchNamesStr = prefs.getString(PreferenceConstants.batchNameKey);
    if (batchNamesStr == null) return;
    List<dynamic> batchNames = jsonDecode(batchNamesStr);

    Map<String, dynamic> data = {};
    for (int i = 0; i < batchNames.length; i++) {
      final batch = batchNames[i];
      final studentsStr = prefs.getString(batch);
      if (studentsStr == null) continue;
      final students = jsonDecode(studentsStr);
      print([batch, students]);
      data[batch] = students;
    }

    var backupStr = jsonEncode(data);
    print(backupStr);
    file.writeAsString(backupStr);
  }

  Future<void> restoreData() async {
    try {
      final file = await _localFile;

      // Read the file
      final backupStr = await file.readAsString();
      if (backupStr.isEmpty) return;

      final dataMap = jsonDecode(backupStr) as Map?;
      if (dataMap == null || dataMap.isEmpty) return;

      print(backupStr);
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final keys = dataMap.keys.toList();
      await prefs.setString(PreferenceConstants.batchNameKey, jsonEncode(keys));

      for (int i = 0; i < keys.length; i++) {
        await prefs.setString(keys[i], dataMap[keys[i]]);
      }
    } catch (e) {
      print(e);
    }
  }
}

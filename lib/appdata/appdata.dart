import 'dart:convert';
import 'dart:io';

import 'package:hisaberkhata/appdata/student_details_data_model.dart';
import 'package:hisaberkhata/constants/constants.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppData {
  Future<File?> get _localFile async {
    var status = await Permission.storage.status;
    if (!status.isGranted) await Permission.storage.request();
    if (!status.isGranted) return null;
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

  Future<List<String>> getBatchNames() async {
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

  Future createBatchName(String batch, List studentBatch) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (batch == '') return;
    studentBatch.add(batch);
    var studentBatchJsonE = jsonEncode(studentBatch);
    // print(batchName);
    await prefs.setString(PreferenceConstants.batchNameKey, studentBatchJsonE);
  }

  Future<void> updateBatchName(String old, String newName) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final batchNamesStr = prefs.getString(PreferenceConstants.batchNameKey);
    print('batchname: ${batchNamesStr}');
    // list of batch names
    if (batchNamesStr == null || batchNamesStr.isEmpty) return;
    List<dynamic> batchNames = jsonDecode(batchNamesStr);
    final studentBatch = <String>[];
    for (int i = 0; i < batchNames.length; i++) {
      if (batchNames[i] == old) {
        batchNames[i] = newName;
      }
      studentBatch.add(batchNames[i]);
    }
     print('studentBatch: ${studentBatch}');

    var res = jsonEncode(studentBatch);
    print('res  ${res}, $newName');
    prefs.setString(PreferenceConstants.batchNameKey, res);
    // find the old item and replace with the new one

    final oldBatchnamesJson = prefs.getString(old);
    if (oldBatchnamesJson == null) return;
    print('new name : ${[old, newName]}');
    prefs.setString(newName, oldBatchnamesJson);
    prefs.remove(old);
// prefs.remove(old);
  }
  Future<void>deleteBatchName(String batchName)async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final batchNamesStr = prefs.getString(PreferenceConstants.batchNameKey);
    if (batchNamesStr == null || batchNamesStr.isEmpty) return;
    List<dynamic> batchNames = jsonDecode(batchNamesStr);
    final studentBatch = <String>[];
    for (int i = 0; i < batchNames.length; i++) {
      if (batchNames[i] != batchName) {
       studentBatch.add(batchNames[i]);
      }
    }
   var res = jsonEncode(studentBatch);
    prefs.setString(PreferenceConstants.batchNameKey, res);
    prefs.remove(batchName);
print('deleted: $batchName, $res');
  }

  Future<List<StudentDetails>> getStudents(String batch) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final studentsListStr = prefs.getString(batch);

    if (studentsListStr == null || studentsListStr.isEmpty) return [];
    List<dynamic> studentsList = jsonDecode(studentsListStr);
    final students = <StudentDetails>[];
    for (int i = 0; i < studentsList.length; i++) {
      final s = StudentDetails(
        name: studentsList[i]['name'],
        mobile: studentsList[i]['mobile'],
        address: studentsList[i]['address'],
        roll: studentsList[i]['roll'],
        payment: studentsList[i]['payment'],
        batch: studentsList[i]['studentBatch'],
      );

      final records = studentsList[i]['paymentHistory'] as List?;
      // records.forEach(s.paymentHistory.add);
      // records.forEach((value) {
      //   s.paymentHistory.add(value);
      // });

      if (records != null) {
        for (var r in records) {
          s.paymentHistory.add(r as String);
        }
      }
      students.add(s);
    }
    return students;
  }

  Future<StudentDetails> getStudentDetails(String batchName, int index) async {
    final students = await getStudents(batchName);
    return students[index];
  }

  void createBackup() async {
    final file = await _localFile;
    if (file == null) return;
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
      if (file == null) return;
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

  Future<void> updateStudentDetails(
      String batchName, int index, StudentDetails details) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final studentsListStr = prefs.getString(batchName);
    if (studentsListStr == null || studentsListStr.isEmpty) return;
    List<dynamic> studentsList = jsonDecode(studentsListStr);
    studentsList[index] = details.toJson();
    await prefs.setString(batchName, jsonEncode(studentsList));
  }
}

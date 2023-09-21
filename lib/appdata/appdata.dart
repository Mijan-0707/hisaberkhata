import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:hisaberkhata/appdata/student_details_data_model.dart';
import 'package:hisaberkhata/constants/constants.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppData {
  List<String> payableMonths = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
  ];
  ValueNotifier<List<String>> studentBatch = ValueNotifier([]);
  ValueNotifier<List<StudentDetails>> students = ValueNotifier([]);

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
    this.studentBatch.value = studentBatch;
    return studentBatch;
  }

  Future createBatchName(String batch) async {
    batch = batch.trim();
    if (batch == '') return;
    studentBatch.value.add(batch);
    studentBatch.notifyListeners();

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final batches = await getBatchNames();
    batches.add(batch);
    var studentBatchJsonE = jsonEncode(batches);
    await prefs.setString(PreferenceConstants.batchNameKey, studentBatchJsonE);
  }

  Future addNewStudent(String batch, StudentDetails studentInfo) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (studentInfo == null) return;
    final students = await getStudents(batch);
    students.add(studentInfo);
    this.students.value = students;
    await prefs.setString(batch, jsonEncode(students));
  }

  Future<void> updateBatchName(String old, String newName) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final batchNamesStr = prefs.getString(PreferenceConstants.batchNameKey);
    // print('batchname: ${batchNamesStr}');
    // list of batch names
    if (batchNamesStr == null || batchNamesStr.isEmpty) return;
    List<dynamic> batchNames = jsonDecode(batchNamesStr);
    final studentBatch = <String>[];
    for (int i = 0; i < batchNames.length; i++) {
      newName.trim();
      if (newName == '') return;
      if (batchNames[i] == old) {
        batchNames[i] = newName;
      }
      studentBatch.add(batchNames[i]);
      this.studentBatch.value = studentBatch;
    }
    // print('studentBatch: ${studentBatch}');

    var res = jsonEncode(studentBatch);
    // print('res  ${res}, $newName');
    prefs.setString(PreferenceConstants.batchNameKey, res);
    // find the old item and replace with the new one

    final oldBatchnamesJson = prefs.getString(old);
    if (oldBatchnamesJson == null) return;
    // print('new name : ${[old, newName]}');
    prefs.setString(newName, oldBatchnamesJson);
    prefs.remove(old);
  }

  Future<void> deleteBatchName(String batchName) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove(batchName);
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
    studentBatch.remove(batchName);

    this.studentBatch.value = studentBatch;

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
        section: studentsList[i]['section'],
        payment: studentsList[i]['payment'],
        batch: studentsList[i]['studentBatch'],
      );

      final records = studentsList[i]['paymentHistory'] as List?;
      if (records != null) {
        for (var r in records) {
          s.paymentHistory.add(r as String);
        }
      }
      students.add(s);
    }
    this.students.value = students;
    // print(batch);
    // print(students.);
    return students;
  }

  Future<StudentDetails> getStudentDetails(String batchName, int index) async {
    // final students = await getStudents(batchName);
    return students.value[index];
  }

  void createBackup() async {
    // final file = await _localFile;
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

    final path = await getTemporaryDirectory();
    final file = File('${path.path}/hisaberkhata_backup.txt');
    file.writeAsString(backupStr);
    await Share.shareXFiles([
      XFile(
        '${path.path}/hisaberkhata_backup.txt',
        name: 'hisaberkhata_backup',
        mimeType: 'application/json',
      )
    ]);
  }

  Future<void> restoreData() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['txt', 'json'],
      );
      if (result == null) return;
      final f = File(result.files.first.path!);
      print(f);
      final dataStr = File(f.path!).readAsStringSync();
      print('dataStr: $dataStr');
      if (dataStr.isEmpty) return;

      final dataMap = jsonDecode(dataStr) as Map?;
      if (dataMap == null || dataMap.isEmpty) return;

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final keys = dataMap.keys.toList();
      await prefs.setString(PreferenceConstants.batchNameKey, jsonEncode(keys));

      for (int i = 0; i < keys.length; i++) {
        await prefs.setString(keys[i], dataMap[keys[i]]);
      }
      await getBatchNames();
    } catch (e) {
      // print(e);
    }
  }

  Future<void> updateStudentDetails(
      String batchName, int index, StudentDetails details) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final studentsListStr = prefs.getString(batchName);
    if (studentsListStr == null || studentsListStr.isEmpty) return;
    List<dynamic> studentsList = jsonDecode(studentsListStr);
    studentsList[index] = details.toJson();
    students.value[index] = details;
    students.notifyListeners();
    await prefs.setString(batchName, jsonEncode(studentsList));
  }

  void savePaymentHistory(StudentDetails details) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final paymentHistoryJson = jsonEncode(details.paymentHistory);
    prefs.setString(details.batch + details.name, paymentHistoryJson);
  }

  void deleteStudentDetails(String batchName, int studentIndex) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final studentsListStr = prefs.getString(batchName);
    if (studentsListStr == null || studentsListStr.isEmpty) return;
    List<dynamic> studentsList = jsonDecode(studentsListStr);
    // print(studentIndex);
    // print(studentsList);
    studentsList.removeAt(studentIndex);
    students.value.removeAt(studentIndex);
    students.notifyListeners();
    // print(studentsList);
    await prefs.setString(batchName, jsonEncode(studentsList));
  }
}

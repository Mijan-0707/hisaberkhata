import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:hisaberkhata/appdata/student_details_data_model.dart';
import 'package:hisaberkhata/constants/constants.dart';
import 'package:hisaberkhata/core/data_model/batch.dart';
import 'package:hisaberkhata/core/data_model/transaction.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/data_model/student.dart';

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
  // ValueNotifier<List<Batch>> studentBatch = ValueNotifier([]);
  // ValueNotifier<List<Student>> students = ValueNotifier([]);
  // ValueNotifier<List<Student>> tempStudents = ValueNotifier([]);
  Student student = Student();

  Isar? isar;
  Future<void> initialize() async {
    final dir = await getTemporaryDirectory();
    isar = await Isar.open([StudentSchema, BatchSchema], directory: dir.path);
  }

  // Future<void> getBatches() async {
  //   List<Batch>? batchs = await isar?.batchs.where().findAll();
  //   if (batchs != null) studentBatch.value = batchs;
  //   print(batchs);
  // }

  Future createBatch(Batch batch) async {
    // studentBatch.value.add(batch);
    // studentBatch.notifyListeners();
    await isar!.writeTxn(() async {
      await isar!.batchs.put(batch);
    });
  }

  Future<void> addNewStudent(Student student) async {
    print('student name --> ${student.name}');
    await isar!.writeTxn(() async {
      await isar!.students.put(student);
    });
    // students.value.add(student);
    // students.notifyListeners();
    // tempStudents.value.add(student);
    // tempStudents.notifyListeners();
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
      // this.studentBatch.value = studentBatch;
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

    // this.studentBatch.value = studentBatch;

    print('deleted: $batchName, $res');
  }

  Future<void> getStudents() async {
    List<Student>? students = await isar?.students.where().findAll();
    print('--> ${students}');
    if (students != null) {
      // this.students.value = students;
    }
  }

  Future<List<Student>?> getStudentsOnBatch(int batchId) async {
    List<Student>? students =
        await isar?.students.filter().batchIdEqualTo(batchId).findAll();
    print('--> ${students}');
    if (students != null) {
      // tempStudents.value = students;
    }
  }

  void createBackup() async {
    final status = await Permission.manageExternalStorage.request();
    if (!status.isGranted) return;
    isar?.copyToFile('/storage/emulated/0/Download/hisaberkhata_backup.isar');
    // return;
    final downloadDir = Directory('/storage/emulated/0/Download');
    if (!downloadDir.existsSync()) await downloadDir.create(recursive: true);
    final dirExists = downloadDir.existsSync();

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

    if (dirExists) {
      final file = File('${downloadDir.path}/hisaberkhata_backup.txt');
      print(file);
      if (!file.existsSync()) file.createSync();
      print(file.existsSync());
      file.writeAsString(backupStr);
    } else {
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
      file.deleteSync();
    }
  }

  Future<void> restoreData() async {
    print('Restore');
    try {
      final result = await FilePicker.platform.pickFiles(
          // type: FileType.custom,
          // allowedExtensions: ['json', 'txt'],
          );
      // isar!.batchs.importJson(jsonEncode(isar!.batchs.where().findAll()));
      print('result --> ${result}');
      final backupIsar = await Isar.open([StudentSchema, BatchSchema],
          directory: result!.files.first.path!);
      print('${result.files.first.path}');
      await isar!.writeTxn(() async {
        isar!.attachCollections({Student: backupIsar.students});
        print('i am in attachCollection');
      });
      backupIsar.close();
      return;
      if (result == null) return;
      print(result);
      final f = File(result.files.first.path!);
      print(f);
      final dataStr = File(f.path!).readAsStringSync();
      f.deleteSync();
      print('dataStr: $dataStr');
      if (dataStr.isEmpty) return;

      final dataMap = jsonDecode(dataStr) as Map?;
      if (dataMap == null || dataMap.isEmpty) return;

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final keys = dataMap.keys.toList();
      await prefs.setString(PreferenceConstants.batchNameKey, jsonEncode(keys));

      for (String batch in keys) {
        await prefs.setString(batch, jsonEncode(dataMap[batch]));
        // studentBatch.value.add(batch);
      }
      // studentBatch.notifyListeners();
      // await getBatchNames();
    } catch (e) {
      print(e);
    }
  }

  Future<void> updateStudentDetails(Student details) async {
    await isar!.writeTxn(() async {
      await isar!.students.put(details);
    });
    await getStudents();
    await getStudentsOnBatch(details.id);
  }

  void savePaymentHistory(StudentDetails details) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final paymentHistoryJson = jsonEncode(details.paymentHistory);
    prefs.setString(details.batch + details.name, paymentHistoryJson);
  }

  Future<void> deleteStudentDetails(Student details) async {
    await isar!.students.delete(details.id); // delete
    await getStudents();

    return;
  }

  // void deleteStudentDetails(String batchName, int studentIndex) async {
  //   final SharedPreferences prefs = await SharedPreferences.getInstance();
  //   final studentsListStr = prefs.getString(batchName);
  //   if (studentsListStr == null || studentsListStr.isEmpty) return;
  //   List<dynamic> studentsList = jsonDecode(studentsListStr);
  //   // print(studentIndex);
  //   // print(studentsList);
  //   studentsList.removeAt(studentIndex);
  //   students.value.removeAt(studentIndex);
  //   students.notifyListeners();
  //   // print(studentsList);
  //   await prefs.setString(batchName, jsonEncode(studentsList));
  // }

  // Future<List<StudentDetails>> getAllStudents() async {
  //   List<StudentDetails> allStudents = [];
  //   final batchNames = await getBatchNames();
  //   for (int i = 0; i < batchNames.length; i++) {
  //     print(' batchNames --> ${batchNames[i]}');
  //     final students = await getStudents(batchNames[i]);
  //     print('students --> ${students}');
  //     allStudents = [...allStudents, ...students];
  //     print('allStudents Appdata --> ${allStudents}');
  //   }
  //   // allStudents.sort((a, b) => a.name.compareTo(b.name));
  //   this.allStudents.value = allStudents;
  //   return allStudents;
  // }
}

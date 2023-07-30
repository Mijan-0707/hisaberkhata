// import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hisaberkhata/appdata/appdata.dart';
import 'package:hisaberkhata/appdata/student_details_data_model.dart';
import 'package:hisaberkhata/screens/homescreen.dart';
import 'package:hisaberkhata/screens/student_info_screen.dart';
import 'package:hisaberkhata/screens/studentprofile.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// import '../constants/constants.dart';
import '../widgets/profileicon.dart';

class StudentListPage extends StatelessWidget {
  StudentListPage({super.key, required this.batchName});

  String batchName;
  // final appData = AppData();
//   @override
//   State<StudentListPage> createState() => _StudentListPageState();
// }

// class _StudentListPageState extends State<StudentListPage> {
  // List<StudentDetails> students = [];

  // @override
  // void initState() {
  //   super.initState();
  //   AppData().getStudents(widget.batchName).then((value) {
  //     students.addAll(value);
  //     setState(() {});
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    appData.getStudents(batchName);
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => StudentInfoScreen(batchName: batchName),
              ));
          if (result == null) return;
          // appData.students.value.add(result);
          // appData.students.notifyListeners();
          appData.addNewStudent(batchName, result);
        },
      ),
      appBar: AppBar(
          centerTitle: true,
          title: Text(batchName),
          actions: [
            PopupMenuButton(
              itemBuilder: (c) {
                return {'Edit', 'Delete'}.map((String choice) {
                  return PopupMenuItem(
                      onTap: () async {
                        // print(choice);
                        if (choice == 'Edit') {
                          studentListOnTapEdit(context, batchName);
                        } else if (choice == 'Delete') {
                          studentListOnTapDelete(context, batchName);
                        }
                      },
                      value: choice,
                      child: Text(choice));
                }).toList();
              },
            )
          ],
          leading: IconButton(
              onPressed: () {
                Navigator.pop(
                    context,
                    MaterialPageRoute(
                        builder: ((context) => const HomeScreen())));
              },
              icon: const Icon(Icons.arrow_back))),
      body: ValueListenableBuilder(
          valueListenable: appData.students,
          builder: (context, students, _) {
            // print(students.length);
            return ListView(
              children: [
                for (int i = 0; i < students.length; i++)
                  GestureDetector(
                    onTap: () async {
                      await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: ((context) => StudentProfile(
                                    batchName: batchName,
                                    stuIndex: i,
                                  ))));
                    },
                    child: Padding(
                        padding:
                            const EdgeInsets.only(left: 8, right: 8, top: 8),
                        child: ListTile(
                          tileColor: Colors.tealAccent,
                          leading: ProfileIconCreator(name: students[i].name),
                          title: Text('Name: ${students[i].name}'),
                          subtitle: Text('Roll: ${students[i].roll}'),
                          trailing: PopupMenuButton(
                            itemBuilder: (c) {
                              return {'Edit', 'Delete'}.map((String choice) {
                                return PopupMenuItem(
                                    onTap: () async {
                                      // print(choice);
                                      Future.delayed(
                                        const Duration(seconds: 0),
                                        () {
                                          if (choice == 'Edit') {
                                            studentListtileOnTapEdit(context,
                                                students[i], i, batchName);
                                          } else if (choice == 'Delete') {
                                            appData.deleteStudentDetails(
                                                batchName, i);
                                          }
                                        },
                                      );
                                    },
                                    value: choice,
                                    child: Text(choice));
                              }).toList();
                            },
                          ),

                          textColor: Colors.white,
                          // trailing: Checkbox(onChanged: (value) {}, value: true),
                        )),
                  ),
              ],
            );
          }),
    );
  }

  void studentListtileOnTapEdit(BuildContext context, StudentDetails details,
      int index, String batchName) async {
    var result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => StudentInfoScreen.update(
            batchName: batchName,
            details: details,
          ),
        ));
    details = result;
    appData.updateStudentDetails(batchName, index, result);
  }

  void studentListOnTapDelete(BuildContext context, String batchName) {
    Future.delayed(
      const Duration(seconds: 0),
      () async {
        final result = await showDialog<bool>(
          context: context,
          builder: (context) {
            return Dialog(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Do you Really want to delete'),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextButton(
                          onPressed: () {
                            appData.deleteBatchName(batchName);
                            Navigator.pop(context, true);
                          },
                          child: const Text('Yes')),
                      TextButton(
                          onPressed: () {
                            return;
                          },
                          child: const Text('No'))
                    ],
                  ),
                ],
              ),
            );
          },
        );
        if (result == true) Navigator.pop(context);
      },
    );
  }

  void studentListOnTapEdit(BuildContext context, String batchName) {
    Future.delayed(
      const Duration(seconds: 0),
      () async {
        String newBatchName = '';
        final ValueNotifier<bool> _isInvalid = ValueNotifier<bool>(false);
        var res = await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return Dialog(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Edit Batch Name',
                      style: TextStyle(
                          fontSize: 16,
                          color: Colors.blue,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ValueListenableBuilder(
                        valueListenable: _isInvalid,
                        builder: (BuildContext context, bool isInvalid,
                            Widget? child) {
                          return TextField(
                              controller:
                                  TextEditingController(text: batchName),
                              decoration: InputDecoration(
                                  labelText: 'Batch Name',
                                  errorText: isInvalid
                                      ? 'The name already exists'
                                      : null,
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16))),
                              onChanged: (value) {
                                newBatchName = value;
                              });
                        }),
                  ),
                  TextButton(
                    onPressed: () async {
                      final batchNames = await appData.getBatchNames();
                      _isInvalid.value = false;
                      for (int i = 0; i < batchNames.length; i++) {
                        if (newBatchName == batchNames[i]) {
                          _isInvalid.value = true;
                          break;
                        }
                      }

                      if (!_isInvalid.value) Navigator.pop(context);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.blueAccent,
                          borderRadius: BorderRadius.circular(12)),
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'Save',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            );
          },
        );
        appData.updateBatchName(batchName, newBatchName);
        batchName = newBatchName;
        if (newBatchName == '') return;
        // setState(() {});
      },
    );
  }
}

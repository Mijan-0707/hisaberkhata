import 'package:flutter/material.dart';
import 'package:hisaberkhata/appdata/student_details_data_model.dart';
import 'package:hisaberkhata/screens/homescreen.dart';
import 'package:hisaberkhata/screens/student_info_screen.dart';
import 'package:hisaberkhata/screens/studentprofile.dart';
import '../widgets/profileicon.dart';
import 'inherited_widget.dart';
import 'dart:collection';

class StudentListPage extends StatelessWidget {
  StudentListPage({super.key, required this.batchName});

  String batchName;
  final searchText = TextEditingController();

  @override
  Widget build(BuildContext context) {
    AppDataProvider.of(context).appData.getStudents(batchName);
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
          AppDataProvider.of(context).appData.addNewStudent(batchName, result);
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
        valueListenable: AppDataProvider.of(context).appData.students,
        builder: (context, students, _) {
          students.sort((a, b) => a.name.compareTo(b.name));
          ValueNotifier<List<StudentDetails>> filteredStudentList =
              ValueNotifier([...students]);
          final indexList = List.generate(students.length, (index) => index);
          return ValueListenableBuilder(
            valueListenable: filteredStudentList,
            builder: (context, filturedStudents, _) {
              return studentsList(
                context,
                filturedStudents,
                indexList,
                (value) {
                  print(value);
                  filteredStudentList.value.clear();
                  indexList.clear();
                  for (int i = 0; i < students.length; i++) {
                    final s = students[i];
                    if (s.name
                        .toLowerCase()
                        .contains(value.toLowerCase().trim())) {
                      indexList.add(i);
                      filteredStudentList.value.add(s);
                    }
                  }
                  filteredStudentList.notifyListeners();
                  print(filteredStudentList.value.length);
                },
              );
            },
          );
        },
      ),
    );
  }

  ListView studentsList(
    BuildContext context,
    List<StudentDetails> students,
    List<int> indexList,
    void Function(String str) onFilter,
  ) {
    return ListView(
      children: [
        TextField(
          controller: searchText,
          onChanged: onFilter,
        ),
        for (int i = 0; i < students.length; i++)
          GestureDetector(
            onTap: () async {
              print('Student index $i');
              // print('IndexList ${students[indexList[i]]}');
              await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: ((context) => StudentProfile(
                            batchName: batchName,
                            stuIndex: indexList[i],
                          ))));
            },
            child: Padding(
                padding: const EdgeInsets.only(left: 8, right: 8, top: 8),
                child: ListTile(
                  tileColor: Colors.tealAccent,
                  leading: ProfileIconCreator(name: indexList[i].toString()),
                  // leading: ProfileIconCreator(name: students[i].name),
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Name: ${students[i].name}'),
                      Text('Roll: ${students[i].roll}'),
                      Text('Section: ${students[i].section}'),
                    ],
                  ),
                  trailing: PopupMenuButton(
                    itemBuilder: (c) {
                      return {'Edit', 'Delete'}.map((String choice) {
                        return PopupMenuItem(
                            onTap: () async {
                              Future.delayed(
                                const Duration(seconds: 0),
                                () {
                                  if (choice == 'Edit') {
                                    studentListtileOnTapEdit(
                                        context, students[i], i, batchName);
                                  } else if (choice == 'Delete') {
                                    AppDataProvider.of(context)
                                        .appData
                                        .deleteStudentDetails(batchName, i);
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
                )),
          ),
      ],
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
    if (result == null) return;
    details = result;
    AppDataProvider.of(context)
        .appData
        .updateStudentDetails(batchName, index, result);
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
                            AppDataProvider.of(context)
                                .appData
                                .deleteBatchName(batchName);
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
                        builder: (BuildContext context, bool isInvalid, _) {
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
                      final batchNames = await AppDataProvider.of(context)
                          .appData
                          .getBatchNames();
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
        AppDataProvider.of(context)
            .appData
            .updateBatchName(batchName, newBatchName);
        batchName = newBatchName;
      },
    );
  }
}

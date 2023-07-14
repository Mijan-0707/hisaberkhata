import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hisaberkhata/appdata/appdata.dart';
import 'package:hisaberkhata/appdata/student_details_data_model.dart';
import 'package:hisaberkhata/screens/homescreen.dart';
import 'package:hisaberkhata/screens/student_info_screen.dart';
import 'package:hisaberkhata/screens/studentprofile.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/constants.dart';

class StudentListPage extends StatefulWidget {
  StudentListPage({super.key, required this.batchName});

  String batchName;

  @override
  State<StudentListPage> createState() => _StudentListPageState();
}

class _StudentListPageState extends State<StudentListPage> {
  List<StudentDetails> students = [];

  @override
  void initState() {
    super.initState();
    AppData().getStudents(widget.batchName).then((value) {
      students.addAll(value);
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    StudentInfoScreen(batchName: widget.batchName),
              ));

          if (result == null) return;
          setState(() {
            students.add(result);
          });
          AppData().addNewStudent(widget.batchName, result);
        },
      ),
      appBar: AppBar(
          centerTitle: true,
          title: Text(widget.batchName),
          actions: [
            PopupMenuButton(
              itemBuilder: (c) {
                return {'Edit', 'Delete'}.map((String choice) {
                  return PopupMenuItem(
                      onTap: () async {
                        print(choice);
                        if (choice == 'Edit') {
                          Future.delayed(
                            Duration(seconds: 0),
                            () async {
                              String newBatchName = '';
                              final ValueNotifier<bool> _isInvalid =
                                  ValueNotifier<bool>(false);
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
                                              builder: (BuildContext context,
                                                  bool isInvalid,
                                                  Widget? child) {
                                                return TextField(
                                                    controller:
                                                        TextEditingController(
                                                            text: widget
                                                                .batchName),
                                                    decoration: InputDecoration(
                                                        labelText: 'Batch Name',
                                                        errorText: isInvalid
                                                            ? 'The name already exists'
                                                            : null,
                                                        border: OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        16))),
                                                    onChanged: (value) {
                                                      newBatchName = value;
                                                    });
                                              }),
                                        ),
                                        TextButton(
                                          onPressed: () async {
                                            final batchNames =
                                                await AppData().getBatchNames();
                                            _isInvalid.value = false;
                                            for (int i = 0;
                                                i < batchNames.length;
                                                i++) {
                                              if (newBatchName ==
                                                  batchNames[i]) {
                                                _isInvalid.value = true;
                                                break;
                                              }
                                            }

                                            if (!_isInvalid.value)
                                              Navigator.pop(context);
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                                color: Colors.blueAccent,
                                                borderRadius:
                                                    BorderRadius.circular(12)),
                                            child: const Padding(
                                              padding: EdgeInsets.all(8.0),
                                              child: Text(
                                                'Save',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 16),
                                              ),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  );
                                },
                              );
                              AppData().updateBatchName(
                                  widget.batchName, newBatchName);
                              widget.batchName = newBatchName;
                              if (newBatchName == '') return;
                              setState(() {});
                            },
                          );
                        } else if (choice == 'Delete') {
                          Future.delayed(
                            Duration(seconds: 0),
                            () async {
                              final result = await showDialog<bool>(
                                context: context,
                                builder: (context) {
                                  return Dialog(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text('Do you Really want to delete'),
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            TextButton(
                                                onPressed: () {
                                                  AppData().deleteBatchName(
                                                      widget.batchName);
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
      body: ListView(
        children: [
          for (int i = 0; i < students.length; i++)
            GestureDetector(
              onTap: () async {
                await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: ((context) => StudentProfile(
                              batchName: widget.batchName,
                              stuIndex: i,
                            ))));

                AppData().getStudents(widget.batchName).then((value) {
                  students.clear();
                  students.addAll(value);
                  setState(() {});
                });
              },
              child: Padding(
                padding: const EdgeInsets.only(left: 8, right: 8, top: 8),
                child: ListTile(
                  tileColor: Colors.tealAccent,
                  leading: Image.asset('assets/pic/pp.png'),
                  title: Text('Name: ${students[i].name}'),
                  subtitle: Text('Roll: ${students[i].roll}'),
                  trailing: PopupMenuButton(
                    itemBuilder: (c) {
                      return {'Edit', 'Delete'}.map((String choice) {
                        return PopupMenuItem(
                            onTap: () async {
                              // print(choice);
                              if (choice == 'Edit') {
                                Future.delayed(
                                  Duration(seconds: 0),
                                  () async {
                                    await showDialog(
                                      context: context,
                                      builder: (context) {
                                        return Dialog(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Padding(
                                                padding: EdgeInsets.all(8.0),
                                                child: Text(
                                                  'Edit Student Information',
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      color: Colors.blue,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: TextField(
                                                  keyboardType:
                                                      TextInputType.name,
                                                  controller:
                                                      TextEditingController(
                                                          text:
                                                              students[i].name),
                                                  decoration: InputDecoration(
                                                      labelText: 'Name',
                                                      border:
                                                          OutlineInputBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          16))),
                                                  onChanged: (value) =>
                                                      students[i].name = value,
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: TextField(
                                                    keyboardType:
                                                        TextInputType.number,
                                                    controller:
                                                        TextEditingController(
                                                            text: students[i]
                                                                .roll),
                                                    decoration: InputDecoration(
                                                        labelText: 'Roll',
                                                        border: OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        16))),
                                                    onChanged: (value) =>
                                                        students[i].roll =
                                                            value),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: TextField(
                                                    keyboardType:
                                                        TextInputType.phone,
                                                    controller:
                                                        TextEditingController(
                                                            text: students[i]
                                                                .mobile),
                                                    decoration: InputDecoration(
                                                        labelText: 'Mobile',
                                                        border: OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        16))),
                                                    onChanged: (value) =>
                                                        students[i].mobile =
                                                            value),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: TextField(
                                                    keyboardType: TextInputType
                                                        .streetAddress,
                                                    controller:
                                                        TextEditingController(
                                                            text: students[i]
                                                                .address),
                                                    decoration: InputDecoration(
                                                        labelText: 'Address',
                                                        border: OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        16))),
                                                    onChanged: (value) =>
                                                        students[i].address =
                                                            value),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: TextField(
                                                    keyboardType:
                                                        TextInputType.number,
                                                    controller:
                                                        TextEditingController(
                                                            text: students[i]
                                                                .address),
                                                    decoration: InputDecoration(
                                                        labelText: 'Payment',
                                                        border: OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        16))),
                                                    onChanged: (value) =>
                                                        students[i].payment =
                                                            value),
                                              ),
                                              TextButton(
                                                onPressed: () async {
                                                  Navigator.pop(context);
                                                },
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                      color: Colors.blueAccent,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12)),
                                                  child: const Padding(
                                                    padding:
                                                        EdgeInsets.all(8.0),
                                                    child: Text(
                                                      'Save',
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 16),
                                                    ),
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                        );
                                      },
                                    );

                                    AppData().updateStudentDetails(
                                        widget.batchName, i, students[i]);
                                    setState(() {});
                                  },
                                );
                              } else if (choice == 'Delete') {
                                AppData()
                                    .deleteStudentDetails(widget.batchName, i);
                                setState(() {});
                                Future.delayed(
                                  Duration(seconds: 0),
                                  () {
                                    Navigator.pop(context, true);
                                  },
                                );
                              }
                            },
                            value: choice,
                            child: Text(choice));
                      }).toList();
                    },
                  ),

                  textColor: Colors.white,
                  // trailing: Checkbox(onChanged: (value) {}, value: true),
                ),
              ),
            )
        ],
      ),
    );
  }
}

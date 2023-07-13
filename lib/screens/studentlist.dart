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
                              var newBatchName = '';
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
                                            'Edit Batch Name',
                                            style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.blue,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: TextField(
                                            controller: TextEditingController(
                                                text: widget.batchName),
                                            decoration: InputDecoration(
                                                labelText: 'Batch Name',
                                                border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            16))),
                                            onChanged: (value) =>
                                                newBatchName = value,
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () async {
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
                          // setState(() {});
                          // Future.delayed(
                          //   Duration(seconds: 0),
                          //       () {
                          //     Navigator.pop(context, true);
                          //   },
                          // );
                        } else if (choice == 'Edit Payment') {
                          bool EditPayment = true;
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

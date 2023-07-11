import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hisaberkhata/appdata/appdata.dart';
import 'package:hisaberkhata/constants/constants.dart';
import 'package:hisaberkhata/screens/studentlist.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<String> studentBatch = [];
  final appData = AppData();

  @override
  void initState() {
    super.initState();
    appData.getBatchNames().then((value) {
      studentBatch = value;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final res = await showModalBottomSheet<String?>(
              context: context,
              builder: (context) {
                var batch = '';
                bool isInvalid = false;

                return StatefulBuilder(builder: (context, setState2) {
                  return Padding(
                    padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextField(
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                                labelText: 'Name of Batch11',
                                errorText: isInvalid
                                    ? 'The name already exists'
                                    : null,
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16))),
                            onChanged: (value) {
                              batch = value;
                            },
                          ),
                        ),
                        TextButton(
                            onPressed: () async {
                              isInvalid = false;
                              for (int i = 0; i < studentBatch.length; i++) {
                                if (batch == studentBatch[i]) {
                                  isInvalid = true;
                                  break;
                                }
                              }
                              setState2(() {});
                              if (!isInvalid) Navigator.pop(context, batch);
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                  color: Colors.blueAccent,
                                  borderRadius: BorderRadius.circular(8)),
                              child: const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  'Save',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 16),
                                ),
                              ),
                            ))
                      ],
                    ),
                  );
                });
              },
            );
            if (res != null && res.isNotEmpty) {
              studentBatch.add(res);
              appData.createBatchName(res);
              setState(() {});
            }
          },
          backgroundColor: const Color(0xff536DFE),
          child: const Icon(Icons.add)),
      appBar: AppBar(
        centerTitle: true,
        title: const Text('List Of Batches'),
        backgroundColor: const Color(0xff536DFE),
        actions: [
          PopupMenuButton(itemBuilder: (c) {
            return {'Backup', 'Restore'}.map((String choice) {
              return PopupMenuItem(
                onTap: () async {
                  if (choice == 'Backup') {
                    appData.createBackup();
                  } else if (choice == 'Restore') {
                    await appData.restoreData();
                    setState(() {});
                  }
                },
                child: Text(choice),
              );
            }).toList();
          })
        ],
      ),
      body: ListView(
        children: [
          for (int i = 0; i < studentBatch.length; i++)
            Padding(
              padding: const EdgeInsets.only(left: 5, right: 5, top: 5),
              child: GestureDetector(
                onLongPress: () {
                  showModalBottomSheet(
                      context: context,
                      builder: (context) {
                        return Container(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                onTap: () {
                                  Navigator.pop(context);
                                  deleteItem(context, i);
                                },
                                leading: const Icon(Icons.delete),
                                title: const Text('Delete'),
                              ),
                              ListTile(
                                onTap: () {
                                  Navigator.pop(context);
                                  var newBatchName = studentBatch[i];
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        return Dialog(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: TextField(
                                                  decoration: InputDecoration(
                                                    labelText: 'Name of Batch',
                                                    border: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              16),
                                                    ),
                                                  ),
                                                  onChanged: (value) {
                                                    newBatchName = value;
                                                  },
                                                ),
                                              ),
                                              TextButton(
                                                  onPressed: () async {
                                                    await appData
                                                        .updateBatchName(
                                                            studentBatch[i],
                                                            newBatchName);
                                                    Navigator.pop(context);
                                                    appData
                                                        .getBatchNames()
                                                        .then((value) {
                                                      studentBatch = value;
                                                      setState(() {});
                                                    });
                                                  },
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                        color:
                                                            Colors.blueAccent,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8)),
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
                                                  ))
                                            ],
                                          ),
                                        );
                                      });
                                },
                                leading: const Icon(Icons.edit),
                                title: const Text('Edit'),
                              )
                            ],
                          ),
                        );
                      });
                },
                onTap: () async {
                  await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => StudentListPage(
                                batchName: studentBatch[i],
                              )));

                  appData.getBatchNames().then((value) {
                    studentBatch = value;
                    setState(() {});
                  });
                },
                child: Container(
                  height: 60,
                  decoration: BoxDecoration(
                      color: Color(0xff455A64),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Color(0xffCFD8DC))),
                  child: Center(
                    child: Text(
                      studentBatch[i],
                      style: const TextStyle(color: Colors.white, fontSize: 22),
                    ),
                  ),
                ),
              ),
            )
        ],
      ),
    );
  }

  void deleteItem(BuildContext context, int i) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Delete Batch'),
            content: const Text('Are you sure you want to delete this batch?'),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('No')),
              TextButton(
                  onPressed: () async {
                    await appData.deleteBatchName(studentBatch[i]);
                    Navigator.pop(context);
                    appData.getBatchNames().then((value) {
                      studentBatch = value;
                      setState(() {});
                    });
                  },
                  child: const Text('Yes'))
            ],
          );
        });
  }
}

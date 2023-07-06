import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hisaberkhata/appdata/appdata.dart';
import 'package:hisaberkhata/constants/constants.dart';
import 'package:hisaberkhata/screens/studentlist.dart';
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
            var batch = '';
            await showDialog(
              context: context,
              builder: (context) {
                return Dialog(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          decoration: InputDecoration(
                              labelText: 'Name of Batch',
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16))),
                          onChanged: (value) {
                            batch = value;
                          },
                        ),
                      ),
                      TextButton(
                          onPressed: () async {
                            Navigator.pop(context);
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
              },
            );
            final SharedPreferences prefs =
                await SharedPreferences.getInstance();
            if (batch == '') return;
            studentBatch.add(batch);
            var studentBatchJsonE = jsonEncode(studentBatch);
            // print(batchName);
            final res = await prefs.setString(
                PreferenceConstants.batchNameKey, studentBatchJsonE);
            // await Future.delayed(Duration(seconds: 1));
            // await prefs.reload();
            // print([res, prefs.getString('123'), prefs.getKeys()]);
            setState(() {});
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
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => StudentListPage(
                                batchName: studentBatch[i],
                              )));
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
}

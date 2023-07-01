import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hisaberkhata/appdata/appdata.dart';
import 'package:hisaberkhata/screens/homescreen.dart';
import 'package:hisaberkhata/screens/studentprofile.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StudentListPage extends StatefulWidget {
  String batchName;

  StudentListPage({super.key, required this.batchName});

  @override
  State<StudentListPage> createState() => _StudentListPageState();
}

class _StudentListPageState extends State<StudentListPage> {
  List<StudenDetails> students = [
    // StudenDetails('name1', 'mobile1', 'address1', 1, 1000, 1),
    // StudenDetails('name2', 'mobile2', 'address2', 2, 2000, 2),
    // StudenDetails('name3', 'mobile3', 'address3', 3, 3000, 3),
    // StudenDetails('name4', 'mobile4', 'address4', 4, 4000, 4),
  ];
  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          final result = await showDialog(
            context: context,
            builder: (context) {
              String name = '',
                  roll = '',
                  mobile = '',
                  address = '',
                  payment = '';
              return Dialog(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'Student Information',
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.blue,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        decoration: InputDecoration(
                            labelText: 'Name',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16))),
                        onChanged: (value) => name = value,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                          decoration: InputDecoration(
                              labelText: 'Roll',
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16))),
                          onChanged: (value) => roll = value),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                          decoration: InputDecoration(
                              labelText: 'Mobile',
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16))),
                          onChanged: (value) => mobile = value),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                          decoration: InputDecoration(
                              labelText: 'Address',
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16))),
                          onChanged: (value) => address = value),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                          decoration: InputDecoration(
                              labelText: 'Payment',
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16))),
                          onChanged: (value) => payment = value),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextButton(
                        onPressed: () async {
                          final SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          if (name == '') {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Name is Empty')));
                            return;
                          }
                          final st = StudenDetails(
                              name: name,
                              roll: roll,
                              mobile: mobile,
                              address: address,
                              payment: payment,
                              studentBatch: widget.batchName);

                          // print(json);
                          // await prefs.setString('name', name);
                          // await prefs.setString('roll', roll);
                          // await prefs.setString('mobile', mobile);
                          // await prefs.setString('address', '21');
                          // await prefs.setString('payment', '999');
                          // await prefs.setString('studentClass', '1');
                          Navigator.pop(context, st);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              color: Colors.blueAccent,
                              borderRadius: BorderRadius.circular(12)),
                          child: const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'Save',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 16),
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              );
            },
          );

          if (result == null) return;
          setState(() {
            students.add(result);
          });
          final SharedPreferences prefs = await SharedPreferences.getInstance();
          final json = jsonEncode(students);
          await prefs.setString(widget.batchName, json);
          // print(' =>${prefs.getString('json')}');
        },
      ),
      appBar: AppBar(
          centerTitle: true,
          title: const Text('Student List'),
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
                final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: ((context) => StudentProfile(
                              details: students[i],
                              studentlist: students,
                            ))));
                if (result == true) {
                  setState(() {});
                }
              },
              child: ListTile(
                tileColor: Colors.tealAccent,
                leading: Image.asset('assets/pic/pp.png'),
                title: Text(students[i].name),
                subtitle: Text(students[i].roll),

                textColor: Colors.white,
                // trailing: Checkbox(onChanged: (value) {}, value: true),
              ),
            )
        ],
      ),
    );
  }

  dynamic getData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? json = prefs.getString(widget.batchName);
    if (json == null || json.isEmpty) return;
    var jsodecode = jsonDecode(json) as List;
    for (int i = 0; i < jsodecode.length; i++) {
      print(jsodecode[i]['name']);
      students.add(StudenDetails(
          name: jsodecode[i]['name'],
          mobile: jsodecode[i]['mobile'],
          address: jsodecode[i]['address'],
          roll: jsodecode[i]['roll'],
          payment: jsodecode[i]['payment'],
          studentBatch: jsodecode[i]['studentBatch']));
    }
    // final String name = prefs.getString('name') ?? '';
    // final String roll = prefs.getString('roll') ?? '';
    // final String address = prefs.getString('address') ?? '';
    // final String mobile = prefs.getString('mobile') ?? '';
    // final String payment = prefs.getString('payment') ?? '';
    // final String studentClass = prefs.getString('studentClass') ?? '';
    // var stu = StudenDetails(
    //     name: name,
    //     mobile: mobile,
    //     address: address,
    //     roll: roll,
    //     payment: payment,
    //     studentClass: studentClass);
    // if (name == '') return;
    // students.add(stu);
    setState(() {});
  }
}

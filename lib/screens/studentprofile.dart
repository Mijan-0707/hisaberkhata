import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hisaberkhata/appdata/appdata.dart';
import 'package:hisaberkhata/appdata/student_details_data_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class StudentProfile extends StatefulWidget {
  const StudentProfile(
      {super.key, required this.batchName, required this.stuIndex});

  final String batchName;
  final int stuIndex;

  @override
  State<StudentProfile> createState() => _StudentProfileState();
}

class _StudentProfileState extends State<StudentProfile> {
  bool editPayment = false;
  StudentDetails details = StudentDetails();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    AppData()
        .getStudentDetails(widget.batchName, widget.stuIndex)
        .then((value) {
      print(value);
      details = value;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    print(details.name);
    return Scaffold(
      floatingActionButton: FloatingActionButton(
          onPressed: () async {
            String payedMonth = '';
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
                              labelText: 'Payment',
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16))),
                          onChanged: (value) {
                            payedMonth = value;
                          },
                        ),
                      ),
                      TextButton(
                          onPressed: () async {
                            Navigator.pop(context);
                          },
                          child: const Text('Save'))
                    ],
                  ),
                );
              },
            );
            if (payedMonth == '' || payedMonth == null) return;
            details.paymentHistory.add(payedMonth);
            setState(() {});
            AppData().updateStudentDetails(
                widget.batchName, widget.stuIndex, details);
            print('object');
          },
          child: const Icon(Icons.add)),
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Student Profile'),
        actions: [
          PopupMenuButton(
            itemBuilder: (c) {
              return {'Edit', 'Delete', 'Edit Payment'}.map((String choice) {
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
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: TextField(
                                          controller: TextEditingController(
                                              text: details.name),
                                          decoration: InputDecoration(
                                              labelText: 'Name',
                                              border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          16))),
                                          onChanged: (value) =>
                                              details.name = value,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: TextField(
                                            controller: TextEditingController(
                                                text: details.roll),
                                            decoration: InputDecoration(
                                                labelText: 'Roll',
                                                border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            16))),
                                            onChanged: (value) =>
                                                details.roll = value),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: TextField(
                                            controller: TextEditingController(
                                                text: details.mobile),
                                            decoration: InputDecoration(
                                                labelText: 'Mobile',
                                                border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            16))),
                                            onChanged: (value) =>
                                                details.mobile = value),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: TextField(
                                            controller: TextEditingController(
                                                text: details.address),
                                            decoration: InputDecoration(
                                                labelText: 'Address',
                                                border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            16))),
                                            onChanged: (value) =>
                                                details.address = value),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: TextField(
                                            controller: TextEditingController(
                                                text: details.address),
                                            decoration: InputDecoration(
                                                labelText: 'Payment',
                                                border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            16))),
                                            onChanged: (value) =>
                                                details.payment = value),
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

                            AppData().updateStudentDetails(
                                widget.batchName, widget.stuIndex, details);
                            setState(() {});
                          },
                        );
                      } else if (choice == 'Delete') {
                        // final SharedPreferences prefs =
                        //     await SharedPreferences.getInstance();
                        // widget.studentlist.remove(details);
                        // var json = jsonEncode(widget.studentlist);
                        // await prefs.setString('json', json);
                        setState(() {});
                        Future.delayed(
                          Duration(seconds: 0),
                          () {
                            Navigator.pop(context, true);
                          },
                        );
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
      ),
      body: ListView(
        children: [
          Container(
            height: 200,
            decoration: const BoxDecoration(color: Colors.blue),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Container(
                    height: 120,
                    width: 120,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: Image.asset(
                      'assets/pic/pp.png',
                      fit: BoxFit.fill,
                      height: 80,
                      width: 80,
                    ),
                  ),
                ),
                const SizedBox(
                  width: 20,
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // for (int i = 0; i < students.length; i++)
                      Text(
                        'Name: ${details.name}',
                        style:
                            const TextStyle(fontSize: 20, color: Colors.white),
                      ),
                      Text(
                        'Roll: ${details.roll}',
                        style:
                            const TextStyle(fontSize: 20, color: Colors.white),
                      ),
                      Text(
                        details.payment,
                        style:
                            const TextStyle(fontSize: 20, color: Colors.white),
                      ),
                      Row(
                        children: [
                          Text(
                            details.mobile,
                            style: const TextStyle(
                                fontSize: 20, color: Colors.white),
                          ),
                          const Spacer(),
                          IconButton(
                            onPressed: () {
                              launchUrl(Uri.parse('tel:${details.mobile}'));
                            },
                            icon: const Icon(
                              Icons.call,
                              color: Colors.white,
                            ),
                          ),
                          IconButton(
                              onPressed: () {
                                launchUrl(Uri.parse('sms:${details.mobile}'));
                              },
                              icon: const Icon(
                                Icons.sms_rounded,
                                color: Colors.white,
                              ))
                        ],
                      ),
                      Text(
                        details.address,
                        style:
                            const TextStyle(fontSize: 20, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          for (int i = 0; i < details.paymentHistory.length; i++)
            ListTile(
              title: Text(details.paymentHistory[i]),
              subtitle: Text('payed on ${DateTime.now()}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (editPayment == true)
                    IconButton(onPressed: () {}, icon: Icon(Icons.edit))
                ],
              ),
            )
        ],
      ),
    );
  }
}

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_sms/flutter_sms.dart';
import 'package:hisaberkhata/appdata/appdata.dart';
import 'package:hisaberkhata/screens/studentlist.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StudentProfile extends StatefulWidget {
  const StudentProfile(
      {super.key, required this.details, required this.studentlist});
  final StudenDetails details;
  final List<StudenDetails> studentlist;

  @override
  State<StudentProfile> createState() => _StudentProfileState();
}

class _StudentProfileState extends State<StudentProfile> {
  bool editPayment = false;
  @override
  Widget build(BuildContext context) {
    print(widget.details.name);
    return Scaffold(
      floatingActionButton: FloatingActionButton(
          onPressed: () async {
            String monthPayed = '';
            await showDialog(
              context: context,
              builder: (context) {
                return Dialog(
                  child: Column(
                    children: [
                      TextField(
                        onChanged: (value) {
                          monthPayed = value;
                        },
                      ),
                      TextButton(
                          onPressed: () {
                            payedMonth.add(monthPayed);
                            Navigator.pop(context);
                          },
                          child: const Text('Save'))
                    ],
                  ),
                );
              },
            );
            print('object');
            setState(() {});
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
                      print(choice);
                      if (choice == 'Edit') {
                        Future.delayed(
                          Duration(seconds: 0),
                          () {
                            showDialog(
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
                                          decoration: InputDecoration(
                                              labelText: 'Name',
                                              border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          16))),
                                          onChanged: (value) =>
                                              widget.details.name = value,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: TextField(
                                            decoration: InputDecoration(
                                                labelText: 'Roll',
                                                border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            16))),
                                            onChanged: (value) =>
                                                widget.details.roll = value),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: TextField(
                                            decoration: InputDecoration(
                                                labelText: 'Mobile',
                                                border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            16))),
                                            onChanged: (value) =>
                                                widget.details.mobile = value),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: TextField(
                                            decoration: InputDecoration(
                                                labelText: 'Address',
                                                border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            16))),
                                            onChanged: (value) =>
                                                widget.details.address = value),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: TextField(
                                            decoration: InputDecoration(
                                                labelText: 'Payment',
                                                border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            16))),
                                            onChanged: (value) =>
                                                widget.details.payment = value),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                          setState(() async {
                                            final SharedPreferences prefs =
                                                await SharedPreferences
                                                    .getInstance();
                                            var json =
                                                jsonEncode(widget.studentlist);
                                            await prefs.setString('json', json);
                                          });
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
                          },
                        );
                      } else if (choice == 'Delete') {
                        final SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        widget.studentlist.remove(widget.details);
                        var json = jsonEncode(widget.studentlist);
                        await prefs.setString('json', json);
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
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // for (int i = 0; i < students.length; i++)
                    Text(
                      '${widget.details.name}  - ${widget.details.roll}',
                      style: const TextStyle(fontSize: 20, color: Colors.white),
                    ),
                    Text(
                      widget.details.address,
                      style: const TextStyle(fontSize: 20, color: Colors.white),
                    ),

                    // Text(
                    //   widget.details.roll,
                    //   style: const TextStyle(fontSize: 20, color: Colors.white),
                    // ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 40),
                          child: Text(
                            widget.details.mobile,
                            style: const TextStyle(
                                fontSize: 20, color: Colors.white),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            launchUrl(
                                Uri.parse('tel:${widget.details.mobile}'));
                          },
                          icon: const Icon(
                            Icons.call,
                            color: Colors.white,
                          ),
                        ),
                        IconButton(
                            onPressed: () {
                              launchUrl(
                                  Uri.parse('sms:${widget.details.mobile}'));
                            },
                            icon: const Icon(
                              Icons.sms_rounded,
                              color: Colors.white,
                            ))
                      ],
                    ),
                    Text(
                      widget.details.payment,
                      style: const TextStyle(fontSize: 20, color: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
          ),
          for (int i = 0; i < payedMonth.length; i++)
            ListTile(
              title: Text(payedMonth[i]),
              subtitle: Text('payed on ${DateTime.now()}'),
              trailing: Row(
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

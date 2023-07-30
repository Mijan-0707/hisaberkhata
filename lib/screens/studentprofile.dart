// import 'dart:convert';

import 'package:flutter/material.dart';
// import 'package:hisaberkhata/appdata/appdata.dart';
import 'package:hisaberkhata/appdata/student_details_data_model.dart';
import 'package:hisaberkhata/screens/student_info_screen.dart';
// import 'package:hisaberkhata/screens/studentlist.dart';
// import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:hisaberkhata/widgets/profileicon.dart';
import 'package:hisaberkhata/screens/homescreen.dart';

class StudentProfile extends StatelessWidget {
  StudentProfile({super.key, required this.batchName, required this.stuIndex});

  final String batchName;
  final int stuIndex;
  bool editPayment = false;
  ValueNotifier<StudentDetails> detailsValue = ValueNotifier(StudentDetails());
  // final appData = appData;
  // @override
  // void initState() {
  //   super.initState();
  //   appData
  //       .getStudentDetails(batchName, stuIndex)
  //       .then((value) {
  //     print(value);
  //     details = value;
  //     setState(() {});
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    appData.getStudentDetails(batchName, stuIndex).then((value) {
      detailsValue.value = value;
      print(detailsValue.value.name);
    });
    return Scaffold(
      floatingActionButton: FloatingActionButton(
          onPressed: () async {
            String payedMonth = '';
            await showModalBottomSheet(
              context: context,
              builder: (context) {
                return ValueListenableBuilder(
                    valueListenable: detailsValue,
                    builder: (context, details, _) {
                      return ListView(
                        children: [
                          for (int i = 0; i < appData.payableMonths.length; i++)
                            GestureDetector(
                              onTap: () async {
                                var month = appData.payableMonths[i];
                                details.paymentHistory.add(month);
                                Navigator.pop(context);
                                appData.updateStudentDetails(
                                    details.batch, stuIndex, details);
                                // setState(() {});
                                detailsValue.notifyListeners();
                              },
                              child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                    alignment: Alignment.center,
                                    height: 40,
                                    decoration: BoxDecoration(
                                        color: Colors.blue,
                                        borderRadius: BorderRadius.circular(8)),
                                    child: Text(
                                      appData.payableMonths[i],
                                      style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  )),
                            ),
                        ],
                      );
                    });
              },
            );

            appData.updateStudentDetails(
                batchName, stuIndex, detailsValue.value);
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
                          const Duration(seconds: 0),
                          () async {
                            studentListtileOnTapEdit(context,
                                detailsValue.value, stuIndex, batchName);

                            // final result = await Navigator.push(
                            //     context,
                            //     MaterialPageRoute(
                            //       builder: (context) =>
                            //           StudentInfoScreen.update(
                            //               batchName: batchName,
                            //               details: details.value),
                            //     ));
                            // print('old:  ${details.value.name}');
                            // details.value = result;
                            // print(details.value.name);
                            appData.updateStudentDetails(
                                batchName, stuIndex, detailsValue.value);
                            // // setState(() {});
                          },
                        );
                      } else if (choice == 'Delete') {
                        appData.deleteStudentDetails(batchName, stuIndex);
                        // setState(() {});
                        Future.delayed(
                          const Duration(seconds: 0),
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
      body: ValueListenableBuilder(
          valueListenable: detailsValue,
          builder: (context, details, _) {
            print('-> inside ValueListenableBuilder : ${details.name}');
            return ListView(
              children: [
                Container(
                  height: 200,
                  decoration: const BoxDecoration(color: Colors.blue),
                  child: Row(
                    children: [
                      Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: ProfileIconCreator(
                              name: details.name, size: 120)),
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
                              style: const TextStyle(
                                  fontSize: 20, color: Colors.white),
                            ),
                            Text(
                              'Roll: ${details.roll}',
                              style: const TextStyle(
                                  fontSize: 20, color: Colors.white),
                            ),
                            Text(
                              details.payment,
                              style: const TextStyle(
                                  fontSize: 20, color: Colors.white),
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
                                    launchUrl(
                                        Uri.parse('tel:${details.mobile}'));
                                  },
                                  icon: const Icon(
                                    Icons.call,
                                    color: Colors.white,
                                  ),
                                ),
                                IconButton(
                                    onPressed: () {
                                      launchUrl(
                                          Uri.parse('sms:${details.mobile}'));
                                    },
                                    icon: const Icon(
                                      Icons.sms_rounded,
                                      color: Colors.white,
                                    ))
                              ],
                            ),
                            Text(
                              details.address,
                              style: const TextStyle(
                                  fontSize: 20, color: Colors.white),
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
                          IconButton(
                              onPressed: () {}, icon: const Icon(Icons.edit))
                      ],
                    ),
                  )
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
    print('result ${result}');
    if (result == null) return;
    detailsValue.value = result;
    detailsValue.notifyListeners();
    appData.updateStudentDetails(batchName, index, result);
  }
}

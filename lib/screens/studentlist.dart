import 'package:flutter/material.dart';
import 'package:hisaberkhata/appdata/student_details_data_model.dart';
import 'package:hisaberkhata/core/data_model/batch.dart';
import 'package:hisaberkhata/core/data_model/student.dart';
import 'package:hisaberkhata/feature/home/screen/home_screen.dart';
import 'package:hisaberkhata/screens/homescreen.dart';
import 'package:hisaberkhata/screens/student_info_screen.dart';
import 'package:hisaberkhata/screens/studentprofile.dart';
import 'package:isar/isar.dart';
import '../widgets/profileicon.dart';
import 'inherited_widget.dart';
import 'dart:collection';

class StudentListPage extends StatelessWidget {
  StudentListPage({super.key, required this.batchId, required this.batchName});
  String? batchName;
  int batchId;
  final searchText = TextEditingController();
  // String? batchName;
  @override
  Widget build(BuildContext context) {
    final isar = AppDataProvider.of(context).appData.isar!;
    var isarStream = isar.students
        .filter()
        .batchIdEqualTo(batchId)
        .watch(fireImmediately: true);
    // AppDataProvider.of(context).appData.getStudentsOnBatch(batchId);
    return Scaffold(
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () async {
            Student result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => StudentInfoScreen(
                    batchId: batchId,
                  ),
                ));
            if (result == null) return;
            AppDataProvider.of(context).appData.addNewStudent(result);
          },
        ),
        appBar: AppBar(
            centerTitle: true,
            // isar.batchs.get(batchId).then((value) => (value) {

            // }),
            title: Text(batchName!),
            actions: [
              PopupMenuButton(
                itemBuilder: (c) {
                  return {'Edit', 'Delete'}.map((String choice) {
                    return PopupMenuItem(
                        onTap: () async {
                          // print(choice);
                          if (choice == 'Edit') {
                            studentListOnTapEdit(context, 'batchName');
                          } else if (choice == 'Delete') {
                            studentListOnTapDelete(context, 'batchName');
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
        body: StreamBuilder(
          stream: isarStream,
          builder: (context, students) {
            if (students.hasData) {
              return ListView.builder(
                itemCount: students.data!.length,
                itemBuilder: (context, index) {
                  students.data!
                      .sort((a, b) => a.name!.compareTo(b.name ?? ''));
                  return ListTile(
                    title: GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => StudentProfile(
                                  details: students.data![index]),
                            ));
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        color: Colors.transparent,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Name: ${students.data![index].name}'),
                            Text('Roll: ${students.data![index].roll}'),
                            Text('Section: ${students.data![index].section}'),
                          ],
                        ),
                      ),
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
                                          context, students.data![index]);
                                    } else if (choice == 'Delete') {
                                      AppDataProvider.of(context)
                                          .appData
                                          .deleteStudentDetails(
                                              students.data![index]);
                                    }
                                  },
                                );
                              },
                              value: choice,
                              child: Text(choice));
                        }).toList();
                      },
                    ),
                  );
                },
              );
            } else {
              return const CircularProgressIndicator();
            }
          },
        ));
  }

  void studentListtileOnTapEdit(BuildContext context, Student details) async {
    await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => StudentInfoScreen.update(
            details: details,
          ),
        ));

    // AppDataProvider.of(context).appData.updateStudentDetails(result);
  }

  // void studentListtileOnTapEdit(BuildContext context, StudentDetails details,
  //     int index, String batchName) async {
  //   var result = await Navigator.push(
  //       context,
  //       MaterialPageRoute(
  //         builder: (context) => StudentInfoScreen.update(
  //           batchName: batchName,
  //           details: details,
  //         ),
  //       ));
  //   if (result == null) return;
  //   details = result;
  //   AppDataProvider.of(context)
  //       .appData
  //       .updateStudentDetails(batchName, index, result);
  // }

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
    final isar = AppDataProvider.of(context).appData.isar!;
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
                      List<Batch> batchNames =
                          await isar.batchs.where().findAll();
                      _isInvalid.value = false;
                      for (int i = 0; i < batchNames.length; i++) {
                        if (newBatchName == batchNames[i].name) {
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

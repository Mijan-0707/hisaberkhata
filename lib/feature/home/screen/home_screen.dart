import 'package:flutter/material.dart';
import 'package:hisaberkhata/core/data_model/batch.dart';
import 'package:hisaberkhata/core/data_model/student.dart';
import 'package:hisaberkhata/core/theme/app_theme.dart';
import 'package:hisaberkhata/feature/batch/screen/batch_info_screen.dart';
import 'package:hisaberkhata/feature/home/widget/batch_tile.dart';
import 'package:hisaberkhata/feature/home/widget/horizontal_batch_list.dart';
import 'package:hisaberkhata/screens/inherited_widget.dart';
import 'package:isar/isar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../screens/student_info_screen.dart';
import '../../../screens/studentlist.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isar = AppDataProvider.of(context).appData.isar!;
    var batches = isar.batchs.where().findAll();
    // AppDataProvider.of(context).appData.getBatches();
    return Scaffold(
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 50),
            buildGreetings(context),
            const SizedBox(height: 32),
            const HorizantalBatchList(),
            const SizedBox(height: 32),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget buildGreetings(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 50,
              ),
              Text(
                'Hello,',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              Text(
                'Sharif Khan',
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const Spacer(),
          buildSearch(context),
          buildPopupMenu(context),
        ],
      ),
    );
  }

  PopupMenuButton<dynamic> buildPopupMenu(BuildContext context) {
    final menuMap = {
      'Backup': (BuildContext context) {
        AppDataProvider.of(context).appData.createBackup();
      },
      'Restore': (BuildContext context) {
        AppDataProvider.of(context).appData.restoreData();
      },
      'Theme': (BuildContext context) => showThemeChangerDialog(context),
    };
    return PopupMenuButton(itemBuilder: (c) {
      return menuMap.keys.map((String choice) {
        return PopupMenuItem(
          child: Text(choice),
          onTap: () => menuMap[choice]?.call(context),
        );
      }).toList();
    });
  }

  Widget buildSearch(BuildContext context) {
    return IconButton(
        onPressed: () {
          showSearch(context: context, delegate: CustomSearchDelegate());
        },
        icon: const Icon(Icons.search));
  }

  Widget buildSearchBar(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search Student',
          suffixIcon: Icon(Icons.search),
        ),
      ),
    );
  }

  void showThemeChangerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Theme'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              buildMenuItem(context, ThemeMode.light),
              buildMenuItem(context, ThemeMode.dark),
              buildMenuItem(context, ThemeMode.system),
            ],
          ),
        );
      },
    );
  }

  ListTile buildMenuItem(BuildContext context, ThemeMode mode) {
    return ListTile(
      title: Text('${mode.name[0].toUpperCase()}${mode.name.substring(1)}'),
      onTap: () {
        SharedPreferences.getInstance().then((prefs) {
          prefs.setInt('theme', mode.index);
        });
        themeValueNotifier.value = mode;
        Navigator.pop(context);
      },
      trailing:
          themeValueNotifier.value == mode ? const Icon(Icons.check) : null,
    );
  }

  Widget buildBatchList(BuildContext context) {
    // var batches = AppDataProvider.of(context).appData.studentBatch;
    final isar = AppDataProvider.of(context).appData.isar!;
    var batches = isar.batchs.where().findAll().asStream();
    return SizedBox(
      height: 250,
      child: StreamBuilder(
        stream: batches,
        // valueListenable: batches,
        builder: (
          context,
          batches,
        ) {
          if (batches.data == null) {
            return const CircularProgressIndicator();
          } else {
            batches.data!.sort((a, b) => a.name!.compareTo(b.name!));
            return ListView.builder(
              physics: const BouncingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemBuilder: (context, index) => index < batches.data!.length
                  ? BatchTile(
                      batch: batches.data![index].name,
                      menuMap: {
                        'Edit': () {},
                        // studentListOnTapEdit(context, batches[index]),
                        'Delete': () {}
                        // studentListOnTapDelete(context, batches[index]),
                      },
                      onTapBody: () async {
                        await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => StudentListPage(
                                      batchId: batches.data![index].id,
                                      batchName: batches.data![index].name,
                                    )));
                        // AppDataProvider.of(context).appData.students.value = [];
                      },
                      onTapAdd: () async {
                        Student result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => StudentInfoScreen(
                                  batchId: batches.data![index].id),
                            ));
                        print('result --> ${result}');
                        // if (result == null || result is! Student) return;
                        AppDataProvider.of(context)
                            .appData
                            .addNewStudent(result);
                      },
                    )
                  : BatchTile.empty(
                      onTapEmptyCard: () async {
                        Batch result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BatchInfoScreen(),
                            ));
                        // print(result);
                        if (result != null) {
                          isar.writeTxn(() async {
                            await isar.batchs.put(result as Batch);
                          });
                        }
                      },
                    ),
              itemCount: batches.data!.length + 1,
            );
          }
        },
      ),
    );
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

  // Future<void> onTapCreateNewBatch(BuildContext context) async {
  //   String batch = '';
  //   String? errMsg;
  //   final res = await showModalBottomSheet<String?>(
  //     context: context,
  //     builder: (context) {
  //       return StatefulBuilder(builder: (context, setState2) {
  //         return Padding(
  //           padding: EdgeInsets.only(
  //               bottom: MediaQuery.of(context).viewInsets.bottom),
  //           child: Column(
  //             mainAxisSize: MainAxisSize.min,
  //             children: [
  //               Padding(
  //                 padding: const EdgeInsets.all(8.0),
  //                 child: TextField(
  //                   keyboardType: TextInputType.text,
  //                   decoration: InputDecoration(
  //                       labelText: 'Name of Batch',
  //                       errorText: errMsg,
  //                       border: OutlineInputBorder(
  //                           borderRadius: BorderRadius.circular(16))),
  //                   onChanged: (value) {
  //                     batch = value;
  //                   },
  //                 ),
  //               ),
  //               TextButton(
  //                   onPressed: () async {
  //                     if (batch.isEmpty) {
  //                       errMsg = 'Batch name cannot be empty';
  //                     } else if (AppDataProvider.of(context)
  //                         .appData
  //                         .studentBatch
  //                         .value
  //                         .toSet()
  //                         .contains(batch)) {
  //                       errMsg = 'Batch name already exists';
  //                     } else {
  //                       errMsg = null;
  //                     }

  //                     if (errMsg == null) {
  //                       Navigator.pop(context, batch);
  //                     } else {
  //                       setState2(() {});
  //                     }
  //                   },
  //                   child: Container(
  //                     decoration: BoxDecoration(
  //                         color: Colors.blueAccent,
  //                         borderRadius: BorderRadius.circular(8)),
  //                     child: const Padding(
  //                       padding: EdgeInsets.all(8.0),
  //                       child: Text(
  //                         'Save',
  //                         style: TextStyle(color: Colors.white, fontSize: 16),
  //                       ),
  //                     ),
  //                   ))
  //             ],
  //           ),
  //         );
  //       });
  //     },
  //   );
  //   if (res != null && res.isNotEmpty) {
  //     AppDataProvider.of(context).appData.createBatchName(res);
  //   }
  // }

  // void studentListOnTapEdit(BuildContext context, String batchName) {
  //   Future.delayed(
  //     const Duration(seconds: 0),
  //     () async {
  //       String newBatchName = '';
  //       final ValueNotifier<bool> _isInvalid = ValueNotifier<bool>(false);
  //       var res = await showDialog(
  //         context: context,
  //         barrierDismissible: false,
  //         builder: (context) {
  //           return Dialog(
  //             child: Column(
  //               mainAxisSize: MainAxisSize.min,
  //               children: [
  //                 const Padding(
  //                   padding: EdgeInsets.all(8.0),
  //                   child: Text(
  //                     'Edit Batch Name',
  //                     style: TextStyle(
  //                         fontSize: 16,
  //                         color: Colors.blue,
  //                         fontWeight: FontWeight.bold),
  //                   ),
  //                 ),
  //                 Padding(
  //                   padding: const EdgeInsets.all(8.0),
  //                   child: ValueListenableBuilder(
  //                       valueListenable: _isInvalid,
  //                       builder: (BuildContext context, bool isInvalid, _) {
  //                         return TextField(
  //                             controller:
  //                                 TextEditingController(text: batchName),
  //                             decoration: InputDecoration(
  //                                 labelText: 'Batch Name',
  //                                 errorText: isInvalid
  //                                     ? 'The name already exists'
  //                                     : null,
  //                                 border: OutlineInputBorder(
  //                                     borderRadius: BorderRadius.circular(16))),
  //                             onChanged: (value) {
  //                               newBatchName = value;
  //                             });
  //                       }),
  //                 ),
  //                 TextButton(
  //                   onPressed: () async {
  //                     final batches = await AppDataProvider.of(context)
  //                         .appData
  //                         .getBatchNames();
  //                     _isInvalid.value = false;
  //                     for (int i = 0; i < batches.length; i++) {
  //                       if (newBatchName == batches[i]) {
  //                         _isInvalid.value = true;
  //                         break;
  //                       }
  //                     }
  //                     if (!_isInvalid.value) Navigator.pop(context);
  //                   },
  //                   child: Container(
  //                     decoration: BoxDecoration(
  //                         color: Colors.blueAccent,
  //                         borderRadius: BorderRadius.circular(12)),
  //                     child: const Padding(
  //                       padding: EdgeInsets.all(8.0),
  //                       child: Text(
  //                         'Save',
  //                         style: TextStyle(color: Colors.white, fontSize: 16),
  //                       ),
  //                     ),
  //                   ),
  //                 )
  //               ],
  //             ),
  //           );
  //         },
  //       );
  //       AppDataProvider.of(context)
  //           .appData
  //           .updateBatchName(batchName, newBatchName);
  //       batchName = newBatchName;
  //     },
  //   );
  // }

  Widget buildStudentTile(BuildContext context, Map<String, dynamic> student) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SizedBox.square(
        dimension: MediaQuery.of(context).size.width * .35,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.face, size: 30),
            const SizedBox(height: 8),
            Text(student['name']!.toString()),
            const SizedBox(height: 8),
            Text(
              '${student['due']!}',
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ],
        ),
      ),
    );
  }

  buildSectionTitle(BuildContext context, title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const Divider(thickness: 1.2),
        ],
      ),
    );
  }
}

class CustomSearchDelegate extends SearchDelegate {
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
          onPressed: () {
            query = '';
          },
          icon: const Icon(Icons.clear))
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
        onPressed: () {
          close(context, null);
        },
        icon: const Icon(Icons.arrow_back));
  }

  @override
  Widget buildResults(BuildContext context) {
    // final isar = AppDataProvider.of(context).appData.isar!;
    // List<Student> matchQuery = filteredStudents(context, query);

    // isar.students.where().filter().nameContains(query).build();
    print('Query --> $matchQuery');
    return ListView.builder(
      itemCount: matchQuery.length,
      itemBuilder: (context, index) {
        Student result = matchQuery[index];
        return ListTile(
          title: Text(result.name!),
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // List<Student> matchQuery = filteredStudents(context, query);
    print('Query --> $matchQuery');
    return ListView.builder(
      itemCount: matchQuery.length,
      itemBuilder: (context, index) {
        var result = matchQuery[index];
        return ListTile(
          title: Text(result.name!),
        );
      },
    );
  }
}

List<Student> matchQuery = [];

Future<List<Student>> filteredStudents(
    BuildContext context, String query) async {
  final isar = AppDataProvider.of(context).appData.isar!;
  AppDataProvider.of(context).appData.getStudents();
  List<Student> students = await isar.students.where().findAll();
  print('Students --> $students');
  for (int i = 0; i < students.length; i++) {
    if (students[i].name!.toLowerCase().contains(query.toLowerCase())) {
      matchQuery.add(students[i]);
    }
  }
  print('Match query --> $matchQuery');
  return [];
}

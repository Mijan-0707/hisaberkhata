import 'package:flutter/material.dart';
import 'package:hisaberkhata/core/theme/app_theme.dart';
import 'package:hisaberkhata/feature/home/widget/batch_tile.dart';
import 'package:hisaberkhata/screens/inherited_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../screens/student_info_screen.dart';
import '../../../screens/studentlist.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 72),
            buildGreetings(context),
            const SizedBox(height: 32),
            buildSearchBar(context),
            const SizedBox(height: 32),
            // buildSectionTitle(context, 'Batches'),
            buildBatchList(context),
            const SizedBox(height: 32),
            // buildSectionTitle(context, 'Bandor Students'),
            buildCechraStudentsList(context),
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
          Spacer(),
          buildSearch(context),
          buildPopupMenu(context)
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

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text('Hisaber Khata'),
      actions: [buildPopupMenu(context)],
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
    var batchNames = AppDataProvider.of(context).appData.studentBatch;
    // final batchData = [
    //   {
    //     'name': 'Physics',
    //     'description': 'Physics Batch of class 10',
    //     'students': 10,
    //     'weekDays': ['Mon', 'Wed', 'Fri'],
    //     'time': '10:00 AM',
    //     'isActive': true,
    //   },
    //   {
    //     'name': 'Chemistry',
    //     'description': 'Chemistry Batch of class 10',
    //     'students': 10,
    //     'weekDays': ['Mon', 'Wed', 'Fri'],
    //     'time': '10:00 AM',
    //     'isActive': true,
    //   },
    //   {
    //     'name': 'Math',
    //     'description': 'Math Batch of class 10',
    //     'students': 10,
    //     'weekDays': ['Mon', 'Wed', 'Fri'],
    //     'time': '10:00 AM',
    //     'isActive': true,
    //   },
    // ];
    return SizedBox(
      height: 250,
      child: ValueListenableBuilder(
          valueListenable: batchNames,
          builder: (context, batchName, _) {
            batchName.sort((a, b) => a.compareTo(b));
            return ListView.builder(
              physics: const BouncingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemBuilder: (context, index) => index < batchName.length
                  ? BatchTile(
                      batch: batchName[index],
                      menuMap: {
                        'Edit': () => studentListOnTapEdit(context, batchName[index]),
                        'Delete': () => studentListOnTapDelete(context, batchName[index]),
                      },
                onTapBody: ()async{
                  await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => StudentListPage(batchName: batchName[index],)));
                  AppDataProvider.of(context).appData.students.value = [];
                },
                onTapAdd: ()async{final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => StudentInfoScreen(batchName: batchName[index],),
                    ));
                if (result == null) return;
                AppDataProvider.of(context).appData.addNewStudent(batchName[index], result);},

                    )
                  : BatchTile.empty(
                onTapEmptyCard: ()async{
                  await onTapCreateNewBatch(context);
                },
              ),
              itemCount: batchName.length + 1,
            );
          }),
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
  Future<void> onTapCreateNewBatch(BuildContext context) async {
    String batch = '';
    String? errMsg;
    final res = await showModalBottomSheet<String?>(
      context: context,
      builder: (context) {
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
                        labelText: 'Name of Batch',
                        errorText: errMsg,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16))),
                    onChanged: (value) {
                      batch = value;
                    },
                  ),
                ),
                TextButton(
                    onPressed: () async {
                      if (batch.isEmpty) {
                        errMsg = 'Batch name cannot be empty';
                      } else if (AppDataProvider.of(context)
                          .appData
                          .studentBatch
                          .value
                          .toSet()
                          .contains(batch)) {
                        errMsg = 'Batch name already exists';
                      } else {
                        errMsg = null;
                      }

                      if (errMsg == null) {
                        Navigator.pop(context, batch);
                      } else {
                        setState2(() {});
                      }
                      // for (int i = 0;
                      //     i <
                      //         AppDataProvider.of(context)
                      //             .appData
                      //             .studentBatch
                      //             .value
                      //             .length;
                      //     i++) {
                      //   if (batch ==
                      //       AppDataProvider.of(context)
                      //           .appData
                      //           .studentBatch
                      //           .value[i]) {
                      //     isInvalid = true;
                      //     break;
                      //   }
                      // }
                      // if (isInvalid) setState2(() {});
                      // else
                      //   Navigator.pop(context, batch);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.blueAccent,
                          borderRadius: BorderRadius.circular(8)),
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'Save',
                          style: TextStyle(color: Colors.white, fontSize: 16),
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
      AppDataProvider.of(context).appData.createBatchName(res);
    }
  }


  void studentListOnTapEdit(BuildContext context, String batchName) {
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
                      final batchNames = await AppDataProvider.of(context)
                          .appData
                          .getBatchNames();
                      _isInvalid.value = false;
                      for (int i = 0; i < batchNames.length; i++) {
                        if (newBatchName == batchNames[i]) {
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


  Widget buildCechraStudentsList(BuildContext context) {
    final studentData = [
      {
        'name': 'Sharif Khan',
        'due': 3,
      },
      {
        'name': 'Mijan Khan',
        'due': 3,
      },
      {
        'name': 'Rahim Khan',
        'due': 3,
      },
      {
        'name': 'Karim Khan',
        'due': 3,
      },
      {
        'name': 'Sharif Khan',
        'due': 3,
      },
      {
        'name': 'Mijan Khan',
        'due': 3,
      },
      {
        'name': 'Rahim Khan',
        'due': 3,
      },
      {
        'name': 'Karim Khan',
        'due': 3,
      },
    ];
    return SizedBox(
      height: MediaQuery.of(context).size.width * .35,
      child: ListView.separated(
        physics: const BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        separatorBuilder: (context, index) => const SizedBox(width: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemBuilder: (context, index) =>
            buildStudentTile(context, studentData[index]),
        itemCount: studentData.length,
      ),
    );
  }

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
    var matchQuery = getAllStudents(context, query);
    print('matchQuery --> ${matchQuery}');
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
    var matchQuery = getAllStudents(context, query);
 print('matchQuery --> ${matchQuery}');
    return ListView.builder(
      itemCount: matchQuery.length,
      itemBuilder: (context, index) {
        var result = matchQuery[index];
        return ListTile(
          title: Text(result),
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    List<String> matchQuery = getAllStudents(context, query);
    return ListView.builder(
      itemCount: matchQuery.length,
      itemBuilder: (context, index) {
        var result = matchQuery[index];
        return ListTile(
          title: Text(result),
        );
      },
    );
  }
}

List<String> getAllStudents(BuildContext context, String query) {
  AppDataProvider.of(context).appData.getAllStudents();
  var allStudents = AppDataProvider.of(context).appData.allStudents;
  print('allStudents --> ${allStudents.value}');
  List<String> matchQuery = [];
  for (int i = 0; i < allStudents.value.length; i++) {
    if (allStudents.value[i].name.toLowerCase().contains(query.toLowerCase())) {
      matchQuery.add(allStudents.value[i].name);
    }
  }
  return matchQuery;
}

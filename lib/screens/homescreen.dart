import 'package:flutter/material.dart';
import 'package:hisaberkhata/appdata/appdata.dart';
import 'package:hisaberkhata/screens/studentlist.dart';

final appData = AppData();

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    appData.getBatchNames();

    return Scaffold(
      floatingActionButton: FloatingActionButton(
          onPressed: () async {
            await onCreateNewBatch(context);
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
                  }
                },
                child: Text(choice),
              );
            }).toList();
          })
        ],
      ),
      body: ValueListenableBuilder(
          valueListenable: appData.studentBatch,
          builder: (context, studentBatch, _) {
            return ListView(
              children: [
                for (int i = 0; i < studentBatch.length; i++)
                  BatchItemWidget(studentBatch[i], onTap: () {
                    onTapBatchName(context, studentBatch[i]);
                  }, onLongPress: () {
                    onLongPressBatchName(context, studentBatch[i]);
                  }),
              ],
            );
          }),
    );
  }

  Future<void> onCreateNewBatch(BuildContext context) async {
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
                        labelText: 'Name of Batch',
                        errorText: isInvalid ? 'The name already exists' : null,
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
                      for (int i = 0;
                          i < appData.studentBatch.value.length;
                          i++) {
                        if (batch == appData.studentBatch.value[i]) {
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
      appData.createBatchName(res);
    }
  }

  Future<void> onTapBatchName(BuildContext context, String name) async {
    await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => StudentListPage(batchName: name)));
  }

  Future<dynamic> onLongPressBatchName(BuildContext context, String name) {
    return showModalBottomSheet(
        context: context,
        builder: (context) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                onTap: () {
                  Navigator.pop(context);
                  deleteItem(context, name);
                },
                leading: const Icon(Icons.delete),
                title: const Text('Delete'),
              ),
              ListTile(
                onTap: () {
                  Navigator.pop(context);
                  var newBatchName = name;
                  showDialog(
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
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  onChanged: (value) {
                                    newBatchName = value;
                                  },
                                ),
                              ),
                              TextButton(
                                  onPressed: () async {
                                    await appData.updateBatchName(
                                        name, newBatchName);
                                    // ignore: use_build_context_synchronously
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
                      });
                },
                leading: const Icon(Icons.edit),
                title: const Text('Edit'),
              )
            ],
          );
        });
  }

  void deleteItem(BuildContext context, String name) {
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
                    await appData.deleteBatchName(name);
                    Navigator.pop(context);
                    // appData.getBatchNames().then((value) {
                    //   studentBatch = value;
                    //   setState(() {});
                    // });
                  },
                  child: const Text('Yes'))
            ],
          );
        });
  }
}

class BatchItemWidget extends StatelessWidget {
  const BatchItemWidget(this.name,
      {required this.onTap, required this.onLongPress, super.key});
  final String name;
  final VoidCallback onTap, onLongPress;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 5, right: 5, top: 5),
      child: GestureDetector(
        onLongPress: () {
          onLongPress();
        },
        onTap: () async {
          onTap();
        },
        child: Container(
          height: 60,
          decoration: BoxDecoration(
              color: Color(0xff455A64),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Color(0xffCFD8DC))),
          child: Center(
            child: Text(
              name,
              style: const TextStyle(color: Colors.white, fontSize: 22),
            ),
          ),
        ),
      ),
    );
  }
}

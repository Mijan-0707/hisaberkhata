import 'package:flutter/material.dart';
import 'package:hisaberkhata/screens/inherited_widget.dart';

import '../../../screens/student_info_screen.dart';

class BatchTile extends StatelessWidget {
  BatchTile({super.key, required this.batch});

  BatchTile.empty({super.key}) : batch = null;

  final String? batch;

  @override
  Widget build(BuildContext context) {
    return batch == null ? buildEmptyCard(context) : buildCard(context, batch!);
  }

  Widget buildEmptyCard(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await onTapCreateNewBatch(context);
      },
      child: Container(
        width: 200,
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.group_add_outlined,
              color: Colors.grey.shade400,
              size: 40,
            ),
            const SizedBox(height: 8),
            Text(
              'Add Batch',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.grey.shade500, fontWeight: FontWeight.w300),
            ),
          ],
        ),
      ),
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

  Card buildCard(BuildContext context, String batch) {
    return Card(
      child: Container(
        width: 200,
        padding: const EdgeInsets.only(top: 16, left: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: buildPopupMenuForBatch(context, batch),
            ),
            const Spacer(),
            Text(
              batch,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 4),
            Text(
              'Description',
              // batch['description']!.toString(),
              style: Theme.of(context).textTheme.labelMedium,
            ),
            const Spacer(flex: 3),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // students icon
                const Icon(Icons.people),
                const SizedBox(width: 8),
                Text(
                  '10',
                  // '${batch['students']!}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () async {
                    final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              StudentInfoScreen(batchName: batch),
                        ));
                    if (result == null) return;
                    AppDataProvider.of(context)
                        .appData
                        .addNewStudent(batch, result);
                  },
                  child: Container(
                    height: 56,
                    width: 56,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      // color: Theme.of(context).brightness == Brightness.dark
                      //     ? Colors.grey.shade300
                      //     : Colors.grey.shade900,
                      borderRadius: const BorderRadius.only(
                        bottomRight: Radius.circular(16),
                        topLeft: Radius.circular(16),
                      ),
                    ),
                    child: Icon(
                      Icons.add,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.black
                          : Colors.white,
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  PopupMenuButton<dynamic> buildPopupMenuForBatch(
      BuildContext context, String batchName) {
    final menuMap = {
      'Edit': (BuildContext context) {
        studentListOnTapEdit(context, batchName);
      },
      'Delete': (BuildContext context) {
        studentListOnTapDelete(context, batchName);
      },
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

  void studentListOnTapDelete(BuildContext context, String batchName) {
    Future.delayed(
      const Duration(seconds: 0),
      () async {
        await showDialog<bool>(
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
      },
    );
  }

  void studentListOnTapEdit(BuildContext context, String batchName) {
    Future.delayed(
      const Duration(seconds: 0),
      () async {
        String newBatchName = '';
        final ValueNotifier<bool> _isInvalid = ValueNotifier<bool>(false);
        await showDialog(
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
}

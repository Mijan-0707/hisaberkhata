import 'package:flutter/material.dart';
import 'package:hisaberkhata/core/data_model/batch.dart';
import 'package:hisaberkhata/screens/inherited_widget.dart';
import 'package:isar/isar.dart';

import '../../../core/data_model/student.dart';
import '../../../screens/student_info_screen.dart';
import '../../../screens/studentlist.dart';
import '../../batch/screen/batch_info_screen.dart';
import 'batch_tile.dart';

class HorizantalBatchList extends StatefulWidget {
  const HorizantalBatchList({super.key});

  @override
  State<HorizantalBatchList> createState() => _HorizantalBatchListState();
}

class _HorizantalBatchListState extends State<HorizantalBatchList> {
  @override
  Widget build(BuildContext context) {
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
                        // studentListOnTapEdit(context, batches[index].),
                        'Delete': () {}
                        // studentListOnTapDelete(context, batches[index]),
                      },
                      onTapBody: () async {
                        await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => StudentListPage(
                                    batchId: batches.data![index].id,
                                    batchName: batches.data![index].name)));
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
                            setState(() {});
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
}

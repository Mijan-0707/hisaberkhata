// import 'package:flutter/material.dart';
// import 'package:hisaberkhata/core/data_model/batch.dart';
// import 'package:hisaberkhata/screens/inherited_widget.dart';
// import 'package:hisaberkhata/screens/studentlist.dart';

// class HomeScreenOld extends StatelessWidget {
//   const HomeScreenOld({super.key});

//   @override
//   Widget build(BuildContext context) {
//     // AppDataProvider.of(context).appData.getBatchNames();

//     return Scaffold(
//       backgroundColor: Colors.white,
//       floatingActionButton: FloatingActionButton(
//           onPressed: () async {
//             await onTapCreateNewBatch(context);
//           },
//           backgroundColor: const Color(0xff536DFE),
//           child: const Icon(Icons.add)),
//       appBar: AppBar(
//         actionsIconTheme: const IconThemeData.fallback(),
//         leading: Row(
//           children: [
//             const SizedBox(
//               width: 5,
//             ),
//             Container(
//               height: 50,
//               width: 50,
//               decoration: const BoxDecoration(
//                 shape: BoxShape.circle,
//               ),
//               child: Image.asset('assets/pic/pp.png', fit: BoxFit.fill),
//             ),
//           ],
//         ),
//         centerTitle: true,
//         title: const Text(
//           'List Of Batches',
//           style: TextStyle(color: Colors.black),
//         ),
//         backgroundColor: const Color(0xffffffff),
//         actions: [
//           PopupMenuButton(itemBuilder: (c) {
//             return {'Backup', 'Restore'}.map((String choice) {
//               return PopupMenuItem(
//                 child: Text(choice),
//                 onTap: () async {
//                   if (choice == 'Backup') {
//                     AppDataProvider.of(context).appData.createBackup();
//                   } else if (choice == 'Restore') {
//                     await AppDataProvider.of(context).appData.restoreData();
//                   }
//                 },
//               );
//             }).toList();
//           })
//         ],
//       ),
//       body: ValueListenableBuilder(
//           valueListenable: AppDataProvider.of(context).appData.studentBatch,
//           builder: (context, studentBatch, _) {
//             return SizedBox(
//               height: 300,
//               child: ListView(
//                 children: [
//                   for (int i = 0; i < studentBatch.length; i++)
//                     BatchItemWidget(studentBatch[i].name!, onTap: () {
//                       // onTapBatchName(context, studentBatch[i]);
//                     }, onLongPress: () {
//                       // onLongPressBatchName(context, studentBatch[i]);
//                     }),
//                 ],
//               ),
//             );
//           }),
//     );
//   }

//   Future<void> onTapCreateNewBatch(BuildContext context) async {
//     String batch = '';
//     String? errMsg;
//     final res = await showModalBottomSheet<String?>(
//       context: context,
//       builder: (context) {
//         return StatefulBuilder(builder: (context, setState2) {
//           return Padding(
//             padding: EdgeInsets.only(
//                 bottom: MediaQuery.of(context).viewInsets.bottom),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: TextField(
//                     keyboardType: TextInputType.text,
//                     decoration: InputDecoration(
//                         labelText: 'Name of Batch',
//                         errorText: errMsg,
//                         border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(16))),
//                     onChanged: (value) {
//                       batch = value;
//                     },
//                   ),
//                 ),
//                 TextButton(
//                     onPressed: () async {
//                       if (batch.isEmpty) {
//                         errMsg = 'Batch name cannot be empty';
//                       } else if (AppDataProvider.of(context)
//                           .appData
//                           .studentBatch
//                           .value
//                           .toSet()
//                           .contains(batch)) {
//                         errMsg = 'Batch name already exists';
//                       } else {
//                         errMsg = null;
//                       }

//                       if (errMsg == null) {
//                         Navigator.pop(context, batch);
//                       } else {
//                         setState2(() {});
//                       }
//                       // for (int i = 0;
//                       //     i <
//                       //         AppDataProvider.of(context)
//                       //             .appData
//                       //             .studentBatch
//                       //             .value
//                       //             .length;
//                       //     i++) {
//                       //   if (batch ==
//                       //       AppDataProvider.of(context)
//                       //           .appData
//                       //           .studentBatch
//                       //           .value[i]) {
//                       //     isInvalid = true;
//                       //     break;
//                       //   }
//                       // }
//                       // if (isInvalid) setState2(() {});
//                       // else
//                       //   Navigator.pop(context, batch);
//                     },
//                     child: Container(
//                       decoration: BoxDecoration(
//                           color: Colors.blueAccent,
//                           borderRadius: BorderRadius.circular(8)),
//                       child: const Padding(
//                         padding: EdgeInsets.all(8.0),
//                         child: Text(
//                           'Save',
//                           style: TextStyle(color: Colors.white, fontSize: 16),
//                         ),
//                       ),
//                     ))
//               ],
//             ),
//           );
//         });
//       },
//     );
//     if (res != null && res.isNotEmpty) {
//       // AppDataProvider.of(context).appData.createBatchName(res);
//     }
//   }

//   // Future<void> onTapBatchName(BuildContext context, String name) async {
//   //   await Navigator.push(
//   //       context,
//   //       MaterialPageRoute(
//   //           builder: (context) => StudentListPage(batchId: )));
//   //   AppDataProvider.of(context).appData.students.value = [];
//   // }

//   Future<dynamic> onLongPressBatchName(BuildContext context, String name) {
//     return showModalBottomSheet(
//         context: context,
//         builder: (context) {
//           return Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               ListTile(
//                 onTap: () {
//                   Navigator.pop(context);
//                   deleteItem(context, name);
//                 },
//                 leading: const Icon(Icons.delete),
//                 title: const Text('Delete'),
//               ),
//               ListTile(
//                 onTap: () {
//                   Navigator.pop(context);
//                   var newBatchName = name;
//                   showDialog(
//                       context: context,
//                       builder: (context) {
//                         return Dialog(
//                           child: Column(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               Padding(
//                                 padding: const EdgeInsets.all(8.0),
//                                 child: TextField(
//                                   decoration: InputDecoration(
//                                     labelText: 'Name of Batch',
//                                     border: OutlineInputBorder(
//                                       borderRadius: BorderRadius.circular(16),
//                                     ),
//                                   ),
//                                   onChanged: (value) {
//                                     newBatchName = value;
//                                   },
//                                 ),
//                               ),
//                               TextButton(
//                                   onPressed: () async {
//                                     await AppDataProvider.of(context)
//                                         .appData
//                                         .updateBatchName(name, newBatchName);
//                                     // ignore: use_build_context_synchronously
//                                     Navigator.pop(context);
//                                   },
//                                   child: Container(
//                                     decoration: BoxDecoration(
//                                         color: Colors.blueAccent,
//                                         borderRadius: BorderRadius.circular(8)),
//                                     child: const Padding(
//                                       padding: EdgeInsets.all(8.0),
//                                       child: Text(
//                                         'Save',
//                                         style: TextStyle(
//                                             color: Colors.white, fontSize: 16),
//                                       ),
//                                     ),
//                                   ))
//                             ],
//                           ),
//                         );
//                       });
//                 },
//                 leading: const Icon(Icons.edit),
//                 title: const Text('Edit'),
//               )
//             ],
//           );
//         });
//   }

//   void deleteItem(BuildContext context, String name) {
//     showDialog(
//         context: context,
//         builder: (context) {
//           return AlertDialog(
//             title: const Text('Delete Batch'),
//             content: const Text('Are you sure you want to delete this batch?'),
//             actions: [
//               TextButton(
//                   onPressed: () {
//                     Navigator.pop(context);
//                   },
//                   child: const Text('No')),
//               TextButton(
//                   onPressed: () async {
//                     await AppDataProvider.of(context)
//                         .appData
//                         .deleteBatchName(name);
//                     Navigator.pop(context);
//                   },
//                   child: const Text('Yes'))
//             ],
//           );
//         });
//   }
// }

// class BatchItemWidget extends StatelessWidget {
//   const BatchItemWidget(this.name,
//       {required this.onTap, required this.onLongPress, super.key});

//   final String name;
//   final VoidCallback onTap, onLongPress;

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.only(left: 5, right: 5, top: 5),
//       child: GestureDetector(
//         onLongPress: () {
//           onLongPress();
//         },
//         onTap: () async {
//           onTap();
//         },
//         child: Container(
//           height: 60,
//           decoration: BoxDecoration(
//               color: Color(0xff455A64),
//               borderRadius: BorderRadius.circular(8),
//               border: Border.all(color: Color(0xffCFD8DC))),
//           child: Center(
//             child: Text(
//               name,
//               style: const TextStyle(color: Colors.white, fontSize: 22),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

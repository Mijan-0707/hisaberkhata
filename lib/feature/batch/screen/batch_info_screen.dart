import 'package:flutter/material.dart';
import 'package:hisaberkhata/core/data_model/batch.dart';
import 'package:hisaberkhata/core/data_model/student.dart';
import 'package:hisaberkhata/screens/inherited_widget.dart';
import 'package:toggle_switch/toggle_switch.dart';

class BatchInfoScreen extends StatelessWidget {
  final Batch details;

  static var context;
  BatchInfoScreen({super.key}) : details = Batch();
  BatchInfoScreen.update({super.key, required this.details});

  ValueNotifier<bool> isInvalid = ValueNotifier(false);
  bool isActive = true;
  late final batchNameController = TextEditingController(text: details.name);
  late final batchDescriptionController =
      TextEditingController(text: details.description);
  late final batchTimeController = TextEditingController(text: details.time);
  @override
  Widget build(BuildContext context) {
    print('I am in');
    final List<String> weekDays = [
      'Sat',
      'Sun',
      'Mon',
      'Tue',
      'Wed',
      'Thu',
      'Fri'
    ];
    List<String> workingDays = [];
    ValueNotifier<bool> isSelected = ValueNotifier(false);
    ValueNotifier<String> time = ValueNotifier('');
    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          title: const Text(
            'Student Information',
            style: TextStyle(
                fontSize: 16, color: Colors.blue, fontWeight: FontWeight.bold),
          )),
      body: ListView(
        shrinkWrap: true,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ValueListenableBuilder(
                valueListenable: isInvalid,
                builder: (context, v, _) {
                  return TextField(
                    controller: batchNameController,
                    keyboardType: TextInputType.name,
                    decoration: InputDecoration(
                      errorText: v ? 'Please enter the Batch name' : null,
                      labelText: 'Batch Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  );
                }),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              keyboardType: TextInputType.name,
              decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16))),
              controller: batchDescriptionController,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              for (int i = 0; i < weekDays.length; i++)
                GestureDetector(
                  onTap: () {
                    isSelected.value = !isSelected.value;
                    print(isSelected);
                    workingDays.add(weekDays[i]);
                  },
                  child: ValueListenableBuilder(
                      valueListenable: isSelected,
                      builder: (context, isSelected, _) {
                        return Container(
                          height: 35,
                          width: 35,
                          margin: EdgeInsets.all(8),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              // color: weekDays[i] == workingDays[i]
                              // ? Colors.green
                              color: Colors.grey),
                          child: Text(weekDays[i]),
                        );
                      }),
                )
            ],
          ),
          GestureDetector(
            onTap: () async {
              time.value = await TimePicker(context);
            },
            child: ValueListenableBuilder(
                valueListenable: time,
                builder: (context, time, _) {
                  return Container(
                    height: 50,
                    width: 50,
                    color: Colors.red,
                    child: Text(time),
                  );
                }),
          ),
          // Here, default theme colors are used for activeBgColor, activeFgColor, inactiveBgColor and inactiveFgColor
          // ToggleSwitch(
          //   initialLabelIndex: 0,
          //   totalSwitches: 2,
          //   labels: const ['Active', 'Deactivate'],
          //   onToggle: (index) => index == 0 ? isActive = true : false

          //     // print('switched to: $index');

          // ),
          ElevatedButton(
            onPressed: () async {
              if (batchNameController.text.trim() != '') {
                details.name = batchNameController.text;
                details.description = batchDescriptionController.text;
                details.weekDays = workingDays;
                details.isActive = true;
                details.time = time.value;
                Navigator.pop(context, details);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Name is Empty')));
                isInvalid.value = true;
              }
            },
            child: const Text(
              'Save',
            ),
          )
        ],
      ),
    );
  }

  String TimePicker(BuildContext context) {
    Future<TimeOfDay?> selectedTime = showTimePicker(
      initialTime: TimeOfDay.now(),
      context: context,
    );

    return selectedTime.toString();
  }
}

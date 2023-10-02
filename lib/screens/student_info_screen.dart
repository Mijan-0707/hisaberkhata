import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../appdata/student_details_data_model.dart';

class StudentInfoScreen extends StatelessWidget {
  var batchName;
  final StudentDetails details;
  StudentInfoScreen({super.key, required this.batchName})
      : details = StudentDetails();
  StudentInfoScreen.update(
      {super.key, required this.batchName, required this.details});

  ValueNotifier<bool> isInvalid = ValueNotifier(false);
  late final nameController = TextEditingController(text: details.name);
  late final addressController = TextEditingController(text: details.address);
  late final rollController = TextEditingController(text: details.roll);
  late final mobileController = TextEditingController(text: details.mobile);
  late final paymentController = TextEditingController(text: details.payment);
  late final sectionController = TextEditingController(
    text: details.section,
  );
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Student Information',
          style: TextStyle(
              fontSize: 16, color: Colors.blue, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        shrinkWrap: true,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ValueListenableBuilder(
                valueListenable: isInvalid,
                builder: (context, v, _) {
                  return TextField(
                    controller: nameController,
                    keyboardType: TextInputType.name,
                    decoration: InputDecoration(
                      errorText: v ? 'Please enter the Student name' : null,
                      labelText: 'Name',
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
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp('[0-9.,]')),
              ],
              decoration: InputDecoration(
                  labelText: 'Roll',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16))),
              controller: rollController,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              keyboardType: TextInputType.name,
              decoration: InputDecoration(
                  labelText: 'section',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16))),
              controller: sectionController,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp('[0-9.,+]')),
              ],
              decoration: InputDecoration(
                  labelText: 'Mobile',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16))),
              controller: mobileController,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              keyboardType: TextInputType.streetAddress,
              decoration: InputDecoration(
                  labelText: 'Address',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16))),
              controller: addressController,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp('[0-9.,]')),
              ],
              decoration: InputDecoration(
                  labelText: 'Payment',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16))),
              controller: paymentController,
            ),
          ),
          TextButton(
            onPressed: () async {
              if (nameController.text != '') {
                details.name = nameController.text;
                details.payment = paymentController.text;
                details.roll = rollController.text;
                details.section = sectionController.text;
                details.address = addressController.text;
                details.mobile = mobileController.text;
                Navigator.pop(context, details);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Name is Empty')));
                isInvalid.value = true;
              }
            },
            child: Container(
              height: 40,
              width: MediaQuery.of(context).size.width - 10,
              decoration: BoxDecoration(
                  color: Colors.blueAccent,
                  borderRadius: BorderRadius.circular(12)),
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Center(
                  child: Text(
                    'Save',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

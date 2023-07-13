import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../appdata/student_details_data_model.dart';

class StudentInfoScreen extends StatefulWidget {
  var batchName;

  StudentInfoScreen({super.key, required this.batchName});

  @override
  State<StudentInfoScreen> createState() => _StudentInfoScreenState();
}

class _StudentInfoScreenState extends State<StudentInfoScreen> {
  String name = '', roll = '', mobile = '', address = '', payment = '';
  bool isInvalid = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        shrinkWrap: true,
        children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Center(
              child: Text(
                'Student Information',
                style: TextStyle(
                    fontSize: 16,
                    color: Colors.blue,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              keyboardType: TextInputType.name,
              decoration: InputDecoration(
                  errorText: isInvalid ? 'Please enter the Student name' : null,
                  labelText: 'Name',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16))),
              onChanged: (value) => name = value,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                    labelText: 'Roll',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16))),
                onChanged: (value) => roll = value),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                    labelText: 'Mobile',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16))),
                onChanged: (value) => mobile = value),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
                keyboardType: TextInputType.streetAddress,
                decoration: InputDecoration(
                    labelText: 'Address',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16))),
                onChanged: (value) => address = value),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                    labelText: 'Payment',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16))),
                onChanged: (value) => payment = value),
          ),
          TextButton(
            onPressed: () async {
              var data = StudentDetails(
                address: address,
                batch: widget.batchName,
                mobile: mobile,
                name: name,
                payment: payment,
                roll: roll,
              );
              if (data.name != '') {
                Navigator.pop(context, data);
              }
              if (name == '') {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Name is Empty')));
                isInvalid = true;
                setState(() {});
                return;
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

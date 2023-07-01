const List<String> months = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'Auguest',
  'September',
  'October',
  'November',
  'December'
];

class StudenDetails {
  StudenDetails(
      {required this.name,
      required this.mobile,
      required this.address,
      required this.roll,
      required this.payment,
      required this.studentBatch});
  String name, mobile, address, roll, payment, studentBatch;
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'address': address,
      'mobile': mobile,
      'roll': roll,
      'payment': payment,
      'studentBatch': studentBatch
    };
  }

  @override
  String toString() {
    return '$name, $mobile, $address';
  }
}

final payedMonth = [];

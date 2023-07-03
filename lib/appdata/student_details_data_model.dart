class StudentDetails {
  StudentDetails({
    required this.name,
    required this.mobile,
    required this.address,
    required this.roll,
    required this.payment,
    required this.batch,
  });

  String name, mobile, address, roll, payment, batch;

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'address': address,
      'mobile': mobile,
      'roll': roll,
      'payment': payment,
      'studentBatch': batch
    };
  }

  @override
  String toString() {
    return '$name, $mobile, $address';
  }
}

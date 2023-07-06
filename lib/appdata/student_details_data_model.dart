class StudentDetails {
  StudentDetails({
    this.name = '',
    this.mobile = '',
    this.address = '',
    this.roll = '',
    this.payment = '',
    this.batch = '',
  });

  String name, mobile, address, roll, payment, batch;
  List<String> paymentHistory = [];

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'address': address,
      'mobile': mobile,
      'roll': roll,
      'payment': payment,
      'studentBatch': batch,
      'paymentHistory':paymentHistory
    };
  }

  @override
  String toString() {
    return '$name, $mobile, $address';
  }
}

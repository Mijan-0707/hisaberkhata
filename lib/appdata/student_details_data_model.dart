class StudentDetails {
  StudentDetails({
    this.name = '',
    this.mobile = '',
    this.address = '',
    this.roll = '',
    this.section = '',
    this.payment = '',
    this.batch = '',
  });

  String name, mobile, address, roll, payment, batch, section;
  List<String> paymentHistory = [];

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'address': address,
      'mobile': mobile,
      'roll': roll,
      'section': section,
      'payment': payment,
      'studentBatch': batch,
      'paymentHistory': paymentHistory
    };
  }

  @override
  String toString() {
    return '$name, $mobile, $address';
  }
}

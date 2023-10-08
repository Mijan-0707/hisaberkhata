import 'package:isar/isar.dart';

part 'student.g.dart';

@collection
class Student {
  Id id = Isar.autoIncrement;

  @Index(type: IndexType.value)
  String? name;
  String? mobile, mobile2;
  String? address;
  String? roll;
  String? payment;
  int? batchId;
  String? section;
  List<String>? paymentHistory = [];
}

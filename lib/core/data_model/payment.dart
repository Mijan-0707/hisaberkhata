import 'package:isar/isar.dart';
// part 'payment.g.dart';

@collection
class Payment {
  Id id = Isar.autoIncrement;
  @Index(type: IndexType.value)
  String? name;
  String? description;
  List<int>? students;
  List<String>? weekDays;
  String? time;
  bool? isActive;
}

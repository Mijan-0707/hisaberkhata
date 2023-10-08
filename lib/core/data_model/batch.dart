import 'package:isar/isar.dart';
part 'batch.g.dart';

@collection
class Batch {
  Id id = Isar.autoIncrement;
  @Index(type: IndexType.value)
  String? name;
  String? description;
  List<int>? students;
  List<String>? weekDays;
  String? time;
  bool? isActive;
}

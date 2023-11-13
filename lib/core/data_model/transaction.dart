import 'package:isar/isar.dart';

part 'transaction.g.dart';

@collection
class Transaction {
  Id id = Isar.autoIncrement;

  @Index(type: IndexType.value)
  String? payment;
  String? month;
  String? date;
  int? studentId;
}

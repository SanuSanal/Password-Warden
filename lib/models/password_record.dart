import 'package:hive/hive.dart';

part 'password_record.g.dart';

@HiveType(typeId: 0)
class PasswordRecord extends HiveObject {
  @HiveField(0)
  String applicationName;

  @HiveField(1)
  String username;

  @HiveField(2)
  String password;

  @HiveField(3)
  Map<String, String> additionalInfo;

  PasswordRecord({
    required this.applicationName,
    required this.username,
    required this.password,
    required this.additionalInfo,
  });
}

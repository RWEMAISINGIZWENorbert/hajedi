import 'package:hive/hive.dart';

part 'user.g.dart';

@HiveType(typeId: 0)
class User extends HiveObject {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final String role;

  @HiveField(2)
  final String password;

  User({
    required this.name,
    required this.role,
    required this.password,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json['name'] ?? '',
      role: json['role'] ?? '',
      password: json['password'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'role': role,
      'password': password,
    };
  }

  User copyWith({
    String? name,
    String? role,
    String? password,
  }) {
    return User(
      name: name ?? this.name,
      role: role ?? this.role,
      password: password ?? this.password,
    );
  }
}
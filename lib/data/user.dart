import 'package:hive/hive.dart';

part 'user.g.dart';

@HiveType(typeId: 0)
class User extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String role;

  @HiveField(3)
  final String password;

  User({
    required this.id,
    required this.name,
    required this.role,
    required this.password,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? json['_id'] ?? '',
      name: json['name'] ?? '',
      role: json['role'] ?? '',
      password: json['password'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'role': role,
      'password': password,
    };
  }

  User copyWith({
    String? id,
    String? name,
    String? role,
    String? password,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      role: role ?? this.role,
      password: password ?? this.password,
    );
  }
}
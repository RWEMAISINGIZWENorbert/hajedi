part of 'user_bloc.dart';

@immutable
abstract class UserEvent {}

class LoadUsers extends UserEvent {}

class LoadUser extends UserEvent {
  final String userId;

  LoadUser({required this.userId});
}

class UpdateUser extends UserEvent {
  final String userId;
  final String? name;
  final String? role;
  final String? password;

  UpdateUser({
    required this.userId,
    this.name,
    this.role,
    this.password,
  });
}

class RemoveUser extends UserEvent {
  final String userId;

  RemoveUser({required this.userId});
}
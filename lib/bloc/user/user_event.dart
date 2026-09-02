part of 'user_bloc.dart';

@immutable
abstract class UserEvent {}

class LoadUsers extends UserEvent {}

class AddUserLocal extends UserEvent {
  final User user;

  AddUserLocal({required this.user});
}

class UpdateUserLocal extends UserEvent {
  final String userId;
  final User user;

  UpdateUserLocal({
    required this.userId,
    required this.user,
  });
}

class DeleteUserLocal extends UserEvent {
  final String userId;

  DeleteUserLocal({required this.userId});
}

class SyncUsers extends UserEvent {}
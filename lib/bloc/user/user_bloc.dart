import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hajedi/data/user.dart';
import 'package:hajedi/repository/user_repository.dart';

part 'user_event.dart';
part 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final UserRepository _repository;

  UserBloc(this._repository) : super(UserInitial()) {
    on<LoadUsers>(_loadUsers);
    on<LoadUser>(_loadUser);
    on<UpdateUser>(_updateUser);
    on<RemoveUser>(_removeUser);
  }

  Future<void> _loadUsers(
    LoadUsers event,
    Emitter<UserState> emit,
  ) async {
    emit(UsersLoadingState());

    try {
      final users = await _repository.getAllUsers();
      emit(UsersLoadedState(users: users));
    } catch (e) {
      emit(RequestFailureState(message: e.toString()));
    }
  }

  Future<void> _loadUser(
    LoadUser event,
    Emitter<UserState> emit,
  ) async {
    emit(UsersLoadingState());

    try {
      final users = await _repository.getAllUsers();
      final user = users.firstWhere(
        (u) => u.id == event.userId,
        orElse: () => throw Exception('User not found'),
      );

      emit(UsersLoadedState(users: [user]));
    } catch (e) {
      emit(RequestFailureState(message: e.toString()));
    }
  }

  Future<void> _updateUser(
    UpdateUser event,
    Emitter<UserState> emit,
  ) async {
    emit(UsersLoadingState());

    try {
      
      await _repository.updateUser(
        event.userId,
        name: event.name,
        role: event.role,
        password: event.password,
      );

      emit(RequestSuccessfullyState(message: 'User updated successfully'));
    } catch (e) {
      emit(RequestFailureState(message: e.toString()));
    }
  }

  Future<void> _removeUser(
    RemoveUser event,
    Emitter<UserState> emit,
  ) async {
    emit(UsersLoadingState());

    try {
      await _repository.removeUser(event.userId);
      emit(RequestSuccessfullyState(message: 'User removed successfully'));
    } catch (e) {
      emit(RequestFailureState(message: e.toString()));
    }
  }
}
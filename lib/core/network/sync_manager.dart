import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hajedi/core/helpers/sync_queue.dart';
import 'package:hajedi/core/network/sync_metadata.dart';
import 'package:hajedi/data/sync_queue_item.dart';
import 'package:hajedi/data/user.dart';
import 'package:hajedi/repository/user_repository.dart';
import 'package:hive/hive.dart';

class SyncManager {
  final Box<SyncQueueItem> queueBox;
  final Box<User> userBox;
  final UserRepository _userRepository;

  bool _isSyncing = false;
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  SyncManager(
    this.queueBox,
    this.userBox, {
    UserRepository? userRepository,
  }) : _userRepository = userRepository ?? UserRepository();

  Future<void> start() async {
    final connectivity = Connectivity();

    _subscription = connectivity.onConnectivityChanged.listen(
      (results) async {
        final hasConnection =
            !results.contains(ConnectivityResult.none);

        if (hasConnection) {
          await syncIfConnected();
        }
      },
    );

    await syncIfConnected();
  }

  Future<void> stop() async {
    await _subscription?.cancel();
    _subscription = null;
  }

  Future<void> syncIfConnected() async {
    if (_isSyncing) {
      return;
    }

    final connectivity = Connectivity();
    final results = await connectivity.checkConnectivity();

    if (results.contains(ConnectivityResult.none)) {
      return;
    }

    _isSyncing = true;

    try {
      await _uploadPendingChanges();
      await _pullRemoteChanges();
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> _uploadPendingChanges() async {
    final pending = SyncQueue.getPending();

    for (final item in pending) {
      await SyncQueue.markSyncing(item.id);

      try {
        final success = await _sendToServer(item);

        if (success) {
          await SyncQueue.markSynced(item.id);
        } else {
          await SyncQueue.markFailed(
            item.id,
            error: 'Sync failed',
          );
        }
      } catch (error) {
        await SyncQueue.markFailed(
          item.id,
          error: error.toString(),
        );
      }
    }

    await SyncQueue.removeSynced();
  }

  Future<bool> _sendToServer(SyncQueueItem item) async {
    final payload = jsonDecode(item.payload)
        as Map<String, dynamic>;

    if (item.entityType != 'user') {
      return false;
    }

    switch (item.operationType) {
      case 'create':
        final localUser = User(
          id: payload['id']?.toString() ?? '',
          clientId: payload['clientId']?.toString() ??
              payload['id']?.toString() ??
              '',
          name: payload['name']?.toString() ?? '',
          role: payload['role']?.toString() ?? 'employee',
          password: payload['password']?.toString() ?? '',
        );

        final serverUser =
            await _userRepository.registerUser(localUser);

        final localUserKey = localUser.clientId;
        final storedUser = userBox.get(localUserKey);

        if (storedUser != null) {
          await userBox.put(
            localUserKey,
            storedUser.copyWith(
              id: serverUser.id,
              clientId: serverUser.clientId,
              isSynced: true,
              updatedAt: DateTime.now(),
            ),
          );
        }

        return true;

      case 'update':
        final clientId =
            payload['clientId']?.toString() ??
            payload['id']?.toString();

        if (clientId == null || clientId.isEmpty) {
          return false;
        }

        await _userRepository.updateUser(
          clientId,
          name: payload['name']?.toString(),
          role: payload['role']?.toString(),
          password: payload['password']?.toString(),
        );

        await _markLocalUserAsSynced(clientId);
        return true;

      case 'delete':
        final clientId =
            payload['clientId']?.toString() ??
            payload['id']?.toString();

        if (clientId == null || clientId.isEmpty) {
          return false;
        }

        await _userRepository.removeUser(clientId);
        return true;

      default:
        return false;
    }
  }

  Future<void> _markLocalUserAsSynced(
    String clientId,
  ) async {
    final user = userBox.get(clientId);

    if (user == null) {
      return;
    }

    await userBox.put(
      clientId,
      user.copyWith(
        isSynced: true,
        updatedAt: DateTime.now(),
      ),
    );
  }

  Future<void> _pullRemoteChanges() async {
    final cursor = await SyncMetadata.getUsersCursor();

    final response = await _userRepository.getUserChanges(
      since: cursor,
    );

    final data = response['data'] as Map<String, dynamic>;

    final created = data['created'] as List<dynamic>? ?? [];
    final updated = data['updated'] as List<dynamic>? ?? [];
    final deleted = data['deleted'] as List<dynamic>? ?? [];

    for (final item in created) {
      await _saveRemoteUser(
        Map<String, dynamic>.from(item as Map),
      );
    }

    for (final item in updated) {
      await _saveRemoteUser(
        Map<String, dynamic>.from(item as Map),
      );
    }

    for (final item in deleted) {
      final deletedData =
          Map<String, dynamic>.from(item as Map);

      final clientId = deletedData['clientId']?.toString();

      if (clientId != null && clientId.isNotEmpty) {
        await userBox.delete(clientId);
      }
    }

    final nextCursor = response['nextCursor']?.toString();

    if (nextCursor != null && nextCursor.isNotEmpty) {
      await SyncMetadata.saveUsersCursor(nextCursor);
    }
  }

  Future<void> _saveRemoteUser(
    Map<String, dynamic> data,
  ) async {
    final clientId = data['clientId']?.toString();

    if (clientId == null || clientId.isEmpty) {
      return;
    }

    final existing = userBox.get(clientId);
    final remoteUser = User.fromJson(data);

    await userBox.put(
      clientId,
      remoteUser.copyWith(
        password: existing?.password ?? '',
        isSynced: true,
      ),
    );
  }
}
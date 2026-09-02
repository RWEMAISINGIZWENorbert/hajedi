import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hajedi/core/helpers/sync_queue.dart';
import 'package:hajedi/data/sync_queue_item.dart';
import 'package:hajedi/data/user.dart';
import 'package:hajedi/repository/user_repository.dart';
import 'package:hive/hive.dart';

class SyncManager {
  final Box<SyncQueueItem> queueBox;
  final UserRepository _userRepository = UserRepository();

  bool _isSyncing = false;
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  SyncManager(this.queueBox);

  Future<void> start() async {
    final connectivity = Connectivity();

    _subscription = connectivity.onConnectivityChanged.listen((results) async {
      final hasConnection = !results.contains(ConnectivityResult.none);

      if (hasConnection) {
        await syncPending();
      }
    });

    final result = await connectivity.checkConnectivity();
    if (!result.contains(ConnectivityResult.none)) {
      await syncPending();
    }
  }

  Future<void> stop() async {
    await _subscription?.cancel();
  }

  Future<void> syncPending() async {
    if (_isSyncing) return;

    _isSyncing = true;

    try {
      final pending = SyncQueue.getPending();

      for (final item in pending) {
        await SyncQueue.markSyncing(item.id);

        final success = await sendToServer(item);

        if (success) {
          await SyncQueue.markSynced(item.id);
        } else {
          await SyncQueue.markFailed(item.id, error: 'Sync failed');
        }
      }

      await SyncQueue.removeSynced();
    } finally {
      _isSyncing = false;
    }
  }

  Future<bool> sendToServer(SyncQueueItem item) async {
    try {
      final payload = jsonDecode(item.payload);

      switch (item.entityType) {
        case 'user':
          switch (item.operationType) {
            case 'create':
              await _userRepository.registerUser(
                User(
                  id: payload['id'] ?? '',
                  name: payload['name'] ?? '',
                  role: payload['role'] ?? 'employee',
                  password: payload['password'] ?? '',
                ),
              );
              return true;

            case 'update':
              await _userRepository.updateUser(
                payload['id'],
                name: payload['name'],
                role: payload['role'],
                password: payload['password'],
              );
              return true;

            case 'delete':
              await _userRepository.removeUser(payload['id']);
              return true;

            default:
              return false;
          }

        default:
          return false;
      }
    } catch (e) {
      return false;
    }
  }
}
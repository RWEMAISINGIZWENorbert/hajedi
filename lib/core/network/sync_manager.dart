import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hajedi/core/helpers/sync_queue.dart';
import 'package:hajedi/core/network/sync_metadata.dart';
import 'package:hajedi/data/sync_queue_item.dart';
import 'package:hajedi/data/user.dart';
import 'package:hajedi/repository/user_repository.dart';
import 'package:hajedi/data/product.dart';
import 'package:hajedi/repository/product_repository.dart';
import 'package:hive/hive.dart';

class SyncManager {
  final Box<SyncQueueItem> queueBox;
  final Box<User> userBox;
  final UserRepository _userRepository;
  final Box<Product> productBox;
  final ProductRepository _productRepository;

  bool _isSyncing = false;
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  SyncManager(
  this.queueBox,
  this.userBox,
  this.productBox, {
  UserRepository? userRepository,
  ProductRepository? productRepository,
})  : _userRepository = userRepository ?? UserRepository(),
      _productRepository = productRepository ?? ProductRepository();

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
     await _pullRemoteUserChanges();
     await _pullRemoteProductChanges();
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
    final payload = jsonDecode(item.payload) as Map<String, dynamic>;

  switch (item.entityType) {
    case 'user':
      return _sendUserToServer(item, payload);

    case 'product':
      return _sendProductToServer(item, payload);

    default:
      return false;
   }
  }

  Future<bool> _sendUserToServer(
  SyncQueueItem item,
  Map<String, dynamic> payload,
) async {
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

      final storedUser = userBox.get(localUser.clientId);

      if (storedUser != null) {
        await userBox.put(
          localUser.clientId,
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

  Future<bool> _sendProductToServer(
  SyncQueueItem item,
  Map<String, dynamic> payload,
) async {
  switch (item.operationType) {
    case 'create':
      final localProduct = Product(
        id: payload['id']?.toString() ?? '',
        clientId: payload['clientId']?.toString() ??
            payload['id']?.toString() ??
            '',
        name: payload['name']?.toString() ?? '',
        productType: payload['productType']?.toString() ?? 'item',
        purchaseMethod:
            payload['purchaseMethod']?.toString() ?? 'unit',
        saleMethod: payload['saleMethod']?.toString() ?? 'unit',
        purchaseCost:
            _toDouble(payload['purchaseCost']),
        sellingPrice:
            _toDouble(payload['sellingPrice']),
        unitsPerPackage:
            _toInt(payload['unitsPerPackage'], fallback: 1),
        quantityInStock:
            _toInt(payload['quantityInStock']),
      );

      final serverProduct =
          await _productRepository.registerProduct(localProduct);

      final storedProduct =
          productBox.get(localProduct.clientId);

      if (storedProduct != null) {
        await productBox.put(
          localProduct.clientId,
          storedProduct.copyWith(
            id: serverProduct.id,
            clientId: serverProduct.clientId,
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

      await _productRepository.updateProduct(
        clientId,
        name: payload['name']?.toString(),
        productType: payload['productType']?.toString(),
        purchaseMethod:
            payload['purchaseMethod']?.toString(),
        saleMethod: payload['saleMethod']?.toString(),
        purchaseCost: payload['purchaseCost'] == null
            ? null
            : _toDouble(payload['purchaseCost']),
        sellingPrice: payload['sellingPrice'] == null
            ? null
            : _toDouble(payload['sellingPrice']),
        unitsPerPackage: payload['unitsPerPackage'] == null
            ? null
            : _toInt(payload['unitsPerPackage']),
        quantityInStock: payload['quantityInStock'] == null
            ? null
            : _toInt(payload['quantityInStock']),
      );

      await _markLocalProductAsSynced(clientId);
      return true;

    case 'delete':
      final clientId =
          payload['clientId']?.toString() ??
          payload['id']?.toString();

      if (clientId == null || clientId.isEmpty) {
        return false;
      }

      await _productRepository.removeProduct(clientId);
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
  
  Future<void> _markLocalProductAsSynced(
  String clientId,
) async {
  final product = productBox.get(clientId);

  if (product == null) {
    return;
  }

  await productBox.put(
    clientId,
    product.copyWith(
      isSynced: true,
      updatedAt: DateTime.now(),
    ),
  );
}

  Future<void> _pullRemoteUserChanges() async {
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
  
  Future<void> _pullRemoteProductChanges() async {
  final cursor = await SyncMetadata.getProductsCursor();

  final response = await _productRepository.getProductChanges(
    since: cursor,
  );

  final data =
      response['data'] as Map<String, dynamic>;

  final created =
      data['created'] as List<dynamic>? ?? [];

  final updated =
      data['updated'] as List<dynamic>? ?? [];

  final deleted =
      data['deleted'] as List<dynamic>? ?? [];

  for (final item in created) {
    await _saveRemoteProduct(
      Map<String, dynamic>.from(item as Map),
    );
  }

  for (final item in updated) {
    await _saveRemoteProduct(
      Map<String, dynamic>.from(item as Map),
    );
  }

  for (final item in deleted) {
    final deletedData =
        Map<String, dynamic>.from(item as Map);

    final clientId =
        deletedData['clientId']?.toString();

    if (clientId != null && clientId.isNotEmpty) {
      await productBox.delete(clientId);
    }
  }

  final nextCursor =
      response['nextCursor']?.toString();

  if (nextCursor != null && nextCursor.isNotEmpty) {
    await SyncMetadata.saveProductsCursor(nextCursor);
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

  Future<void> _saveRemoteProduct(
  Map<String, dynamic> data,
) async {
  final clientId = data['clientId']?.toString();

  if (clientId == null || clientId.isEmpty) {
    return;
  }

  final existingProduct = productBox.get(clientId);
  final remoteProduct = Product.fromJson(data);

  await productBox.put(
    clientId,
    remoteProduct.copyWith(
      isSynced: true,
      updatedAt: DateTime.now(),
    ),
  );
}

  double _toDouble(dynamic value) {
     if (value is num) {
        return value.toDouble();
      }

    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  int _toInt(dynamic value, {int fallback = 0}) {
     if (value is int) {
         return value;
      }

      if (value is num) {
        return value.toInt();
      }

      return int.tryParse(value?.toString() ?? '') ?? fallback;
    }
}
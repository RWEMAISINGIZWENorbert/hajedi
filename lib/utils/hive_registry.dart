import 'package:hajedi/data/expense.dart';
import 'package:hajedi/data/purchase.dart';
import 'package:hajedi/data/purchase_item.dart';
import 'package:hajedi/data/sale.dart';
import 'package:hajedi/data/sale_item.dart';
import 'package:hajedi/data/sync_queue_item.dart';
import 'package:hajedi/data/user.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hajedi/data/product.dart';

class HiveRegistry {

  static Future init() async {
       await Hive.initFlutter();
       registerAdapters();
       await openAllBoxes();
   }

   static void registerAdapters() {
     Hive.registerAdapter(UserAdapter());
     Hive.registerAdapter(ProductAdapter());
     Hive.registerAdapter(SyncQueueItemAdapter());
     Hive.registerAdapter(SaleItemAdapter());
     Hive.registerAdapter(SaleAdapter());
     Hive.registerAdapter(PurchaseItemAdapter());
     Hive.registerAdapter(PurchaseAdapter());
     Hive.registerAdapter(ExpenseAdapter());
   }

   static Future<void> openAllBoxes() async {
     await Hive.openBox<User>('users');
     await Hive.openBox<Product>('products');
     await Hive.openBox<SyncQueueItem>('syncQueue');
     await Hive.openBox<Sale>('sales');
     await Hive.openBox<Purchase>('purchases');
     await Hive.openBox<Expense>('expenses');
   }

  static Future<void> closeAll() async {
    await Hive.close();
  }

  static Future clearALlBoxes() async {
    await Future.wait([
    Hive.box<User>('users').clear(),
    Hive.box<Product>('products').clear(),
    Hive.box<SyncQueueItem>('syncQueue').clear(),
    Hive.box<Sale>('sales').clear(),
    Hive.box<Purchase>('purchases').clear(),
    Hive.box<Expense>('expenses').clear(),
   ]);
  }
  
  static Future<void> clearQueue() async {
     await Hive.box<SyncQueueItem>('syncQueue').clear();
  }
}
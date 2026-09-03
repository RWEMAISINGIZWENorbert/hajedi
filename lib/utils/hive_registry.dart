
import 'package:hajedi/data/sync_queue_item.dart';
import 'package:hajedi/data/user.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HiveRegistry {

  static Future init() async {
       await Hive.initFlutter();
       registerAdapters();
       await openAllBoxes();
   }

   static void registerAdapters() {
     Hive.registerAdapter(UserAdapter());
     Hive.registerAdapter(SyncQueueItemAdapter());
   }

   static Future<void> openAllBoxes() async {
     await Hive.openBox<User>('users');
     await Hive.openBox<SyncQueueItem>('syncQueue');
   }

   static Future<void> closeAll() async {
    await Hive.close();
  }

  static Future clearALlBoxes() async {
    await Future.wait([
    Hive.box<User>('users').clear(),
    Hive.box<SyncQueueItem>('syncQueue').clear(),
   ]);
  }
  
  static Future<void> clearQueue() async {
     await Hive.box<SyncQueueItem>('syncQueue').clear();
  }
}
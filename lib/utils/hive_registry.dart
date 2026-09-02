
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
   }

   static Future<void> openAllBoxes() async {
     await Hive.openBox<User>('userBox');
   }

   static Future<void> closeAll() async {
    await Hive.close();
  }

  static Future clearALlBoxes() async {
    await Future.wait([
    Hive.box('userBox').clear(),
   ]);
  }

}
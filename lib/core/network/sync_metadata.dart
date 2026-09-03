import 'package:shared_preferences/shared_preferences.dart';

class SyncMetadata {
  static const _usersCursorKey = 'users_sync_cursor';

  static Future<String?> getUsersCursor() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getString(_usersCursorKey);
  }

  static Future<void> saveUsersCursor(String cursor) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_usersCursorKey, cursor);
  }

  static Future<void> clear() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_usersCursorKey);
  }
}
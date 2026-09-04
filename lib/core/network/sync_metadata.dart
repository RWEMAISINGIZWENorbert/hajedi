import 'package:shared_preferences/shared_preferences.dart';

class SyncMetadata {
  static const _usersCursorKey = 'users_sync_cursor';
  static const _productsCursorKey = 'products_sync_cursor';

  static Future<String?> getUsersCursor() async {
    final preferences =
        await SharedPreferences.getInstance();

    return preferences.getString(_usersCursorKey);
  }

  static Future<void> saveUsersCursor(
    String cursor,
  ) async {
    final preferences =
        await SharedPreferences.getInstance();

    await preferences.setString(
      _usersCursorKey,
      cursor,
    );
  }

  static Future<String?> getProductsCursor() async {
    final preferences =
        await SharedPreferences.getInstance();

    return preferences.getString(_productsCursorKey);
  }

  static Future<void> saveProductsCursor(
    String cursor,
  ) async {
    final preferences =
        await SharedPreferences.getInstance();

    await preferences.setString(
      _productsCursorKey,
      cursor,
    );
  }

  static Future<void> clear() async {
    final preferences =
        await SharedPreferences.getInstance();

    await preferences.remove(_usersCursorKey);
    await preferences.remove(_productsCursorKey);
  }
}
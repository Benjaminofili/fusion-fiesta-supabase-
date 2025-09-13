// lib/storage/auth_storage.dart
import 'package:hive/hive.dart';
import 'hive_manager.dart';
import '../models/user_model.dart';

class AuthStorage {
  static const String _currentUserKey = 'current_user';

  static Future<void> persistSession(UserModel user, {String? token}) async {
    if (token != null) user.sessionToken = token;
    user.lastModified = DateTime.now().toUtc();

    final box = Hive.box<UserModel>('users');
    await box.put(user.id, user);

    final metaBox = Hive.box('app_meta');
    await metaBox.put(_currentUserKey, user.id);
  }

  static UserModel? loadSession() {
    final metaBox = Hive.box('app_meta');
    final userId = metaBox.get(_currentUserKey);
    if (userId == null) return null;

    final box = Hive.box<UserModel>('users');
    return box.get(userId);
  }

  static Future<void> clearSession() async {
    final metaBox = Hive.box('app_meta');
    await metaBox.delete(_currentUserKey);
  }
}

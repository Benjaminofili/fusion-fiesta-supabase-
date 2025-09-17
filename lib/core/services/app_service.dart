import '../constants/app_constants.dart';
import '../../storage/hive_manager.dart';
import '../../supabase_manager.dart';

class AppService {
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;

    try {
      print('🔄 Initializing app services...');

      // Initialize Hive (with built-in error handling and data clearing if needed)
      await HiveManager.init();
      print('✅ Hive initialized');

      // Initialize Supabase
      await SupabaseManager.init();
      print('✅ Supabase initialized');

      _initialized = true;
      print('✅ App services initialized successfully');
    } catch (e) {
      print('❌ App initialization failed: $e');
      rethrow;
    }
  }

  static bool get isInitialized => _initialized;
}
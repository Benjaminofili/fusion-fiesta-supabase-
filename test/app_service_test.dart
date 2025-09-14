import 'package:flutter_test/flutter_test.dart';
import 'package:fusion_fiesta/core/services/app_service.dart';
import 'package:fusion_fiesta/storage/hive_manager.dart';
import 'package:fusion_fiesta/supabase_manager.dart';

void main() {
group('AppService Initialization', () {
test('App initializes without errors', () async {
// Act
await AppService.initialize();

// Assert
expect(AppService.isInitialized, true);
expect(HiveManager.init(), true); // Assuming HiveManager has an isInitialized getter
expect(SupabaseManager.client, isNotNull);
});
});
}

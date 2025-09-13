import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseManager {
  static Future<void> init() async {
    await Supabase.initialize(
      url: 'https://qtfedzzccivfbhpnnaqq.supabase.co',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InF0ZmVkenpjY2l2ZmJocG5uYXFxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc2OTY5ODgsImV4cCI6MjA3MzI3Mjk4OH0.2axwPVhRwf5j5ZX8aeX8mu3beLDJ59RR6QTedcsV-9M',
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}

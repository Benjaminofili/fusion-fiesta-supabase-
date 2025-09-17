import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import '../models/bookmark_model.dart';
import '../models/certificate_model.dart';
import '../models/media_gallery_model.dart';
import '../models/notification_model.dart';
import '../models/user_model.dart';
import '../models/event_model.dart';
import '../models/registration_model.dart';
import '../models/feedback_model.dart';

class HiveManager {
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;

    await Hive.initFlutter();

    // FIRST: Register adapters BEFORE opening any boxes
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(UserModelAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(EventModelAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(RegistrationModelAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(FeedbackModelAdapter());
    }
    if (!Hive.isAdapterRegistered(4)) {
      Hive.registerAdapter(CertificateModelAdapter());
    }
    if (!Hive.isAdapterRegistered(5)) {
      Hive.registerAdapter(NotificationModelAdapter());
    }
    if (!Hive.isAdapterRegistered(6)) {
      Hive.registerAdapter(MediaGalleryModelAdapter());
    }
    if (!Hive.isAdapterRegistered(7)) {
      Hive.registerAdapter(BookmarkModelAdapter());
    }

    // SECOND: Open boxes with error handling
    try {
      await Hive.openBox<UserModel>('users');
      await Hive.openBox<EventModel>('events');
      await Hive.openBox<RegistrationModel>('registrations');
      await Hive.openBox<FeedbackModel>('feedback');
      await Hive.openBox<CertificateModel>('certificates');
      await Hive.openBox<NotificationModel>('notifications');
      await Hive.openBox<MediaGalleryModel>('media_gallery');
      await Hive.openBox<BookmarkModel>('bookmarks');
      await Hive.openBox('app_meta');
      await Hive.openBox('offline_queue');
    } catch (e) {
      print('❌ Error opening Hive boxes: $e');

      // If there's a type cast error, clear all data and try again
      if (e.toString().contains('type cast') || e.toString().contains('subtype')) {
        print('🔄 Clearing corrupted Hive data and recreating boxes...');

        try {
          // Close any open boxes first
          await Hive.close();

          // Delete all Hive data
          await Hive.deleteFromDisk();

          // Reinitialize Hive
          await Hive.initFlutter();

          // Re-register adapters
          Hive.registerAdapter(UserModelAdapter());
          Hive.registerAdapter(EventModelAdapter());
          Hive.registerAdapter(RegistrationModelAdapter());
          Hive.registerAdapter(FeedbackModelAdapter());
          Hive.registerAdapter(CertificateModelAdapter());
          Hive.registerAdapter(NotificationModelAdapter());
          Hive.registerAdapter(MediaGalleryModelAdapter());
          Hive.registerAdapter(BookmarkModelAdapter());

          // Open boxes again
          await Hive.openBox<UserModel>('users');
          await Hive.openBox<EventModel>('events');
          await Hive.openBox<RegistrationModel>('registrations');
          await Hive.openBox<FeedbackModel>('feedback');
          await Hive.openBox<CertificateModel>('certificates');
          await Hive.openBox<NotificationModel>('notifications');
          await Hive.openBox<MediaGalleryModel>('media_gallery');
          await Hive.openBox<BookmarkModel>('bookmarks');
          await Hive.openBox('app_meta');
          await Hive.openBox('offline_queue');

          print('✅ Hive data cleared and boxes recreated successfully');
        } catch (clearError) {
          print('❌ Failed to clear and recreate Hive data: $clearError');
          rethrow;
        }
      } else {
        rethrow;
      }
    }

    _initialized = true;
  }

  static Future<void> clearHiveData() async {
    try {
      await Hive.close();
      await Hive.deleteFromDisk();
      _initialized = false;
      print('✅ Hive data cleared successfully');
    } catch (e) {
      print('❌ Error clearing Hive data: $e');
      rethrow;
    }
  }

  // Getters with null safety checks
  static Box<UserModel> get usersBox {
    if (!Hive.isBoxOpen('users')) {
      throw HiveError('Users box is not open. Call HiveManager.init() first.');
    }
    return Hive.box<UserModel>('users');
  }

  static Box<EventModel> get eventsBox {
    if (!Hive.isBoxOpen('events')) {
      throw HiveError('Events box is not open. Call HiveManager.init() first.');
    }
    return Hive.box<EventModel>('events');
  }

  static Box<RegistrationModel> get registrationsBox {
    if (!Hive.isBoxOpen('registrations')) {
      throw HiveError('Registrations box is not open. Call HiveManager.init() first.');
    }
    return Hive.box<RegistrationModel>('registrations');
  }

  static Box<FeedbackModel> get feedbackBox {
    if (!Hive.isBoxOpen('feedback')) {
      throw HiveError('Feedback box is not open. Call HiveManager.init() first.');
    }
    return Hive.box<FeedbackModel>('feedback');
  }

  static Box<NotificationModel> get notificationsBox {
    if (!Hive.isBoxOpen('notifications')) {
      throw HiveError('Notifications box is not open. Call HiveManager.init() first.');
    }
    return Hive.box<NotificationModel>('notifications');
  }

  static Box<CertificateModel> get certificatesBox {
    if (!Hive.isBoxOpen('certificates')) {
      throw HiveError('Certificates box is not open. Call HiveManager.init() first.');
    }
    return Hive.box<CertificateModel>('certificates');
  }

  static Box<MediaGalleryModel> get mediaGalleryBox {
    if (!Hive.isBoxOpen('media_gallery')) {
      throw HiveError('Media gallery box is not open. Call HiveManager.init() first.');
    }
    return Hive.box<MediaGalleryModel>('media_gallery');
  }

  static Box<BookmarkModel> get bookmarksBox {
    if (!Hive.isBoxOpen('bookmarks')) {
      throw HiveError('Bookmarks box is not open. Call HiveManager.init() first.');
    }
    return Hive.box<BookmarkModel>('bookmarks');
  }

  static Box get metaBox {
    if (!Hive.isBoxOpen('app_meta')) {
      throw HiveError('App meta box is not open. Call HiveManager.init() first.');
    }
    return Hive.box('app_meta');
  }

  static Box get offlineBox {
    if (!Hive.isBoxOpen('offline_queue')) {
      throw HiveError('Offline queue box is not open. Call HiveManager.init() first.');
    }
    return Hive.box('offline_queue');
  }
}
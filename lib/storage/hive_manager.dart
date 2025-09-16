import 'package:hive_flutter/hive_flutter.dart';
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

    // Register adapters
    Hive.registerAdapter(UserModelAdapter());
    Hive.registerAdapter(EventModelAdapter());
    Hive.registerAdapter(RegistrationModelAdapter());
    Hive.registerAdapter(FeedbackModelAdapter());
    Hive.registerAdapter(CertificateModelAdapter());
    Hive.registerAdapter(NotificationModelAdapter());
    Hive.registerAdapter(MediaGalleryModelAdapter());
    Hive.registerAdapter(BookmarkModelAdapter());

    // Open boxes
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

    _initialized = true;
  }

  // Getters
  static Box<UserModel> get usersBox => Hive.box<UserModel>('users');
  static Box<EventModel> get eventsBox => Hive.box<EventModel>('events');
  static Box<RegistrationModel> get registrationsBox => Hive.box<RegistrationModel>('registrations');
  static Box<FeedbackModel> get feedbackBox => Hive.box<FeedbackModel>('feedback');
  static Box<NotificationModel> get notificationsBox => Hive.box<NotificationModel>('notifications');
  static Box<CertificateModel> get certificatesBox => Hive.box<CertificateModel>('certificates');
  static Box<MediaGalleryModel> get mediaGalleryBox => Hive.box<MediaGalleryModel>('media_gallery');
  static Box<BookmarkModel> get bookmarksBox => Hive.box<BookmarkModel>('bookmarks');
  static Box get metaBox => Hive.box('app_meta');
  static Box get offlineBox => Hive.box('offline_queue');
}
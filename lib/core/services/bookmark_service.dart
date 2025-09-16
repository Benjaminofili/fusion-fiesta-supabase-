import 'package:uuid/uuid.dart';
import '../../models/bookmark_model.dart';
import '../../storage/hive_manager.dart';
import '../../supabase_manager.dart';
import '../constants/app_constants.dart';
import 'auth_service.dart';
import 'sync_service.dart';
import 'AppError.dart';

class BookmarkService {
  static final _supabase = SupabaseManager.client;

  /// Toggle bookmark status for an event
  static Future<Map<String, dynamic>> toggleBookmark(String eventId) async {
    try {
      final user = EnhancedAuthService.getCurrentUser();
      if (user == null) {
        return {'success': false, 'error': 'User not authenticated'};
      }

      // Check if event is already bookmarked
      final existingBookmark = HiveManager.bookmarksBox.values
          .where((bookmark) => bookmark.eventId == eventId && bookmark.userId == user.id)
          .firstOrNull;

      bool isOnline = await SyncService.checkConnectivityAndSync();

      if (existingBookmark != null) {
        // Remove bookmark
        if (isOnline) {
          await _supabase
              .from('bookmarks')
              .delete()
              .eq('event_id', eventId)
              .eq('user_id', user.id);
        } else {
          await HiveManager.offlineBox.add({
            'type': 'bookmark_deletion',
            'data': {'id': existingBookmark.id},
            'timestamp': DateTime.now().toIso8601String(),
          });
        }

        // Remove from local storage
        await existingBookmark.delete();

        return {'success': true, 'isBookmarked': false, 'message': 'Bookmark removed'};
      } else {
        // Add bookmark
        final bookmark = BookmarkModel(
          id: const Uuid().v4(),
          userId: user.id,
          eventId: eventId,
          createdAt: DateTime.now(),
        );

        if (isOnline) {
          await _supabase.from('bookmarks').insert(bookmark.toMap());
        } else {
          await HiveManager.offlineBox.add({
            'type': 'bookmark_creation',
            'data': bookmark.toMap(),
            'timestamp': DateTime.now().toIso8601String(),
          });
        }

        // Add to local storage
        await HiveManager.bookmarksBox.put(bookmark.id, bookmark);

        return {'success': true, 'isBookmarked': true, 'message': 'Event bookmarked'};
      }
    } catch (e) {
      return {'success': false, 'error': AppError.fromException(e).message};
    }
  }

  /// Get all bookmarked events for a user
  static Future<Map<String, dynamic>> getBookmarkedEvents(String userId) async {
    try {
      List<String> bookmarkedEventIds = [];

      bool isOnline = await SyncService.checkConnectivityAndSync();

      if (isOnline) {
        final response = await _supabase
            .from('bookmarks')
            .select('event_id')
            .eq('user_id', userId);

        bookmarkedEventIds = response
            .map((bookmark) => bookmark['event_id'] as String)
            .toList();

        // Update local bookmarks
        for (final eventId in bookmarkedEventIds) {
          final existingBookmark = HiveManager.bookmarksBox.values
              .where((b) => b.eventId == eventId && b.userId == userId)
              .firstOrNull;

          if (existingBookmark == null) {
            final bookmark = BookmarkModel(
              id: const Uuid().v4(),
              userId: userId,
              eventId: eventId,
              createdAt: DateTime.now(),
            );
            await HiveManager.bookmarksBox.put(bookmark.id, bookmark);
          }
        }
      } else {
        bookmarkedEventIds = HiveManager.bookmarksBox.values
            .where((bookmark) => bookmark.userId == userId)
            .map((bookmark) => bookmark.eventId)
            .toList();
      }

      // Get the actual events
      final bookmarkedEvents = HiveManager.eventsBox.values
          .where((event) => bookmarkedEventIds.contains(event.id))
          .toList();

      return {'success': true, 'events': bookmarkedEvents};
    } catch (e) {
      return {'success': false, 'error': AppError.fromException(e).message};
    }
  }

  /// Check if an event is bookmarked by a user
  static bool isEventBookmarked(String eventId, String userId) {
    return HiveManager.bookmarksBox.values
        .any((bookmark) => bookmark.eventId == eventId && bookmark.userId == userId);
  }

  /// Remove bookmark by bookmark ID
  static Future<Map<String, dynamic>> removeBookmark(String bookmarkId) async {
    try {
      bool isOnline = await SyncService.checkConnectivityAndSync();

      if (isOnline) {
        await _supabase.from('bookmarks').delete().eq('id', bookmarkId);
      } else {
        await HiveManager.offlineBox.add({
          'type': 'bookmark_deletion',
          'data': {'id': bookmarkId},
          'timestamp': DateTime.now().toIso8601String(),
        });
      }

      // Remove from local storage
      final bookmark = HiveManager.bookmarksBox.get(bookmarkId);
      if (bookmark != null) {
        await bookmark.delete();
      }

      return {'success': true, 'message': 'Bookmark removed'};
    } catch (e) {
      return {'success': false, 'error': AppError.fromException(e).message};
    }
  }

  /// Get bookmark count for an event
  static Future<Map<String, dynamic>> getBookmarkCount(String eventId) async {
    try {
      int count = 0;

      bool isOnline = await SyncService.checkConnectivityAndSync();

      if (isOnline) {
        final response = await _supabase
            .from('bookmarks')
            .select('count(*)')
            .eq('event_id', eventId)
            .single();

        count = response['count'] as int? ?? 0;
      } else {
        count = HiveManager.bookmarksBox.values
            .where((bookmark) => bookmark.eventId == eventId)
            .length;
      }

      return {'success': true, 'count': count};
    } catch (e) {
      return {'success': false, 'error': AppError.fromException(e).message};
    }
  }

  /// Sync bookmarks with server
  static Future<Map<String, dynamic>> syncBookmarks(String userId) async {
    try {
      bool isOnline = await SyncService.checkConnectivityAndSync();

      if (!isOnline) {
        return {'success': false, 'error': 'No internet connection'};
      }

      // Fetch bookmarks from server
      final response = await _supabase
          .from('bookmarks')
          .select()
          .eq('user_id', userId);

      final serverBookmarks = response
          .map((data) => BookmarkModel.fromMap(data))
          .toList();

      // Update local storage
      final localBookmarkIds = HiveManager.bookmarksBox.values
          .where((b) => b.userId == userId)
          .map((b) => b.id)
          .toSet();

      final serverBookmarkIds = serverBookmarks.map((b) => b.id).toSet();

      // Remove bookmarks that exist locally but not on server
      for (final localId in localBookmarkIds) {
        if (!serverBookmarkIds.contains(localId)) {
          final bookmark = HiveManager.bookmarksBox.get(localId);
          if (bookmark != null) {
            await bookmark.delete();
          }
        }
      }

      // Add bookmarks that exist on server but not locally
      for (final serverBookmark in serverBookmarks) {
        await HiveManager.bookmarksBox.put(serverBookmark.id, serverBookmark);
      }

      return {'success': true, 'message': 'Bookmarks synced successfully'};
    } catch (e) {
      return {'success': false, 'error': AppError.fromException(e).message};
    }
  }
}
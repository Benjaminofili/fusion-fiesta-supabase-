import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fusion_fiesta/core/theme/app_theme.dart';
import 'package:intl/intl.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _isLoading = true;
  String _selectedFilter = 'All';
  
  // Mock data for notifications
  final List<Map<String, dynamic>> _allNotifications = [
    {
      'id': '1',
      'title': 'New Event: Tech Conference 2023',
      'message': 'A new tech conference has been added that matches your interests.',
      'timestamp': DateTime.now().subtract(const Duration(hours: 2)),
      'isRead': false,
      'type': 'event',
      'actionId': '1', // Event ID
    },
    {
      'id': '2',
      'title': 'Registration Confirmed',
      'message': 'Your registration for Design Workshop has been confirmed.',
      'timestamp': DateTime.now().subtract(const Duration(hours: 5)),
      'isRead': true,
      'type': 'registration',
      'actionId': '2', // Event ID
    },
    {
      'id': '3',
      'title': 'Certificate Issued',
      'message': 'You have been awarded a certificate for Web Development Bootcamp.',
      'timestamp': DateTime.now().subtract(const Duration(days: 1)),
      'isRead': false,
      'type': 'certificate',
      'actionId': '1', // Certificate ID
    },
    {
      'id': '4',
      'title': 'Event Reminder: Hackathon 2023',
      'message': 'Reminder: Hackathon 2023 starts tomorrow at 9:00 AM.',
      'timestamp': DateTime.now().subtract(const Duration(days: 1, hours: 6)),
      'isRead': true,
      'type': 'reminder',
      'actionId': '5', // Event ID
    },
    {
      'id': '5',
      'title': 'New Message from Organizer',
      'message': 'The organizer of Design Workshop has sent you a message.',
      'timestamp': DateTime.now().subtract(const Duration(days: 2)),
      'isRead': false,
      'type': 'message',
      'actionId': '2', // Event ID
    },
    {
      'id': '6',
      'title': 'Event Updated: Cultural Fest',
      'message': 'The details for Cultural Fest have been updated. Tap to view changes.',
      'timestamp': DateTime.now().subtract(const Duration(days: 3)),
      'isRead': true,
      'type': 'update',
      'actionId': '4', // Event ID
    },
    {
      'id': '7',
      'title': 'Feedback Request',
      'message': 'Please provide feedback for the Tech Conference 2023 you attended.',
      'timestamp': DateTime.now().subtract(const Duration(days: 4)),
      'isRead': false,
      'type': 'feedback',
      'actionId': '1', // Event ID
    },
    {
      'id': '8',
      'title': 'Payment Successful',
      'message': 'Your payment for Music Festival tickets has been processed successfully.',
      'timestamp': DateTime.now().subtract(const Duration(days: 5)),
      'isRead': true,
      'type': 'payment',
      'actionId': '7', // Event ID
    },
  ];
  
  final List<String> _filters = [
    'All',
    'Unread',
    'Events',
    'Registrations',
    'Certificates',
    'Messages',
  ];
  
  @override
  void initState() {
    super.initState();
    // Simulate loading delay
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }
  
  List<Map<String, dynamic>> get _filteredNotifications {
    List<Map<String, dynamic>> filteredList = List.from(_allNotifications);
    
    // Apply filter
    if (_selectedFilter != 'All') {
      if (_selectedFilter == 'Unread') {
        filteredList = filteredList.where((notification) => notification['isRead'] == false).toList();
      } else if (_selectedFilter == 'Events') {
        filteredList = filteredList.where((notification) => 
          notification['type'] == 'event' || notification['type'] == 'reminder' || notification['type'] == 'update'
        ).toList();
      } else if (_selectedFilter == 'Registrations') {
        filteredList = filteredList.where((notification) => 
          notification['type'] == 'registration' || notification['type'] == 'payment'
        ).toList();
      } else if (_selectedFilter == 'Certificates') {
        filteredList = filteredList.where((notification) => notification['type'] == 'certificate').toList();
      } else if (_selectedFilter == 'Messages') {
        filteredList = filteredList.where((notification) => 
          notification['type'] == 'message' || notification['type'] == 'feedback'
        ).toList();
      }
    }
    
    // Sort by timestamp (newest first)
    filteredList.sort((a, b) => (b['timestamp'] as DateTime).compareTo(a['timestamp'] as DateTime));
    
    return filteredList;
  }
  
  void _markAsRead(String notificationId) {
    setState(() {
      final index = _allNotifications.indexWhere((notification) => notification['id'] == notificationId);
      if (index != -1) {
        _allNotifications[index]['isRead'] = true;
      }
    });
  }
  
  void _markAllAsRead() {
    setState(() {
      for (var notification in _allNotifications) {
        notification['isRead'] = true;
      }
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('All notifications marked as read'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
  
  void _deleteNotification(String notificationId) {
    setState(() {
      _allNotifications.removeWhere((notification) => notification['id'] == notificationId);
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Notification deleted'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
  
  void _handleNotificationTap(Map<String, dynamic> notification) {
    // Mark as read when tapped
    if (!notification['isRead']) {
      _markAsRead(notification['id']);
    }
    
    // In a real app, this would navigate to the appropriate screen based on the notification type
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Navigating to ${notification['type']} details'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.background,
        elevation: 0,
        title: Text(
          'Notifications',
          style: TextStyle(
            color: theme.colorScheme.onBackground,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: theme.colorScheme.primary,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          // Mark all as read button
          IconButton(
            icon: Icon(
              Icons.done_all,
              color: theme.colorScheme.primary,
            ),
            onPressed: _markAllAsRead,
            tooltip: 'Mark all as read',
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips
          SizedBox(
            height: 50,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              scrollDirection: Axis.horizontal,
              itemCount: _filters.length,
              itemBuilder: (context, index) {
                final filter = _filters[index];
                final isSelected = filter == _selectedFilter;
                
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(filter),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedFilter = filter;
                        });
                      }
                    },
                    backgroundColor: theme.colorScheme.surfaceVariant,
                    selectedColor: theme.colorScheme.primary,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.onSurfaceVariant,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                ).animate()
                  .fade(duration: 600.ms, delay: (100 + (index * 50)).ms)
                  .slideX(begin: 0.1, end: 0, duration: 600.ms);
              },
            ),
          ),
          
          // Notification Count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                Text(
                  '${_filteredNotifications.length} Notifications',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onBackground.withOpacity(0.7),
                  ),
                ),
                const Spacer(),
                if (_selectedFilter == 'All')
                  Text(
                    '${_allNotifications.where((n) => !n['isRead']).length} unread',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
          ).animate()
            .fade(duration: 600.ms, delay: 300.ms),
          
          // Notifications List
          Expanded(
            child: _isLoading
                ? _buildLoadingState(theme)
                : _filteredNotifications.isEmpty
                    ? _buildEmptyState(theme)
                    : ListView.builder(
                        padding: const EdgeInsets.all(16.0),
                        itemCount: _filteredNotifications.length,
                        itemBuilder: (context, index) {
                          final notification = _filteredNotifications[index];
                          return _buildNotificationCard(notification, theme, index);
                        },
                      ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildNotificationCard(Map<String, dynamic> notification, ThemeData theme, int index) {
    final isRead = notification['isRead'] as bool;
    final timestamp = notification['timestamp'] as DateTime;
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    String timeAgo;
    if (difference.inMinutes < 60) {
      timeAgo = '${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      timeAgo = '${difference.inHours} hr ago';
    } else if (difference.inDays < 7) {
      timeAgo = '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else {
      timeAgo = DateFormat('MMM dd').format(timestamp);
    }
    
    // Determine icon based on notification type
    IconData typeIcon;
    Color iconColor;
    
    switch (notification['type']) {
      case 'event':
        typeIcon = Icons.event;
        iconColor = Colors.blue;
        break;
      case 'registration':
        typeIcon = Icons.how_to_reg;
        iconColor = Colors.green;
        break;
      case 'certificate':
        typeIcon = Icons.emoji_events;
        iconColor = Colors.amber;
        break;
      case 'reminder':
        typeIcon = Icons.alarm;
        iconColor = Colors.orange;
        break;
      case 'message':
        typeIcon = Icons.message;
        iconColor = Colors.purple;
        break;
      case 'update':
        typeIcon = Icons.update;
        iconColor = Colors.teal;
        break;
      case 'feedback':
        typeIcon = Icons.feedback;
        iconColor = Colors.indigo;
        break;
      case 'payment':
        typeIcon = Icons.payment;
        iconColor = Colors.deepPurple;
        break;
      default:
        typeIcon = Icons.notifications;
        iconColor = theme.colorScheme.primary;
    }
    
    return Dismissible(
      key: Key(notification['id']),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20.0),
        color: Colors.red,
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        _deleteNotification(notification['id']);
      },
      child: Card(
        elevation: 0,
        color: isRead
            ? theme.colorScheme.surface
            : theme.colorScheme.primaryContainer.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isRead
                ? Colors.transparent
                : theme.colorScheme.primary.withOpacity(0.3),
            width: 1,
          ),
        ),
        margin: const EdgeInsets.only(bottom: 8.0),
        child: InkWell(
          onTap: () => _handleNotificationTap(notification),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Notification Type Icon
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    typeIcon,
                    color: iconColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                
                // Notification Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Title
                          Expanded(
                            child: Text(
                              notification['title'],
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                                color: theme.colorScheme.onBackground,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          
                          // Timestamp
                          Text(
                            timeAgo,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      
                      // Message
                      Text(
                        notification['message'],
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      
                      // Action Button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          OutlinedButton(
                            onPressed: () => _handleNotificationTap(notification),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: theme.colorScheme.primary,
                              side: BorderSide(color: theme.colorScheme.primary),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                              minimumSize: const Size(0, 30),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              _getActionButtonText(notification['type']),
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                          
                          // Mark as read button (only for unread notifications)
                          if (!isRead)
                            IconButton(
                              onPressed: () => _markAsRead(notification['id']),
                              icon: Icon(
                                Icons.check_circle_outline,
                                color: theme.colorScheme.primary,
                                size: 20,
                              ),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              visualDensity: VisualDensity.compact,
                              tooltip: 'Mark as read',
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate()
      .fade(duration: 600.ms, delay: (200 + (index * 50)).ms)
      .slideY(begin: 0.05, end: 0, duration: 600.ms);
  }
  
  String _getActionButtonText(String notificationType) {
    switch (notificationType) {
      case 'event':
        return 'View Event';
      case 'registration':
        return 'View Details';
      case 'certificate':
        return 'View Certificate';
      case 'reminder':
        return 'Set Reminder';
      case 'message':
        return 'Read Message';
      case 'update':
        return 'View Updates';
      case 'feedback':
        return 'Give Feedback';
      case 'payment':
        return 'View Receipt';
      default:
        return 'View';
    }
  }
  
  Widget _buildLoadingState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            'Loading notifications...',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onBackground.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: 80,
            color: theme.colorScheme.primary.withOpacity(0.5),
          ).animate()
            .fade(duration: 600.ms)
            .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1), duration: 600.ms),
          
          const SizedBox(height: 16),
          
          Text(
            'No Notifications',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onBackground,
            ),
          ).animate()
            .fade(duration: 600.ms, delay: 200.ms),
          
          const SizedBox(height: 8),
          
          Text(
            _selectedFilter != 'All'
                ? 'No ${_selectedFilter.toLowerCase()} notifications found'
                : 'You\'re all caught up!',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onBackground.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ).animate()
            .fade(duration: 600.ms, delay: 400.ms),
          
          const SizedBox(height: 24),
          
          if (_selectedFilter != 'All')
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _selectedFilter = 'All';
                });
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Show All Notifications'),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ).animate()
              .fade(duration: 600.ms, delay: 600.ms)
              .slideY(begin: 0.1, end: 0, duration: 600.ms),
        ],
      ),
    );
  }
}
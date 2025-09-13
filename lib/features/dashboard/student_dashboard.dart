import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/event_service.dart';
import '../../core/services/notification_service.dart';
import '../../core/services/certificate_service.dart';
import '../../core/services/auth_service.dart';
import '../../core/theme/app_theme.dart';
import '../../models/event_model.dart';
import '../../models/certificate_model.dart';
import '../../models/notification_model.dart';
import '../../storage/hive_manager.dart';
import '../../supabase_manager.dart';
import 'presentation/bloc/dashboard_bloc.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({Key? key}) : super(key: key);

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 0;
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final user = EnhancedAuthService.getCurrentUser();
    if (user != null) {
      context.read<DashboardBloc>().add(FetchDashboardDataEvent(
        userRole: user.role,
        userId: user.id,
      ));
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _getTimeAgo(DateTime date) {
    final difference = DateTime.now().difference(date);
    if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else {
      return 'Just now';
    }
  }

  Widget _buildProfileContent(ThemeData theme, bool isDarkMode) {
    final user = EnhancedAuthService.getCurrentUser();
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Profile',
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 20),
          Text('Name: ${user?.name ?? 'N/A'}'),
          Text('Email: ${user?.email ?? 'N/A'}'),
          Text('Role: ${user?.role ?? 'N/A'}'),
          Text('Department: ${user?.department ?? 'N/A'}'),
          Text('Enrollment: ${user?.enrollmentNumber ?? 'N/A'}'),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              context.read<DashboardBloc>().add(FetchDashboardDataEvent(
                userRole: user?.role ?? AppConstants.roleParticipant,
                userId: user?.id ?? '',
              ));
            },
            child: const Text('Refresh Profile'),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarContent(List<EventModel> registeredEvents, ThemeData theme, bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Event Calendar',
            style: theme.textTheme.headlineSmall,
          ),
        ),
        if (registeredEvents.isEmpty)
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('No upcoming registered events'),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: registeredEvents.length,
            itemBuilder: (context, index) {
              final event = registeredEvents[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: ListTile(
                  leading: Icon(Icons.calendar_today, color: theme.colorScheme.primary),
                  title: Text(event.title),
                  subtitle: Text('${DateFormat('MMM d, yyyy HH:mm').format(event.dateTime)} - ${event.venue}'),
                ),
              ).animate().fade().slideY();
            },
          ),
      ],
    );
  }

  Widget _buildUpcomingEventsSection(List<EventModel> events, ThemeData theme, bool isDarkMode, String userId) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Upcoming Events',
            style: theme.textTheme.headlineSmall,
          ),
        ),
        if (_isSearching)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search events...',
                prefixIcon: Icon(Icons.search, color: theme.colorScheme.primary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onChanged: (value) {
                setState(() {}); // Trigger rebuild for search
              },
            ),
          ),
        if (events.isEmpty)
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('No upcoming events available'),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              if (_isSearching && !_searchController.text.isEmpty) {
                if (!event.title.toLowerCase().contains(_searchController.text.toLowerCase())) {
                  return const SizedBox.shrink();
                }
              }
              final isRegistered = HiveManager.registrationsBox.values
                  .any((r) => r.eventId == event.id && r.userId == userId && r.status == 'registered');
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: ListTile(
                  leading: event.bannerUrl != null
                      ? Image.network(event.bannerUrl!, width: 60, height: 60, fit: BoxFit.cover, errorBuilder: (_, __, ___) {
                    return Image.asset('assets/images/default_event.jpg', width: 60, height: 60, fit: BoxFit.cover);
                  })
                      : Image.asset('assets/images/default_event.jpg', width: 60, height: 60, fit: BoxFit.cover),
                  title: Text(event.title),
                  subtitle: FutureBuilder<String?>(
                    future: _getOrganizerName(event.organizerId),
                    builder: (context, snapshot) {
                      return Text(
                        '${DateFormat('MMM d, yyyy HH:mm').format(event.dateTime)} - ${event.venue}\nOrganized by: ${snapshot.data ?? 'Loading...'}',
                      );
                    },
                  ),
                  trailing: ElevatedButton(
                    onPressed: isRegistered || event.currentParticipants >= event.maxParticipants
                        ? null
                        : () async {
                      final result = await EventService.registerForEvent(event.id);
                      if (result['success']) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Registered successfully')));
                        context.read<DashboardBloc>().add(FetchDashboardDataEvent(
                          userRole: EnhancedAuthService.getCurrentUser()?.role ?? AppConstants.roleParticipant,
                          userId: userId,
                        ));
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Registration failed: ${result['error']}')));
                      }
                    },
                    child: Text(isRegistered ? 'Registered' : event.currentParticipants >= event.maxParticipants ? 'Full' : 'Register'),
                  ),
                ),
              ).animate().fade().slideY();
            },
          ),
      ],
    );
  }

  Future<String?> _getOrganizerName(String? organizerId) async {
    if (organizerId == null) return 'Unknown';
    try {
      final user = HiveManager.usersBox.get(organizerId);
      if (user != null) return user.name;
      final response = await SupabaseManager.client
          .from('users')
          .select('name')
          .eq('id', organizerId)
          .single();
      return response['name'] as String? ?? 'Unknown';
    } catch (e) {
      return 'Unknown';
    }
  }

  Widget _buildRegisteredEventsSection(List<EventModel> events, ThemeData theme, bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Registered Events',
            style: theme.textTheme.headlineSmall,
          ),
        ),
        if (events.isEmpty)
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('No registered events'),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: ListTile(
                  leading: event.bannerUrl != null
                      ? Image.network(event.bannerUrl!, width: 60, height: 60, fit: BoxFit.cover, errorBuilder: (_, __, ___) {
                    return Image.asset('assets/images/default_event.jpg', width: 60, height: 60, fit: BoxFit.cover);
                  })
                      : Image.asset('assets/images/default_event.jpg', width: 60, height: 60, fit: BoxFit.cover),
                  title: Text(event.title),
                  subtitle: Text('${DateFormat('MMM d, yyyy HH:mm').format(event.dateTime)} - ${event.venue}'),
                ),
              ).animate().fade().slideY();
            },
          ),
      ],
    );
  }

  Widget _buildPastEventsSection(List<EventModel> events, ThemeData theme, bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Past Events',
            style: theme.textTheme.headlineSmall,
          ),
        ),
        if (events.isEmpty)
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('No past events'),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: ListTile(
                  leading: event.bannerUrl != null
                      ? Image.network(event.bannerUrl!, width: 60, height: 60, fit: BoxFit.cover, errorBuilder: (_, __, ___) {
                    return Image.asset('assets/images/default_event.jpg', width: 60, height: 60, fit: BoxFit.cover);
                  })
                      : Image.asset('assets/images/default_event.jpg', width: 60, height: 60, fit: BoxFit.cover),
                  title: Text(event.title),
                  subtitle: Text('${DateFormat('MMM d, yyyy HH:mm').format(event.dateTime)} - ${event.venue}'),
                  trailing: const Icon(Icons.check_circle, color: Colors.green),
                ),
              ).animate().fade().slideY();
            },
          ),
      ],
    );
  }

  Widget _buildCertificatesSection(List<CertificateModel> certificates, ThemeData theme, bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Certificates',
            style: theme.textTheme.headlineSmall,
          ),
        ),
        if (certificates.isEmpty)
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('No certificates available'),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: certificates.length,
            itemBuilder: (context, index) {
              final certificate = certificates[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: ListTile(
                  leading: const Icon(Icons.card_giftcard, color: Colors.blue),
                  title: FutureBuilder<String?>(
                    future: certificate.getEventTitle(),
                    builder: (context, snapshot) {
                      return Text(snapshot.data ?? 'Event ${certificate.eventId}');
                    },
                  ),
                  subtitle: Text('Issued: ${DateFormat('MMM d, yyyy').format(certificate.issuedAt)}'),
                  trailing: IconButton(
                    icon: certificate.downloadedAt != null
                        ? const Icon(Icons.download_done, color: Colors.green)
                        : const Icon(Icons.download),
                    onPressed: certificate.downloadedAt != null
                        ? null
                        : () async {
                      final url = Uri.parse(certificate.certificateUrl);
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url);
                        final result = await CertificateService.markCertificateDownloaded(certificate.id);
                        if (result['success']) {
                          setState(() {}); // Refresh UI
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Failed to mark as downloaded: ${result['error']}')),
                          );
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Cannot open certificate URL')),
                        );
                      }
                    },
                  ),
                ),
              ).animate().fade().slideY();
            },
          ),
      ],
    );
  }

  Widget _buildNotificationsSection(List<NotificationModel> notifications, ThemeData theme, bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Notifications',
            style: theme.textTheme.headlineSmall,
          ),
        ),
        if (notifications.isEmpty)
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('No notifications'),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: ListTile(
                  leading: Icon(
                    notification.type == 'success'
                        ? Icons.check_circle
                        : notification.type == 'warning'
                        ? Icons.warning
                        : notification.type == 'error'
                        ? Icons.error
                        : Icons.info,
                    color: notification.type == 'success'
                        ? Colors.green
                        : notification.type == 'warning'
                        ? Colors.orange
                        : notification.type == 'error'
                        ? Colors.red
                        : Colors.blue,
                  ),
                  title: Text(notification.title),
                  subtitle: Text('${notification.message} - ${_getTimeAgo(notification.createdAt)}'),
                  trailing: notification.isRead
                      ? const Icon(Icons.check, color: Colors.green)
                      : IconButton(
                    icon: const Icon(Icons.mark_email_read),
                    onPressed: () async {
                      final result = await NotificationService.markAsRead(notification.id);
                      if (result['success']) {
                        context.read<DashboardBloc>().add(FetchDashboardDataEvent(
                          userRole: EnhancedAuthService.getCurrentUser()?.role ?? AppConstants.roleParticipant,
                          userId: EnhancedAuthService.getCurrentUser()?.id ?? '',
                        ));
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed to mark as read: ${result['error']}')),
                        );
                      }
                    },
                  ),
                ),
              ).animate().fade().slideY();
            },
          ),
      ],
    );
  }

  Widget _buildBottomNavigationBar(ThemeData theme, bool isDarkMode) {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (index) => setState(() => _selectedIndex = index),
      selectedItemColor: theme.colorScheme.primary,
      unselectedItemColor: theme.colorScheme.onBackground.withOpacity(0.7),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Calendar'),
        BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Notifications'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isDarkMode = theme.brightness == Brightness.dark;
    final user = EnhancedAuthService.getCurrentUser();

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(_selectedIndex == 0
            ? 'Student Dashboard'
            : _selectedIndex == 1
            ? 'Event Calendar'
            : _selectedIndex == 2
            ? 'Notifications'
            : 'Profile'),
        actions: [
          if (_selectedIndex == 0)
            IconButton(
              icon: Icon(_isSearching ? Icons.close : Icons.search),
              onPressed: () {
                setState(() {
                  _isSearching = !_isSearching;
                  if (!_isSearching) _searchController.clear();
                });
              },
            ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              EnhancedAuthService.logout();
              Navigator.pushReplacementNamed(context, AppConstants.loginRoute);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          if (user != null) {
            context.read<DashboardBloc>().add(FetchDashboardDataEvent(
              userRole: user.role,
              userId: user.id,
            ));
          }
        },
        child: BlocBuilder<DashboardBloc, DashboardState>(
          builder: (context, state) {
            if (state is DashboardLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is DashboardError) {
              return Center(child: Text('Error: ${state.message}'));
            } else if (state is DashboardLoaded) {
              final List<EventModel> upcomingEvents = state.dashboardData['upcomingEvents'] ?? [];
              final List<EventModel> registeredEvents = state.dashboardData['registeredEvents'] ?? [];
              final List<EventModel> pastEvents = registeredEvents.where((e) => e.dateTime.isBefore(DateTime.now())).toList();
              final List<CertificateModel> certificates = state.dashboardData['certificates'] ?? [];
              final List<NotificationModel> notifications = state.dashboardData['notifications'] ?? [];

              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_selectedIndex == 0) ...[
                      _buildUpcomingEventsSection(upcomingEvents, theme, isDarkMode, user?.id ?? ''),
                      _buildRegisteredEventsSection(registeredEvents, theme, isDarkMode),
                      _buildPastEventsSection(pastEvents, theme, isDarkMode),
                      _buildCertificatesSection(certificates, theme, isDarkMode),
                    ],
                    if (_selectedIndex == 1) _buildCalendarContent(registeredEvents, theme, isDarkMode),
                    if (_selectedIndex == 2) _buildNotificationsSection(notifications, theme, isDarkMode),
                    if (_selectedIndex == 3) _buildProfileContent(theme, isDarkMode),
                  ],
                ),
              );
            }
            return const Center(child: Text('No data available'));
          },
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(theme, isDarkMode),
    );
  }
}
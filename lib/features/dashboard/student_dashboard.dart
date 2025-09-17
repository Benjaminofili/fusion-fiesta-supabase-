import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/AppError.dart';
import '../../core/services/sync_service.dart';
import '../../core/services/event_service.dart';
import '../../core/services/notification_service.dart';
import '../../core/services/certificate_service.dart';
import '../../core/services/bookmark_service.dart'; // Added bookmark service
import '../../core/services/auth_service.dart';
import '../../models/event_model.dart';
import '../../models/certificate_model.dart';
import '../../models/notification_model.dart';
import '../../models/user_model.dart';
import '../../storage/hive_manager.dart';
import '../../supabase_manager.dart';
import 'presentation/bloc/dashboard_bloc.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({Key? key}) : super(key: key);

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 0;
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this); // Updated to 5 tabs
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
      }
    });

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
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        // Reset to show all events
        final user = EnhancedAuthService.getCurrentUser();
        if (user != null) {
          context.read<DashboardBloc>().add(FetchDashboardDataEvent(
            userRole: user.role,
            userId: user.id,
          ));
        }
      }
    });
  }

  void _openDrawer() {
    _scaffoldKey.currentState?.openDrawer();
  }

  void _navigateToEventDetails(EventModel event) {
    Navigator.pushNamed(context, AppConstants.eventDetailsRoute, arguments: event);
  }

  void _navigateToProfile() {
    Navigator.pushNamed(context, AppConstants.profileRoute);
  }

  void _navigateToNotifications() {
    Navigator.pushNamed(context, AppConstants.notificationsRoute);
  }

  Future<void> _registerForEvent(String eventId) async {
    final result = await EventService.registerForEvent(eventId);
    if (result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Registered successfully'),
          backgroundColor: Theme.of(context).colorScheme.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Refresh data
      final user = EnhancedAuthService.getCurrentUser();
      if (user != null) {
        context.read<DashboardBloc>().add(FetchDashboardDataEvent(
          userRole: user.role,
          userId: user.id,
        ));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Registration failed: ${result['error']}'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _toggleBookmark(String eventId) async {
    final result = await BookmarkService.toggleBookmark(eventId);
    if (result['success']) {
      final message = result['message'] as String;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Theme.of(context).colorScheme.primary,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );

      // Refresh data to update bookmark status
      final user = EnhancedAuthService.getCurrentUser();
      if (user != null) {
        context.read<DashboardBloc>().add(FetchDashboardDataEvent(
          userRole: user.role,
          userId: user.id,
        ));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update bookmark: ${result['error']}'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _downloadCertificate(String certificateId) async {
    try {
      // Check connectivity
      bool isOnline = await SyncService.checkConnectivityAndSync();

      String? certificateUrl;
      if (isOnline) {
        // Fetch certificate from Supabase
        final response = await SupabaseManager.client
            .from('certificates')
            .select('certificate_url')
            .eq('id', certificateId)
            .single();

        certificateUrl = response['certificate_url'] as String?;
        if (certificateUrl == null) {
          throw Exception('Certificate URL not found');
        }

        // Update local storage
        final certificate = HiveManager.certificatesBox.get(certificateId);
        if (certificate != null) {
          HiveManager.certificatesBox.put(certificateId, certificate);
        }
      } else {
        // Fetch from Hive
        final certificate = HiveManager.certificatesBox.get(certificateId);
        if (certificate == null) {
          throw Exception('Certificate not available offline');
        }
        certificateUrl = certificate.certificateUrl;
      }

      // Request storage permission
      var status = await Permission.storage.request();
      if (!status.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Storage permission denied')),
        );
        return;
      }

      // Download the file
      final response = await http.get(Uri.parse(certificateUrl));
      if (response.statusCode != 200) {
        throw Exception('Failed to download certificate');
      }

      // Save to temporary directory
      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/certificate_$certificateId.pdf';
      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);

      // Mark as downloaded
      await CertificateService.markCertificateDownloaded(certificateId);

      // Open the file
      final result = await OpenFile.open(filePath);
      if (result.type != ResultType.done) {
        throw Exception('Failed to open certificate: ${result.message}');
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Certificate downloaded and opened: $filePath')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to download certificate: ${AppError.fromException(e).message}')),
      );
    }
  }

  Future<void> _showSearchDialog(BuildContext context) async {
    String query = '';
    String? category;
    DateTime? startDate;
    DateTime? endDate;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Search Events'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Event Title',
                    hintText: 'Enter event title...',
                  ),
                  onChanged: (value) => query = value,
                ),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: ['general', 'academic', 'cultural', 'sports']
                      .map((c) => DropdownMenuItem(value: c, child: Text(c.capitalize())))
                      .toList(),
                  onChanged: (value) => category = value,
                ),
                TextButton(
                  onPressed: () async {
                    final picked = await showDateRangePicker(
                      context: context,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) {
                      startDate = picked.start;
                      endDate = picked.end;
                    }
                  },
                  child: const Text('Select Date Range'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                context.read<DashboardBloc>().add(SearchEventsEvent(
                  query: query,
                  category: category,
                  startDate: startDate,
                  endDate: endDate,
                ));
                Navigator.pop(context);
              },
              child: const Text('Search'),
            ),
          ],
        );
      },
    );
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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final user = EnhancedAuthService.getCurrentUser();

    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {
        // Extract data from state
        List<EventModel> upcomingEvents = [];
        List<EventModel> registeredEvents = [];
        List<EventModel> bookmarkedEvents = [];
        List<CertificateModel> certificates = [];
        List<NotificationModel> notifications = [];

        if (state is DashboardLoaded) {
          upcomingEvents = state.dashboardData['upcomingEvents'] ?? [];
          registeredEvents = state.dashboardData['registeredEvents'] ?? [];
          bookmarkedEvents = state.dashboardData['bookmarkedEvents'] ?? [];
          certificates = state.dashboardData['certificates'] ?? [];
          notifications = state.dashboardData['notifications'] ?? [];
        }

        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: _buildAppBar(theme, isDarkMode),
          drawer: _buildDrawer(theme, isDarkMode, user),
          body: state is DashboardLoading
              ? const Center(child: CircularProgressIndicator())
              : state is DashboardError
              ? Center(child: Text('Error: ${state.message}'))
              : _selectedIndex == 0
              ? _buildHomeContent(theme, isDarkMode, size, upcomingEvents, registeredEvents, certificates, user?.id ?? '')
              : _selectedIndex == 1
              ? _buildBookmarksContent(theme, isDarkMode, bookmarkedEvents)
              : _selectedIndex == 2
              ? _buildNotificationsContent(theme, isDarkMode, notifications)
              : _buildProfileContent(theme, isDarkMode),
          bottomNavigationBar: _buildBottomNavigationBar(theme, isDarkMode),
          floatingActionButton: _selectedIndex == 0
              ? FloatingActionButton(
            onPressed: () => _showSearchDialog(context),
            backgroundColor: theme.colorScheme.primary,
            child: const Icon(Icons.search),
          )
              : null,
        );
      },
    );
  }


  PreferredSizeWidget _buildAppBar(ThemeData theme, bool isDarkMode) {
    final user = EnhancedAuthService.getCurrentUser(); // Fetch current user

    return AppBar(
      systemOverlayStyle: isDarkMode ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      backgroundColor: theme.appBarTheme.backgroundColor,
      elevation: 0,
      title: _isSearching
          ? TextField(
        controller: _searchController,
        autofocus: true,
        decoration: InputDecoration(
          hintText: 'Search events...',
          hintStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6)),
          border: InputBorder.none,
        ),
        style: theme.textTheme.titleMedium,
        onChanged: (value) {
          if (value.isNotEmpty) {
            context.read<DashboardBloc>().add(SearchEventsEvent(query: value));
          } else {
            final user = EnhancedAuthService.getCurrentUser();
            if (user != null) {
              context.read<DashboardBloc>().add(FetchDashboardDataEvent(
                userRole: user.role,
                userId: user.id,
              ));
            }
          }
        },
      )
          : Text(
        'FusionFiesta',
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.onBackground,
        ),
      ),
      leading: IconButton(
        icon: Icon(
          Icons.menu,
          color: theme.colorScheme.onBackground,
        ),
        onPressed: _openDrawer,
      ),
      actions: [
        IconButton(
          icon: Icon(
            _isSearching ? Icons.close : Icons.search,
            color: theme.colorScheme.onBackground,
          ),
          onPressed: _toggleSearch,
        ),
        IconButton(
          icon: Badge(
            label: const Text('0'),
            isLabelVisible: false,
            child: Icon(
              Icons.notifications_outlined,
              color: theme.colorScheme.onBackground,
            ),
          ),
          onPressed: _navigateToNotifications,
        ),
        IconButton(
          icon: CircleAvatar(
            radius: 14,
            backgroundImage: user?.profilePictureUrl != null
                ? CachedNetworkImageProvider(user!.profilePictureUrl!)
                : const AssetImage('assets/images/profile.jpg') as ImageProvider,
            onBackgroundImageError: user?.profilePictureUrl != null
                ? (error, stackTrace) {
              print('Failed to load profile picture: $error');
            }
                : null,
          ),
          onPressed: _navigateToProfile,
        ),
      ],
    );
  }

  Widget _buildDrawer(ThemeData theme, bool isDarkMode, dynamic user) {
    return Drawer(
      backgroundColor: theme.scaffoldBackgroundColor,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.secondary,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundImage: AssetImage('assets/images/profile.jpg'),
                ),
                const SizedBox(height: 10),
                Text(
                  user?.name ?? 'User Name',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${user?.department ?? 'Department'}, Year 3',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          _buildDrawerItem(
            icon: Icons.home_outlined,
            title: 'Home',
            onTap: () {
              Navigator.pop(context);
              _onItemTapped(0);
            },
            theme: theme,
          ),
          _buildDrawerItem(
            icon: Icons.bookmark_outlined,
            title: 'Bookmarks',
            onTap: () {
              Navigator.pop(context);
              _onItemTapped(1);
            },
            theme: theme,
          ),
          _buildDrawerItem(
            icon: Icons.event_outlined,
            title: 'My Events',
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppConstants.myEventsRoute);
            },
            theme: theme,
          ),
          _buildDrawerItem(
            icon: Icons.card_membership_outlined,
            title: 'Certificates',
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppConstants.certificatesRoute);
            },
            theme: theme,
          ),
          _buildDrawerItem(
            icon: Icons.photo_library_outlined,
            title: 'Gallery',
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppConstants.galleryRoute);
            },
            theme: theme,
          ),
          const Divider(),
          _buildDrawerItem(
            icon: Icons.settings_outlined,
            title: 'Settings',
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppConstants.settingsRoute);
            },
            theme: theme,
          ),
          _buildDrawerItem(
            icon: Icons.help_outline,
            title: 'Help & Support',
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppConstants.helpRoute);
            },
            theme: theme,
          ),
          _buildDrawerItem(
            icon: Icons.info_outline,
            title: 'About',
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppConstants.aboutRoute);
            },
            theme: theme,
          ),
          const Divider(),
          _buildDrawerItem(
            icon: Icons.logout,
            title: 'Logout',
            onTap: () {
              EnhancedAuthService.logout();
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, AppConstants.loginRoute);
            },
            theme: theme,
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required ThemeData theme,
  }) {
    return ListTile(
      leading: Icon(icon, color: theme.colorScheme.primary),
      title: Text(
        title,
        style: theme.textTheme.bodyLarge,
      ),
      onTap: onTap,
    );
  }

  Widget _buildHomeContent(ThemeData theme, bool isDarkMode, Size size,
      List<EventModel> upcomingEvents, List<EventModel> registeredEvents,
      List<CertificateModel> certificates, String userId) {

    // Filter events based on search
    final filteredUpcomingEvents = _isSearching && _searchController.text.isNotEmpty
        ? upcomingEvents.where((event) =>
        event.title.toLowerCase().contains(_searchController.text.toLowerCase()))
        : upcomingEvents;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            // Welcome message
            Text(
              'Hello, ${EnhancedAuthService.getCurrentUser()?.name ?? 'User'}!',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onBackground,
              ),
            ).animate()
                .fade(duration: 500.ms)
                .slideX(begin: -0.1, end: 0, duration: 500.ms, curve: Curves.easeOutQuad),

            Text(
              'Discover exciting events happening around you',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onBackground.withOpacity(0.7),
              ),
            ).animate()
                .fade(duration: 500.ms, delay: 200.ms)
                .slideX(begin: -0.1, end: 0, duration: 500.ms, curve: Curves.easeOutQuad),

            const SizedBox(height: 30),

            // Event categories
            Text(
              'Categories',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onBackground,
              ),
            ).animate()
                .fade(duration: 500.ms, delay: 300.ms),

            const SizedBox(height: 16),

            SizedBox(
              height: 100,
              child: ListView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildCategoryCard(
                    icon: Icons.computer,
                    title: 'Technical',
                    color: const Color(0xFF4CAF50),
                    theme: theme,
                    isDarkMode: isDarkMode,
                  ),
                  _buildCategoryCard(
                    icon: Icons.music_note,
                    title: 'Cultural',
                    color: const Color(0xFFF44336),
                    theme: theme,
                    isDarkMode: isDarkMode,
                  ),
                  _buildCategoryCard(
                    icon: Icons.sports_basketball,
                    title: 'Sports',
                    color: const Color(0xFF2196F3),
                    theme: theme,
                    isDarkMode: isDarkMode,
                  ),
                  _buildCategoryCard(
                    icon: Icons.school,
                    title: 'Academic',
                    color: const Color(0xFF9C27B0),
                    theme: theme,
                    isDarkMode: isDarkMode,
                  ),
                  _buildCategoryCard(
                    icon: Icons.business_center,
                    title: 'Workshop',
                    color: const Color(0xFFFF9800),
                    theme: theme,
                    isDarkMode: isDarkMode,
                  ),
                ],
              ),
            ).animate()
                .fade(duration: 500.ms, delay: 400.ms)
                .slideX(begin: 0.1, end: 0, duration: 500.ms, curve: Curves.easeOutQuad),

            const SizedBox(height: 30),

            // Upcoming events
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Upcoming Events',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onBackground,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // TODO: Navigate to all events
                  },
                  child: Text(
                    'See All',
                    style: TextStyle(color: theme.colorScheme.primary),
                  ),
                ),
              ],
            ).animate()
                .fade(duration: 500.ms, delay: 500.ms),

            const SizedBox(height: 16),

            SizedBox(
              height: 320, // Increased height to accommodate bookmark button
              child: filteredUpcomingEvents.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.event_busy,
                      size: 50,
                      color: theme.colorScheme.onBackground.withOpacity(0.3),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'No upcoming events',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              )
                  : ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: filteredUpcomingEvents.length,
                itemBuilder: (context, index) {
                  final event = filteredUpcomingEvents.elementAt(index);
                  final isRegistered = HiveManager.registrationsBox.values
                      .any((r) => r.eventId == event.id && r.userId == userId && r.status == 'registered');
                  final isBookmarked = BookmarkService.isEventBookmarked(event.id, userId);

                  return _buildEnhancedEventCard(
                    event: event,
                    theme: theme,
                    isDarkMode: isDarkMode,
                    index: index,
                    isRegistered: isRegistered,
                    isBookmarked: isBookmarked,
                    onRegister: () => _registerForEvent(event.id),
                    onBookmark: () => _toggleBookmark(event.id),
                  );
                },
              ),
            ).animate()
                .fade(duration: 500.ms, delay: 600.ms),

            const SizedBox(height: 30),

            // Registered events
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Your Registered Events',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onBackground,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // TODO: Navigate to registered events
                  },
                  child: Text(
                    'See All',
                    style: TextStyle(color: theme.colorScheme.primary),
                  ),
                ),
              ],
            ).animate()
                .fade(duration: 500.ms, delay: 700.ms),

            const SizedBox(height: 16),

            registeredEvents.isEmpty
                ? Center(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Icon(
                    Icons.event_busy,
                    size: 80,
                    color: theme.colorScheme.onBackground.withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No registered events',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onBackground.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Explore and register for events',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onBackground.withOpacity(0.5),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () => _onItemTapped(0), // Go to home tab
                    icon: const Icon(Icons.explore),
                    label: const Text('Explore Events'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                ],
              ),
            )
                : ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: registeredEvents.length,
              itemBuilder: (context, index) {
                final event = registeredEvents[index];
                final isBookmarked = BookmarkService.isEventBookmarked(event.id, userId);
                return _buildRegisteredEventCard(
                  event: event,
                  theme: theme,
                  isDarkMode: isDarkMode,
                  index: index,
                  isBookmarked: isBookmarked,
                  onBookmark: () => _toggleBookmark(event.id),
                );
              },
            ).animate()
                .fade(duration: 500.ms, delay: 800.ms),

            const SizedBox(height: 20),
            // Certificates section
            _buildCertificatesSection(theme).animate()
                .fade(duration: 500.ms, delay: 900.ms),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildBookmarksContent(ThemeData theme, bool isDarkMode, List<EventModel> bookmarkedEvents) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.bookmark,
                  color: theme.colorScheme.primary,
                  size: 28,
                ),
                const SizedBox(width: 8),
                Text(
                  'Bookmarked Events',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Events you\'ve saved for later',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onBackground.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 24),
            bookmarkedEvents.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 60),
                  Icon(
                    Icons.bookmark_border,
                    size: 80,
                    color: theme.colorScheme.onBackground.withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No bookmarked events',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onBackground.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start bookmarking events you\'re interested in',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onBackground.withOpacity(0.5),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () => _onItemTapped(0), // Go to home tab
                    icon: const Icon(Icons.explore),
                    label: const Text('Explore Events'),
                  ),
                ],
              ),
            )
                : GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: bookmarkedEvents.length,
              itemBuilder: (context, index) {
                final event = bookmarkedEvents[index];
                final user = EnhancedAuthService.getCurrentUser();
                final isRegistered = user != null ? HiveManager.registrationsBox.values
                    .any((r) => r.eventId == event.id && r.userId == user.id && r.status == 'registered') : false;

                return _buildBookmarkCard(
                  event: event,
                  theme: theme,
                  isDarkMode: isDarkMode,
                  index: index,
                  isRegistered: isRegistered,
                  onRegister: () => _registerForEvent(event.id),
                  onRemoveBookmark: () => _toggleBookmark(event.id),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCertificatesSection(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'My Certificates',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  // Navigate to full certificates page
                },
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Show recent certificates or empty state
          _buildCertificatePreview(theme),
        ],
      ),
    );
  }

  Widget _buildCertificatePreview(ThemeData theme) {
    // If no certificates
    return Card(
      elevation: 0,
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(
              Icons.workspace_premium,
              size: 40,
              color: theme.colorScheme.primary.withOpacity(0.7),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'No certificates yet',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Complete events to earn certificates',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCertificatesContent(ThemeData theme, bool isDarkMode, List<CertificateModel> certificates) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.card_membership,
                  color: theme.colorScheme.primary,
                  size: 28,
                ),
                const SizedBox(width: 8),
                Text(
                  'Your Certificates',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Download and manage your event certificates',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onBackground.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 24),
            certificates.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 60),
                  Icon(
                    Icons.card_membership_outlined,
                    size: 80,
                    color: theme.colorScheme.onBackground.withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No certificates available',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onBackground.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Complete events to earn certificates',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onBackground.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            )
                : ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: certificates.length,
              itemBuilder: (context, index) {
                final certificate = certificates[index];
                return _buildCertificateCard(
                  certificate: certificate,
                  theme: theme,
                  isDarkMode: isDarkMode,
                  index: index,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCertificateCard({
    required CertificateModel certificate,
    required ThemeData theme,
    required bool isDarkMode,
    required int index,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDarkMode ? theme.colorScheme.surface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.card_membership,
            color: theme.colorScheme.primary,
            size: 24,
          ),
        ),
        title: Text(
          certificate.eventTitle ?? 'Certificate ${certificate.id}',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('Issued: ${DateFormat('MMM d, yyyy').format(certificate.issuedAt)}'),
            if (certificate.downloadedAt != null)
              Text(
                'Downloaded: ${DateFormat('MMM d, yyyy').format(certificate.downloadedAt!)}',
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.download),
              onPressed: () => _downloadCertificate(certificate.id),
              tooltip: 'Download Certificate',
            ),
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: () {
                // TODO: Implement share functionality
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Share functionality coming soon')),
                );
              },
              tooltip: 'Share Certificate',
            ),
          ],
        ),
        onTap: () {
          Navigator.pushNamed(context, '/certificate', arguments: certificate);
        },
      ),
    ).animate()
        .fade(duration: 500.ms, delay: 100.ms * index)
        .slideY(begin: 0.1, end: 0, duration: 500.ms, curve: Curves.easeOutQuad);
  }

  Widget _buildCategoryCard({
    required IconData icon,
    required String title,
    required Color color,
    required ThemeData theme,
    required bool isDarkMode,
  }) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: isDarkMode ? theme.colorScheme.surface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 30),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedEventCard({
    required EventModel event,
    required ThemeData theme,
    required bool isDarkMode,
    required int index,
    required bool isRegistered,
    required bool isBookmarked,
    required VoidCallback onRegister,
    required VoidCallback onBookmark,
  }) {
    final formattedDate = DateFormat('MMM dd, yyyy').format(event.dateTime);

    return GestureDetector(
      onTap: () => _navigateToEventDetails(event),
      child: Container(
        width: 240,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: isDarkMode ? theme.colorScheme.surface : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event image with bookmark button
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  child: event.bannerUrl != null
                      ? Image.network(
                    event.bannerUrl!,
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Image.asset(
                      'assets/images/default_event.jpg',
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  )
                      : Image.asset(
                    'assets/images/default_event.jpg',
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: onBookmark, // Fixed: changed from onRemoveBookmark to onBookmark
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Icon(
                        // Changed icon based on bookmark status
                        isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                        color: isBookmarked ? theme.colorScheme.primary : Colors.grey[600],
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16), // Increased padding for better spacing
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Event title
                    Text(
                      event.title,
                      style: theme.textTheme.titleMedium?.copyWith( // Changed from titleSmall
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 8),

                    // Event date
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 16, // Slightly larger icon
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            formattedDate,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onBackground.withOpacity(0.7),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    // Event location
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 16, // Slightly larger icon
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            event.venue,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onBackground.withOpacity(0.7),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                    const Spacer(),

                    // Register button
                    SizedBox(
                      width: double.infinity,
                      child: isRegistered
                          ? OutlinedButton(
                        onPressed: null,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: theme.colorScheme.primary,
                          side: BorderSide(color: theme.colorScheme.primary),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                        ),
                        child: const Text('Registered'),
                      )
                          : ElevatedButton(
                        onPressed: onRegister,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: theme.colorScheme.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                        ),
                        child: const Text('Register'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate()
        .fade(duration: 500.ms, delay: 100.ms * index)
        .slideY(begin: 0.1, end: 0, duration: 500.ms, curve: Curves.easeOutQuad);
  }

  Widget _buildRegisteredEventCard({
    required EventModel event,
    required ThemeData theme,
    required bool isDarkMode,
    required int index,
    required bool isBookmarked,
    required VoidCallback onBookmark,
  }) {
    final formattedDate = DateFormat('MMM dd, yyyy').format(event.dateTime);

    return GestureDetector(
      onTap: () => _navigateToEventDetails(event),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: isDarkMode ? theme.colorScheme.surface : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            // Event image
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
              child: event.bannerUrl != null
                  ? Image.network(
                event.bannerUrl!,
                height: 100,
                width: 100,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Image.asset(
                  'assets/images/default_event.jpg',
                  height: 100,
                  width: 100,
                  fit: BoxFit.cover,
                ),
              )
                  : Image.asset(
                'assets/images/default_event.jpg',
                height: 100,
                width: 100,
                fit: BoxFit.cover,
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Event title
                    Text(
                      event.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 8),

                    // Event date
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          formattedDate,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onBackground.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    // Event location
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 16,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            event.venue,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onBackground.withOpacity(0.7),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            Column(
              children: [
                // Bookmark button
                GestureDetector(
                  onTap: onBookmark,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: Icon(
                      isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                      color: isBookmarked ? theme.colorScheme.primary : Colors.grey[600],
                      size: 24,
                    ),
                  ),
                ),
                // Registered badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Registered',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
          ],
        ),
      ),
    ).animate()
        .fade(duration: 500.ms, delay: 100.ms * index)
        .slideX(begin: 0.1, end: 0, duration: 500.ms, curve: Curves.easeOutQuad);
  }

  Widget _buildBookmarkCard({
    required EventModel event,
    required ThemeData theme,
    required bool isDarkMode,
    required int index,
    required bool isRegistered,
    required VoidCallback onRegister,
    required VoidCallback onRemoveBookmark,
  }) {
    final formattedDate = DateFormat('MMM dd, yyyy').format(event.dateTime);

    return GestureDetector(
      onTap: () => _navigateToEventDetails(event),
      child: Container(
        decoration: BoxDecoration(
          color: isDarkMode ? theme.colorScheme.surface : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event image with remove bookmark button
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  child: event.bannerUrl != null
                      ? Image.network(
                    event.bannerUrl!,
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Image.asset(
                      'assets/images/default_event.jpg',
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  )
                      : Image.asset(
                    'assets/images/default_event.jpg',
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: onRemoveBookmark,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.bookmark_remove,
                        color: Colors.red[600],
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Event title
                    Text(
                      event.title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 8),

                    // Event date
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 14,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            formattedDate,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onBackground.withOpacity(0.7),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    // Event location
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 14,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            event.venue,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onBackground.withOpacity(0.7),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                    const Spacer(),

                    // Register button
                    SizedBox(
                      width: double.infinity,
                      child: isRegistered
                          ? Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: theme.colorScheme.primary),
                        ),
                        child: Text(
                          'Registered',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                          : ElevatedButton(
                        onPressed: onRegister,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: theme.colorScheme.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                        child: Text(
                          'Register',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate()
        .fade(duration: 500.ms, delay: 100.ms * index)
        .scale(begin: const Offset(0.8, 0.8), end: const Offset(1.0, 1.0),
        duration: 500.ms, curve: Curves.easeOutQuad);
  }

  // Complete the registered events section that was cut off
  Widget _buildRegisteredEventsSection(ThemeData theme, bool isDarkMode,
      List<EventModel> registeredEvents, String userId) {
    return registeredEvents.isEmpty
        ? Center(
      child: Column(
        children: [
          const SizedBox(height: 20),
          Icon(
            Icons.event_busy,
            size: 80,
            color: theme.colorScheme.onBackground.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No registered events',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onBackground.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Explore and register for events',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onBackground.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => _onItemTapped(0), // Go to home tab
            icon: const Icon(Icons.explore),
            label: const Text('Explore Events'),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ],
      ),
    )
        : ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: registeredEvents.length,
      itemBuilder: (context, index) {
        final event = registeredEvents[index];
        final isBookmarked = BookmarkService.isEventBookmarked(event.id, userId);
        return _buildRegisteredEventCard(
          event: event,
          theme: theme,
          isDarkMode: isDarkMode,
          index: index,
          isBookmarked: isBookmarked,
          onBookmark: () => _toggleBookmark(event.id),
        );
      },
    ).animate()
        .fade(duration: 500.ms, delay: 800.ms);
  }

  Widget _buildCalendarContent(ThemeData theme, bool isDarkMode, List<EventModel> registeredEvents) {
    // TODO: Implement calendar view
    return Center(
      child: Text(
        'Calendar View Coming Soon',
        style: theme.textTheme.headlineSmall,
      ),
    );
  }

  Widget _buildNotificationsContent(ThemeData theme, bool isDarkMode, List<NotificationModel> notifications) {
    return notifications.isEmpty
        ? Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: 80,
            color: theme.colorScheme.onBackground.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No notifications',
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.onBackground.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You\'re all caught up!',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onBackground.withOpacity(0.5),
            ),
          ),
        ],
      ),
    )
        : ListView.builder(
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final notification = notifications[index];
        return _buildNotificationCard(
          notification: notification,
          theme: theme,
          isDarkMode: isDarkMode,
          index: index,
        );
      },
    );
  }

  Widget _buildNotificationCard({
    required NotificationModel notification,
    required ThemeData theme,
    required bool isDarkMode,
    required int index,
  }) {
    final timeAgo = _getTimeAgo(notification.createdAt);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: notification.isRead
            ? (isDarkMode ? theme.colorScheme.surface : Colors.white)
            : theme.colorScheme.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
          child: Icon(
            _getNotificationIcon(notification.title),
            color: theme.colorScheme.primary,
          ),
        ),
        title: Text(
          notification.title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              notification.message,
              style: theme.textTheme.bodyMedium,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              timeAgo,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onBackground.withOpacity(0.5),
              ),
            ),
          ],
        ),
        trailing: notification.isRead
            ? null
            : Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary,
            shape: BoxShape.circle,
          ),
        ),
        onTap: () async {
          final result = await NotificationService.markAsRead(notification.id);
          if (result['success']) {
            // Refresh data
            final user = EnhancedAuthService.getCurrentUser();
            if (user != null) {
              context.read<DashboardBloc>().add(FetchDashboardDataEvent(
                userRole: user.role,
                userId: user.id,
              ));
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to mark as read: ${result['error']}')),
            );
          }
        },
      ),
    ).animate()
        .fade(duration: 500.ms, delay: 100.ms * index)
        .slideY(begin: 0.1, end: 0, duration: 500.ms, curve: Curves.easeOutQuad);
  }

  IconData _getNotificationIcon(String title) {
    if (title.contains('Registration')) {
      return Icons.how_to_reg;
    } else if (title.contains('Reminder')) {
      return Icons.access_time;
    } else if (title.contains('Certificate')) {
      return Icons.card_membership;
    } else if (title.contains('Announced')) {
      return Icons.campaign;
    } else {
      return Icons.notifications;
    }
  }
  // Profile picture upload functionality
  Future<void> _uploadProfilePicture() async {
    try {
      final picker = FilePicker.platform;
      final result = await picker.pickFiles(type: FileType.image);
      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final uploadResult = await EnhancedAuthService.uploadProfilePicture(file);
        if (uploadResult['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile picture updated successfully'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
          // Refresh profile
          final user = EnhancedAuthService.getCurrentUser();
          if (user != null) {
            context.read<DashboardBloc>().add(FetchDashboardDataEvent(
              userRole: user.role,
              userId: user.id,
            ));
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to update profile picture: ${uploadResult['error']}'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error uploading profile picture: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }


  Future<void> _showProfilePictureOptions() async {
    final user = EnhancedAuthService.getCurrentUser();
    if (user == null) return;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final theme = Theme.of(context);
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Profile Picture',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: Icon(
                  Icons.photo_library,
                  color: theme.colorScheme.primary,
                ),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _uploadProfilePicture();
                },
              ),
              if (user.profilePictureUrl != null)
                ListTile(
                  leading: Icon(
                    Icons.delete,
                    color: Colors.red[600],
                  ),
                  title: const Text('Remove Photo'),
                  onTap: () {
                    Navigator.pop(context);
                    _removeProfilePicture();
                  },
                ),
              ListTile(
                leading: Icon(
                  Icons.cancel,
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
                title: const Text('Cancel'),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _removeProfilePicture() async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Removing profile picture...'),
            ],
          ),
        ),
      );

      final result = await EnhancedAuthService.updateProfilePicture('');

      Navigator.pop(context);

      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Profile picture removed successfully'),
            backgroundColor: Theme.of(context).colorScheme.primary,
            behavior: SnackBarBehavior.floating,
          ),
        );

        setState(() {});

        final user = EnhancedAuthService.getCurrentUser();
        if (user != null) {
          context.read<DashboardBloc>().add(FetchDashboardDataEvent(
            userRole: user.role,
            userId: user.id,
          ));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to remove profile picture: ${result['error']}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Widget _buildProfileContent(ThemeData theme, bool isDarkMode) {
    final user = EnhancedAuthService.getCurrentUser(); // Fetch user dynamically

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: user?.profilePictureUrl != null
                  ? NetworkImage(user!.profilePictureUrl!)
                  : const AssetImage('assets/images/profile.jpg') as ImageProvider,
              onBackgroundImageError: user?.profilePictureUrl != null
                  ? (error, stackTrace) {
                print('Failed to load profile picture: $error');
              }
                  : null,
            ),
            const SizedBox(height: 20),
            Text(
              user?.name ?? 'User Name',
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 10),
            Text(
              user?.email ?? 'user@example.com',
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 5),
            Text(
              '${user?.department ?? 'Department'} • ${user?.enrollmentNumber ?? 'Enrollment Number'}',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    final currentUser = EnhancedAuthService.getCurrentUser();
                    if (currentUser != null) {
                      context.read<DashboardBloc>().add(FetchDashboardDataEvent(
                        userRole: currentUser.role,
                        userId: currentUser.id,
                      ));
                    }
                  },
                  child: const Text('Refresh Profile'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _uploadProfilePicture,
                  child: const Text('Update Profile Picture'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }


Widget _buildBottomNavigationBar(ThemeData theme, bool isDarkMode) {
  return Container(
    decoration: BoxDecoration(
      color: isDarkMode ? theme.colorScheme.surface : Colors.white,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, -5),
        ),
      ],
    ),
    child: SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildNavBarItem(
              icon: Icons.home_outlined,
              activeIcon: Icons.home,
              label: 'Home',
              index: 0,
              theme: theme,
            ),
            _buildNavBarItem(
              icon: Icons.bookmark_outlined,
              activeIcon: Icons.bookmark,
              label: 'Bookmarks',
              index: 1,
              theme: theme,
            ),
            _buildNavBarItem(
              icon: Icons.notifications_outlined,
              activeIcon: Icons.notifications,
              label: 'Notifications',
              index: 2,
              theme: theme,
            ),
            _buildNavBarItem(
              icon: Icons.person_outline,
              activeIcon: Icons.person,
              label: 'Profile',
              index: 3,
              theme: theme,
            ),
          ],
        ),
      ),
    ),
  );
}

  Widget _buildNavBarItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
    required ThemeData theme,
  }) {
    final isSelected = _selectedIndex == index; // ✅ now recognized

    return InkWell(
      onTap: () => _onItemTapped(index), // ✅ now recognized
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onBackground.withOpacity(0.7),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onBackground.withOpacity(0.7),
                fontWeight:
                isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }


}
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}

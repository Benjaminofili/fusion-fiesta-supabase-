import 'dart:io';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:http/http.dart' as http;
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
import '../../core/services/auth_service.dart';
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
  late TabController _tabController;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 0;
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
      }
    });

    // Fetch data on init
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
        const SnackBar(content: Text('Registered successfully')),
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
        SnackBar(content: Text('Registration failed: ${result['error']}')),
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
        List<CertificateModel> certificates = [];
        List<NotificationModel> notifications = [];

        if (state is DashboardLoaded) {
          upcomingEvents = state.dashboardData['upcomingEvents'] ?? [];
          registeredEvents = state.dashboardData['registeredEvents'] ?? [];
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
              ? _buildCertificatesContent(theme, isDarkMode, certificates)
              : _selectedIndex == 2
              ? _buildCalendarContent(theme, isDarkMode, registeredEvents)
              : _selectedIndex == 2
              ? _buildNotificationsContent(theme, isDarkMode, notifications)
              : _buildProfileContent(theme, isDarkMode, user),
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
        onSubmitted: (value) {
          // TODO: Implement search functionality
          _toggleSearch();
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
            label: const Text('0'), // You can update this with actual notification count
            isLabelVisible: false,
            child: Icon(
              Icons.notifications_outlined,
              color: theme.colorScheme.onBackground,
            ),
          ),
          onPressed: _navigateToNotifications,
        ),
        IconButton(
          icon: const CircleAvatar(
            radius: 14,
            backgroundImage: AssetImage('assets/images/profile.jpg'),
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
              height: 280,
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
                  return _buildEventCard(
                    event: event,
                    theme: theme,
                    isDarkMode: isDarkMode,
                    index: index,
                    isRegistered: isRegistered,
                    onRegister: () => _registerForEvent(event.id),
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
                ],
              ),
            )
                : ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: registeredEvents.length,
              itemBuilder: (context, index) {
                final event = registeredEvents[index];
                return _buildRegisteredEventCard(
                  event: event,
                  theme: theme,
                  isDarkMode: isDarkMode,
                  index: index,
                );
              },
            ).animate()
                .fade(duration: 500.ms, delay: 800.ms),

            const SizedBox(height: 30),
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
            Text(
              'Your Certificates',
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            certificates.isEmpty
                ? const Center(child: Text('No certificates available'))
                : ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: certificates.length,
              itemBuilder: (context, index) {
                final certificate = certificates[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: ListTile(
                    leading: const Icon(Icons.card_membership),
                    title: Text(certificate.eventTitle ?? 'Certificate ${certificate.id}'),
                    subtitle: Text('Issued: ${DateFormat('MMM d, yyyy').format(certificate.issuedAt)}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.download),
                      onPressed: () => _downloadCertificate(certificate.id),
                    ),
                    onTap: () {
                      Navigator.pushNamed(context, '/certificate', arguments: certificate);
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
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

  Widget _buildEventCard({
    required EventModel event,
    required ThemeData theme,
    required bool isDarkMode,
    required int index,
    required bool isRegistered,
    required VoidCallback onRegister,
  }) {
    final formattedDate = DateFormat('MMM dd, yyyy').format(event.dateTime);

    return GestureDetector(
      onTap: () => _navigateToEventDetails(event),
      child: Container(
        width: 220,
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
            // Event image
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

            Padding(
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

                  const SizedBox(height: 16),

                  // Register button
                  isRegistered
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
                ],
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

            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
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
            ),
          ],
        ),
      ),
    ).animate()
        .fade(duration: 500.ms, delay: 100.ms * index)
        .slideX(begin: 0.1, end: 0, duration: 500.ms, curve: Curves.easeOutQuad);
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

  Widget _buildProfileContent(ThemeData theme, bool isDarkMode, dynamic user) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage('assets/images/profile.jpg'),
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
            ElevatedButton(
              onPressed: () {
                // Refresh data
                final user = EnhancedAuthService.getCurrentUser();
                if (user != null) {
                  context.read<DashboardBloc>().add(FetchDashboardDataEvent(
                    userRole: user.role,
                    userId: user.id,
                  ));
                }
              },
              child: const Text('Refresh Profile'),
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
                icon: Icons.calendar_today_outlined,
                activeIcon: Icons.calendar_today,
                label: 'Calendar',
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
    final isSelected = _selectedIndex == index;

    return InkWell(
      onTap: () => _onItemTapped(index),
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onBackground.withOpacity(0.7),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onBackground.withOpacity(0.7),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
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
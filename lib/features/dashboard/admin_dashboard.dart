import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
// import 'package:percent_indicator/circular_percent_indicator.dart';

import '../../core/constants/app_constants.dart';
// import '../../core/theme/app_theme.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 0;
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  late TabController _tabController;

  // Mock data for pending approvals
  final List<Map<String, dynamic>> _pendingApprovals = [
    {
      'id': '1',
      'title': 'Hackathon 2023',
      'organizer': 'Jane Smith',
      'date': DateTime.now().add(const Duration(days: 7)),
      'location': 'Computer Lab',
      'image': 'assets/images/hackathon.jpg',
      'description':
          '24-hour coding competition to solve real-world problems with innovative solutions.',
      'requestDate': DateTime.now().subtract(const Duration(days: 2)),
    },
    {
      'id': '2',
      'title': 'Cultural Fest',
      'organizer': 'John Doe',
      'date': DateTime.now().add(const Duration(days: 15)),
      'location': 'College Grounds',
      'image': 'assets/images/cultural_fest.jpg',
      'description':
          'Annual cultural festival featuring music, dance, and art performances from students.',
      'requestDate': DateTime.now().subtract(const Duration(days: 1)),
    },
    {
      'id': '3',
      'title': 'Career Fair',
      'organizer': 'Career Services',
      'date': DateTime.now().add(const Duration(days: 10)),
      'location': 'Main Hall',
      'image': 'assets/images/career_fair.jpg',
      'description':
          'Connect with top employers and explore career opportunities across various industries.',
      'requestDate': DateTime.now().subtract(const Duration(hours: 12)),
    },
  ];

  // Mock data for all events
  final List<Map<String, dynamic>> _allEvents = [
    {
      'id': '1',
      'title': 'Annual Tech Symposium',
      'organizer': 'Jane Smith',
      'date': DateTime.now().add(const Duration(days: 5)),
      'location': 'Main Auditorium',
      'image': 'assets/images/tech_symposium.jpg',
      'status': 'Approved',
      'registrations': 120,
      'capacity': 200,
    },
    {
      'id': '2',
      'title': 'Workshop on AI & ML',
      'organizer': 'Jane Smith',
      'date': DateTime.now().add(const Duration(days: 3)),
      'location': 'Seminar Hall B',
      'image': 'assets/images/ai_workshop.jpg',
      'status': 'Approved',
      'registrations': 45,
      'capacity': 50,
    },
    {
      'id': '3',
      'title': 'Hackathon 2023',
      'organizer': 'Jane Smith',
      'date': DateTime.now().add(const Duration(days: 7)),
      'location': 'Computer Lab',
      'image': 'assets/images/hackathon.jpg',
      'status': 'Pending',
      'registrations': 0,
      'capacity': 100,
    },
    {
      'id': '4',
      'title': 'Photography Workshop',
      'organizer': 'John Doe',
      'date': DateTime.now().subtract(const Duration(days: 30)),
      'location': 'Art Gallery',
      'image': 'assets/images/photography.jpg',
      'status': 'Completed',
      'registrations': 35,
      'capacity': 40,
      'attendees': 32,
      'feedback': 4.7,
    },
    {
      'id': '5',
      'title': 'Cultural Fest',
      'organizer': 'John Doe',
      'date': DateTime.now().add(const Duration(days: 15)),
      'location': 'College Grounds',
      'image': 'assets/images/cultural_fest.jpg',
      'status': 'Pending',
      'registrations': 0,
      'capacity': 500,
    },
    {
      'id': '6',
      'title': 'Career Fair',
      'organizer': 'Career Services',
      'date': DateTime.now().add(const Duration(days: 10)),
      'location': 'Main Hall',
      'image': 'assets/images/career_fair.jpg',
      'status': 'Pending',
      'registrations': 0,
      'capacity': 300,
    },
  ];

  // Mock data for users
  final List<Map<String, dynamic>> _users = [
    {
      'id': '1',
      'name': 'Jane Smith',
      'email': 'jane.smith@example.com',
      'role': 'Organizer',
      'image': 'assets/images/profile.jpg',
      'eventsOrganized': 3,
      'status': 'Active',
      'joinDate': DateTime.now().subtract(const Duration(days: 180)),
    },
    {
      'id': '2',
      'name': 'John Doe',
      'email': 'john.doe@example.com',
      'role': 'Organizer',
      'image': 'assets/images/profile2.jpg',
      'eventsOrganized': 2,
      'status': 'Active',
      'joinDate': DateTime.now().subtract(const Duration(days: 120)),
    },
    {
      'id': '3',
      'name': 'Alice Johnson',
      'email': 'alice.johnson@example.com',
      'role': 'Student',
      'image': 'assets/images/profile3.jpg',
      'eventsAttended': 5,
      'status': 'Active',
      'joinDate': DateTime.now().subtract(const Duration(days: 90)),
    },
    {
      'id': '4',
      'name': 'Bob Williams',
      'email': 'bob.williams@example.com',
      'role': 'Student',
      'image': 'assets/images/profile4.jpg',
      'eventsAttended': 3,
      'status': 'Inactive',
      'joinDate': DateTime.now().subtract(const Duration(days: 150)),
    },
    {
      'id': '5',
      'name': 'Career Services',
      'email': 'career.services@example.com',
      'role': 'Organizer',
      'image': 'assets/images/profile5.jpg',
      'eventsOrganized': 1,
      'status': 'Active',
      'joinDate': DateTime.now().subtract(const Duration(days: 60)),
    },
  ];

  // Mock data for notifications
  final List<Map<String, dynamic>> _notifications = [
    {
      'id': '1',
      'title': 'New Event Request',
      'message': 'Jane Smith has requested approval for "Hackathon 2023".',
      'time': DateTime.now().subtract(const Duration(days: 2)),
      'isRead': false,
    },
    {
      'id': '2',
      'title': 'New Event Request',
      'message': 'John Doe has requested approval for "Cultural Fest".',
      'time': DateTime.now().subtract(const Duration(days: 1)),
      'isRead': false,
    },
    {
      'id': '3',
      'title': 'New Event Request',
      'message': 'Career Services has requested approval for "Career Fair".',
      'time': DateTime.now().subtract(const Duration(hours: 12)),
      'isRead': false,
    },
    {
      'id': '4',
      'title': 'User Report',
      'message': 'Monthly user activity report is now available.',
      'time': DateTime.now().subtract(const Duration(days: 3)),
      'isRead': true,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
      }
    });
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

  void _navigateToEventDetails(Map<String, dynamic> event) {
    Navigator.pushNamed(context, AppConstants.eventDetailsRoute,
        arguments: event);
  }

  void _navigateToUserDetails(Map<String, dynamic> user) {
    Navigator.pushNamed(context, AppConstants.userDetailsRoute,
        arguments: user);
  }

  void _navigateToProfile() {
    Navigator.pushNamed(context, AppConstants.profileRoute);
  }

  void _navigateToNotifications() {
    Navigator.pushNamed(context, AppConstants.notificationsRoute);
  }

  void _approveEvent(String eventId) {
    setState(() {
      final eventIndex =
          _pendingApprovals.indexWhere((event) => event['id'] == eventId);
      if (eventIndex != -1) {
  _pendingApprovals.removeAt(eventIndex);

        final allEventIndex = _allEvents.indexWhere((e) => e['id'] == eventId);
        if (allEventIndex != -1) {
          _allEvents[allEventIndex]['status'] = 'Approved';
        }
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Event approved successfully')),
    );
  }

  void _rejectEvent(String eventId) {
    setState(() {
      final eventIndex =
          _pendingApprovals.indexWhere((event) => event['id'] == eventId);
      if (eventIndex != -1) {
  _pendingApprovals.removeAt(eventIndex);

        final allEventIndex = _allEvents.indexWhere((e) => e['id'] == eventId);
        if (allEventIndex != -1) {
          _allEvents[allEventIndex]['status'] = 'Rejected';
        }
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Event rejected')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: _buildAppBar(theme, isDarkMode),
      drawer: _buildDrawer(theme, isDarkMode),
      body: _selectedIndex == 0
          ? _buildHomeContent(theme, isDarkMode, size)
          : _selectedIndex == 1
              ? _buildEventsContent(theme, isDarkMode)
              : _selectedIndex == 2
                  ? _buildUsersContent(theme, isDarkMode)
                  : _buildReportsContent(theme, isDarkMode),
      bottomNavigationBar: _buildBottomNavigationBar(theme, isDarkMode),
    );
  }

  PreferredSizeWidget _buildAppBar(ThemeData theme, bool isDarkMode) {
    return AppBar(
      systemOverlayStyle:
          isDarkMode ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      backgroundColor: theme.appBarTheme.backgroundColor,
      elevation: 0,
      title: _isSearching
          ? TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Search...',
                hintStyle: TextStyle(
                    color: theme.colorScheme.onSurface.withOpacity(0.6)),
                border: InputBorder.none,
              ),
              style: theme.textTheme.titleMedium,
              onSubmitted: (value) {
                // TODO: Implement search functionality
                _toggleSearch();
              },
            )
          : Text(
              'Admin Dashboard',
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
            label: Text(
                _notifications.where((n) => !n['isRead']).length.toString()),
            isLabelVisible: _notifications.any((n) => !n['isRead']),
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
            backgroundImage:
                const AssetImage('assets/images/admin_profile.jpg'),
          ),
          onPressed: _navigateToProfile,
        ),
      ],
    );
  }

  Widget _buildDrawer(ThemeData theme, bool isDarkMode) {
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
                CircleAvatar(
                  radius: 30,
                  backgroundImage:
                      const AssetImage('assets/images/admin_profile.jpg'),
                ),
                const SizedBox(height: 10),
                Text(
                  'Admin User',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'System Administrator',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          _buildDrawerItem(
            icon: Icons.dashboard_outlined,
            title: 'Dashboard',
            onTap: () {
              Navigator.pop(context);
              _onItemTapped(0);
            },
            theme: theme,
          ),
          _buildDrawerItem(
            icon: Icons.event_outlined,
            title: 'Events Management',
            onTap: () {
              Navigator.pop(context);
              _onItemTapped(1);
            },
            theme: theme,
          ),
          _buildDrawerItem(
            icon: Icons.people_outline,
            title: 'User Management',
            onTap: () {
              Navigator.pop(context);
              _onItemTapped(2);
            },
            theme: theme,
          ),
          _buildDrawerItem(
            icon: Icons.analytics_outlined,
            title: 'Reports & Analytics',
            onTap: () {
              Navigator.pop(context);
              _onItemTapped(3);
            },
            theme: theme,
          ),
          _buildDrawerItem(
            icon: Icons.photo_library_outlined,
            title: 'Media Gallery',
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppConstants.mediaGalleryRoute);
            },
            theme: theme,
          ),
          _buildDrawerItem(
            icon: Icons.feedback_outlined,
            title: 'Feedback Management',
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(
                  context, AppConstants.feedbackManagementRoute);
            },
            theme: theme,
          ),
          const Divider(),
          _buildDrawerItem(
            icon: Icons.settings_outlined,
            title: 'System Settings',
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppConstants.systemSettingsRoute);
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
          const Divider(),
          _buildDrawerItem(
            icon: Icons.logout,
            title: 'Logout',
            onTap: () {
              // TODO: Implement logout logic
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

  Widget _buildHomeContent(ThemeData theme, bool isDarkMode, Size size) {
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
              'Welcome, Admin!',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onBackground,
              ),
            ).animate().fade(duration: 500.ms).slideX(
                begin: -0.1,
                end: 0,
                duration: 500.ms,
                curve: Curves.easeOutQuad),

            Text(
              'Manage events, users, and system settings',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onBackground.withOpacity(0.7),
              ),
            ).animate().fade(duration: 500.ms, delay: 200.ms).slideX(
                begin: -0.1,
                end: 0,
                duration: 500.ms,
                curve: Curves.easeOutQuad),

            const SizedBox(height: 30),

            // Stats cards
            _buildStatsSection(theme, isDarkMode),

            const SizedBox(height: 30),

            // Pending approvals
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Pending Approvals',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onBackground,
                  ),
                ),
                TextButton(
                  onPressed: () => _onItemTapped(1),
                  child: Text(
                    'See All',
                    style: TextStyle(color: theme.colorScheme.primary),
                  ),
                ),
              ],
            ).animate().fade(duration: 500.ms, delay: 500.ms),

            const SizedBox(height: 16),

            _pendingApprovals.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 30),
                      child: Column(
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            size: 60,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No pending approvals',
                            style: theme.textTheme.titleMedium,
                          ),
                        ],
                      ),
                    ),
                  ).animate().fade(duration: 500.ms, delay: 600.ms)
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _pendingApprovals.length,
                    itemBuilder: (context, index) {
                      final approval = _pendingApprovals[index];
                      return _buildApprovalCard(
                        approval: approval,
                        theme: theme,
                        isDarkMode: isDarkMode,
                        index: index,
                      );
                    },
                  ).animate().fade(duration: 500.ms, delay: 600.ms),

            const SizedBox(height: 30),

            // Recent users
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Users',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onBackground,
                  ),
                ),
                TextButton(
                  onPressed: () => _onItemTapped(2),
                  child: Text(
                    'See All',
                    style: TextStyle(color: theme.colorScheme.primary),
                  ),
                ),
              ],
            ).animate().fade(duration: 500.ms, delay: 700.ms),

            const SizedBox(height: 16),

            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: _users.length,
                itemBuilder: (context, index) {
                  final user = _users[index];
                  return _buildUserAvatar(
                    user: user,
                    theme: theme,
                    isDarkMode: isDarkMode,
                    index: index,
                  );
                },
              ),
            ).animate().fade(duration: 500.ms, delay: 800.ms),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection(ThemeData theme, bool isDarkMode) {
    final approvedCount =
        _allEvents.where((e) => e['status'] == 'Approved').length;
    final pendingCount =
        _allEvents.where((e) => e['status'] == 'Pending').length;
    final completedCount =
        _allEvents.where((e) => e['status'] == 'Completed').length;
    final userCount = _users.length;

    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildStatCard(
          title: 'Total Users',
          value: userCount.toString(),
          icon: Icons.people,
          color: const Color(0xFF4CAF50),
          theme: theme,
          isDarkMode: isDarkMode,
          index: 0,
        ),
        _buildStatCard(
          title: 'Pending Approvals',
          value: pendingCount.toString(),
          icon: Icons.pending_actions,
          color: const Color(0xFFFFC107),
          theme: theme,
          isDarkMode: isDarkMode,
          index: 1,
        ),
        _buildStatCard(
          title: 'Approved Events',
          value: approvedCount.toString(),
          icon: Icons.event_available,
          color: const Color(0xFF2196F3),
          theme: theme,
          isDarkMode: isDarkMode,
          index: 2,
        ),
        _buildStatCard(
          title: 'Completed Events',
          value: completedCount.toString(),
          icon: Icons.check_circle,
          color: const Color(0xFF9C27B0),
          theme: theme,
          isDarkMode: isDarkMode,
          index: 3,
        ),
      ],
    ).animate().fade(duration: 500.ms, delay: 300.ms).scale(
        begin: const Offset(0.95, 0.95),
        end: const Offset(1, 1),
        duration: 500.ms,
        curve: Curves.easeOutBack);
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required ThemeData theme,
    required bool isDarkMode,
    required int index,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              Text(
                value,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    ).animate().fade(duration: 500.ms, delay: 100.ms * index).slideY(
        begin: 0.1, end: 0, duration: 500.ms, curve: Curves.easeOutQuad);
  }

  Widget _buildApprovalCard({
    required Map<String, dynamic> approval,
    required ThemeData theme,
    required bool isDarkMode,
    required int index,
  }) {
    final formattedDate = DateFormat('MMM dd, yyyy').format(approval['date']);
    final formattedRequestDate =
        DateFormat('MMM dd, yyyy').format(approval['requestDate']);

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Event image and title
          Row(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
                child: Image.asset(
                  approval['image'],
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
                      Text(
                        approval['title'],
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.person,
                            size: 16,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'By: ${approval['organizer']}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onBackground
                                  .withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 16,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Event Date: $formattedDate',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onBackground
                                  .withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 16,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Requested: $formattedRequestDate',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onBackground
                                  .withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Event description
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              approval['description'],
              style: theme.textTheme.bodyMedium,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Action buttons
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _navigateToEventDetails(approval),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: theme.colorScheme.primary,
                      side: BorderSide(color: theme.colorScheme.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text('View Details'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _approveEvent(approval['id']),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text('Approve'),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => _rejectEvent(approval['id']),
                  icon: const Icon(Icons.close),
                  color: theme.colorScheme.error,
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fade(duration: 500.ms, delay: 100.ms * index).slideY(
        begin: 0.1, end: 0, duration: 500.ms, curve: Curves.easeOutQuad);
  }

  Widget _buildUserAvatar({
    required Map<String, dynamic> user,
    required ThemeData theme,
    required bool isDarkMode,
    required int index,
  }) {
    return GestureDetector(
      onTap: () => _navigateToUserDetails(user),
      child: Container(
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: AssetImage(user['image']),
                ),
                if (user['status'] == 'Active')
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 15,
                      height: 15,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDarkMode
                              ? theme.colorScheme.surface
                              : Colors.white,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              user['name'].split(' ')[0],
              style: theme.textTheme.bodyMedium,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              user['role'],
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onBackground.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    ).animate().fade(duration: 500.ms, delay: 100.ms * index).slideY(
        begin: 0.1, end: 0, duration: 500.ms, curve: Curves.easeOutQuad);
  }

  Widget _buildEventsContent(ThemeData theme, bool isDarkMode) {
    return Column(
      children: [
        // Tab bar
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: isDarkMode ? theme.colorScheme.surface : Colors.grey[200],
            borderRadius: BorderRadius.circular(30),
          ),
          child: TabBar(
            controller: _tabController,
            indicator: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(30),
            ),
            labelColor: Colors.white,
            unselectedLabelColor: theme.colorScheme.onBackground,
            tabs: const [
              Tab(text: 'All Events'),
              Tab(text: 'Pending'),
              Tab(text: 'Approved'),
            ],
          ),
        ),

        // Tab content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              // All events
              _buildEventsList(
                events: _allEvents,
                theme: theme,
                isDarkMode: isDarkMode,
                emptyMessage: 'No events found',
              ),

              // Pending events
              _buildEventsList(
                events:
                    _allEvents.where((e) => e['status'] == 'Pending').toList(),
                theme: theme,
                isDarkMode: isDarkMode,
                emptyMessage: 'No pending events',
              ),

              // Approved events
              _buildEventsList(
                events:
                    _allEvents.where((e) => e['status'] == 'Approved').toList(),
                theme: theme,
                isDarkMode: isDarkMode,
                emptyMessage: 'No approved events',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEventsList({
    required List<Map<String, dynamic>> events,
    required ThemeData theme,
    required bool isDarkMode,
    required String emptyMessage,
  }) {
    return events.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.event_busy,
                  size: 80,
                  color: theme.colorScheme.onBackground.withOpacity(0.3),
                ),
                const SizedBox(height: 16),
                Text(
                  emptyMessage,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.onBackground.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              return _buildEventListItem(
                event: event,
                theme: theme,
                isDarkMode: isDarkMode,
                index: index,
              );
            },
          );
  }

  Widget _buildEventListItem({
    required Map<String, dynamic> event,
    required ThemeData theme,
    required bool isDarkMode,
    required int index,
  }) {
    final formattedDate = DateFormat('MMM dd, yyyy').format(event['date']);

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
              child: Image.asset(
                event['image'],
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
                      event['title'],
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 8),

                    // Organizer
                    Row(
                      children: [
                        Icon(
                          Icons.person,
                          size: 16,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'By: ${event['organizer']}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color:
                                theme.colorScheme.onBackground.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 4),

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
                            color:
                                theme.colorScheme.onBackground.withOpacity(0.7),
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
                            event['location'],
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onBackground
                                  .withOpacity(0.7),
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getStatusColor(event['status']).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  event['status'],
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: _getStatusColor(event['status']),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().fade(duration: 500.ms, delay: 100.ms * index).slideX(
        begin: 0.1, end: 0, duration: 500.ms, curve: Curves.easeOutQuad);
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Approved':
        return const Color(0xFF4CAF50); // Green
      case 'Pending':
        return const Color(0xFFFFC107); // Yellow
      case 'Completed':
        return const Color(0xFF2196F3); // Blue
      case 'Rejected':
        return const Color(0xFFF44336); // Red
      default:
        return const Color(0xFF9E9E9E); // Grey
    }
  }

  Widget _buildUsersContent(ThemeData theme, bool isDarkMode) {
    return Column(
      children: [
        // Header with search and filter
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search users...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: isDarkMode
                        ? theme.colorScheme.surface
                        : Colors.grey[200],
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () {
                  // TODO: Implement filter functionality
                },
                icon: const Icon(Icons.filter_list),
                style: IconButton.styleFrom(
                  backgroundColor:
                      isDarkMode ? theme.colorScheme.surface : Colors.grey[200],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Tab bar
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isDarkMode ? theme.colorScheme.surface : Colors.grey[200],
            borderRadius: BorderRadius.circular(30),
          ),
          child: TabBar(
            controller: _tabController,
            indicator: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(30),
            ),
            labelColor: Colors.white,
            unselectedLabelColor: theme.colorScheme.onBackground,
            tabs: const [
              Tab(text: 'All Users'),
              Tab(text: 'Organizers'),
              Tab(text: 'Students'),
            ],
          ),
        ),

        // Tab content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              // All users
              _buildUsersList(
                users: _users,
                theme: theme,
                isDarkMode: isDarkMode,
                emptyMessage: 'No users found',
              ),

              // Organizers
              _buildUsersList(
                users: _users.where((u) => u['role'] == 'Organizer').toList(),
                theme: theme,
                isDarkMode: isDarkMode,
                emptyMessage: 'No organizers found',
              ),

              // Students
              _buildUsersList(
                users: _users.where((u) => u['role'] == 'Student').toList(),
                theme: theme,
                isDarkMode: isDarkMode,
                emptyMessage: 'No students found',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUsersList({
    required List<Map<String, dynamic>> users,
    required ThemeData theme,
    required bool isDarkMode,
    required String emptyMessage,
  }) {
    return users.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.people_outline,
                  size: 80,
                  color: theme.colorScheme.onBackground.withOpacity(0.3),
                ),
                const SizedBox(height: 16),
                Text(
                  emptyMessage,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.onBackground.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return _buildUserListItem(
                user: user,
                theme: theme,
                isDarkMode: isDarkMode,
                index: index,
              );
            },
          );
  }

  Widget _buildUserListItem({
    required Map<String, dynamic> user,
    required ThemeData theme,
    required bool isDarkMode,
    required int index,
  }) {
    final formattedJoinDate =
        DateFormat('MMM dd, yyyy').format(user['joinDate']);

    return GestureDetector(
      onTap: () => _navigateToUserDetails(user),
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
            // User image
            Padding(
              padding: const EdgeInsets.all(16),
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: AssetImage(user['image']),
                  ),
                  if (user['status'] == 'Active')
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 15,
                        height: 15,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDarkMode
                                ? theme.colorScheme.surface
                                : Colors.white,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // User name
                    Text(
                      user['name'],
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 4),

                    // User email
                    Text(
                      user['email'],
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onBackground.withOpacity(0.7),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // User role and join date
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            user['role'],
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.calendar_today,
                          size: 12,
                          color:
                              theme.colorScheme.onBackground.withOpacity(0.7),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Joined: $formattedJoinDate',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color:
                                theme.colorScheme.onBackground.withOpacity(0.7),
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: user['status'] == 'Active'
                      ? Colors.green.withOpacity(0.1)
                      : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  user['status'],
                  style: theme.textTheme.bodySmall?.copyWith(
                    color:
                        user['status'] == 'Active' ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().fade(duration: 500.ms, delay: 100.ms * index).slideX(
        begin: 0.1, end: 0, duration: 500.ms, curve: Curves.easeOutQuad);
  }

  Widget _buildReportsContent(ThemeData theme, bool isDarkMode) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Reports & Analytics',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ).animate().fade(duration: 500.ms),

            const SizedBox(height: 8),

            Text(
              'Overview of system performance and usage',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onBackground.withOpacity(0.7),
              ),
            ).animate().fade(duration: 500.ms, delay: 100.ms),

            const SizedBox(height: 30),

            // Date range selector
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Last 30 Days',
                    style: theme.textTheme.titleMedium,
                  ),
                  IconButton(
                    onPressed: () {
                      // TODO: Implement date range selection
                    },
                    icon: const Icon(Icons.calendar_month),
                    color: theme.colorScheme.primary,
                  ),
                ],
              ),
            ).animate().fade(duration: 500.ms, delay: 200.ms),

            const SizedBox(height: 30),

            // Event statistics
            Text(
              'Event Statistics',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ).animate().fade(duration: 500.ms, delay: 300.ms),

            const SizedBox(height: 16),

            Container(
              height: 300,
              padding: const EdgeInsets.all(16),
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
              child: Center(
                child: Text(
                  'Event statistics chart will be displayed here',
                  style: theme.textTheme.bodyLarge,
                ),
              ),
            ).animate().fade(duration: 500.ms, delay: 400.ms),

            const SizedBox(height: 30),

            // User statistics
            Text(
              'User Statistics',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ).animate().fade(duration: 500.ms, delay: 500.ms),

            const SizedBox(height: 16),

            Container(
              height: 300,
              padding: const EdgeInsets.all(16),
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
              child: Center(
                child: Text(
                  'User statistics chart will be displayed here',
                  style: theme.textTheme.bodyLarge,
                ),
              ),
            ).animate().fade(duration: 500.ms, delay: 600.ms),

            const SizedBox(height: 30),

            // Generated reports
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Generated Reports',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Implement report generation
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Generate New'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ],
            ).animate().fade(duration: 500.ms, delay: 700.ms),

            const SizedBox(height: 16),

            _buildReportsList(theme, isDarkMode)
                .animate()
                .fade(duration: 500.ms, delay: 800.ms),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildReportsList(ThemeData theme, bool isDarkMode) {
    final reports = [
      {
        'title': 'Monthly User Activity Report',
        'date': DateTime.now().subtract(const Duration(days: 3)),
        'type': 'PDF',
        'size': '2.4 MB',
      },
      {
        'title': 'Event Registration Analytics',
        'date': DateTime.now().subtract(const Duration(days: 7)),
        'type': 'Excel',
        'size': '1.8 MB',
      },
      {
        'title': 'Feedback Summary Report',
        'date': DateTime.now().subtract(const Duration(days: 14)),
        'type': 'PDF',
        'size': '3.2 MB',
      },
      {
        'title': 'System Performance Metrics',
        'date': DateTime.now().subtract(const Duration(days: 30)),
        'type': 'PDF',
        'size': '1.5 MB',
      },
    ];

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: reports.length,
      itemBuilder: (context, index) {
        final report = reports[index];
        final formattedDate =
            DateFormat('MMM dd, yyyy').format(report['date'] as DateTime);

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
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
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                report['type'] == 'PDF'
                    ? Icons.picture_as_pdf
                    : Icons.table_chart,
                color: theme.colorScheme.primary,
              ),
            ),
            title: Text(
              report['title'] as String,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              'Generated on $formattedDate • ${report['size']}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onBackground.withOpacity(0.7),
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () {
                    // TODO: Implement view report
                  },
                  icon: const Icon(Icons.visibility),
                  color: theme.colorScheme.primary,
                ),
                IconButton(
                  onPressed: () {
                    // TODO: Implement download report
                  },
                  icon: const Icon(Icons.download),
                  color: theme.colorScheme.primary,
                ),
              ],
            ),
          ),
        );
      },
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
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: theme.colorScheme.primary,
        unselectedItemColor: theme.colorScheme.onBackground.withOpacity(0.5),
        selectedLabelStyle: theme.textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.bold,
        ),
        unselectedLabelStyle: theme.textTheme.bodySmall,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event_outlined),
            activeIcon: Icon(Icons.event),
            label: 'Events',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline),
            activeIcon: Icon(Icons.people),
            label: 'Users',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics_outlined),
            activeIcon: Icon(Icons.analytics),
            label: 'Reports',
          ),
        ],
      ),
    ).animate().fade(duration: 500.ms).slideY(
        begin: 0.1, end: 0, duration: 500.ms, curve: Curves.easeOutQuad);
  }
}

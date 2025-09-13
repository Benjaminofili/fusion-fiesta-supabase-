import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';

class OrganizerDashboard extends StatefulWidget {
  const OrganizerDashboard({Key? key}) : super(key: key);

  @override
  State<OrganizerDashboard> createState() => _OrganizerDashboardState();
}

class _OrganizerDashboardState extends State<OrganizerDashboard> with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 0;
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  late TabController _tabController;

  // Mock data for events
  final List<Map<String, dynamic>> _myEvents = [
    {
      'id': '1',
      'title': 'Annual Tech Symposium',
      'date': DateTime.now().add(const Duration(days: 5)),
      'location': 'Main Auditorium',
      'image': 'assets/images/tech_symposium.jpg',
      'status': 'Upcoming',
      'registrations': 120,
      'capacity': 200,
      'description': 'A technical symposium featuring the latest advancements in technology with expert speakers and hands-on workshops.',
      'isApproved': true,
    },
    {
      'id': '2',
      'title': 'Workshop on AI & ML',
      'date': DateTime.now().add(const Duration(days: 3)),
      'location': 'Seminar Hall B',
      'image': 'assets/images/ai_workshop.jpg',
      'status': 'Upcoming',
      'registrations': 45,
      'capacity': 50,
      'description': 'An intensive workshop on Artificial Intelligence and Machine Learning fundamentals with practical applications.',
      'isApproved': true,
    },
    {
      'id': '3',
      'title': 'Hackathon 2023',
      'date': DateTime.now().add(const Duration(days: 7)),
      'location': 'Computer Lab',
      'image': 'assets/images/hackathon.jpg',
      'status': 'Pending Approval',
      'registrations': 0,
      'capacity': 100,
      'description': '24-hour coding competition to solve real-world problems with innovative solutions.',
      'isApproved': false,
    },
    {
      'id': '4',
      'title': 'Photography Workshop',
      'date': DateTime.now().subtract(const Duration(days: 30)),
      'location': 'Art Gallery',
      'image': 'assets/images/photography.jpg',
      'status': 'Completed',
      'registrations': 35,
      'capacity': 40,
      'description': 'Learn photography techniques from professional photographers with hands-on practice sessions.',
      'isApproved': true,
      'attendees': 32,
      'feedback': 4.7,
    },
  ];

  // Mock data for tasks
  final List<Map<String, dynamic>> _tasks = [
    {
      'id': '1',
      'title': 'Confirm speakers for Tech Symposium',
      'dueDate': DateTime.now().add(const Duration(days: 2)),
      'priority': 'High',
      'isCompleted': false,
      'relatedEvent': 'Annual Tech Symposium',
    },
    {
      'id': '2',
      'title': 'Book catering for AI Workshop',
      'dueDate': DateTime.now().add(const Duration(days: 1)),
      'priority': 'Medium',
      'isCompleted': false,
      'relatedEvent': 'Workshop on AI & ML',
    },
    {
      'id': '3',
      'title': 'Prepare certificates for Photography Workshop',
      'dueDate': DateTime.now(),
      'priority': 'High',
      'isCompleted': false,
      'relatedEvent': 'Photography Workshop',
    },
    {
      'id': '4',
      'title': 'Submit Hackathon proposal for approval',
      'dueDate': DateTime.now().subtract(const Duration(days: 1)),
      'priority': 'High',
      'isCompleted': true,
      'relatedEvent': 'Hackathon 2023',
    },
    {
      'id': '5',
      'title': 'Arrange prizes for Tech Symposium',
      'dueDate': DateTime.now().add(const Duration(days: 3)),
      'priority': 'Medium',
      'isCompleted': false,
      'relatedEvent': 'Annual Tech Symposium',
    },
  ];

  // Mock data for notifications
  final List<Map<String, dynamic>> _notifications = [
    {
      'id': '1',
      'title': 'Event Approved',
      'message': 'Your event "Annual Tech Symposium" has been approved by the admin.',
      'time': DateTime.now().subtract(const Duration(hours: 5)),
      'isRead': false,
    },
    {
      'id': '2',
      'title': 'New Registration',
      'message': '5 new students registered for "Workshop on AI & ML".',
      'time': DateTime.now().subtract(const Duration(hours: 8)),
      'isRead': true,
    },
    {
      'id': '3',
      'title': 'Task Due Soon',
      'message': 'Task "Book catering for AI Workshop" is due tomorrow.',
      'time': DateTime.now().subtract(const Duration(hours: 12)),
      'isRead': false,
    },
    {
      'id': '4',
      'title': 'Feedback Received',
      'message': 'New feedback received for "Photography Workshop".',
      'time': DateTime.now().subtract(const Duration(days: 1)),
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
    Navigator.pushNamed(context, AppConstants.eventManagementRoute, arguments: event);
  }

  void _navigateToCreateEvent() {
    Navigator.pushNamed(context, AppConstants.createEventRoute);
  }

  void _navigateToProfile() {
    Navigator.pushNamed(context, AppConstants.profileRoute);
  }

  void _navigateToNotifications() {
    Navigator.pushNamed(context, AppConstants.notificationsRoute);
  }

  void _completeTask(String taskId) {
    setState(() {
      final taskIndex = _tasks.indexWhere((task) => task['id'] == taskId);
      if (taskIndex != -1) {
        _tasks[taskIndex]['isCompleted'] = true;
      }
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Task marked as completed')),
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
                  ? _buildTasksContent(theme, isDarkMode)
                  : _buildAnalyticsContent(theme, isDarkMode),
      bottomNavigationBar: _buildBottomNavigationBar(theme, isDarkMode),
      floatingActionButton: _selectedIndex == 1
          ? FloatingActionButton(
              onPressed: _navigateToCreateEvent,
              backgroundColor: theme.colorScheme.primary,
              child: const Icon(Icons.add),
            )
          : null,
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
              'Organizer Dashboard',
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
            label: Text(_notifications.where((n) => !n['isRead']).length.toString()),
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
            backgroundImage: const AssetImage('assets/images/profile.jpg'),
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
                  backgroundImage: const AssetImage('assets/images/profile.jpg'),
                ),
                const SizedBox(height: 10),
                Text(
                  'Jane Smith',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Event Organizer',
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
            title: 'My Events',
            onTap: () {
              Navigator.pop(context);
              _onItemTapped(1);
            },
            theme: theme,
          ),
          _buildDrawerItem(
            icon: Icons.task_outlined,
            title: 'Tasks',
            onTap: () {
              Navigator.pop(context);
              _onItemTapped(2);
            },
            theme: theme,
          ),
          _buildDrawerItem(
            icon: Icons.analytics_outlined,
            title: 'Analytics',
            onTap: () {
              Navigator.pop(context);
              _onItemTapped(3);
            },
            theme: theme,
          ),
          _buildDrawerItem(
            icon: Icons.people_outline,
            title: 'Participants',
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppConstants.participantsRoute);
            },
            theme: theme,
          ),
          _buildDrawerItem(
            icon: Icons.card_membership_outlined,
            title: 'Certificates',
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppConstants.certificateManagementRoute);
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
              'Welcome, Jane!',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onBackground,
              ),
            ).animate()
              .fade(duration: 500.ms)
              .slideX(begin: -0.1, end: 0, duration: 500.ms, curve: Curves.easeOutQuad),
            
            Text(
              'Manage your events and tasks efficiently',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onBackground.withOpacity(0.7),
              ),
            ).animate()
              .fade(duration: 500.ms, delay: 200.ms)
              .slideX(begin: -0.1, end: 0, duration: 500.ms, curve: Curves.easeOutQuad),
            
            const SizedBox(height: 30),
            
            // Stats cards
            _buildStatsSection(theme, isDarkMode),
            
            const SizedBox(height: 30),
            
            // Upcoming events
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Your Events',
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
            ).animate()
              .fade(duration: 500.ms, delay: 500.ms),
            
            const SizedBox(height: 16),
            
            SizedBox(
              height: 280,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: _myEvents.where((e) => e['status'] != 'Completed').length,
                itemBuilder: (context, index) {
                  final event = _myEvents.where((e) => e['status'] != 'Completed').toList()[index];
                  return _buildEventCard(
                    event: event,
                    theme: theme,
                    isDarkMode: isDarkMode,
                    index: index,
                  );
                },
              ),
            ).animate()
              .fade(duration: 500.ms, delay: 600.ms),
            
            const SizedBox(height: 30),
            
            // Pending tasks
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Pending Tasks',
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
            ).animate()
              .fade(duration: 500.ms, delay: 700.ms),
            
            const SizedBox(height: 16),
            
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _tasks.where((t) => !t['isCompleted']).take(3).length,
              itemBuilder: (context, index) {
                final task = _tasks.where((t) => !t['isCompleted']).toList()[index];
                return _buildTaskCard(
                  task: task,
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

  Widget _buildStatsSection(ThemeData theme, bool isDarkMode) {
    final upcomingCount = _myEvents.where((e) => e['status'] == 'Upcoming').length;
    final pendingCount = _myEvents.where((e) => e['status'] == 'Pending Approval').length;
    final completedCount = _myEvents.where((e) => e['status'] == 'Completed').length;
    final pendingTasksCount = _tasks.where((t) => !t['isCompleted']).length;
    
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildStatCard(
          title: 'Upcoming Events',
          value: upcomingCount.toString(),
          icon: Icons.event,
          color: const Color(0xFF4CAF50),
          theme: theme,
          isDarkMode: isDarkMode,
          index: 0,
        ),
        _buildStatCard(
          title: 'Pending Approval',
          value: pendingCount.toString(),
          icon: Icons.pending_actions,
          color: const Color(0xFFFFC107),
          theme: theme,
          isDarkMode: isDarkMode,
          index: 1,
        ),
        _buildStatCard(
          title: 'Completed Events',
          value: completedCount.toString(),
          icon: Icons.event_available,
          color: const Color(0xFF2196F3),
          theme: theme,
          isDarkMode: isDarkMode,
          index: 2,
        ),
        _buildStatCard(
          title: 'Pending Tasks',
          value: pendingTasksCount.toString(),
          icon: Icons.check_circle,
          color: const Color(0xFFF44336),
          theme: theme,
          isDarkMode: isDarkMode,
          index: 3,
        ),
      ],
    ).animate()
      .fade(duration: 500.ms, delay: 300.ms)
      .scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1), duration: 500.ms, curve: Curves.easeOutBack);
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
    ).animate()
      .fade(duration: 500.ms, delay: 100.ms * index)
      .slideY(begin: 0.1, end: 0, duration: 500.ms, curve: Curves.easeOutQuad);
  }

  Widget _buildEventCard({
    required Map<String, dynamic> event,
    required ThemeData theme,
    required bool isDarkMode,
    required int index,
  }) {
    final formattedDate = DateFormat('MMM dd, yyyy').format(event['date']);
    final registrationPercent = event['registrations'] / event['capacity'];
    
    return GestureDetector(
      onTap: () => _navigateToEventDetails(event),
      child: Container(
        width: 280,
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
              child: Stack(
                children: [
                  Image.asset(
                    event['image'],
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getStatusColor(event['status']),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        event['status'],
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            Padding(
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
                          event['location'],
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
                  
                  // Registration progress
                  if (event['status'] != 'Pending Approval')
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Registrations',
                              style: theme.textTheme.bodyMedium,
                            ),
                            Text(
                              '${event['registrations']}/${event['capacity']}',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: registrationPercent,
                          backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            registrationPercent > 0.8
                                ? Colors.red
                                : registrationPercent > 0.5
                                    ? Colors.orange
                                    : theme.colorScheme.primary,
                          ),
                          borderRadius: BorderRadius.circular(10),
                          minHeight: 8,
                        ),
                      ],
                    )
                  else
                    OutlinedButton.icon(
                      onPressed: () {
                        // TODO: Implement edit event logic
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Edit event details')),
                        );
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit Proposal'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: theme.colorScheme.primary,
                        side: BorderSide(color: theme.colorScheme.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
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

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Upcoming':
        return const Color(0xFF4CAF50); // Green
      case 'Pending Approval':
        return const Color(0xFFFFC107); // Yellow
      case 'Completed':
        return const Color(0xFF2196F3); // Blue
      default:
        return const Color(0xFF9E9E9E); // Grey
    }
  }

  Widget _buildTaskCard({
    required Map<String, dynamic> task,
    required ThemeData theme,
    required bool isDarkMode,
    required int index,
  }) {
    final formattedDate = DateFormat('MMM dd, yyyy').format(task['dueDate']);
    final isOverdue = task['dueDate'].isBefore(DateTime.now()) && !task['isCompleted'];
    
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _getPriorityColor(task['priority']).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.assignment,
            color: _getPriorityColor(task['priority']),
          ),
        ),
        title: Text(
          task['title'],
          style: theme.textTheme.titleMedium?.copyWith(
            decoration: task['isCompleted'] ? TextDecoration.lineThrough : null,
            color: task['isCompleted']
                ? theme.colorScheme.onBackground.withOpacity(0.5)
                : theme.colorScheme.onBackground,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              'Due: $formattedDate',
              style: theme.textTheme.bodySmall?.copyWith(
                color: isOverdue
                    ? theme.colorScheme.error
                    : theme.colorScheme.onBackground.withOpacity(0.7),
                fontWeight: isOverdue ? FontWeight.bold : null,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'For: ${task['relatedEvent']}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onBackground.withOpacity(0.7),
              ),
            ),
          ],
        ),
        trailing: task['isCompleted']
            ? Icon(
                Icons.check_circle,
                color: theme.colorScheme.primary,
              )
            : IconButton(
                icon: const Icon(Icons.check_circle_outline),
                color: theme.colorScheme.primary,
                onPressed: () => _completeTask(task['id']),
              ),
        onTap: () {
          // TODO: Implement task details view
          if (!task['isCompleted']) {
            _completeTask(task['id']);
          }
        },
      ),
    ).animate()
      .fade(duration: 500.ms, delay: 100.ms * index)
      .slideX(begin: 0.1, end: 0, duration: 500.ms, curve: Curves.easeOutQuad);
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'High':
        return const Color(0xFFF44336); // Red
      case 'Medium':
        return const Color(0xFFFFC107); // Yellow
      case 'Low':
        return const Color(0xFF4CAF50); // Green
      default:
        return const Color(0xFF9E9E9E); // Grey
    }
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
              Tab(text: 'Upcoming'),
              Tab(text: 'Pending'),
              Tab(text: 'Completed'),
            ],
          ),
        ),
        
        // Tab content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              // Upcoming events
              _buildEventsList(
                events: _myEvents.where((e) => e['status'] == 'Upcoming').toList(),
                theme: theme,
                isDarkMode: isDarkMode,
                emptyMessage: 'No upcoming events',
              ),
              
              // Pending events
              _buildEventsList(
                events: _myEvents.where((e) => e['status'] == 'Pending Approval').toList(),
                theme: theme,
                isDarkMode: isDarkMode,
                emptyMessage: 'No pending events',
              ),
              
              // Completed events
              _buildEventsList(
                events: _myEvents.where((e) => e['status'] == 'Completed').toList(),
                theme: theme,
                isDarkMode: isDarkMode,
                emptyMessage: 'No completed events',
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
                            event['location'],
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onBackground.withOpacity(0.7),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    
                    if (event['status'] == 'Completed')
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Row(
                          children: [
                            Icon(
                              Icons.people,
                              size: 16,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${event['attendees']}/${event['registrations']} attended',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onBackground.withOpacity(0.7),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.star,
                              size: 16,
                              color: Colors.amber,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              event['feedback'].toString(),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onBackground.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
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
    ).animate()
      .fade(duration: 500.ms, delay: 100.ms * index)
      .slideX(begin: 0.1, end: 0, duration: 500.ms, curve: Curves.easeOutQuad);
  }

  Widget _buildTasksContent(ThemeData theme, bool isDarkMode) {
    return Column(
      children: [
        // Header with add task button
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Task Management',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  // TODO: Implement add task logic
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Add new task')),
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text('Add Task'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
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
              Tab(text: 'Pending'),
              Tab(text: 'Completed'),
              Tab(text: 'All'),
            ],
          ),
        ),
        
        // Tab content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              // Pending tasks
              _buildTasksList(
                tasks: _tasks.where((t) => !t['isCompleted']).toList(),
                theme: theme,
                isDarkMode: isDarkMode,
                emptyMessage: 'No pending tasks',
              ),
              
              // Completed tasks
              _buildTasksList(
                tasks: _tasks.where((t) => t['isCompleted']).toList(),
                theme: theme,
                isDarkMode: isDarkMode,
                emptyMessage: 'No completed tasks',
              ),
              
              // All tasks
              _buildTasksList(
                tasks: _tasks,
                theme: theme,
                isDarkMode: isDarkMode,
                emptyMessage: 'No tasks',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTasksList({
    required List<Map<String, dynamic>> tasks,
    required ThemeData theme,
    required bool isDarkMode,
    required String emptyMessage,
  }) {
    return tasks.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.assignment_late,
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
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return _buildTaskCard(
                task: task,
                theme: theme,
                isDarkMode: isDarkMode,
                index: index,
              );
            },
          );
  }

  Widget _buildAnalyticsContent(ThemeData theme, bool isDarkMode) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Event Analytics',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ).animate()
              .fade(duration: 500.ms),
            
            const SizedBox(height: 8),
            
            Text(
              'Overview of your event performance',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onBackground.withOpacity(0.7),
              ),
            ).animate()
              .fade(duration: 500.ms, delay: 100.ms),
            
            const SizedBox(height: 30),
            
            // Analytics cards
            _buildAnalyticsCards(theme, isDarkMode),
            
            const SizedBox(height: 30),
            
            // Event performance chart
            Text(
              'Event Performance',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ).animate()
              .fade(duration: 500.ms, delay: 300.ms),
            
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
                  'Event performance chart will be displayed here',
                  style: theme.textTheme.bodyLarge,
                ),
              ),
            ).animate()
              .fade(duration: 500.ms, delay: 400.ms)
              .slideY(begin: 0.1, end: 0, duration: 500.ms, curve: Curves.easeOutQuad),
            
            const SizedBox(height: 30),
            
            // Feedback summary
            Text(
              'Feedback Summary',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ).animate()
              .fade(duration: 500.ms, delay: 500.ms),
            
            const SizedBox(height: 16),
            
            Container(
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
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Photography Workshop',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            color: Colors.amber,
                            size: 20,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '4.7',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildFeedbackBar(
                    label: 'Content',
                    value: 0.9,
                    theme: theme,
                  ),
                  const SizedBox(height: 12),
                  _buildFeedbackBar(
                    label: 'Organization',
                    value: 0.85,
                    theme: theme,
                  ),
                  const SizedBox(height: 12),
                  _buildFeedbackBar(
                    label: 'Venue',
                    value: 0.75,
                    theme: theme,
                  ),
                  const SizedBox(height: 12),
                  _buildFeedbackBar(
                    label: 'Instructor',
                    value: 0.95,
                    theme: theme,
                  ),
                ],
              ),
            ).animate()
              .fade(duration: 500.ms, delay: 600.ms)
              .slideY(begin: 0.1, end: 0, duration: 500.ms, curve: Curves.easeOutQuad),
            
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsCards(ThemeData theme, bool isDarkMode) {
    return Row(
      children: [
        Expanded(
          child: _buildAnalyticsCard(
            title: 'Total Events',
            value: _myEvents.length.toString(),
            icon: Icons.event,
            color: theme.colorScheme.primary,
            theme: theme,
            isDarkMode: isDarkMode,
            index: 0,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildAnalyticsCard(
            title: 'Total Registrations',
            value: '200',
            icon: Icons.people,
            color: const Color(0xFF4CAF50),
            theme: theme,
            isDarkMode: isDarkMode,
            index: 1,
          ),
        ),
      ],
    ).animate()
      .fade(duration: 500.ms, delay: 200.ms);
  }

  Widget _buildAnalyticsCard({
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
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onBackground.withOpacity(0.7),
            ),
          ),
        ],
      ),
    ).animate()
      .fade(duration: 500.ms, delay: 100.ms * index)
      .slideY(begin: 0.1, end: 0, duration: 500.ms, curve: Curves.easeOutQuad);
  }

  Widget _buildFeedbackBar({
    required String label,
    required double value,
    required ThemeData theme,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: theme.textTheme.bodyMedium,
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LinearProgressIndicator(
                value: value,
                backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                borderRadius: BorderRadius.circular(10),
                minHeight: 8,
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${(value * 5).toStringAsFixed(1)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '5.0',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
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
        backgroundColor: Colors.transparent,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: theme.colorScheme.primary,
        unselectedItemColor: theme.colorScheme.onBackground.withOpacity(0.5),
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
            icon: Icon(Icons.task_outlined),
            activeIcon: Icon(Icons.task),
            label: 'Tasks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics_outlined),
            activeIcon: Icon(Icons.analytics),
            label: 'Analytics',
          ),
        ],
      ),
    );
  }
}
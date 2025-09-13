import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';

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

  // Mock data for events
  final List<Map<String, dynamic>> _upcomingEvents = [
    {
      'id': '1',
      'title': 'Annual Tech Symposium',
      'date': DateTime.now().add(const Duration(days: 5)),
      'location': 'Main Auditorium',
      'image': 'assets/images/tech_symposium.jpg',
      'organizer': 'Computer Science Department',
      'category': 'Technical',
      'isRegistered': false,
    },
    {
      'id': '2',
      'title': 'Cultural Fest 2023',
      'date': DateTime.now().add(const Duration(days: 10)),
      'location': 'College Ground',
      'image': 'assets/images/cultural_fest.jpg',
      'organizer': 'Cultural Committee',
      'category': 'Cultural',
      'isRegistered': true,
    },
    {
      'id': '3',
      'title': 'Workshop on AI & ML',
      'date': DateTime.now().add(const Duration(days: 3)),
      'location': 'Seminar Hall B',
      'image': 'assets/images/ai_workshop.jpg',
      'organizer': 'AI Club',
      'category': 'Workshop',
      'isRegistered': false,
    },
    {
      'id': '4',
      'title': 'Entrepreneurship Summit',
      'date': DateTime.now().add(const Duration(days: 15)),
      'location': 'Business School',
      'image': 'assets/images/entrepreneurship.jpg',
      'organizer': 'E-Cell',
      'category': 'Summit',
      'isRegistered': false,
    },
  ];

  final List<Map<String, dynamic>> _registeredEvents = [
    {
      'id': '2',
      'title': 'Cultural Fest 2023',
      'date': DateTime.now().add(const Duration(days: 10)),
      'location': 'College Ground',
      'image': 'assets/images/cultural_fest.jpg',
      'organizer': 'Cultural Committee',
      'category': 'Cultural',
      'status': 'Registered',
    },
    {
      'id': '5',
      'title': 'Hackathon 2023',
      'date': DateTime.now().add(const Duration(days: 7)),
      'location': 'Computer Lab',
      'image': 'assets/images/hackathon.jpg',
      'organizer': 'Developer Club',
      'category': 'Competition',
      'status': 'Registered',
    },
  ];

  final List<Map<String, dynamic>> _pastEvents = [
    {
      'id': '6',
      'title': 'Sports Day 2023',
      'date': DateTime.now().subtract(const Duration(days: 15)),
      'location': 'Sports Complex',
      'image': 'assets/images/sports_day.jpg',
      'organizer': 'Sports Committee',
      'category': 'Sports',
      'status': 'Attended',
      'certificate': true,
    },
    {
      'id': '7',
      'title': 'Photography Workshop',
      'date': DateTime.now().subtract(const Duration(days: 30)),
      'location': 'Art Gallery',
      'image': 'assets/images/photography.jpg',
      'organizer': 'Photography Club',
      'category': 'Workshop',
      'status': 'Attended',
      'certificate': true,
    },
    {
      'id': '8',
      'title': 'Debate Competition',
      'date': DateTime.now().subtract(const Duration(days: 45)),
      'location': 'Seminar Hall A',
      'image': 'assets/images/debate.jpg',
      'organizer': 'Literary Club',
      'category': 'Competition',
      'status': 'Missed',
      'certificate': false,
    },
  ];

  // Mock data for notifications
  final List<Map<String, dynamic>> _notifications = [
    {
      'id': '1',
      'title': 'Registration Confirmed',
      'message': 'Your registration for Cultural Fest 2023 has been confirmed.',
      'time': DateTime.now().subtract(const Duration(hours: 2)),
      'isRead': false,
    },
    {
      'id': '2',
      'title': 'Event Reminder',
      'message': 'Workshop on AI & ML is scheduled for tomorrow at 10:00 AM.',
      'time': DateTime.now().subtract(const Duration(hours: 5)),
      'isRead': true,
    },
    {
      'id': '3',
      'title': 'Certificate Available',
      'message': 'Your certificate for Sports Day 2023 is now available for download.',
      'time': DateTime.now().subtract(const Duration(days: 1)),
      'isRead': false,
    },
    {
      'id': '4',
      'title': 'New Event Announced',
      'message': 'Entrepreneurship Summit has been announced. Register now!',
      'time': DateTime.now().subtract(const Duration(days: 2)),
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
    Navigator.pushNamed(context, AppConstants.eventDetailsRoute, arguments: event);
  }

  void _navigateToProfile() {
    Navigator.pushNamed(context, AppConstants.profileRoute);
  }

  void _navigateToNotifications() {
    Navigator.pushNamed(context, AppConstants.notificationsRoute);
  }

  void _registerForEvent(String eventId) {
    // TODO: Implement registration logic
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Registered for event $eventId')),
    );
  }

  void _downloadCertificate(String eventId) {
    // TODO: Implement certificate download logic
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Downloading certificate for event $eventId')),
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
              ? _buildCalendarContent(theme, isDarkMode)
              : _selectedIndex == 2
                  ? _buildNotificationsContent(theme, isDarkMode)
                  : _buildProfileContent(theme, isDarkMode),
      bottomNavigationBar: _buildBottomNavigationBar(theme, isDarkMode),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: () {
                // TODO: Implement quick event search or filter
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Quick event search')),
                );
              },
              backgroundColor: theme.colorScheme.primary,
              child: const Icon(Icons.search),
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
                  'John Doe',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Computer Science, Year 3',
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
              'Hello, John!',
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
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: _upcomingEvents.length,
                itemBuilder: (context, index) {
                  final event = _upcomingEvents[index];
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
            
            _registeredEvents.isEmpty
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
                    itemCount: _registeredEvents.length,
                    itemBuilder: (context, index) {
                      final event = _registeredEvents[index];
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
    required Map<String, dynamic> event,
    required ThemeData theme,
    required bool isDarkMode,
    required int index,
  }) {
    final formattedDate = DateFormat('MMM dd, yyyy').format(event['date']);
    
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
                        color: theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        event['category'],
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
                  
                  // Register button
                  event['isRegistered']
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
                          onPressed: () => _registerForEvent(event['id']),
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
                  event['status'],
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

  Widget _buildCalendarContent(ThemeData theme, bool isDarkMode) {
    // TODO: Implement calendar view
    return Center(
      child: Text(
        'Calendar View Coming Soon',
        style: theme.textTheme.headlineSmall,
      ),
    );
  }

  Widget _buildNotificationsContent(ThemeData theme, bool isDarkMode) {
    return _notifications.isEmpty
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
            itemCount: _notifications.length,
            itemBuilder: (context, index) {
              final notification = _notifications[index];
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
    required Map<String, dynamic> notification,
    required ThemeData theme,
    required bool isDarkMode,
    required int index,
  }) {
    final timeAgo = _getTimeAgo(notification['time']);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: notification['isRead']
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
            _getNotificationIcon(notification['title']),
            color: theme.colorScheme.primary,
          ),
        ),
        title: Text(
          notification['title'],
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: notification['isRead'] ? FontWeight.normal : FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              notification['message'],
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
        trailing: notification['isRead']
            ? null
            : Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  shape: BoxShape.circle,
                ),
              ),
        onTap: () {
          // TODO: Implement notification read logic
          setState(() {
            notification['isRead'] = true;
          });
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

  String _getTimeAgo(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    
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
    // TODO: Implement profile view
    return Center(
      child: Text(
        'Profile View Coming Soon',
        style: theme.textTheme.headlineSmall,
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
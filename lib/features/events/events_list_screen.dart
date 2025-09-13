import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fusion_fiesta/core/theme/app_theme.dart';
import 'package:fusion_fiesta/features/events/event_details_screen.dart';
import 'package:intl/intl.dart';

class EventsListScreen extends StatefulWidget {
  const EventsListScreen({Key? key}) : super(key: key);

  @override
  State<EventsListScreen> createState() => _EventsListScreenState();
}

class _EventsListScreenState extends State<EventsListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'All';
  String _selectedSort = 'Date: Newest';
  
  // Mock data for events
  final List<Map<String, dynamic>> _allEvents = [
    {
      'id': '1',
      'title': 'Tech Conference 2023',
      'date': DateTime.now().add(const Duration(days: 5)),
      'location': 'Main Auditorium',
      'image': 'https://images.unsplash.com/photo-1540575467063-178a50c2df87',
      'description': 'Join us for the biggest tech conference of the year featuring keynotes from industry leaders, workshops, and networking opportunities.',
      'organizer': 'Tech Association',
      'price': 'Free',
      'category': 'Technology',
      'isFavorite': false,
      'isRegistered': false,
      'attendees': 120,
      'rating': 4.8,
    },
    {
      'id': '2',
      'title': 'Design Workshop',
      'date': DateTime.now().add(const Duration(days: 2)),
      'location': 'Design Lab',
      'image': 'https://images.unsplash.com/photo-1475721027785-f74eccf877e2',
      'description': 'Learn the fundamentals of UI/UX design in this hands-on workshop led by industry professionals.',
      'organizer': 'Design Guild',
      'price': '\$25',
      'category': 'Design',
      'isFavorite': true,
      'isRegistered': true,
      'attendees': 45,
      'rating': 4.5,
    },
    {
      'id': '3',
      'title': 'Entrepreneurship Summit',
      'date': DateTime.now().add(const Duration(days: 10)),
      'location': 'Business School',
      'image': 'https://images.unsplash.com/photo-1556761175-b413da4baf72',
      'description': 'Connect with successful entrepreneurs and investors to learn about starting and scaling your business.',
      'organizer': 'Startup Hub',
      'price': '\$50',
      'category': 'Business',
      'isFavorite': false,
      'isRegistered': false,
      'attendees': 80,
      'rating': 4.7,
    },
    {
      'id': '4',
      'title': 'Cultural Fest',
      'date': DateTime.now().add(const Duration(days: 15)),
      'location': 'College Ground',
      'image': 'https://images.unsplash.com/photo-1514525253161-7a46d19cd819',
      'description': 'Celebrate diversity with performances, food, and activities from cultures around the world.',
      'organizer': 'Cultural Committee',
      'price': 'Free',
      'category': 'Cultural',
      'isFavorite': true,
      'isRegistered': false,
      'attendees': 350,
      'rating': 4.9,
    },
    {
      'id': '5',
      'title': 'Hackathon 2023',
      'date': DateTime.now().add(const Duration(days: 7)),
      'location': 'Computer Science Building',
      'image': 'https://images.unsplash.com/photo-1504384308090-c894fdcc538d',
      'description': 'Put your coding skills to the test in this 24-hour hackathon with prizes for the most innovative solutions.',
      'organizer': 'Code Club',
      'price': 'Free',
      'category': 'Technology',
      'isFavorite': false,
      'isRegistered': true,
      'attendees': 75,
      'rating': 4.6,
    },
    {
      'id': '6',
      'title': 'Career Fair',
      'date': DateTime.now().add(const Duration(days: 3)),
      'location': 'University Hall',
      'image': 'https://images.unsplash.com/photo-1560523159-4a9692d222f9',
      'description': 'Meet recruiters from top companies and explore internship and job opportunities in various fields.',
      'organizer': 'Career Services',
      'price': 'Free',
      'category': 'Career',
      'isFavorite': false,
      'isRegistered': false,
      'attendees': 200,
      'rating': 4.3,
    },
    {
      'id': '7',
      'title': 'Music Festival',
      'date': DateTime.now().add(const Duration(days: 20)),
      'location': 'City Park',
      'image': 'https://images.unsplash.com/photo-1459749411175-04bf5292ceea',
      'description': 'Enjoy performances from local and international artists across multiple genres in this weekend-long festival.',
      'organizer': 'Music Society',
      'price': '\$75',
      'category': 'Entertainment',
      'isFavorite': true,
      'isRegistered': false,
      'attendees': 500,
      'rating': 4.9,
    },
    {
      'id': '8',
      'title': 'Health & Wellness Expo',
      'date': DateTime.now().add(const Duration(days: 12)),
      'location': 'Community Center',
      'image': 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b',
      'description': 'Discover the latest in health, fitness, and wellness with workshops, demonstrations, and product showcases.',
      'organizer': 'Wellness Club',
      'price': '\$10',
      'category': 'Health',
      'isFavorite': false,
      'isRegistered': false,
      'attendees': 150,
      'rating': 4.4,
    },
  ];
  
  final List<String> _categories = [
    'All',
    'Technology',
    'Design',
    'Business',
    'Cultural',
    'Career',
    'Entertainment',
    'Health',
  ];
  
  final List<String> _sortOptions = [
    'Date: Newest',
    'Date: Oldest',
    'Rating: High to Low',
    'Popularity',
    'Price: Low to High',
    'Price: High to Low',
  ];
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  List<Map<String, dynamic>> get _filteredEvents {
    List<Map<String, dynamic>> filteredList = List.from(_allEvents);
    
    // Apply category filter
    if (_selectedCategory != 'All') {
      filteredList = filteredList.where((event) => 
        event['category'] == _selectedCategory
      ).toList();
    }
    
    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filteredList = filteredList.where((event) {
        return event['title'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
               event['description'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
               event['location'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
               event['organizer'].toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }
    
    // Apply sorting
    switch (_selectedSort) {
      case 'Date: Newest':
        filteredList.sort((a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime));
        break;
      case 'Date: Oldest':
        filteredList.sort((a, b) => (a['date'] as DateTime).compareTo(b['date'] as DateTime));
        break;
      case 'Rating: High to Low':
        filteredList.sort((a, b) => (b['rating'] as double).compareTo(a['rating'] as double));
        break;
      case 'Popularity':
        filteredList.sort((a, b) => (b['attendees'] as int).compareTo(a['attendees'] as int));
        break;
      case 'Price: Low to High':
        filteredList.sort((a, b) {
          final aPrice = a['price'] == 'Free' ? 0 : double.parse(a['price'].toString().replaceAll('\$', ''));
          final bPrice = b['price'] == 'Free' ? 0 : double.parse(b['price'].toString().replaceAll('\$', ''));
          return aPrice.compareTo(bPrice);
        });
        break;
      case 'Price: High to Low':
        filteredList.sort((a, b) {
          final aPrice = a['price'] == 'Free' ? 0 : double.parse(a['price'].toString().replaceAll('\$', ''));
          final bPrice = b['price'] == 'Free' ? 0 : double.parse(b['price'].toString().replaceAll('\$', ''));
          return bPrice.compareTo(aPrice);
        });
        break;
    }
    
    return filteredList;
  }
  
  void _toggleFavorite(String eventId) {
    setState(() {
      final index = _allEvents.indexWhere((event) => event['id'] == eventId);
      if (index != -1) {
        _allEvents[index]['isFavorite'] = !_allEvents[index]['isFavorite'];
      }
    });
  }
  
  void _navigateToEventDetails(String eventId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EventDetailsScreen(eventId: eventId),
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
          'Events',
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
          IconButton(
            icon: Icon(
              Icons.filter_list,
              color: theme.colorScheme.primary,
            ),
            onPressed: () {
              _showFilterBottomSheet(theme);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search events...',
                prefixIcon: Icon(
                  Icons.search,
                  color: theme.colorScheme.primary,
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.clear,
                          color: theme.colorScheme.primary,
                        ),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ).animate()
            .fade(duration: 600.ms)
            .slideY(begin: -0.1, end: 0, duration: 600.ms),
          
          // Category Chips
          SizedBox(
            height: 50,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = category == _selectedCategory;
                
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedCategory = category;
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
          
          // Sort Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_filteredEvents.length} Events',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onBackground.withOpacity(0.7),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    _showSortBottomSheet(theme);
                  },
                  child: Row(
                    children: [
                      Text(
                        'Sort: $_selectedSort',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_drop_down,
                        color: theme.colorScheme.primary,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ).animate()
            .fade(duration: 600.ms, delay: 300.ms),
          
          // Events List
          Expanded(
            child: _filteredEvents.isEmpty
                ? _buildEmptyState(theme)
                : ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: _filteredEvents.length,
                    itemBuilder: (context, index) {
                      final event = _filteredEvents[index];
                      return _buildEventCard(event, theme, index);
                    },
                  ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildEventCard(Map<String, dynamic> event, ThemeData theme, int index) {
    final isRegistered = event['isRegistered'] as bool;
    final isFavorite = event['isFavorite'] as bool;
    
    return GestureDetector(
      onTap: () => _navigateToEventDetails(event['id']),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event Image and Favorite Button
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  child: Image.network(
                    event['image'],
                    width: double.infinity,
                    height: 150,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: double.infinity,
                        height: 150,
                        color: theme.colorScheme.primary.withOpacity(0.2),
                        child: Icon(
                          Icons.image_not_supported,
                          color: theme.colorScheme.primary,
                          size: 40,
                        ),
                      );
                    },
                  ),
                ),
                
                // Favorite Button
                Positioned(
                  top: 12,
                  right: 12,
                  child: GestureDetector(
                    onTap: () => _toggleFavorite(event['id']),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.red : Colors.grey,
                        size: 20,
                      ),
                    ),
                  ),
                ),
                
                // Category Badge
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      event['category'],
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                
                // Registration Badge
                if (isRegistered)
                  Positioned(
                    bottom: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: Colors.white,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Registered',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            
            // Event Info
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          event['title'],
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          event['price'],
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        color: theme.colorScheme.onSurfaceVariant,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('MMM dd, yyyy').format(event['date']),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        color: theme.colorScheme.onSurfaceVariant,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          event['location'],
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.person,
                        color: theme.colorScheme.onSurfaceVariant,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          'By ${event['organizer']}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.star,
                        color: Colors.amber,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        event['rating'].toString(),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        Icons.people,
                        color: theme.colorScheme.onSurfaceVariant,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${event['attendees']} attending',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    event['description'],
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _navigateToEventDetails(event['id']),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isRegistered
                            ? Colors.green
                            : theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(isRegistered ? 'View Details' : 'Register Now'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate()
      .fade(duration: 600.ms, delay: (200 + (index * 100)).ms)
      .slideY(begin: 0.1, end: 0, duration: 600.ms);
  }
  
  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_busy,
            size: 80,
            color: theme.colorScheme.primary.withOpacity(0.5),
          ).animate()
            .fade(duration: 600.ms)
            .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1), duration: 600.ms),
          
          const SizedBox(height: 16),
          
          Text(
            'No Events Found',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onBackground,
            ),
          ).animate()
            .fade(duration: 600.ms, delay: 200.ms),
          
          const SizedBox(height: 8),
          
          Text(
            _searchQuery.isNotEmpty || _selectedCategory != 'All'
                ? 'Try changing your filters or search terms'
                : 'Check back later for upcoming events',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onBackground.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ).animate()
            .fade(duration: 600.ms, delay: 400.ms),
          
          const SizedBox(height: 24),
          
          if (_searchQuery.isNotEmpty || _selectedCategory != 'All')
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _searchController.clear();
                  _searchQuery = '';
                  _selectedCategory = 'All';
                });
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Reset Filters'),
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
  
  void _showFilterBottomSheet(ThemeData theme) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: theme.colorScheme.background,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onBackground.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            
            // Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filter Events',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onBackground,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedCategory = 'All';
                        _selectedSort = 'Date: Newest';
                        _searchController.clear();
                        _searchQuery = '';
                      });
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Reset All',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const Divider(),
            
            // Categories
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Categories',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onBackground,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _categories.map((category) {
                      final isSelected = category == _selectedCategory;
                      return FilterChip(
                        label: Text(category),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _selectedCategory = category;
                          });
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
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            
            const Divider(),
            
            // Sort Options
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sort By',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onBackground,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...List.generate(_sortOptions.length, (index) {
                    final option = _sortOptions[index];
                    final isSelected = option == _selectedSort;
                    
                    return RadioListTile<String>(
                      title: Text(
                        option,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onBackground,
                        ),
                      ),
                      value: option,
                      groupValue: _selectedSort,
                      onChanged: (value) {
                        setState(() {
                          _selectedSort = value!;
                        });
                      },
                      activeColor: theme.colorScheme.primary,
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                    );
                  }),
                ],
              ),
            ),
            
            const Spacer(),
            
            // Apply Button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Text('Apply Filters'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  void _showSortBottomSheet(ThemeData theme) {
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.onBackground.withOpacity(0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Sort By',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onBackground,
              ),
            ),
          ),
          
          // Sort Options
          ...List.generate(_sortOptions.length, (index) {
            final option = _sortOptions[index];
            final isSelected = option == _selectedSort;
            
            return ListTile(
              title: Text(
                option,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onBackground,
                ),
              ),
              leading: Radio<String>(
                value: option,
                groupValue: _selectedSort,
                onChanged: (value) {
                  setState(() {
                    _selectedSort = value!;
                  });
                  Navigator.pop(context);
                },
                activeColor: theme.colorScheme.primary,
              ),
              onTap: () {
                setState(() {
                  _selectedSort = option;
                });
                Navigator.pop(context);
              },
            );
          }),
          
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
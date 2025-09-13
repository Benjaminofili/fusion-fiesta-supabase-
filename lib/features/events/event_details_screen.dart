import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';


class EventDetailsScreen extends StatefulWidget {
  final String eventId;
  
  const EventDetailsScreen({
    Key? key,
    required this.eventId,
  }) : super(key: key);

  @override
  State<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isFavorite = false;
  bool _isRegistered = false;
  bool _isRegistering = false;
  
  // Mock event data
  late Map<String, dynamic> _event;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _loadEventDetails();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  void _loadEventDetails() {
    // Mock data - in a real app, this would be fetched from an API
    _event = {
      'id': widget.eventId,
      'title': 'Tech Innovation Summit 2023',
      'description': 'Join us for the biggest tech innovation summit of the year. Connect with industry leaders, participate in workshops, and explore the latest technologies shaping our future.',
      'bannerImage': 'assets/images/event_banner.jpg',
      'date': DateTime.now().add(const Duration(days: 15)),
      'endDate': DateTime.now().add(const Duration(days: 16)),
      'location': 'Central Convention Center, New Delhi',
      'organizer': {
        'name': 'Tech Innovators Association',
        'logo': 'assets/images/organizer_logo.png',
        'description': 'A community of tech enthusiasts dedicated to promoting innovation and collaboration in the tech industry.',
      },
      'isFree': false,
      'price': 499.0,
      'rating': 4.7,
      'totalRatings': 235,
      'capacity': 500,
      'registeredCount': 342,
      'tags': ['Technology', 'Innovation', 'Networking', 'Workshops'],
      'speakers': [
        {
          'name': 'Dr. Rajesh Kumar',
          'designation': 'CTO, TechGiant Inc.',
          'image': 'assets/images/speaker1.jpg',
          'bio': 'Dr. Kumar has over 15 years of experience in AI and machine learning.',
        },
        {
          'name': 'Priya Sharma',
          'designation': 'Founder, InnovateTech',
          'image': 'assets/images/speaker2.jpg',
          'bio': 'Priya is a serial entrepreneur with multiple successful tech startups.',
        },
        {
          'name': 'Alex Johnson',
          'designation': 'AI Research Lead, FutureTech',
          'image': 'assets/images/speaker3.jpg',
          'bio': 'Alex specializes in deep learning and neural networks.',
        },
      ],
      'schedule': [
        {
          'day': 'Day 1',
          'date': DateTime.now().add(const Duration(days: 15)),
          'sessions': [
            {
              'time': '09:00 AM - 10:00 AM',
              'title': 'Registration & Breakfast',
              'location': 'Main Hall',
            },
            {
              'time': '10:00 AM - 11:30 AM',
              'title': 'Keynote: Future of AI',
              'speaker': 'Dr. Rajesh Kumar',
              'location': 'Auditorium A',
            },
            {
              'time': '11:45 AM - 01:00 PM',
              'title': 'Panel Discussion: Tech Trends 2023',
              'location': 'Auditorium B',
            },
            {
              'time': '01:00 PM - 02:00 PM',
              'title': 'Lunch Break',
              'location': 'Dining Area',
            },
            {
              'time': '02:00 PM - 04:00 PM',
              'title': 'Workshop: Building AI Solutions',
              'speaker': 'Priya Sharma',
              'location': 'Workshop Hall 1',
            },
            {
              'time': '04:15 PM - 05:30 PM',
              'title': 'Networking Session',
              'location': 'Exhibition Area',
            },
          ],
        },
        {
          'day': 'Day 2',
          'date': DateTime.now().add(const Duration(days: 16)),
          'sessions': [
            {
              'time': '09:30 AM - 10:00 AM',
              'title': 'Morning Coffee',
              'location': 'Main Hall',
            },
            {
              'time': '10:00 AM - 11:30 AM',
              'title': 'Deep Dive: Neural Networks',
              'speaker': 'Alex Johnson',
              'location': 'Auditorium A',
            },
            {
              'time': '11:45 AM - 01:00 PM',
              'title': 'Startup Showcase',
              'location': 'Exhibition Area',
            },
            {
              'time': '01:00 PM - 02:00 PM',
              'title': 'Lunch Break',
              'location': 'Dining Area',
            },
            {
              'time': '02:00 PM - 03:30 PM',
              'title': 'Workshop: Cloud Solutions',
              'location': 'Workshop Hall 2',
            },
            {
              'time': '03:45 PM - 05:00 PM',
              'title': 'Closing Ceremony & Awards',
              'location': 'Main Auditorium',
            },
          ],
        },
      ],
      'sponsors': [
        {
          'name': 'TechGiant Inc.',
          'logo': 'assets/images/sponsor1.png',
          'level': 'Platinum',
        },
        {
          'name': 'InnovateTech',
          'logo': 'assets/images/sponsor2.png',
          'level': 'Gold',
        },
        {
          'name': 'FutureTech',
          'logo': 'assets/images/sponsor3.png',
          'level': 'Silver',
        },
      ],
      'faqs': [
        {
          'question': 'What is the refund policy?',
          'answer': 'Full refunds are available up to 7 days before the event. Partial refunds (50%) are available up to 3 days before the event.',
        },
        {
          'question': 'Is there parking available at the venue?',
          'answer': 'Yes, the venue has ample parking space available for attendees. Parking is free for registered participants.',
        },
        {
          'question': 'Will the sessions be recorded?',
          'answer': 'Yes, all sessions will be recorded and made available to registered participants after the event.',
        },
        {
          'question': 'Is there a dress code?',
          'answer': 'Business casual is recommended for all sessions and networking events.',
        },
      ],
    };
    
    setState(() {});
  }
  
  void _toggleFavorite() {
    setState(() {
      _isFavorite = !_isFavorite;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isFavorite ? 'Added to favorites' : 'Removed from favorites'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
  
  void _toggleRegistration() {
    if (_isRegistering) return;
    
    setState(() {
      _isRegistering = true;
    });
    
    // Simulate API call
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _isRegistered = !_isRegistered;
        _isRegistering = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isRegistered ? 'Successfully registered for the event' : 'Registration canceled'),
          duration: const Duration(seconds: 2),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      body: _event == null
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                _buildAppBar(theme),
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildEventInfoCard(theme),
                      _buildRegistrationButton(theme),
                      _buildTabBar(theme),
                    ],
                  ),
                ),
                SliverFillRemaining(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildAboutTab(theme),
                      _buildScheduleTab(theme),
                      _buildSpeakersTab(theme),
                      _buildLocationTab(theme),
                      _buildFAQsTab(theme),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
  
  Widget _buildAppBar(ThemeData theme) {
    return SliverAppBar(
      expandedHeight: 200.0,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          _event['title'],
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(color: Colors.black45, blurRadius: 10, offset: Offset(0, 2)),
            ],
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              _event['bannerImage'],
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: theme.colorScheme.primary,
                  child: Center(
                    child: Icon(
                      Icons.event,
                      size: 80,
                      color: theme.colorScheme.onPrimary.withOpacity(0.5),
                    ),
                  ),
                );
              },
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(
            _isFavorite ? Icons.favorite : Icons.favorite_border,
            color: _isFavorite ? Colors.red : Colors.white,
          ),
          onPressed: _toggleFavorite,
          tooltip: 'Favorite',
        ),
        IconButton(
          icon: const Icon(Icons.share, color: Colors.white),
          onPressed: () {
            // TODO: Implement share functionality
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Share functionality coming soon')),
            );
          },
          tooltip: 'Share',
        ),
      ],
    );
  }
  
  Widget _buildEventInfoCard(ThemeData theme) {
    final dateFormat = DateFormat('E, MMM d, yyyy');
    final timeFormat = DateFormat('h:mm a');
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 0,
        color: theme.colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: theme.colorScheme.outline.withOpacity(0.2),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.star,
                          size: 16,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${_event['rating']}',
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          ' (${_event['totalRatings']})',
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _event['registeredCount'] >= _event['capacity'] * 0.8
                          ? Colors.red.withOpacity(0.1)
                          : Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _event['registeredCount'] >= _event['capacity']
                          ? 'Sold Out'
                          : _event['registeredCount'] >= _event['capacity'] * 0.8
                              ? 'Filling Fast'
                              : 'Spots Available',
                      style: TextStyle(
                        color: _event['registeredCount'] >= _event['capacity'] * 0.8
                            ? Colors.red
                            : Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 20,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dateFormat.format(_event['date']),
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (_event['date'].day != _event['endDate'].day)
                          Text(
                            'to ${dateFormat.format(_event['endDate'])}',
                            style: theme.textTheme.bodyMedium,
                          ),
                        Text(
                          '${timeFormat.format(_event['date'])} - ${timeFormat.format(_event['date'].add(const Duration(hours: 8)))}',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 20,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _event['location'],
                      style: theme.textTheme.bodyLarge,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.business,
                    size: 20,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Organized by ${_event['organizer']?['name'] ?? ''}',
                      style: theme.textTheme.bodyLarge,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text(
                    _event['isFree'] ? 'Free' : '₹${_event['price'].toStringAsFixed(0)}',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  if (!_event['isFree']) ...[  
                    const SizedBox(width: 8),
                    Text(
                      'per person',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                  const Spacer(),
                  Text(
                    '${_event['registeredCount']}/${_event['capacity']}',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'registered',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ],
          ),
        ),
      ).animate()
        .fade(duration: 400.ms)
        .slideY(begin: 0.1, end: 0, duration: 400.ms),
    );
  }
  
  Widget _buildRegistrationButton(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _event['registeredCount'] >= _event['capacity'] ? null : _toggleRegistration,
          style: ElevatedButton.styleFrom(
            backgroundColor: _isRegistered ? Colors.red : theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            disabledBackgroundColor: theme.colorScheme.onSurface.withOpacity(0.12),
            disabledForegroundColor: theme.colorScheme.onSurface.withOpacity(0.38),
          ),
          child: _isRegistering
              ? SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: theme.colorScheme.onPrimary,
                  ),
                )
              : Text(
                  _event['registeredCount'] >= _event['capacity']
                      ? 'SOLD OUT'
                      : _isRegistered
                          ? 'CANCEL REGISTRATION'
                          : 'REGISTER NOW',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
        ),
      ).animate()
        .fade(duration: 400.ms, delay: 100.ms)
        .slideY(begin: 0.1, end: 0, duration: 400.ms),
    );
  }
  
  Widget _buildTabBar(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        labelColor: theme.colorScheme.primary,
        unselectedLabelColor: theme.colorScheme.onSurface.withOpacity(0.7),
        indicatorColor: theme.colorScheme.primary,
        indicatorWeight: 3,
        tabs: const [
          Tab(text: 'About'),
          Tab(text: 'Schedule'),
          Tab(text: 'Speakers'),
          Tab(text: 'Location'),
          Tab(text: 'FAQs'),
        ],
      ).animate()
        .fade(duration: 400.ms, delay: 200.ms),
    );
  }
  
  Widget _buildAboutTab(ThemeData theme) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'About',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _event['description'],
            style: theme.textTheme.bodyLarge?.copyWith(
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Organizer',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                child: Image.asset(
                  _event['organizer']?['logo'] ?? '',
                  width: 40,
                  height: 40,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.business,
                      size: 30,
                      color: theme.colorScheme.primary,
                    );
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _event['organizer']?['name'] ?? '',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _event['organizer']?['description'] ?? '',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Tags',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(
              _event['tags'].length,
              (index) => Chip(
                label: Text(_event['tags'][index]),
                backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                side: BorderSide.none,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Sponsors',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildSponsorsList(theme),
        ],
      ),
    ).animate()
      .fade(duration: 400.ms, delay: 300.ms);
  }
  
  Widget _buildSponsorsList(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(
        _event['sponsors']?.length ?? 0,
        (index) => Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: theme.colorScheme.outline.withOpacity(0.2),
                  ),
                ),
                child: Center(
                  child: Image.asset(
                    _event['sponsors']?[index]?['logo'] ?? '',
                    width: 40,
                    height: 40,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.business,
                        size: 30,
                        color: theme.colorScheme.primary,
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _event['sponsors']?[index]?['name'] ?? '',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getSponsorLevelColor(_event['sponsors']?[index]?['level'] ?? '').withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _event['sponsors']?[index]?['level'] ?? '',
                        style: TextStyle(
                          color: _getSponsorLevelColor(_event['sponsors']?[index]?['level'] ?? ''),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Color _getSponsorLevelColor(String level) {
    switch (level) {
      case 'Platinum':
        return Colors.blueGrey;
      case 'Gold':
        return Colors.amber.shade700;
      case 'Silver':
        return Colors.grey.shade500;
      default:
        return Colors.blue;
    }
  }
  
  Widget _buildScheduleTab(ThemeData theme) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16.0),
      itemCount: _event['schedule'].length,
      itemBuilder: (context, dayIndex) {
        final day = _event['schedule'][dayIndex];
        final dateFormat = DateFormat('E, MMM d');
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    day['day'],
                    style: TextStyle(
                      color: theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  dateFormat.format(day['date']),
                  style: theme.textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...List.generate(
              day['sessions'].length,
              (sessionIndex) {
                final session = day['sessions'][sessionIndex];
                final bool isLast = sessionIndex == day['sessions'].length - 1;
                
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        if (!isLast)
                          Container(
                            width: 2,
                            height: 80,
                            color: theme.colorScheme.primary.withOpacity(0.3),
                          ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            session['time'],
                            style: TextStyle(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            session['title'],
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (session.containsKey('speaker'))
                            Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text(
                                'Speaker: ${session['speaker']}',
                                style: theme.textTheme.bodyMedium,
                              ),
                            ),
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0, bottom: 16.0),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  size: 16,
                                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  session['location'],
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
            if (dayIndex < _event['schedule'].length - 1)
              const Divider(height: 32),
          ],
        );
      },
    ).animate()
      .fade(duration: 400.ms, delay: 300.ms);
  }
  
  Widget _buildSpeakersTab(ThemeData theme) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16.0),
      itemCount: _event['speakers'].length,
      itemBuilder: (context, index) {
        final speaker = _event['speakers'][index];
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Card(
            elevation: 0,
            color: theme.colorScheme.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: theme.colorScheme.outline.withOpacity(0.2),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                    backgroundImage: AssetImage(speaker['image']),
                    onBackgroundImageError: (exception, stackTrace) {},
                    child: Icon(
                      Icons.person,
                      size: 40,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          speaker['name'],
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          speaker['designation'],
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          speaker['bio'],
                          style: theme.textTheme.bodyMedium?.copyWith(
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ).animate()
            .fade(duration: 400.ms, delay: 100.ms * index)
            .slideY(begin: 0.1, end: 0, duration: 400.ms),
        );
      },
    );
  }
  
  Widget _buildLocationTab(ThemeData theme) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: theme.colorScheme.outline.withOpacity(0.2),
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.map,
                    size: 64,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Map view coming soon',
                    style: theme.textTheme.titleMedium,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Venue Details',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 0,
            color: theme.colorScheme.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: theme.colorScheme.outline.withOpacity(0.2),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _event['location'],
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(
                        Icons.directions,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Get Directions',
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  Text(
                    'Parking Information',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Free parking is available at the venue. Additional paid parking is available at nearby parking lots.',
                    style: TextStyle(height: 1.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Public Transportation',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'The venue is accessible by bus routes 101, 102, and 103. The nearest metro station is Central Station, which is a 10-minute walk from the venue.',
                    style: TextStyle(height: 1.5),
                  ),
                ],
              ),
            ),
          ).animate()
            .fade(duration: 400.ms, delay: 100.ms)
            .slideY(begin: 0.1, end: 0, duration: 400.ms),
        ],
      ),
    );
  }
  
  Widget _buildFAQsTab(ThemeData theme) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16.0),
      itemCount: _event['faqs'].length,
      itemBuilder: (context, index) {
        final faq = _event['faqs'][index];
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Card(
            elevation: 0,
            color: theme.colorScheme.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: theme.colorScheme.outline.withOpacity(0.2),
              ),
            ),
            child: Theme(
              data: Theme.of(context).copyWith(
                dividerColor: Colors.transparent,
              ),
              child: ExpansionTile(
                title: Text(
                  faq['question'],
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                iconColor: theme.colorScheme.primary,
                childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                children: [
                  Text(
                    faq['answer'],
                    style: theme.textTheme.bodyMedium?.copyWith(
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ).animate()
            .fade(duration: 400.ms, delay: 100.ms * index)
            .slideY(begin: 0.1, end: 0, duration: 400.ms),
        );
      },
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  final String userId;
  
  const ProfileScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isEditing = false;
  bool _isSaving = false;
  
  // Mock user data
  final Map<String, dynamic> _userData = {
    'id': 'USR001',
    'name': 'Rahul Sharma',
    'email': 'rahul.sharma@example.com',
    'phone': '+91 9876543210',
    'role': 'Student',
    'department': 'Computer Science',
    'year': '3rd Year',
    'college': 'ABC Engineering College',
    'bio': 'Passionate computer science student with interests in AI, mobile development, and cybersecurity. Looking to connect with like-minded individuals and explore opportunities in the tech industry.',
    'profileImage': null,
    'skills': ['Flutter', 'Python', 'Java', 'Machine Learning', 'Web Development'],
    'interests': ['Artificial Intelligence', 'Mobile App Development', 'Cybersecurity', 'Cloud Computing'],
    'socialLinks': {
      'github': 'github.com/rahulsharma',
      'linkedin': 'linkedin.com/in/rahulsharma',
      'twitter': 'twitter.com/rahulsharma',
    },
    'events': [
      {
        'id': 'EVT001',
        'name': 'Annual Tech Symposium 2023',
        'date': '15 Aug 2023',
        'role': 'Participant',
        'status': 'Registered',
      },
      {
        'id': 'EVT002',
        'name': 'Hackathon 2023',
        'date': '10 Sep 2023',
        'role': 'Participant',
        'status': 'Completed',
      },
      {
        'id': 'EVT003',
        'name': 'Workshop on Flutter',
        'date': '25 Jul 2023',
        'role': 'Participant',
        'status': 'Completed',
      },
    ],
    'achievements': [
      {
        'id': 'ACH001',
        'title': '1st Prize in College Hackathon',
        'description': 'Won first prize in the annual college hackathon for developing an innovative solution for healthcare.',
        'date': 'May 2023',
        'issuer': 'ABC Engineering College',
      },
      {
        'id': 'ACH002',
        'title': 'Best Project Award',
        'description': 'Received the best project award for the final year project on AI-based healthcare system.',
        'date': 'Apr 2023',
        'issuer': 'Department of Computer Science',
      },
    ],
    'certificates': [
      {
        'id': 'CERT001',
        'title': 'Flutter Development Bootcamp',
        'issuer': 'Udemy',
        'date': 'Jun 2023',
        'credentialUrl': 'udemy.com/certificate/flutter-bootcamp',
      },
      {
        'id': 'CERT002',
        'title': 'Machine Learning Specialization',
        'issuer': 'Coursera',
        'date': 'Mar 2023',
        'credentialUrl': 'coursera.org/certificate/ml-specialization',
      },
      {
        'id': 'CERT003',
        'title': 'Web Development Bootcamp',
        'issuer': 'Udemy',
        'date': 'Jan 2023',
        'credentialUrl': 'udemy.com/certificate/web-dev-bootcamp',
      },
    ],
  };
  
  // Form controllers
  late TextEditingController _nameController;
  late TextEditingController _bioController;
  late TextEditingController _phoneController;
  late TextEditingController _departmentController;
  late TextEditingController _yearController;
  late TextEditingController _collegeController;
  late TextEditingController _githubController;
  late TextEditingController _linkedinController;
  late TextEditingController _twitterController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Initialize controllers with user data
    _nameController = TextEditingController(text: _userData['name']);
    _bioController = TextEditingController(text: _userData['bio']);
    _phoneController = TextEditingController(text: _userData['phone']);
    _departmentController = TextEditingController(text: _userData['department']);
    _yearController = TextEditingController(text: _userData['year']);
    _collegeController = TextEditingController(text: _userData['college']);
    _githubController = TextEditingController(text: _userData['socialLinks']['github']);
    _linkedinController = TextEditingController(text: _userData['socialLinks']['linkedin']);
    _twitterController = TextEditingController(text: _userData['socialLinks']['twitter']);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _bioController.dispose();
    _phoneController.dispose();
    _departmentController.dispose();
    _yearController.dispose();
    _collegeController.dispose();
    _githubController.dispose();
    _linkedinController.dispose();
    _twitterController.dispose();
    super.dispose();
  }
  
  void _toggleEditMode() {
    setState(() {
      _isEditing = !_isEditing;
      
      if (!_isEditing) {
        // Reset controllers to original values if canceled
        _nameController.text = _userData['name'];
        _bioController.text = _userData['bio'];
        _phoneController.text = _userData['phone'];
        _departmentController.text = _userData['department'];
        _yearController.text = _userData['year'];
        _collegeController.text = _userData['college'];
        _githubController.text = _userData['socialLinks']['github'];
        _linkedinController.text = _userData['socialLinks']['linkedin'];
        _twitterController.text = _userData['socialLinks']['twitter'];
      }
    });
  }
  
  void _saveProfile() {
    setState(() {
      _isSaving = true;
    });
    
    // Simulate API call
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        // Update user data with form values
        _userData['name'] = _nameController.text;
        _userData['bio'] = _bioController.text;
        _userData['phone'] = _phoneController.text;
        _userData['department'] = _departmentController.text;
        _userData['year'] = _yearController.text;
        _userData['college'] = _collegeController.text;
        _userData['socialLinks']['github'] = _githubController.text;
        _userData['socialLinks']['linkedin'] = _linkedinController.text;
        _userData['socialLinks']['twitter'] = _twitterController.text;
        
        _isSaving = false;
        _isEditing = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully!'),
          duration: Duration(seconds: 2),
        ),
      );
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: _toggleEditMode,
              tooltip: 'Edit Profile',
            ),
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: _toggleEditMode,
              tooltip: 'Cancel',
            ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // Profile Header
            _buildProfileHeader(theme, isDarkMode),
            
            // Tabs
            Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TabBar(
                controller: _tabController,
                labelColor: theme.colorScheme.primary,
                unselectedLabelColor: theme.colorScheme.onSurface.withOpacity(0.6),
                indicatorColor: theme.colorScheme.primary,
                indicatorSize: TabBarIndicatorSize.label,
                tabs: const [
                  Tab(text: 'Events'),
                  Tab(text: 'Achievements'),
                  Tab(text: 'Certificates'),
                ],
              ),
            ).animate()
              .fade(duration: 400.ms, delay: 200.ms)
              .slideY(begin: 0.1, end: 0, duration: 400.ms),
            
            // Tab Content
            SizedBox(
              height: 500, // Fixed height for tab content
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Events Tab
                  _buildEventsTab(theme),
                  
                  // Achievements Tab
                  _buildAchievementsTab(theme),
                  
                  // Certificates Tab
                  _buildCertificatesTab(theme),
                ],
              ),
            ).animate()
              .fade(duration: 400.ms, delay: 300.ms)
              .slideY(begin: 0.1, end: 0, duration: 400.ms),
          ],
        ),
      ),
      floatingActionButton: _isEditing
          ? FloatingActionButton.extended(
              onPressed: _isSaving ? null : _saveProfile,
              icon: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.save),
              label: const Text('SAVE'),
            ).animate()
              .fade(duration: 300.ms)
              .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1), duration: 300.ms)
          : null,
    );
  }
  
  Widget _buildProfileHeader(ThemeData theme, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.1),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Profile Image
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.2),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: theme.colorScheme.primary,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    _userData['name'].substring(0, 1),
                    style: theme.textTheme.displayMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              if (_isEditing)
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
            ],
          ).animate()
            .fade(duration: 400.ms)
            .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1), duration: 400.ms),
          const SizedBox(height: 16),
          
          // Basic Info
          _isEditing
              ? _buildEditableBasicInfo(theme)
              : _buildBasicInfo(theme),
          
          const SizedBox(height: 24),
          
          // Bio
          _isEditing
              ? _buildEditableBio(theme)
              : _buildBio(theme),
          
          const SizedBox(height: 24),
          
          // Skills & Interests
          _isEditing
              ? _buildEditableSkillsInterests(theme)
              : _buildSkillsInterests(theme),
          
          const SizedBox(height: 24),
          
          // Social Links
          _isEditing
              ? _buildEditableSocialLinks(theme)
              : _buildSocialLinks(theme),
        ],
      ),
    ).animate()
      .fade(duration: 400.ms)
      .slideY(begin: 0.1, end: 0, duration: 400.ms);
  }
  
  Widget _buildBasicInfo(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          _userData['name'],
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          _userData['email'],
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.primary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          _userData['phone'],
          style: theme.textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            _userData['role'],
            style: theme.textTheme.labelLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${_userData['department']} • ${_userData['year']}',
          style: theme.textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          _userData['college'],
          style: theme.textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
  
  Widget _buildEditableBasicInfo(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _nameController,
          decoration: InputDecoration(
            labelText: 'Name',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            prefixIcon: const Icon(Icons.person),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _phoneController,
          decoration: InputDecoration(
            labelText: 'Phone',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            prefixIcon: const Icon(Icons.phone),
          ),
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _departmentController,
          decoration: InputDecoration(
            labelText: 'Department',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            prefixIcon: const Icon(Icons.business),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _yearController,
          decoration: InputDecoration(
            labelText: 'Year',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            prefixIcon: const Icon(Icons.calendar_today),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _collegeController,
          decoration: InputDecoration(
            labelText: 'College',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            prefixIcon: const Icon(Icons.school),
          ),
        ),
      ],
    );
  }
  
  Widget _buildBio(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bio',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _userData['bio'],
          style: theme.textTheme.bodyLarge?.copyWith(
            height: 1.5,
          ),
        ),
      ],
    );
  }
  
  Widget _buildEditableBio(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bio',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _bioController,
          decoration: InputDecoration(
            hintText: 'Tell us about yourself',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          maxLines: 4,
        ),
      ],
    );
  }
  
  Widget _buildSkillsInterests(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Skills',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: (_userData['skills'] as List).map<Widget>((skill) {
            return Chip(
              label: Text(skill),
              backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
              side: BorderSide(
                color: theme.colorScheme.primary.withOpacity(0.3),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        Text(
          'Interests',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: (_userData['interests'] as List).map<Widget>((interest) {
            return Chip(
              label: Text(interest),
              backgroundColor: theme.colorScheme.secondary.withOpacity(0.1),
              side: BorderSide(
                color: theme.colorScheme.secondary.withOpacity(0.3),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
  
  Widget _buildEditableSkillsInterests(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Skills & Interests',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Skills and interests editing coming soon',
          style: theme.textTheme.bodyMedium,
        ),
        // In a real app, we would implement a UI for adding/removing skills and interests
      ],
    );
  }
  
  Widget _buildSocialLinks(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Social Links',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildSocialButton(
              icon: Icons.code,
              label: 'GitHub',
              url: _userData['socialLinks']['github'],
              theme: theme,
            ),
            _buildSocialButton(
              icon: Icons.work,
              label: 'LinkedIn',
              url: _userData['socialLinks']['linkedin'],
              theme: theme,
            ),
            _buildSocialButton(
              icon: Icons.chat,
              label: 'Twitter',
              url: _userData['socialLinks']['twitter'],
              theme: theme,
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildEditableSocialLinks(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Social Links',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _githubController,
          decoration: InputDecoration(
            labelText: 'GitHub',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            prefixIcon: const Icon(Icons.code),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _linkedinController,
          decoration: InputDecoration(
            labelText: 'LinkedIn',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            prefixIcon: const Icon(Icons.work),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _twitterController,
          decoration: InputDecoration(
            labelText: 'Twitter',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            prefixIcon: const Icon(Icons.chat),
          ),
        ),
      ],
    );
  }
  
  Widget _buildSocialButton({
    required IconData icon,
    required String label,
    required String url,
    required ThemeData theme,
  }) {
    return Column(
      children: [
        IconButton(
          onPressed: () {
            // TODO: Open URL
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Opening $url coming soon')),
            );
          },
          icon: Icon(
            icon,
            color: theme.colorScheme.primary,
            size: 28,
          ),
          style: IconButton.styleFrom(
            backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
            padding: const EdgeInsets.all(12),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.labelMedium,
        ),
      ],
    );
  }
  
  Widget _buildEventsTab(ThemeData theme) {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount: (_userData['events'] as List).length,
      itemBuilder: (context, index) {
        final event = _userData['events'][index];
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            title: Text(
              event['name'],
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                      event['date'],
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.person,
                      size: 16,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Role: ${event['role']}',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(event['status'], theme).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: _getStatusColor(event['status'], theme).withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    event['status'],
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: _getStatusColor(event['status'], theme),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.arrow_forward_ios, size: 16),
              onPressed: () {
                // TODO: Navigate to event details
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Navigating to ${event['name']} details coming soon')),
                );
              },
            ),
          ),
        ).animate()
          .fade(duration: 400.ms, delay: (index * 100).ms)
          .slideX(begin: 0.1, end: 0, duration: 400.ms);
      },
    );
  }
  
  Color _getStatusColor(String status, ThemeData theme) {
    switch (status) {
      case 'Registered':
        return Colors.blue;
      case 'Completed':
        return Colors.green;
      case 'Cancelled':
        return Colors.red;
      default:
        return theme.colorScheme.primary;
    }
  }
  
  Widget _buildAchievementsTab(ThemeData theme) {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount: (_userData['achievements'] as List).length,
      itemBuilder: (context, index) {
        final achievement = _userData['achievements'][index];
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.emoji_events,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            achievement['title'],
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${achievement['issuer']} • ${achievement['date']}',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  achievement['description'],
                  style: theme.textTheme.bodyMedium?.copyWith(
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ).animate()
          .fade(duration: 400.ms, delay: (index * 100).ms)
          .slideX(begin: 0.1, end: 0, duration: 400.ms);
      },
    );
  }
  
  Widget _buildCertificatesTab(ThemeData theme) {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount: (_userData['certificates'] as List).length,
      itemBuilder: (context, index) {
        final certificate = _userData['certificates'][index];
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.secondary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.workspace_premium,
                color: theme.colorScheme.secondary,
              ),
            ),
            title: Text(
              certificate['title'],
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  '${certificate['issuer']} • ${certificate['date']}',
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: () {
                        // TODO: View certificate
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('View certificate coming soon')),
                        );
                      },
                      icon: const Icon(Icons.visibility, size: 16),
                      label: const Text('VIEW'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed: () {
                        // TODO: Download certificate
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Download certificate coming soon')),
                        );
                      },
                      icon: const Icon(Icons.download, size: 16),
                      label: const Text('DOWNLOAD'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ).animate()
          .fade(duration: 400.ms, delay: (index * 100).ms)
          .slideX(begin: 0.1, end: 0, duration: 400.ms);
      },
    );
  }
}
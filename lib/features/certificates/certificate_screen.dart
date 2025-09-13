import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_theme.dart';

class CertificateScreen extends StatefulWidget {
  const CertificateScreen({Key? key}) : super(key: key);

  @override
  State<CertificateScreen> createState() => _CertificateScreenState();
}

class _CertificateScreenState extends State<CertificateScreen> {
  final _searchController = TextEditingController();
  bool _isSearching = false;
  String _searchQuery = '';
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Recent', 'Oldest', 'Event', 'Course'];
  
  // Mock certificate data
  final List<Map<String, dynamic>> _certificates = [
    {
      'id': 1,
      'title': 'Flutter Development Masterclass',
      'issuer': 'Google Developers',
      'date': '2023-05-15',
      'type': 'Course',
      'imageUrl': 'assets/images/certificate1.png',
      'description': 'Awarded for completing the Flutter Development Masterclass with distinction.',
      'skills': ['Flutter', 'Dart', 'Mobile Development', 'UI/UX'],
    },
    {
      'id': 2,
      'title': 'Tech Innovators Summit 2023',
      'issuer': 'Tech Innovators Association',
      'date': '2023-07-22',
      'type': 'Event',
      'imageUrl': 'assets/images/certificate2.png',
      'description': 'Certificate of participation in the Tech Innovators Summit 2023.',
      'skills': ['Networking', 'Innovation', 'Technology Trends'],
    },
    {
      'id': 3,
      'title': 'UI/UX Design Principles',
      'issuer': 'Design Academy',
      'date': '2023-03-10',
      'type': 'Course',
      'imageUrl': 'assets/images/certificate3.png',
      'description': 'Awarded for mastering UI/UX design principles and best practices.',
      'skills': ['UI Design', 'UX Research', 'Prototyping', 'Figma'],
    },
    {
      'id': 4,
      'title': 'Hackathon 2023 - First Place',
      'issuer': 'TechFest Organization',
      'date': '2023-08-05',
      'type': 'Event',
      'imageUrl': 'assets/images/certificate4.png',
      'description': 'Awarded first place in the annual Hackathon for developing an innovative solution.',
      'skills': ['Problem Solving', 'Teamwork', 'Coding', 'Innovation'],
    },
    {
      'id': 5,
      'title': 'Advanced Data Structures',
      'issuer': 'Computer Science Institute',
      'date': '2023-02-28',
      'type': 'Course',
      'imageUrl': 'assets/images/certificate5.png',
      'description': 'Certificate for completing the advanced data structures course with excellence.',
      'skills': ['Algorithms', 'Data Structures', 'Problem Solving', 'Optimization'],
    },
  ];
  
  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  List<Map<String, dynamic>> get _filteredCertificates {
    return _certificates.where((certificate) {
      // Apply search filter
      final matchesSearch = _searchQuery.isEmpty ||
          certificate['title'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
          certificate['issuer'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
          certificate['description'].toLowerCase().contains(_searchQuery.toLowerCase());
      
      // Apply category filter
      final matchesFilter = _selectedFilter == 'All' ||
          (_selectedFilter == 'Recent' && DateTime.parse(certificate['date']).isAfter(DateTime.now().subtract(const Duration(days: 180)))) ||
          (_selectedFilter == 'Oldest' && DateTime.parse(certificate['date']).isBefore(DateTime.now().subtract(const Duration(days: 180)))) ||
          _selectedFilter == certificate['type'];
      
      return matchesSearch && matchesFilter;
    }).toList();
  }
  
  void _showCertificateDetails(Map<String, dynamic> certificate) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildCertificateDetailsSheet(certificate),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Search certificates...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(
                    color: isDarkMode ? Colors.white70 : Colors.black54,
                  ),
                ),
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              )
            : const Text('My Certificates'),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                }
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter chips
          SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: _filters.length,
              itemBuilder: (context, index) {
                final filter = _filters[index];
                final isSelected = _selectedFilter == filter;
                
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(filter),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedFilter = filter;
                      });
                    },
                    backgroundColor: theme.colorScheme.surface,
                    selectedColor: theme.colorScheme.primary.withOpacity(0.2),
                    checkmarkColor: theme.colorScheme.primary,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Certificates list
          Expanded(
            child: _filteredCertificates.isEmpty
                ? _buildEmptyState(theme)
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredCertificates.length,
                    itemBuilder: (context, index) {
                      final certificate = _filteredCertificates[index];
                      return _buildCertificateCard(certificate, theme, index);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Certificate verification coming soon')),
          );
        },
        child: const Icon(Icons.qr_code_scanner),
      ).animate()
        .scale(duration: 300.ms, curve: Curves.easeOut)
        .fade(duration: 300.ms),
    );
  }
  
  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.workspace_premium,
            size: 80,
            color: theme.colorScheme.primary.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No certificates found',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty
                ? 'Try a different search term'
                : 'Participate in events to earn certificates',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ).animate()
        .fade(duration: 400.ms)
        .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1), duration: 400.ms),
    );
  }
  
  Widget _buildCertificateCard(Map<String, dynamic> certificate, ThemeData theme, int index) {
    final formattedDate = DateFormat.yMMMd().format(DateTime.parse(certificate['date']));
    
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showCertificateDetails(certificate),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Icon(
                        certificate['type'] == 'Event'
                            ? Icons.event
                            : Icons.school,
                        color: theme.colorScheme.primary,
                        size: 30,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          certificate['title'],
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          certificate['issuer'],
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Issued on $formattedDate',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildActionButton(
                    icon: Icons.visibility,
                    label: 'View',
                    onTap: () => _showCertificateDetails(certificate),
                    theme: theme,
                  ),
                  _buildActionButton(
                    icon: Icons.download,
                    label: 'Download',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Download feature coming soon')),
                      );
                    },
                    theme: theme,
                  ),
                  _buildActionButton(
                    icon: Icons.share,
                    label: 'Share',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Share feature coming soon')),
                      );
                    },
                    theme: theme,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ).animate()
      .fade(duration: 400.ms, delay: (index * 100).ms)
      .slideY(begin: 0.1, end: 0, duration: 400.ms);
  }
  
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required ThemeData theme,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: theme.colorScheme.primary,
              size: 20,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildCertificateDetailsSheet(Map<String, dynamic> certificate) {
    final theme = Theme.of(context);
    final formattedDate = DateFormat.yMMMd().format(DateTime.parse(certificate['date']));
    
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withOpacity(0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          
          // Certificate image
          Expanded(
            flex: 3,
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.primary.withOpacity(0.2),
                  width: 2,
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.workspace_premium,
                      size: 80,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'CERTIFICATE',
                      style: theme.textTheme.titleLarge?.copyWith(
                        letterSpacing: 2,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'This certifies that',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'John Doe',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'has successfully completed',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        certificate['title'],
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Issued by ${certificate['issuer']} on $formattedDate',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Certificate details
          Expanded(
            flex: 2,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Certificate Details',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow(
                    icon: Icons.title,
                    label: 'Title',
                    value: certificate['title'],
                    theme: theme,
                  ),
                  _buildDetailRow(
                    icon: Icons.business,
                    label: 'Issuer',
                    value: certificate['issuer'],
                    theme: theme,
                  ),
                  _buildDetailRow(
                    icon: Icons.calendar_today,
                    label: 'Issue Date',
                    value: formattedDate,
                    theme: theme,
                  ),
                  _buildDetailRow(
                    icon: Icons.category,
                    label: 'Type',
                    value: certificate['type'],
                    theme: theme,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Description',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    certificate['description'],
                    style: theme.textTheme.bodyMedium?.copyWith(
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Skills',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: (certificate['skills'] as List).map((skill) {
                      return Chip(
                        label: Text(skill),
                        backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                        labelStyle: TextStyle(
                          color: theme.colorScheme.primary,
                          fontSize: 12,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Download feature coming soon')),
                            );
                          },
                          icon: const Icon(Icons.download),
                          label: const Text('DOWNLOAD'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Share feature coming soon')),
                            );
                          },
                          icon: const Icon(Icons.share),
                          label: const Text('SHARE'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
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
    ).animate()
      .fade(duration: 300.ms)
      .slideY(begin: 0.1, end: 0, duration: 300.ms);
  }
  
  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    required ThemeData theme,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
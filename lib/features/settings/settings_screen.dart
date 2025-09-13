import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Settings state
  bool _isDarkMode = false;
  double _textSize = 1.0; // 1.0 is normal, 0.8 is small, 1.2 is large
  bool _notificationsEnabled = true;
  bool _emailNotifications = true;
  bool _pushNotifications = true;
  bool _eventReminders = true;
  String _selectedLanguage = 'English';
  bool _locationEnabled = true;
  bool _dataCollection = true;
  bool _isSaving = false;
  
  // Language options
  final List<String> _languages = [
    'English',
    'Hindi',
    'Spanish',
    'French',
    'German',
    'Chinese',
    'Japanese',
    'Arabic',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              _showAboutDialog(context);
            },
            tooltip: 'About',
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Appearance Section
              _buildSectionHeader('Appearance', Icons.palette, theme),
              _buildDarkModeToggle(theme),
              _buildTextSizeSlider(theme),
              const SizedBox(height: 24),
              
              // Notifications Section
              _buildSectionHeader('Notifications', Icons.notifications, theme),
              _buildNotificationsToggle(theme),
              if (_notificationsEnabled) ..._buildNotificationOptions(theme),
              const SizedBox(height: 24),
              
              // Language Section
              _buildSectionHeader('Language', Icons.language, theme),
              _buildLanguageDropdown(theme),
              const SizedBox(height: 24),
              
              // Privacy & Security Section
              _buildSectionHeader('Privacy & Security', Icons.security, theme),
              _buildPrivacyOptions(theme),
              const SizedBox(height: 24),
              
              // About Section
              _buildSectionHeader('About', Icons.info, theme),
              _buildAboutOptions(theme),
              const SizedBox(height: 32),
              
              // Save Button
              _buildSaveButton(theme),
              const SizedBox(height: 16),
              
              // Logout Button
              _buildLogoutButton(theme),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildSectionHeader(String title, IconData icon, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(
            icon,
            color: theme.colorScheme.primary,
            size: 24,
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    ).animate()
      .fade(duration: 400.ms)
      .slideX(begin: -0.1, end: 0, duration: 400.ms);
  }
  
  Widget _buildDarkModeToggle(ThemeData theme) {
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  _isDarkMode ? Icons.dark_mode : Icons.light_mode,
                  color: _isDarkMode ? Colors.amber : Colors.orange,
                ),
                const SizedBox(width: 12),
                Text(
                  'Dark Mode',
                  style: theme.textTheme.titleMedium,
                ),
              ],
            ),
            Switch(
              value: _isDarkMode,
              onChanged: (value) {
                setState(() {
                  _isDarkMode = value;
                });
                // TODO: Implement theme change
              },
              activeColor: theme.colorScheme.primary,
            ),
          ],
        ),
      ),
    ).animate()
      .fade(duration: 400.ms, delay: 100.ms)
      .slideY(begin: 0.1, end: 0, duration: 400.ms);
  }
  
  Widget _buildTextSizeSlider(ThemeData theme) {
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.text_fields),
                const SizedBox(width: 12),
                Text(
                  'Text Size',
                  style: theme.textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('A', style: TextStyle(fontSize: 14)),
                Expanded(
                  child: Slider(
                    value: _textSize,
                    min: 0.8,
                    max: 1.2,
                    divisions: 4,
                    label: _getTextSizeLabel(),
                    onChanged: (value) {
                      setState(() {
                        _textSize = value;
                      });
                      // TODO: Implement text size change
                    },
                    activeColor: theme.colorScheme.primary,
                  ),
                ),
                const Text('A', style: TextStyle(fontSize: 24)),
              ],
            ),
          ],
        ),
      ),
    ).animate()
      .fade(duration: 400.ms, delay: 200.ms)
      .slideY(begin: 0.1, end: 0, duration: 400.ms);
  }
  
  String _getTextSizeLabel() {
    if (_textSize <= 0.8) return 'Small';
    if (_textSize >= 1.2) return 'Large';
    if (_textSize >= 1.1) return 'Medium Large';
    if (_textSize <= 0.9) return 'Medium Small';
    return 'Medium';
  }
  
  Widget _buildNotificationsToggle(ThemeData theme) {
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  Icons.notifications,
                  color: _notificationsEnabled ? theme.colorScheme.primary : theme.colorScheme.onSurface.withOpacity(0.5),
                ),
                const SizedBox(width: 12),
                Text(
                  'Enable Notifications',
                  style: theme.textTheme.titleMedium,
                ),
              ],
            ),
            Switch(
              value: _notificationsEnabled,
              onChanged: (value) {
                setState(() {
                  _notificationsEnabled = value;
                });
              },
              activeColor: theme.colorScheme.primary,
            ),
          ],
        ),
      ),
    ).animate()
      .fade(duration: 400.ms, delay: 300.ms)
      .slideY(begin: 0.1, end: 0, duration: 400.ms);
  }
  
  List<Widget> _buildNotificationOptions(ThemeData theme) {
    return [
      Card(
        elevation: 0,
        color: theme.colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: theme.colorScheme.outline.withOpacity(0.2),
          ),
        ),
        child: Column(
          children: [
            _buildNotificationOption(
              'Email Notifications',
              Icons.email,
              _emailNotifications,
              (value) {
                setState(() {
                  _emailNotifications = value;
                });
              },
              theme,
            ),
            Divider(height: 1, color: theme.colorScheme.outline.withOpacity(0.2)),
            _buildNotificationOption(
              'Push Notifications',
              Icons.notifications_active,
              _pushNotifications,
              (value) {
                setState(() {
                  _pushNotifications = value;
                });
              },
              theme,
            ),
            Divider(height: 1, color: theme.colorScheme.outline.withOpacity(0.2)),
            _buildNotificationOption(
              'Event Reminders',
              Icons.event,
              _eventReminders,
              (value) {
                setState(() {
                  _eventReminders = value;
                });
              },
              theme,
            ),
          ],
        ),
      ).animate()
        .fade(duration: 400.ms, delay: 400.ms)
        .slideY(begin: 0.1, end: 0, duration: 400.ms),
    ];
  }
  
  Widget _buildNotificationOption(
    String title,
    IconData icon,
    bool value,
    Function(bool) onChanged,
    ThemeData theme,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: value ? theme.colorScheme.primary : theme.colorScheme.onSurface.withOpacity(0.5),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: theme.textTheme.bodyLarge,
              ),
            ],
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: theme.colorScheme.primary,
          ),
        ],
      ),
    );
  }
  
  Widget _buildLanguageDropdown(ThemeData theme) {
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.translate),
                const SizedBox(width: 12),
                Text(
                  'Select Language',
                  style: theme.textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedLanguage,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              items: _languages.map((language) {
                return DropdownMenuItem<String>(
                  value: language,
                  child: Text(language),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedLanguage = value;
                  });
                  // TODO: Implement language change
                }
              },
            ),
          ],
        ),
      ),
    ).animate()
      .fade(duration: 400.ms, delay: 500.ms)
      .slideY(begin: 0.1, end: 0, duration: 400.ms);
  }
  
  Widget _buildPrivacyOptions(ThemeData theme) {
    return Card(
      elevation: 0,
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          _buildPrivacyOption(
            'Location Services',
            Icons.location_on,
            'Allow the app to access your location',
            _locationEnabled,
            (value) {
              setState(() {
                _locationEnabled = value;
              });
            },
            theme,
          ),
          Divider(height: 1, color: theme.colorScheme.outline.withOpacity(0.2)),
          _buildPrivacyOption(
            'Data Collection',
            Icons.analytics,
            'Allow the app to collect usage data for improving services',
            _dataCollection,
            (value) {
              setState(() {
                _dataCollection = value;
              });
            },
            theme,
          ),
          Divider(height: 1, color: theme.colorScheme.outline.withOpacity(0.2)),
          ListTile(
            leading: const Icon(Icons.delete),
            title: Text('Delete Account', style: theme.textTheme.bodyLarge),
            subtitle: const Text('Permanently delete your account and all data'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // TODO: Implement delete account
              _showDeleteAccountDialog(context);
            },
          ),
        ],
      ),
    ).animate()
      .fade(duration: 400.ms, delay: 600.ms)
      .slideY(begin: 0.1, end: 0, duration: 400.ms);
  }
  
  Widget _buildPrivacyOption(
    String title,
    IconData icon,
    String subtitle,
    bool value,
    Function(bool) onChanged,
    ThemeData theme,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  icon,
                  size: 24,
                  color: value ? theme.colorScheme.primary : theme.colorScheme.onSurface.withOpacity(0.5),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: theme.colorScheme.primary,
          ),
        ],
      ),
    );
  }
  
  Widget _buildAboutOptions(ThemeData theme) {
    return Card(
      elevation: 0,
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.info),
            title: Text('App Version', style: theme.textTheme.bodyLarge),
            subtitle: const Text('1.0.0 (Build 1)'),
          ),
          Divider(height: 1, color: theme.colorScheme.outline.withOpacity(0.2)),
          ListTile(
            leading: const Icon(Icons.description),
            title: Text('Terms of Service', style: theme.textTheme.bodyLarge),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // TODO: Navigate to Terms of Service
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Terms of Service coming soon')),
              );
            },
          ),
          Divider(height: 1, color: theme.colorScheme.outline.withOpacity(0.2)),
          ListTile(
            leading: const Icon(Icons.privacy_tip),
            title: Text('Privacy Policy', style: theme.textTheme.bodyLarge),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // TODO: Navigate to Privacy Policy
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Privacy Policy coming soon')),
              );
            },
          ),
          Divider(height: 1, color: theme.colorScheme.outline.withOpacity(0.2)),
          ListTile(
            leading: const Icon(Icons.help),
            title: Text('Help & Support', style: theme.textTheme.bodyLarge),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // TODO: Navigate to Help & Support
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Help & Support coming soon')),
              );
            },
          ),
        ],
      ),
    ).animate()
      .fade(duration: 400.ms, delay: 700.ms)
      .slideY(begin: 0.1, end: 0, duration: 400.ms);
  }
  
  Widget _buildSaveButton(ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isSaving ? null : _saveSettings,
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isSaving
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Text(
                'SAVE SETTINGS',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
      ),
    ).animate()
      .fade(duration: 400.ms, delay: 800.ms)
      .slideY(begin: 0.1, end: 0, duration: 400.ms);
  }
  
  Widget _buildLogoutButton(ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () {
          // TODO: Implement logout
          _showLogoutDialog(context);
        },
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          side: BorderSide(color: theme.colorScheme.error),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          'LOGOUT',
          style: TextStyle(
            color: theme.colorScheme.error,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ).animate()
      .fade(duration: 400.ms, delay: 900.ms)
      .slideY(begin: 0.1, end: 0, duration: 400.ms);
  }
  
  void _saveSettings() {
    setState(() {
      _isSaving = true;
    });
    
    // Simulate API call
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isSaving = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Settings saved successfully!'),
          duration: Duration(seconds: 2),
        ),
      );
    });
  }
  
  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About FusionFiesta'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'FusionFiesta is a comprehensive event management platform designed for college events, providing seamless experiences for students, organizers, and administrators.',
              style: TextStyle(height: 1.5),
            ),
            const SizedBox(height: 16),
            const Text('Version: 1.0.0 (Build 1)'),
            const SizedBox(height: 8),
            const Text('© 2023 FusionFiesta Team'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('CLOSE'),
          ),
        ],
      ),
    );
  }
  
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implement logout logic
              Navigator.of(context).pushReplacementNamed('/login');
            },
            child: const Text('LOGOUT'),
          ),
        ],
      ),
    );
  }
  
  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone and all your data will be permanently deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implement account deletion logic
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Account deletion coming soon'),
                ),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('DELETE'),
          ),
        ],
      ),
    );
  }
}
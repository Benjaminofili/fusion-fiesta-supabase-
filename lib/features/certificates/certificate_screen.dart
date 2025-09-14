import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusion_fiesta/core/services/certificate_service.dart';
import 'package:fusion_fiesta/models/certificate_model.dart';
import '../../core/theme/app_theme.dart';
import '../../storage/hive_manager.dart';
import 'presentation/bloc/certificates_bloc.dart';
import '../../core/services/AppError.dart';
import '../../core/services/auth_service.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../core/services/sync_service.dart';
import '../../supabase_manager.dart';

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

  @override
  void initState() {
    super.initState();
    final user = EnhancedAuthService.getCurrentUser();
    if (user != null) {
      context.read<CertificatesBloc>().add(FetchCertificatesEvent(userId: user.id));
    }
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

  List<CertificateModel> _filteredCertificates(List<CertificateModel> certificates) {
    return certificates.where((certificate) {
      final matchesSearch = _searchQuery.isEmpty ||
          (certificate.eventTitle?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
          (certificate.templateUsed?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
      final matchesFilter = _selectedFilter == 'All' ||
          (_selectedFilter == 'Recent' && certificate.issuedAt.isAfter(DateTime.now().subtract(const Duration(days: 180)))) ||
          (_selectedFilter == 'Oldest' && certificate.issuedAt.isBefore(DateTime.now().subtract(const Duration(days: 180)))) ||
          (_selectedFilter == 'Event' && (certificate.templateUsed?.toLowerCase().contains('event') ?? false)) ||
          (_selectedFilter == 'Course' && (certificate.templateUsed?.toLowerCase().contains('course') ?? false));
      return matchesSearch && matchesFilter;
    }).toList();
  }

  void _showCertificateDetails(CertificateModel certificate) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildCertificateDetailsSheet(certificate),
    );
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

  Widget _buildCertificateDetailsSheet(CertificateModel certificate) {
    final theme = Theme.of(context);
    final formattedDate = DateFormat('MMM d, yyyy').format(certificate.issuedAt);

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 5,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(2.5),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        certificate.eventTitle ?? 'Certificate ${certificate.id}',
                        style: theme.textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 16),
                      _buildDetailRow(
                        icon: Icons.code,
                        label: 'Verification Code',
                        value: certificate.certificateCode,
                        theme: theme,
                      ),
                      _buildDetailRow(
                        icon: Icons.calendar_today,
                        label: 'Issue Date',
                        value: formattedDate,
                        theme: theme,
                      ),
                      if (certificate.templateUsed != null)
                        _buildDetailRow(
                          icon: Icons.category,
                          label: 'Type',
                          value: certificate.templateUsed!,
                          theme: theme,
                        ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _downloadCertificate(certificate.id),
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
                                context.read<CertificatesBloc>().add(ShareCertificateEvent(
                                  certificateId: certificate.id,
                                  platform: 'general',
                                ));
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
              ],
            ),
          ),
        );
      },
    );
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
                  _searchQuery = '';
                }
              });
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _selectedFilter = value;
              });
            },
            itemBuilder: (context) => _filters
                .map((filter) => PopupMenuItem(
              value: filter,
              child: Text(filter),
            ))
                .toList(),
            icon: const Icon(Icons.filter_list),
          ),
        ],
      ),
      body: BlocBuilder<CertificatesBloc, CertificatesState>(
        builder: (context, state) {
          if (state is CertificatesLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is CertificatesError) {
            return Center(child: Text(state.message));
          } else if (state is CertificatesLoaded) {
            final certificates = _filteredCertificates(state.certificates);
            return certificates.isEmpty
                ? const Center(child: Text('No certificates found'))
                : ListView.builder(
              padding: const EdgeInsets.all(16),
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
                    onTap: () => _showCertificateDetails(certificate),
                  ),
                ).animate().fadeIn(duration: 300.ms, delay: (100 * index).ms);
              },
            );
          }
          return const Center(child: Text('No certificates available'));
        },
      ),
    );
  }
}
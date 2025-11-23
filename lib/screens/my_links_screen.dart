import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class MyLinksScreen extends StatefulWidget {
  const MyLinksScreen({super.key});

  @override
  State<MyLinksScreen> createState() => _MyLinksScreenState();
}

class _MyLinksScreenState extends State<MyLinksScreen> {
  List<Map<String, dynamic>> _links = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadLinks();
  }

  Future<void> _loadLinks() async {
    setState(() {
      _isLoading = true;
    });

    _links = await StorageService.getLinks();

    // Fetch stats for each link
    for (var i = 0; i < _links.length; i++) {
      final slug = _links[i]['slug'];
      final stats = await ApiService.getLinkStats(slug);
      
      if (stats['success']) {
        setState(() {
          _links[i]['clicks'] = stats['data']['clicks'];
          _links[i]['last_click'] = stats['data']['last_click'];
          _links[i]['is_executable'] = stats['data']['is_executable'];
          _links[i]['is_adult'] = stats['data']['is_adult'];
        });
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _deleteLink(String slug, int index) async {
    final result = await ApiService.deleteLink(slug);
    
    if (result['success']) {
      await StorageService.deleteLink(slug);
      setState(() {
        _links.removeAt(index);
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Link deleted successfully'),
            backgroundColor: Color(0xFF00FF88),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['error'] ?? 'Failed to delete link'),
            backgroundColor: const Color(0xFFFF006E),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _copyToClipboard(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Copied to clipboard!'),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'Never';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('MMM dd, yyyy HH:mm').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  String _getExpiryText(Map<String, dynamic> link) {
    if (link['expiry_days'] == null) {
      return 'Never expires 🏆';
    }
    
    try {
      final createdAt = DateTime.parse(link['created_at']);
      final expiryDays = link['expiry_days'] as int;
      final expiresAt = createdAt.add(Duration(days: expiryDays));
      final now = DateTime.now();
      
      if (expiresAt.isBefore(now)) {
        return 'Expired';
      }
      
      final difference = expiresAt.difference(now);
      final days = difference.inDays;
      final hours = difference.inHours % 24;
      
      return 'Expires in ${days}d ${hours}h';
    } catch (e) {
      return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadLinks,
      child: _isLoading && _links.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : _links.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.link_off,
                        size: 64,
                        color: Colors.white.withOpacity(0.3),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No links yet',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white.withOpacity(0.5),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Create your first short link!',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.3),
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _links.length,
                  itemBuilder: (context, index) {
                    final link = _links[index];
                    return _buildLinkCard(link, index);
                  },
                ),
    );
  }

  Widget _buildLinkCard(Map<String, dynamic> link, int index) {
    final clicks = link['clicks'] ?? 0;
    final isExecutable = link['is_executable'] ?? false;
    final isAdult = link['is_adult'] ?? false;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with slug and actions
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Icon(
                        Icons.link,
                        color: Color(0xFF8338EC),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          link['slug'],
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF8338EC),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy, size: 20),
                  onPressed: () => _copyToClipboard(link['short_url']),
                  tooltip: 'Copy',
                ),
                IconButton(
                  icon: const Icon(Icons.open_in_new, size: 20),
                  onPressed: () => _openUrl(link['short_url']),
                  tooltip: 'Open',
                ),
                IconButton(
                  icon: const Icon(Icons.delete, size: 20),
                  onPressed: () => _showDeleteDialog(link['slug'], index),
                  color: const Color(0xFFFF006E),
                  tooltip: 'Delete',
                ),
              ],
            ),
            const Divider(height: 24),
            
            // Original URL
            _buildInfoRow(
              Icons.language,
              'Original URL',
              link['url'],
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            
            // Stats
            Row(
              children: [
                Expanded(
                  child: _buildStatChip(
                    Icons.mouse,
                    'Clicks',
                    clicks.toString(),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatChip(
                    Icons.timer,
                    'Expiry',
                    _getExpiryText(link),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Created date
            _buildInfoRow(
              Icons.calendar_today,
              'Created',
              _formatDate(link['created_at']),
            ),
            
            // Last click
            if (link['last_click'] != null) ...[
              const SizedBox(height: 8),
              _buildInfoRow(
                Icons.access_time,
                'Last click',
                _formatDate(link['last_click']),
              ),
            ],
            
            // Warnings
            if (isExecutable || isAdult) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (isExecutable)
                    Chip(
                      avatar: const Icon(
                        Icons.warning,
                        color: Color(0xFFFF006E),
                        size: 16,
                      ),
                      label: const Text(
                        'Executable',
                        style: TextStyle(fontSize: 12),
                      ),
                      backgroundColor: const Color(0xFFFF006E).withOpacity(0.2),
                    ),
                  if (isAdult)
                    Chip(
                      avatar: const Icon(
                        Icons.report,
                        color: Colors.orange,
                        size: 16,
                      ),
                      label: const Text(
                        'Adult',
                        style: TextStyle(fontSize: 12),
                      ),
                      backgroundColor: Colors.orange.withOpacity(0.2),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, {int maxLines = 1}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.white70),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.5),
                ),
              ),
              Text(
                value,
                style: const TextStyle(fontSize: 14),
                maxLines: maxLines,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatChip(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF8338EC).withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFF8338EC).withOpacity(0.5),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFF8338EC), size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF8338EC),
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(String slug, int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Link'),
        content: Text('Are you sure you want to delete "$slug"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteLink(slug, index);
            },
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFFF006E),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

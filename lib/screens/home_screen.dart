import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _urlController = TextEditingController();
  final _slugController = TextEditingController();
  final _expiryController = TextEditingController();
  bool _isLoading = false;
  String? _shortUrl;
  String? _errorMessage;

  @override
  void dispose() {
    _urlController.dispose();
    _slugController.dispose();
    _expiryController.dispose();
    super.dispose();
  }

  Future<void> _shortenUrl() async {
    final url = _urlController.text.trim();
    
    if (url.isEmpty) {
      _showError('Yo, paste a fucking URL first!');
      return;
    }

    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      _showError('URL must start with http:// or https://, dumbass!');
      return;
    }

    int? expiryDays;
    if (_expiryController.text.trim().isNotEmpty) {
      expiryDays = int.tryParse(_expiryController.text.trim());
      if (expiryDays == null || expiryDays < 1) {
        _showError('Expiry must be at least 1 day!');
        return;
      }
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _shortUrl = null;
    });

    final result = await ApiService.shortenUrl(
      url: url,
      customSlug: _slugController.text.trim(),
      expiryDays: expiryDays,
    );

    setState(() {
      _isLoading = false;
    });

    if (result['success']) {
      final data = result['data'];
      
      // Save to local storage
      await StorageService.saveLink({
        'slug': data['slug'],
        'url': data['original_url'],
        'short_url': data['short_url'],
        'created_at': DateTime.now().toIso8601String(),
        'expiry_days': data['expiry_days'],
        'expires_at': data['expires_at'],
        'is_supporter': data['is_supporter'],
      });

      setState(() {
        _shortUrl = data['short_url'];
      });

      // Clear inputs
      _urlController.clear();
      _slugController.clear();
      _expiryController.clear();

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Fuck yeah! Your link is ready!'),
            backgroundColor: Color(0xFF00FF88),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } else {
      _showError(result['error'] ?? 'Something fucked up. Try again!');
    }
  }

  void _showError(String message) {
    setState(() {
      _errorMessage = message;
    });
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

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Shorten your damn links already',
            style: TextStyle(
              fontSize: 18,
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          
          // URL Input
          TextField(
            controller: _urlController,
            decoration: const InputDecoration(
              labelText: 'Long URL',
              hintText: 'https://example.com/some/really/fucking/long/url',
              prefixIcon: Icon(Icons.link),
            ),
            keyboardType: TextInputType.url,
          ),
          const SizedBox(height: 16),
          
          // Custom Slug
          TextField(
            controller: _slugController,
            decoration: const InputDecoration(
              labelText: 'Custom Slug (optional)',
              hintText: 'my-custom-link',
              prefixIcon: Icon(Icons.edit),
            ),
          ),
          const SizedBox(height: 16),
          
          // Expiry Days
          TextField(
            controller: _expiryController,
            decoration: const InputDecoration(
              labelText: 'Expiry Days (optional)',
              hintText: 'Leave blank for max (150 days)',
              prefixIcon: Icon(Icons.timer),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 24),
          
          // Shorten Button
          ElevatedButton.icon(
            onPressed: _isLoading ? null : _shortenUrl,
            icon: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.auto_fix_high),
            label: Text(_isLoading ? 'Shortening...' : 'Shorten'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
          
          // Info Card
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow(Icons.info_outline, 
                    'Custom URLs: letters, numbers, dashes, underscores only'),
                  const SizedBox(height: 8),
                  _buildInfoRow(Icons.timer, 
                    'Default expiry: 150 days (5 months)'),
                  const SizedBox(height: 8),
                  _buildInfoRow(Icons.shield, 
                    'Executable files get a warning screen'),
                  const SizedBox(height: 8),
                  _buildInfoRow(Icons.warning_amber, 
                    'Adult content gets an age verification screen'),
                ],
              ),
            ),
          ),
          
          // Error Message
          if (_errorMessage != null) ...[
            const SizedBox(height: 16),
            Card(
              color: const Color(0xFFFF006E).withOpacity(0.2),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Color(0xFFFF006E),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Color(0xFFFF006E)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          
          // Success Result
          if (_shortUrl != null) ...[
            const SizedBox(height: 16),
            Card(
              color: const Color(0xFF00FF88).withOpacity(0.2),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: Color(0xFF00FF88),
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Fuck yeah! Your link is ready!',
                          style: TextStyle(
                            color: Color(0xFF00FF88),
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1A1A1A),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0xFF00FF88),
                              ),
                            ),
                            child: Text(
                              _shortUrl!,
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                color: Color(0xFF00FF88),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton.filled(
                          onPressed: () => _copyToClipboard(_shortUrl!),
                          icon: const Icon(Icons.copy),
                          style: IconButton.styleFrom(
                            backgroundColor: const Color(0xFF8338EC),
                          ),
                        ),
                        IconButton.filled(
                          onPressed: () => _openUrl(_shortUrl!),
                          icon: const Icon(Icons.open_in_new),
                          style: IconButton.styleFrom(
                            backgroundColor: const Color(0xFF8338EC),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
          
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: const Color(0xFF8338EC)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }
}

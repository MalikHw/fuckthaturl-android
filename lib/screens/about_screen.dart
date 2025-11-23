import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
        backgroundColor: const Color(0xFF1A1A1A),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // App Icon and Title
            Center(
              child: Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: const Color(0xFF8338EC),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.link,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'FuckThatURL',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Version 1.0.0',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            // Description Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Made with ❤️ and shit by',
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'MalikHw47',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF8338EC),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Social Links
            Card(
              child: Column(
                children: [
                  _buildSocialLink(
                    context,
                    icon: Icons.play_arrow,
                    label: 'YouTube',
                    subtitle: '@MalikHw47',
                    url: 'https://youtube.com/@MalikHw47',
                    color: const Color(0xFFFF0000),
                  ),
                  const Divider(height: 1),
                  _buildSocialLink(
                    context,
                    icon: Icons.videocam,
                    label: 'Twitch',
                    subtitle: 'MalikHw47',
                    url: 'https://twitch.tv/MalikHw47',
                    color: const Color(0xFF9146FF),
                  ),
                  const Divider(height: 1),
                  _buildSocialLink(
                    context,
                    icon: Icons.code,
                    label: 'GitHub',
                    subtitle: 'MalikHw',
                    url: 'https://github.com/MalikHw',
                    color: const Color(0xFF00FF88),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Features Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Features',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildFeature(
                      Icons.link,
                      'URL Shortening',
                      'Create short links with custom slugs',
                    ),
                    _buildFeature(
                      Icons.timer,
                      'Expiry Control',
                      'Set custom expiry dates (1-150 days)',
                    ),
                    _buildFeature(
                      Icons.bar_chart,
                      'Click Tracking',
                      'Monitor how many clicks your links get',
                    ),
                    _buildFeature(
                      Icons.shield,
                      'Safety Features',
                      'Warnings for executable files & adult content',
                    ),
                    _buildFeature(
                      Icons.delete,
                      'Link Management',
                      'Delete your links anytime',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Supporter Info
            Card(
              color: const Color(0xFF00FF88).withOpacity(0.2),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.star,
                          color: Color(0xFF00FF88),
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Become a Supporter',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF00FF88),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Want links that never expire? Text "malikhw" on Discord to support financially and get a supporter key!',
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Supporter Benefits:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildBenefit('Links never expire'),
                    _buildBenefit('API access'),
                    _buildBenefit('Priority support'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            
            // Copyright
            Center(
              child: Text(
                '© 2024 MalikHw47\nAll rights reserved',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.3),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialLink(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String subtitle,
    required String url,
    required Color color,
  }) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(label),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.open_in_new, size: 20),
      onTap: () => _launchUrl(url),
    );
  }

  Widget _buildFeature(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: const Color(0xFF8338EC),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefit(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 4),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle,
            color: Color(0xFF00FF88),
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(fontSize: 13),
          ),
        ],
      ),
    );
  }
}

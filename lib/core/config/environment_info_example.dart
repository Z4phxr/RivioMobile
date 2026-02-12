import 'package:flutter/material.dart';
import 'package:habit_tracker/core/config/api_config.dart';
import 'package:habit_tracker/core/config/env_config.dart';

/// Example widget showing proper usage of environment configuration
/// This is a reference implementation - copy patterns to your own widgets
class EnvironmentInfoExample extends StatelessWidget {
  const EnvironmentInfoExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Environment Configuration')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section 1: Current Environment Info
            _buildSection(
              title: 'Current Environment',
              children: [
                _buildInfoTile(
                  'Environment',
                  EnvironmentConfig.environmentName,
                  isDev: EnvironmentConfig.isDevelopment,
                ),
                _buildInfoTile(
                  'Mode',
                  EnvironmentConfig.isDevelopment ? 'Debug' : 'Release',
                  isDev: EnvironmentConfig.isDevelopment,
                ),
              ],
            ),
            const Divider(height: 32),

            // Section 2: API Configuration
            _buildSection(
              title: 'API Configuration',
              children: [
                _buildInfoTile(
                  'Base URL',
                  EnvironmentConfig.baseUrl,
                  isDev: EnvironmentConfig.isDevelopment,
                ),
                _buildInfoTile(
                  'API Base URL',
                  ApiConfig.apiBaseUrl,
                  isDev: EnvironmentConfig.isDevelopment,
                ),
                _buildInfoTile(
                  'API Version',
                  ApiConfig.apiVersion,
                  isDev: EnvironmentConfig.isDevelopment,
                ),
              ],
            ),
            const Divider(height: 32),

            // Section 3: Features
            _buildSection(
              title: 'Features',
              children: [
                _buildInfoTile(
                  'Logging Enabled',
                  EnvironmentConfig.enableLogging ? 'Yes' : 'No',
                  isDev: EnvironmentConfig.isDevelopment,
                ),
                _buildInfoTile(
                  'Timeouts',
                  '${ApiConfig.connectTimeout.inSeconds}s (connect) / ${ApiConfig.receiveTimeout.inSeconds}s (receive)',
                  isDev: EnvironmentConfig.isDevelopment,
                ),
              ],
            ),
            const Divider(height: 32),

            // Section 4: Usage Examples
            _buildSection(
              title: 'Usage Examples',
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    'In your code, use these properties:',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
                _buildCodeExample(
                  'Get Current Base URL',
                  'String url = EnvironmentConfig.baseUrl;',
                ),
                _buildCodeExample(
                  'Check Environment',
                  '''if (EnvironmentConfig.isDevelopment) {
  // Dev-only code
}''',
                ),
                _buildCodeExample(
                  'Build API URLs',
                  'String habit = ApiConfig.apiBaseUrl + ApiConfig.habits;',
                ),
              ],
            ),
            const Divider(height: 32),

            // Section 5: Important Notes
            _buildSection(
              title: '⚠️ Important Notes',
              children: [
                _buildNoteItem(
                  '✓ Never hardcode URLs in widgets',
                  'Always use EnvironmentConfig.baseUrl or ApiConfig',
                ),
                _buildNoteItem(
                  '✓ Use ApiClient for all HTTP requests',
                  'It automatically applies the correct base URL and interceptors',
                ),
                _buildNoteItem(
                  '✓ Build with correct environment',
                  'Dev: flutter run\nProd: flutter run --dart-define=ENV=production',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Build a section with title and children
  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  /// Build an info tile showing key-value pair
  Widget _buildInfoTile(String label, String value, {required bool isDev}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDev ? Colors.blue[50] : Colors.green[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isDev ? Colors.blue[200]! : Colors.green[200]!,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  /// Build a code example tile
  Widget _buildCodeExample(String title, String code) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(8),
              fontFamily: 'Courier',
            ),
            child: Text(
              code,
              style: const TextStyle(
                fontSize: 12,
                fontFamily: 'monospace',
                color: Colors.green,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build a note item
  Widget _buildNoteItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(description, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}

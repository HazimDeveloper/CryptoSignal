// screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'dart:io' show Platform;

import '../providers/trading_provider.dart';
import '../utils/notification_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _serverUrlController = TextEditingController();
  bool _notificationsEnabled = true;
  bool _darkMode = true;
  String _appVersion = '';
  String _buildNumber = '';

  // Keys for shared preferences
  static const String KEY_SERVER_URL = 'server_url';
  static const String KEY_NOTIFICATIONS_ENABLED = 'notifications_enabled';
  static const String KEY_DARK_MODE = 'dark_mode';

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _loadAppInfo();
  }

  @override
  void dispose() {
    _serverUrlController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    setState(() {
      _serverUrlController.text = prefs.getString(KEY_SERVER_URL) ?? 'http://10.0.2.2:5000/api';
      _notificationsEnabled = prefs.getBool(KEY_NOTIFICATIONS_ENABLED) ?? true;
      _darkMode = prefs.getBool(KEY_DARK_MODE) ?? true;
    });
  }

  Future<void> _loadAppInfo() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      setState(() {
        _appVersion = packageInfo.version;
        _buildNumber = packageInfo.buildNumber;
      });
    } catch (e) {
      // Fallback values if package info fails
      setState(() {
        _appVersion = '1.0.0';
        _buildNumber = '1';
      });
    }
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Save server URL
    await prefs.setString(KEY_SERVER_URL, _serverUrlController.text);
    
    // Save notification preference
    await prefs.setBool(KEY_NOTIFICATIONS_ENABLED, _notificationsEnabled);
    
    // Save theme preference
    await prefs.setBool(KEY_DARK_MODE, _darkMode);
    
    // Show confirmation
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Settings saved'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Server Settings
            _buildSectionHeader('Server Settings'),
            _buildServerUrlField(),
            const SizedBox(height: 16),
            _buildTestConnectionButton(),
            
            const SizedBox(height: 32),
            
            // App Settings
            _buildSectionHeader('App Settings'),
            _buildSettingsSwitch(
              'Enable Notifications',
              'Receive alerts for new trading signals',
              _notificationsEnabled,
              (value) {
                setState(() {
                  _notificationsEnabled = value;
                });
              },
            ),
            _buildSettingsSwitch(
              'Dark Mode',
              'Toggle between dark and light theme',
              _darkMode,
              (value) {
                setState(() {
                  _darkMode = value;
                });
                // In a real app, this would update the theme
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Theme changes will apply after restart'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
            
            const SizedBox(height: 32),
            
            // Data Management
            _buildSectionHeader('Data Management'),
            _buildActionButton(
              'Clear Cache',
              'Delete locally stored data',
              Icons.cleaning_services,
              _clearCache,
            ),
            _buildActionButton(
              'Refresh All Data',
              'Update model and fetch latest signals',
              Icons.refresh,
              _refreshData,
            ),
            
            const SizedBox(height: 32),
            
            // About Section
            _buildSectionHeader('About'),
            _buildAboutCard(),
            
            const SizedBox(height: 32),
            
            // App Info
            _buildAppInfo(),
            
            // Save button
            const SizedBox(height: 24),
            Center(
              child: ElevatedButton.icon(
                onPressed: _saveSettings,
                icon: const Icon(Icons.save),
                label: const Text('Save Settings'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildServerUrlField() {
    return TextFormField(
      controller: _serverUrlController,
      decoration: InputDecoration(
        labelText: 'Server URL',
        hintText: 'http://10.0.2.2:5000/api',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        fillColor: Colors.grey[800],
        prefixIcon: const Icon(Icons.link),
      ),
      keyboardType: TextInputType.url,
      autocorrect: false,
    );
  }

  Widget _buildTestConnectionButton() {
    return ElevatedButton.icon(
      onPressed: _testConnection,
      icon: const Icon(Icons.network_check),
      label: const Text('Test Connection'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue[700],
      ),
    );
  }

  Widget _buildSettingsSwitch(
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
  ) {
    return Card(
      elevation: 0,
      color: const Color(0xFF252D4A),
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: SwitchListTile(
        title: Text(title),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 12,
          ),
        ),
        value: value,
        onChanged: onChanged,
        activeColor: Colors.blue,
      ),
    );
  }

  Widget _buildActionButton(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return Card(
      elevation: 0,
      color: const Color(0xFF252D4A),
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        title: Text(title),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 12,
          ),
        ),
        leading: Icon(icon, color: Colors.blue),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onPressed,
      ),
    );
  }

  Widget _buildAboutCard() {
    return Card(
      elevation: 0,
      color: const Color(0xFF252D4A),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Self-Learning Trading Model',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'This application uses machine learning to analyze cryptocurrency market data and generate trading signals. The model leverages CNN and LSTM neural networks with HMM regime detection to identify market patterns.',
            ),
            const SizedBox(height: 12),
            const Text(
              'Key features:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            _buildFeatureItem('Automatic signal generation'),
            _buildFeatureItem('Market regime detection'),
            _buildFeatureItem('Performance evaluation'),
            _buildFeatureItem('Real-time notifications'),
            
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildLinkButton(
                  'Documentation',
                  Icons.menu_book,
                  'https://github.com/yourusername/trading-model/wiki',
                ),
                _buildLinkButton(
                  'Source Code',
                  Icons.code,
                  'https://github.com/yourusername/trading-model',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 16),
          const SizedBox(width: 8),
          Text(text),
        ],
      ),
    );
  }

  Widget _buildLinkButton(String label, IconData icon, String url) {
    return ElevatedButton.icon(
      onPressed: () => _launchUrl(url),
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue[800],
      ),
    );
  }

  Widget _buildAppInfo() {
    return Center(
      child: Column(
        children: [
          Text(
            'Version $_appVersion (Build $_buildNumber)',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '© ${DateTime.now().year} Your Company',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // Action methods
  Future<void> _testConnection() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('Testing connection...'),
          ],
        ),
      ),
    );
    
    try {
      // Update the API URL in the provider
      final provider = context.read<TradingProvider>();
      
      // Wait for the status check
      final result = await provider.apiService.getStatus();
      
      // Close loading dialog
      Navigator.pop(context);
      
      // Show result
      if (result['error'] != null) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('Connection failed: ${result['error']}'),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('Connection successful: ${result['model_loaded'] ? 'Model loaded' : 'Model not loaded'}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      // Close loading dialog
      Navigator.pop(context);
      
      // Show error
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Connection failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _clearCache() async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cache'),
        content: const Text('This will delete all locally stored data. You will need to reload data from the server. Continue?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
          ),
        ],
      ),
    ) ?? false;
    
    if (confirmed) {
      final prefs = await SharedPreferences.getInstance();
      
      // Clear all cached data except settings
      await prefs.remove(TradingProvider.KEY_PRICE_DATA);
      await prefs.remove(TradingProvider.KEY_SIGNALS);
      await prefs.remove(TradingProvider.KEY_PERFORMANCE);
      await prefs.remove(TradingProvider.KEY_REGIMES);
      await prefs.remove(TradingProvider.KEY_METRICS);
      await prefs.remove(TradingProvider.KEY_LAST_UPDATED);
      
      // Show confirmation
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cache cleared successfully'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _refreshData() async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('Refreshing data...'),
          ],
        ),
      ),
    );
    
    try {
      // Refresh data in the provider
      await context.read<TradingProvider>().loadAllData(forceRefresh: true);
      
      // Close loading dialog
      Navigator.pop(context);
      
      // Show confirmation
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data refreshed successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      // Close loading dialog
      Navigator.pop(context);
      
      // Show error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to refresh data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _launchUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open $url'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
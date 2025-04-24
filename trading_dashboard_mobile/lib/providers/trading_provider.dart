// providers/trading_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

import '../models/price_data.dart';
import '../models/signal_data.dart';
import '../models/performance_metrics.dart';
import '../utils/api_service.dart';
import '../utils/notification_service.dart';

class TradingProvider with ChangeNotifier {
  final ApiService apiService;
  final SharedPreferences prefs;
  
  // State variables
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';
  DateTime? _lastUpdated;
  
  // Data
  List<PriceData> _priceData = [];
  List<SignalData> _signals = [];
  PerformanceMetrics? _performance;
  Map<String, dynamic> _regimes = {};
  Map<String, dynamic> _metrics = {};
  
  // Cached data keys
  static const String KEY_PRICE_DATA = 'price_data';
  static const String KEY_SIGNALS = 'signals';
  static const String KEY_PERFORMANCE = 'performance';
  static const String KEY_REGIMES = 'regimes';
  static const String KEY_METRICS = 'metrics';
  static const String KEY_LAST_UPDATED = 'last_updated';
  
  TradingProvider({
    required this.apiService,
    required this.prefs,
  }) {
    _loadCachedData();
  }
  
  // Getters
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  String get errorMessage => _errorMessage;
  DateTime? get lastUpdated => _lastUpdated;
  
  List<PriceData> get priceData => _priceData;
  List<SignalData> get signals => _signals;
  PerformanceMetrics? get performance => _performance;
  Map<String, dynamic> get regimes => _regimes;
  Map<String, dynamic> get metrics => _metrics;
  
  // Load data from cache
  void _loadCachedData() {
    try {
      // Load last updated timestamp
      final lastUpdatedStr = prefs.getString(KEY_LAST_UPDATED);
      if (lastUpdatedStr != null) {
        _lastUpdated = DateTime.parse(lastUpdatedStr);
      }
      
      // Load price data
      final priceDataStr = prefs.getString(KEY_PRICE_DATA);
      if (priceDataStr != null) {
        final priceDataJson = json.decode(priceDataStr) as List;
        _priceData = priceDataJson.map((item) => PriceData.fromJson(item)).toList();
      }
      
      // Load signals
      final signalsStr = prefs.getString(KEY_SIGNALS);
      if (signalsStr != null) {
        final signalsJson = json.decode(signalsStr) as List;
        _signals = signalsJson.map((item) => SignalData.fromJson(item)).toList();
      }
      
      // Load performance
      final performanceStr = prefs.getString(KEY_PERFORMANCE);
      if (performanceStr != null) {
        final performanceJson = json.decode(performanceStr);
        _performance = PerformanceMetrics.fromJson(performanceJson);
      }
      
      // Load regimes
      final regimesStr = prefs.getString(KEY_REGIMES);
      if (regimesStr != null) {
        _regimes = json.decode(regimesStr);
      }
      
      // Load metrics
      final metricsStr = prefs.getString(KEY_METRICS);
      if (metricsStr != null) {
        _metrics = json.decode(metricsStr);
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading cached data: $e');
    }
  }
  
  // Save data to cache
  Future<void> _saveCachedData() async {
    try {
      // Save last updated timestamp
      _lastUpdated = DateTime.now();
      await prefs.setString(KEY_LAST_UPDATED, _lastUpdated!.toIso8601String());
      
      // Save price data
      final priceDataJson = _priceData.map((item) => item.toJson()).toList();
      await prefs.setString(KEY_PRICE_DATA, json.encode(priceDataJson));
      
      // Save signals
      final signalsJson = _signals.map((item) => item.toJson()).toList();
      await prefs.setString(KEY_SIGNALS, json.encode(signalsJson));
      
      // Save performance
      if (_performance != null) {
        await prefs.setString(KEY_PERFORMANCE, json.encode(_performance!.toJson()));
      }
      
      // Save regimes
      await prefs.setString(KEY_REGIMES, json.encode(_regimes));
      
      // Save metrics
      await prefs.setString(KEY_METRICS, json.encode(_metrics));
    } catch (e) {
      debugPrint('Error saving cached data: $e');
    }
  }
  
  // Load data from API
  Future<void> loadAllData({bool forceRefresh = false}) async {
    // Skip if already loading
    if (_isLoading) return;
    
    // Skip if we have cached data and not forcing refresh
    if (!forceRefresh && 
        _lastUpdated != null && 
        _priceData.isNotEmpty && 
        _signals.isNotEmpty &&
        DateTime.now().difference(_lastUpdated!).inHours < 1) {
      return;
    }
    
    _isLoading = true;
    _hasError = false;
    notifyListeners();
    
    try {
      // Check server status
        final allData = await apiService.getAllData();
    
    // Update state with new data
    _priceData = allData['priceData'];
    _signals = allData['signals'];
    _performance = allData['performance'];
    
    // Add extra debugging for regimes data
    if (allData['regimes'] != null) {
      print("Regimes data found: ${allData['regimes']}");
      _regimes = allData['regimes'];
    } else {
      print("No regimes data returned from API");
      // Initialize with empty structure to avoid null errors
      _regimes = {
        'regime_data': [],
        'regime_counts': {},
        'regime_labels': {
          '0': 'Neutral',
          '1': 'Bullish',
          '2': 'Bearish'
        }
      };
    }
    
    _metrics = allData['metrics'] ?? {};
    
    // Save to cache
    await _saveCachedData();
      
      // Check for important signals
      _checkForSignalNotifications();
      
    } catch (e) {
      _hasError = true;
      _errorMessage = e.toString();
      debugPrint('Error loading data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Check for signals that should trigger notifications
  void _checkForSignalNotifications() {
    if (_signals.isEmpty) return;
    
    // Get the latest signal
    final latestSignal = _signals.last;
    
    // Only notify for BUY or SELL signals
    if (latestSignal.signal == 'BUY' || latestSignal.signal == 'SELL') {
      // Check if it's a recent signal (last 24 hours)
      final now = DateTime.now();
      if (now.difference(latestSignal.timestamp).inHours <= 24) {
        // Format the date
        final dateStr = DateFormat('MMM dd, HH:mm').format(latestSignal.timestamp);
        
        // Create notification
        NotificationService.showNotification(
          title: '${latestSignal.signal} Signal Generated',
          body: 'New ${latestSignal.signal.toLowerCase()} signal on $dateStr with '
               '${latestSignal.confidence.toStringAsFixed(1)}% confidence',
        );
      }
    }
  }
  
  // Get active signals (BUY or SELL only)
 List<SignalData> getActiveSignals() {
  final activeSignals = _signals.where((s) => s.signal == 'BUY' || s.signal == 'SELL').toList();
  
  // Sort signals by timestamp (newest first)
  activeSignals.sort((a, b) => b.timestamp.compareTo(a.timestamp));
  
  return activeSignals;
}
  
  // Get recent signals (last 7 days)
  List<SignalData> getRecentSignals() {
  final now = DateTime.now();
  final recentSignals = getActiveSignals()
      .where((s) => now.difference(s.timestamp).inDays <= 7)
      .toList();
  
  return recentSignals; // Already sorted from getActiveSignals()
}
}
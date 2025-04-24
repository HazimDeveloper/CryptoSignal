// providers/signal_metrics_provider.dart
import 'package:flutter/material.dart';
import 'package:trading_dashboard_mobile/models/signal_metric.dart';
import '../utils/api_service.dart';

class SignalMetricsProvider with ChangeNotifier {
  final ApiService apiService;
  
  SignalMetrics? _signalMetrics;
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';
  
  SignalMetricsProvider({required this.apiService});
  
  // Getters
  SignalMetrics? get signalMetrics => _signalMetrics;
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  String get errorMessage => _errorMessage;
  
  Future<void> loadModelMetrics() async {
    _isLoading = true;
    _hasError = false;
    notifyListeners();
    
    try {
      final metrics = await apiService.getModelMetrics();
      if (metrics.isNotEmpty) {
        _signalMetrics = metrics['signal_metrics'] as SignalMetrics;
      }
    } catch (e) {
      _hasError = true;
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
// Create a Provider for candlestick patterns
// candlestick_patterns_provider.dart

import 'package:flutter/material.dart';
import '../models/candlestick_pattern.dart';
import '../utils/api_service.dart';

class CandlestickPatternsProvider with ChangeNotifier {
  final ApiService apiService;
  
  List<CandlestickPattern> _patterns = [];
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';
  
  CandlestickPatternsProvider({required this.apiService});
  
  // Getters
  List<CandlestickPattern> get patterns => _patterns;
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  String get errorMessage => _errorMessage;
  
  List<CandlestickPattern> getBullishPatterns() {
    return _patterns.where((p) => p.type == 'Bullish').toList();
  }
  
  List<CandlestickPattern> getBearishPatterns() {
    return _patterns.where((p) => p.type == 'Bearish').toList();
  }
  
  List<CandlestickPattern> getReversalPatterns() {
    return _patterns.where((p) => p.category == 'Reversal').toList();
  }
  
  List<CandlestickPattern> getContinuationPatterns() {
    return _patterns.where((p) => p.category == 'Continuation').toList();
  }
  
  Future<void> loadPatterns() async {
    _isLoading = true;
    _hasError = false;
    notifyListeners();
    
    try {
      final patternsData = await apiService.getCandlestickPatterns();
      
      if (patternsData != null) {
        _patterns = patternsData.map((item) => CandlestickPattern.fromJson(item)).toList();
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
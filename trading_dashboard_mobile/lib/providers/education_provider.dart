// providers/education_provider.dart
import 'package:flutter/material.dart';
import '../models/educational_content.dart';
import '../utils/api_service.dart';

class EducationProvider with ChangeNotifier {
  final ApiService apiService;
  
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';
  
  List<Topic> _basics = [];
  List<Term> _terms = [];
  List<Strategy> _strategies = [];
  
  EducationProvider({required this.apiService});
  
  // Getters
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  String get errorMessage => _errorMessage;
  
  List<Topic> get basics => _basics;
  List<Term> get terms => _terms;
  List<Strategy> get strategies => _strategies;
  
  Future<void> loadEducationalContent() async {
    _isLoading = true;
    _hasError = false;
    notifyListeners();
    
    try {
      // Load basics
      final basicsResponse = await apiService.getEducationalContent('basics');
      if (basicsResponse != null) {
        _basics = (basicsResponse as List).map((item) => Topic.fromJson(item)).toList();
      }
      
      // Load terms
      final termsResponse = await apiService.getEducationalContent('terms');
      if (termsResponse != null) {
        _terms = (termsResponse as List).map((item) => Term.fromJson(item)).toList();
      }
      
      // Load strategies
      final strategiesResponse = await apiService.getEducationalContent('strategies');
      if (strategiesResponse != null) {
        _strategies = (strategiesResponse as List).map((item) => Strategy.fromJson(item)).toList();
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
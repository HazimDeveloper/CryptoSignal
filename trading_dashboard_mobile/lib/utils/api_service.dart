// utils/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/price_data.dart';
import '../models/signal_data.dart';
import '../models/performance_metrics.dart';

class ApiService {
  // Base URL - Update with your server address
  // For emulator, use: 10.0.2.2:5000 instead of localhost
  // For iOS simulator, use: localhost:5000
  final String baseUrl = 'http://10.0.2.2:5000/api';
  
  // Timeout for requests
  final Duration timeout = const Duration(seconds: 15);
  
  // Get the status of the backend
  Future<Map<String, dynamic>> getStatus() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/status'),
      ).timeout(timeout);
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to get status: ${response.statusCode}');
      }
    } catch (e) {
      return {
        'model_loaded': false,
        'data_available': false,
        'signals_available': false,
        'performance_available': false,
        'task_running': false,
        'error': e.toString(),
      };
    }
  }
  
  // Start the data processing
  Future<bool> startProcess() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/start-process'),
      ).timeout(timeout);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['status'] == 'success';
      } else {
        throw Exception('Failed to start process: ${response.statusCode}');
      }
    } catch (e) {
      return false;
    }
  }
  
  // Get price data
  Future<List<PriceData>> getPriceData() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/price-data'),
      ).timeout(timeout);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['status'] == 'success') {
          final chartData = data['data']['chart_data'] as List;
          final priceColumn = data['data']['price_column'] as String;
          
          return chartData.map((item) {
            // Convert item to have the right structure for PriceData.fromJson
            final convertedItem = {
              'timestamp': item['timestamp'],
              'price': item[priceColumn],
              'volume': item['volume'] ?? 0,
              'market_cap': item['market_cap'],
            };
            
            return PriceData.fromJson(convertedItem);
          }).toList();
        } else {
          throw Exception(data['message'] ?? 'Unknown error');
        }
      } else {
        throw Exception('Failed to load price data: ${response.statusCode}');
      }
    } catch (e) {
      return [];
    }
  }
  
  // Get signals
  Future<List<SignalData>> getSignals() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/signals'),
      ).timeout(timeout);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['status'] == 'success') {
          final signals = data['data']['recent_signals'] as List;
          return signals.map((item) => SignalData.fromJson(item)).toList();
        } else {
          throw Exception(data['message'] ?? 'Unknown error');
        }
      } else {
        throw Exception('Failed to load signals: ${response.statusCode}');
      }
    } catch (e) {
      return [];
    }
  }
  
  // Get performance metrics
  Future<PerformanceMetrics?> getPerformance() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/performance'),
      ).timeout(timeout);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['status'] == 'success') {
          return PerformanceMetrics.fromJson(data['data']);
        } else {
          throw Exception(data['message'] ?? 'Unknown error');
        }
      } else {
        throw Exception('Failed to load performance: ${response.statusCode}');
      }
    } catch (e) {
      return null;
    }
  }
  
  // Get regimes
  Future<Map<String, dynamic>> getRegimes() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/regimes'),
      ).timeout(timeout);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['status'] == 'success') {
          return data['data'];
        } else {
          throw Exception(data['message'] ?? 'Unknown error');
        }
      } else {
        throw Exception('Failed to load regimes: ${response.statusCode}');
      }
    } catch (e) {
      return {};
    }
  }
  
  // Get all data in one call
  Future<Map<String, dynamic>> getAllData() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/all-data'),
      ).timeout(timeout);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['status'] == 'success') {
          final responseData = data['data'];
          
          // Parse price data
          final chartData = responseData['price_data']['chart_data'] as List;
          final priceColumn = responseData['price_data']['price_column'] as String;
          
          final priceData = chartData.map((item) {
            final convertedItem = {
              'timestamp': item['timestamp'],
              'price': item[priceColumn],
              'volume': item['volume'] ?? 0,
              'market_cap': item['market_cap'],
            };
            
            return PriceData.fromJson(convertedItem);
          }).toList();
          
          // Parse signals
          final signalsData = responseData['signals']['recent_signals'] as List;
          final signals = signalsData.map((item) => SignalData.fromJson(item)).toList();
          
          // Parse performance metrics
          final performance = responseData['performance'] != null
              ? PerformanceMetrics.fromJson(responseData['performance'])
              : null;
          
          // Return all parsed data
          return {
            'priceData': priceData,
            'signals': signals,
            'performance': performance,
            'regimes': responseData['regimes'],
            'metrics': {
              'latest_price': responseData['price_data']['latest_price'],
              'price_change_24h': responseData['price_data']['price_change_24h'],
              'latest_signal': responseData['signals']['latest_signal'],
              'signal_confidence': responseData['signals']['signal_confidence'],
            },
          };
        } else {
          throw Exception(data['message'] ?? 'Unknown error');
        }
      } else {
        throw Exception('Failed to load all data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching data: $e');
    }
  }
}
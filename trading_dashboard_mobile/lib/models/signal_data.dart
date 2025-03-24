// models/signal_data.dart
class SignalData {
  final DateTime timestamp;
  final String signal; // 'BUY', 'SELL', or 'HOLD'
  final double confidence;
  final double? predictedReturn;
  
  SignalData({
    required this.timestamp,
    required this.signal,
    required this.confidence,
    this.predictedReturn,
  });
  
  factory SignalData.fromJson(Map<String, dynamic> json) {
    return SignalData(
      timestamp: DateTime.parse(json['timestamp']),
      signal: json['signal'] ?? 'HOLD',
      confidence: (json['confidence'] ?? 0).toDouble(),
      predictedReturn: json['predicted_return'] != null 
          ? (json['predicted_return']).toDouble() 
          : null,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'signal': signal,
      'confidence': confidence,
      'predicted_return': predictedReturn,
    };
  }
}
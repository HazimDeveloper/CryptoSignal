// models/performance_metrics.dart
class PerformanceMetrics {
  final double sharpeRatio;
  final double maxDrawdown;
  final double tradeFrequency;
  final bool meetsCriteria;
  
  PerformanceMetrics({
    required this.sharpeRatio,
    required this.maxDrawdown,
    required this.tradeFrequency,
    required this.meetsCriteria,
  });
  
  factory PerformanceMetrics.fromJson(Map<String, dynamic> json) {
    return PerformanceMetrics(
      sharpeRatio: (json['sharpe_ratio'] ?? 0).toDouble(),
      maxDrawdown: (json['max_drawdown'] ?? 0).toDouble(),
      tradeFrequency: (json['trade_frequency'] ?? 0).toDouble(),
      meetsCriteria: json['meets_criteria'] ?? false,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'sharpe_ratio': sharpeRatio,
      'max_drawdown': maxDrawdown,
      'trade_frequency': tradeFrequency,
      'meets_criteria': meetsCriteria,
    };
  }
  
  // Helper methods to check if meeting individual criteria
  bool get meetsSharpeRatio => sharpeRatio >= 1.8;
  bool get meetsDrawdown => maxDrawdown <= 0.4;
  bool get meetsFrequency => tradeFrequency >= 0.03;
}
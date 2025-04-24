// models/signal_metrics.dart
class SignalMetrics {
  final int buySignalsCount;
  final int sellSignalsCount;
  final double buyAccuracy;
  final double sellAccuracy;
  final double avgAccuracy;
  final List<HistoricalPeriod> historicalPeriods;
  final SignalConfidenceDistribution confidenceDistribution;
  
  SignalMetrics({
    required this.buySignalsCount,
    required this.sellSignalsCount,
    required this.buyAccuracy,
    required this.sellAccuracy,
    required this.avgAccuracy,
    required this.historicalPeriods,
    required this.confidenceDistribution,
  });
  
  factory SignalMetrics.fromJson(Map<String, dynamic> json) {
    final historicalPeriodsJson = json['historical_periods'] as List;
    final distributionJson = json['signal_confidence_distribution'] as Map<String, dynamic>;
    
    return SignalMetrics(
      buySignalsCount: json['buy_signals_count'] ?? 0,
      sellSignalsCount: json['sell_signals_count'] ?? 0,
      buyAccuracy: (json['buy_accuracy'] ?? 0).toDouble(),
      sellAccuracy: (json['sell_accuracy'] ?? 0).toDouble(),
      avgAccuracy: (json['avg_accuracy'] ?? 0).toDouble(),
      historicalPeriods: historicalPeriodsJson
          .map((item) => HistoricalPeriod.fromJson(item))
          .toList(),
      confidenceDistribution: SignalConfidenceDistribution.fromJson(distributionJson),
    );
  }
}

class HistoricalPeriod {
  final String period;
  final double accuracy;
  
  HistoricalPeriod({
    required this.period,
    required this.accuracy,
  });
  
  factory HistoricalPeriod.fromJson(Map<String, dynamic> json) {
    return HistoricalPeriod(
      period: json['period'] ?? '',
      accuracy: (json['accuracy'] ?? 0).toDouble(),
    );
  }
}

class SignalConfidenceDistribution {
  final int veryHigh;
  final int high;
  final int medium;
  final int low;
  
  SignalConfidenceDistribution({
    required this.veryHigh,
    required this.high,
    required this.medium,
    required this.low,
  });
  
  factory SignalConfidenceDistribution.fromJson(Map<String, dynamic> json) {
    return SignalConfidenceDistribution(
      veryHigh: json['very_high'] ?? 0,
      high: json['high'] ?? 0,
      medium: json['medium'] ?? 0,
      low: json['low'] ?? 0,
    );
  }
  
  int get total => veryHigh + high + medium + low;
  
  double get veryHighPercentage => total > 0 ? veryHigh / total * 100 : 0;
  double get highPercentage => total > 0 ? high / total * 100 : 0;
  double get mediumPercentage => total > 0 ? medium / total * 100 : 0;
  double get lowPercentage => total > 0 ? low / total * 100 : 0;
}
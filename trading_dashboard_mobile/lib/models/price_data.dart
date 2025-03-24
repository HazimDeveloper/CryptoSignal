// models/price_data.dart
class PriceData {
  final DateTime timestamp;
  final double price;
  final double volume;
  final double? marketCap;
  
  PriceData({
    required this.timestamp,
    required this.price,
    required this.volume,
    this.marketCap,
  });
  
  factory PriceData.fromJson(Map<String, dynamic> json) {
    return PriceData(
      timestamp: DateTime.parse(json['timestamp']),
      price: (json['price'] ?? 0).toDouble(),
      volume: (json['volume'] ?? 0).toDouble(),
      marketCap: json['market_cap'] != null ? (json['market_cap']).toDouble() : null,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'price': price,
      'volume': volume,
      'market_cap': marketCap,
    };
  }
}

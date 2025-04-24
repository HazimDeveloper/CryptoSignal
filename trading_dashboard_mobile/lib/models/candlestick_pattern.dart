// models/candlestick_pattern.dart

class CandlestickPattern {
  final String name;
  final String type; // 'Bullish', 'Bearish', or 'Neutral'
  final String category; // 'Reversal' or 'Continuation'
  final String description;
  final String key; // For image lookup
  final String imageUrl; // Added this property
  
  CandlestickPattern({
    required this.name,
    required this.type,
    required this.category,
    required this.description,
    required this.key,
    this.imageUrl = '', // Default to empty string
  });
  
  factory CandlestickPattern.fromJson(Map<String, dynamic> json) {
    // Determine type from pattern name or category if not explicitly provided
    String patternType = json['type'] ?? 'Neutral';
    if (patternType == 'Neutral') {
      final name = json['name']?.toLowerCase() ?? '';
      if (name.contains('bullish')) {
        patternType = 'Bullish';
      } else if (name.contains('bearish')) {
        patternType = 'Bearish';
      }
    }
    
    return CandlestickPattern(
      name: json['name'] ?? '',
      type: patternType,
      category: json['category'] ?? 'Other',
      description: json['description'] ?? '',
      key: json['key'] ?? '',
      imageUrl: json['image_url'] ?? '',
    );
  }
}
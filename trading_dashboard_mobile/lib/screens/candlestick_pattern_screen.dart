// screens/candlestick_patterns_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trading_dashboard_mobile/models/candlestick_pattern.dart';
import 'package:trading_dashboard_mobile/widgets/crrypto_app_bar.dart';
import '../widgets/chatbot_widget.dart';
import '../providers/candlestick_patterns_provider.dart';

class CandlestickPatternsScreen extends StatefulWidget {
  const CandlestickPatternsScreen({Key? key}) : super(key: key);

  @override
  _CandlestickPatternsScreenState createState() => _CandlestickPatternsScreenState();
}

class _CandlestickPatternsScreenState extends State<CandlestickPatternsScreen> with SingleTickerProviderStateMixin {
  final List<String> _categories = ['All', 'Bullish', 'Bearish', 'Continuation', 'Reversal'];
  String _selectedCategory = 'All';
late TabController _tabController;
@override
void initState() {
  super.initState();
  _tabController = TabController(length: 3, vsync: this);
  
  // Load patterns data
  WidgetsBinding.instance.addPostFrameCallback((_) {
    Provider.of<CandlestickPatternsProvider>(context, listen: false).loadPatterns();
  });
}

  @override
  void dispose() {
    // Don't forget to dispose the controller when done
    _tabController.dispose();
    super.dispose();
  }
  // Define all patterns
  final List<CandlestickPattern> patterns = [
    // Bearish patterns
    CandlestickPattern(
      name: 'Bearish Engulfing',
      type: 'Bearish',
      category: 'Reversal',
      description: 'A bearish engulfing pattern appears in an uptrend when a large red candle completely engulfs the previous green candle, signaling a potential reversal to the downside.',
      key: 'bearish_engulfing',
    ),
    CandlestickPattern(
      name: 'Evening Star',
      type: 'Bearish',
      category: 'Reversal',
      description: 'A three-candle bearish reversal pattern consisting of a large green candle, followed by a small-bodied candle, and then a large red candle that closes below the midpoint of the first candle.',
      key: 'evening_star',
    ),
    CandlestickPattern(
      name: 'Shooting Star',
      type: 'Bearish',
      category: 'Reversal',
      description: 'A bearish reversal pattern with a small body, little or no lower shadow, and a long upper shadow, appearing at the top of an uptrend.',
      key: 'shooting_star',
    ),
    CandlestickPattern(
      name: 'Dark Cloud Cover',
      type: 'Bearish',
      category: 'Reversal',
      description: 'A two-candle bearish reversal pattern where a red candle opens above the previous green candles close but closes well into the body of the green candle.',
      key: 'dark_cloud_cover',
    ),
    CandlestickPattern(
      name: 'Bearish Harami',
      type: 'Bearish',
      category: 'Reversal',
      description: 'A two-candle pattern where a small red candle is contained within the body of the previous larger green candle, suggesting a potential reversal of the uptrend.',
      key: 'bearish_harami',
    ),
    
    // Bullish patterns
    CandlestickPattern(
      name: 'Bullish Engulfing',
      type: 'Bullish',
      category: 'Reversal',
      description: 'A bullish engulfing pattern appears in a downtrend when a large green candle completely engulfs the previous red candle, signaling a potential reversal to the upside.',
      key: 'bullish_engulfing',
    ),
    CandlestickPattern(
      name: 'Morning Star',
      type: 'Bullish',
      category: 'Reversal',
      description: 'A three-candle bullish reversal pattern consisting of a large red candle, followed by a small-bodied candle, and then a large green candle that closes above the midpoint of the first candle.',
      key: 'morning_star',
    ),
    CandlestickPattern(
      name: 'Hammer',
      type: 'Bullish',
      category: 'Reversal',
      description: 'A bullish reversal pattern with a small body, little or no upper shadow, and a long lower shadow that appears at the bottom of a downtrend.',
      key: 'hammer',
    ),
    CandlestickPattern(
      name: 'Bullish Harami',
      type: 'Bullish',
      category: 'Reversal',
      description: 'A two-candle pattern where a small green candle is contained within the body of the previous larger red candle, suggesting a potential reversal of the downtrend.',
      key: 'bullish_harami',
    ),
    CandlestickPattern(
      name: 'Piercing Line',
      type: 'Bullish',
      category: 'Reversal',
      description: 'A two-candle bullish reversal pattern where a green candle opens below the previous red candles close but closes well into the body of the red candle.',
      key: 'piercing_line',
    ),
    
    // Continuation patterns
    CandlestickPattern(
      name: 'Doji',
      type: 'Neutral',
      category: 'Continuation',
      description: 'A candle with a very small body where the opening and closing prices are very close or the same, indicating indecision in the market.',
      key: 'doji',
    ),
    CandlestickPattern(
      name: 'Spinning Top',
      type: 'Neutral',
      category: 'Continuation',
      description: 'A candle with a small body and long upper and lower shadows, indicating indecision in the market.',
      key: 'spinning_top',
    ),
    CandlestickPattern(
      name: 'Three White Soldiers',
      type: 'Bullish',
      category: 'Continuation',
      description: 'Three consecutive green candles, each opening within the previous candles body and closing higher than the previous candle, indicating strong bullish momentum.',
      key: 'three_white_soldiers',
    ),
    CandlestickPattern(
      name: 'Three Black Crows',
      type: 'Bearish',
      category: 'Continuation',
      description: 'Three consecutive red candles, each opening within the previous candles body and closing lower than the previous candle, indicating strong bearish momentum.',
      key: 'three_black_crows',
    ),
    CandlestickPattern(
      name: 'Rising Three Methods',
      type: 'Bullish',
      category: 'Continuation',
      description: 'A large green candle followed by three smaller red candles contained within the range of the first candle, and then another large green candle, indicating a continuation of the uptrend.',
      key: 'rising_three_methods',
    ),
    CandlestickPattern(
      name: 'Falling Three Methods',
      type: 'Bearish',
      category: 'Continuation',
      description: 'A large red candle followed by three smaller green candles contained within the range of the first candle, and then another large red candle, indicating a continuation of the downtrend.',
      key: 'falling_three_methods',
    ),
  ];

  List<CandlestickPattern> get filteredPatterns {
    if (_selectedCategory == 'All') {
      return patterns;
    } else if (_selectedCategory == 'Bullish') {
      return patterns.where((pattern) => pattern.type == 'Bullish').toList();
    } else if (_selectedCategory == 'Bearish') {
      return patterns.where((pattern) => pattern.type == 'Bearish').toList();
    } else if (_selectedCategory == 'Continuation') {
      return patterns.where((pattern) => pattern.category == 'Continuation').toList();
    } else if (_selectedCategory == 'Reversal') {
      return patterns.where((pattern) => pattern.category == 'Reversal').toList();
    }
    return patterns;
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: CryptoAppBar(
      title: 'Candlestick Patterns',
      showGradient: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.help_outline),
          tooltip: 'Learn about candlestick patterns',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ChatbotScreen(
                  initialQuestion: 'Explain how to use candlestick patterns in trading',
                ),
              ),
            );
          },
        ),
      ],
    ),
    body: Consumer<CandlestickPatternsProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (provider.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                Text('Error: ${provider.errorMessage}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: provider.loadPatterns,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }
        
        return Column(
          children: [
            // Filter chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Row(
                children: _categories.map((category) {
                  final isSelected = _selectedCategory == category;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(
                        category,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.grey[300],
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _selectedCategory = category;
                          });
                        }
                      },
                      selectedColor: category == 'Bullish' 
                          ? Colors.green 
                          : category == 'Bearish' 
                              ? Colors.red 
                              : Colors.blue,
                      backgroundColor: const Color(0xFF252D4A),
                    ),
                  );
                }).toList(),
              ),
            ),
            
            // Introduction card
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 0,
                color: const Color(0xFF252D4A),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.blue),
                          SizedBox(width: 8),
                          Text(
                            'About Candlestick Patterns',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Candlestick patterns are visual formations created by candlesticks on a price chart. Traders use these patterns to predict future price movements based on historical behavior.',
                        style: TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'Bullish',
                              style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text('Signals potential upward movement'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'Bearish',
                              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text('Signals potential downward movement'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            // Patterns grid - Now using data from provider
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.8,
                ),
                itemCount: getFilteredPatterns(provider).length,
                itemBuilder: (context, index) {
                  final pattern = getFilteredPatterns(provider)[index];
                  return _buildPatternCard(pattern, context);
                },
              ),
            ),
          ],
        );
      },
    ),
  );
}

// Add this helper method to filter patterns based on selected category:
List<CandlestickPattern> getFilteredPatterns(CandlestickPatternsProvider provider) {
  if (_selectedCategory == 'All') {
    return provider.patterns.cast<CandlestickPattern>();
  } else if (_selectedCategory == 'Bullish') {
    return provider.getBullishPatterns().cast<CandlestickPattern>();
  } else if (_selectedCategory == 'Bearish') {
    return provider.getBearishPatterns().cast<CandlestickPattern>();
  } else if (_selectedCategory == 'Continuation') {
    return provider.getContinuationPatterns().cast<CandlestickPattern>();
  } else if (_selectedCategory == 'Reversal') {
    return provider.getReversalPatterns().cast<CandlestickPattern>();
  }
  return provider.patterns.cast<CandlestickPattern>();
}
  
// Update the _buildPatternCard method to handle the imageUrl property
// You can use this as a fallback if imageUrl is not available

Widget _buildPatternCard(CandlestickPattern pattern, BuildContext context) {
  final Color patternColor = pattern.type == 'Bullish' 
      ? Colors.green 
      : pattern.type == 'Bearish' 
          ? Colors.red 
          : Colors.grey;
          
  return GestureDetector(
    onTap: () => _showPatternDetail(pattern, context),
    child: Card(
      elevation: 0,
      color: const Color(0xFF252D4A),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: patternColor.withOpacity(0.3), width: 1),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Pattern image (placeholder or actual image if available)
            Container(
              height: 100,
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: hasImageUrl(pattern) 
                  ? Image.network(
                      getImageUrl(pattern),
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      errorBuilder: (context, error, stackTrace) {
                        return patternIcon(pattern, patternColor);
                      },
                    )
                  : patternIcon(pattern, patternColor),
            ),
            
            // Pattern details
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pattern.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: patternColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          pattern.type,
                          style: TextStyle(
                            color: patternColor,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          pattern.category,
                          style: const TextStyle(
                            color: Colors.blue,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    pattern.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[400],
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

// Helper methods to handle the image URL property which might not exist
bool hasImageUrl(CandlestickPattern pattern) {
  try {
    return pattern.imageUrl.isNotEmpty;
  } catch (e) {
    // If the property doesn't exist, handle the error
    return false;
  }
}

String getImageUrl(CandlestickPattern pattern) {
  try {
    return pattern.imageUrl;
  } catch (e) {
    // If the property doesn't exist, return an empty string
    return '';
  }
}

Widget patternIcon(CandlestickPattern pattern, Color color) {
  return Center(
    child: Icon(
      pattern.type == 'Bullish' 
          ? Icons.trending_up 
          : pattern.type == 'Bearish' 
              ? Icons.trending_down 
              : Icons.trending_flat,
      size: 48,
      color: color,
    ),
  );
} 
  void _showPatternDetail(CandlestickPattern pattern, BuildContext context) {
    final Color patternColor = pattern.type == 'Bullish' 
        ? Colors.green 
        : pattern.type == 'Bearish' 
            ? Colors.red 
            : Colors.grey;
            
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (_, controller) => Container(
          decoration: const BoxDecoration(
            color: Color(0xFF1F2937),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: ListView(
            controller: controller,
            padding: const EdgeInsets.all(20),
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey[600],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              
              // Pattern title
              Text(
                pattern.name,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              // Pattern image (placeholder)
              Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: pattern.imageUrl.isNotEmpty
                      ? Image(image: NetworkImage(pattern.imageUrl))
                      : patternIcon(pattern, patternColor),
                ),
              ),
              const SizedBox(height: 20),
              
              // Pattern tags
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: patternColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      pattern.type,
                      style: TextStyle(
                        color: patternColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      pattern.category,
                      style: const TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              // Description
              const Text(
                'Description',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                pattern.description,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              
              // Trading implications
              const Text(
                'Trading Implications',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              if (pattern.type == 'Bullish') ...[
                _buildImplication('Suggests a potential upward movement or trend reversal'),
                _buildImplication('Consider opening long positions or closing shorts'),
                _buildImplication('Look for confirmation from other indicators'),
              ] else if (pattern.type == 'Bearish') ...[
                _buildImplication('Suggests a potential downward movement or trend reversal'),
                _buildImplication('Consider opening short positions or closing longs'),
                _buildImplication('Look for confirmation from other indicators'),
              ] else ...[
                _buildImplication('Indicates market indecision or consolidation'),
                _buildImplication('May precede a significant price movement in either direction'),
                _buildImplication('Wait for confirmation before making trading decisions'),
              ],
              
              const SizedBox(height: 24),
              
              // Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatbotScreen(
                              initialQuestion: 'Explain the ${pattern.name} candlestick pattern and how to trade it',
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.chat_outlined,color: Colors.white,),
                      label: const Text('Ask Assistant',style: TextStyle(color: Colors.white),),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildImplication(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.arrow_right, size: 20, color: Colors.blue),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text),
          ),
        ],
      ),
    );
  }
}


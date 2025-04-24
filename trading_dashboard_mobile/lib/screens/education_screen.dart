// screens/education_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trading_dashboard_mobile/screens/candlestick_pattern_screen.dart';
import '../providers/education_provider.dart';
import '../widgets/topic_card.dart';
import '../widgets/term_card.dart';
import '../widgets/strategy_card.dart';
import '../widgets/chatbot_widget.dart';

class EducationScreen extends StatefulWidget {
  const EducationScreen({Key? key}) : super(key: key);

  @override
  _EducationScreenState createState() => _EducationScreenState();
}

class _EducationScreenState extends State<EducationScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isBeginnerUser = false;
  bool _showRecommendedSection = true;
  
  @override
  void initState() {
    super.initState();
    // Update tab controller to have 4 tabs
    _tabController = TabController(length: 4, vsync: this);
    
    // Load educational content
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<EducationProvider>(context, listen: false).loadEducationalContent();
      _checkUserExperience();
    });
  }
  
  Future<void> _checkUserExperience() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isBeginnerUser = prefs.getBool('user_experience') ?? false;
    });
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Learn Trading'),
        centerTitle: false,
        bottom: TabBar(
          labelColor: Colors.white,
          indicatorColor: Colors.white,
          controller: _tabController,
          tabs: const [
            Tab(text: 'Basics'),
            Tab(text: 'Dictionary'),
            Tab(text: 'Strategies'),
            Tab(text: 'Patterns'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.chat),
            tooltip: 'Ask Questions',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ChatbotScreen(
                    initialQuestion: 'I\'m new to trading. Can you explain some basics?',
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<EducationProvider>(
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
                    onPressed: provider.loadEducationalContent,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          
          return Column(
            children: [
              // Recommended for Beginners section (only shows for beginners)
              if (_isBeginnerUser && _showRecommendedSection)
                _buildRecommendedSection(provider),
                
              // Tab content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Basics Tab
                    ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: provider.basics.length,
                      itemBuilder: (context, index) {
                        final topic = provider.basics[index];
                        return TopicCard(topic: topic);
                      },
                    ),
                    
                    // Dictionary Tab
                    ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: provider.terms.length,
                      itemBuilder: (context, index) {
                        final term = provider.terms[index];
                        return TermCard(term: term);
                      },
                    ),
                    
                    // Strategies Tab
                    ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: provider.strategies.length,
                      itemBuilder: (context, index) {
                        final strategy = provider.strategies[index];
                        return StrategyCard(strategy: strategy);
                      },
                    ),
                    
                    // Patterns Tab
                    _buildPatternsTab(),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.blue,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ChatbotScreen(
                initialQuestion: 'Please recommend learning resources for beginners',
              ),
            ),
          );
        },
        icon: const Icon(Icons.lightbulb_outline),
        label: const Text('Get Help'),
      ),
    );
  }
  
  Widget _buildRecommendedSection(EducationProvider provider) {
    return Container(
      margin: const EdgeInsets.all(16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.stars, color: Colors.amber),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Recommended for Beginners',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 18),
                onPressed: () {
                  setState(() {
                    _showRecommendedSection = false;
                  });
                },
                tooltip: 'Hide recommendations',
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Get started with these basics:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          
          // Recommended items - these should be your most beginner-friendly content
          _buildRecommendedItem(
            'Understanding Market Trends',
            'Learn how markets move and what drives price changes',
            Icons.trending_up,
            () {
              // Navigate to the specific topic (for now just switch to Basics tab)
              _tabController.animateTo(0);
            },
          ),
          _buildRecommendedItem(
            'Common Trading Terms',
            'Essential vocabulary every trader should know',
            Icons.menu_book,
            () {
              // Switch to Dictionary tab
              _tabController.animateTo(1);
            },
          ),
          _buildRecommendedItem(
            'Basic Candlestick Patterns',
            'Learn to read price charts with visual patterns',
            Icons.show_chart,
            () {
              // Switch to Patterns tab
              _tabController.animateTo(3);
            },
          ),
          _buildRecommendedItem(
            'Ask the Trading Assistant',
            'Get personalized answers to your trading questions',
            Icons.chat_bubble_outline,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ChatbotScreen(
                    initialQuestion: 'What are the most important things for a beginner trader to learn first?',
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildRecommendedItem(String title, String description, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: Colors.blue, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    description,
                    style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
  
 Widget _buildPatternsTab() {
  return SingleChildScrollView(
    padding: const EdgeInsets.all(16.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Card with main content
        Card(
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
                    Icon(Icons.show_chart, color: Colors.blue),
                    SizedBox(width: 8),
                    Text(
                      'Candlestick Patterns',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  'Candlestick patterns are visual formations that can help traders predict future price movements based on historical behavior.',
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 16),
                
                // Image placeholder - with fixed height
                SizedBox(
                  height: 180, // Reduced height
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return Dialog(
                                  child: Container(
                                    width: double.infinity,
                                    height: 400,
                                    decoration: const BoxDecoration(
                                      image: DecorationImage(
                                        image: AssetImage('assets/images/candlestick_pattern.png'),
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset(
                              'assets/images/candlestick_pattern.png',
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return const Center(
                                  child: Icon(Icons.error, color: Colors.red, size: 32),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return Dialog(
                                  child: Container(
                                    width: double.infinity,
                                    height: 400,
                                    decoration: const BoxDecoration(
                                      image: DecorationImage(
                                        image: AssetImage('assets/images/candlestick_image.png'),
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset(
                              'assets/images/candlestick_image.png',
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return const Center(
                                  child: Icon(Icons.error, color: Colors.red, size: 32),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CandlestickPatternsScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Explore All Patterns', style: TextStyle(color: Colors.white)),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward, color: Colors.white),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Preview of most common patterns
        const Text(
          'Key Patterns to Know',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        
        // Pattern list - without Expanded
        _buildPatternPreviewCard(
          'Bullish Engulfing',
          'A bullish reversal pattern that appears in a downtrend when a green candle completely engulfs the previous red candle.',
           Colors.green,
        ),
        _buildPatternPreviewCard(
          'Bearish Engulfing',
          'A bearish reversal pattern that appears in an uptrend when a red candle completely engulfs the previous green candle.',
          Colors.red,
        ),
        _buildPatternPreviewCard(
          'Doji',
          'A candle with a very small body where the opening and closing prices are very close, indicating market indecision.',
          Colors.grey,
        ),
        _buildPatternPreviewCard(
          'Hammer',
          'A bullish reversal pattern with a small body, little or no upper shadow, and a long lower shadow, appearing at the bottom of a downtrend.',
          Colors.green,
        ),
        _buildPatternPreviewCard(
          'Shooting Star',
          'A bearish reversal pattern with a small body, little or no lower shadow, and a long upper shadow, appearing at the top of an uptrend.',
          Colors.red,
        ),
      ],
    ),
  );
}
  Widget _buildPatternPreviewCard(String name, String description, Color color) {
    return Card(
      elevation: 0,
      color: const Color(0xFF252D4A),
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: color.withOpacity(0.3), width: 1),
      ),
      child: ListTile(
        leading: Icon(
          color == Colors.green ? Icons.trending_up :
          color == Colors.red ? Icons.trending_down : 
          Icons.trending_flat,
          color: color,
        ),
        title: Text(
          name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          description,
          style: TextStyle(fontSize: 12, color: Colors.grey[400]),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CandlestickPatternsScreen(),
            ),
          );
        },
      ),
    );
  }
}
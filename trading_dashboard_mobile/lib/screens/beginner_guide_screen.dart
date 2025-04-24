// screens/beginner_guide_screen.dart
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:trading_dashboard_mobile/widgets/chatbot_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BeginnerGuideScreen extends StatefulWidget {
  const BeginnerGuideScreen({Key? key}) : super(key: key);

  @override
  _BeginnerGuideScreenState createState() => _BeginnerGuideScreenState();
}

class _BeginnerGuideScreenState extends State<BeginnerGuideScreen> {
  int _currentStep = 0;
  final int _totalSteps = 5;
  
  final List<Map<String, dynamic>> _guideSteps = [
    {
      'title': 'Welcome to Trading Assistant',
      'description': 'This guide will help you understand the basics of our app and cryptocurrency trading.',
      'icon': Icons.waving_hand,
      'color': Colors.amber,
    },
    {
      'title': 'Learn First, Trade Later',
      'description': 'Start by exploring the Learn tab. Understanding the basics is crucial before making any trading decisions.',
      'icon': Icons.school,
      'color': Colors.blue,
    },
    {
      'title': 'Understanding Signals',
      'description': 'Our app provides BUY, SELL, and HOLD signals based on machine learning analysis. These signals help guide your trading decisions.',
      'icon': Icons.sync_alt,
      'color': Colors.green,
    },
    {
      'title': 'Reading Charts',
      'description': 'The Chart screen shows price movements and signals. Learning to interpret these charts is an essential trading skill.',
      'icon': Icons.show_chart,
      'color': Colors.purple,
    },
    {
      'title': 'Ask for Help',
      'description': 'Use our Trading Assistant chatbot to ask any questions about trading or the app features.',
      'icon': Icons.chat,
      'color': Colors.orange,
    },
  ];
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Beginner\'s Guide'),
        centerTitle: false,
        actions: [
          TextButton(
            onPressed: _markGuideComplete,
            child: const Text('Skip All', style: TextStyle(color: Colors.grey)),
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress indicator
          LinearProgressIndicator(
            value: (_currentStep + 1) / _totalSteps,
            backgroundColor: Colors.grey[800],
            color: Colors.blue,
          ),
          
          // Step counter
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Step ${_currentStep + 1} of $_totalSteps',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          
          // Current step content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: _buildCurrentStep(),
            ),
          ),
          
          // Navigation buttons
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Back button
                if (_currentStep > 0)
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _currentStep--;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[700],
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: const Text('Back', style: TextStyle(color: Colors.white)),
                  )
                else
                  const SizedBox(width: 100),
                
                // Next/Finish button
                ElevatedButton(
                  onPressed: () {
                    if (_currentStep < _totalSteps - 1) {
                      setState(() {
                        _currentStep++;
                      });
                    } else {
                      _markGuideComplete();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  ),
                  child: Text(
                    _currentStep < _totalSteps - 1 ? 'Next' : 'Finish',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCurrentStep() {
    final step = _guideSteps[_currentStep];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Icon
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: step['color'].withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            step['icon'],
            size: 72,
            color: step['color'],
          ),
        ),
        const SizedBox(height: 32),
        
        // Title
        Text(
          step['title'],
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        
        // Description
        Text(
          step['description'],
          style: const TextStyle(
            fontSize: 16,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        
        // Additional content based on current step
        _buildStepSpecificContent(),
      ],
    );
  }
  
  Widget _buildStepSpecificContent() {
    switch (_currentStep) {
      case 0:
        return Card(
          elevation: 0,
          color: const Color(0xFF252D4A),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const Text(
                  'Trading involves risk',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Cryptocurrency markets can be volatile. Always start with small amounts and never invest more than you can afford to lose.',
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ChatbotScreen(
                          initialQuestion: 'What are the biggest risks in cryptocurrency trading for beginners?',
                        ),
                      ),
                    );
                  },
                  child: const Text('Learn About Risks', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        );
        
    case 1:
        return Image(
          image: const AssetImage('assets/images/learn_section.png'),
          height: 200,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => 
              const Icon(Icons.school, size: 100, color: Colors.blue),
        );
        
      case 2:
        return Card(
          elevation: 0,
          color: const Color(0xFF252D4A),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildSignalIndicator('BUY', Colors.green),
                    _buildSignalIndicator('HOLD', Colors.grey),
                    _buildSignalIndicator('SELL', Colors.red),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Signals are suggestions, not guarantees. Always do your own research before making trading decisions.',
                  style: TextStyle(fontStyle: FontStyle.italic, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
        
      case 3:
        return Card(
          elevation: 0,
          color: const Color(0xFF252D4A),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Simple mockup of a price chart
                Container(
                  height: 120,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[700]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: CustomPaint(
                    size: const Size(double.infinity, 120),
                    painter: ChartPainter(),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed('/chart');
                  },
                  child: const Text('Try the Chart Screen', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        );
        
      case 4:
        return Card(
          elevation: 0,
          color: const Color(0xFF252D4A),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const Icon(
                  Icons.chat_bubble_outline,
                  size: 48,
                  color: Colors.blue,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Our AI assistant can answer your trading questions, explain terms, and help you understand market concepts.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ChatbotScreen(),
                      ),
                    );
                  },
                  child: const Text('Try the Assistant', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        );
        
      default:
        return const SizedBox.shrink();
    }
  }
  
  Widget _buildSignalIndicator(String label, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withOpacity(0.5)),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label == 'BUY' ? 'Upward trend' :
          label == 'SELL' ? 'Downward trend' : 'No clear trend',
          style: TextStyle(fontSize: 12, color: Colors.grey[400]),
        ),
      ],
    );
  }
  
  void _markGuideComplete() async {
    // Mark beginner guide as completed
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('beginner_guide_complete', true);
    
    if (mounted) {
      // Navigate back to main screen
      Navigator.of(context).pushReplacementNamed('/home', arguments: {'initialTab': 3}); // Learn tab
    }
  }
}

class ChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    
    final path = Path();
    
    // Starting point
    path.moveTo(0, size.height * 0.7);
    
    // Generate a simple sine wave-like path
    for (int i = 0; i < size.width.toInt(); i++) {
      final x = i.toDouble();
      final y = size.height * (0.5 + 0.2 * Math.sin(i * 0.05) + 0.1 * Math.cos(i * 0.02));
      path.lineTo(x, y);
    }
    
    canvas.drawPath(path, paint);
    
    // Add Buy indicator
    final buyPaint = Paint()
      ..color = Colors.green
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    
    canvas.drawCircle(Offset(size.width * 0.3, size.height * 0.6), 5, buyPaint);
    
    // Add Sell indicator
    final sellPaint = Paint()
      ..color = Colors.red
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    
    canvas.drawCircle(Offset(size.width * 0.7, size.height * 0.3), 5, sellPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

// Helper class for Math operations
class Math {
  static double sin(double x) {
    return math.sin(x);
  }
  
  static double cos(double x) {
    return math.cos(x);
  }
}
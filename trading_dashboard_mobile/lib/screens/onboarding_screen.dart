// screens/onboarding_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isBeginnerUser = false; // Track if user is a beginner
  static const String KEY_ONBOARDING_COMPLETE = 'onboarding_complete';
  static const String KEY_USER_EXPERIENCE = 'user_experience'; // Store user experience level
  
  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: 'Welcome to Trading Assistant',
      description: 'Your smart companion for cryptocurrency trading, designed for both beginners and professionals.',
      image: 'assets/images/onboarding_welcome.png',
      bgColor: Color(0xFF1A2036),
    ),
    OnboardingPage(
      title: 'Trading Signals',
      description: 'Receive BUY and SELL signals powered by machine learning algorithms that analyze market patterns.',
      image: 'assets/images/onboarding_signals.png',
      bgColor: Color(0xFF1A2036),
    ),
    OnboardingPage(
      title: 'Market Insights',
      description: 'Understand market regimes and trends with our visual charts and automated analysis.',
      image: 'assets/images/onboarding_insights.png',
      bgColor: Color(0xFF1A2036),
    ),
    OnboardingPage(
      title: 'Learn as You Go',
      description: 'Access educational content and explanations to help you understand trading concepts and make informed decisions.',
      image: 'assets/images/onboarding_learn.jpg',
      bgColor: Color(0xFF1A2036),
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(KEY_ONBOARDING_COMPLETE, true);
    await prefs.setBool(KEY_USER_EXPERIENCE, _isBeginnerUser);
    
    if (_isBeginnerUser) {
      // Navigate to Learn screen for beginners
      Navigator.of(context).pushReplacementNamed('/home', arguments: {'initialTab': 3}); // 3 is the Learn tab index
    } else {
      // Navigate to Dashboard (default) for experienced users
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Page content
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: _pages.length,
            itemBuilder: (context, index) {
              final page = _pages[index];
              return Container(
                color: page.bgColor,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Image placeholder (in a real app, load actual image)
                    Container(
                      width: 240,
                      height: 240,
                      margin: const EdgeInsets.only(bottom: 40),
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(page.image),
                          fit: BoxFit.cover,
                        ),
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                     
                    ),
                    
                    // Title
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Text(
                        page.title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Description
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40.0),
                      child: Text(
                        page.description,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    
                    // Add experience level question on the last page
                    if (_currentPage == _pages.length - 1) ...[
                      const SizedBox(height: 32),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 40.0),
                        child: Text(
                          'Are you new to cryptocurrency trading?',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _isBeginnerUser = true;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isBeginnerUser ? Colors.blue : Colors.grey[600],
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            ),
                            child: const Text('Yes, I\'m a beginner', style: TextStyle(color: Colors.white)),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _isBeginnerUser = false;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: !_isBeginnerUser ? Colors.blue : Colors.grey[600],
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            ),
                            child: const Text('No, I\'m experienced', style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
          
          // Bottom navigation
          Positioned(
            bottom: 48,
            left: 0,
            right: 0,
            child: Column(
              children: [
                // Page indicator
                SmoothPageIndicator(
                  controller: _pageController,
                  count: _pages.length,
                  effect: const ExpandingDotsEffect(
                    dotHeight: 8,
                    dotWidth: 8,
                    spacing: 8,
                    activeDotColor: Colors.blue,
                    dotColor: Colors.grey,
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Navigation buttons
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Skip button
                      TextButton(
                        onPressed: _completeOnboarding,
                        child: const Text(
                          'Skip',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                      
                      // Next/Done button
                      ElevatedButton(
                        onPressed: () {
                          if (_currentPage == _pages.length - 1) {
                            _completeOnboarding();
                          } else {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                        child: Text(
                          _currentPage == _pages.length - 1 ? 'Get Started' : 'Next',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingPage {
  final String title;
  final String description;
  final String image;
  final Color bgColor;

  OnboardingPage({
    required this.title,
    required this.description,
    required this.image,
    required this.bgColor,
  });
}
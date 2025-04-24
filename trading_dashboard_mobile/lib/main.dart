// main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trading_dashboard_mobile/screens/candlestick_pattern_screen.dart';
import 'package:trading_dashboard_mobile/screens/beginner_guide_screen.dart';

import 'screens/onboarding_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/chart_screen.dart';
import 'screens/signals_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/guide_screen.dart';
import 'screens/education_screen.dart';
import 'providers/trading_provider.dart';
import 'providers/education_provider.dart';
import 'providers/signal_metrics_provider.dart';
import 'providers/candlestick_patterns_provider.dart';
import 'utils/api_service.dart';
import 'utils/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize notifications
  await NotificationService.initialize();
  
  // Initialize shared preferences
  final prefs = await SharedPreferences.getInstance();
  
  // Check if onboarding is completed
  final bool onboardingCompleted = prefs.getBool('onboarding_complete') ?? false;
  
  // Create API service
  final apiService = ApiService();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => TradingProvider(
            apiService: apiService,
            prefs: prefs,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => EducationProvider(
            apiService: apiService,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => SignalMetricsProvider(
            apiService: apiService,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => CandlestickPatternsProvider(
            apiService: apiService,
          ),
        ),
      ],
      child: TradingApp(showOnboarding: !onboardingCompleted),
    ),
  );
}

class TradingApp extends StatelessWidget {
  final bool showOnboarding;
  
  const TradingApp({
    Key? key,
    required this.showOnboarding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trading Dashboard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        primaryColor: const Color(0xFF1F2937),
        scaffoldBackgroundColor: const Color(0xFF1A2036),
        cardColor: const Color(0xFF252D4A),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF252D4A),
          elevation: 0,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF252D4A),
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.grey,
        ),
      ),
      home: showOnboarding 
          ? const OnboardingScreen() 
          : const HomeScreen(),
      routes: {
        '/home': (context) {
          // Extract arguments if provided
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
          final initialTabIndex = args?['initialTab'] as int?;
          return HomeScreen(initialTabIndex: initialTabIndex);
        },
        '/dashboard': (context) => const DashboardScreen(),
        '/chart': (context) => const ChartScreen(),
        '/signals': (context) => const SignalsScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/guide': (context) => const GuideScreen(),
        '/education': (context) => const EducationScreen(),
        '/candlestick_patterns': (context) => const CandlestickPatternsScreen(),
        '/beginner_guide': (context) => const BeginnerGuideScreen(),
      },
    );
  }
}

class HomeScreen extends StatefulWidget {
  final int? initialTabIndex;
  
  const HomeScreen({
    Key? key, 
    this.initialTabIndex,
  }) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late int _selectedIndex;
  late PageController _pageController;
  bool _firstLoad = true;
  bool _showBeginnerTips = false;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const ChartScreen(),
    const SignalsScreen(),
    const EducationScreen(), // Learn screen
    const SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    
    // Set initial tab index (default to 0 if not provided)
    _selectedIndex = widget.initialTabIndex ?? 0;
    _pageController = PageController(initialPage: _selectedIndex);
    
    // Check if user is a beginner
    _checkUserExperience();
    
    // Load data on first launch
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_firstLoad) {
        _loadData();
        _firstLoad = false;
        
        // Show beginner tips popup if needed
        if (_showBeginnerTips && _selectedIndex == 3) { // If on Learn tab
          _showBeginnerTipsDialog();
        }
      }
    });
  }
  
  Future<void> _checkUserExperience() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _showBeginnerTips = prefs.getBool('user_experience') ?? false;
    });
  }
  
  void _showBeginnerTipsDialog() {
    // Show beginner tips dialog after a short delay
    Future.delayed(const Duration(milliseconds: 500), () {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.lightbulb_outline, color: Colors.amber),
              SizedBox(width: 8),
              Text('Welcome to Trading Assistant!'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Since you\'re new to trading, we\'ve brought you to the Learn section first. Here you can:',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              _buildTipItem('Explore trading basics and terms'),
              _buildTipItem('Learn about market signals and strategies'),
              _buildTipItem('Understand candlestick patterns'),
              _buildTipItem('Ask questions to our AI assistant'),
              SizedBox(height: 16),
              Text(
                'Take your time to learn before moving to the dashboard.',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Got it!'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/beginner_guide');
              },
              child: Text('Show Me More'),
            ),
          ],
        ),
      );
    });
  }
  
  Widget _buildTipItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green, size: 16),
          SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      await Provider.of<TradingProvider>(context, listen: false).loadAllData();
    } catch (e) {
      // Error already handled in provider
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _pageController.jumpToPage(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.show_chart),
            label: 'Chart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.sync_alt),
            label: 'Signals',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            label: 'Learn',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget? _buildFloatingActionButton() {
    // Show Learn FAB if user is beginner and not on Learn tab
    if (_showBeginnerTips && _selectedIndex != 3) {
      return FloatingActionButton.extended(
        onPressed: () => _onItemTapped(3), // Switch to Learn tab
        tooltip: 'Go to Learn Section',
        backgroundColor: Colors.green,
        icon: const Icon(Icons.school),
        label: const Text('Learn'),
      );
    }
    
    // Only show refresh FAB on dashboard, chart, and signals screens
    if (_selectedIndex <= 2) {
      return FloatingActionButton(
        onPressed: () => _loadData(),
        tooltip: 'Refresh Data',
        backgroundColor: Colors.blue,
        child: const Icon(Icons.refresh),
      );
    }
    
    return null;
  }
}
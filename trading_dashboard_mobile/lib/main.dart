import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'providers/trading_provider.dart';
import 'screens/dashboard_screen.dart';
import 'screens/chart_screen.dart';
import 'screens/signals_screen.dart';
import 'screens/settings_screen.dart';
import 'utils/api_service.dart';
import 'utils/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize services
  await NotificationService.initialize();
  final prefs = await SharedPreferences.getInstance();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => TradingProvider(
            apiService: ApiService(),
            prefs: prefs,
          ),
        ),
      ],
      child: const TradingApp(),
    ),
  );
}

class TradingApp extends StatelessWidget {
  const TradingApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trading Model',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF1A2035),
        cardColor: const Color(0xFF252D4A),
        fontFamily: GoogleFonts.poppins().fontFamily,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      ),
      home: const MainScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  late PageController _pageController;
  bool _isConnected = true;
  
  final List<Widget> _screens = [
    const DashboardScreen(),
    const ChartScreen(),
    const SignalsScreen(),
    const SettingsScreen(),
  ];
  
  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
    _checkConnectivity();
    
    // Load data when app starts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TradingProvider>().loadAllData();
    });
  }
  
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
  
  Future<void> _checkConnectivity() async {
    final result = await Connectivity().checkConnectivity();
    setState(() {
      _isConnected = result != ConnectivityResult.none;
    });
    
    // Listen for connectivity changes
    Connectivity().onConnectivityChanged.listen((result) {
      final isConnected = result != ConnectivityResult.none;
      
      if (!_isConnected && isConnected) {
        // Re-fetch data when connection is restored
        context.read<TradingProvider>().loadAllData();
      }
      
      setState(() {
        _isConnected = isConnected;
      });
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Connectivity indicator
            if (!_isConnected)
              Container(
                width: double.infinity,
                color: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.wifi_off, size: 16),
                    SizedBox(width: 8),
                    Text('No internet connection'),
                  ],
                ),
              ),
            
            // Main content
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                children: _screens,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
            _pageController.animateToPage(
              index,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF1A2035),
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
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
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
      floatingActionButton: _currentIndex != 3
          ? FloatingActionButton(
              onPressed: () {
                // Show loading indicator
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Refreshing data...'),
                    duration: Duration(seconds: 2),
                  ),
                );
                
                // Reload data
                context.read<TradingProvider>().loadAllData(forceRefresh: true);
              },
              child: const Icon(Icons.refresh),
              tooltip: 'Refresh data',
            )
          : null,
    );
  }
}
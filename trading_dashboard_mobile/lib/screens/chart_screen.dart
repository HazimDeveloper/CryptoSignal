// screens/chart_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:trading_dashboard_mobile/widgets/crrypto_app_bar.dart';

import '../providers/trading_provider.dart';
import '../models/price_data.dart';
import '../models/signal_data.dart';
import '../widgets/market_regime_widget.dart';

class ChartScreen extends StatefulWidget {
  const ChartScreen({Key? key}) : super(key: key);

  @override
  _ChartScreenState createState() => _ChartScreenState();
}

class _ChartScreenState extends State<ChartScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _timeRange = '1M'; // Default to 1 month
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CryptoAppBar(
      title: 'Price Chart',
      showGradient: true,
      bottom: TabBar(
        labelColor: Colors.white,
        controller: _tabController,
        tabs: const [
          Tab(text: 'Price Chart'),
          Tab(text: 'Market Regimes'),
        ],
        indicatorColor: Colors.blue,
        indicatorWeight: 3,
        indicatorSize: TabBarIndicatorSize.label,
      ),
    ) ,
      body: Consumer<TradingProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.priceData.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (provider.hasError && provider.priceData.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text('Error: ${provider.errorMessage}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.loadAllData(forceRefresh: true),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          
          return TabBarView(
            controller: _tabController,
            children: [
              // Price Chart Tab
              _buildPriceChartTab(provider),
              
              // Market Regimes Tab
              MarketRegimeWidget(regimes: provider.regimes),
            ],
          );
        },
      ),
    );
  }
  
  Widget _buildPriceChartTab(TradingProvider provider) {
    final priceData = _getFilteredPriceData(provider.priceData);
    final signals = _getFilteredSignals(provider.signals);
    
    if (priceData.isEmpty) {
      return const Center(child: Text('No price data available'));
    }
    
    return Column(
      children: [
        // Time range selector
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildTimeRangeButton('1W', '1 Week'),
              _buildTimeRangeButton('1M', '1 Month'),
              _buildTimeRangeButton('3M', '3 Months'),
              _buildTimeRangeButton('ALL', 'All'),
            ],
          ),
        ),
        
        // Price chart
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8.0, 8.0, 0.0, 8.0), // Removed right padding
            child: LineChart(
              _createLineChartData(priceData, signals),
            ),
          ),
        ),
        
        // Chart legend
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem('Price', Colors.blue),
              const SizedBox(width: 16),
              _buildLegendItem('Buy Signal', Colors.green),
              const SizedBox(width: 16),
              _buildLegendItem('Sell Signal', Colors.red),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildTimeRangeButton(String range, String label) {
    final isSelected = _timeRange == range;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2.0),
      child: ChoiceChip(
        label: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isSelected ? Colors.white : Colors.grey[300],
          ),
        ),
        selected: isSelected,
        selectedColor: Colors.blue,
        onSelected: (selected) {
          if (selected) {
            setState(() {
              _timeRange = range;
            });
          }
        },
      ),
    );
  }
  
  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 4,
          color: color,
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 12,
          ),
        ),
      ],
    );
  }
  
  List<PriceData> _getFilteredPriceData(List<PriceData> allData) {
    if (allData.isEmpty) return [];
    
    final now = DateTime.now();
    
    switch (_timeRange) {
      case '1W':
        final weekAgo = now.subtract(const Duration(days: 7));
        return allData.where((data) => data.timestamp.isAfter(weekAgo)).toList();
      case '1M':
        final monthAgo = DateTime(now.year, now.month - 1, now.day);
        return allData.where((data) => data.timestamp.isAfter(monthAgo)).toList();
      case '3M':
        final threeMonthsAgo = DateTime(now.year, now.month - 3, now.day);
        return allData.where((data) => data.timestamp.isAfter(threeMonthsAgo)).toList();
      case 'ALL':
      default:
        return allData;
    }
  }
  
  List<SignalData> _getFilteredSignals(List<SignalData> allSignals) {
    if (allSignals.isEmpty) return [];
    
    final now = DateTime.now();
    final activeSignals = allSignals.where((s) => s.signal == 'BUY' || s.signal == 'SELL').toList();
    
    switch (_timeRange) {
      case '1W':
        final weekAgo = now.subtract(const Duration(days: 7));
        return activeSignals.where((data) => data.timestamp.isAfter(weekAgo)).toList();
      case '1M':
        final monthAgo = DateTime(now.year, now.month - 1, now.day);
        return activeSignals.where((data) => data.timestamp.isAfter(monthAgo)).toList();
      case '3M':
        final threeMonthsAgo = DateTime(now.year, now.month - 3, now.day);
        return activeSignals.where((data) => data.timestamp.isAfter(threeMonthsAgo)).toList();
      case 'ALL':
      default:
        return activeSignals;
    }
  }
  
  LineChartData _createLineChartData(List<PriceData> priceData, List<SignalData> signals) {
    // Find min and max values for Y axis
    final minY = priceData.map((data) => data.price).reduce(
      (value, element) => value < element ? value : element
    ) * 0.95; // Add 5% padding
    
    final maxY = priceData.map((data) => data.price).reduce(
      (value, element) => value > element ? value : element
    ) * 1.05; // Add 5% padding
    
    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: 1,
        verticalInterval: 1,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: Colors.grey[800]!,
            strokeWidth: 1,
          );
        },
        getDrawingVerticalLine: (value) {
          return FlLine(
            color: Colors.grey[800]!,
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 22, // Reduced from 30
            interval: _getXAxisInterval(priceData.length),
            getTitlesWidget: (value, meta) {
              if (value < 0 || value >= priceData.length) {
                return const Text('');
              }
              final date = priceData[value.toInt()].timestamp;
              return Padding(
                padding: const EdgeInsets.only(top: 4.0), // Reduced from 8.0
                child: Text(
                  DateFormat(_getDateFormat()).format(date),
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontWeight: FontWeight.bold,
                    fontSize: 8, // Reduced from 10
                  ),
                ),
              );
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: _calculateYAxisInterval(minY, maxY),
            reservedSize: 38, // Reduced from 42
            getTitlesWidget: (value, meta) {
              return Text(
                '\$${value.toStringAsFixed(0)}',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontWeight: FontWeight.bold,
                  fontSize: 8, // Reduced from 10
                ),
              );
            },
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: Colors.grey[800]!),
      ),
      minX: 0,
      maxX: (priceData.length - 1).toDouble(),
      minY: minY,
      maxY: maxY,
      lineBarsData: [
        LineChartBarData(
          spots: List.generate(priceData.length, (index) {
            return FlSpot(
              index.toDouble(),
              priceData[index].price,
            );
          }),
          isCurved: true,
          color: Colors.blue,
          barWidth: 2,
          isStrokeCapRound: true,
          dotData: const FlDotData(
            show: false,
          ),
          belowBarData: BarAreaData(
            show: true,
            color: Colors.blue.withOpacity(0.2),
          ),
        ),
      ],
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          getTooltipColor: (LineBarSpot spot) => Colors.grey[800]!,
          tooltipMargin: 8, // Reduced from default
          getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
            return touchedBarSpots.map((barSpot) {
              final index = barSpot.x.toInt();
              final date = priceData[index].timestamp;
              
              return LineTooltipItem(
                '${DateFormat('MMM dd').format(date)}\n', // Shortened date format
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12, // Smaller font
                ),
                children: [
                  TextSpan(
                    text: '\$${barSpot.y.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 11, // Smaller font
                    ),
                  ),
                ],
              );
            }).toList();
          },
        ),
        handleBuiltInTouches: true,
        getTouchLineStart: (data, index) => 0,
      ),
      // Add buy/sell signal markers
      extraLinesData: ExtraLinesData(
        horizontalLines: [],
        verticalLines: _getSignalLines(priceData, signals),
      ),

    );
  }
  
  List<VerticalLine> _getSignalLines(List<PriceData> priceData, List<SignalData> signals) {
    final lines = <VerticalLine>[];
    
    for (final signal in signals) {
      final signalTime = signal.timestamp;
      final isBuy = signal.signal == 'BUY';
      
      // Find closest data point
      int? closestIndex;
      Duration smallestDiff = const Duration(days: 365);
      
      for (int i = 0; i < priceData.length; i++) {
        final chartTime = priceData[i].timestamp;
        final diff = signalTime.difference(chartTime).abs();
        
        if (diff < smallestDiff) {
          smallestDiff = diff;
          closestIndex = i;
        }
      }
      
      if (closestIndex != null) {
        lines.add(VerticalLine(
          x: closestIndex.toDouble(),
          color: isBuy ? Colors.green : Colors.red,
          strokeWidth: 1.5,
          dashArray: [4, 4], // Make it dashed
          label: VerticalLineLabel(
            show: true,
            style: TextStyle(
              color: isBuy ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
              fontSize: 8, // Reduced from 10
            ),
            labelResolver: (line) => isBuy ? 'BUY' : 'SELL',
            alignment: Alignment.topCenter,
          ),
        ));
      }
    }
    
    return lines;
  }
  
  double _getXAxisInterval(int dataLength) {
    if (dataLength <= 10) return 1;
    if (dataLength <= 30) return 7; // Increased from 5 to show fewer labels
    if (dataLength <= 60) return 14; // Increased from 10 to show fewer labels
    return (dataLength / 5).floor().toDouble(); // Show about 5 labels total
  }
  
  String _getDateFormat() {
    switch (_timeRange) {
      case '1W':
        return 'M/d'; // Shortened
      case '1M':
        return 'M/d'; // Shortened
      case '3M':
      case 'ALL':
      default:
        return 'M/d'; // Shortened
    }
  }
  
  double _calculateYAxisInterval(double minY, double maxY) {
    final range = maxY - minY;
    if (range <= 100) return 10;
    if (range <= 500) return 50;
    if (range <= 1000) return 100;
    if (range <= 5000) return 500;
    return 1000;
  }
}
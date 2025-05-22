// screens/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:trading_dashboard_mobile/widgets/crrypto_app_bar.dart';

import '../providers/trading_provider.dart';
import '../widgets/metric_card.dart';
import '../widgets/signal_distribution_widget.dart';
import '../widgets/price_summary_widget.dart';
import '../models/signal_data.dart';
import '../widgets/chatbot_widget.dart'; 

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CryptoAppBar(
      title: 'Crypto Signal',
      showGradient: true,
      actions: [
        // Live price ticker (optional)
        Container(
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.blue.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.currency_bitcoin, size: 16, color: Colors.amber),
              const SizedBox(width: 4),
              const Text(
                'BTC/USDT',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.arrow_upward,
                size: 12,
                color: Colors.green,
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        
      ],
    ),
      body: Consumer<TradingProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.priceData.isEmpty) {
            return _buildLoadingState();
          }

          if (provider.hasError && provider.priceData.isEmpty) {
            return _buildErrorState(context, provider.errorMessage);
          }

          return RefreshIndicator(
            onRefresh: () => provider.loadAllData(forceRefresh: true),
            child: _buildDashboard(context, provider),
          );
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[800]!,
      highlightColor: Colors.grey[700]!,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 24,
                width: 200,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 16),
              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: List.generate(4, (_) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 24),
              Container(
                height: 24,
                width: 160,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String errorMessage) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Error loading data',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                context.read<TradingProvider>().loadAllData(forceRefresh: true);
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboard(BuildContext context, TradingProvider provider) {
    final performance = provider.performance;
    final signals = provider.getActiveSignals();

    // Get the most recent price data
    final latestPrice =
        provider.priceData.isNotEmpty ? provider.priceData.last.price : 0.0;

    // Calculate 24h price change if we have enough data
    double priceChange24h = 0.0;
    if (provider.priceData.length > 1) {
      final previousDayIndex = provider.priceData.length - 2;
      priceChange24h =
          (latestPrice - provider.priceData[previousDayIndex].price) /
          provider.priceData[previousDayIndex].price *
          100;
    }

    // Get the latest signal
    final latestSignal = signals.isNotEmpty ? signals.last : null;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Last updated indicator
          if (provider.lastUpdated != null) ...[
            Row(
              children: [
                const Icon(Icons.access_time, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'Last updated: ${DateFormat('MMM dd, HH:mm').format(provider.lastUpdated!)}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (provider.isLoading) ...[
                  const SizedBox(width: 8),
                  const SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),
          ],

          // Performance indicator
          if (performance != null) ...[
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color:
                      performance.meetsCriteria
                          ? Colors.green[800]
                          : Colors.red[800],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  performance.meetsCriteria
                      ? 'Meeting All Success Criteria'
                      : 'Not Meeting All Criteria',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Price summary
          PriceSummaryWidget(
            latestPrice: latestPrice,
            priceChange24h: priceChange24h,
            latestSignal: latestSignal,
          ),

          const SizedBox(height: 24),

          // Performance metrics
          const Text(
            'Performance Metrics',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              // Use responsive GridView with maximum width constraint
              double cardWidth = (constraints.maxWidth - 16) / 2;
              return GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                shrinkWrap: true,
                childAspectRatio:
                    cardWidth / 160, // Further increased height to fit content
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  // Sharpe ratio card
                  MetricCard(
  title: 'Sharpe Ratio',
  value: performance?.sharpeRatio.toStringAsFixed(2) ?? '0.00',
  subvalue: 'Target: ≥ 1.8',
  icon: Icons.assessment,
  valueColor: performance?.meetsSharpeRatio ?? false ? Colors.green : Colors.red,
  // Add this onInfoPressed parameter and function
  onInfoPressed: () {
    // Navigate to chatbot with pre-filled question
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatbotScreen(
          initialQuestion: 'What is Sharpe Ratio and why is it important?',
        ),
      ),
    );
  },
),

                  // Max drawdown card
                  MetricCard(
                    title: 'Max Drawdown',
                    value:
                        performance != null
                            ? '${(performance.maxDrawdown * 100).toStringAsFixed(2)}%'
                            : '0.00%',
                    subvalue: 'Target: ≤ 40%',
                    icon: Icons.trending_down,
                    valueColor:
                        performance != null && performance.meetsDrawdown
                            ? Colors.green
                            : Colors.red,
                  ),

                  // Trade frequency card
                  MetricCard(
                    title: 'Trade Frequency',
                    value:
                        performance != null
                            ? '${(performance.tradeFrequency * 100).toStringAsFixed(2)}%'
                            : '0.00%',
                    subvalue: 'Target: ≥ 3%',
                    icon: Icons.sync_alt,
                    valueColor:
                        performance != null && performance.meetsFrequency
                            ? Colors.green
                            : Colors.red,
                  ),

                  // Signal distribution card
                  SignalDistributionWidget(signals: signals),
                ],
              );
            },
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildRecentSignalsWidget(
    BuildContext context,
    List<SignalData> signals,
  ) {
    if (signals.isEmpty) {
      return Card(
        elevation: 0,
        color: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: const Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(
            child: Text(
              'No recent signals',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ),
      );
    }

    return Card(
      elevation: 0,
      color: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ...signals
                .take(3)
                .map((signal) => _buildSignalItem(context, signal)),
            if (signals.length > 3) ...[
              const Divider(),

              // Fix for the "View All Signals" button in dashboard_screen.dart
              // Replace the existing TextButton in _buildRecentSignalsWidget method with this:
              TextButton(
                onPressed: () {
                  // Instead of trying to use TabController, navigate directly
                  // This assumes you have a bottom navigation bar with Signals tab
                  // or you can use Navigator to push the Signals screen

                  // Option 1: If you have a bottom navigation bar:
                  // Find the parent scaffold that contains the bottom navigation
                  final scaffoldState = ScaffoldMessenger.of(context);

                  // Navigate to Signals tab (assuming index 2 is Signals)
                  // You would need to replace this with your actual bottom navigation controller
                  try {
                    // This approach needs your main navigation controller
                    // If your app uses something like a PageController, IndexedStack,
                    // or some state management approach to control the bottom nav:

                    // Example if you're using a Provider to manage the selected index:
                    // Provider.of<NavigationProvider>(context, listen: false).selectTab(2);

                    // For simplicity in this example, we'll just show a snackbar
                    // and you can implement the actual navigation logic
                    scaffoldState.showSnackBar(
                      const SnackBar(
                        content: Text('Navigating to Signals tab...'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  } catch (e) {
                    // Option 2: If the above doesn't work, use direct navigation:
                    Navigator.of(context).pushNamed('/signals');
                    // or Navigator.of(context).push(MaterialPageRoute(builder: (_) => SignalsScreen()));
                  }
                },
                child: const Text('View All Signals'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSignalItem(BuildContext context, SignalData signal) {
    final isBuy = signal.signal == 'BUY';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color:
                  isBuy
                      ? Colors.green.withOpacity(0.2)
                      : Colors.red.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isBuy ? Icons.arrow_upward : Icons.arrow_downward,
              color: isBuy ? Colors.green : Colors.red,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('MMM dd, yyyy HH:mm').format(signal.timestamp),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${signal.signal} Signal',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isBuy ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Confidence',
                style: TextStyle(fontSize: 12, color: Colors.grey[400]),
              ),
              Text(
                '${signal.confidence.toStringAsFixed(1)}%',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

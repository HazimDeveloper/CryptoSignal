// screens/signals_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:trading_dashboard_mobile/screens/signal_details_screen.dart';
import 'package:trading_dashboard_mobile/widgets/chatbot_widget.dart';
import 'package:trading_dashboard_mobile/widgets/crrypto_app_bar.dart';

import '../providers/trading_provider.dart';
import '../models/signal_data.dart';

class SignalsScreen extends StatefulWidget {
  const SignalsScreen({Key? key}) : super(key: key);

  @override
  _SignalsScreenState createState() => _SignalsScreenState();
}

class _SignalsScreenState extends State<SignalsScreen> {
  String _filterType = 'All'; // 'All', 'Buy', 'Sell'
  void _explainSignal(SignalData signal) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ChatbotScreen(
        initialQuestion: 'Explain this ${signal.signal} signal with ${signal.confidence.toStringAsFixed(1)}% confidence from ${DateFormat('MMM dd').format(signal.timestamp)}',
      ),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CryptoAppBar(
      title: 'Trading Signals',
      showGradient: true,
      actions: [
        // Filter icon
        PopupMenuButton<String>(
          icon: const Icon(Icons.filter_list),
          tooltip: 'Filter signals',
          onSelected: (value) {
            setState(() {
              _filterType = value;
            });
          },
          itemBuilder:
              (context) => [
                const PopupMenuItem(value: 'All', child: Text('All Signals')),
                const PopupMenuItem(value: 'BUY', child: Text('Buy Signals')),
                const PopupMenuItem(
                  value: 'SELL',
                  child: Text('Sell Signals'),
                ),
              ],
        ),
      ],
    ),
      body: Consumer<TradingProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.signals.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.hasError && provider.signals.isEmpty) {
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

          List<SignalData> signals = provider.getActiveSignals().where((signal) {
          if (_filterType == 'All') return true;
          return signal.signal == _filterType;
        }).toList();

        signals.sort((a, b) => b.timestamp.compareTo(a.timestamp));

          if (signals.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.search_off, color: Colors.grey, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    _filterType == 'All'
                        ? 'No trading signals available'
                        : 'No $_filterType signals available',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.loadAllData(forceRefresh: true),
                    child: const Text('Refresh Data'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Signal type filter chips
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildFilterChip('All'),
                    const SizedBox(width: 8),
                    _buildFilterChip('BUY'),
                    const SizedBox(width: 8),
                    _buildFilterChip('SELL'),
                  ],
                ),
              ),

              // Signal count indicator
                Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Text(
                    '${signals.length} signal${signals.length != 1 ? 's' : ''} found',
                    style: TextStyle(color: Colors.grey[400], fontSize: 14),
                  ),
                  const Spacer(),
                  if (provider.lastUpdated != null)
                    Text(
                      'Updated: ${DateFormat('MMM dd, HH:mm').format(provider.lastUpdated!)}',
                      style: TextStyle(color: Colors.grey[400], fontSize: 12),
                    ),
                ],
              ),
            ),

              // Signals list
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(8.0),
                itemCount: signals.length,
                itemBuilder: (context, index) {
                  final signal = signals[index];
                  return _buildSignalCard(signal);
                },
              ),
            ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterChip(String type) {
    final isSelected = _filterType == type;

    return ChoiceChip(
      label: Text(
        type,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.grey[300],
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      selectedColor:
          type == 'BUY'
              ? Colors.green
              : type == 'SELL'
              ? Colors.red
              : Colors.blue,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _filterType = type;
          });
        }
      },
    );
  }

  Widget _buildSignalCard(SignalData signal) {
  final isBuy = signal.signal == 'BUY';
  final signalColor = isBuy ? Colors.green : Colors.red;
  final icon = isBuy ? Icons.arrow_upward : Icons.arrow_downward;

  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SignalDetailsScreen(signal: signal),
        ),
      );
    },
    child: Card(
      elevation: 0,
      color: const Color(0xFF252D4A),
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: signalColor.withOpacity(0.5), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with signal type and date
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: signalColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      Icon(icon, color: signalColor, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        signal.signal,
                        style: TextStyle(
                          color: signalColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Text(
                  DateFormat('MMM dd, yyyy').format(signal.timestamp),
                  style: TextStyle(color: Colors.grey[400], fontSize: 14),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Time and confidence
            Row(
              children: [
                const Icon(Icons.access_time, size: 16, color: Colors.grey),
                const SizedBox(width: 6),
                Text(
                  DateFormat('HH:mm').format(signal.timestamp),
                  style: TextStyle(color: Colors.grey[300], fontSize: 14),
                ),
                const Spacer(),
                const Text(
                  'Confidence:',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getConfidenceColor(
                      signal.confidence,
                    ).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${signal.confidence.toStringAsFixed(1)}%',
                    style: TextStyle(
                      color: _getConfidenceColor(signal.confidence),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Predicted return
            if (signal.predictedReturn != null) ...[
              Row(
                children: [
                  const Text(
                    'Predicted Return:',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${(signal.predictedReturn! * 100).toStringAsFixed(2)}%',
                    style: TextStyle(
                      color:
                          signal.predictedReturn! >= 0
                              ? Colors.green
                              : Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                      icon: const Icon(Icons.help_outline, size: 16,color: Colors.white,),
                      label: const Text(
                        'Explain',
                        style: TextStyle(fontSize: 12,color: Colors.white),
                      ),
                      onPressed: () => _explainSignal(signal),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                    // NEW: View Details Button
                    TextButton.icon(
                      icon: const Icon(Icons.analytics_outlined, size: 16,color: Colors.white,),
                      label: const Text(
                        'Details',
                        style: TextStyle(fontSize: 12,color: Colors.white),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SignalDetailsScreen(signal: signal),
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    ),
  );
}

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 75) {
      return Colors.green;
    } else if (confidence >= 50) {
      return Colors.amber;
    } else {
      return Colors.red;
    }
  }
}

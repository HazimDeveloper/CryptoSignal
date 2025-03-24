// screens/signals_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../providers/trading_provider.dart';
import '../models/signal_data.dart';

class SignalsScreen extends StatelessWidget {
  const SignalsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trading Signals'),
        centerTitle: false,
      ),
      body: Consumer<TradingProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.signals.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          
          final activeSignals = provider.getActiveSignals();
          
          if (activeSignals.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.signal_cellular_alt, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'No trading signals yet',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Signals will appear here when generated',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  if (provider.hasError) ...[
                    Text(
                      'Error: ${provider.errorMessage}',
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                  ],
                  ElevatedButton.icon(
                    onPressed: () => provider.loadAllData(forceRefresh: true),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Refresh Data'),
                  ),
                ],
              ),
            );
          }
          
          return RefreshIndicator(
            onRefresh: () => provider.loadAllData(forceRefresh: true),
            child: _buildSignalsList(context, activeSignals),
          );
        },
      ),
    );
  }
  
  Widget _buildSignalsList(BuildContext context, List<SignalData> signals) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // Signal statistics
        _buildSignalStats(signals),
        
        const SizedBox(height: 24),
        
        // Signals list
        ...signals.map((signal) => _buildSignalCard(context, signal)).toList(),
        
        // Bottom padding
        const SizedBox(height: 16),
      ],
    );
  }
  
  Widget _buildSignalStats(List<SignalData> signals) {
    // Count buy and sell signals
    final buySignals = signals.where((s) => s.signal == 'BUY').length;
    final sellSignals = signals.where((s) => s.signal == 'SELL').length;
    final total = signals.length;
    
    // Calculate average confidence
    final avgConfidence = signals.isNotEmpty
        ? signals.map((s) => s.confidence).reduce((a, b) => a + b) / signals.length
        : 0.0;
    
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: const Color(0xFF252D4A),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Signal Summary',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('Total Signals', total.toString()),
                _buildStatItem('Buy Signals', buySignals.toString(), Colors.green),
                _buildStatItem('Sell Signals', sellSignals.toString(), Colors.red),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildStatItem(
                  'Average Confidence', 
                  '${avgConfidence.toStringAsFixed(1)}%',
                  Colors.blue
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatItem(String label, String value, [Color? valueColor]) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[400],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }
  
  Widget _buildSignalCard(BuildContext context, SignalData signal) {
    final isBuy = signal.signal == 'BUY';
    
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: const Color(0xFF252D4A),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isBuy ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isBuy ? Icons.arrow_upward : Icons.arrow_downward,
                        color: isBuy ? Colors.green : Colors.red,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${signal.signal} SIGNAL',
                        style: TextStyle(
                          color: isBuy ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Text(
                  DateFormat('MMM dd, yyyy').format(signal.timestamp),
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSignalDetail('Time', DateFormat('HH:mm').format(signal.timestamp)),
                _buildSignalDetail('Confidence', '${signal.confidence.toStringAsFixed(1)}%'),
                if (signal.predictedReturn != null)
                  _buildSignalDetail(
                    'Expected Return',
                    '${signal.predictedReturn! >= 0 ? '+' : ''}${(signal.predictedReturn! * 100).toStringAsFixed(2)}%',
                    signal.predictedReturn! >= 0 ? Colors.green : Colors.red,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSignalDetail(String label, String value, [Color? valueColor]) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[400],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
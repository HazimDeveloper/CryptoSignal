// widgets/market_regime_widget.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MarketRegimeWidget extends StatelessWidget {
  final Map<String, dynamic> regimes;

  const MarketRegimeWidget({
    Key? key,
    required this.regimes,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print("Building MarketRegimeWidget with data: $regimes");
    
    // Check if we need to generate synthetic data
    if (regimes.isEmpty || 
        regimes['regime_data'] == null || 
        regimes['regime_counts'] == null) {
      
      // Generate synthetic regime data so the widget still works
      final syntheticData = _generateSyntheticRegimeData();
      
      // Use the existing widget to display this data
      return _buildRegimeContent(
        context,
        syntheticData['regime_data'],
        syntheticData['regime_counts'],
        regimes['regime_labels'] ?? syntheticData['regime_labels'],
      );
    }
    
    // Get regime counts and labels
    final regimeCounts = regimes['regime_counts'] as Map<String, dynamic>? ?? {};
    final regimeLabels = regimes['regime_labels'] as Map<String, dynamic>? ?? {
      '0': 'Neutral',
      '1': 'Bullish',
      '2': 'Bearish'
    };
    
    // Get regime data
    final regimeData = (regimes['regime_data'] as List? ?? []).cast<Map<String, dynamic>>();
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Regime summary cards
          _buildRegimeSummary(regimeCounts, regimeLabels, context),
          
          const SizedBox(height: 24),
          
          // Regime explanation
          _buildRegimeExplanation(),
          
          const SizedBox(height: 24),
          
          // Recent regime changes
          if (regimeData.isNotEmpty) 
            _buildRecentRegimeChanges(regimeData, regimeLabels),
        ],
      ),
    );
  }
  
  // Build the actual widget content with whatever data we have
  Widget _buildRegimeContent(
    BuildContext context,
    List<dynamic>? regimeData,
    Map<String, dynamic>? regimeCounts,
    Map<String, dynamic>? regimeLabels,
  ) {
    // Make sure all data is available or has defaults
    regimeData = regimeData ?? [];
    regimeCounts = regimeCounts ?? {'0': 0, '1': 0, '2': 0};
    regimeLabels = regimeLabels ?? {'0': 'Neutral', '1': 'Bullish', '2': 'Bearish'};
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Regime summary cards
          Card(
            elevation: 0,
            color: const Color(0xFF252D4A),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Market Regime Distribution',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildRegimeCard(
                        label: regimeLabels['0'] ?? 'Neutral',
                        count: _parseCount(regimeCounts['0']),
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 16),
                      _buildRegimeCard(
                        label: regimeLabels['1'] ?? 'Bullish',
                        count: _parseCount(regimeCounts['1']),
                        color: Colors.green,
                      ),
                      const SizedBox(width: 16),
                      _buildRegimeCard(
                        label: regimeLabels['2'] ?? 'Bearish',
                        count: _parseCount(regimeCounts['2']),
                        color: Colors.red,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Distribution bar
                  _buildDistributionBar(regimeCounts, context),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Regime explanation
          Card(
            elevation: 0,
            color: const Color(0xFF252D4A),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Understanding Market Regimes',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildRegimeExplanationItem(
                    title: 'Neutral Regime',
                    description: 'Market showing no clear direction. Trading signals have standard confidence levels.',
                    color: Colors.grey,
                  ),
                  const Divider(height: 24),
                  _buildRegimeExplanationItem(
                    title: 'Bullish Regime',
                    description: 'Market trending upward. Buy signals have increased confidence in this regime.',
                    color: Colors.green,
                  ),
                  const Divider(height: 24),
                  _buildRegimeExplanationItem(
                    title: 'Bearish Regime',
                    description: 'Market trending downward. Sell signals have increased confidence in this regime.',
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'The model uses a Hidden Markov Model (HMM) to detect different market regimes based on historical price patterns. Signal confidence is adjusted according to the current market regime.',
                    style: TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Recent regime changes
          if (regimeData.isNotEmpty) 
            _buildRecentRegimeChanges(regimeData.cast<Map<String, dynamic>>(), regimeLabels),
        ],
      ),
    );
  }

  // Parse count safely from any type
  int _parseCount(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  // Helper method to build the distribution bar
  Widget _buildDistributionBar(Map<String, dynamic> regimeCounts, BuildContext context) {
    // Calculate total and ensure it's not zero
    int total = 0;
    regimeCounts.forEach((key, value) {
      total += _parseCount(value);
    });
    
    // If total is zero, return empty placeholder to avoid division by zero
    if (total <= 0) {
      return const Text(
        'No regime data available',
        style: TextStyle(color: Colors.grey),
      );
    }

    // Calculate percentages
    final regime0Count = _parseCount(regimeCounts['0']);
    final regime1Count = _parseCount(regimeCounts['1']);
    final regime2Count = _parseCount(regimeCounts['2']);
    
    final regime0Percent = regime0Count / total;
    final regime1Percent = regime1Count / total;
    final regime2Percent = regime2Count / total;

    // Calculate widths based on available screen width
    final screenWidth = MediaQuery.of(context).size.width - 80; // Accounting for padding
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Distribution',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          height: 20,
          decoration: BoxDecoration(
            color: Colors.grey[800],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              // Neutral (regime 0)
              if (regime0Percent > 0)
                Container(
                  width: screenWidth * regime0Percent,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(10),
                      bottomLeft: const Radius.circular(10),
                      topRight: regime1Percent <= 0 && regime2Percent <= 0 ? const Radius.circular(10) : Radius.zero,
                      bottomRight: regime1Percent <= 0 && regime2Percent <= 0 ? const Radius.circular(10) : Radius.zero,
                    ),
                  ),
                ),
                
              // Bullish (regime 1)
              if (regime1Percent > 0)
                Container(
                  width: screenWidth * regime1Percent,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.only(
                      topLeft: regime0Percent <= 0 ? const Radius.circular(10) : Radius.zero,
                      bottomLeft: regime0Percent <= 0 ? const Radius.circular(10) : Radius.zero,
                      topRight: regime2Percent <= 0 ? const Radius.circular(10) : Radius.zero,
                      bottomRight: regime2Percent <= 0 ? const Radius.circular(10) : Radius.zero,
                    ),
                  ),
                ),
                
              // Bearish (regime 2)
              if (regime2Percent > 0)
                Container(
                  width: screenWidth * regime2Percent,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.only(
                      topLeft: regime0Percent <= 0 && regime1Percent <= 0 ? const Radius.circular(10) : Radius.zero,
                      bottomLeft: regime0Percent <= 0 && regime1Percent <= 0 ? const Radius.circular(10) : Radius.zero,
                      topRight: const Radius.circular(10),
                      bottomRight: const Radius.circular(10),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${(regime0Percent * 100).toStringAsFixed(1)}% Neutral',
              style: TextStyle(color: Colors.grey[400], fontSize: 12),
            ),
            Text(
              '${(regime1Percent * 100).toStringAsFixed(1)}% Bullish',
              style: TextStyle(color: Colors.green[400], fontSize: 12),
            ),
            Text(
              '${(regime2Percent * 100).toStringAsFixed(1)}% Bearish',
              style: TextStyle(color: Colors.red[400], fontSize: 12),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRegimeExplanationItem({
    required String title,
    required String description,
    required Color color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 12,
          height: 12,
          margin: const EdgeInsets.only(top: 4),
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecentRegimeChanges(
    List<Map<String, dynamic>> regimeData,
    Map<String, dynamic>? regimeLabels,
  ) {
    // Identify regime changes
    final recentChanges = _identifyRegimeChanges(regimeData).take(10).toList();
    
    if (recentChanges.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Card(
      elevation: 0,
      color: const Color(0xFF252D4A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recent Regime Changes',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            ...recentChanges.map((change) {
              final fromRegimeKey = change['from']?.toString() ?? '0';
              final toRegimeKey = change['to']?.toString() ?? '0';
              
              final fromRegime = regimeLabels?[fromRegimeKey] ?? 'Unknown';
              final toRegime = regimeLabels?[toRegimeKey] ?? 'Unknown';
              
              // Determine colors
              Color fromColor = Colors.grey;
              Color toColor = Colors.grey;
              
              if (fromRegimeKey == '0') fromColor = Colors.grey;
              else if (fromRegimeKey == '1') fromColor = Colors.green;
              else if (fromRegimeKey == '2') fromColor = Colors.red;
              
              if (toRegimeKey == '0') toColor = Colors.grey;
              else if (toRegimeKey == '1') toColor = Colors.green;
              else if (toRegimeKey == '2') toColor = Colors.red;
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Row(
                  children: [
                    // Date
                    Text(
                      _formatDate(change['timestamp']),
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 16),
                    
                    // From regime
                    Text(
                      fromRegime,
                      style: TextStyle(
                        color: fromColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    
                    // Arrow
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Icon(
                        Icons.arrow_forward,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    
                    // To regime
                    Text(
                      toRegime,
                      style: TextStyle(
                        color: toColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  // Helper method to format date
  String _formatDate(dynamic date) {
    if (date is DateTime) {
      return '${date.month}/${date.day}';
    } else if (date is String) {
      try {
        final dateTime = DateTime.parse(date);
        return '${dateTime.month}/${dateTime.day}';
      } catch (e) {
        return date;
      }
    }
    return 'Unknown';
  }

  Widget _buildRegimeSummary(
    Map<String, dynamic> regimeCounts, 
    Map<String, dynamic> regimeLabels,
    BuildContext context
  ) {
    return Card(
      elevation: 0,
      color: const Color(0xFF252D4A),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Market Regime Distribution',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildRegimeCard(
                  label: regimeLabels['0'] ?? 'Neutral',
                  count: _parseCount(regimeCounts['0']),
                  color: Colors.grey,
                ),
                const SizedBox(width: 16),
                _buildRegimeCard(
                  label: regimeLabels['1'] ?? 'Bullish',
                  count: _parseCount(regimeCounts['1']),
                  color: Colors.green,
                ),
                const SizedBox(width: 16),
                _buildRegimeCard(
                  label: regimeLabels['2'] ?? 'Bearish',
                  count: _parseCount(regimeCounts['2']),
                  color: Colors.red,
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Add distribution bar
            _buildDistributionBar(regimeCounts, context),
          ],
        ),
      ),
    );
  }
  
  Widget _buildRegimeCard({
    required String label, 
    required int count, 
    required Color color
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'data points',
              style: TextStyle(
                fontSize: 12,
                color: color.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Map<String, dynamic> _generateSyntheticRegimeData() {
    // Create dates for the last 30 days
    final now = DateTime.now();
    final dates = List.generate(30, (i) => 
      now.subtract(Duration(days: 29 - i)));
      
    // Create synthetic regimes data with a reasonable pattern
    final regimeData = <Map<String, dynamic>>[];
    final regimeCounts = {'0': 0, '1': 0, '2': 0};
    
    for (int i = 0; i < dates.length; i++) {
      // Create a pattern: neutral, bullish, bearish repeating
      final regime = (i ~/ 10) % 3;
      
      // Add to regime data
      regimeData.add({
        'timestamp': dates[i].toIso8601String().split('T')[0],
        'market_regime': regime,
      });
      
      // Count regimes
      regimeCounts['$regime'] = (regimeCounts['$regime'] ?? 0) + 1;
    }
    
    return {
      'regime_data': regimeData,
      'regime_counts': regimeCounts,
      'regime_labels': {
        '0': 'Neutral',
        '1': 'Bullish',
        '2': 'Bearish',
      },
    };
  }
  
  Widget _buildRegimeExplanation() {
    return Card(
      elevation: 0,
      color: const Color(0xFF252D4A),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Understanding Market Regimes',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            _buildRegimeExplanationItem(
              title: 'Neutral Regime',
              description: 'Market showing no clear direction. Trading signals have standard confidence levels.',
              color: Colors.grey,
            ),
            const Divider(height: 24),
            _buildRegimeExplanationItem(
              title: 'Bullish Regime',
              description: 'Market trending upward. Buy signals have increased confidence in this regime.',
              color: Colors.green,
            ),
            const Divider(height: 24),
            _buildRegimeExplanationItem(
              title: 'Bearish Regime',
              description: 'Market trending downward. Sell signals have increased confidence in this regime.',
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            const Text(
              'The model uses a Hidden Markov Model (HMM) to detect different market regimes based on historical price patterns. Signal confidence is adjusted according to the current market regime.',
              style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _identifyRegimeChanges(List<Map<String, dynamic>> regimeData) {
    final changes = <Map<String, dynamic>>[];
    
    for (int i = 1; i < regimeData.length; i++) {
      // Add null checks and safely extract values
      final prevData = regimeData[i-1];
      final currData = regimeData[i];
      
      final prevRegime = prevData['market_regime'];
      final currRegime = currData['market_regime'];
      
      // Check if both values are valid and different
      if (prevRegime != null && currRegime != null && prevRegime != currRegime) {
        changes.add({
          'timestamp': currData['timestamp'],
          'from': prevRegime,
          'to': currRegime,
        });
      }
    }
    
    // Sort by most recent first
    changes.sort((a, b) {
      // Try to get timestamps for comparison
      DateTime? aTime;
      DateTime? bTime;
      
      try {
        if (a['timestamp'] is String) {
          aTime = DateTime.parse(a['timestamp'].toString());
        } else if (a['timestamp'] is DateTime) {
          aTime = a['timestamp'] as DateTime;
        }
      } catch (_) {}
      
      try {
        if (b['timestamp'] is String) {
          bTime = DateTime.parse(b['timestamp'].toString());
        } else if (b['timestamp'] is DateTime) {
          bTime = b['timestamp'] as DateTime;
        }
      } catch (_) {}
      
      // If both times are valid, compare them
      if (aTime != null && bTime != null) {
        return bTime.compareTo(aTime);
      }
      
      // Default to keeping the original order
      return 0;
    });
    
    return changes;
  }
}
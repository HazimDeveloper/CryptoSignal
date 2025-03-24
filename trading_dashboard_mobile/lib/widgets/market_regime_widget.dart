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
    // Check if we have regime data
    if (regimes.isEmpty || regimes['regime_data'] == null) {
      return const Center(
        child: Text('No market regime data available'),
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
    
    // Calculate total points
    int total = 0;
    regimeCounts.forEach((key, value) {
      total += (value as num).toInt();
    });

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Regime summary cards
          _buildRegimeSummary(regimeCounts, regimeLabels, total,context),
          
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
  
  Widget _buildRegimeSummary(
    Map<String, dynamic> regimeCounts, 
    Map<String, dynamic> regimeLabels, 
    int total,
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
                  count: regimeCounts['0'] ?? 0,
                  color: Colors.grey,
                ),
                const SizedBox(width: 16),
                _buildRegimeCard(
                  label: regimeLabels['1'] ?? 'Bullish',
                  count: regimeCounts['1'] ?? 0,
                  color: Colors.green,
                ),
                const SizedBox(width: 16),
                _buildRegimeCard(
                  label: regimeLabels['2'] ?? 'Bearish',
                  count: regimeCounts['2'] ?? 0,
                  color: Colors.red,
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (total > 0) ...[
              // Add distribution bar
              _buildDistributionBar(regimeCounts, total , context),
            ],
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
  
  Widget _buildDistributionBar(Map<String, dynamic> regimeCounts, int total,BuildContext context) {
    // Calculate percentages
    final regime0Count = regimeCounts['0'] ?? 0;
    final regime1Count = regimeCounts['1'] ?? 0;
    final regime2Count = regimeCounts['2'] ?? 0;
    
    final regime0Percent = total > 0 ? regime0Count / total : 0.0;
    final regime1Percent = total > 0 ? regime1Count / total : 0.0;
    final regime2Percent = total > 0 ? regime2Count / total : 0.0;
    
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
        Stack(
          children: [
            // Base container
            Container(
              height: 20,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            
            // Regime 0 (Neutral)
            FractionallySizedBox(
              widthFactor: regime0Percent,
              child: Container(
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(10),
                    bottomLeft: const Radius.circular(10),
                    topRight: Radius.circular(regime0Percent == 1.0 ? 10 : 0),
                    bottomRight: Radius.circular(regime0Percent == 1.0 ? 10 : 0),
                  ),
                ),
              ),
            ),
            
            // Regime 1 (Bullish)
            Positioned(
              left: MediaQuery.of(context).size.width * regime0Percent * 0.9,
              child: FractionallySizedBox(
                widthFactor: regime1Percent,
                child: Container(
                  height: 20,
                  width: MediaQuery.of(context).size.width * regime1Percent * 0.9,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(
                      regime0Percent == 0.0 ? 10 : 0
                    ),
                  ),
                ),
              ),
            ),
            
            // Regime 2 (Bearish)
            Positioned(
              left: MediaQuery.of(context).size.width * (regime0Percent + regime1Percent) * 0.9,
              child: FractionallySizedBox(
                widthFactor: regime2Percent,
                child: Container(
                  height: 20,
                  width: MediaQuery.of(context).size.width * regime2Percent * 0.9,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.only(
                      topRight: const Radius.circular(10),
                      bottomRight: const Radius.circular(10),
                      topLeft: Radius.circular(regime0Percent == 0.0 && regime1Percent == 0.0 ? 10 : 0),
                      bottomLeft: Radius.circular(regime0Percent == 0.0 && regime1Percent == 0.0 ? 10 : 0),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
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
    Map<String, dynamic> regimeLabels,
  ) {
    // Take only the last 10 regime changes
    final recentChanges = _identifyRegimeChanges(regimeData).take(10).toList();
    
    if (recentChanges.isEmpty) {
      return const SizedBox.shrink();
    }
    
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
              'Recent Regime Changes',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            ...recentChanges.map((change) {
              final fromRegime = regimeLabels[change['from'].toString()] ?? 'Unknown';
              final toRegime = regimeLabels[change['to'].toString()] ?? 'Unknown';
              
              // Determine colors
              Color fromColor;
              Color toColor;
              
              switch (change['from']) {
                case 0: fromColor = Colors.grey; break;
                case 1: fromColor = Colors.green; break;
                case 2: fromColor = Colors.red; break;
                default: fromColor = Colors.grey;
              }
              
              switch (change['to']) {
                case 0: toColor = Colors.grey; break;
                case 1: toColor = Colors.green; break;
                case 2: toColor = Colors.red; break;
                default: toColor = Colors.grey;
              }
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Row(
                  children: [
                    // Date
                    Text(
                      DateFormat('MMM dd').format(change['timestamp']),
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
  
  List<Map<String, dynamic>> _identifyRegimeChanges(List<Map<String, dynamic>> regimeData) {
    final changes = <Map<String, dynamic>>[];
    
    for (int i = 1; i < regimeData.length; i++) {
      final prevRegime = regimeData[i-1]['market_regime'] as int;
      final currRegime = regimeData[i]['market_regime'] as int;
      
      if (prevRegime != currRegime) {
        changes.add({
          'timestamp': DateTime.parse(regimeData[i]['timestamp']),
          'from': prevRegime,
          'to': currRegime,
        });
      }
    }
    
    // Sort by most recent first
    changes.sort((a, b) => b['timestamp'].compareTo(a['timestamp']));
    
    return changes;
  }
}
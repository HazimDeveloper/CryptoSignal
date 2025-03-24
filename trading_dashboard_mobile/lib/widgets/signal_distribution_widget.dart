// widgets/signal_distribution_widget.dart
import 'package:flutter/material.dart';
import '../models/signal_data.dart';

class SignalDistributionWidget extends StatelessWidget {
  final List<SignalData> signals;

  const SignalDistributionWidget({
    Key? key,
    required this.signals,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Count signals by type
    int buyCount = 0;
    int sellCount = 0;
    int holdCount = 0;

    for (var signal in signals) {
      if (signal.signal == 'BUY') {
        buyCount++;
      } else if (signal.signal == 'SELL') {
        sellCount++;
      } else if (signal.signal == 'HOLD') {
        holdCount++;
      }
    }

    // Calculate percentages
    final total = signals.isEmpty ? 1 : signals.length;
    final buyPercent = (buyCount / total) * 100;
    final sellPercent = (sellCount / total) * 100;
    final holdPercent = (holdCount / total) * 100;

    return Card(
      elevation: 0,
      color: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0), // Reduced padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min, // Important - use minimum required space
          children: [
            // Title row with icon
            Row(
              children: [
                const Icon(
                  Icons.pie_chart,
                  size: 16, // Smaller icon
                  color: Colors.blue,
                ),
                const SizedBox(width: 4), // Reduced spacing
                Expanded(
                  child: Text(
                    'Signal Distribution',
                    style: TextStyle(
                      fontSize: 12, // Smaller font
                      color: Colors.grey[400],
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 8), // Reduced spacing
            
            // Compact signal bars list
            _buildCompactSignalBar(context, 'BUY', buyPercent, Colors.green),
            const SizedBox(height: 4), // Minimal spacing
            _buildCompactSignalBar(context, 'SELL', sellPercent, Colors.red),
            const SizedBox(height: 4), // Minimal spacing
            _buildCompactSignalBar(context, 'HOLD', holdPercent, Colors.blueGrey),
          ],
        ),
      ),
    );
  }
  
  // More compact signal bar implementation
  Widget _buildCompactSignalBar(BuildContext context, String label, double percent, Color color) {
    return SizedBox(
      height: 18, // Fixed height constraint for each bar section
      child: Row(
        children: [
          // Label
          SizedBox(
            width: 40, // Fixed width for label
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11, // Smaller font
                color: Colors.grey[300],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          // Progress bar
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: percent / 100,
                backgroundColor: Colors.grey[800],
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 6, // Thinner bar
              ),
            ),
          ),
          
          // Percentage
          SizedBox(
            width: 45, // Fixed width for percentage
            child: Text(
              '${percent.toStringAsFixed(1)}%',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 11, // Smaller font
                color: Colors.grey[400],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
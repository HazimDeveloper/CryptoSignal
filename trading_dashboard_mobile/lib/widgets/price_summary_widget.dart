// widgets/price_summary_widget.dart
import 'package:flutter/material.dart';
import '../models/signal_data.dart';

class PriceSummaryWidget extends StatelessWidget {
  final double latestPrice;
  final double priceChange24h;
  final SignalData? latestSignal;

  const PriceSummaryWidget({
    Key? key,
    required this.latestPrice,
    required this.priceChange24h,
    this.latestSignal,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isPositiveChange = priceChange24h >= 0;
    final bool isBuySignal = latestSignal?.signal == 'BUY';
    
    return LayoutBuilder(
      builder: (context, constraints) {
        // Responsive design based on available width
        final isNarrow = constraints.maxWidth < 340;
        
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: isNarrow 
              ? _buildNarrowLayout(context, isPositiveChange, isBuySignal)
              : _buildWideLayout(context, isPositiveChange, isBuySignal),
        );
      }
    );
  }
  
  Widget _buildWideLayout(BuildContext context, bool isPositiveChange, bool isBuySignal) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Price information
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Current Price',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  '\$${latestPrice.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Text(
                    '24h Change',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${isPositiveChange ? "+" : ""}${priceChange24h.toStringAsFixed(2)}%',
                    style: TextStyle(
                      color: isPositiveChange ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        
        // Separator
        Container(
          height: 60,
          width: 1,
          color: Colors.grey[800],
          margin: const EdgeInsets.symmetric(horizontal: 16),
        ),
        
        // Signal information
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Latest Signal',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              if (latestSignal != null) ...[
                Text(
                  latestSignal!.signal,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isBuySignal ? Colors.green : Colors.red,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${latestSignal!.confidence.toStringAsFixed(1)}% confidence',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[400],
                  ),
                ),
              ] else ...[
                const Text(
                  'No Signal',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildNarrowLayout(BuildContext context, bool isPositiveChange, bool isBuySignal) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Price information
        const Text(
          'Current Price',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            '\$${latestPrice.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            const Text(
              '24h Change',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '${isPositiveChange ? "+" : ""}${priceChange24h.toStringAsFixed(2)}%',
              style: TextStyle(
                color: isPositiveChange ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
        
        const Divider(height: 24),
        
        // Signal information
        const Text(
          'Latest Signal',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        if (latestSignal != null) ...[
          Text(
            latestSignal!.signal,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isBuySignal ? Colors.green : Colors.red,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${latestSignal!.confidence.toStringAsFixed(1)}% confidence',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[400],
            ),
          ),
        ] else ...[
          const Text(
            'No Signal',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ],
      ],
    );
  }
}
// screens/signal_details_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

import '../models/signal_data.dart';
import '../providers/signal_metrics_provider.dart';
import '../widgets/chatbot_widget.dart';

class SignalDetailsScreen extends StatefulWidget {
  final SignalData signal;

  const SignalDetailsScreen({Key? key, required this.signal}) : super(key: key);

  @override
  _SignalDetailsScreenState createState() => _SignalDetailsScreenState();
}

class _SignalDetailsScreenState extends State<SignalDetailsScreen> {
  bool _showRiskInfo = false;

  @override
  void initState() {
    super.initState();

    // Load model metrics
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SignalMetricsProvider>(
        context,
        listen: false,
      ).loadModelMetrics();
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isBuy = widget.signal.signal == 'BUY';
    final signalColor = isBuy ? Colors.green : Colors.red;

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.signal.signal} Signal Details',style: TextStyle(color: Colors.white),),
        centerTitle: false,
      ),
      body: Consumer<SignalMetricsProvider>(
        builder: (context, provider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Signal overview card
                _buildSignalOverviewCard(signalColor, isBuy),

                const SizedBox(height: 24),

                // Price impact
                _buildPriceImpactCard(isBuy),

                const SizedBox(height: 24),

                // Historical accuracy
                _buildHistoricalAccuracyCard(provider, isBuy),

                const SizedBox(height: 24),

                // Risk information
                _buildRiskInformationCard(provider),

                const SizedBox(height: 24),

                // Signal explanation
                _buildExplanationCard(),

                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => ChatbotScreen(
                    initialQuestion:
                        'Explain this ${widget.signal.signal} signal with ${widget.signal.confidence.toStringAsFixed(1)}% confidence from ${DateFormat('MMM dd').format(widget.signal.timestamp)}',
                  ),
            ),
          );
        },
        icon: const Icon(Icons.help_outline),
        label: const Text('Ask Assistant'),
      ),
    );
  }

  Widget _buildSignalOverviewCard(Color signalColor, bool isBuy) {
    return Card(
      elevation: 0,
      color: const Color(0xFF252D4A),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: signalColor.withOpacity(0.5), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Signal type header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: signalColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isBuy ? Icons.arrow_upward : Icons.arrow_downward,
                        color: signalColor,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        widget.signal.signal,
                        style: TextStyle(
                          color: signalColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      DateFormat(
                        'MMM dd, yyyy',
                      ).format(widget.signal.timestamp),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      DateFormat('HH:mm').format(widget.signal.timestamp),
                      style: TextStyle(color: Colors.grey[400], fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Signal confidence
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Signal Confidence',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getConfidenceColor(
                      widget.signal.confidence,
                    ).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${widget.signal.confidence.toStringAsFixed(1)}%',
                    style: TextStyle(
                      color: _getConfidenceColor(widget.signal.confidence),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Predicted return
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Predicted Return',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                Text(
                  widget.signal.predictedReturn != null
                      ? '${(widget.signal.predictedReturn! * 100).toStringAsFixed(2)}%'
                      : 'N/A',
                  style: TextStyle(
                    color:
                        widget.signal.predictedReturn != null
                            ? (widget.signal.predictedReturn! >= 0
                                ? Colors.green
                                : Colors.red)
                            : Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Confidence rating
            const Text(
              'Confidence Rating',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: widget.signal.confidence / 100,
              backgroundColor: Colors.grey[800],
              valueColor: AlwaysStoppedAnimation<Color>(
                _getConfidenceColor(widget.signal.confidence),
              ),
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Low',
                  style: TextStyle(color: Colors.grey[400], fontSize: 12),
                ),
                Text(
                  'Medium',
                  style: TextStyle(color: Colors.grey[400], fontSize: 12),
                ),
                Text(
                  'High',
                  style: TextStyle(color: Colors.grey[400], fontSize: 12),
                ),
                Text(
                  'Very High',
                  style: TextStyle(color: Colors.grey[400], fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceImpactCard(bool isBuy) {
    // Calculate potential price impact (for demonstration)
    final basePrice = 39500.0; // Example price
    final predictedChange =
        widget.signal.predictedReturn ?? (isBuy ? 0.025 : -0.035);
    final potentialPrice = basePrice * (1 + predictedChange);

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
              'Potential Price Impact',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 16),

            // Current price
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Current Price',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                Text(
                  '\$${basePrice.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Potential price after signal
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Potential Target',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                Text(
                  '\$${potentialPrice.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: predictedChange >= 0 ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Price difference visualization
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[800]!.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '\$${basePrice.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[300],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(height: 2, color: Colors.grey[700]),
                        Icon(
                          isBuy ? Icons.arrow_forward : Icons.arrow_back,
                          color: isBuy ? Colors.green : Colors.red,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    '\$${potentialPrice.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: predictedChange >= 0 ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Note about potential price
            Text(
              'This price target is based on the predicted return of ${(predictedChange * 100).toStringAsFixed(2)}%',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[400],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoricalAccuracyCard(
    SignalMetricsProvider provider,
    bool isBuy,
  ) {
    final metrics = provider.signalMetrics;
    final accuracy =
        isBuy
            ? (metrics?.buyAccuracy ?? 0) * 100
            : (metrics?.sellAccuracy ?? 0) * 100;

    return Card(
      elevation: 0,
      color: const Color(0xFF252D4A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Historical Signal Accuracy',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const Spacer(),
                if (provider.isLoading)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            if (metrics != null) ...[
              // Accuracy rate
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Historical ${isBuy ? 'BUY' : 'SELL'} Signal Accuracy',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: accuracy / 100,
                          backgroundColor: Colors.grey[800],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _getAccuracyColor(accuracy),
                          ),
                          minHeight: 8,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: _getAccuracyColor(accuracy).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${accuracy.toStringAsFixed(1)}%',
                      style: TextStyle(
                        color: _getAccuracyColor(accuracy),
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Historical periods
              const Text(
                'Performance by Period',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 12),

              ...metrics.historicalPeriods.map((period) {
                final periodAccuracy = period.accuracy * 100;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text(
                          period.period,
                          style: TextStyle(color: Colors.grey[300]),
                        ),
                      ),
                      Expanded(
                        flex: 7,
                        child: Row(
                          children: [
                            Expanded(
                              child: LinearProgressIndicator(
                                value: periodAccuracy / 100,
                                backgroundColor: Colors.grey[800],
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  _getAccuracyColor(periodAccuracy),
                                ),
                                minHeight: 8,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${periodAccuracy.toStringAsFixed(1)}%',
                              style: TextStyle(
                                color: _getAccuracyColor(periodAccuracy),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ] else if (provider.hasError) ...[
              Center(
                child: Column(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.orange,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Could not load accuracy data: ${provider.errorMessage}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: provider.loadModelMetrics,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ] else if (provider.isLoading) ...[
              const Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Loading accuracy data...'),
                  ],
                ),
              ),
            ] else ...[
              const Center(
                child: Text(
                  'No historical accuracy data available',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRiskInformationCard(SignalMetricsProvider provider) {
    return Card(
      elevation: 0,
      color: const Color(0xFF252D4A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Risk Assessment',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(
                    _showRiskInfo ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                    color: Colors.blue,
                  ),
                  onPressed: () {
                    setState(() {
                      _showRiskInfo = !_showRiskInfo;
                    });
                  },
                ),
              ],
            ),

            if (_showRiskInfo) ...[
              const SizedBox(height: 16),

              // Risk factors
              _buildRiskFactor(
                'Market Volatility',
                'Medium',
                Colors.orange,
                'Current market conditions show moderate volatility',
              ),

              const SizedBox(height: 12),

              _buildRiskFactor(
                'Signal Strength',
                widget.signal.confidence >= 70 ? 'Strong' : 'Moderate',
                widget.signal.confidence >= 70 ? Colors.green : Colors.orange,
                'Based on confidence score of ${widget.signal.confidence.toStringAsFixed(1)}%',
              ),

              const SizedBox(height: 12),

              _buildRiskFactor(
                'Historical Reliability',
                (provider.signalMetrics != null &&
                        provider.signalMetrics!.avgAccuracy >= 0.7)
                    ? 'High'
                    : 'Moderate',
                (provider.signalMetrics != null &&
                        provider.signalMetrics!.avgAccuracy >= 0.7)
                    ? Colors.green
                    : Colors.orange,
                'Based on past signal performance',
              ),

              const SizedBox(height: 24),

              // Risk disclaimer
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.warning_amber,
                          color: Colors.orange,
                          size: 16,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Risk Disclaimer',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Trading cryptocurrencies involves substantial risk. Past performance does not guarantee future results. Always use proper risk management.',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ] else ...[
              LinearProgressIndicator(
                value: 0.7,
                backgroundColor: Colors.grey[800],
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.orange),
                minHeight: 4,
                borderRadius: BorderRadius.circular(2),
              ),
              const SizedBox(height: 8),
              Text(
                'Tap to view detailed risk assessment',
                style: TextStyle(fontSize: 12, color: Colors.grey[400]),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRiskFactor(
    String name,
    String level,
    Color color,
    String description,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.info_outline, size: 16, color: Colors.grey[400]),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(name, style: TextStyle(color: Colors.grey[300])),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      level,
                      style: TextStyle(
                        fontSize: 12,
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(fontSize: 12, color: Colors.grey[400]),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildExplanationCard() {
    return Card(
      elevation: 0,
      color: const Color(0xFF252D4A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.lightbulb_outline, color: Colors.amber),
                const SizedBox(width: 8),
                const Text(
                  'Signal Explanation',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.chat, color: Colors.blue, size: 20),
                  tooltip: 'Ask for more details',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => ChatbotScreen(
                              initialQuestion:
                                  'Explain this ${widget.signal.signal} signal with ${widget.signal.confidence.toStringAsFixed(1)}% confidence from ${DateFormat('MMM dd').format(widget.signal.timestamp)}',
                            ),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildExplanationText(),
          ],
        ),
      ),
    );
  }

  Widget _buildExplanationText() {
    final isBuy = widget.signal.signal == 'BUY';
    final highConfidence = widget.signal.confidence >= 70;

    if (isBuy) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            highConfidence
                ? 'This is a strong BUY signal with high confidence, suggesting a potential upward price movement.'
                : 'This is a BUY signal with moderate confidence, suggesting a possible upward price movement.',
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 12),
          const Text(
            'This signal is based on several factors:',
            style: TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 8),
          _buildExplanationPoint('Recent price action shows bullish momentum'),
          _buildExplanationPoint(
            'Technical indicators suggest an uptrend may be forming',
          ),
          _buildExplanationPoint(
            'Market regime analysis indicates favorable conditions for long positions',
          ),

          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // In a real app, this would navigate to a detailed technical analysis screen
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('View Technical Analysis'),
                ),
              ),
            ],
          ),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            highConfidence
                ? 'This is a strong SELL signal with high confidence, suggesting a potential downward price movement.'
                : 'This is a SELL signal with moderate confidence, suggesting a possible downward price movement.',
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 12),
          const Text(
            'This signal is based on several factors:',
            style: TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 8),
          _buildExplanationPoint('Recent price action shows bearish momentum'),
          _buildExplanationPoint(
            'Technical indicators suggest a downtrend may be forming',
          ),
          _buildExplanationPoint(
            'Market regime analysis indicates potential selling pressure',
          ),

          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // In a real app, this would navigate to a detailed technical analysis screen
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('View Technical Analysis'),
                ),
              ),
            ],
          ),
        ],
      );
    }
  }

  Widget _buildExplanationPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 14)),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 80) {
      return Colors.green;
    } else if (confidence >= 60) {
      return Colors.amber;
    } else if (confidence >= 40) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  Color _getAccuracyColor(double accuracy) {
    if (accuracy >= 80) {
      return Colors.green;
    } else if (accuracy >= 70) {
      return Colors.lightGreen;
    } else if (accuracy >= 60) {
      return Colors.amber;
    } else if (accuracy >= 50) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
}

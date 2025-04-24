// widgets/strategy_card.dart
import 'package:flutter/material.dart';
import '../models/educational_content.dart';
import 'chatbot_widget.dart';

class StrategyCard extends StatelessWidget {
  final Strategy strategy;
  
  const StrategyCard({
    Key? key,
    required this.strategy,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Determine color based on risk level
    Color riskColor;
    switch (strategy.risk.toLowerCase()) {
      case 'low':
        riskColor = Colors.green;
        break;
      case 'medium':
      case 'medium-low':
        riskColor = Colors.orange;
        break;
      case 'medium-high':
      case 'high':
        riskColor = Colors.red;
        break;
      default:
        riskColor = Colors.blue;
    }
    
    return Card(
      elevation: 0,
      color: const Color(0xFF252D4A),
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Strategy header
            Row(
              children: [
                // widgets/strategy_card.dart (continued)
                const Icon(Icons.insights, color: Colors.blue, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    strategy.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Strategy details
            Text(
              strategy.description,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            
            // Strategy metadata
            Row(
              children: [
                _buildMetadataItem('Difficulty', strategy.difficulty, Colors.blue),
                const SizedBox(width: 16),
                _buildMetadataItem('Risk', strategy.risk, riskColor),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Learn more button
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  icon: const Icon(Icons.help_outline, size: 16,color: Colors.white,),
                  label: const Text('Learn How',style: TextStyle(color: Colors.white),),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatbotScreen(
                          initialQuestion: 'Explain how to use the ${strategy.title} trading strategy',
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildMetadataItem(String label, String value, Color color) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[400],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
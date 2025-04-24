// widgets/metric_card.dart
import 'package:flutter/material.dart';

class MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String subvalue;
  final IconData icon;
  final Color? valueColor;
  final VoidCallback? onInfoPressed;

  const MetricCard({
    Key? key,
    required this.title,
    required this.value,
    required this.subvalue,
    required this.icon,
    this.valueColor,
    this.onInfoPressed, // Add this
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title row with icon
            Row(
              children: [
                Icon(icon, size: 18, color: Colors.blue),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(fontSize: 14, color: Colors.grey[400]),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // Add this if statement and IconButton
                if (onInfoPressed != null)
                  IconButton(
                    icon: const Icon(Icons.help_outline, size: 14),
                    onPressed: onInfoPressed,
                    tooltip: 'Learn about $title',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
              ],
            ),
            const SizedBox(height: 8),

            // Value
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: valueColor,
                ),
              ),
            ),

            const SizedBox(height: 4),

            // Subvalue
            Text(
              subvalue,
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

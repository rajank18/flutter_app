import 'package:flutter/material.dart';
import '../models/event_model.dart';
import '../utils/helpers.dart';

class EventCard extends StatelessWidget {
  final EventModel event;
  final String subtitle;
  final String actionLabel;
  final VoidCallback? onAction;
  final bool isActionEnabled;

  const EventCard({
    super.key,
    required this.event,
    required this.subtitle,
    required this.actionLabel,
    required this.isActionEnabled,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final published = event.isPublished ?? true;
    return Card(
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    event.eventName,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: published ? Colors.green.shade50 : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    published ? 'Published' : 'Draft',
                    style: TextStyle(
                      color: published ? Colors.green.shade700 : Colors.grey.shade700,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(Helpers.formatDateTime(event.eventDate), style: const TextStyle(color: Colors.black54)),
            const SizedBox(height: 4),
            Text('Capacity: ${event.maxCapacity}', style: const TextStyle(color: Colors.black54)),
            if (event.requiresSecureKey && (event.registrationKey?.isNotEmpty ?? false)) ...[
              const SizedBox(height: 8),
              Text(
                'Secure Key: ${event.registrationKey}',
                style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w700),
              ),
            ],
            const SizedBox(height: 8),
            Text(subtitle, style: const TextStyle(color: Colors.black87)),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isActionEnabled ? onAction : null,
                child: Text(actionLabel),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

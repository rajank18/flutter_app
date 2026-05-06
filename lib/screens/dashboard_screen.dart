import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/stats_card.dart';
import '../providers/event_provider.dart';
import '../providers/attendance_provider.dart';
import '../utils/helpers.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<EventProvider, AttendanceProvider>(
      builder: (context, eventProvider, attendanceProvider, _) {
        final event = eventProvider.event;
        final total = event?.maxCapacity ?? 0;
        final checkedIn = attendanceProvider.checkedInCount();
        final remaining = attendanceProvider.remainingCapacity(event);
        final level = Helpers.crowdLevel(checkedIn: checkedIn, capacity: total == 0 ? 1 : total);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (event != null)
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(event.eventName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 4),
                        Text(Helpers.formatDateTime(event.eventDate), style: const TextStyle(color: Colors.black54)),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(child: StatsCard(label: 'Total', value: '$total', color: const Color(0xFF1463FF))),
                  const SizedBox(width: 12),
                  Expanded(child: StatsCard(label: 'Checked-in', value: '$checkedIn', color: const Color(0xFF1E9E5A))),
                  const SizedBox(width: 12),
                  Expanded(child: StatsCard(label: 'Remaining', value: '$remaining', color: const Color(0xFFF5A524))),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Helpers.crowdColor(level).withValues(alpha: 0.12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.people_alt, color: Helpers.crowdColor(level)),
                    const SizedBox(width: 10),
                    Text(
                      'Crowd Level: ${Helpers.crowdLabel(level)}',
                      style: TextStyle(fontWeight: FontWeight.w700, color: Helpers.crowdColor(level)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/participant_tile.dart';
import '../widgets/custom_textfield.dart';
import '../providers/attendance_provider.dart';
import '../utils/helpers.dart';

class LogsScreen extends StatefulWidget {
  const LogsScreen({super.key});

  @override
  State<LogsScreen> createState() => _LogsScreenState();
}

class _LogsScreenState extends State<LogsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          CustomTextField(
            label: 'Search Participant',
            hint: 'Search by ID or name',
            controller: _searchController,
            onChanged: (value) => setState(() => _query = value),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Consumer<AttendanceProvider>(
              builder: (_, attendanceProvider, __) {
                final logs = attendanceProvider.filteredLogs(_query);
                if (logs.isEmpty) {
                  return const Center(child: Text('No logs found.'));
                }

                return ListView.separated(
                  itemCount: logs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final log = logs[index];
                    return ParticipantTile(
                      name: log.participantName,
                      id: log.participantId,
                      checkedIn: true,
                      checkinTime: Helpers.formatDateTime(log.checkinTime),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

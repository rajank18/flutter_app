import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/registration_provider.dart';
import '../widgets/custom_textfield.dart';
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
            label: 'Search logs',
            hint: 'Search by event name or email',
            controller: _searchController,
            onChanged: (value) => setState(() => _query = value),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Consumer<RegistrationProvider>(
              builder: (context, registrationProvider, _) {
                final logs = registrationProvider.searchLogs(_query);

                if (logs.isEmpty) {
                  return const Center(child: Text('No logs found.'));
                }

                return ListView.separated(
                  itemCount: logs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = logs[index];
                    return Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: ListTile(
                        title: Text(item.eventName, style: const TextStyle(fontWeight: FontWeight.w700)),
                        subtitle: Text('${item.userEmail}\nRegistered: ${Helpers.formatDateTime(item.registeredAt)}'),
                        isThreeLine: true,
                      ),
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

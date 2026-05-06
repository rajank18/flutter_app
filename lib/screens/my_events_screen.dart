import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/registration_provider.dart';
import '../utils/helpers.dart';

class MyEventsScreen extends StatelessWidget {
  const MyEventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<RegistrationProvider, AuthProvider>(
      builder: (context, registrationProvider, authProvider, _) {
        final userEmail = authProvider.email ?? '';
        final registrations = registrationProvider.myRegistrations(userEmail);

        if (registrations.isEmpty) {
          return const Center(child: Text('You have not registered for any events yet.'));
        }

        return ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: registrations.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final item = registrations[index];
            return Card(
              elevation: 1.5,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.eventName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 6),
                    Text('Event ID: ${item.eventId}', style: const TextStyle(color: Colors.black54)),
                    const SizedBox(height: 4),
                    Text('Registered at: ${Helpers.formatDateTime(item.registeredAt)}', style: const TextStyle(color: Colors.black54)),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

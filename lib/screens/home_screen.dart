import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/event_provider.dart';
import '../providers/registration_provider.dart';
import '../widgets/event_card.dart';
import '../utils/helpers.dart';

class HomeScreen extends StatelessWidget {
  final bool isAdmin;

  const HomeScreen({super.key, required this.isAdmin});

  @override
  Widget build(BuildContext context) {
    return Consumer3<EventProvider, RegistrationProvider, AuthProvider>(
      builder: (context, eventProvider, registrationProvider, authProvider, _) {
        final events = eventProvider.publishedEvents;
        final email = authProvider.email ?? '';

        return events.isEmpty
            ? const Center(child: Text('No published events yet.'))
            : ListView.separated(
                padding: const EdgeInsets.all(20),
                itemCount: events.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final event = events[index];
                  final registered = registrationProvider.isRegistered(
                    eventId: event.id,
                    userEmail: email,
                  );

                  return EventCard(
                    event: event,
                    subtitle: isAdmin
                        ? 'Created by: ${event.createdBy ?? 'Admin'}'
                        : registered
                            ? 'You are already registered for this event.'
                            : 'Tap register to save this event in My Events.',
                    actionLabel: isAdmin
                        ? (event.isPublished ?? true) ? 'Published' : 'Draft'
                        : registered
                            ? 'Registered'
                            : 'Register',
                    isActionEnabled: !isAdmin && !registered,
                    onAction: isAdmin
                        ? null
                        : () async {
                            final message = await registrationProvider.registerToEvent(
                              event: event,
                              userEmail: email,
                            );
                            if (context.mounted) {
                              Helpers.showSnack(context, message ?? 'Registered successfully.');
                            }
                          },
                  );
                },
              );
      },
    );
  }
}

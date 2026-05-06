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
                            String? keyInput;
                            if (event.requiresSecureKey) {
                              keyInput = await showDialog<String>(
                                context: context,
                                builder: (ctx) {
                                  final controller = TextEditingController();
                                  return AlertDialog(
                                    title: const Text('Secure Registration'),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Text('Enter the 6-digit key to register.'),
                                        const SizedBox(height: 12),
                                        TextField(
                                          controller: controller,
                                          keyboardType: TextInputType.number,
                                          maxLength: 6,
                                          decoration: const InputDecoration(
                                            labelText: '6-digit key',
                                            border: OutlineInputBorder(),
                                            counterText: '',
                                          ),
                                        ),
                                      ],
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(ctx),
                                        child: const Text('Cancel'),
                                      ),
                                      ElevatedButton(
                                        onPressed: () => Navigator.pop(ctx, controller.text.trim()),
                                        child: const Text('Submit'),
                                      ),
                                    ],
                                  );
                                },
                              );

                              if (!context.mounted) return;
                              if (keyInput == null) return; // cancelled
                            }

                            final message = await registrationProvider.registerToEvent(
                              event: event,
                              userEmail: email,
                              registrationKeyInput: keyInput,
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

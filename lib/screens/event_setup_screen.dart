import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_textfield.dart';
import 'package:intl/intl.dart';
import '../providers/event_provider.dart';
import '../providers/auth_provider.dart';
import '../utils/helpers.dart';

class EventSetupScreen extends StatefulWidget {
  const EventSetupScreen({super.key});

  @override
  State<EventSetupScreen> createState() => _EventSetupScreenState();
}

class _EventSetupScreenState extends State<EventSetupScreen> {
  final TextEditingController _eventNameController = TextEditingController();
  final TextEditingController _capacityController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isSaving = false;
  bool _isPublished = true;
  bool _requiresSecureKey = false;

  void _pickDate() {
    showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
      helpText: 'Select event date',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: const Color(0xFF1463FF),
                ),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    ).then((date) {
      if (date == null) return;
      setState(() => _selectedDate = date);
    });
  }

  void _pickTime() {
    showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      helpText: 'Select event time',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: const Color(0xFF1463FF),
                  onPrimary: Colors.white,
                ),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    ).then((time) {
      if (time == null) return;
      setState(() => _selectedTime = time);
    });
  }

  Future<void> _createEvent() async {
    if (_isSaving) return;

    setState(() {
      _isSaving = true;
    });

    final error = await context.read<EventProvider>().createEvent(
          eventName: _eventNameController.text,
          date: _selectedDate,
          time: _selectedTime,
          capacityText: _capacityController.text,
          isPublished: _isPublished,
          createdBy: context.read<AuthProvider>().email,
          requiresSecureKey: _requiresSecureKey,
        );

    if (!mounted) return;

    setState(() {
      _isSaving = false;
    });

    if (error != null) {
      Helpers.showSnack(context, error);
      return;
    }

    Helpers.showSnack(context, 'Event created successfully.');

    _eventNameController.clear();
    _capacityController.clear();
    setState(() {
      _selectedDate = null;
      _selectedTime = null;
      _isPublished = true;
      _requiresSecureKey = false;
    });
  }

  @override
  void dispose() {
    _eventNameController.dispose();
    _capacityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<EventProvider>(
        builder: (context, eventProvider, _) {
          final myEvents =
              eventProvider.eventsByCreator(context.read<AuthProvider>().email ?? '');

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _BuildHeader(
                    isPublished: _isPublished,
                    selectedDate: _selectedDate,
                    selectedTime: _selectedTime,
                  ),
                  const SizedBox(height: 20),
                  Card(
                    elevation: 0,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          CustomTextField(
                            label: 'Event Name',
                            hint: 'Enter event name',
                            controller: _eventNameController,
                            prefixIcon: Icons.event_outlined,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _PickerField(
                                  label: 'Date',
                                  value: _selectedDate != null
                                      ? DateFormat('EEE, dd MMM').format(_selectedDate!)
                                      : 'Pick date',
                                  icon: Icons.calendar_month,
                                  onTap: _pickDate,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _PickerField(
                                  label: 'Time',
                                  value: _selectedTime != null
                                      ? _selectedTime!.format(context)
                                      : 'Pick time',
                                  icon: Icons.access_time,
                                  onTap: _pickTime,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          CustomTextField(
                            label: 'Maximum Capacity',
                            hint: 'Enter max capacity',
                            keyboardType: TextInputType.number,
                            controller: _capacityController,
                            prefixIcon: Icons.people_outline,
                          ),
                          const SizedBox(height: 12),
                          SwitchListTile.adaptive(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Publish immediately'),
                            subtitle: const Text('Visible to all users in Home'),
                            value: _isPublished,
                            onChanged: (value) => setState(() => _isPublished = value),
                          ),
                          const SizedBox(height: 8),
                          SwitchListTile.adaptive(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Secure registration (6-digit key)'),
                            subtitle: const Text('Users must enter the key to register'),
                            value: _requiresSecureKey,
                            onChanged: (value) => setState(() => _requiresSecureKey = value),
                          ),
                          const SizedBox(height: 8),
                          CustomButton(
                            text: _isSaving ? 'Creating...' : 'Create Event',
                            onPressed: _createEvent,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text('My Events', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 12),
                  if (myEvents.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 24),
                      child: Center(child: Text('No events created yet.')),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: myEvents.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final event = myEvents[index];
                        return Card(
                          elevation: 1,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
                                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                                      ),
                                    ),
                                    Switch.adaptive(
                                      value: event.isPublished ?? true,
                                      onChanged: (value) =>
                                          context.read<EventProvider>().togglePublish(event, value),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  DateFormat('EEE, dd MMM yyyy • hh:mm a').format(event.eventDate),
                                  style: const TextStyle(color: Colors.black54),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Capacity: ${event.maxCapacity}',
                                  style: const TextStyle(color: Colors.black54),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _BuildHeader extends StatelessWidget {
  final bool isPublished;
  final DateTime? selectedDate;
  final TimeOfDay? selectedTime;

  const _BuildHeader({
    required this.isPublished,
    required this.selectedDate,
    required this.selectedTime,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1463FF), Color(0xFF6BA3FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.event_available, color: Colors.white),
              const SizedBox(width: 10),
              Text(
                isPublished ? 'Publishing enabled' : 'Draft mode',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Create a clean, visible event for your users.',
            style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          Text(
            'Date: ${selectedDate == null ? 'Not set' : DateFormat('EEE, dd MMM yyyy').format(selectedDate!)}\nTime: ${selectedTime == null ? 'Not set' : selectedTime!.format(context)}',
            style: const TextStyle(color: Colors.white70, height: 1.5),
          ),
        ],
      ),
    );
  }
}

class _PickerField extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onTap;

  const _PickerField({
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(icon, size: 18, color: Colors.grey.shade700),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    value,
                    style: TextStyle(
                      color: value.startsWith('Pick') ? Colors.grey.shade600 : Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}


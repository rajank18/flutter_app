import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_textfield.dart';
import 'package:horizontal_week_calendar/horizontal_week_calendar.dart';
import 'package:flutter_pickers/pickers.dart';
import 'package:flutter_pickers/time_picker/model/date_mode.dart';
import 'package:flutter_pickers/time_picker/model/pduration.dart';
import 'package:intl/intl.dart';
import '../providers/event_provider.dart';
import '../providers/attendance_provider.dart';
import '../routes/app_routes.dart';
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

  void _pickDate() {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return SizedBox(
          height: 350,
          child: HorizontalWeekCalendar(
            initialDate: _selectedDate ?? DateTime.now(),
            minDate: DateTime.now().subtract(const Duration(days: 365)),
            maxDate: DateTime.now().add(const Duration(days: 365)),
            showNavigationButtons: true,
            weekStartFrom: WeekStartFrom.Monday,
            onDateChange: (date) {
              setState(() {
                _selectedDate = date;
              });
              Navigator.pop(context);
            },
          ),
        );
      },
    );
  }

  void _pickTime() {
    Pickers.showDatePicker(
      context,
      mode: DateMode.HM,
      onConfirm: (PDuration data) {
        setState(() {
          _selectedTime = TimeOfDay(
            hour: data.hour ?? 0,
            minute: data.minute ?? 0,
          );
        });
      },
    );
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
        );

    if (!mounted) return;

    setState(() {
      _isSaving = false;
    });

    if (error != null) {
      Helpers.showSnack(context, error);
      return;
    }

    await context.read<AttendanceProvider>().initialize();
    Helpers.showSnack(context, 'Event created successfully.');
    Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
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
      appBar: AppBar(
        title: const Text('Event Setup'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Event Name',
              hint: 'Enter event name',
              controller: _eventNameController,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _PickerField(
                    label: 'Date',
                    value: _selectedDate != null ? DateFormat('yyyy-MM-dd').format(_selectedDate!) : 'Pick date',
                    icon: Icons.calendar_month,
                    onTap: _pickDate,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _PickerField(
                    label: 'Time',
                    value: _selectedTime != null ? _selectedTime!.format(context) : 'Pick time',
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
            ),
            const Spacer(),
            CustomButton(
              text: _isSaving ? 'Creating...' : 'Create Event',
              onPressed: _createEvent,
            ),
          ],
        ),
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

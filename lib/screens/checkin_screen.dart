import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_textfield.dart';
import '../providers/event_provider.dart';
import '../providers/attendance_provider.dart';
import '../services/qr_service.dart';
import '../utils/helpers.dart';

class CheckinScreen extends StatefulWidget {
  const CheckinScreen({super.key});

  @override
  State<CheckinScreen> createState() => _CheckinScreenState();
}

class _CheckinScreenState extends State<CheckinScreen> {
  final TextEditingController _idController = TextEditingController();
  final MobileScannerController _scannerController = MobileScannerController();
  bool _handlingScan = false;

  Future<void> _handleCheckIn(String rawId) async {
    final event = context.read<EventProvider>().event;
    final result = await context.read<AttendanceProvider>().checkInParticipant(
          participantRawId: rawId,
          event: event,
        );

    if (!mounted) return;

    await Helpers.showResultDialog(
      context,
      success: result.success,
      title: result.success ? 'Check-in Success' : 'Check-in Failed',
      message: result.message,
    );

    if (result.success) {
      _idController.clear();
    }
  }

  Future<void> _onScanCapture(BarcodeCapture capture) async {
    if (_handlingScan) return;
    final raw = capture.barcodes.isNotEmpty ? capture.barcodes.first.rawValue : null;
    if (raw == null || raw.trim().isEmpty) return;

    _handlingScan = true;
    final id = QrService.parseParticipantId(raw);
    await _handleCheckIn(id);
    _handlingScan = false;
  }

  @override
  void dispose() {
    _idController.dispose();
    _scannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 220,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade300),
            ),
            clipBehavior: Clip.antiAlias,
            child: MobileScanner(
              controller: _scannerController,
              onDetect: _onScanCapture,
            ),
          ),
          const SizedBox(height: 14),
          CustomTextField(
            label: 'Participant ID',
            hint: 'Scan or enter ID (e.g. P001)',
            controller: _idController,
          ),
          const SizedBox(height: 12),
          CustomButton(
            text: 'Check-in',
            onPressed: () => _handleCheckIn(_idController.text),
          ),
        ],
      ),
    );
  }
}

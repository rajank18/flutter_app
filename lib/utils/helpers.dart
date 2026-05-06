import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'app_colors.dart';

enum CrowdLevel { safe, moderate, full }

class Helpers {
	static String formatDateTime(DateTime dateTime) {
		return DateFormat('dd MMM yyyy, hh:mm a').format(dateTime);
	}

	static CrowdLevel crowdLevel({required int checkedIn, required int capacity}) {
		if (capacity <= 0) return CrowdLevel.full;
		final ratio = checkedIn / capacity;
		if (ratio >= 1) return CrowdLevel.full;
		if (ratio >= 0.7) return CrowdLevel.moderate;
		return CrowdLevel.safe;
	}

	static Color crowdColor(CrowdLevel level) {
		switch (level) {
			case CrowdLevel.safe:
				return AppColors.safe;
			case CrowdLevel.moderate:
				return AppColors.moderate;
			case CrowdLevel.full:
				return AppColors.full;
		}
	}

	static String crowdLabel(CrowdLevel level) {
		switch (level) {
			case CrowdLevel.safe:
				return 'Safe';
			case CrowdLevel.moderate:
				return 'Moderate';
			case CrowdLevel.full:
				return 'Full';
		}
	}

	static void showSnack(BuildContext context, String message) {
		ScaffoldMessenger.of(context).showSnackBar(
			SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
		);
	}

	static Future<void> showResultDialog(
		BuildContext context, {
		required bool success,
		required String title,
		required String message,
	}) async {
		await showDialog<void>(
			context: context,
			builder: (ctx) => AlertDialog(
				shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
				title: Row(
					children: [
						Icon(success ? Icons.check_circle : Icons.error, color: success ? AppColors.safe : AppColors.full),
						const SizedBox(width: 8),
						Text(title),
					],
				),
				content: Text(message),
				actions: [
					TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK')),
				],
			),
		);
	}
}


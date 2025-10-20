import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class UIHelpers {
  static void showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  static void showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  static void showInfoSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.blue,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  static void showToast(String message, {bool isError = false}) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: isError ? Colors.red : Colors.green,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  static Future<bool?> showConfirmDialog(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
  }) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(cancelText),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(confirmText),
            ),
          ],
        );
      },
    );
  }

  static void showLoadingDialog(BuildContext context, {String? message}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                if (message != null) ...[
                  const SizedBox(height: 16),
                  Text(message),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  static void hideLoadingDialog(BuildContext context) {
    Navigator.of(context).pop();
  }

  static void showErrorDialog(
    BuildContext context, {
    required String title,
    required String message,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.error, color: Colors.red),
              const SizedBox(width: 8),
              Text(title),
            ],
          ),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  static Future<DateTime?> showDatePickerDialog(
    BuildContext context, {
    DateTime? initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
  }) {
    return showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: firstDate ?? DateTime(2020),
      lastDate: lastDate ?? DateTime(2100),
    );
  }

  static Future<TimeOfDay?> showTimePickerDialog(
    BuildContext context, {
    TimeOfDay? initialTime,
  }) {
    return showTimePicker(
      context: context,
      initialTime: initialTime ?? TimeOfDay.now(),
    );
  }

  static void showBottomSheet(
    BuildContext context, {
    required Widget child,
    bool isDismissible = true,
  }) {
    showModalBottomSheet(
      context: context,
      isDismissible: isDismissible,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: child,
      ),
    );
  }

  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
      case 'delivered':
      case 'paid':
      case 'verified':
        return Colors.green;
      case 'pending':
      case 'scheduled':
        return Colors.orange;
      case 'paused':
      case 'missed':
      case 'partially_paid':
        return Colors.amber;
      case 'cancelled':
      case 'failed':
      case 'overdue':
        return Colors.red;
      case 'expired':
      case 'inactive':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }

  static IconData getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'active':
      case 'delivered':
      case 'paid':
      case 'verified':
        return Icons.check_circle;
      case 'pending':
      case 'scheduled':
        return Icons.pending;
      case 'paused':
        return Icons.pause_circle;
      case 'missed':
      case 'failed':
        return Icons.cancel;
      case 'cancelled':
        return Icons.block;
      case 'expired':
      case 'inactive':
        return Icons.info;
      default:
        return Icons.circle;
    }
  }
}

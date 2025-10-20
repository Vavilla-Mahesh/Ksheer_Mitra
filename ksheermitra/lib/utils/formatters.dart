import 'package:intl/intl.dart';

class Formatters {
  static String formatCurrency(double amount) {
    return '₹${amount.toStringAsFixed(2)}';
  }

  static String formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd MMM yyyy').format(date);
    } catch (e) {
      return dateString;
    }
  }

  static String formatDateTime(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd MMM yyyy, hh:mm a').format(date);
    } catch (e) {
      return dateString;
    }
  }

  static String formatTime(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('hh:mm a').format(date);
    } catch (e) {
      return dateString;
    }
  }

  static String formatPhone(String phone) {
    if (phone.startsWith('+91')) {
      final number = phone.substring(3);
      if (number.length == 10) {
        return '+91 ${number.substring(0, 5)} ${number.substring(5)}';
      }
    }
    return phone;
  }

  static String formatQuantity(double quantity, String unit) {
    return '${quantity.toStringAsFixed(quantity.truncateToDouble() == quantity ? 0 : 1)} $unit';
  }

  static String formatDistance(int meters) {
    if (meters < 1000) {
      return '$meters m';
    }
    return '${(meters / 1000).toStringAsFixed(1)} km';
  }

  static String formatDuration(int seconds) {
    if (seconds < 60) {
      return '$seconds sec';
    }
    if (seconds < 3600) {
      return '${(seconds / 60).round()} min';
    }
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    return '$hours hr ${minutes > 0 ? "$minutes min" : ""}';
  }

  static String getRelativeTime(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inSeconds < 60) {
        return 'Just now';
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes} minutes ago';
      } else if (difference.inHours < 24) {
        return '${difference.inHours} hours ago';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} days ago';
      } else {
        return formatDate(dateString);
      }
    } catch (e) {
      return dateString;
    }
  }

  static String getMonthYear(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('MMMM yyyy').format(date);
    } catch (e) {
      return dateString;
    }
  }

  static String capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  static String capitalizeWords(String text) {
    if (text.isEmpty) return text;
    return text.split(' ').map((word) => capitalizeFirst(word)).join(' ');
  }

  static String truncate(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  static String formatPercentage(double value) {
    return '${value.toStringAsFixed(1)}%';
  }

  static String formatInvoiceNumber(String type, String number) {
    final prefix = type == 'daily' ? 'INV-D' : 'INV-M';
    return '$prefix-$number';
  }
}

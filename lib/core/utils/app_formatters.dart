import 'package:flutter/material.dart';

class AppFormatters {
  AppFormatters._();

  static String birr(num amount) {
    final value = amount.round();
    final digits = value.toString();
    final buffer = StringBuffer();

    for (var i = 0; i < digits.length; i++) {
      final reverseIndex = digits.length - i;
      buffer.write(digits[i]);
      if (reverseIndex > 1 && reverseIndex % 3 == 1) {
        buffer.write(',');
      }
    }

    return 'ETB ${buffer.toString()}';
  }

  static String compactBirr(num amount) {
    if (amount >= 1000000) {
      return 'ETB ${(amount / 1000000).toStringAsFixed(1)}M';
    }
    if (amount >= 1000) {
      return 'ETB ${(amount / 1000).toStringAsFixed(0)}K';
    }
    return 'ETB ${amount.toStringAsFixed(0)}';
  }

  static String timeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    }
    if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    }
    return '${diff.inDays}d ago';
  }

  static Locale toLocale(String code) {
    return switch (code) {
      'am' => const Locale('am', 'ET'),
      _ => const Locale('en', 'US'),
    };
  }
}

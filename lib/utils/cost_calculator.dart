import 'dart:math';

/// Utility to calculate the human, psychological, and opportunity costs of a purchase.
class CostCalculator {
  /// Calculate how many hours of work are needed to pay for this item.
  /// If hourlyWage <= 0 or amount <= 0, returns null.
  static double? calculateWorkHours(double amount, double hourlyWage) {
    if (hourlyWage <= 0 || amount <= 0) return null;
    return amount / hourlyWage;
  }

  /// Format work hours into a friendly, visceral human string.
  /// e.g. "45 mins of work", "3.2 hrs of work", "2 workdays (16 hrs)"
  static String formatWorkHours(double hours) {
    if (hours <= 0) return '0 hrs';
    if (hours < 1) {
      final mins = (hours * 60).round();
      return '$mins min${mins == 1 ? '' : 's'} of work';
    } else if (hours < 8) {
      return '${hours.toStringAsFixed(1)} hrs of work';
    } else {
      final days = (hours / 8).floor(); // assuming 8-hour workday
      final remainingHours = (hours % 8).round();
      if (remainingHours == 0) {
        return '$days workday${days == 1 ? '' : 's'}';
      }
      return '$days day${days == 1 ? '' : 's'} $remainingHours hr${remainingHours == 1 ? '' : 's'} of work';
    }
  }

  /// Calculates future value if this exact amount was invested at compound interest
  /// Default: 8% CAGR over 20 years (typical broad market index like S&P 500)
  static double calculateFutureValue(double amount, {int years = 20, double annualReturn = 0.08}) {
    if (amount <= 0) return 0;
    return amount * pow(1 + annualReturn, years);
  }

  /// Calculates 10-year future value
  static double calculate10YearValue(double amount, {double annualReturn = 0.08}) {
    return calculateFutureValue(amount, years: 10, annualReturn: annualReturn);
  }

  /// Suggests a cooling period duration in hours based on the amount.
  /// - Under $30: 24 hours (Quick check)
  /// - $30 - $150: 48 hours (Standard impulse)
  /// - $150 - $500: 72 hours (Significant purchase)
  /// - Over $500: 168 hours / 7 days (Major commitment)
  static int suggestCoolingHours(double amount) {
    if (amount <= 0) return 48;
    if (amount < 30) return 24;
    if (amount <= 150) return 48;
    if (amount <= 500) return 72;
    return 168;
  }

  /// Formats cooling hours into a readable badge label
  /// e.g. "24h", "48h", "3 Days", "7 Days"
  static String formatCoolingHours(int hours) {
    if (hours < 24) return '${hours}h';
    if (hours == 24) return '24h (1 Day)';
    if (hours == 48) return '48h (2 Days)';
    if (hours % 24 == 0) {
      final days = hours ~/ 24;
      return '$days Days (${hours}h)';
    }
    return '${hours}h';
  }
}

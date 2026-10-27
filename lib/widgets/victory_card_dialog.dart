import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/wish_item.dart';
import '../utils/cost_calculator.dart';

class VictoryCardDialog extends StatelessWidget {
  final WishItem item;
  final String currencySymbol;
  final double totalSavedAllTime;
  final double? hourlyWage;

  const VictoryCardDialog({
    super.key,
    required this.item,
    required this.currencySymbol,
    required this.totalSavedAllTime,
    this.hourlyWage,
  });

  static Future<void> show(
    BuildContext context, {
    required WishItem item,
    required String currencySymbol,
    required double totalSavedAllTime,
    double? hourlyWage,
  }) {
    return showDialog(
      context: context,
      builder: (context) => VictoryCardDialog(
        item: item,
        currencySymbol: currencySymbol,
        totalSavedAllTime: totalSavedAllTime,
        hourlyWage: hourlyWage,
      ),
    );
  }

  void _share(BuildContext context) {
    final workHours = item.workHoursEquivalent ??
        (hourlyWage != null && hourlyWage! > 0
            ? CostCalculator.calculateWorkHours(item.amount, hourlyWage!)
            : null);

    final hoursText = workHours != null ? '\n⚡ Reclaimed: ${CostCalculator.formatWorkHours(workHours)}' : '';

    final shareText = '''
🛡️ I just defeated an impulse buy of "${item.title}"!
💰 Money saved: $currencySymbol${item.amount.toStringAsFixed(2)}$hoursText
📈 Total saved with Impulse Control: $currencySymbol${totalSavedAllTime.toStringAsFixed(2)}

Stop the 1-click economy. Cool off before you buy!
#ImpulseControl #FinancialFreedom #MindfulSpending
'''.trim();

    Clipboard.setData(ClipboardData(text: shareText));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🎉 Victory brag copied to clipboard! Ready to paste & share.'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final secondaryColor = Theme.of(context).colorScheme.secondary;

    final workHours = item.workHoursEquivalent ??
        (hourlyWage != null && hourlyWage! > 0
            ? CostCalculator.calculateWorkHours(item.amount, hourlyWage!)
            : null);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF181826) : Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: secondaryColor.withValues(alpha: isDark ? 0.35 : 0.2),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header Trophy & Confetti
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    Colors.amber.withValues(alpha: 0.3),
                    secondaryColor.withValues(alpha: 0.2),
                  ],
                ),
              ),
              child: const Text('🏆', style: TextStyle(fontSize: 40)),
            ),
            const SizedBox(height: 14),

            const Text(
              'Impulse Defeated!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Your future self thanks you.',
              style: TextStyle(fontSize: 13, color: Colors.grey[400]),
            ),
            const SizedBox(height: 20),

            // The Brag Card Container
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
                      : [const Color(0xFFF1F5F9), const Color(0xFFE2E8F0)],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: secondaryColor.withValues(alpha: 0.4),
                  width: 1.5,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.shield_outlined, size: 16, color: Colors.green),
                          const SizedBox(width: 6),
                          Text(
                            'IMPULSE CONTROL',
                            style: TextStyle(
                              letterSpacing: 1.2,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.grey[400] : Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'PASSED',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Item Name
                  Text(
                    item.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  // Big Saved Amount
                  Text(
                    '+$currencySymbol${item.amount.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      color: secondaryColor,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const Text(
                    'KEPT IN YOUR POCKET',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                      color: Colors.grey,
                    ),
                  ),

                  if (workHours != null && workHours > 0) ...[
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.bolt, color: Colors.amber, size: 15),
                          const SizedBox(width: 6),
                          Text(
                            '${CostCalculator.formatWorkHours(workHours)} reclaimed!',
                            style: const TextStyle(
                              color: Colors.amber,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const Divider(height: 28),

                  // All Time Saved
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Saved to Date',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                      Text(
                        '$currencySymbol${totalSavedAllTime.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Share & Close Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.share, size: 18),
                    label: const Text('Share Victory', style: TextStyle(fontWeight: FontWeight.bold)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      side: BorderSide(color: primaryColor),
                    ),
                    onPressed: () => _share(context),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: secondaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Done', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

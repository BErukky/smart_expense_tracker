import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/wish_item.dart';
import '../settings_provider.dart';
import '../utils/cost_calculator.dart';

class AnalyticsScreen extends StatelessWidget {
  final List<WishItem> wishes;

  const AnalyticsScreen({super.key, required this.wishes});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final secondaryColor = Theme.of(context).colorScheme.secondary;
    final settings = context.watch<SettingsProvider>();

    final passedItems = wishes.where((w) => w.status == WishStatus.passed).toList();
    final boughtItems = wishes.where((w) => w.status == WishStatus.bought).toList();
    final pendingItems = wishes.where((w) => w.status == WishStatus.pending).toList();

    final totalPassedMoney = passedItems.fold(0.0, (sum, w) => sum + w.amount);
    final totalBoughtMoney = boughtItems.fold(0.0, (sum, w) => sum + w.amount);
    final totalDecided = passedItems.length + boughtItems.length;

    final passRate = totalDecided > 0 ? (passedItems.length / totalDecided) * 100 : 0.0;
    final workHoursReclaimed = settings.hasHourlyWage ? totalPassedMoney / settings.hourlyWage : 0.0;

    final futureVal10 = CostCalculator.calculate10YearValue(totalPassedMoney);
    final futureVal20 = CostCalculator.calculateFutureValue(totalPassedMoney, years: 20);

    // Group passed items by category
    final Map<String, double> categoryTotals = {};
    for (var item in passedItems) {
      final cat = item.category ?? 'Other';
      categoryTotals[cat] = (categoryTotals[cat] ?? 0.0) + item.amount;
    }
    final sortedCategories = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Top 3 Hall of Fame saved items
    final hallOfFame = List<WishItem>.from(passedItems)
      ..sort((a, b) => b.amount.compareTo(a.amount));
    final topThree = hallOfFame.take(3).toList();

    String rankBadge;
    String rankTitle;
    if (passRate >= 80) {
      rankBadge = '🏆';
      rankTitle = 'Impulse Slayer';
    } else if (passRate >= 60) {
      rankBadge = '🛡️';
      rankTitle = 'Mindful Spender';
    } else if (passRate >= 40) {
      rankBadge = '⚖️';
      rankTitle = 'Balanced Buyer';
    } else {
      rankBadge = '🌱';
      rankTitle = 'Impulse Novice';
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Anti-Impulse Insights'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Rank Banner
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [const Color(0xFF1B2349), const Color(0xFF2E1B4E)]
                      : [const Color(0xFFE8EAF6), const Color(0xFFEDE7F6)],
                ),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: primaryColor.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDark ? Colors.black26 : Colors.white60,
                    ),
                    child: Text(rankBadge, style: const TextStyle(fontSize: 32)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          rankTitle,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          totalDecided == 0
                              ? 'Add items to the queue to unlock your mindful rating.'
                              : 'You defeat ${passRate.toStringAsFixed(0)}% of impulse urges!',
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? Colors.grey[300] : Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Top Stats Grid
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    title: 'Pass Rate',
                    value: totalDecided > 0 ? '${passRate.toStringAsFixed(0)}%' : '--',
                    subtitle: '${passedItems.length} passed / ${boughtItems.length} bought (${settings.currencySymbol}${totalBoughtMoney.toStringAsFixed(0)} spent)',
                    color: secondaryColor,
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    title: 'Total Saved',
                    value: '${settings.currencySymbol}${totalPassedMoney.toStringAsFixed(0)}',
                    subtitle: '${passedItems.length} impulses conquered',
                    color: primaryColor,
                    isDark: isDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    title: 'Life Energy Kept',
                    value: workHoursReclaimed > 0
                        ? CostCalculator.formatWorkHours(workHoursReclaimed)
                        : (settings.hasHourlyWage ? '0 hrs' : 'Set wage'),
                    subtitle: 'Hours of work reclaimed',
                    color: Colors.amber,
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    title: 'In Cooling Queue',
                    value: '${pendingItems.length}',
                    subtitle: 'Currently cooling off',
                    color: Colors.blueAccent,
                    isDark: isDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // Wealth Projection Card (Compound growth)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                    blurRadius: 16,
                  ),
                ],
                border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.trending_up, color: Colors.green),
                      const SizedBox(width: 8),
                      const Text(
                        'Future Wealth Projection',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'If your total saved money (${settings.currencySymbol}${totalPassedMoney.toStringAsFixed(0)}) stays invested in a low-cost index fund (@ 8% CAGR):',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          Text('In 10 Years', style: TextStyle(fontSize: 12, color: Colors.grey[400])),
                          const SizedBox(height: 4),
                          Text(
                            '${settings.currencySymbol}${futureVal10.toStringAsFixed(0)}',
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green),
                          ),
                        ],
                      ),
                      Container(height: 36, width: 1, color: isDark ? Colors.white12 : Colors.black12),
                      Column(
                        children: [
                          Text('In 20 Years', style: TextStyle(fontSize: 12, color: Colors.grey[400])),
                          const SizedBox(height: 4),
                          Text(
                            '${settings.currencySymbol}${futureVal20.toStringAsFixed(0)}',
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: secondaryColor),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Category Breakdown
            if (sortedCategories.isNotEmpty) ...[
              const Text(
                'Where You Resisted Most',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ...sortedCategories.map((entry) {
                final pct = totalPassedMoney > 0 ? entry.value / totalPassedMoney : 0.0;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(entry.key, style: const TextStyle(fontWeight: FontWeight.w600)),
                          Text(
                            '${settings.currencySymbol}${entry.value.toStringAsFixed(2)} (${(pct * 100).toStringAsFixed(0)}%)',
                            style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: pct,
                          minHeight: 8,
                          backgroundColor: isDark ? Colors.white10 : Colors.black12,
                          valueColor: AlwaysStoppedAnimation<Color>(secondaryColor),
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 28),
            ],

            // Hall of Fame
            if (topThree.isNotEmpty) ...[
              const Text(
                '🏆 Resisted Hall of Fame',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'Your top biggest avoided splurges:',
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
              const SizedBox(height: 12),
              ...topThree.map((item) => Card(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: secondaryColor.withValues(alpha: 0.15),
                        child: Icon(Icons.shield, color: secondaryColor, size: 20),
                      ),
                      title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(item.category ?? 'Impulse purchase'),
                      trailing: Text(
                        '+${settings.currencySymbol}${item.amount.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: secondaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  )),
              const SizedBox(height: 24),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String subtitle,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2C) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 12,
          ),
        ],
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[400], fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(subtitle, style: TextStyle(fontSize: 10, color: Colors.grey[500])),
        ],
      ),
    );
  }
}

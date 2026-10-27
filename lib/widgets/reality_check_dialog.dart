import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/wish_item.dart';
import '../services/ai_service.dart';
import '../settings_provider.dart';
import '../utils/cost_calculator.dart';

class RealityCheckDialog extends StatefulWidget {
  final String title;
  final double amount;
  final String? category;
  final DesireLevel desireLevel;
  final int lockDurationHours;

  const RealityCheckDialog({
    super.key,
    required this.title,
    required this.amount,
    this.category,
    required this.desireLevel,
    required this.lockDurationHours,
  });

  static Future<bool?> show(
    BuildContext context, {
    required String title,
    required double amount,
    String? category,
    required DesireLevel desireLevel,
    required int lockDurationHours,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => RealityCheckDialog(
        title: title,
        amount: amount,
        category: category,
        desireLevel: desireLevel,
        lockDurationHours: lockDurationHours,
      ),
    );
  }

  @override
  State<RealityCheckDialog> createState() => _RealityCheckDialogState();
}

class _RealityCheckDialogState extends State<RealityCheckDialog> {
  bool _q1Checked = false;
  bool _q2Checked = false;
  bool _q3Checked = false;

  String? _aiRoast;
  bool _isLoadingAi = true;

  @override
  void initState() {
    super.initState();
    _fetchAiAdvice();
  }

  void _fetchAiAdvice() async {
    final settings = context.read<SettingsProvider>();
    final workHours = CostCalculator.calculateWorkHours(widget.amount, settings.hourlyWage);

    try {
      final advice = await AiService().getRealityCheck(
        title: widget.title,
        amount: widget.amount,
        currencySymbol: settings.currencySymbol,
        category: widget.category,
        desireLevel: widget.desireLevel,
        workHours: workHours,
        apiKey: settings.aiApiKey,
        provider: settings.aiProvider,
      );
      if (mounted) {
        setState(() {
          _aiRoast = advice;
          _isLoadingAi = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoadingAi = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final settings = context.watch<SettingsProvider>();
    final workHours = CostCalculator.calculateWorkHours(widget.amount, settings.hourlyWage);

    return Dialog(
      backgroundColor: isDark ? const Color(0xFF1E1E2C) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 460),
        padding: const EdgeInsets.all(22),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Text('🧠', style: TextStyle(fontSize: 22)),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Reality Check',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Pause before locking in',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Item Summary Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF141420) : const Color(0xFFF3F6FA),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? Colors.white10 : Colors.black12,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            widget.title,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          '${settings.currencySymbol}${widget.amount.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    if (workHours != null) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.bolt, color: Colors.amber, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            CostCalculator.formatWorkHours(workHours),
                            style: const TextStyle(
                              color: Colors.amber,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // AI Advice Box
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [const Color(0xFF2E1B4E), const Color(0xFF1B2349)]
                        : [const Color(0xFFEDE7F6), const Color(0xFFE8EAF6)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.purple.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text('💬', style: TextStyle(fontSize: 14)),
                        const SizedBox(width: 6),
                        Text(
                          settings.hasAiKey
                              ? 'AI Devil\'s Advocate (${settings.aiProvider.toUpperCase()})'
                              : 'Impulse Devil\'s Advocate',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.purple[200] : Colors.purple[800],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _isLoadingAi
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            ),
                          )
                        : Text(
                            _aiRoast ?? 'Take a deep breath and let the timer do the thinking.',
                            style: TextStyle(
                              fontSize: 13,
                              height: 1.4,
                              fontStyle: FontStyle.italic,
                              color: isDark ? Colors.white.withValues(alpha: 0.9) : Colors.black87,
                            ),
                          ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 3 Reflection Questions
              const Text(
                'Check off if true for you:',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              _buildCheckTile(
                title: 'Will you still care about this in 3 months?',
                value: _q1Checked,
                onChanged: (v) => setState(() => _q1Checked = v ?? false),
                isDark: isDark,
              ),
              _buildCheckTile(
                title: 'You don\'t own anything that already does this?',
                value: _q2Checked,
                onChanged: (v) => setState(() => _q2Checked = v ?? false),
                isDark: isDark,
              ),
              _buildCheckTile(
                title: 'Given cash vs this item right now, you want this?',
                value: _q3Checked,
                onChanged: (v) => setState(() => _q3Checked = v ?? false),
                isDark: isDark,
              ),
              const SizedBox(height: 20),

              // Action Buttons
              Row(
                children: [
                  // Cancel / Abandon impulse
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        side: BorderSide(color: Colors.red.withValues(alpha: 0.5)),
                      ),
                      child: const Text('Pass Now 💸', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Lock into cooling queue
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: isDark ? Colors.black : Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                      child: Text(
                        'Lock (${widget.lockDurationHours}h) 🔒',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCheckTile({
    required String title,
    required bool value,
    required ValueChanged<bool?> onChanged,
    required bool isDark,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        onTap: () => onChanged(!value),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: value
                ? Colors.green.withValues(alpha: 0.12)
                : (isDark ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.03)),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: value ? Colors.green.withValues(alpha: 0.4) : Colors.transparent,
            ),
          ),
          child: Row(
            children: [
              Icon(
                value ? Icons.check_circle : Icons.radio_button_unchecked,
                size: 20,
                color: value ? Colors.green : Colors.grey,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: value ? (isDark ? Colors.green[300] : Colors.green[800]) : null,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

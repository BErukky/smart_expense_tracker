import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/wish_item.dart';
import '../settings_provider.dart';
import '../utils/cost_calculator.dart';
import 'item_detail_sheet.dart';

class WishTile extends StatefulWidget {
  final WishItem item;
  final VoidCallback onBuy;
  final VoidCallback onPass;
  final Function(WishItem updatedItem)? onUpdate;
  final VoidCallback? onDelete;

  const WishTile({
    super.key,
    required this.item,
    required this.onBuy,
    required this.onPass,
    this.onUpdate,
    this.onDelete,
  });

  @override
  State<WishTile> createState() => _WishTileState();
}

class _WishTileState extends State<WishTile> {
  Timer? _timer;
  late Duration _remaining;
  bool _isUnlocked = false;

  @override
  void initState() {
    super.initState();
    _calculateRemaining();
  }

  void _calculateRemaining() {
    if (widget.item.status != WishStatus.pending) return;

    final unlockTime = widget.item.unlockAt;
    final now = DateTime.now();

    if (now.isAfter(unlockTime)) {
      _isUnlocked = true;
      _remaining = Duration.zero;
    } else {
      _isUnlocked = false;
      _remaining = unlockTime.difference(now);
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!mounted) return;
        setState(() {
          final currentUnlockTime = widget.item.unlockAt;
          final currentNow = DateTime.now();
          if (currentNow.isAfter(currentUnlockTime)) {
            _isUnlocked = true;
            _remaining = Duration.zero;
            _timer?.cancel();
          } else {
            _remaining = currentUnlockTime.difference(currentNow);
          }
        });
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    if (d <= Duration.zero) return 'Ready to decide!';
    final days = d.inDays;
    final hours = d.inHours % 24;
    final minutes = d.inMinutes % 60;
    final seconds = d.inSeconds % 60;

    String twoDigits(int n) => n.toString().padLeft(2, '0');

    if (days > 0) {
      return '${days}d ${hours}h ${twoDigits(minutes)}m';
    }
    return '${twoDigits(d.inHours)}h ${twoDigits(minutes)}m ${twoDigits(seconds)}s';
  }

  double _calculateProgress() {
    final totalSeconds = widget.item.lockDurationHours * 3600;
    if (totalSeconds <= 0) return 1.0;
    final elapsedSeconds = DateTime.now().difference(widget.item.createdAt).inSeconds;
    return (elapsedSeconds / totalSeconds).clamp(0.0, 1.0);
  }

  Color _getDesireColor() {
    switch (widget.item.desireLevel) {
      case DesireLevel.high:
        return const Color(0xFFFF5252); // Red accent
      case DesireLevel.medium:
        return const Color(0xFFFFAB40); // Amber/orange accent
      case DesireLevel.low:
        return const Color(0xFF69F0AE); // Green accent
    }
  }

  String _getCategoryIcon(String? category) {
    switch (category?.toLowerCase()) {
      case 'tech':
        return '💻';
      case 'fashion':
      case 'clothes':
        return '👕';
      case 'gaming':
        return '🎮';
      case 'dining':
      case 'food':
        return '🍔';
      case 'books':
        return '📚';
      case 'gadgets':
      default:
        return '🎧';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPending = widget.item.status == WishStatus.pending;
    final isPassed = widget.item.status == WishStatus.passed;
    final isBought = widget.item.status == WishStatus.bought;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final primaryColor = Theme.of(context).colorScheme.primary;
    final secondaryColor = Theme.of(context).colorScheme.secondary;
    final cardColor = Theme.of(context).cardColor;
    final settings = context.watch<SettingsProvider>();

    final workHours = widget.item.workHoursEquivalent ??
        (settings.hasHourlyWage
            ? CostCalculator.calculateWorkHours(widget.item.amount, settings.hourlyWage)
            : null);

    final progress = _calculateProgress();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.05),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(
          color: isPassed
              ? secondaryColor.withValues(alpha: 0.6)
              : _getDesireColor().withValues(alpha: isDark ? 0.35 : 0.2),
          width: isPassed ? 2 : 1.5,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            ItemDetailSheet.show(
              context,
              item: widget.item,
              onUpdate: (updated) => widget.onUpdate?.call(updated),
              onDelete: () => widget.onDelete?.call(),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Hero Image
          if (widget.item.imageUrl != null && widget.item.imageUrl!.isNotEmpty)
            SizedBox(
              height: 130,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    widget.item.imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: isDark ? Colors.white10 : Colors.black12,
                        child: const Icon(Icons.broken_image, color: Colors.grey),
                      );
                    },
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          cardColor,
                        ],
                        stops: const [0.35, 1.0],
                      ),
                    ),
                  ),
                ],
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Tags (Category, Desire Urgency, Lock Duration)
                Row(
                  children: [
                    // Category badge
                    if (widget.item.category != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(_getCategoryIcon(widget.item.category), style: const TextStyle(fontSize: 12)),
                            const SizedBox(width: 4),
                            Text(
                              widget.item.category!,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.grey[300] : Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Desire badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getDesireColor().withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${widget.item.desireLevel.name.toUpperCase()} DESIRE',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: _getDesireColor(),
                        ),
                      ),
                    ),

                    const Spacer(),

                    // Lock Duration badge
                    if (isPending)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: primaryColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${widget.item.lockDurationHours}h LOCK',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),

                // Title & Price
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        widget.item.title,
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black87,
                          fontSize: 19,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${settings.currencySymbol}${widget.item.amount.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: isPassed ? secondaryColor : primaryColor,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                // Life Energy Badge
                if (workHours != null && workHours > 0) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.bolt, color: Colors.amber, size: 15),
                      const SizedBox(width: 4),
                      Text(
                        'Equal to ${CostCalculator.formatWorkHours(workHours)}',
                        style: const TextStyle(
                          color: Colors.amber,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],

                // Pending State (Countdown or Action buttons)
                if (isPending) ...[
                  const SizedBox(height: 14),

                  if (!_isUnlocked) ...[
                    // Progress bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 6,
                        backgroundColor: isDark ? Colors.white10 : Colors.black12,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          progress >= 1.0 ? secondaryColor : primaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.03),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.lock_clock, color: isDark ? Colors.grey[400] : Colors.grey[600], size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Unlocks in ${_formatDuration(_remaining)}',
                              style: TextStyle(
                                color: isDark ? Colors.grey[300] : Colors.grey[800],
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          // DEV TESTING BUTTON: Fast Forward
                          IconButton(
                            icon: const Icon(Icons.fast_forward, color: Colors.blueAccent, size: 20),
                            tooltip: 'Unlock Now (Demo / Test)',
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () {
                              setState(() {
                                _isUnlocked = true;
                                _timer?.cancel();
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    // Unlocked decision buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.shopping_bag_outlined, size: 18),
                            label: const Text('Buy Now', style: TextStyle(fontWeight: FontWeight.bold)),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              side: BorderSide(color: primaryColor.withValues(alpha: 0.5)),
                              foregroundColor: primaryColor,
                            ),
                            onPressed: widget.onBuy,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.shield, size: 18),
                            label: const Text('Pass & Save', style: TextStyle(fontWeight: FontWeight.bold)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: secondaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 0,
                            ),
                            onPressed: widget.onPass,
                          ),
                        ),
                      ],
                    ),
                  ],
                ] else ...[
                  // Resolved status badge
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    decoration: BoxDecoration(
                      color: isBought
                          ? Colors.grey.withValues(alpha: 0.12)
                          : secondaryColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isBought ? Icons.shopping_bag : Icons.shield,
                          size: 16,
                          color: isBought ? Colors.grey : secondaryColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isBought
                              ? 'Bought'
                              : 'Impulse Defeated! Kept ${settings.currencySymbol}${widget.item.amount.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: isBought ? Colors.grey : secondaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    ),
  ),
);
  }
}

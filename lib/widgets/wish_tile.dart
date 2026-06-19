import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/wish_item.dart';
import '../settings_provider.dart';

class WishTile extends StatefulWidget {
  final WishItem item;
  final VoidCallback onBuy;
  final VoidCallback onPass;

  const WishTile({
    super.key,
    required this.item,
    required this.onBuy,
    required this.onPass,
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

    final unlockTime = widget.item.createdAt.add(const Duration(hours: 48));
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
          final currentUnlockTime = widget.item.createdAt.add(const Duration(hours: 48));
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
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(d.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(d.inSeconds.remainder(60));
    return "${twoDigits(d.inHours)}h ${twoDigitMinutes}m ${twoDigitSeconds}s";
  }

  Color _getDesireColor() {
    switch (widget.item.desireLevel) {
      case DesireLevel.high:
        return Colors.redAccent;
      case DesireLevel.medium:
        return Colors.orangeAccent;
      case DesireLevel.low:
        return Colors.greenAccent;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPending = widget.item.status == WishStatus.pending;
    final isBought = widget.item.status == WishStatus.bought;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final primaryColor = Theme.of(context).colorScheme.primary;
    final secondaryColor = Theme.of(context).colorScheme.secondary;
    final cardColor = Theme.of(context).cardColor;
    final currencySymbol = context.watch<SettingsProvider>().currencySymbol;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(
          color: _getDesireColor().withOpacity(isDark ? 0.3 : 0.2),
          width: 2,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Hero Image Section
          if (widget.item.imageUrl != null && widget.item.imageUrl!.isNotEmpty)
            SizedBox(
              height: 140,
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
                  // Gradient overlay to make text pop
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          cardColor,
                        ],
                        stops: const [0.4, 1.0],
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.item.title,
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black87,
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getDesireColor().withOpacity(0.1),
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
                        ],
                      ),
                    ),
                    Text(
                      '$currencySymbol${widget.item.amount.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: primaryColor,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                
                if (isPending) ...[
                  const SizedBox(height: 20),
                  if (!_isUnlocked)
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.lock_clock, color: isDark ? Colors.grey[400] : Colors.grey[600], size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Unlocks in ${_formatDuration(_remaining)}',
                              style: TextStyle(
                                color: isDark ? Colors.grey[300] : Colors.grey[700],
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          // DEV TESTING BUTTON: Fast Forward
                          IconButton(
                            icon: const Icon(Icons.fast_forward, color: Colors.blueAccent),
                            tooltip: 'Skip Timer (Test Mode)',
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
                    )
                  else
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor.withOpacity(0.1),
                              foregroundColor: primaryColor,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: widget.onBuy,
                            child: const Text('Buy Now', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: secondaryColor.withOpacity(0.1),
                              foregroundColor: secondaryColor,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: widget.onPass,
                            child: const Text('Pass (Save \$)', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                ] else ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    decoration: BoxDecoration(
                      color: isBought 
                          ? Colors.grey.withOpacity(0.1) 
                          : secondaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isBought ? Icons.shopping_bag : Icons.savings,
                          size: 16,
                          color: isBought ? Colors.grey : secondaryColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isBought ? 'Bought' : 'Passed & Saved!',
                          style: TextStyle(
                            color: isBought ? Colors.grey : secondaryColor,
                            fontWeight: FontWeight.bold,
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
    );
  }
}

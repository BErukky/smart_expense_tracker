import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/wish_item.dart';
import '../widgets/wish_tile.dart';
import 'add_wish_screen.dart';
import '../settings_provider.dart';
import '../services/notification_service.dart';
import '../utils/cost_calculator.dart';
import '../widgets/settings_dialog.dart';
import '../widgets/victory_card_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<WishItem> _wishes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWishes();
  }

  Future<void> _loadWishes() async {
    final prefs = await SharedPreferences.getInstance();
    final wishesJson = prefs.getStringList('wishes') ?? [];

    setState(() {
      _wishes = wishesJson.map((json) => WishItem.fromJson(json)).toList();
      _isLoading = false;
    });
  }

  Future<void> _saveWishes() async {
    final prefs = await SharedPreferences.getInstance();
    final wishesJson = _wishes.map((wish) => wish.toJson()).toList();
    await prefs.setStringList('wishes', wishesJson);
  }

  void _addWish() async {
    final wish = await Navigator.of(context).push<WishItem>(
      MaterialPageRoute(
        builder: (context) => const AddWishScreen(),
      ),
    );

    if (wish != null) {
      setState(() {
        _wishes.add(wish);
      });
      await _saveWishes();

      // If user passed immediately in the Reality Check dialog, celebrate!
      if (wish.status == WishStatus.passed && mounted) {
        final settings = context.read<SettingsProvider>();
        VictoryCardDialog.show(
          context,
          item: wish,
          currencySymbol: settings.currencySymbol,
          totalSavedAllTime: _moneySaved,
          hourlyWage: settings.hourlyWage,
        );
      }
    }
  }

  void _updateStatus(int index, WishStatus newStatus) async {
    final item = _wishes[index];
    setState(() {
      _wishes[index] = item.copyWith(status: newStatus);
    });

    // Cancel pending notification reminders if resolved
    if (newStatus != WishStatus.pending) {
      await NotificationService().cancelNotifications(item);
    }

    await _saveWishes();

    // Trigger Victory celebration when user passes!
    if (newStatus == WishStatus.passed && mounted) {
      final settings = context.read<SettingsProvider>();
      VictoryCardDialog.show(
        context,
        item: item,
        currencySymbol: settings.currencySymbol,
        totalSavedAllTime: _moneySaved,
        hourlyWage: settings.hourlyWage,
      );
    }
  }

  double get _moneySaved {
    return _wishes
        .where((w) => w.status == WishStatus.passed)
        .fold(0.0, (sum, wish) => sum + wish.amount);
  }

  double get _hoursSaved {
    final wage = context.watch<SettingsProvider>().hourlyWage;
    if (wage <= 0) return 0.0;
    return _moneySaved / wage;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final secondaryColor = Theme.of(context).colorScheme.secondary;
    final currencySymbol = context.watch<SettingsProvider>().currencySymbol;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Impulse Control'),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            tooltip: 'Preferences & Wage',
            onPressed: () => SettingsDialog.show(context),
          ),
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            tooltip: 'Toggle Theme',
            onPressed: () {
              context.read<SettingsProvider>().toggleTheme();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Total Money & Life Energy Saved Dashboard
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: secondaryColor.withValues(alpha: isDark ? 0.35 : 0.15),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: secondaryColor.withValues(alpha: isDark ? 0.12 : 0.06),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.shield, color: secondaryColor, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            'Total Money Saved',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white.withValues(alpha: 0.7) : Colors.black54,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '$currencySymbol${_moneySaved.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 44,
                          fontWeight: FontWeight.bold,
                          color: secondaryColor,
                          letterSpacing: -0.5,
                        ),
                      ),
                      if (_hoursSaved > 0) ...[
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.amber.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '⚡ ${CostCalculator.formatWorkHours(_hoursSaved)} of life energy reclaimed!',
                            style: const TextStyle(
                              color: Colors.amber,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Your Cooling Queue',
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      Text(
                        '${_wishes.where((w) => w.status == WishStatus.pending).length} pending',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: _wishes.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.shopping_bag_outlined,
                                size: 64,
                                color: isDark ? Colors.white.withValues(alpha: 0.2) : Colors.black12,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Your queue is empty!\nTap + when you feel an impulse to buy.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: isDark ? Colors.white.withValues(alpha: 0.5) : Colors.black38,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: _wishes.length,
                          itemBuilder: (context, index) {
                            final item = _wishes.reversed.toList()[index];
                            final originalIndex = _wishes.indexOf(item);
                            return WishTile(
                              key: ValueKey(item.id),
                              item: item,
                              onBuy: () => _updateStatus(originalIndex, WishStatus.bought),
                              onPass: () => _updateStatus(originalIndex, WishStatus.passed),
                            );
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addWish,
        backgroundColor: primaryColor,
        foregroundColor: isDark ? Colors.black : Colors.white,
        child: const Icon(Icons.add, size: 30),
      ),
    );
  }
}
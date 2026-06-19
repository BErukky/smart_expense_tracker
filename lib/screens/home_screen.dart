import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/wish_item.dart';
import '../widgets/wish_tile.dart';
import 'add_wish_screen.dart';
import '../settings_provider.dart';
import '../services/notification_service.dart';

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
      _wishes = wishesJson
          .map((json) => WishItem.fromJson(json))
          .toList();
      _isLoading = false;
    });
  }

  Future<void> _saveWishes() async {
    final prefs = await SharedPreferences.getInstance();
    final wishesJson = _wishes
        .map((wish) => wish.toJson())
        .toList();
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
    }
  }

  void _updateStatus(int index, WishStatus newStatus) async {
    final item = _wishes[index];
    setState(() {
      _wishes[index] = item.copyWith(status: newStatus);
    });
    
    // Cancel any pending notifications if the user resolved the item
    if (newStatus != WishStatus.pending) {
      await NotificationService().cancelNotifications(item);
    }
    
    await _saveWishes();
  }

  double get _moneySaved {
    return _wishes
        .where((w) => w.status == WishStatus.passed)
        .fold(0.0, (sum, wish) => sum + wish.amount);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currencySymbol = context.watch<SettingsProvider>().currencySymbol;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Impulse Control'),
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
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
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.secondary.withOpacity(isDark ? 0.3 : 0.1),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).colorScheme.secondary.withOpacity(isDark ? 0.1 : 0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                      if (!isDark)
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Total Money Saved',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white.withOpacity(0.7) : Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$currencySymbol${_moneySaved.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Your Queue',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: _wishes.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.shopping_bag_outlined, size: 64, color: isDark ? Colors.white.withOpacity(0.2) : Colors.black12),
                              const SizedBox(height: 16),
                              Text(
                                'Your queue is empty!\nAdd something you want to buy.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: isDark ? Colors.white.withOpacity(0.5) : Colors.black38,
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
                              key: ValueKey(item.id), // Fix: ensures unique state per item
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
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: isDark ? Colors.black : Colors.white,
        child: const Icon(Icons.add, size: 32),
      ),
    );
  }
}
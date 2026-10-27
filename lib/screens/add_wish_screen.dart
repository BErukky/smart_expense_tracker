import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import '../models/wish_item.dart';
import '../services/notification_service.dart';
import '../services/url_scraper_service.dart';
import '../settings_provider.dart';
import '../utils/cost_calculator.dart';
import '../widgets/reality_check_dialog.dart';
import '../widgets/settings_dialog.dart';

class AddWishScreen extends StatefulWidget {
  const AddWishScreen({super.key});

  @override
  State<AddWishScreen> createState() => _AddWishScreenState();
}

class _AddWishScreenState extends State<AddWishScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _imageController = TextEditingController();

  DesireLevel _selectedDesire = DesireLevel.medium;
  String _selectedCategory = 'Gadgets';
  int _selectedDurationHours = 48;
  bool _manuallyOverrodeDuration = false;

  final List<Map<String, String>> _categories = [
    {'name': 'Gadgets', 'icon': '🎧'},
    {'name': 'Tech', 'icon': '💻'},
    {'name': 'Fashion', 'icon': '👕'},
    {'name': 'Gaming', 'icon': '🎮'},
    {'name': 'Dining', 'icon': '🍔'},
    {'name': 'Books', 'icon': '📚'},
    {'name': 'Other', 'icon': '✨'},
  ];

  final List<int> _durations = [24, 48, 72, 168];
  bool _isScraping = false;

  void _pasteAndScrapeLink() async {
    final clipData = await Clipboard.getData(Clipboard.kTextPlain);
    final text = clipData?.text?.trim();
    if (text == null || (!text.startsWith('http://') && !text.startsWith('https://'))) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please copy a valid product URL (http/https) first!'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    setState(() => _isScraping = true);

    final product = await UrlScraperService().scrapeUrl(text);

    if (mounted) {
      setState(() => _isScraping = false);
      if (product != null) {
        if (product.title != null && product.title!.isNotEmpty) {
          _titleController.text = product.title!;
        }
        if (product.amount != null && product.amount! > 0) {
          _amountController.text = product.amount!.toStringAsFixed(2);
        }
        if (product.imageUrl != null && product.imageUrl!.isNotEmpty) {
          _imageController.text = product.imageUrl!;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('⚡ Product details auto-filled from link!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not auto-extract details. You can enter them manually.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _amountController.addListener(_onAmountChanged);
  }

  void _onAmountChanged() {
    if (_manuallyOverrodeDuration) return;
    final amount = double.tryParse(_amountController.text.trim()) ?? 0.0;
    if (amount > 0) {
      final suggested = CostCalculator.suggestCoolingHours(amount);
      if (suggested != _selectedDurationHours) {
        setState(() {
          _selectedDurationHours = suggested;
        });
      }
    }
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final title = _titleController.text.trim();
    final amount = double.parse(_amountController.text.trim());
    final imageUrl = _imageController.text.trim();
    final settings = context.read<SettingsProvider>();
    final workHours = CostCalculator.calculateWorkHours(amount, settings.hourlyWage);

    // Show the Reality Check Interrogation modal
    final decision = await RealityCheckDialog.show(
      context,
      title: title,
      amount: amount,
      category: _selectedCategory,
      desireLevel: _selectedDesire,
      lockDurationHours: _selectedDurationHours,
    );

    if (decision == null) return; // User closed dialog

    if (decision == true) {
      // 1. Confirmed: Lock into cooling queue
      final newItem = WishItem(
        id: const Uuid().v4(),
        title: title,
        amount: amount,
        createdAt: DateTime.now(),
        status: WishStatus.pending,
        imageUrl: imageUrl.isEmpty ? null : imageUrl,
        desireLevel: _selectedDesire,
        lockDurationHours: _selectedDurationHours,
        workHoursEquivalent: workHours,
        category: _selectedCategory,
      );

      await NotificationService().scheduleWishNotifications(newItem);

      if (mounted) {
        Navigator.of(context).pop(newItem);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('🔒 "$title" locked for ${_selectedDurationHours}h!'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      }
    } else {
      // 2. Passed on the spot! Instant money saved win!
      final passedItem = WishItem(
        id: const Uuid().v4(),
        title: title,
        amount: amount,
        createdAt: DateTime.now(),
        status: WishStatus.passed,
        imageUrl: imageUrl.isEmpty ? null : imageUrl,
        desireLevel: _selectedDesire,
        lockDurationHours: _selectedDurationHours,
        workHoursEquivalent: workHours,
        category: _selectedCategory,
      );

      if (mounted) {
        Navigator.of(context).pop(passedItem);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('🎉 Passed immediately! Saved ${settings.currencySymbol}$amount!'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _amountController.removeListener(_onAmountChanged);
    _titleController.dispose();
    _amountController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final settings = context.watch<SettingsProvider>();

    final currentAmount = double.tryParse(_amountController.text.trim()) ?? 0.0;
    final workHours = CostCalculator.calculateWorkHours(currentAmount, settings.hourlyWage);
    final futureVal20 = CostCalculator.calculateFutureValue(currentAmount, years: 20);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add to Cooling Queue'),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            tooltip: 'Preferences & Wage',
            onPressed: () => SettingsDialog.show(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Paste Link Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'What do you want to buy?',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                  TextButton.icon(
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      visualDensity: VisualDensity.compact,
                    ),
                    icon: _isScraping
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.link, size: 16),
                    label: Text(_isScraping ? 'Scanning...' : 'Paste Store Link 🔗'),
                    onPressed: _isScraping ? null : _pasteAndScrapeLink,
                  ),
                ],
              ),
              const SizedBox(height: 4),

              // Title Input
              TextFormField(
                controller: _titleController,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
                decoration: InputDecoration(
                  hintText: 'What are you tempted to buy?',
                  hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.black38),
                  border: InputBorder.none,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return 'Please enter what you want.';
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Price Input
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    settings.currencySymbol,
                    style: TextStyle(
                      color: primaryColor,
                      fontSize: 38,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _amountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: TextStyle(
                        color: primaryColor,
                        fontSize: 38,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: InputDecoration(
                        hintText: '0.00',
                        hintStyle: TextStyle(color: primaryColor.withValues(alpha: 0.3)),
                        border: InputBorder.none,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) return 'Enter an amount.';
                        if (double.tryParse(value) == null) return 'Enter a valid number.';
                        if (double.parse(value) <= 0) return 'Amount must be greater than 0.';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Live "True Cost" / Perspective Card
              if (currentAmount > 0)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1B1B2A) : const Color(0xFFEDF2F7),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isDark ? Colors.white12 : Colors.black12,
                    ),
                  ),
                  child: Column(
                    children: [
                      // Work hours equivalent
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.amber.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.bolt, color: Colors.amber, size: 18),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: settings.hasHourlyWage
                                ? RichText(
                                    text: TextSpan(
                                      style: TextStyle(
                                        color: isDark ? Colors.white : Colors.black87,
                                        fontSize: 13,
                                      ),
                                      children: [
                                        const TextSpan(text: 'Life Energy: '),
                                        TextSpan(
                                          text: CostCalculator.formatWorkHours(workHours ?? 0),
                                          style: const TextStyle(
                                            color: Colors.amber,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : InkWell(
                                    onTap: () => SettingsDialog.show(context),
                                    child: const Text(
                                      '⚡ Set your hourly wage to see life hours cost →',
                                      style: TextStyle(
                                        color: Colors.amber,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      // Opportunity Cost
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.trending_up, color: Colors.green, size: 18),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                style: TextStyle(
                                  color: isDark ? Colors.white : Colors.black87,
                                  fontSize: 13,
                                ),
                                children: [
                                  const TextSpan(text: 'Opportunity Cost: '),
                                  TextSpan(
                                    text: '${settings.currencySymbol}${futureVal20.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextSpan(
                                    text: ' in 20 yrs (@ 8% CAGR)',
                                    style: TextStyle(
                                      color: Colors.grey[400],
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 20),

              // Categories Chips
              Text(
                'Category',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _categories.map((cat) {
                    final isSelected = _selectedCategory == cat['name'];
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        avatar: Text(cat['icon']!),
                        label: Text(cat['name']!),
                        selected: isSelected,
                        onSelected: (val) {
                          if (val) setState(() => _selectedCategory = cat['name']!);
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20),

              // Dynamic Cooling Lock Duration
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Cooling Lock Duration',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                  if (currentAmount > 0 && !_manuallyOverrodeDuration)
                    Text(
                      'AI Suggested',
                      style: TextStyle(
                        fontSize: 11,
                        color: primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: _durations.map((hours) {
                  final isSelected = _selectedDurationHours == hours;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: ChoiceChip(
                        label: Center(
                          child: Text(
                            hours == 168 ? '7 Days' : '${hours}h',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                        selected: isSelected,
                        onSelected: (val) {
                          if (val) {
                            setState(() {
                              _selectedDurationHours = hours;
                              _manuallyOverrodeDuration = true;
                            });
                          }
                        },
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Desire Level
              Text(
                'Impulse Urgency Level',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
              const SizedBox(height: 8),
              SegmentedButton<DesireLevel>(
                segments: const [
                  ButtonSegment(
                    value: DesireLevel.low,
                    label: Text('Low 😊'),
                  ),
                  ButtonSegment(
                    value: DesireLevel.medium,
                    label: Text('Medium 🤔'),
                  ),
                  ButtonSegment(
                    value: DesireLevel.high,
                    label: Text('High 🔥'),
                  ),
                ],
                selected: {_selectedDesire},
                onSelectionChanged: (newSelection) {
                  setState(() => _selectedDesire = newSelection.first);
                },
                style: SegmentedButton.styleFrom(
                  selectedBackgroundColor: primaryColor.withValues(alpha: 0.2),
                  selectedForegroundColor: primaryColor,
                  backgroundColor: Theme.of(context).cardColor,
                ),
              ),
              const SizedBox(height: 20),

              // Optional Image URL
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
                ),
                child: TextFormField(
                  controller: _imageController,
                  style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                  decoration: InputDecoration(
                    icon: Icon(Icons.image_outlined, color: isDark ? Colors.white54 : Colors.black54),
                    hintText: 'Image URL (Optional)',
                    hintStyle: TextStyle(color: isDark ? Colors.white30 : Colors.black26),
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // Submit Button -> Reality Check
              ElevatedButton.icon(
                icon: const Icon(Icons.lock_clock),
                label: Text(
                  'Cool Off for ${_selectedDurationHours == 168 ? '7 Days' : '$_selectedDurationHours Hours'}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: isDark ? Colors.black : Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                onPressed: _submit,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

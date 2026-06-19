import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:provider/provider.dart';
import '../models/wish_item.dart';
import '../services/notification_service.dart';
import '../settings_provider.dart';

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

  void _saveItem() async {
    if (_formKey.currentState!.validate()) {
      final imageUrl = _imageController.text.trim();
      final newItem = WishItem(
        id: Uuid().v4(),
        title: _titleController.text.trim(),
        amount: double.parse(_amountController.text.trim()),
        createdAt: DateTime.now(),
        status: WishStatus.pending,
        imageUrl: imageUrl.isEmpty ? null : imageUrl,
        desireLevel: _selectedDesire,
      );
      
      // Schedule the unlock and reminder notifications
      await NotificationService().scheduleWishNotifications(newItem);

      if (mounted) Navigator.of(context).pop(newItem);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final currencySymbol = context.watch<SettingsProvider>().currencySymbol;

    return Scaffold(
      appBar: AppBar(
        title: const Text('I want to buy...'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 24),
                decoration: InputDecoration(
                  hintText: 'e.g. New Headphones',
                  hintStyle: TextStyle(color: isDark ? Colors.white30 : Colors.black26),
                  border: InputBorder.none,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return 'Please enter what you want.';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: TextStyle(color: primaryColor, fontSize: 40, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  prefixText: '$currencySymbol ',
                  prefixStyle: TextStyle(color: primaryColor, fontSize: 40, fontWeight: FontWeight.bold),
                  hintText: '0.00',
                  hintStyle: TextStyle(color: primaryColor.withOpacity(0.3)),
                  border: InputBorder.none,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return 'Enter an amount.';
                  if (double.tryParse(value) == null) return 'Enter a valid number.';
                  return null;
                },
              ),
              const SizedBox(height: 32),
              // Image URL Input
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
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
              const SizedBox(height: 32),
              // Desire Level
              Text(
                'Desire Level',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
              const SizedBox(height: 12),
              SegmentedButton<DesireLevel>(
                segments: const [
                  ButtonSegment(value: DesireLevel.low, label: Text('Low')),
                  ButtonSegment(value: DesireLevel.medium, label: Text('Medium')),
                  ButtonSegment(value: DesireLevel.high, label: Text('High')),
                ],
                selected: {_selectedDesire},
                onSelectionChanged: (Set<DesireLevel> newSelection) {
                  setState(() {
                    _selectedDesire = newSelection.first;
                  });
                },
                style: SegmentedButton.styleFrom(
                  selectedBackgroundColor: primaryColor.withOpacity(0.2),
                  selectedForegroundColor: primaryColor,
                  backgroundColor: Theme.of(context).cardColor,
                ),
              ),
              const SizedBox(height: 48),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: primaryColor),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Adding this will lock it in the Cooling Queue for 48 hours to prevent an impulse buy.',
                        style: TextStyle(color: primaryColor.withOpacity(0.8)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: isDark ? Colors.black : Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: _saveItem,
                child: const Text(
                  'Add to Cooling Queue',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

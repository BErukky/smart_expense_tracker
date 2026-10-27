import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:currency_picker/currency_picker.dart';
import '../settings_provider.dart';

class SettingsDialog extends StatefulWidget {
  const SettingsDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const SettingsDialog(),
    );
  }

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  late TextEditingController _wageController;
  late TextEditingController _apiKeyController;
  late String _selectedProvider;

  @override
  void initState() {
    super.initState();
    final settings = context.read<SettingsProvider>();
    _wageController = TextEditingController(
      text: settings.hourlyWage > 0 ? settings.hourlyWage.toStringAsFixed(0) : '',
    );
    _apiKeyController = TextEditingController(text: settings.aiApiKey ?? '');
    _selectedProvider = settings.aiProvider;
  }

  @override
  void dispose() {
    _wageController.dispose();
    _apiKeyController.dispose();
    super.dispose();
  }

  void _saveSettings() {
    final settings = context.read<SettingsProvider>();
    
    // Save wage
    final wageText = _wageController.text.trim();
    final wage = double.tryParse(wageText) ?? 0.0;
    settings.setHourlyWage(wage);

    // Save AI Key & Provider
    final key = _apiKeyController.text.trim();
    settings.setAiApiKey(key.isEmpty ? null : key);
    settings.setAiProvider(_selectedProvider);

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Settings saved successfully!'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final settings = context.watch<SettingsProvider>();

    return Container(
      padding: EdgeInsets.only(
        top: 24,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2C) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.tune, color: primaryColor, size: 22),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Preferences',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Currency Row
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text('🌍', style: TextStyle(fontSize: 18)),
              ),
              title: const Text('Local Currency', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('Current: ${settings.currencySymbol}', style: TextStyle(color: Colors.grey[400])),
              trailing: OutlinedButton(
                onPressed: () {
                  showCurrencyPicker(
                    context: context,
                    showFlag: true,
                    showCurrencyName: true,
                    showCurrencyCode: true,
                    onSelect: (currency) {
                      settings.setCurrency(currency.symbol);
                    },
                  );
                },
                child: const Text('Change'),
              ),
            ),
            const Divider(height: 24),

            // Hourly Wage / Life Energy
            Text(
              '⚡ Life Energy (Hourly Wage)',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Used to convert price tags into real hours of your work time.',
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _wageController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                prefixText: '${settings.currencySymbol} ',
                suffixText: '/ hour',
                hintText: 'e.g. 25',
                filled: true,
                fillColor: isDark ? const Color(0xFF141420) : const Color(0xFFF0F4F8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const Divider(height: 28),

            // Optional AI Configuration
            Row(
              children: [
                const Text(
                  '✨ AI Reality Check (Optional)',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('Free Tier', style: TextStyle(fontSize: 11, color: Colors.green, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Supports Groq (instant) or Gemini. Without a key, witty offline templates are used.',
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            ),
            const SizedBox(height: 12),

            // Provider Selector
            Row(
              children: [
                ChoiceChip(
                  label: const Text('Groq (Recommended)'),
                  selected: _selectedProvider == 'groq',
                  onSelected: (val) {
                    if (val) setState(() => _selectedProvider = 'groq');
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Gemini'),
                  selected: _selectedProvider == 'gemini',
                  onSelected: (val) {
                    if (val) setState(() => _selectedProvider = 'gemini');
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),

            TextField(
              controller: _apiKeyController,
              obscureText: true,
              decoration: InputDecoration(
                hintText: 'Paste ${_selectedProvider == 'groq' ? 'gsk_...' : 'AIza...'} API Key',
                filled: true,
                fillColor: isDark ? const Color(0xFF141420) : const Color(0xFFF0F4F8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: _apiKeyController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () => setState(() => _apiKeyController.clear()),
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 24),

            // Save Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _saveSettings,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: isDark ? Colors.black : Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: const Text('Save Preferences', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

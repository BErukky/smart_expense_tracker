import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/wish_item.dart';
import '../settings_provider.dart';
import '../utils/cost_calculator.dart';

class ItemDetailSheet extends StatefulWidget {
  final WishItem item;
  final Function(WishItem updatedItem) onUpdate;
  final VoidCallback onDelete;

  const ItemDetailSheet({
    super.key,
    required this.item,
    required this.onUpdate,
    required this.onDelete,
  });

  static Future<void> show(
    BuildContext context, {
    required WishItem item,
    required Function(WishItem updatedItem) onUpdate,
    required VoidCallback onDelete,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ItemDetailSheet(
        item: item,
        onUpdate: onUpdate,
        onDelete: onDelete,
      ),
    );
  }

  @override
  State<ItemDetailSheet> createState() => _ItemDetailSheetState();
}

class _ItemDetailSheetState extends State<ItemDetailSheet> {
  late TextEditingController _titleController;
  late TextEditingController _imageController;
  late String _selectedCategory;
  bool _isEditing = false;

  final List<String> _categories = [
    'Gadgets',
    'Tech',
    'Fashion',
    'Gaming',
    'Dining',
    'Books',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.item.title);
    _imageController = TextEditingController(text: widget.item.imageUrl ?? '');
    _selectedCategory = widget.item.category ?? 'Gadgets';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  void _saveEdits() {
    final updated = widget.item.copyWith(
      title: _titleController.text.trim().isEmpty ? widget.item.title : _titleController.text.trim(),
      imageUrl: _imageController.text.trim().isEmpty ? null : _imageController.text.trim(),
      category: _selectedCategory,
    );
    widget.onUpdate(updated);
    setState(() => _isEditing = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Item updated!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Abandon this item?'),
        content: const Text(
          'This will remove it from your cooling queue. If you want it again later, the cooling timer restarts.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
              widget.onDelete();
            },
            child: const Text('Abandon & Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final secondaryColor = Theme.of(context).colorScheme.secondary;
    final settings = context.watch<SettingsProvider>();

    final workHours = widget.item.workHoursEquivalent ??
        (settings.hasHourlyWage
            ? CostCalculator.calculateWorkHours(widget.item.amount, settings.hourlyWage)
            : null);
    final futureVal = CostCalculator.calculateFutureValue(widget.item.amount, years: 20);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2C) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Header Row: Edit toggle & Delete
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: widget.item.status == WishStatus.passed
                            ? secondaryColor.withValues(alpha: 0.15)
                            : (widget.item.status == WishStatus.bought
                                ? Colors.grey.withValues(alpha: 0.15)
                                : primaryColor.withValues(alpha: 0.15)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        widget.item.status == WishStatus.passed
                            ? '🛡️ PASSED & SAVED'
                            : (widget.item.status == WishStatus.bought
                                ? '🛍️ PURCHASED'
                                : '🔒 COOLING QUEUE'),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: widget.item.status == WishStatus.passed
                              ? secondaryColor
                              : (widget.item.status == WishStatus.bought ? Colors.grey : primaryColor),
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(_isEditing ? Icons.check : Icons.edit_outlined, size: 22),
                      tooltip: _isEditing ? 'Save Changes' : 'Edit Details',
                      onPressed: () {
                        if (_isEditing) {
                          _saveEdits();
                        } else {
                          setState(() => _isEditing = true);
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 22),
                      tooltip: 'Delete Item',
                      onPressed: _confirmDelete,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Hero image preview if available
            if (widget.item.imageUrl != null && widget.item.imageUrl!.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  widget.item.imageUrl!,
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (ctx, err, stack) => const SizedBox.shrink(),
                ),
              ),
            const SizedBox(height: 16),

            // Title (Editable or Text)
            if (_isEditing)
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Item Name',
                  filled: true,
                  fillColor: isDark ? const Color(0xFF141420) : const Color(0xFFF3F6FA),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              )
            else
              Text(
                widget.item.title,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            const SizedBox(height: 8),

            // Price & Protected Notice
            Row(
              children: [
                Text(
                  '${settings.currencySymbol}${widget.item.amount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(width: 10),
                if (_isEditing)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      '🔒 Price is locked during cooling',
                      style: TextStyle(fontSize: 10, color: Colors.amber, fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Life Energy & Opportunity Cost Breakdown
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF141420) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  if (workHours != null && workHours > 0)
                    Row(
                      children: [
                        const Icon(Icons.bolt, color: Colors.amber, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Equals ${CostCalculator.formatWorkHours(workHours)} of your life at work',
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  if (workHours != null && workHours > 0) const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.trending_up, color: Colors.green, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'If invested instead: ${settings.currencySymbol}${futureVal.toStringAsFixed(0)} in 20 yrs',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Editable Category & Image URL
            if (_isEditing) ...[
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                items: _categories.map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedCategory = val);
                },
                decoration: InputDecoration(
                  labelText: 'Category',
                  filled: true,
                  fillColor: isDark ? const Color(0xFF141420) : const Color(0xFFF3F6FA),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _imageController,
                decoration: InputDecoration(
                  labelText: 'Image URL (optional)',
                  filled: true,
                  fillColor: isDark ? const Color(0xFF141420) : const Color(0xFFF3F6FA),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _saveEdits,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: isDark ? Colors.black : Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ] else ...[
              // Timeline details
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Added on',
                    style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                  ),
                  Text(
                    '${widget.item.createdAt.day}/${widget.item.createdAt.month}/${widget.item.createdAt.year} at ${widget.item.createdAt.hour.toString().padLeft(2, '0')}:${widget.item.createdAt.minute.toString().padLeft(2, '0')}',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Cooling Duration',
                    style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                  ),
                  Text(
                    '${widget.item.lockDurationHours} Hours (${(widget.item.lockDurationHours / 24).toStringAsFixed(0)} Days)',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Urgency Level',
                    style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                  ),
                  Text(
                    widget.item.desireLevel.name.toUpperCase(),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: widget.item.desireLevel == DesireLevel.high
                          ? Colors.redAccent
                          : (widget.item.desireLevel == DesireLevel.medium ? Colors.orangeAccent : Colors.greenAccent),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

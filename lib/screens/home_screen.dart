import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/expense.dart';
import '../widgets/expense_tile.dart';
import 'add_expense_screen.dart';

/// Home screen showing list of expenses with add and delete functionality
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Expense> _expenses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  /// Load expenses from shared preferences
  Future<void> _loadExpenses() async {
    final prefs = await SharedPreferences.getInstance();
    final expensesJson = prefs.getStringList('expenses') ?? [];
    
    setState(() {
      _expenses = expensesJson
          .map((json) => Expense.fromMap(jsonDecode(json)))
          .toList();
      _isLoading = false;
    });
  }

  /// Save expenses to shared preferences
  Future<void> _saveExpenses() async {
    final prefs = await SharedPreferences.getInstance();
    final expensesJson = _expenses
        .map((expense) => jsonEncode(expense.toMap()))
        .toList();
    await prefs.setStringList('expenses', expensesJson);
  }

  /// Add new expense
  void _addExpense() async {
    final expense = await Navigator.of(context).push<Expense>(
      MaterialPageRoute(
        builder: (context) => const AddExpenseScreen(),
      ),
    );

    if (expense != null) {
      setState(() {
        _expenses.add(expense);
      });
      await _saveExpenses();
    }
  }

  /// Delete expense
  void _deleteExpense(int index) async {
    setState(() {
      _expenses.removeAt(index);
    });
    await _saveExpenses();
  }

  /// Calculate total expenses
  double get _totalAmount {
    return _expenses.fold(0.0, (sum, expense) => sum + expense.amount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Expense Tracker'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Total amount card
                if (_expenses.isNotEmpty)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Total Expenses',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '\$${_totalAmount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ),
                // Expenses list
                Expanded(
                  child: _expenses.isEmpty
                      ? const Center(
                          child: Text(
                            'No expenses yet!\nTap + to add your first expense',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _expenses.length,
                          itemBuilder: (context, index) {
                            return ExpenseTile(
                              expense: _expenses[index],
                              onDelete: () => _deleteExpense(index),
                            );
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addExpense,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}
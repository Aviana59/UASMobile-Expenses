import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pengeluaran_harian/components/chart.dart';

import 'package:pengeluaran_harian/login/login_screen.dart';
import 'package:pengeluaran_harian/login/register_screen.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Menghilangkan banner debug
      title: 'My Expenses',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/expenses': (context) => const ExpenseListScreen(),
      },
    );
  }
}

class Expense {
  final int id;
  final String title;
  final double amount;

  Expense({required this.id, required this.title, required this.amount});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
    };
  }
}

class ExpenseListScreen extends StatefulWidget {
  const ExpenseListScreen({super.key});

  @override
  _ExpenseListScreenState createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends State<ExpenseListScreen> {
  late Database _database;
  List<Expense> _expenses = [];
  List<Map<String, dynamic>> _expensesData = [];

  @override
  void initState() {
    super.initState();
    _initDatabase();
  }

  Future<void> _initDatabase() async {
    _database = await openDatabase(
      join(await getDatabasesPath(), 'expenses_database.db'),
      onCreate: (db, version) {
        return db.execute(
          "CREATE TABLE expenses(id INTEGER PRIMARY KEY, title TEXT, amount REAL)",
        );
      },
      version: 1,
    );
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    final List<Map<String, dynamic>> maps = await _database.query('expenses');
    setState(() {
      _expenses = List.generate(maps.length, (i) {
        return Expense(
          id: maps[i]['id'],
          title: maps[i]['title'],
          amount: maps[i]['amount'],
        );
      });
      _expensesData = maps;
    });
  }

  Future<void> _addExpense(String title, double amount) async {
    Random random = Random();
    int randomNumber = random.nextInt(100);
    final newExpense = Expense(
      id: randomNumber,
      title: title,
      amount: amount,
    );
    await _database.insert(
      'expenses',
      newExpense.toMap(),
    );
    _loadExpenses();
  }

  Future<void> _editExpense(int id, String title, double amount) async {
    final updatedExpense = Expense(
      id: id,
      title: title,
      amount: amount,
    );
    await _database.update(
      'expenses',
      updatedExpense.toMap(),
      where: "id = ?",
      whereArgs: [id],
    );
    _loadExpenses();
  }

  Future<void> _removeExpense(int id) async {
    await _database.delete(
      'expenses',
      where: "id = ?",
      whereArgs: [id],
    );
    _loadExpenses();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('images/pengeluaran.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Semi-transparent overlay
          Container(
            color: Colors.black.withOpacity(0.6),
          ),
          Column(
            children: [
              AppBar(
                title: const Text('Pengeluaran Harian'),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.logout),
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/');
                    },
                  ),
                ],
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _expenses.length,
                  itemBuilder: (ctx, index) {
                    final expense = _expenses[index];
                    return Card(
                      color: Colors.white.withOpacity(0.9),
                      margin: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 16.0),
                      child: ListTile(
                        title: Text(expense.title),
                        subtitle: Text(
                          'Rp ${expense.amount.toString()}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () =>
                                  _showEditExpenseDialog(context, expense),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => _removeExpense(expense.id),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              _buildTotalExpense(),
              BarChartSample3(
                data: _expensesData,
              )
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddExpenseDialog(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTotalExpense() {
    double totalExpense =
        _expenses.fold(0, (prev, expense) => prev + expense.amount);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        'Total Pengeluaran: ${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp').format(totalExpense)}',
        style: const TextStyle(
            fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    );
  }

  Future<void> _showAddExpenseDialog(BuildContext context) async {
    TextEditingController titleController = TextEditingController();
    TextEditingController amountController = TextEditingController();

    return showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Expense'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: amountController,
              decoration: const InputDecoration(labelText: 'Amount'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final title = titleController.text;
              final amount = double.parse(amountController.text);
              _addExpense(title, amount);
              Navigator.of(ctx).pop();
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _showEditExpenseDialog(
      BuildContext context, Expense expense) async {
    TextEditingController titleController =
        TextEditingController(text: expense.title);
    TextEditingController amountController =
        TextEditingController(text: expense.amount.toString());

    return showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Expense'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: amountController,
              decoration: const InputDecoration(labelText: 'Amount'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final title = titleController.text;
              final amount = double.parse(amountController.text);
              _editExpense(expense.id, title, amount);
              Navigator.of(ctx).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

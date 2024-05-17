import 'package:flutter/material.dart';
import 'package:pengeluaran_harian/login/register_screen.dart';
import 'package:pengeluaran_harian/main.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  Future<Database> getDatabase() async {
    String path = join(await getDatabasesPath(), 'pengeluaran_harian.db');
    return openDatabase(
      path,
      onCreate: (db, version) {
        return db.execute(
          "CREATE TABLE users(id INTEGER PRIMARY KEY, email TEXT, password TEXT)",
        );
      },
      version: 1,
    );
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController emailController = TextEditingController();
    TextEditingController passwordController = TextEditingController();

    Future<bool> login(String email, String password) async {
      final Database db = await getDatabase();
      List<Map<String, dynamic>> users = await db.query(
        'users',
        where: 'email = ? AND password = ?',
        whereArgs: [email, password],
      );
      return users.isNotEmpty;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Mbuh Pusing Aku!!',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20.0),
            TextField(
              controller: emailController, // Tambahkan controller
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                hintText: 'Masukkan Email Anda',
              ),
            ),
            const SizedBox(height: 10.0),
            TextField(
              controller: passwordController, // Tambahkan controller
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                hintText: 'Masukkan Password Anda',
              ),
            ),
            const SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () async {
                String email =
                    emailController.text; // Ambil nilai dari controller
                String password =
                    passwordController.text; // Ambil nilai dari controller
                bool loggedIn = await login(email, password);
                if (loggedIn) {
                  Navigator.pushReplacement(
                    // ignore: use_build_context_synchronously
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ExpenseListScreen()),
                  );
                } else {
                  // Show dialog if account does not exist
                  showDialog(
                    // ignore: use_build_context_synchronously
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Akun belum terdaftar!'),
                        content: const Text('Buat akun baru?'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('Back'),
                          ),
                          TextButton(
                            onPressed: () {
                              // Navigate to registration screen if user chooses to create account
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const RegisterScreen()),
                              );
                            },
                            child: const Text('Create Account'),
                          ),
                        ],
                      );
                    },
                  );
                }
              },
              child: const Text('Login'),
            ),
            const SizedBox(height: 10.0),
            TextButton(
              onPressed: () {
                // Navigate to registration screen
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const RegisterScreen()),
                );
              },
              child: const Text('Sign Up'),
            ),
          ],
        ),
      ),
    );
  }
}

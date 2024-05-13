import 'package:flutter/material.dart';
import 'package:pengeluaran_harian/login/login_screen.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    TextEditingController emailController = TextEditingController();
    TextEditingController passwordController = TextEditingController();
    TextEditingController confirmPasswordController = TextEditingController();

    Future<Database> getDatabase() async {
      // Get a location using `getDatabasesPath()`
      String path = join(await getDatabasesPath(), 'pengeluaran_harian.db');

      // Open the database
      return openDatabase(
        path,
        onCreate: (db, version) {
          // Run the CREATE TABLE statement on the database.
          return db.execute(
            "CREATE TABLE users(id INTEGER PRIMARY KEY, email TEXT, password TEXT)",
          );
        },
        version: 1,
      );
    }

    void registerAccount(String email, String password) async {
      final Database db = await getDatabase();
      await db.insert(
        'users',
        {'email': email, 'password': password},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    void showAlertDialog(BuildContext context, String message) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Registration Result'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () {
                  // Navigate to login screen after account creation
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                  );
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Create an Account',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20.0),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                hintText: 'Masukkan Email Anda',
              ),
            ),
            const SizedBox(height: 10.0),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                hintText: 'Masukkan Password Anda',
              ),
            ),
            const SizedBox(height: 10.0),
            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Konfirmasi Password',
                hintText: 'Konfirmasi Password Anda',
              ),
            ),
            const SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                String email = emailController.text;
                String password = passwordController.text;
                String confirmPassword = confirmPasswordController.text;

                if (password == confirmPassword) {
                  // Jika password dan konfirmasi password sama, lakukan pendaftaran
                  registerAccount(email, password);
                  showAlertDialog(context,
                      'Akun Anda telah berhasil dibuat! silahkan login.');
                } else {
                  // Jika password dan konfirmasi password tidak sama, tampilkan pesan kesalahan
                  showAlertDialog(
                      context, 'Password and confirm password do not match.');
                }
              },
              child: const Text('Create Account'),
            ),
          ],
        ),
      ),
    );
  }
}

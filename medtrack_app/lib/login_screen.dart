import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'features/auth/state/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: "Email")),
            TextField(controller: passCtrl, decoration: const InputDecoration(labelText: "Contraseña"), obscureText: true),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                try {
                  await context.read<AuthProvider>().login(emailCtrl.text.trim(), passCtrl.text.trim());
                  if (mounted) Navigator.pushReplacementNamed(context, "/meds");
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
                }
              },
              child: const Text("Iniciar sesión"),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, "/register"),
              child: const Text("¿No tienes cuenta? Regístrate"),
            ),
          ],
        ),
      ),
    );
  }
}

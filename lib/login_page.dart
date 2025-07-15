import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'signup_page.dart';
import 'visitor_page.dart'; // Added import for VisitorPage

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final supabase = Supabase.instance.client;

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  bool validarCampos() {
    final campos = {
      'Correo': emailController.text.trim(),
      'Contraseña': passwordController.text.trim(),
    };

    for (final entry in campos.entries) {
      if (entry.value.isEmpty) {
        _showSnackBar('Todos los campos son obligatorios.');
        return false;
      }
    }

    return true;
  }

  Future<void> login() async {
    if (!validarCampos()) return;

    try {
      final response = await supabase.auth.signInWithPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (response.user != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Inicio de sesión exitoso')),
          );
          // Cierra la pantalla de login para que AuthGate reconstruya
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const VisitorPage()));
        }
      } else {
        _showSnackBar('Credenciales inválidas.');
      }
    } catch (e) {
      _showSnackBar('Error al iniciar sesión: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.meeting_room, color: Colors.white, size: 28),
            const SizedBox(width: 10),
            const Text('Visitas Oficina', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
      body: Stack(
        children: [
          // Fondo gradiente y formas
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF4F8FFF), Color(0xFFB6E0FE)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Positioned(
            top: -60,
            left: -60,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              child: Card(
                color: Colors.white.withOpacity(0.92),
                elevation: 10,
                margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Icon(Icons.verified_user, size: 64, color: Color(0xFF4F8FFF)),
                      const SizedBox(height: 18),
                      const Text(
                        'Bienvenido',
                        style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF4F8FFF)),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Inicia sesión para registrar y consultar visitas a la oficina.',
                        style: TextStyle(fontSize: 15, color: Colors.blueGrey.shade700),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 28),
                      const Text(
                        'Correo electrónico',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF4F8FFF)),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: emailController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                          hintText: 'ejemplo@correo.com',
                          prefixIcon: const Icon(Icons.email, color: Color(0xFF4F8FFF)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Contraseña',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF4F8FFF)),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: passwordController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                          hintText: '******',
                          prefixIcon: const Icon(Icons.lock, color: Color(0xFF4F8FFF)),
                        ),
                        obscureText: true,
                      ),
                      const SizedBox(height: 28),
                      ElevatedButton.icon(
                        onPressed: login,
                        icon: const Icon(Icons.login, color: Colors.white),
                        label: const Text('Iniciar sesión', style: TextStyle(fontSize: 16)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4F8FFF),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 6,
                        ),
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const SignUpPage()),
                          );
                        },
                        icon: const Icon(Icons.person_add, color: Color(0xFF4F8FFF)),
                        label: const Text('Registrarse', style: TextStyle(fontSize: 16, color: Color(0xFF4F8FFF))),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: const BorderSide(color: Color(0xFF4F8FFF)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
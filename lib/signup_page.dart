import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_page.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();
  final supabase = Supabase.instance.client;
  // final List<String> roles = ['visitante', 'publicador']; // Eliminado

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  bool validarCampos() {
    final campos = {
      'Correo': emailController.text.trim(),
      'Contraseña': passwordController.text.trim(),
      // 'Rol': selectedRole, // Eliminado
      'Nombre': nameController.text.trim(),
    };

    for (final entry in campos.entries) {
      if (entry.value == null || entry.value?.isEmpty == true) {
        _showSnackBar('Todos los campos son obligatorios.');
        return false;
      }
    }

    return true;
  }

  Future<void> signup() async {
    if (!validarCampos()) return;

    try {
      final response = await supabase.auth.signUp(
        email: emailController.text,
        password: passwordController.text,
        data: {
          'name': nameController.text,
          // 'role': selectedRole, // Eliminado
        },
      );

      final user = response.user;

      if (user != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Revisa tu correo para confirmar tu cuenta.'),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al registrarse: $e')),
        );
      }
    }
  }

  Widget _buildRoleInfoCard(String role, String description, IconData icon) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, size: 32, color: Colors.blue),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    role[0].toUpperCase() + role.substring(1),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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
                      const Icon(Icons.person_add_alt_1, size: 64, color: Color(0xFF4F8FFF)),
                      const SizedBox(height: 18),
                      const Text(
                        'Crear cuenta',
                        style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF4F8FFF)),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Regístrate para poder registrar y consultar visitas a la oficina.',
                        style: TextStyle(fontSize: 15, color: Colors.blueGrey),
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
                      const SizedBox(height: 16),
                      const Text(
                        'Nombre',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF4F8FFF)),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                          hintText: 'Nombre',
                          prefixIcon: const Icon(Icons.person_outline, color: Color(0xFF4F8FFF)),
                        ),
                      ),
                      const SizedBox(height: 28),
                      ElevatedButton.icon(
                        onPressed: signup,
                        icon: const Icon(Icons.person_add, color: Colors.white),
                        label: const Text('Registrarse', style: TextStyle(fontSize: 16)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4F8FFF),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 6,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        '¿Ya tienes una cuenta?',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Color(0xFF4F8FFF)),
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const LoginPage()),
                          );
                        },
                        icon: const Icon(Icons.login, color: Color(0xFF4F8FFF)),
                        label: const Text('Iniciar Sesión', style: TextStyle(fontSize: 16, color: Color(0xFF4F8FFF))),
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
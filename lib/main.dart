import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'login_page.dart';
import 'visitor_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Supabase
  await Supabase.initialize(
    url: 'https://kldhwzmvasgzlbbaxicl.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtsZGh3em12YXNnemxiYmF4aWNsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTI2MDY2NTYsImV4cCI6MjA2ODE4MjY1Nn0.RGUgnqrltINpoEKr6EfZ8Ry7DRwufZanjpPxyGc5hKo',
  );

   // Inicializar Firebase
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyCLpbCvlKemjhpyYW549tmUMsAAKMUAQC4",
      authDomain: "movil25a.firebaseapp.com",
      projectId: "movil25a",
      storageBucket: "movil25a.firebasestorage.app",
      messagingSenderId: "544548734677",
      appId: "1:544548734677:web:310817784be0aca801c45c",
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Registro de Visitas',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        useMaterial3: true,
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: Colors.indigo.shade50,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white,
          elevation: 2,
          centerTitle: true,
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        cardTheme: CardThemeData(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
          elevation: 6,
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(fontSize: 16),
        ),
      ),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        final session = Supabase.instance.client.auth.currentSession;

        if (session != null) {
          // Usuario autenticado, ir directo a VisitorPage
          return const VisitorPage();
        } else {
          return const LoginPage();
        }
      },
    );
  }
}
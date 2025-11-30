import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:viva_mais/view/inicial.dart';
import 'package:viva_mais/view/cadastro.dart';
import 'package:viva_mais/view/login.dart';
import 'package:viva_mais/view/principal.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (_) => const Inicio(),
        '/cadastrar': (_) => const Cadastro(),
        '/login': (_) => const Login(),
        '/principal': (_) => const Principal(),
      },
    );
  }
}

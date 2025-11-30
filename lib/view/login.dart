import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final email = TextEditingController();
  final senha = TextEditingController();
  bool carregando = false;

  Future<void> logar() async {
    if (email.text.trim().isEmpty || senha.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Preencha todos os campos!")),
      );
      return;
    }

    try {
      setState(() => carregando = true);

      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.text.trim(),
        password: senha.text.trim(),
      );

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/principal');
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.message ?? "Erro desconhecido",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      );
    } finally {
      setState(() => carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 94, 145, 116),
      appBar: AppBar(
        title: const Text("Login"),
        backgroundColor: const Color.fromARGB(255, 94, 145, 116),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white70,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.lock_open_rounded,
                size: 80,
                color: Color.fromARGB(255, 94, 145, 116),
              ),
            ),
            const SizedBox(height: 25),
            const Text(
              "Bem-vindo de volta!",
              style: TextStyle(
                color: Colors.white70,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 35),
            campo(
              label: "Email",
              controller: email,
              icon: Icons.email_outlined,
            ),
            const SizedBox(height: 18),
            campo(
              label: "Senha",
              controller: senha,
              icon: Icons.lock_outline,
              senha: true,
            ),
            const SizedBox(height: 35),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: carregando ? null : logar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 101, 178, 111),
                  foregroundColor: const Color.fromARGB(255, 214, 216, 208),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 5,
                ),
                child: carregando
                    ? const CircularProgressIndicator(color: Colors.black)
                    : const Text(
                        "Entrar",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 15),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/cadastrar');
              },
              child: const Text(
                "Não tem conta? Cadastre-se",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            const SizedBox(height: 15),
          ],
        ),
      ),
    );
  }

  Widget campo({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool senha = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: senha,
      style: const TextStyle(fontSize: 17),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color.fromARGB(255, 94, 145, 116)),
        filled: true,
        fillColor: Colors.white,
        labelStyle: const TextStyle(color: Colors.black87),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF6EC085), width: 2),
        ),
      ),
    );
  }
}

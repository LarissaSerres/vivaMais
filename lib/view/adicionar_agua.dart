import 'package:flutter/material.dart';
import '../service/firestore.dart';
import 'package:flutter/services.dart';

class AdicionarAgua extends StatefulWidget {
  const AdicionarAgua({super.key});

  @override
  State<AdicionarAgua> createState() => AdicionarAguaState();
}

class AdicionarAguaState extends State<AdicionarAgua> {
  final formKey = GlobalKey<FormState>();
  final quantidade = TextEditingController();
  bool carregando = false;

  @override
  void dispose() {
    quantidade.dispose();
    super.dispose();
  }

  Future<void> salvar() async {
    if (!formKey.currentState!.validate()) return;

    final quantidadeValor = int.parse(quantidade.text.trim());

    setState(() => carregando = true);

    try {
      await salvarAgua(quantidade: quantidadeValor);
      void onButtonTapped(BuildContext context) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Água registrada com sucesso!")),
        );
      }

      onButtonTapped(context);

      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao registrar água: $e")),
      );
    } finally {
      if (mounted) setState(() => carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FBF7),
      appBar: AppBar(
        title: const Text("Adicionar Água"),
        backgroundColor: const Color(0xFF6EC085),
        elevation: 1,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Form(
            key: formKey,
            child: Column(
              children: [
                const Icon(
                  Icons.water_drop_rounded,
                  color: Colors.blueAccent,
                  size: 90,
                ),
                const SizedBox(height: 16),
                const Text(
                  "Registrar ingestão de água",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 28),
                TextFormField(
                  controller: quantidade,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  decoration: InputDecoration(
                    labelText: "Quantidade (ml)",
                    hintText: "Ex: 250",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return "Digite a quantidade em ml";
                    }
                    final n = int.tryParse(v.trim());
                    if (n == null || n <= 0) {
                      return "Digite um número válido maior que 0";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: carregando ? null : salvar,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF9E04B),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    child: carregando
                        ? const SizedBox(
                            width: 26,
                            height: 26,
                            child: CircularProgressIndicator(
                              color: Colors.black,
                              strokeWidth: 2.2,
                            ),
                          )
                        : const Text("Adicionar"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

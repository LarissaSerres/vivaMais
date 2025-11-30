import 'package:flutter/material.dart';
import '../service/firestore.dart';

class EditarAgua extends StatefulWidget {
  final String id;
  final int quantidade;

  const EditarAgua({
    super.key,
    required this.id,
    required this.quantidade,
  });

  @override
  State<EditarAgua> createState() => _EditarAguaState();
}

class _EditarAguaState extends State<EditarAgua> {
  final quantidade = TextEditingController();
  bool carregando = false;

  @override
  void initState() {
    super.initState();
    quantidade.text = widget.quantidade.toString();
  }

  Future<void> salvar() async {
    final qtd = int.tryParse(quantidade.text.trim());
    if (qtd == null || qtd <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Digite uma quantidade válida.")),
      );
      return;
    }

    setState(() => carregando = true);

    await editarAgua(id: widget.id, quantidade: qtd);

    if (mounted) Navigator.pop(context, true);
  }

  Future<void> deletar() async {
    await excluirAgua(widget.id);
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF6EC085),
        titleTextStyle: const TextStyle(
            fontWeight: FontWeight.bold, fontSize: 20, color: Colors.black),
        title: const Text("Editar Água"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: quantidade,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Quantidade (ml)",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: carregando ? null : salvar,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6EC085),
                foregroundColor: Colors.black,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text("Salvar"),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: deletar,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 177, 45, 36),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text("Excluir"),
            ),
          ],
        ),
      ),
    );
  }
}

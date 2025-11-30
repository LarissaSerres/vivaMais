import 'package:flutter/material.dart';
import '../service/firestore.dart';

class EditarAtividade extends StatefulWidget {
  final String id;
  final String tipo;
  final int duracao;

  const EditarAtividade({
    super.key,
    required this.id,
    required this.tipo,
    required this.duracao,
  });

  @override
  State<EditarAtividade> createState() => _EditarAtividadeState();
}

class _EditarAtividadeState extends State<EditarAtividade> {
  final duracao = TextEditingController();
  String? tipoSelecionado;

  final atividades = [
    "Dança",
    "Pilates",
    "Natação",
    "Padel",
    "Tênis",
    "Vôlei",
    "Caminhada",
    "Corrida",
    "Musculação",
    "Yoga",
  ];

  @override
  void initState() {
    super.initState();
    tipoSelecionado = widget.tipo;
    duracao.text = widget.duracao.toString();
  }

  Future<void> salvar() async {
    final dur = int.tryParse(duracao.text.trim());
    if (tipoSelecionado == null || dur == null || dur <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Preencha corretamente.")),
      );
      return;
    }

    await editarAtividade(
      id: widget.id,
      tipo: tipoSelecionado!,
      duracao: dur,
    );

    if (mounted) Navigator.pop(context, true);
  }

  Future<void> deletar() async {
    await excluirAtividade(widget.id);
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF6EC085),
        titleTextStyle: const TextStyle(
            fontWeight: FontWeight.bold, fontSize: 20, color: Colors.black),
        title: const Text("Editar Atividade"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              initialValue: tipoSelecionado,
              items: atividades
                  .map((a) => DropdownMenuItem(
                        value: a,
                        child: Text(a),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => tipoSelecionado = v),
              decoration: const InputDecoration(labelText: "Tipo"),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: duracao,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Duração (min)",
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: salvar,
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

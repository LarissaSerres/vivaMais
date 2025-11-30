import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../service/firestore.dart';

class AdicionarAtividade extends StatefulWidget {
  const AdicionarAtividade({super.key});

  @override
  State<AdicionarAtividade> createState() => _AdicionarAtividadeState();
}

class _AdicionarAtividadeState extends State<AdicionarAtividade> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController duracao = TextEditingController();

  String? tipoSelecionado;
  bool carregando = false;

  final List<String> atividades = [
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
  void dispose() {
    duracao.dispose();
    super.dispose();
  }

  Future<void> salvar() async {
    if (!formKey.currentState!.validate()) return;

    final duracaoTempo = int.tryParse(duracao.text.trim()) ?? 0;
    if (tipoSelecionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Selecione um tipo de atividade")),
      );
      return;
    }

    setState(() => carregando = true);

    try {
      await salvarAtividade(
        tipo: tipoSelecionado!,
        duracao: duracaoTempo,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Atividade registrada com sucesso!")),
      );

      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao salvar atividade: $e")),
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
        title: const Text("Adicionar Atividade"),
        backgroundColor: const Color(0xFF6EC085),
        elevation: 1,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Form(
            key: formKey,
            child: Column(
              children: [
                const Icon(Icons.fitness_center,
                    size: 84, color: Colors.orange),
                const SizedBox(height: 18),
                const Text(
                  "Registrar atividade física",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: "Tipo de atividade",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  initialValue: tipoSelecionado,
                  items: atividades
                      .map((a) => DropdownMenuItem(value: a, child: Text(a)))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      tipoSelecionado = value;
                    });
                  },
                  validator: (v) {
                    if (v == null || v.isEmpty) {
                      return "Selecione uma atividade";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: duracao,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    labelText: "Duração (minutos)",
                    hintText: "Ex: 30",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return "Digite a duração em minutos";
                    }
                    final n = int.tryParse(v.trim());
                    if (n == null || n <= 0) {
                      return "Digite um número válido maior que 0";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: carregando ? null : salvar,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 94, 145, 116),
                      foregroundColor: Colors.white70,
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
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                                color: Colors.black, strokeWidth: 2.2),
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

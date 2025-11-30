import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../service/firestore.dart';
import '../service/clima_service.dart';
import 'adicionar_agua.dart';
import 'atividades.dart';
import 'editar_agua.dart';
import 'editar_atividade.dart';

class Principal extends StatefulWidget {
  const Principal({super.key});

  @override
  PrincipalState createState() => PrincipalState();
}

class PrincipalState extends State<Principal> {
  String fraseDoDia = "";
  bool refreshing = false;

  @override
  void initState() {
    super.initState();
    carregarFraseDoDia();
  }

  Future<void> carregarFraseDoDia() async {
    try {
      final jsonString = await rootBundle.loadString('assets/frases.json');
      final List listaFrases = json.decode(jsonString);

      final prefs = await SharedPreferences.getInstance();
      int ultimoIndex = prefs.getInt('ultimoIndex') ?? -1;

      int proximoIndex = (ultimoIndex + 1) % listaFrases.length;
      await prefs.setInt('ultimoIndex', proximoIndex);

      setState(() {
        fraseDoDia = listaFrases[proximoIndex]["texto"] ?? "";
      });
    } catch (_) {
      fraseDoDia = "";
    }
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/');
  }

  Future<void> onRefresh() async {
    setState(() => refreshing = true);
    await carregarFraseDoDia();
    await Future.delayed(const Duration(milliseconds: 400));
    setState(() => refreshing = false);
  }

  String formatTimestamp(dynamic ts) {
    try {
      DateTime dt;

      if (ts is Timestamp) {
        dt = ts.toDate().toLocal();
      } else if (ts is DateTime) {
        dt = ts.toLocal();
      } else {
        return ts.toString();
      }

      return "${dt.day.toString().padLeft(2, '0')}/"
          "${dt.month.toString().padLeft(2, '0')}/"
          "${dt.year}  "
          "${dt.hour.toString().padLeft(2, '0')}:"
          "${dt.minute.toString().padLeft(2, '0')}";
    } catch (_) {
      return ts.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF6EC085);
    const bg = Color(0xFFF1F7F2);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: green,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Viva+",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        actions: [
          IconButton(
            onPressed: logout,
            icon: const Icon(Icons.logout),
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: onRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                "Seu resumo de hoje",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 20),
              FutureBuilder<Map<String, dynamic>>(
                future: ClimaService.buscarClimaAtual(),
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return loadingCard();
                  }

                  if (!snap.hasData) {
                    return sectionCard(
                      child: Row(
                        children: const [
                          Icon(Icons.cloud_off, size: 40),
                          SizedBox(width: 10),
                          Text("Erro ao carregar clima"),
                        ],
                      ),
                    );
                  }

                  final clima = snap.data!;
                  return sectionCard(
                    child: Row(
                      children: [
                        Image.network(
                          "https://openweathermap.org/img/wn/${clima['icone']}@2x.png",
                          width: 70,
                          height: 70,
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(clima["cidade"],
                                style: const TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold)),
                            Text("${clima["temperatura"]}°C"),
                          ],
                        )
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 25),
              secaoCabecalho("Consumo de água", () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AdicionarAgua()),
                );
              }),
              StreamBuilder<QuerySnapshot>(
                stream: listarAgua(),
                builder: (context, snap) {
                  if (!snap.hasData) return loadingCard();
                  if (snap.data!.docs.isEmpty) {
                    return textoVazio("Nenhum consumo registrado.");
                  }

                  return Column(
                    children: snap.data!.docs.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;

                      return sectionCard(
                        child: Row(
                          children: [
                            iconBox(Icons.water_drop, Colors.blue),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                "${data['quantidade']} ml",
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.green),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => EditarAgua(
                                      id: doc.id,
                                      quantidade: data['quantidade'],
                                    ),
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => excluirAgua(doc.id),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
              const SizedBox(height: 25),
              secaoCabecalho("Atividades", () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AdicionarAtividade()),
                );
              }),
              StreamBuilder<QuerySnapshot>(
                stream: listarAtividades(),
                builder: (context, snap) {
                  if (!snap.hasData) return loadingCard();
                  if (snap.data!.docs.isEmpty) {
                    return textoVazio("Nenhuma atividade registrada.");
                  }

                  return Column(
                    children: snap.data!.docs.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;

                      return sectionCard(
                        child: Row(
                          children: [
                            iconBox(Icons.fitness_center, Colors.orange),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                "${data['tipo']} • ${data['duracao']} min",
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.green),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => EditarAtividade(
                                      id: doc.id,
                                      tipo: data['tipo'],
                                      duracao: data['duracao'],
                                    ),
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => excluirAtividade(doc.id),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
              const SizedBox(height: 30),
              if (fraseDoDia.isNotEmpty)
                sectionCard(
                  child: Column(
                    children: [
                      const Icon(Icons.format_quote,
                          size: 40, color: Colors.black26),
                      const SizedBox(height: 6),
                      Text(
                        fraseDoDia,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 17, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget iconBox(IconData icon, Color cor) {
  return Container(
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12),
    ),
    child: Icon(icon, color: cor, size: 28),
  );
}

Widget loadingCard() {
  return const Center(
    child: Padding(
      padding: EdgeInsets.all(20),
      child: CircularProgressIndicator(),
    ),
  );
}

Widget sectionCard({required Widget child}) {
  return Card(
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: child,
    ),
  );
}

Widget textoVazio(String txt) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 12),
    child: Text(
      txt,
      style: const TextStyle(fontSize: 15, color: Colors.black54),
    ),
  );
}

Widget secaoCabecalho(String titulo, VoidCallback onAdd) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        titulo,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
      ElevatedButton.icon(
        onPressed: onAdd,
        icon: const Icon(Icons.add),
        label: const Text("Adicionar"),
      ),
    ],
  );
}

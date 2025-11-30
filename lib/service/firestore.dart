import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

String get userId {
  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    return user.uid;
  } else {
    throw Exception('Nenhum usuário logado.');
  }
}

Future<void> salvarAgua({
  required int quantidade,
}) async {
  await FirebaseFirestore.instance
      .collection('usuarios')
      .doc(userId)
      .collection('agua')
      .add({
    'quantidade': quantidade,
    'data': Timestamp.now(),
  });
}

Future<void> editarAgua({
  required String id,
  required int quantidade,
}) async {
  await FirebaseFirestore.instance
      .collection('usuarios')
      .doc(userId)
      .collection('agua')
      .doc(id)
      .update({
    'quantidade': quantidade,
  });
}

Future<void> excluirAgua(String id) async {
  await FirebaseFirestore.instance
      .collection('usuarios')
      .doc(userId)
      .collection('agua')
      .doc(id)
      .delete();
}

Stream<QuerySnapshot> listarAgua() {
  return FirebaseFirestore.instance
      .collection('usuarios')
      .doc(userId)
      .collection('agua')
      .orderBy('data', descending: true)
      .snapshots();
}

Future<void> salvarAtividade({
  required String tipo,
  required int duracao,
}) async {
  await FirebaseFirestore.instance
      .collection('usuarios')
      .doc(userId)
      .collection('atividades')
      .add({
    'tipo': tipo,
    'duracao': duracao,
    'data': Timestamp.now(),
  });
}

Future<void> editarAtividade({
  required String id,
  required String tipo,
  required int duracao,
}) async {
  await FirebaseFirestore.instance
      .collection('usuarios')
      .doc(userId)
      .collection('atividades')
      .doc(id)
      .update({
    'tipo': tipo,
    'duracao': duracao,
  });
}

Future<void> excluirAtividade(String id) async {
  await FirebaseFirestore.instance
      .collection('usuarios')
      .doc(userId)
      .collection('atividades')
      .doc(id)
      .delete();
}

Stream<QuerySnapshot> listarAtividades() {
  return FirebaseFirestore.instance
      .collection('usuarios')
      .doc(userId)
      .collection('atividades')
      .orderBy('data', descending: true)
      .snapshots();
}

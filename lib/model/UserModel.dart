import 'package:firebase_database/firebase_database.dart';

import './NotificationModel.dart';
class UserModel {
  final String nome, email;
  final String? localiz, pos;
  final bool possuiJogoCriado;
  final List<NotificationModel>? notificacoes;

  UserModel({
    required this.nome,
    required this.email,
    required this.localiz,
    required this.pos,
    required this.possuiJogoCriado,
    this.notificacoes,
  });

  factory UserModel.fromSnapshot(DataSnapshot snapshot) {
    final data = snapshot.value as Map<dynamic, dynamic>;
    return UserModel(
      nome: data['nome'],
      email: data['email'],
      localiz: data['localiz'] ?? '',
      pos: data['pos'] ?? '',
      possuiJogoCriado: data['possuiJogoCriado'],
      notificacoes: (data['received'] != null)
          ? List<NotificationModel>.from(
          (data['received'] as Map<dynamic, dynamic>).values
              .map((value) => NotificationModel.fromMap(value)))
          : null,
    );
  }
}
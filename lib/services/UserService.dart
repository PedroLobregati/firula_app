import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../model/UserModel.dart';
import '../view/home.page.dart';

class UserService{
  final _firebaseAuth = FirebaseAuth.instance;
  final database = FirebaseDatabase.instance.ref();
  User? user = FirebaseAuth.instance.currentUser;

  void cadastrar(String email, String senha, String confirmarSenha, String nome, context) async {
    UserCredential userCredential = await _firebaseAuth
        .createUserWithEmailAndPassword(
      email: email, password: senha,);
    if (userCredential != null) {
      userCredential.user!.updateDisplayName(nome);
      final profileData = database.child(
          'FirulaData/users/${userCredential.user!.uid}');

      await profileData.set({
        'nome': nome,
        'email': email,
        'localiz': '',
        'pos': '',
        'possuiJogoCriado': false
      });
    }
  }

  void publicar(String local, String data, int numeroDeJogadores, String hora, context) async {
      String host = user?.displayName ?? 'Anonymous';
      final profileData = database.child('FirulaData/matches/').push();
      await profileData.set(
          {'local': local,
            'data': data,
            'time': hora,
            'nPlayers': numeroDeJogadores,
            'host': host,
            'id': profileData.key,
            'hostId': user!.uid,
            'onList': 1,
          });
      final matchData = database.child(
          'FirulaData/matches/${profileData.key}/participants').push();
      await matchData.set(
          {'userId': user!.uid, 'username': user!.displayName});
      database.child('FirulaData/users/${user!.uid}').update({
        'possuiJogoCriado' : true,
      });
    }

  Future<UserCredential?> login(String email, String senha, context) async {
      UserCredential userCredential = await _firebaseAuth
          .signInWithEmailAndPassword(
          email: email, password: senha);

      return userCredential;
  }

  void sendToHost(String matchId, String displayLocal, String displayData) async {

    final profileData = database.child('FirulaData/users/${user!.uid}/solicitParticip/$matchId');
    await profileData.set({
      'matchLocal' : displayLocal,
      'matchData'  : displayData,
      'situation' : 'Aguardando resposta...',
    });

    database
        .child('FirulaData/matches/$matchId/hostId')
        .onValue
        .listen((event) async {
      final userName = user!.displayName;
      final getHostId = event.snapshot.value as String;
      print(getHostId);
      final notData = database.child(
          'FirulaData/users/$getHostId/received').push();
      await notData.set(
          {'content': "Solicitação de participação de $userName",
            'senderId': '${user!.uid}',
            'forMatchId': '${matchId}',
            'username': '$userName',
            'notId': '${notData.key}',
            'spId': profileData.key});
    });
  }

}

import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../model/UserModel.dart';
import '../services/UserService.dart';
import '../view/home.page.dart';
import '../view/login.page.dart';

class UserController {
  final _firebaseAuth = FirebaseAuth.instance;
  final database = FirebaseDatabase.instance.ref();
  User? user = FirebaseAuth.instance.currentUser;
  final userService = UserService();

  void cadastrar(email, senha, confirmarSenha, nome, context) async {
    bool checkSign = true;
    if (email == null || email == ''){
      checkSign = false;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(duration: Duration(seconds: 1),content: Text('Email obrigatório'),),
      );
    }
    if (senha == null || senha == ''){
      checkSign = false;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(duration: Duration(seconds: 1),content: Text('Senha obrigatória'),),
      );
    }
    if (senha.toString() != confirmarSenha.toString()) {
      checkSign = false;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        duration: Duration(seconds: 1),
        content: Text('Senhas diferentes'),
        backgroundColor: Colors.redAccent,
      ),
      );
    }
    if (nome == null || nome == ''){
      checkSign = false;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        duration: Duration(seconds: 1),
        content: Text('Campo nome obrigatório'),
        backgroundColor: Colors.redAccent,
      ),
      );
    }
    if (checkSign == true ){
      try {
          userService.cadastrar(email, senha, confirmarSenha, nome, context);
      } on FirebaseAuthException catch (e) {
        if (e.code == 'weak-password') {
          checkSign = false;
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            duration: Duration(seconds: 1),
            content: Text('Senha fraca.'),
            backgroundColor: Colors.redAccent,
          ),
          );
        }
        else if (e.code == 'email-already-in-use') {
          checkSign = false;
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            duration: Duration(seconds: 1),
            content: Text('Email já cadastrado.'),
            backgroundColor: Colors.redAccent,
          ),
          );
        }
      }

      if (checkSign == true){
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const LoginPage(),
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Cadastro realizado com sucesso!'),
          backgroundColor: Colors.green,
        ),
        );
      }
    }
  }

  void publicar(local, data, numeroDeJogadores, hora, context) async {
    if (local == null || local == ''
        || data == null || local == ''
        || numeroDeJogadores == null ||
        numeroDeJogadores == ''
        || hora == null ||
        hora == '') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha todos os campos'),),
      );
    }
    else {
      userService.publicar(local, data, numeroDeJogadores, hora, context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Jogo criado com sucesso'),
        backgroundColor: Colors.lightGreen,
      ));
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const HomePage(),
        ),
      );
    }
  }

  Future<bool> verificarJogoCriado() async {
    Completer<bool> completer = Completer<bool>();

    database.child('FirulaData/users/${user!.uid}/possuiJogoCriado').onValue.listen((event) {
      final bool possuiJogoCriado = event.snapshot.value as bool;
      completer.complete(possuiJogoCriado);
    });

    bool resultado = await completer.future;
    return resultado;
  }


  login(String email, String senha, context) async {
    try {
      UserCredential? userCredential = await userService.login(email, senha, context);
      if (userCredential != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const HomePage(),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Usuário não encontrado')
        ),
        );
      }
      else if (e.code == 'wrong-password') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Senha incorreta'),),
        );
      }
      if (email == null || email == '') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Email vazio'),),
        );
      }
      if (senha == null || senha == '') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Senha vazia'),),
        );
      }
    }
  }

  void cancelMatch(matchId, userId) async{

    database.child('FirulaData/matches/${matchId}').remove();
    database.child('FirulaData/users/${user!.uid}').update(
        {'possuiJogoCriado' : false});
    final ref = FirebaseDatabase.instance.ref().child('FirulaData/matches/${matchId}/participants').orderByKey();
    ref.get().then((snapshot) {
      for (final participant in snapshot.children) {
        String userId = participant.child("userId").value as String;
        if(userId != user!.uid){
          database.child('FirulaData/users/$userId/solicitParticip/${matchId}').update({
            'situation': 'Partida cancelada!',
          });
        }
      }
    });
    final ref3 = FirebaseDatabase.instance.ref().child('FirulaData/users/${user!.uid}');
    await ref3.child("received").once().then((snapshot) {
      if (snapshot.snapshot.exists) {
        final ref2 = FirebaseDatabase.instance.ref().child('FirulaData/users/${user!.uid}/received').orderByKey();
        ref2.get().then((snapshot) {
          for (final recebido in snapshot.children) {
            String forMatchId = recebido.child("forMatchId").value as String;
            if(forMatchId == matchId){
              database.child('FirulaData/users/${user!.uid}/received/${recebido.key}').remove();
            }
          }
        });
      }
    });


  }


  void carregarInfoPerfil(Function(UserModel) onDataReceived){
    StreamSubscription<DatabaseEvent>? _user;
    _user = database.child('FirulaData/users/${user!.uid}').onValue.listen((event) {
      final userData = UserModel.fromSnapshot(event.snapshot);
        onDataReceived(userData);
      });
  }

  void salvarAlteracoes(bool changedLoc, bool changedPos, String localizController, String posController){
    User? user = FirebaseAuth.instance.currentUser;
    if(changedLoc == true && changedPos == false){
      final profileData = database.child('FirulaData/users/${user!.uid}').update(
          {'localiz': localizController});
    }
    else if(changedLoc == false && changedPos == true){
      final profileData = database.child('FirulaData/users/${user!.uid}').update(
          {'pos': posController});
    }
    else if (changedLoc == true && changedPos == true){
      final profileData = database.child('FirulaData/users/${user!.uid}').update(
          {'localiz': localizController, 'pos': posController});
    }
  }

}
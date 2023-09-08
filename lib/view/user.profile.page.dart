import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key, required this.userId});
  final String userId;

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {

  final _database = FirebaseDatabase.instance.ref();
  String displayname = '';
  String displayemail = '';
  String displayloc = '';
  String displaypos = '';

  @override
  void initState(){
    super.initState();
    _activateListeners();
  }
  late StreamSubscription _user;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        elevation:0,
        leading: BackButton(),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.green, Colors.lightGreen.shade200],
          ),
        ),
        child: Column(
          children: [
            Container(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          leading: Icon(Icons.person, color:Colors.white, size: 40,),
                          title: Text(
                            displayname,
                            style: TextStyle(fontSize: 26, color: Colors.white, fontWeight: FontWeight.bold), // Fonte maior e em negrito
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(left: 74.0), // Ajuste o valor conforme necessário para mover o texto para a direita
                          child: Text(
                            displayloc,
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey,
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: Offset(3, 3),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 90,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.person,
                        size: 80, // Ajuste o tamanho conforme necessário
                        color: Colors.grey, // Escolha a cor que desejar
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: Container(
                padding: EdgeInsets.fromLTRB(2, 20, 2, 15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  children: <Widget>[
                    ListTile(
                      leading: Icon(Icons.email, color:Colors.black, size: 40,),
                      title: Text(displayemail, style: const TextStyle(fontSize: 22),),
                    ),
                    SizedBox(height: 30,),
                    ListTile(
                      leading: Icon(Icons.directions_run, color:Colors.black, size: 40,),
                      title: Text(displaypos, style: const TextStyle(fontSize: 22),),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _activateListeners() async{
    _user = _database.child('FirulaData/users/${widget.userId}/nome').onValue.listen((event) {
      final String nome = event.snapshot.value as String;
      print("Nome: $nome");  // Adicionando uma instrução print para verificar se o nome está sendo recebido corretamente
      _database
          .child('FirulaData/users/${widget.userId}/localiz')
          .onValue
          .listen((event) {
        final String localiz = event.snapshot.value as String;
        print("Localização: $localiz"); // Verificando a localização
        _database
            .child('FirulaData/users/${widget.userId}/pos')
            .onValue
            .listen((event) {
          final String pos = event.snapshot.value as String;
          print("Posição: $pos"); // Verificando a posição
          _database
              .child('FirulaData/users/${widget.userId}/email')
              .onValue
              .listen((event) {
            final String email = event.snapshot.value as String;
            print("Email: $email"); // Verificando o email

            setState(() {
              displayname = nome;
              displayloc = localiz.isEmpty ? 'Não definido' : localiz;
              displaypos = pos.isEmpty ? 'Não definido' : pos;
              displayemail = email;
            });
          });
        });
      });
    });
  }
}

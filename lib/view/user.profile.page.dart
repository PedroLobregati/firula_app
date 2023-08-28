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
        elevation:0,
        leading: BackButton(),
        title: Text('Usuário Firula'),
      ),
        body:
        Container(
          padding: EdgeInsets.fromLTRB(2, 20, 2, 15),
          child: Column(
            children: <Widget>[
              ListTile(

                leading: Icon(Icons.person, color:Colors.black, size: 40,),
                title: Text(displayname, style: const TextStyle(fontSize: 22),),
              ),
              SizedBox(height: 30,),

              ListTile(
                leading: Icon(Icons.place_outlined, color:Colors.black, size: 40,),
                title: Text(displayloc, style: const TextStyle(fontSize: 22),),
              ),
              SizedBox(height: 30,),

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

     );
  }













  void _activateListeners(){
    _user = _database.child('FirulaData/users/${widget.userId}/nome').onValue.listen((event) {
      final String nome = event.snapshot.value as String;
      _database
          .child('FirulaData/users/${widget.userId}/localiz')
          .onValue
          .listen((event) {
        final String localiz = event.snapshot.value as String;
        _database
            .child('FirulaData/users/${widget.userId}/pos')
            .onValue
            .listen((event) {
          final String pos = event.snapshot.value as String;

          _database
              .child('FirulaData/users/${widget.userId}/email')
              .onValue
              .listen((event) {
            final String email = event.snapshot.value as String;

            setState(() {
              displayname = nome;
              localiz == "" ? displayloc = 'Não definido' : displayloc = localiz;
              pos == "" ? displaypos = 'Não definido' : displaypos = pos;
              displayemail = email;
            });
          });
        });
      });
    });

  }
}

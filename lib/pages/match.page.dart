import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firula_app/pages/user.profile.page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'home.page.dart';

class MatchPage extends StatefulWidget {
  const MatchPage({super.key, required this.matchId});
  final String matchId;

  @override
  State<MatchPage> createState() => _MatchPageState();
}

class _MatchPageState extends State<MatchPage> {
  final _database = FirebaseDatabase.instance.ref();

  @override
  void initState(){
    super.initState();
    _activateListeners();
  }
  late StreamSubscription _match;
  String displayLocal = '';
  String displayTime = '';
  String displayHost = '';
  String displayData = '';
  int onList = 1;
  int nMax = 0;
  bool _isListFull = false;
  DateTime? buttonClicked;
  bool _isHost = false;
  User? user = FirebaseAuth.instance.currentUser;

  bool alreadyClicked(DateTime currentTime) {
    if (buttonClicked == null) {
      buttonClicked = currentTime;
      return false;
    }
    if (currentTime.difference(buttonClicked!).inSeconds < 10) {
      return true;
    }
    buttonClicked = currentTime;
    return true;
  }

  void _activateListeners(){
    User? user = FirebaseAuth.instance.currentUser;
    _match = _database.child('FirulaData/matches/${widget.matchId}/local').onValue.listen((event) {
      final String localiz = event.snapshot.value as String;
      _database
          .child('FirulaData/matches/${widget.matchId}/time')
          .onValue
          .listen((event) {
        final String time = event.snapshot.value as String;
        _database
            .child('FirulaData/matches/${widget.matchId}/host')
            .onValue
            .listen((event) {
          final String host = event.snapshot.value as String;
          _database
              .child('FirulaData/matches/${widget.matchId}/onList')
              .onValue
              .listen((event) {
            final int onList1 = event.snapshot.value as int;
            _database
                .child('FirulaData/matches/${widget.matchId}/data')
                .onValue
                .listen((event) {
              final String data = event.snapshot.value as String;

              _database
                  .child('FirulaData/matches/${widget.matchId}/nPlayers')
                  .onValue
                  .listen((event) {
                final int nMax1 = event.snapshot.value as int;

                _database
                    .child('FirulaData/matches/${widget.matchId}/hostId')
                    .onValue
                    .listen((event) {
                      final String hostId = event.snapshot.value as String;

                  setState(() {
                    displayLocal = localiz;
                    displayTime = time;
                    displayHost = host;
                    displayData = data;
                    onList = onList1;
                    nMax = nMax1;
                    if (onList >= nMax) {
                      _isListFull = true;
                    }
                    if (hostId == user!.photoURL){
                      _isHost = true;
                    }
                  });
                });
              });
            });
          });
        });
      });
    });
  }

  void _sendToHost() async {
    User? user = FirebaseAuth.instance.currentUser;

    final profileData = _database.child('FirulaData/users/${user!.photoURL}/solicitParticip/${widget.matchId}');
    await profileData.set({
      'matchLocal' : displayLocal,
      'matchData'  : displayData,
      'situation' : 'Aguardando resposta...',
    });

      _database
          .child('FirulaData/matches/${widget.matchId}/hostId')
          .onValue
          .listen((event) async {
        final userName = user!.displayName;
        final getHostId = event.snapshot.value as String;
        print(getHostId);
        final notData = _database.child(
            'FirulaData/users/$getHostId/received').push();
        await notData.set(
            {'content': "Solicitação de participação de $userName",
              'senderId': '${user.photoURL}',
              'forMatchId': '${widget.matchId}',
              'username': '$userName',
              'notId': '${notData.key}',
              'spId': profileData.key});
      });

  }

  void cancelMatch() async{

    _database.child('FirulaData/matches/${widget.matchId}').remove();
    _database.child('FirulaData/users/${user!.photoURL}').update(
        {'possuiJogoCriado' : false});
    final ref = FirebaseDatabase.instance.ref().child('FirulaData/matches/${widget.matchId}/participants').orderByKey();
    ref.get().then((snapshot) {
      for (final participant in snapshot.children) {
        String userId = participant.child("userId").value as String;
        if(userId != user!.photoURL){
          _database.child('FirulaData/users/$userId/solicitParticip/${widget.matchId}').update({
            'situation': 'Partida cancelada!',
          });
        }
      }
    });
    final ref3 = FirebaseDatabase.instance.ref().child('FirulaData/users/${user!.photoURL}');
    await ref3.child("received").once().then((snapshot) {
      if (snapshot.snapshot.exists) {
        final ref2 = FirebaseDatabase.instance.ref().child('FirulaData/users/${user!.photoURL}/received').orderByKey();
        ref2.get().then((snapshot) {
          for (final recebido in snapshot.children) {
            String forMatchId = recebido.child("forMatchId").value as String;
            if(forMatchId == widget.matchId){
              _database.child('FirulaData/users/${user!.photoURL}/received/${recebido.key}').remove();
            }
          }
        });
      }
    });


  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/match3.jpg"),
              fit: BoxFit.cover,
              opacity: 100,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
              Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: (){
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HomePage(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.arrow_back_ios),
                ),
              ],
              ),
                SizedBox(height: 20,),

                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.35),
                        ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.place),
                                      SizedBox(width: 20,),
                                      Text(displayLocal,
                                        style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, fontFamily: 'sans-serif-light'),),

                                    ],
                                  ),

                                  Row(
                                    children: [
                                      Icon(Icons.calendar_month_rounded),
                                      SizedBox(width: 20,),
                                      Text(displayData,
                                        style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, fontFamily: 'sans-serif-light'),),

                                    ],
                                  ),

                                  Row(
                                    children: [
                                      Icon(Icons.watch_later),
                                      SizedBox(width: 20,),
                                      Text(displayTime,
                                        style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, fontFamily: 'sans-serif-light'),),

                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),

                      ),
                    ),
                  ],
                ),
                SizedBox(height: 40,),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                     Icon(Icons.stars),
                     SizedBox(width: 6,),
                     Text("Criado por: $displayHost",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
                  ],
                ),
                SizedBox(height: 45,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton.icon(onPressed: (){}, icon: Icon(Icons.checklist, color: Colors.black,), label: Text("Lista vigente", style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold, color: Colors.black,),)),
                    Text("   ($onList / $nMax)",
                      style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Colors.green),)
                  ],
                ),

                StreamBuilder(stream:
                _database.child('FirulaData/matches/${widget.matchId}/participants').orderByKey().limitToLast(10).onValue,
                    builder: (context, snapshot) {
                      final tileList = <ListTile>[];
                      if(snapshot.hasData) {
                        final participants = Map<String, dynamic>.from(
                            snapshot.data!.snapshot.value as dynamic);
                        participants.forEach((key, value) {
                          final nextParticipant = Map<String, dynamic>.from(value);
                          String userId = nextParticipant['userId'] as String;
                          final orderTile = ListTile(
                            leading: const Icon(Icons.person, size: 26,),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => UserProfilePage(userId: userId,),
                                ),
                              );
                            },
                            title: Text("${nextParticipant['username']}",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),),
                          );
                          tileList.add(orderTile);
                        });
                      }
                      return Expanded(
                        child: ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          shrinkWrap: true,
                          children:
                          tileList,
                        ),
                      );
                    }
                ),

                _buildButton(),
              ],
            ),
          ),
        ),

      ),
    );
  }
  Widget _buildButton(){
    if(_isHost){
      return Padding(
        padding: const EdgeInsets.only(top: 30),
        child: ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xffD03838)),
            onPressed: (){
             showAlertDialog(context);

            },
            child: const Text(
             "Cancelar partida",
              style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold,
              ),)),
      );
    }
    else {
      return Padding(
        padding: const EdgeInsets.only(top: 30),
        child: ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: _isListFull ? Colors.white70 : Color(0xffA2C850)),
            onPressed: () async {
              _isListFull ? null : _sendToHost();
            },
            child: Text(
              _isListFull ? "Lista Fechada" : "Solicitar participação",
              style: const TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold,
              ),)),
      );
    }
  }

  showAlertDialog(BuildContext context) {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: Text("Voltar"),
      onPressed:  () {
        Navigator.pop(context);
      },
    );
    Widget continueButton = TextButton(
      child: const Text("Confirmar", style: TextStyle(color: Colors.red)),
      onPressed:  () async {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Partida cancelada!'),
        ),
        );
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const HomePage(),
          ),
        );
        cancelMatch();
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Confirmação"),
      content: Text("Tem certeza que deseja cancelar a partida? Não será possível reverter a ação."),
      actions: [
        cancelButton,
        continueButton,
      ],
    );
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}



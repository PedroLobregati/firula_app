import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firula_app/controller/MatchController.dart';
import 'package:firula_app/services/UserService.dart';
import 'package:firula_app/view/user.profile.page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import '../model/MatchModel.dart';
import 'home.page.dart';

class MatchPage extends StatefulWidget {
  const MatchPage({super.key, required this.matchId});
  final String matchId;


  @override
  State<MatchPage> createState() => _MatchPageState();
}

class _MatchPageState extends State<MatchPage> {
  final _database = FirebaseDatabase.instance.ref();
  final MatchController _matchController = MatchController();
  MatchModel? _matchData;

  @override
  void initState(){
    super.initState();
    _matchController.CarregarinformacoesDaPartida(widget.matchId, _onDataReceived);
    alreadyClicked();
  }

  void _onDataReceived(MatchModel matchData) {
    setState(() {
      _matchData = matchData;
    });
  }

  late StreamSubscription _match;
  int onList = 1;
  int nMax = 0;
  bool _isListFull = false;
  DateTime? buttonClicked;
  DateTime currentTime = DateTime.now();
  User? user = FirebaseAuth.instance.currentUser;
  bool solicitacaoEnviada = false;
  final userService = UserService();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter, // Modificado para atingir o topo da página
              colors: [Colors.lightGreen.shade200, Colors.white],
            ),
          ),
          child: Column(
            children: [
              ClipPath(
                clipper: WaveClipper(),
                child: Container(
                  height: 150,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.green, Colors.lightGreen.shade200],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            PageTransition(
                              type: PageTransitionType.leftToRight,
                              child: const HomePage(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                      ),
                      Text(
                        "Jogo de ${_matchData!.host}",
                        style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Stack(
                    children: [
                      Container(
                        width: 350,
                        padding: EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Colors.lightGreen.shade100,
                          borderRadius: BorderRadius.circular(15.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 5,
                              blurRadius: 7,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.place),
                                SizedBox(width: 20),
                                Expanded(
                                  child: Text(
                                    '${_matchData!.local}',
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'sans-serif-light'),
                                    softWrap: true,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.calendar_month_rounded),
                                SizedBox(width: 20),
                                Expanded(
                                  child: Text(
                                    '${_matchData!.data}',
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'sans-serif-light'),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.watch_later),
                                SizedBox(width: 20),
                                Expanded(
                                  child: Text(
                                    '${_matchData!.time}',
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'sans-serif-light'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.green,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  SizedBox(width: 6),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Criado por: ${_matchData!.host}",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 45),
              Expanded(
                child: Container(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton.icon(
                            onPressed: () {},
                            icon: Icon(Icons.checklist, color: Colors.black),
                            label: Text("Lista vigente", style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold, color: Colors.black)),
                          ),
                          Text(
                            "   (${_matchData!.onList} / ${_matchData!.nPlayers})",
                            style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Colors.green),
                          ),
                        ],
                      ),
                      Expanded(
                        child: StreamBuilder(
                          stream: _database.child('FirulaData/matches/${widget.matchId}/participants').orderByKey().limitToLast(10).onValue,
                          builder: (context, snapshot) {
                            final tileList = <ListTile>[];
                            if (snapshot.hasData) {
                              final participants = Map<String, dynamic>.from(snapshot.data!.snapshot.value as dynamic);
                              participants.forEach((key, value) {
                                final nextParticipant = Map<String, dynamic>.from(value);
                                String userId = nextParticipant['userId'] as String;
                                final orderTile = ListTile(
                                  leading: const Icon(Icons.person, size: 26),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => UserProfilePage(userId: userId),
                                      ),
                                    );
                                  },
                                  title: Text(
                                    "${nextParticipant['username']}",
                                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                  ),
                                );
                                tileList.add(orderTile);
                              });
                            }
                            return ListView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              shrinkWrap: true,
                              children: tileList,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: SizedBox(
          height: 100,
          child: Center(
            child: _buildButton(),
          ),
        ),
      ),
    );
  }


  Widget _buildButton(){
    if(user!.uid == _matchData!.hostId){
      return Padding(
        padding: const EdgeInsets.only(top: 0),
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
    else{
      return Padding(
        padding: const EdgeInsets.only(top: 30),
        child: ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: _isListFull || solicitacaoEnviada ? Colors.white70 : Color(0xffA2C850)),
            onPressed: () async {
              _isListFull || solicitacaoEnviada ? null : userService.sendToHost(widget.matchId, _matchData!.local, _matchData!.data);
              setState(() {
                solicitacaoEnviada = true;
              });
            },
            child: Text(
              _isListFull ? "Lista Fechada" : solicitacaoEnviada ? "Solicitação enviada" : "Solicitar participação",
              style: TextStyle(color: _isListFull || solicitacaoEnviada ? Colors.grey : Colors.black,
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
        _matchController.cancelMatch(widget.matchId);
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

  void alreadyClicked(){
    _database.child('FirulaData/users/${user!.uid}/solicitParticip/${widget.matchId}/situation').once().then((DatabaseEvent event) {
      print(event.snapshot.value);
      if(event.snapshot.value != null){
        setState(() {
          solicitacaoEnviada = true;
        });
      }
    });
  }
}

class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 20);

    var firstControlPoint = Offset(size.width / 4, size.height);
    var firstEndPoint = Offset(size.width / 2.25, size.height - 30);
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy,
        firstEndPoint.dx, firstEndPoint.dy);

    var secondControlPoint =
    Offset(size.width - (size.width / 3.25), size.height - 65);
    var secondEndPoint = Offset(size.width, size.height - 40);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy,
        secondEndPoint.dx, secondEndPoint.dy);

    path.lineTo(size.width, size.height - 40);
    path.lineTo(size.width, 0);

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}













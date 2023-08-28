import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firula_app/controller/MatchController.dart';
import 'package:firula_app/services/UserService.dart';
import 'package:firula_app/view/user.profile.page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
    MediaQueryData queryData;
    queryData = MediaQuery.of(context);
    return SafeArea(
      child: Scaffold(
        body: Container(
          height: queryData.size.height,
          width: queryData.size.width,
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
                                      Text('${_matchData!.local}',
                                        style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, fontFamily: 'sans-serif-light'),),

                                    ],
                                  ),

                                  Row(
                                    children: [
                                      Icon(Icons.calendar_month_rounded),
                                      SizedBox(width: 20,),
                                      Text('${_matchData!.data}',
                                        style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, fontFamily: 'sans-serif-light'),),

                                    ],
                                  ),

                                  Row(
                                    children: [
                                      Icon(Icons.watch_later),
                                      SizedBox(width: 20,),
                                      Text('${_matchData!.time}',
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
                     Text("Criado por: ${_matchData!.host}",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
                  ],
                ),
                SizedBox(height: 45,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton.icon(onPressed: (){}, icon: Icon(Icons.checklist, color: Colors.black,), label: Text("Lista vigente", style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold, color: Colors.black,),)),
                    Text("   (${_matchData!.onList} / ${_matchData!.nPlayers})",
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
    if(user!.uid == _matchData!.hostId){
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













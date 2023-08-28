import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firula_app/model/MatchModel.dart';

import '../services/UserService.dart';

class MatchController{
  final _firebaseAuth = FirebaseAuth.instance;
  final _database = FirebaseDatabase.instance.ref();
  User? user = FirebaseAuth.instance.currentUser;
  final userService = UserService();

  StreamSubscription<DatabaseEvent>? _matchSubscription;

  void CarregarinformacoesDaPartida(String matchId, Function(MatchModel) onDataReceived){
    _matchSubscription = _database.child('FirulaData/matches/$matchId').onValue.listen((event) {
      final matchData = MatchModel.fromSnapshot(event.snapshot);
      onDataReceived(matchData);
    });
  }




  void cancelMatch(String matchId) async{

    _database.child('FirulaData/matches/$matchId').remove();
    _database.child('FirulaData/users/${user!.uid}').update(
        {'possuiJogoCriado' : false});
    final ref = FirebaseDatabase.instance.ref().child('FirulaData/matches/$matchId/participants').orderByKey();
    ref.get().then((snapshot) {
      for (final participant in snapshot.children) {
        String userId = participant.child("userId").value as String;
        if(userId != user!.uid){
          _database.child('FirulaData/users/$userId/solicitParticip/$matchId').update({
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
              _database.child('FirulaData/users/${user!.uid}/received/${recebido.key}').remove();
            }
          }
        });
      }
    });
  }

}
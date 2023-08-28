import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class MatchService{
  final _firebaseAuth = FirebaseAuth.instance;
  final database = FirebaseDatabase.instance.ref();
  User? user = FirebaseAuth.instance.currentUser;

  void cancelMatch(String matchId) async{

    database.child('FirulaData/matches/$matchId').remove();
    database.child('FirulaData/users/${user!.uid}').update(
        {'possuiJogoCriado' : false});
    final ref = FirebaseDatabase.instance.ref().child('FirulaData/matches/$matchId/participants').orderByKey();
    ref.get().then((snapshot) {
      for (final participant in snapshot.children) {
        String userId = participant.child("userId").value as String;
        if(userId != user!.uid){
          database.child('FirulaData/users/$userId/solicitParticip/$matchId').update({
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
}
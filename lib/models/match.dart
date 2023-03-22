import 'package:firebase_auth/firebase_auth.dart';



class Match {
  final String local, time, data,host, id, hostId;
  final int nPlayers;

  Match({required this.local, required this.data,
    required this.time, required this.nPlayers,
    required this.host, required this.id,
    required this.hostId,});

  factory Match.fromRTDB(Map<String,dynamic> data){
    return Match(
        local: data['local'], data: data['data'],
        time: data['time'], nPlayers: data['nPlayers'],
        host: data['host'], id: data['id'], hostId: data['hostId'],);
  }
}


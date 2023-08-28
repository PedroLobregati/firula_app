import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class MatchModel {
  final String local, time, data,host, hostId;
  final int nPlayers, onList;

  MatchModel({required this.local, required this.data,
    required this.time, required this.nPlayers,
    required this.host, required this.onList,
    required this.hostId,});

  factory MatchModel.fromSnapshot(DataSnapshot snapshot) {
    final data = snapshot.value as Map<dynamic, dynamic>;
    return MatchModel(
      local: data['local'],
      time: data['time'],
      host: data['host'],
      onList: data['onList'],
      data: data['data'],
      nPlayers: data['nPlayers'],
      hostId: data['hostId'],
    );
  }
}


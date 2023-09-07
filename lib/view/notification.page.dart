import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

import 'home.page.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({Key? key}) : super(key: key);

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final _database = FirebaseDatabase.instance.ref();
  User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
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
                                  child: const HomePage()));
                        },
                        icon: const Icon(Icons.arrow_back_ios, color: Colors.white)),
                    Text("Notificações", style: TextStyle(fontSize: 17, color: Colors.white)),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            StreamBuilder(
                stream: _database.child('FirulaData/users/${user!.uid}/received').orderByKey().limitToLast(10).onValue,
                builder: (context, snapshot) {
                  final tileList = <Widget>[];
                  if (snapshot.data!.snapshot.exists) {
                    final myNotifications = Map<String, dynamic>.from(
                        snapshot.data!.snapshot.value as dynamic);
                    myNotifications.forEach((key, value) {
                      final nextNotification = Map<String, dynamic>.from(value);
                      final orderTile = Container(
                        margin: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: Offset(0, 3), // changes position of shadow
                            ),
                          ],
                        ),
                        child: ListTile(
                          leading: const Icon(Icons.circle_notifications, color: Colors.red),
                          onTap: () {
                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return Dialog(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                        BorderRadius.circular(20.0)),
                                    child: Container(
                                      height: 200,
                                      child: Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            const TextField(
                                              decoration: InputDecoration(
                                                  border: InputBorder.none,
                                                  hintText: 'Inserir usuário na lista?'),
                                              textAlign: TextAlign.center,
                                              style: TextStyle(fontSize: 20),
                                            ),
                                            SizedBox(
                                              width: 320.0,
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                children: [
                                                  ElevatedButton(
                                                    onPressed: () async{

                                                      final matchData = _database
                                                          .child(
                                                          'FirulaData/matches/${nextNotification['forMatchId']}/participants')
                                                          .push();
                                                      await matchData.set({
                                                        'username': nextNotification['username'],
                                                        'userId': nextNotification['senderId']
                                                      });
                                                      _database.child(
                                                          'FirulaData/matches/${nextNotification['forMatchId']}/onList')
                                                          .set(ServerValue
                                                          .increment(1));
                                                      _database.child(
                                                          'FirulaData/users/${user!
                                                              .uid}/received/${nextNotification['notId']}')
                                                          .remove();
                                                      Navigator.pop(context);

                                                      final profileData = _database
                                                          .child(
                                                          'FirulaData/users/${nextNotification['senderId']}/solicitParticip/${nextNotification['spId']}')
                                                          .update({
                                                        'situation': 'Na lista!',
                                                      });
                                                    },
                                                    child: Text(
                                                      "Aceitar",
                                                      style: TextStyle(color: Colors.white),
                                                    ),
                                                  ),
                                                  ElevatedButton(
                                                    onPressed: () async {
                                                      _database.child('FirulaData/users/${user!.uid}/received/${nextNotification['notId']}').remove();
                                                      _database.child('FirulaData/users/${nextNotification['senderId']}/solicitParticip/${nextNotification['spId']}');
                                                      _database
                                                          .child(
                                                          'FirulaData/users/${nextNotification['senderId']}/solicitParticip/${nextNotification['spId']}')
                                                          .update({
                                                        'situation': 'Partida cancelada!',
                                                      });
                                                      Navigator.pop(context);
                                                    },
                                                    child: Text(
                                                      "Recusar",
                                                      style: TextStyle(color: Colors.white),
                                                    ),
                                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                                  ),
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                });
                          },
                          title: Text("${nextNotification['content']}",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: const Text("Notificação"),
                        ),
                      );
                      tileList.add(orderTile);
                    });
                  }
                  return Expanded(
                    child: ListView(
                      children: tileList,
                    ),
                  );
                }
            ),
          ],
        ),
      ),
    );
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

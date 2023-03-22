import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firula_app/models/user.dart';
import 'package:firula_app/pages/home.page.dart';
import 'package:firula_app/pages/login.page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firula_app/services/auth_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _firebaseAuth = FirebaseAuth.instance;
  final _database = FirebaseDatabase.instance.ref();
  String displayname = '';
  String displayemail = '';
  String displayloc = '';
  String displaypos = '';
  final _localizController = TextEditingController();
  final _posController = TextEditingController();
  bool changedLoc = false;
  bool changedPos = false;

  @override
  void initState(){
    super.initState();
    _activateListeners();
  }
  late StreamSubscription _user;

  void _activateListeners(){
    User? user = FirebaseAuth.instance.currentUser;
    final uid = user!.photoURL;
    _user = _database.child('FirulaData/users/$uid/localiz').onValue.listen((event) {
      final String localiz = event.snapshot.value as String;
      _database.child('FirulaData/users/$uid/pos').onValue.listen((event) {
        final String pos = event.snapshot.value as String;
        setState(() {
          displayname = user.displayName!;
          displayemail = user.email!;
          displayloc = localiz;
          displaypos = pos;
        });
      });
    });

  }




  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: SingleChildScrollView(
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/FirulaCarta.png"),
                fit: BoxFit.cover,
                opacity: 1,
              ),
            ),

            padding: EdgeInsets.all(8.0),

            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(onPressed: (){
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HomePage(),
                        ),
                      );
                    },
                        icon: const Icon(Icons.arrow_back_ios), color: Colors.white,),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.black,
                      side: BorderSide(color: Colors.lightGreen)),
                        onPressed: () async {
                          showAlertDialog(context);
                        },
                        child: Text('Sair', style: TextStyle(
                          fontWeight: FontWeight.w100,
                          color: Colors.lightGreen,
                        ),),
                    ),
                  ],
                ),
                SizedBox(height: 265,),

                Text("${displayname.toUpperCase()}", style: TextStyle(fontSize: 30, color: Colors.white,
                fontWeight: FontWeight.bold,),),


                SingleChildScrollView(
                  child: Stack(
                    children: [Padding(
                      padding: const EdgeInsets.only(left: 170),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 50, top: 3.0),
                            child: TextFormField(
                              style: TextStyle(
                                color: Colors.white,
                              ),
                              controller: _posController,
                              onFieldSubmitted: (String empty){
                                displaypos = _posController.text;
                                changedPos = true;
                              },
                              decoration: InputDecoration(
                                floatingLabelBehavior: FloatingLabelBehavior.never,
                                labelText: displaypos == '' ? "Definir posição..." : displaypos,
                                labelStyle: TextStyle(
                                  fontSize: 17.5,
                                  color: Colors.white70,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.only(top:8.0),
                              
                            child: Text(displayemail,
                              style: TextStyle(fontSize: 15, color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),


                          Padding(
                            padding: EdgeInsets.only(left: 50, top: 10),
                            child: TextFormField(
                              style: TextStyle(
                                color: Colors.white,
                              ),
                              controller: _localizController,
                              onFieldSubmitted: (String empty){
                                displayloc = _localizController.text;
                                changedLoc = true;
                              },
                              decoration: InputDecoration(
                                floatingLabelBehavior: FloatingLabelBehavior.never,
                                labelText: displayloc == '' ? "Definir localização..." : displayloc,
                                labelStyle: TextStyle(
                                  fontSize: 17.5,
                                  color: Colors.white70,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),

                        ],
                      ),
                    )],
                  ),
                ),
                SizedBox(height: 62.5,),
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.black,
                  ),
                    onPressed: () async {
                      User? user = FirebaseAuth.instance.currentUser;
                      final uid = user!.photoURL;
                      if(changedLoc == true && changedPos == false){
                        final profileData = _database.child('FirulaData/users/$uid').update(
                            {'localiz': _localizController.text});
                      }
                      else if(changedLoc == false && changedPos == true){
                        final profileData = _database.child('FirulaData/users/$uid').update(
                            {'pos': _posController.text});
                      }
                      else if (changedLoc == true && changedPos == true){
                        final profileData = _database.child('FirulaData/users/$uid').update(
                            {'localiz': _localizController.text, 'pos': _posController.text});
                      }

                    },
                    child: const Text('Salvar alterações',
                      style: TextStyle(fontSize: 15),)),

              ],
            ),
          ),
        ),
      ),
    );
  }


  sair() async {
    await _firebaseAuth.signOut().then(
            (user)=> Navigator.pushReplacement(
            context,
            MaterialPageRoute(
            builder: (context) => LoginPage(),
            ),
            ),
    );
  }

  @override
  void deactivate(){
    _user.cancel();
    super.deactivate();
  }

  showAlertDialog(BuildContext context) {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: Text("Voltar", style: TextStyle(fontWeight: FontWeight.bold),),
      onPressed:  () {
        Navigator.pop(context);
      },
    );
    Widget continueButton = TextButton(
      child: const Text("Logout", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      onPressed:  () async {
        sair();
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Confirmação"),
      content: Text("Deseja fazer logout?"),
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

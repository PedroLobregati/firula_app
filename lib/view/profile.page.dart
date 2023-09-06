import 'dart:async';
// EDITADO 0307
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:provider/provider.dart';
import 'package:firula_app/view/home.page.dart';
import 'package:firula_app/view/login.page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firula_app/provider/google_sign_in.dart';

import '../controller/UserController.dart';
import '../model/UserModel.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _firebaseAuth = FirebaseAuth.instance;
  User? user = FirebaseAuth.instance.currentUser;
  final userController = UserController();
  String displayname = '';
  String displayemail = '';
  String displayloc = '';
  String displaypos = '';
  final _localizController = TextEditingController();
  final _posController = TextEditingController();
  bool changedLoc = false;
  bool changedPos = false;
  UserModel? userModel;

  @override
  void initState(){
    super.initState();
    userController.carregarInfoPerfil(_onDataReceived);
  }
  late StreamSubscription _user;

  void _onDataReceived(UserModel userData) {
    setState(() {
      userModel = userData;
    });
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData queryData;
    queryData = MediaQuery.of(context);
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

                Text("${user?.displayName!}", style: TextStyle(fontSize: 30, color: Colors.white,
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
                                labelText: userModel!.pos == '' ? "Definir posição..." : userModel!.pos,
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

                            child: Text(userModel?.email == null ? " " : userModel!.email,
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
                                labelText: userModel!.localiz== '' ? "Definir localização..." : userModel!.localiz,
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
                      userController.salvarAlteracoes(changedLoc, changedPos, _localizController.text, _posController.text);
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
        final provider = Provider.of<GoogleSignInProvider>(context, listen: false);
        provider.googleLogout();
        sair();
        //final provider = Provider.of<GoogleSignInProvider>(context, listen: false);
        //provider.googleLogout().then(
        //(user)=> Navigator.pushReplacement(
        //context,
        //MaterialPageRoute(
        //builder: (context) => LoginPage(),
        //),
        //),
        //);
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